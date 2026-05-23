from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='auth-register'),
    path('verify-email/', views.VerifyEmailView.as_view(), name='auth-verify-email'),
    path('resend-verification/', views.ResendSignupOTPView.as_view(),
         name='auth-resend-verification'),
    path('login/', views.LoginView.as_view(), name='auth-login'),
    path('logout/', views.LogoutView.as_view(), name='auth-logout'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('profile/', views.UserProfileView.as_view(), name='auth-profile'),
    path('change-password/', views.ChangePasswordView.as_view(), name='auth-change-password'),
    path('addresses/', views.UserAddressListCreateView.as_view(), name='auth-addresses'),
    path('addresses/<int:pk>/', views.UserAddressDetailView.as_view(), name='auth-address-detail'),
    path('dealer-apply/', views.DealerApplicationView.as_view(), name='dealer-apply'),
    path('dealers/pending/', views.DealerApprovalView.as_view(), name='dealers-pending'),
    path('dealers/<int:pk>/approve/', views.DealerApprovalView.as_view(), name='dealer-approve'),
    path('dealers/tiers/', include([
        path('', views.DealerTierListView.as_view(), name='dealer-tiers'),
    ])),
    path('google/', views.GoogleLoginRedirectView.as_view(), name='google-login'),
    path('users/', views.UserListView.as_view(), name='user-list'),
    path('dev-login/', views.DevLoginView.as_view(), name='dev-login'),
    path('password-reset/request/', views.PasswordResetRequestView.as_view(), name='password-reset-request'),
    path('password-reset/confirm/', views.PasswordResetConfirmView.as_view(), name='password-reset-confirm'),
    path('otp/request/', views.EmailOTPRequestView.as_view(), name='otp-request'),
    path('otp/verify/', views.EmailOTPVerifyView.as_view(), name='otp-verify'),
    # Admin-only: list & create other admin accounts
    path('admins/', views.AdminUserListCreateView.as_view(), name='admin-user-list'),
    path('admins/<int:pk>/', views.AdminUserDetailView.as_view(), name='admin-user-detail'),
]
