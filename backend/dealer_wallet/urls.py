from django.urls import path
from . import views

# Mounted twice — once at /api/dealer/wallet/ for the dealer's own view,
# once at /api/admin/dealers/<pk>/wallet/topup/ for admin actions. The
# project urls.py wires both prefixes to this same module.
urlpatterns = [
    path('', views.DealerWalletView.as_view(), name='dealer-wallet'),
    path('admin/<int:pk>/topup/', views.AdminWalletTopupView.as_view(), name='dealer-wallet-topup'),
]
