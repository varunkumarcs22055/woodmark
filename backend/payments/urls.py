from django.urls import path
from . import views

urlpatterns = [
    path('create-razorpay-order/', views.CreateRazorpayOrderView.as_view(), name='create-razorpay-order'),
    path('verify/', views.PaymentVerifyView.as_view(), name='payment-verify'),
    path('webhook/', views.RazorpayWebhookView.as_view(), name='razorpay-webhook'),
    path('success/', views.PaymentSimulateView.as_view(), name='payment-simulate'),
    # Self-service reconcile: "I paid but my order isn't showing as paid"
    path('reconcile/', views.PaymentReconcileView.as_view(), name='payment-reconcile'),
]
