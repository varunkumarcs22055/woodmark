import logging
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import authenticate
from django.shortcuts import redirect as django_redirect
from .models import User, PasswordResetToken, EmailOTP, UserAddress
from .serializers import (
    UserRegistrationSerializer, UserLoginSerializer,
    UserProfileSerializer, DealerApplicationSerializer,
    AdminDealerApprovalSerializer,
    PasswordResetRequestSerializer, PasswordResetConfirmSerializer,
    EmailOTPRequestSerializer, EmailOTPVerifySerializer,
    UserAddressSerializer, ChangePasswordSerializer,
)
from .permissions import IsAdminRole

logger = logging.getLogger(__name__)


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    refresh['role'] = user.role
    refresh['email'] = user.email
    if user.role == 'dealer':
        refresh['dealer_status'] = user.dealer_status or 'pending'
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class RegisterView(APIView):
    """
    Two-step signup:
      1) POST /api/auth/register/  with email + password + name
         - rejects disposable / throwaway email domains
         - creates the User row with is_active=False (cannot log in yet)
         - issues a 6-digit OTP, emails it via Brevo
         - returns {detail, email} — NO tokens
      2) POST /api/auth/verify-email/  with email + otp
         - validates OTP, flips is_active=True, returns JWT tokens

    Disposable-email policy: see users/disposable_emails.py. We block
    obvious throwaways but allow corporate / regional providers without
    a positive allowlist (which would be too restrictive).
    """
    permission_classes = [AllowAny]

    def post(self, request):
        from .disposable_emails import is_disposable_email

        email = (request.data.get('email') or '').strip().lower()
        if is_disposable_email(email):
            return Response(
                {'email': 'Disposable / temporary email addresses are not allowed. '
                          'Please use a real email account.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = UserRegistrationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        # Create user as inactive — they can't log in until OTP is verified.
        user = serializer.save()
        user.is_active = False
        user.save(update_fields=['is_active'])

        # Issue OTP + email it.
        otp = EmailOTP.issue(user, purpose='signup', ttl_minutes=15)
        self._send_signup_otp_email(user, otp.code)

        return Response({
            'detail': 'Account created. Check your email for a 6-digit verification code.',
            'email': user.email,
            'requires_verification': True,
        }, status=status.HTTP_201_CREATED)

    @staticmethod
    def _send_signup_otp_email(user, code):
        from django.core.mail import EmailMultiAlternatives
        html = (
            '<div style="font-family:sans-serif;padding:24px;background:#f6f6f4">'
            '<div style="max-width:480px;margin:auto;background:#fff;padding:28px;'
            'border-radius:8px;border:1px solid #eee">'
            '<h2 style="color:#00736A;margin:0 0 12px">Verify your email</h2>'
            f'<p>Hi {user.full_name or "there"}, your FurnoTech verification code is:</p>'
            f'<div style="font-size:32px;font-weight:800;letter-spacing:8px;'
            f'background:#f6f6f4;text-align:center;padding:18px;border-radius:8px;'
            f'margin:18px 0;color:#00736A">{code}</div>'
            '<p>This code expires in 15 minutes. If you didn\'t sign up, '
            'you can ignore this email.</p>'
            '<p style="color:#888;font-size:12px;margin-top:24px">- FurnoTech</p>'
            '</div></div>'
        )
        try:
            msg = EmailMultiAlternatives(
                subject=f'Your FurnoTech verification code: {code}',
                body=(f'Hi {user.full_name or "there"},\n\n'
                      f'Your FurnoTech verification code is: {code}\n\n'
                      f'It expires in 15 minutes.\n\n- FurnoTech'),
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=[user.email],
            )
            msg.attach_alternative(html, 'text/html')
            msg.send(fail_silently=False)
        except Exception:
            logger.exception('Signup OTP email failed for %s', user.email)


class VerifyEmailView(APIView):
    """POST /api/auth/verify-email/  {email, otp}"""
    permission_classes = [AllowAny]

    def post(self, request):
        email = (request.data.get('email') or '').strip().lower()
        otp_code = (request.data.get('otp') or '').strip()
        if not email or not otp_code:
            return Response({'detail': 'email and otp are required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(email__iexact=email)
        except User.DoesNotExist:
            return Response({'detail': 'Invalid email or code.'},
                            status=status.HTTP_400_BAD_REQUEST)

        otp = (EmailOTP.objects
               .filter(user=user, purpose='signup', used_at__isnull=True)
               .order_by('-created_at').first())
        if not otp or not otp.is_valid:
            return Response({'detail': 'Code expired or invalid. Request a new one.'},
                            status=status.HTTP_400_BAD_REQUEST)
        if otp.code != otp_code:
            otp.attempts += 1
            otp.save(update_fields=['attempts'])
            return Response({'detail': 'Invalid code.'},
                            status=status.HTTP_400_BAD_REQUEST)

        # Success: activate user, consume OTP, issue tokens.
        from django.utils import timezone
        otp.used_at = timezone.now()
        otp.save(update_fields=['used_at'])
        user.is_active = True
        user.save(update_fields=['is_active'])

        tokens = get_tokens_for_user(user)
        return Response({
            **tokens,
            'user': UserProfileSerializer(user).data,
        }, status=status.HTTP_200_OK)


class ResendSignupOTPView(APIView):
    """POST /api/auth/resend-verification/  {email}"""
    permission_classes = [AllowAny]

    def post(self, request):
        email = (request.data.get('email') or '').strip().lower()
        if not email:
            return Response({'detail': 'email is required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(email__iexact=email, is_active=False)
        except User.DoesNotExist:
            # Don't leak whether the address exists.
            return Response({'detail': 'If that account exists, a new code was sent.'})
        otp = EmailOTP.issue(user, purpose='signup', ttl_minutes=15)
        RegisterView._send_signup_otp_email(user, otp.code)
        return Response({'detail': 'A new verification code was sent.'})


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        from .disposable_emails import is_disposable_email

        serializer = UserLoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        password = serializer.validated_data['password']

        # Block existing temp-mail accounts from logging in too. Registration
        # already rejects these domains, but legacy rows may exist from before
        # the policy or from registrations that bypassed it.
        if is_disposable_email(email):
            return Response(
                {'detail': 'Disposable / temporary email addresses are not allowed. '
                           'Please sign in with a real email account.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        user = authenticate(request, username=email, password=password)
        if user is None:
            # Django's default backend silently rejects inactive users with
            # None. Check explicitly so an unverified signup gets routed to
            # the verify-email page instead of seeing a misleading
            # "Invalid email or password" message.
            possible = User.objects.filter(email__iexact=email).first()
            if possible and not possible.is_active and not getattr(possible, 'is_blocked', False):
                # Password is correct? Only fire OTP if so — otherwise we'd
                # let attackers probe valid emails. Recheck with the explicit
                # backend that allows inactive users.
                if possible.check_password(password):
                    otp = EmailOTP.issue(possible, purpose='signup', ttl_minutes=15)
                    RegisterView._send_signup_otp_email(possible, otp.code)
                    return Response({
                        'detail': 'Your email is not yet verified. We sent a new 6-digit code.',
                        'requires_verification': True,
                        'email': possible.email,
                    }, status=status.HTTP_403_FORBIDDEN)
            return Response({'detail': 'Invalid email or password.'}, status=status.HTTP_401_UNAUTHORIZED)
        if not user.is_active:
            # Defensive — shouldn't reach here because authenticate() filters
            # out inactive users, but cover the case where a custom backend
            # might let them through.
            return Response({'detail': 'Account is disabled.'}, status=status.HTTP_401_UNAUTHORIZED)
        if getattr(user, 'is_blocked', False):
            return Response(
                {'code': 'user_blocked', 'detail': 'Your account has been blocked. Contact support.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        tokens = get_tokens_for_user(user)
        return Response({
            **tokens,
            'user': UserProfileSerializer(user).data,
        }, status=status.HTTP_200_OK)


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({'detail': 'Logged out successfully.'}, status=status.HTTP_200_OK)
        except TokenError:
            return Response({'detail': 'Token is invalid or expired.'}, status=status.HTTP_400_BAD_REQUEST)


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data)

    def patch(self, request):
        serializer = UserProfileSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = request.user
        if not user.check_password(serializer.validated_data['old_password']):
            return Response({'old_password': 'Current password is incorrect.'},
                            status=status.HTTP_400_BAD_REQUEST)
        user.set_password(serializer.validated_data['new_password'])
        user.save(update_fields=['password'])
        return Response({'detail': 'Password updated.'})


class UserAddressListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = UserAddress.objects.filter(user=request.user)
        return Response(UserAddressSerializer(qs, many=True).data)

    def post(self, request):
        serializer = UserAddressSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserAddressDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get_object(self, request, pk):
        try:
            return UserAddress.objects.get(pk=pk, user=request.user)
        except UserAddress.DoesNotExist:
            return None

    def patch(self, request, pk):
        obj = self.get_object(request, pk)
        if not obj:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        serializer = UserAddressSerializer(obj, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        obj = self.get_object(request, pk)
        if not obj:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class DealerApplicationView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = DealerApplicationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            logger.info(f'New dealer application from {user.email} ({user.dealer_company_name})')
            
            # Notify Admin
            try:
                from django.core.mail import send_mail
                send_mail(
                    'New Dealer Application Received',
                    f'A new dealer application has been submitted by {user.full_name}.\n\n'
                    f'Company: {user.dealer_company_name}\n'
                    f'Email: {user.email}\n'
                    f'GST: {user.dealer_gst_number}\n\n'
                    f'Review it here: {request.build_absolute_uri("/")}admin-dashboard/dealers/',
                    'no-reply@furnishop.in',
                    [settings.DEFAULT_FROM_EMAIL], # Or a dedicated admin email
                    fail_silently=True
                )
            except Exception as e:
                logger.error(f"Failed to notify admin of dealer application: {e}")

            return Response({
                'detail': 'Application submitted. You will be notified once approved.',
                'email': user.email,
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DealerApprovalView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        dealers = User.objects.filter(role='dealer', dealer_status='pending').order_by('-date_joined')
        serializer = UserProfileSerializer(dealers, many=True)
        return Response(serializer.data)

    def patch(self, request, pk=None):
        try:
            dealer = User.objects.get(pk=pk, role='dealer')
        except User.DoesNotExist:
            return Response({'detail': 'Dealer not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = AdminDealerApprovalSerializer(dealer, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            action = 'approved' if dealer.dealer_status == 'active' else 'rejected'
            logger.info(f'Dealer {dealer.email} {action} by admin {request.user.email}')
            return Response(UserProfileSerializer(dealer).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DealerTierListView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        from dealer_pricing.models import DealerTier
        from dealer_pricing.serializers import DealerTierSerializer
        tiers = DealerTier.objects.filter(is_active=True).order_by('sort_order')
        serializer = DealerTierSerializer(tiers, many=True)
        return Response(serializer.data)


class GoogleLoginRedirectView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return django_redirect('/social-auth/login/google-oauth2/')


class DevLoginView(APIView):
    """POST /api/auth/dev-login/ — DEBUG only. Returns real JWTs for test roles."""
    permission_classes = [AllowAny]

    TEST_USERS = {
        'admin': {
            'email': 'dev-admin@furnishop.local',
            'password': 'DevAdmin@2024!',
            'first_name': 'Dev',
            'last_name': 'Admin',
            'role': 'admin',
        },
        'dealer': {
            'email': 'dev-dealer@furnishop.local',
            'password': 'DevDealer@2024!',
            'first_name': 'Dev',
            'last_name': 'Dealer',
            'role': 'dealer',
            'dealer_status': 'active',
            'dealer_company_name': 'Dev Dealer Co.',
            'dealer_gst_number': '29ABCDE1234F1Z5',
        },
        'user': {
            'email': 'dev-user@furnishop.local',
            'password': 'DevUser@2024!',
            'first_name': 'Dev',
            'last_name': 'User',
            'role': 'user',
        },
    }

    def post(self, request):
        # Gate via an explicit env flag so we can keep the testing shortcut
        # available on staging/preview deploys without flipping DEBUG=True
        # (which would also disable security middleware, secure cookies, etc.).
        # Default: enabled when DEBUG=True, OR when ALLOW_DEV_LOGIN env=True.
        from django.conf import settings as dj_settings
        import os
        allowed = (
            dj_settings.DEBUG
            or os.getenv('ALLOW_DEV_LOGIN', '').lower() in ('1', 'true', 'yes')
        )
        if not allowed:
            return Response({'error': 'Not available in production.'},
                            status=status.HTTP_403_FORBIDDEN)

        role = request.data.get('role', 'user')
        if role not in self.TEST_USERS:
            return Response({'error': f'Unknown role: {role}'}, status=status.HTTP_400_BAD_REQUEST)

        cfg = self.TEST_USERS[role]
        user, created = User.objects.get_or_create(
            email=cfg['email'],
            defaults={
                'username': cfg['email'],
                'first_name': cfg['first_name'],
                'last_name': cfg['last_name'],
                'role': cfg['role'],
                'is_staff': cfg['role'] == 'admin',
                'is_superuser': cfg['role'] == 'admin',
                'dealer_status': cfg.get('dealer_status'),
                'dealer_company_name': cfg.get('dealer_company_name', ''),
                'dealer_gst_number': cfg.get('dealer_gst_number', ''),
            }
        )
        if created:
            user.set_password(cfg['password'])
            user.save()

        tokens = get_tokens_for_user(user)
        return Response({**tokens, 'user': UserProfileSerializer(user).data})


class UserListView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        qs = User.objects.all().order_by('-date_joined')
        role = request.query_params.get('role')
        dealer_status = request.query_params.get('dealer_status')
        if role:
            qs = qs.filter(role=role)
        if dealer_status:
            qs = qs.filter(dealer_status=dealer_status)
        serializer = UserProfileSerializer(qs, many=True)
        return Response(serializer.data)


class EmailOTPRequestView(APIView):
    """
    POST /api/auth/otp/request/  body={email}

    Issues a 6-digit code valid for 10 minutes. Like password-reset, the
    response is constant whether the email is registered or not — so the
    endpoint can't be used to enumerate accounts. Cooldown: 60s between
    issues per user.
    """
    permission_classes = [AllowAny]
    COOLDOWN_SECONDS = 60

    def post(self, request):
        from .disposable_emails import is_disposable_email

        serializer = EmailOTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email'].lower().strip()

        if is_disposable_email(email):
            # Use the same constant-response shape as the success path so the
            # endpoint still can't be used to probe for valid emails — we just
            # never deliver the code.
            return Response({
                'detail': 'Disposable / temporary email addresses are not allowed.',
                'expires_in_minutes': 10,
            }, status=status.HTTP_403_FORBIDDEN)

        user = User.objects.filter(email__iexact=email).first()
        debug_payload = {}

        if user is not None:
            from django.utils import timezone as _tz
            from datetime import timedelta as _td
            recent = (EmailOTP.objects
                      .filter(user=user, used_at__isnull=True,
                              created_at__gte=_tz.now() - _td(seconds=self.COOLDOWN_SECONDS))
                      .first())
            if recent is None:
                # Invalidate older outstanding codes so reuse is impossible.
                EmailOTP.objects.filter(user=user, used_at__isnull=True).update(used_at=_tz.now())
                otp = EmailOTP.issue(user, purpose='login')
                try:
                    from services.notifications import notify
                    notify(
                        user=user,
                        kind='login_otp',
                        title='Your FurnoTech login code',
                        body=(
                            f'Hi {user.full_name},\n\n'
                            f'Your one-time login code is: {otp.code}\n'
                            f'It expires in 10 minutes. Do not share it with anyone.'
                        ),
                        channels=['inapp', 'email', 'sms'],
                    )
                except Exception:
                    logger.exception('notify() failed for OTP of %s', user.pk)
                logger.info('Login OTP issued for %s', user.email)
                if settings.DEBUG:
                    debug_payload = {'debug_code': otp.code}

        return Response({
            'detail': 'If that email is registered, a login code has been sent.',
            'expires_in_minutes': 10,
            **debug_payload,
        })


class EmailOTPVerifyView(APIView):
    """
    POST /api/auth/otp/verify/  body={email, code}

    Returns JWTs on success, exactly like /login/. Wrong codes increment the
    `attempts` counter; after 5 attempts the row is locked and a fresh code
    must be requested.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        from .disposable_emails import is_disposable_email

        serializer = EmailOTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email'].lower().strip()
        code = serializer.validated_data['code'].strip()

        # Match the request endpoint — temp-mail addresses can't redeem an OTP
        # even if they somehow got one (e.g. provider added to blocklist after
        # the issue).
        if is_disposable_email(email):
            return Response(
                {'detail': 'Disposable / temporary email addresses are not allowed.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        user = User.objects.filter(email__iexact=email).first()
        if user is None:
            return Response({'detail': 'Invalid code or email.'}, status=status.HTTP_400_BAD_REQUEST)

        otp = (EmailOTP.objects
               .filter(user=user, used_at__isnull=True, purpose='login')
               .order_by('-created_at').first())

        if otp is None or not otp.is_valid:
            return Response({'detail': 'Code expired or already used. Request a new one.'},
                            status=status.HTTP_400_BAD_REQUEST)

        if otp.code != code:
            otp.attempts += 1
            otp.save(update_fields=['attempts'])
            return Response({'detail': 'Invalid code.'}, status=status.HTTP_400_BAD_REQUEST)

        # Blocked = admin took action against the account; never let in.
        if getattr(user, 'is_blocked', False):
            return Response({'detail': 'Account disabled or blocked.'},
                            status=status.HTTP_403_FORBIDDEN)

        # Inactive = signup OTP was never completed. The fact that the
        # user just proved they own this inbox (correct login OTP) is at
        # least as strong as the signup OTP would have been — so activate
        # them in place instead of locking them out. Otherwise old-flow
        # registrants get permanently stranded.
        if not user.is_active:
            user.is_active = True
            user.save(update_fields=['is_active'])
            logger.info('OTP login auto-activated stale signup %s', user.email)

        otp.consume()
        tokens = get_tokens_for_user(user)
        logger.info('OTP login for %s', user.email)
        return Response({**tokens, 'user': UserProfileSerializer(user).data})


class PasswordResetRequestView(APIView):
    """
    POST /api/auth/password-reset/request/  body={email}

    Always returns 200 with the same body so the endpoint can't be used to
    enumerate registered emails. The token is delivered out-of-band: in
    DEBUG we echo it in the response and log it; in prod the notify()
    pipeline emails it.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email'].lower().strip()

        user = User.objects.filter(email__iexact=email).first()
        debug_payload = {}

        if user is not None:
            # Invalidate any outstanding tokens for this user before issuing
            # a new one so an old leaked link can't race against the new one.
            from django.utils import timezone as _tz
            PasswordResetToken.objects.filter(
                user=user, used_at__isnull=True
            ).update(used_at=_tz.now())

            token_obj = PasswordResetToken.issue(user)
            reset_url = f"{settings.FRONTEND_URL.rstrip('/')}/reset-password?token={token_obj.token}"

            try:
                from services.notifications import notify
                notify(
                    user=user,
                    kind='password_reset',
                    title='Reset your FurnoTech password',
                    body=(
                        f"Hi {user.full_name},\n\n"
                        f"Use the link below to reset your password. "
                        f"It expires in 1 hour.\n\n{reset_url}\n\n"
                        f"If you didn't request this, you can ignore this email."
                    ),
                    channels=['inapp', 'email'],
                )
            except Exception:
                logger.exception('notify() failed for password reset of %s', user.pk)

            logger.info('Password reset token issued for %s', user.email)

            if settings.DEBUG:
                debug_payload = {'debug_token': token_obj.token, 'debug_reset_url': reset_url}

        return Response({
            'detail': 'If an account exists for that email, a reset link has been sent.',
            **debug_payload,
        })


class PasswordResetConfirmView(APIView):
    """
    POST /api/auth/password-reset/confirm/  body={token, new_password, confirm_password}
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        token_value = serializer.validated_data['token']
        new_password = serializer.validated_data['new_password']

        token_obj = PasswordResetToken.objects.select_related('user').filter(token=token_value).first()
        if token_obj is None or not token_obj.is_valid:
            return Response(
                {'detail': 'This reset link is invalid or has expired. Request a new one.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = token_obj.user
        user.set_password(new_password)
        user.save(update_fields=['password'])
        token_obj.consume()

        logger.info('Password reset completed for %s', user.email)
        return Response({'detail': 'Password updated. You can now log in with your new password.'})


class AdminUserListCreateView(APIView):
    """
    GET  /api/auth/admins/   → list all admin accounts (admin-only)
    POST /api/auth/admins/   → create a new admin account, return its summary

    Body for POST: { email, password, full_name?, phone? }
    The new admin is active immediately (no OTP) since the inviting admin
    already vouched for their identity — this matches typical SaaS admin
    invite flows where the existing operator hands credentials over manually.
    """
    permission_classes = [IsAdminRole]

    def get(self, request):
        rows = (User.objects
                .filter(role='admin')
                .order_by('-date_joined')
                .values('id', 'email', 'full_name', 'phone', 'is_active',
                        'is_blocked', 'last_login', 'date_joined'))
        return Response(list(rows))

    def post(self, request):
        from .disposable_emails import is_disposable_email

        email = (request.data.get('email') or '').strip().lower()
        password = request.data.get('password') or ''
        full_name = (request.data.get('full_name') or '').strip()
        phone = (request.data.get('phone') or '').strip()

        if not email or '@' not in email:
            return Response({'email': 'Valid email is required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        if is_disposable_email(email):
            return Response({'email': 'Disposable email addresses are not allowed.'},
                            status=status.HTTP_400_BAD_REQUEST)
        if len(password) < 8:
            return Response({'password': 'Password must be at least 8 characters.'},
                            status=status.HTTP_400_BAD_REQUEST)
        if User.objects.filter(email__iexact=email).exists():
            return Response({'email': 'A user with this email already exists.'},
                            status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create(
            email=email,
            username=email,
            full_name=full_name,
            phone=phone,
            role='admin',
            is_active=True,
            is_staff=True,
            is_superuser=False,  # NOT a Django superuser; just role=admin
        )
        user.set_password(password)
        user.save()

        logger.info('Admin %s created new admin user %s', request.user.email, email)

        # Send the new admin a courtesy email so they know how to log in.
        try:
            from services.notifications import notify
            from django.conf import settings as dj_settings
            site = (dj_settings.SITE_URL or '').rstrip('/')
            notify(
                user=user,
                kind='admin_account_created',
                title='You\'ve been added as an admin on FurnoTech',
                body=(
                    f'Hi {full_name or email},\n\n'
                    f'{request.user.full_name or request.user.email} has added you '
                    f'as an administrator on FurnoTech.\n\n'
                    f'Sign in at {site or "your site"} with this email and the '
                    f'password they shared with you.'
                ),
                channels=['inapp', 'email'],
            )
        except Exception:
            logger.exception('Failed to notify new admin %s', email)

        return Response({
            'id': user.id,
            'email': user.email,
            'full_name': user.full_name,
            'phone': user.phone,
            'role': user.role,
            'is_active': user.is_active,
        }, status=status.HTTP_201_CREATED)


class AdminUserDetailView(APIView):
    """
    PATCH /api/auth/admins/{id}/   → block/unblock, change name/phone
    DELETE /api/auth/admins/{id}/  → demote (set role=user, NOT delete the row)

    We never hard-delete admin rows so audit trails referencing them stay
    intact. "Delete" here is a demotion to a regular user account.
    """
    permission_classes = [IsAdminRole]

    def _get_admin(self, pk):
        try:
            return User.objects.get(pk=pk, role='admin')
        except User.DoesNotExist:
            return None

    def patch(self, request, pk):
        user = self._get_admin(pk)
        if user is None:
            return Response({'detail': 'Admin not found.'}, status=status.HTTP_404_NOT_FOUND)
        # Don't let an admin lock themselves out via this endpoint.
        if user.id == request.user.id and 'is_blocked' in request.data:
            return Response({'detail': 'You cannot block your own account.'},
                            status=status.HTTP_400_BAD_REQUEST)
        for field in ('full_name', 'phone', 'is_active', 'is_blocked'):
            if field in request.data:
                setattr(user, field, request.data[field])
        user.save()
        return Response({
            'id': user.id,
            'email': user.email,
            'full_name': user.full_name,
            'phone': user.phone,
            'is_active': user.is_active,
            'is_blocked': user.is_blocked,
        })

    def delete(self, request, pk):
        user = self._get_admin(pk)
        if user is None:
            return Response({'detail': 'Admin not found.'}, status=status.HTTP_404_NOT_FOUND)
        if user.id == request.user.id:
            return Response({'detail': 'You cannot remove your own admin role.'},
                            status=status.HTTP_400_BAD_REQUEST)
        user.role = 'user'
        user.is_staff = False
        user.save(update_fields=['role', 'is_staff'])
        logger.info('Admin %s demoted admin %s to user role', request.user.email, user.email)
        return Response(status=status.HTTP_204_NO_CONTENT)
