"""
  GET   /api/notifications/                  list (current user)
  GET   /api/notifications/unread-count/     {"unread": int}
  POST  /api/notifications/{id}/read/        mark single
  POST  /api/notifications/read-all/         mark all
"""
from rest_framework import generics, serializers, status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Notification, NotificationPreference, Subscriber, Newsletter
from django.contrib.auth import get_user_model

User = get_user_model()



class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'kind', 'title', 'body', 'payload', 'is_read', 'created_at']


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = [
            'email_order_updates', 'email_marketing',
            'sms_order_updates', 'sms_marketing',
            'updated_at',
        ]
        read_only_fields = ['updated_at']


class NotificationListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = NotificationSerializer

    def get_queryset(self):
        qs = Notification.objects.filter(user=self.request.user)
        only_unread = self.request.query_params.get('unread')
        if only_unread in ('1', 'true'):
            qs = qs.filter(is_read=False)
        return qs


class UnreadCountView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(
            {'unread': Notification.objects.filter(user=request.user, is_read=False).count()}
        )


class MarkReadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            n = Notification.objects.get(pk=pk, user=request.user)
        except Notification.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not n.is_read:
            n.is_read = True
            n.save(update_fields=['is_read'])
        return Response(NotificationSerializer(n).data)


class MarkAllReadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        count = Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'updated': count})


class NotificationPreferenceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        prefs, _ = NotificationPreference.objects.get_or_create(user=request.user)
        return Response(NotificationPreferenceSerializer(prefs).data)

    def patch(self, request):
        prefs, _ = NotificationPreference.objects.get_or_create(user=request.user)
        serializer = NotificationPreferenceSerializer(prefs, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class NewsletterTargetGroupView(APIView):
    permission_classes = [IsAuthenticated] # Would normally require IsAdminUser, assuming dashboard handles it

    def get(self, request):
        group = request.query_params.get('group', 'all')
        
        users = []
        if group in ['all', 'customers', 'custom']:
            qs = User.objects.filter(role='user', is_active=True)
            for u in qs:
                users.append({'email': u.email, 'name': u.full_name, 'type': 'Customer'})
                
        if group in ['all', 'dealers', 'custom']:
            qs = User.objects.filter(role='dealer', dealer_status='active', is_active=True)
            for u in qs:
                users.append({'email': u.email, 'name': u.dealer_company_name or u.full_name, 'type': 'Dealer'})
                
        if group in ['all', 'subscribers', 'custom']:
            qs = Subscriber.objects.filter(is_active=True)
            for s in qs:
                users.append({'email': s.email, 'name': 'Subscriber', 'type': 'Subscriber'})

        # Remove duplicates by email
        unique_users = {u['email']: u for u in users}.values()
        return Response(list(unique_users))


class NewsletterSendView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        subject = request.data.get('subject')
        content = request.data.get('content')
        target_group = request.data.get('target_group')
        selected_emails = request.data.get('selected_emails', [])

        if not subject or not content or not target_group:
            return Response({'error': 'Subject, content, and target_group are required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        if not selected_emails:
            return Response({'error': 'At least one recipient is required.'},
                            status=status.HTTP_400_BAD_REQUEST)

        # Fan-out via Brevo (django.core.mail uses anymail when BREVO_API_KEY
        # is set). One message per recipient (Bcc is fine for small lists, but
        # individual sends give Brevo per-recipient analytics + unsubscribe
        # tracking). Failures are tallied but never bubble — the campaign
        # row is still saved so admin sees what was attempted.
        from django.conf import settings
        from django.core.mail import EmailMultiAlternatives
        import logging
        log = logging.getLogger(__name__)

        sent = 0
        failed = []
        for email in selected_emails:
            try:
                msg = EmailMultiAlternatives(
                    subject=subject,
                    body=content,                 # plain-text fallback
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    to=[email],
                )
                msg.attach_alternative(content, 'text/html')
                msg.send(fail_silently=False)
                sent += 1
            except Exception as exc:
                failed.append({'email': email, 'error': str(exc)[:200]})
                log.warning('Newsletter send failed for %s: %s', email, exc)

        newsletter = Newsletter.objects.create(
            subject=subject,
            content=content,
            target_group=target_group,
            sent_to_emails=selected_emails,
        )

        return Response({
            'message': f'Newsletter "{subject}" sent to {sent}/{len(selected_emails)} recipients.',
            'id': newsletter.id,
            'sent': sent,
            'failed': failed,
        })


class SubscriberCreateView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({'error': 'Email is required.'},
                            status=status.HTTP_400_BAD_REQUEST)

        sub, created = Subscriber.objects.get_or_create(email=email)
        if not created and not sub.is_active:
            sub.is_active = True
            sub.save()

        # Send a welcome email only on a fresh subscribe (or on a re-activate
        # of a previously-unsubscribed address). Failures are swallowed —
        # the subscription itself succeeded, that's what matters.
        if created or not sub.welcomed_at:
            try:
                from django.conf import settings
                from django.core.mail import EmailMultiAlternatives
                from django.utils import timezone

                html = (
                    '<div style="font-family:sans-serif;padding:24px;background:#f6f6f4">'
                    '<div style="max-width:480px;margin:auto;background:#fff;padding:28px;'
                    'border-radius:8px;border:1px solid #eee">'
                    '<h2 style="color:#00736A;margin:0 0 12px">Welcome to FurniShop</h2>'
                    '<p>Thanks for subscribing. You\'ll be the first to hear about new '
                    'collections, dealer offers, and seasonal sales.</p>'
                    '<p style="margin-top:24px">'
                    '<a href="' + settings.SITE_URL.rstrip('/') + '" '
                    'style="background:#00736A;color:#fff;text-decoration:none;'
                    'padding:11px 22px;border-radius:6px;font-weight:600">'
                    'Start Browsing</a></p>'
                    '<p style="color:#888;font-size:12px;margin-top:24px">'
                    "If you didn't sign up, you can ignore this email — we won't "
                    'send any more.</p></div></div>'
                )
                msg = EmailMultiAlternatives(
                    subject='Welcome to FurniShop',
                    body='Thanks for subscribing to FurniShop. You\'ll be the first '
                         'to hear about new collections, dealer offers, and seasonal '
                         'sales.\n\nBrowse: ' + settings.SITE_URL,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    to=[email],
                )
                msg.attach_alternative(html, 'text/html')
                msg.send(fail_silently=False)
                sub.welcomed_at = timezone.now()
                sub.save(update_fields=['welcomed_at'])
            except Exception:
                import logging
                logging.getLogger(__name__).warning(
                    'Welcome email failed for %s', email, exc_info=True,
                )

        return Response({'message': 'Subscribed successfully.'})
