"""
Payments app — Admin configuration.
"""

from django.contrib import admin
from .models import Payment


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    """Admin interface for payment records."""
    list_display = (
        'order', 'status', 'amount', 'razorpay_order_id',
        'razorpay_payment_id', 'created_at'
    )
    list_filter = ('status', 'created_at')
    search_fields = ('order__order_id', 'razorpay_order_id', 'razorpay_payment_id')
    readonly_fields = ('order', 'amount', 'created_at')
