"""
SMS Campaign admin views.

Endpoints:
  GET/POST   /api/sms/contacts/              list + create single
  POST       /api/sms/contacts/bulk/          bulk import (textarea or CSV)
  GET/POST   /api/sms/campaigns/             list + create
  GET        /api/sms/campaigns/<id>/         detail
  POST       /api/sms/campaigns/<id>/queue/   queue for send
  POST       /api/sms/campaigns/<id>/send/    actually send (sync, runs in-request)
  GET        /api/sms/campaigns/<id>/deliveries/  delivery log
"""
import csv
import io
import logging

from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from users.permissions import IsAdminRole

from .models import Contact, Campaign, Delivery, normalize_phone
from .serializers import (
    ContactSerializer, ContactBulkSerializer,
    CampaignSerializer, DeliverySerializer,
)
from .services import queue_campaign, send_campaign

logger = logging.getLogger(__name__)


# ── Contacts ──────────────────────────────────────────────────────────────

class ContactDetailView(generics.RetrieveUpdateDestroyAPIView):
    """GET / PATCH / DELETE one contact by id."""
    queryset = Contact.objects.all()
    serializer_class = ContactSerializer
    permission_classes = [IsAdminRole]


class ContactBulkDeleteView(APIView):
    """
    POST /api/sms/contacts/bulk-delete/   {ids: [1,2,3]}  OR  {all: true}

    Used by the admin "Delete selected" / "Delete all" affordances. The
    `all` form skips passing ids over the wire for very large lists.
    """
    permission_classes = [IsAdminRole]

    def post(self, request):
        if request.data.get('all'):
            deleted, _ = Contact.objects.all().delete()
            return Response({'deleted': deleted})
        ids = request.data.get('ids') or []
        if not isinstance(ids, list) or not ids:
            return Response({'detail': 'Provide a non-empty `ids` list, or `all: true`.'},
                            status=status.HTTP_400_BAD_REQUEST)
        deleted, _ = Contact.objects.filter(pk__in=ids).delete()
        return Response({'deleted': deleted})


class ContactListCreateView(generics.ListCreateAPIView):
    queryset = Contact.objects.all()
    serializer_class = ContactSerializer
    permission_classes = [IsAdminRole]
    search_fields = ['phone', 'name', 'tag']
    ordering_fields = ['created_at', 'phone']
    ordering = ['-created_at']

    def create(self, request, *args, **kwargs):
        """
        Override to short-circuit duplicate phones with an idempotent
        response. Without this, the unique constraint raises IntegrityError
        and DRF returns a 500.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data['phone']  # already normalised
        existing = Contact.objects.filter(phone=phone).first()
        if existing:
            return Response(
                ContactSerializer(existing).data,
                status=status.HTTP_200_OK,
                headers={'X-Woodmark-Duplicate': '1'},
            )
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class ContactBulkImportView(APIView):
    """
    POST /api/sms/contacts/bulk/

    Body options:
      - numbers: multi-line or comma-separated phone numbers.
      - csv_file: uploaded CSV with phone,name,tag columns.
      - tag: optional tag to apply to all imported contacts.
    """
    permission_classes = [IsAdminRole]

    def post(self, request):
        import re as _re
        from django.db import IntegrityError, transaction

        tag = (request.data.get('tag') or '').strip()
        contacts_created = 0
        contacts_skipped = 0
        errors = []

        # ─── Step 1: collect every candidate phone in one normalized list ──
        # Doing the collection up-front lets us dedupe across BOTH the
        # textarea AND the CSV in one pass — otherwise the same number
        # showing in both inputs (or twice in the textarea) would loop
        # through get_or_create twice and double-count `skipped`.
        candidates = []   # list of (normalized_phone, name, source)
        seen = set()      # set of normalized phones we've already queued

        def _queue(raw, *, name='', source='manual'):
            if not raw:
                return
            phone = normalize_phone(raw)
            digits = _re.sub(r'\D', '', phone)
            if len(digits) < 10:
                errors.append(f'Invalid: {raw}')
                return
            if phone in seen:        # in-batch duplicate -> silently skip
                return
            seen.add(phone)
            candidates.append((phone, name, source))

        raw_numbers = (request.data.get('numbers') or '').strip()
        if raw_numbers:
            for raw in _re.split(r'[,;\n]+', raw_numbers):
                _queue(raw.strip(), source='bulk_textarea')

        # ── Structured "contacts" payload — used by the wishlist-loader so
        # we preserve each user's name + tag, not just their phone. ──
        # Accept either a list of dicts or a JSON-encoded string of the same.
        contacts_payload = request.data.get('contacts')
        if isinstance(contacts_payload, str):
            try:
                import json
                contacts_payload = json.loads(contacts_payload)
            except (ValueError, TypeError):
                contacts_payload = None
        if isinstance(contacts_payload, list):
            for row in contacts_payload:
                if not isinstance(row, dict):
                    continue
                _queue(
                    (row.get('phone') or '').strip(),
                    name=(row.get('name') or '').strip(),
                    source='structured',
                )

        csv_file = request.FILES.get('csv_file')
        if csv_file:
            try:
                text = csv_file.read().decode('utf-8-sig')
                reader = csv.DictReader(io.StringIO(text))
                for row in reader:
                    phone_raw = (row.get('phone') or row.get('Phone')
                                 or row.get('number') or '').strip()
                    name = (row.get('name') or row.get('Name') or '').strip()
                    row_tag = (row.get('tag') or row.get('Tag') or tag or '').strip()
                    _queue(phone_raw, name=name, source='csv')
                    # Tag override per CSV row — we apply it at insert time.
                    if row_tag and candidates and candidates[-1][0] in seen:
                        # mutate the last queued entry's tag in-place
                        candidates[-1] = (candidates[-1][0], name, 'csv')
            except Exception as e:
                logger.exception('CSV import failed')
                errors.append(f'CSV parse error: {e}')

        # Accept any of: numbers (textarea), csv_file (upload), contacts (JSON).
        if not raw_numbers and not csv_file and not isinstance(contacts_payload, list):
            return Response(
                {'detail': 'Provide one of: "numbers" (text), "csv_file" (file '
                           'upload), or "contacts" (JSON list of {phone, name}).'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # ─── Step 2: insert each unique phone with race-safe duplicate
        # handling. Even though we deduped in-memory, two admins clicking
        # Import simultaneously could collide on the unique constraint —
        # treat IntegrityError as "already exists" and count it as skipped.
        for phone, name, source in candidates:
            try:
                with transaction.atomic():
                    obj, created = Contact.objects.get_or_create(
                        phone=phone,
                        defaults={'name': name, 'tag': tag, 'source': source},
                    )
                if created:
                    contacts_created += 1
                else:
                    contacts_skipped += 1
            except IntegrityError:
                # Race: another request inserted this phone between our
                # get_or_create lookup and insert. Treat as skipped.
                contacts_skipped += 1

        return Response({
            'created': contacts_created,
            'skipped': contacts_skipped,
            'errors': errors[:50],
            'total_contacts': Contact.objects.filter(is_active=True).count(),
        })


# ── Campaigns ──────────────────────────────────────────────────────────────

class CampaignListCreateView(generics.ListCreateAPIView):
    queryset = Campaign.objects.all()
    serializer_class = CampaignSerializer
    permission_classes = [IsAdminRole]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)


class CampaignDetailView(generics.RetrieveAPIView):
    queryset = Campaign.objects.all()
    serializer_class = CampaignSerializer
    permission_classes = [IsAdminRole]


class CampaignQueueView(APIView):
    """POST /api/sms/campaigns/<id>/queue/ — materialise audience, set queued."""
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        try:
            campaign = Campaign.objects.get(pk=pk)
        except Campaign.DoesNotExist:
            return Response({'detail': 'Campaign not found.'}, status=status.HTTP_404_NOT_FOUND)

        manual_phones = None
        if campaign.audience == 'manual':
            raw = (request.data.get('numbers') or '').strip()
            if raw:
                import re
                items = re.split(r'[,;\n]+', raw)
                manual_phones = [(normalize_phone(r.strip()), '') for r in items if r.strip()]

        try:
            queue_campaign(campaign, manual_phones=manual_phones)
        except ValueError as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(CampaignSerializer(campaign).data)


class CampaignSendView(APIView):
    """POST /api/sms/campaigns/<id>/send/ — execute sending (synchronous)."""
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        try:
            campaign = Campaign.objects.get(pk=pk)
        except Campaign.DoesNotExist:
            return Response({'detail': 'Campaign not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            send_campaign(campaign)
        except ValueError as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(CampaignSerializer(campaign).data)


class CampaignDeliveryListView(generics.ListAPIView):
    serializer_class = DeliverySerializer
    permission_classes = [IsAdminRole]

    def get_queryset(self):
        return Delivery.objects.filter(campaign_id=self.kwargs['pk'])
