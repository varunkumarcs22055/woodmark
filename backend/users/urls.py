from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='auth-register'),
    path('login/', views.LoginView.as_view(), name='auth-login'),
    path('logout/', views.LogoutView.as_view(), name='auth-logout'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('profile/', views.UserProfileView.as_view(), name='auth-profile'),
    path('dealer-apply/', views.DealerApplicationView.as_view(), name='dealer-apply'),
    path('dealers/pending/', views.DealerApprovalView.as_view(), name='dealers-pending'),
    path('dealers/<int:pk>/approve/', views.DealerApprovalView.as_view(), name='dealer-approve'),
    path('google/', views.GoogleLoginRedirectView.as_view(), name='google-login'),
    path('users/', views.UserListView.as_view(), name='user-list'),
    path('dev-login/', views.DevLoginView.as_view(), name='dev-login'),
]
