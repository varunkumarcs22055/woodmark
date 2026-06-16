"""
Public read endpoints + admin CRUD endpoints for CMS content.

Public:
  GET /api/cms/banners/?placement=home_hero
  GET /api/cms/pages/{slug}/
  GET /api/cms/faqs/

Admin (gated):
  GET/POST                /api/cms/admin/banners/
  GET/PATCH/DELETE        /api/cms/admin/banners/{id}/
  GET/POST                /api/cms/admin/pages/
  GET/PATCH/DELETE        /api/cms/admin/pages/{id}/
  GET/POST                /api/cms/admin/faqs/
  GET/PATCH/DELETE        /api/cms/admin/faqs/{id}/
"""
from django.utils import timezone
from django.db.models import Q
from django.core.paginator import Paginator
from rest_framework import generics, serializers, status
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from users.models import User

from audit.mixins import write_audit
from core.permissions import IsAdminUser

from .models import Banner, Page, FAQ, NewsletterSubscriber, ContentBlock, NewsletterCampaign


class BannerSerializer(serializers.ModelSerializer):
    image_url_resolved = serializers.CharField(source='resolved_image_url', read_only=True)
    # `image` is a Cloudinary file field — the admin can either:
    #   - upload a file (multipart) → Cloudinary hosts it, image_url_resolved
    #     returns the CDN URL, OR
    #   - paste a remote image_url manually (legacy / external CDN fallback).
    image = serializers.ImageField(required=False, allow_null=True, write_only=True)

    class Meta:
        model = Banner
        fields = [
            'id', 'title',
            'image', 'image_url', 'image_url_resolved',
            'link_url', 'placement', 'is_active', 'sort_order',
            'starts_at', 'ends_at', 'created_at',
        ]


class PageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Page
        fields = ['id', 'slug', 'title', 'body_md', 'is_published', 'updated_at']


class FAQSerializer(serializers.ModelSerializer):
    class Meta:
        model = FAQ
        fields = ['id', 'question', 'answer', 'category', 'sort_order', 'is_active']


class NewsletterSerializer(serializers.ModelSerializer):
    class Meta:
        model = NewsletterSubscriber
        fields = ['email']


class ContentBlockSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContentBlock
        fields = ['id', 'key', 'title', 'body_md', 'data_json', 'is_active', 'updated_at']


class AdminNewsletterSubscriberSerializer(serializers.ModelSerializer):
    class Meta:
        model = NewsletterSubscriber
        fields = ['id', 'email', 'is_active', 'created_at']


class NewsletterCampaignSerializer(serializers.ModelSerializer):
    class Meta:
        model = NewsletterCampaign
        fields = ['id', 'subject', 'body_md', 'status', 'created_at', 'updated_at', 'sent_at']


# ─── Public ───────────────────────────────────────────────────────────────────

class PublicBannerListView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = BannerSerializer
    pagination_class = None

    def get_queryset(self):
        now = timezone.now()
        qs = Banner.objects.filter(is_active=True).filter(
            models_q_starts_ok(now) & models_q_ends_ok(now)
        )
        placement = self.request.query_params.get('placement')
        if placement:
            qs = qs.filter(placement=placement)
        return qs.order_by('placement', 'sort_order', 'id')


def models_q_starts_ok(now):
    from django.db.models import Q
    return Q(starts_at__isnull=True) | Q(starts_at__lte=now)


def models_q_ends_ok(now):
    from django.db.models import Q
    return Q(ends_at__isnull=True) | Q(ends_at__gte=now)


class PublicPageDetailView(generics.RetrieveAPIView):
    permission_classes = [AllowAny]
    serializer_class = PageSerializer
    lookup_field = 'slug'

    def get_queryset(self):
        return Page.objects.filter(is_published=True)


class PublicFAQListView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = FAQSerializer
    pagination_class = None

    def get_queryset(self):
        return FAQ.objects.filter(is_active=True)


class PublicContentBlockListView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = ContentBlockSerializer
    pagination_class = None

    def get_queryset(self):
        qs = ContentBlock.objects.filter(is_active=True)
        keys = (self.request.query_params.get('keys') or '').strip()
        if keys:
            parts = [k.strip() for k in keys.split(',') if k.strip()]
            if parts:
                qs = qs.filter(key__in=parts)
        return qs.order_by('key')


class PublicContentBlockDetailView(generics.RetrieveAPIView):
    permission_classes = [AllowAny]
    serializer_class = ContentBlockSerializer
    lookup_field = 'key'

    def get_queryset(self):
        return ContentBlock.objects.filter(is_active=True)


class NewsletterSubscriptionView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = (request.data.get('email') or '').strip().lower()
        if not email:
            return Response({'error': 'Email is required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Avoid duplicate errors, just return success if already subscribed
        obj, created = NewsletterSubscriber.objects.get_or_create(email=email)
        return Response({'success': True, 'already_existed': not created})


# ─── Admin CRUD (DRY base) ────────────────────────────────────────────────────

class _AdminCRUDMixin:
    permission_classes = [IsAdminUser]
    # JSONParser handles the existing typed-URL flow; FormParser +
    # MultiPartParser let the admin POST a file directly so the
    # Banner.image CloudinaryField receives a real upload.
    from rest_framework.parsers import (
        JSONParser, FormParser, MultiPartParser,
    )
    parser_classes = [JSONParser, FormParser, MultiPartParser]
    audit_target_type = 'cms'

    def perform_create(self, serializer):
        obj = serializer.save()
        write_audit(self.request, action='create',
                    target_type=self.audit_target_type, target_id=obj.id,
                    payload=self.request.data)

    def perform_update(self, serializer):
        obj = serializer.save()
        write_audit(self.request, action='update',
                    target_type=self.audit_target_type, target_id=obj.id,
                    payload=self.request.data)

    def perform_destroy(self, instance):
        write_audit(self.request, action='delete',
                    target_type=self.audit_target_type, target_id=instance.id,
                    payload={})
        instance.delete()


class AdminBannerListCreateView(_AdminCRUDMixin, generics.ListCreateAPIView):
    serializer_class = BannerSerializer
    audit_target_type = 'banner'
    queryset = Banner.objects.all()


class AdminBannerDetailView(_AdminCRUDMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = BannerSerializer
    audit_target_type = 'banner'
    queryset = Banner.objects.all()


class AdminPageListCreateView(_AdminCRUDMixin, generics.ListCreateAPIView):
    serializer_class = PageSerializer
    audit_target_type = 'page'
    queryset = Page.objects.all()


class AdminPageDetailView(_AdminCRUDMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = PageSerializer
    audit_target_type = 'page'
    queryset = Page.objects.all()


class AdminFAQListCreateView(_AdminCRUDMixin, generics.ListCreateAPIView):
    serializer_class = FAQSerializer
    audit_target_type = 'faq'
    queryset = FAQ.objects.all()


class AdminFAQDetailView(_AdminCRUDMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = FAQSerializer
    audit_target_type = 'faq'
    queryset = FAQ.objects.all()


class AdminContentBlockListCreateView(_AdminCRUDMixin, generics.ListCreateAPIView):
    serializer_class = ContentBlockSerializer
    audit_target_type = 'content_block'
    queryset = ContentBlock.objects.all()


class AdminContentBlockDetailView(_AdminCRUDMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ContentBlockSerializer
    audit_target_type = 'content_block'
    queryset = ContentBlock.objects.all()


class AdminNewsletterSubscriberListView(_AdminCRUDMixin, generics.ListAPIView):
    serializer_class = AdminNewsletterSubscriberSerializer
    audit_target_type = 'newsletter_subscriber'

    def get_queryset(self):
        return NewsletterSubscriber.objects.order_by('-created_at')


class AdminNewsletterSubscriberDetailView(_AdminCRUDMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = AdminNewsletterSubscriberSerializer
    audit_target_type = 'newsletter_subscriber'
    queryset = NewsletterSubscriber.objects.all()


class AdminNewsletterCampaignListCreateView(_AdminCRUDMixin, generics.ListCreateAPIView):
    serializer_class = NewsletterCampaignSerializer
    audit_target_type = 'newsletter_campaign'
    queryset = NewsletterCampaign.objects.all()


class AdminNewsletterCampaignDetailView(_AdminCRUDMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = NewsletterCampaignSerializer
    audit_target_type = 'newsletter_campaign'
    queryset = NewsletterCampaign.objects.all()


class AdminNewsletterStatsView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        # Customers: include anyone with role='user' who isn't blocked, even
        # if they haven't verified their OTP yet (they explicitly signed up
        # and gave us their email). Only dealers stay locked behind is_active
        # because B2B campaigns shouldn't go to unapproved accounts.
        subscribers = NewsletterSubscriber.objects.filter(is_active=True).count()
        customers = User.objects.filter(role='user', is_blocked=False).count()
        dealers = User.objects.filter(role='dealer', dealer_status='active', is_active=True, is_blocked=False).count()
        return Response({
            'subscribers': subscribers,
            'customers': customers,
            'dealers': dealers,
        })


class AdminNewsletterSendView(APIView):
    permission_classes = [IsAdminUser]

    def post(self, request):
        subject = (request.data.get('subject') or '').strip()
        body = (request.data.get('body') or request.data.get('body_md') or '').strip()
        targets = request.data.get('targets') or []
        recipient_emails = request.data.get('recipient_emails') or request.data.get('recipients') or []
        if isinstance(targets, str):
            targets = [t.strip() for t in targets.split(',') if t.strip()]
        if isinstance(recipient_emails, str):
            recipient_emails = [e.strip() for e in recipient_emails.split(',') if e.strip()]

        if not subject or not body:
            return Response({'error': 'Subject and body are required.'}, status=status.HTTP_400_BAD_REQUEST)
        # Allow either a group OR a hand-picked recipient list. We only
        # reject when both are empty — i.e. there's nobody to send to.
        if not targets and not recipient_emails:
            return Response(
                {'error': 'Select at least one recipient group OR pick individual recipients.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        emails = set(e.lower().strip() for e in recipient_emails if e)
        if 'subscribers' in targets:
            emails.update(NewsletterSubscriber.objects.filter(is_active=True).values_list('email', flat=True))
        if 'customers' in targets:
            # Include unverified signups — see AdminNewsletterStatsView for rationale.
            emails.update(User.objects.filter(role='user', is_blocked=False).values_list('email', flat=True))
        if 'dealers' in targets:
            emails.update(User.objects.filter(role='dealer', dealer_status='active', is_active=True, is_blocked=False).values_list('email', flat=True))

        recipients_count = len([e for e in emails if e])

        if recipients_count == 0:
            return Response(
                {'error': 'No recipients found. Check the group / individual selection.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        campaign = NewsletterCampaign.objects.create(
            subject=subject,
            body_md=body,
            status='queued',
        )

        # ─── Actually dispatch the email ─────────────────────────────────
        # Routes through django.core.mail, which is wired to Brevo's HTTP
        # backend when BREVO_API_KEY is set in env (see core/settings.py).
        # Per-recipient sends so Brevo's dashboard shows individual
        # delivery / open / click status — Bcc would collapse that to one
        # bulk row.
        from django.conf import settings as dj_settings
        from django.core.mail import EmailMultiAlternatives
        from django.core.signing import TimestampSigner
        from django.utils.html import escape as _esc
        import logging, re
        log = logging.getLogger(__name__)

        site = (dj_settings.SITE_URL or 'https://woodmark.in').rstrip('/')
        signer = TimestampSigner(salt='newsletter-unsubscribe')

        # Detect whether the admin pasted real HTML (has tags) or plain text.
        # Sending the identical body as both 'plain' and 'HTML' is a known
        # spam trigger — instead, generate a branded HTML wrapper around the
        # plain text when no tags are present.
        has_html = bool(re.search(r'<[a-zA-Z][^>]*>', body or ''))

        def _build_plain(unsub_url):
            # Strip tags for the plain alternative.
            txt = re.sub(r'<[^>]+>', '', body or '')
            return (
                f'{txt}\n\n'
                f'---\n'
                f'You\'re receiving this because you opted in to Woodmark updates.\n'
                f'Unsubscribe: {unsub_url}\n'
                f'Woodmark, Nagpur · hello@woodmark.in'
            )

        def _build_html(unsub_url):
            if has_html:
                inner = body
            else:
                # Wrap plain text in a clean branded HTML shell.
                paras = '\n'.join(
                    f'<p style="margin:0 0 14px;font-size:15px;line-height:1.6;color:#111827">{_esc(p)}</p>'
                    for p in (body or '').split('\n\n') if p.strip()
                )
                inner = paras
            return f"""<!doctype html>
<html><body style="margin:0;padding:0;background:#F6F6F4;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif">
  <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" style="padding:24px 0">
    <tr><td align="center">
      <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="600" style="max-width:600px;background:#FFFFFF;border-radius:12px;overflow:hidden;border:1px solid #E5E7EB">
        <tr><td style="background:#2D2E5F;padding:20px 28px;color:#fff;font-size:20px;font-weight:800;letter-spacing:-0.01em">
          Furno<span style="color:#E47D2A">Tech</span>
        </td></tr>
        <tr><td style="padding:28px">
          {inner}
        </td></tr>
        <tr><td style="padding:0 28px 22px">
          <hr style="border:0;border-top:1px solid #E5E7EB;margin:8px 0 14px"/>
          <p style="margin:0;font-size:11px;color:#6B7280;line-height:1.5">
            You're receiving this because you opted in to Woodmark updates.
            <a href="{unsub_url}" style="color:#6B7280">Unsubscribe</a> ·
            <a href="mailto:hello@woodmark.in" style="color:#6B7280">Contact us</a>
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>"""

        # From header: include a display name (bare emails look spammy).
        from_header = dj_settings.DEFAULT_FROM_EMAIL
        if '<' not in from_header:
            from_header = f'Woodmark <{from_header}>'

        sent = 0
        failed = []
        clean_emails = [e for e in emails if e]
        for to_email in clean_emails:
            try:
                # Signed token so the unsubscribe link can't be forged.
                token = signer.sign(to_email)
                unsub_url = f'{site}/api/notifications/unsubscribe/?token={token}'
                # mailto+post version per RFC 8058 (Gmail/Yahoo one-click).
                mailto_unsub = f'mailto:unsubscribe@woodmark.in?subject=unsubscribe%20{to_email}'

                msg = EmailMultiAlternatives(
                    subject=subject,
                    body=_build_plain(unsub_url),
                    from_email=from_header,
                    to=[to_email],
                    reply_to=['hello@woodmark.in'],
                    headers={
                        # RFC 2369 + RFC 8058 — required by Gmail/Yahoo as of
                        # Feb 2024 to clear the spam filter on bulk mail.
                        'List-Unsubscribe': f'<{unsub_url}>, <{mailto_unsub}>',
                        'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
                        'Precedence': 'bulk',
                        'X-Auto-Response-Suppress': 'OOF, AutoReply',
                    },
                )
                msg.attach_alternative(_build_html(unsub_url), 'text/html')
                msg.send(fail_silently=False)
                sent += 1
            except Exception as exc:
                failed.append({'email': to_email, 'error': str(exc)[:200]})
                log.warning('Newsletter send to %s failed: %s', to_email, exc)

        campaign.status = 'sent' if sent and not failed else (
            'failed' if not sent else 'sent'   # partial fail still counts as sent
        )
        from django.utils import timezone
        campaign.sent_at = timezone.now()
        campaign.save(update_fields=['status', 'sent_at'])

        return Response({
            'success': True,
            'recipients_count': recipients_count,
            'sent': sent,
            'failed': failed,
            'campaign_id': campaign.id,
            'status': campaign.status,
        })


class AdminNewsletterRecipientsView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        group = (request.query_params.get('group') or 'subscribers').strip().lower()
        search = (request.query_params.get('search') or '').strip()
        page = int(request.query_params.get('page') or 1)
        page_size = int(request.query_params.get('page_size') or 20)

        if group == 'subscribers':
            qs = NewsletterSubscriber.objects.filter(is_active=True)
            if search:
                qs = qs.filter(email__icontains=search)
            qs = qs.order_by('-created_at')
            paginator = Paginator(qs, page_size)
            page_obj = paginator.get_page(page)
            results = [
                {
                    'id': s.id,
                    'email': s.email,
                    'name': None,
                    'group': 'subscribers',
                    'created_at': s.created_at,
                }
                for s in page_obj.object_list
            ]
        elif group == 'customers':
            # Include unverified signups — they handed us their email at
            # registration and newsletter is opt-in by signup.
            qs = User.objects.filter(role='user', is_blocked=False)
            if search:
                qs = qs.filter(
                    Q(email__icontains=search)
                    | Q(first_name__icontains=search)
                    | Q(last_name__icontains=search)
                )
            qs = qs.order_by('-date_joined')
            paginator = Paginator(qs, page_size)
            page_obj = paginator.get_page(page)
            results = [
                {
                    'id': u.id,
                    'email': u.email,
                    'name': u.full_name,
                    'group': 'customers',
                    'created_at': u.date_joined,
                }
                for u in page_obj.object_list
            ]
        elif group == 'dealers':
            qs = User.objects.filter(role='dealer', dealer_status='active', is_active=True, is_blocked=False)
            if search:
                qs = qs.filter(
                    Q(email__icontains=search)
                    | Q(first_name__icontains=search)
                    | Q(last_name__icontains=search)
                    | Q(dealer_company_name__icontains=search)
                )
            qs = qs.order_by('-date_joined')
            paginator = Paginator(qs, page_size)
            page_obj = paginator.get_page(page)
            results = [
                {
                    'id': u.id,
                    'email': u.email,
                    'name': u.full_name or u.dealer_company_name,
                    'group': 'dealers',
                    'company': u.dealer_company_name,
                    'created_at': u.date_joined,
                }
                for u in page_obj.object_list
            ]
        else:
            return Response({'error': 'Invalid group.'}, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'count': paginator.count,
            'page': page_obj.number,
            'page_size': page_size,
            'total_pages': paginator.num_pages,
            'results': results,
        })



