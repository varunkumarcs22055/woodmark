"""
Payments app — URL configuration.
"""

from django.urls import path
from . import views

urlpatterns = [
    # POST /api/payment/success/ — Simulate payment success
    path('success/', views.PaymentSuccessView.as_view(), name='payment-success'),
]
