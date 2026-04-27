"""
Orders app — Models.

Defines Order and OrderItem models for tracking customer purchases.
Orders support guest checkout (no user account required).
"""

import uuid
from django.db import models
from products.models import Product


class Order(models.Model):
    """
    Order model representing a customer purchase.
    Supports guest checkout via name/email/phone fields.
    """

    # Payment status choices
    PAYMENT_STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
    ]

    # Order status choices
    ORDER_STATUS_CHOICES = [
        ('CREATED', 'Created'),
        ('CONFIRMED', 'Confirmed'),
        ('SHIPPED', 'Shipped'),
        ('DELIVERED', 'Delivered'),
        ('CANCELLED', 'Cancelled'),
    ]

    # Unique order identifier (human-readable)
    order_id = models.CharField(
        max_length=20,
        unique=True,
        editable=False,
        help_text='Auto-generated unique order ID (e.g., ORD-XXXXXX)'
    )

    # Guest checkout fields (no user account needed)
    user_name = models.CharField(max_length=100)
    user_email = models.EmailField()
    phone = models.CharField(max_length=15)
    address = models.TextField()

    # Order financials
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)

    # Status tracking
    payment_status = models.CharField(
        max_length=10,
        choices=PAYMENT_STATUS_CHOICES,
        default='PENDING'
    )
    order_status = models.CharField(
        max_length=12,
        choices=ORDER_STATUS_CHOICES,
        default='CREATED'
    )

    # ERP integration
    erp_order_id = models.CharField(
        max_length=50,
        blank=True,
        null=True,
        help_text='Order ID returned from external ERP system'
    )

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        """Auto-generate a unique order_id if not set."""
        if not self.order_id:
            # Generate format: ORD-XXXXXXXX (8 hex chars)
            self.order_id = f'ORD-{uuid.uuid4().hex[:8].upper()}'
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.order_id} — {self.user_name}'


class OrderItem(models.Model):
    """
    Individual item within an order.
    Stores the price at time of purchase (won't change if product price updates).
    """
    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name='items'
    )
    product = models.ForeignKey(
        Product,
        on_delete=models.PROTECT,  # Don't delete products that have been ordered
        related_name='order_items'
    )
    quantity = models.PositiveIntegerField()
    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        help_text='Price at time of order (snapshot)'
    )

    class Meta:
        db_table = 'order_items'

    def __str__(self):
        return f'{self.product.name} x{self.quantity}'

    @property
    def subtotal(self):
        """Calculate line item subtotal."""
        return self.price * self.quantity
