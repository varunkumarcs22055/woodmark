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

    class Meta:
        model = Banner
        fields = [
            'id', 'title', 'image_url', 'image_url_resolved',
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
        subscribers = NewsletterSubscriber.objects.filter(is_active=True).count()
        customers = User.objects.filter(role='user', is_active=True, is_blocked=False).count()
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
        if not targets:
            return Response({'error': 'Select at least one recipient group.'}, status=status.HTTP_400_BAD_REQUEST)

        emails = set(e.lower().strip() for e in recipient_emails if e)
        if 'subscribers' in targets:
            emails.update(NewsletterSubscriber.objects.filter(is_active=True).values_list('email', flat=True))
        if 'customers' in targets:
            emails.update(User.objects.filter(role='user', is_active=True, is_blocked=False).values_list('email', flat=True))
        if 'dealers' in targets:
            emails.update(User.objects.filter(role='dealer', dealer_status='active', is_active=True, is_blocked=False).values_list('email', flat=True))

        recipients_count = len([e for e in emails if e])

        if recipients_count == 0:
            return Response({'error': 'Selected groups have no active recipients.'}, status=status.HTTP_400_BAD_REQUEST)

        campaign = NewsletterCampaign.objects.create(
            subject=subject,
            body_md=body,
            status='queued',
        )

        return Response({
            'success': True,
            'recipients_count': recipients_count,
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
            qs = User.objects.filter(role='user', is_active=True, is_blocked=False)
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



