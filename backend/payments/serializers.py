"""
Payments app — Serializers.
"""

from rest_framework import serializers
from .models import Payment


class PaymentSerializer(serializers.ModelSerializer):
    """Serializer for Payment model."""
    order_id = serializers.CharField(source='order.order_id', read_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'order_id', 'razorpay_order_id',
            'razorpay_payment_id', 'status', 'amount', 'created_at'
        ]
