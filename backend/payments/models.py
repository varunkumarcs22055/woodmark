"""
Payments app — Models.

Payment model tracks payment status for orders.
Structured to support future Razorpay integration.
"""

from django.db import models
from orders.models import Order


class Payment(models.Model):
    """
    Payment record linked to an order.

    Currently uses simulated payment.
    Razorpay fields (razorpay_order_id, razorpay_payment_id) are nullable
    and will be populated when real Razorpay integration is added.
    """

    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
    ]

    order = models.OneToOneField(
        Order,
        on_delete=models.CASCADE,
        related_name='payment'
    )

    # Razorpay fields — nullable for now (simulated payment)
    razorpay_order_id = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        help_text='Razorpay Order ID (populated when Razorpay is integrated)'
    )
    razorpay_payment_id = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        help_text='Razorpay Payment ID (populated when Razorpay is integrated)'
    )

    status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default='PENDING'
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'payments'

    def __str__(self):
        return f'Payment for {self.order.order_id} — {self.status}'
