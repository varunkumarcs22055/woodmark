import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import authenticate
from django.shortcuts import redirect as django_redirect
from .models import User
from .serializers import (
    UserRegistrationSerializer, UserLoginSerializer,
    UserProfileSerializer, DealerApplicationSerializer,
    AdminDealerApprovalSerializer,
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
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            tokens = get_tokens_for_user(user)
            return Response({
                **tokens,
                'user': UserProfileSerializer(user).data,
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = UserLoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        password = serializer.validated_data['password']

        user = authenticate(request, username=email, password=password)
        if user is None:
            return Response({'detail': 'Invalid email or password.'}, status=status.HTTP_401_UNAUTHORIZED)
        if not user.is_active:
            return Response({'detail': 'Account is disabled.'}, status=status.HTTP_401_UNAUTHORIZED)

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


class DealerApplicationView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = DealerApplicationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            logger.info(f'New dealer application from {user.email} ({user.dealer_company_name})')
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
        from django.conf import settings as dj_settings
        if not dj_settings.DEBUG:
            return Response({'error': 'Not available in production.'}, status=status.HTTP_403_FORBIDDEN)

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
