import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from products.models import Product


class Order(models.Model):
    PAYMENT_STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
    ]
    ORDER_STATUS_CHOICES = [
        ('CREATED', 'Created'),
        ('CONFIRMED', 'Confirmed'),
        ('SHIPPED', 'Shipped'),
        ('DELIVERED', 'Delivered'),
        ('CANCELLED', 'Cancelled'),
    ]

    order_id = models.CharField(max_length=20, unique=True, editable=False)
    user_name = models.CharField(max_length=100)
    user_email = models.EmailField(db_index=True)
    phone = models.CharField(max_length=15)
    address = models.TextField()
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='orders'
    )
    subtotal_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    gst_percent = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    gst_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    shipping_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_status = models.CharField(
        max_length=10, choices=PAYMENT_STATUS_CHOICES, default='PENDING', db_index=True
    )
    order_status = models.CharField(
        max_length=12, choices=ORDER_STATUS_CHOICES, default='CREATED', db_index=True
    )
    erp_order_id = models.CharField(max_length=50, blank=True, null=True)
    erp_sync_status = models.CharField(
        max_length=10,
        choices=[('pending', 'Pending'), ('synced', 'Synced'), ('failed', 'Failed')],
        default='pending'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user_email']),
            models.Index(fields=['payment_status', 'order_status']),
        ]

    def save(self, *args, **kwargs):
        if not self.order_id:
            self.order_id = f'ORD-{uuid.uuid4().hex[:8].upper()}'
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.order_id} — {self.user_name}'


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name='order_items')
    quantity = models.PositiveIntegerField()
    price = models.DecimalField(
        max_digits=10, decimal_places=2,
        help_text='Effective price (after discount) at time of order'
    )
    original_price = models.DecimalField(
        max_digits=10, decimal_places=2,
        help_text='Full price at time of order (before discount)'
    )

    class Meta:
        db_table = 'order_items'

    @property
    def subtotal(self):
        return Decimal(str(self.price)) * self.quantity

    def __str__(self):
        return f'{self.product.name} × {self.quantity}'
