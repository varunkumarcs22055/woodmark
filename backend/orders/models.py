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
    PACKING_STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('packed', 'Packed'),
    ]
    SHIPPING_STATUS_CHOICES = [
        ('not_shipped', 'Not Shipped'),
        ('shipped', 'Shipped'),
        ('in_transit', 'In Transit'),
        ('delivered', 'Delivered'),
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
    coupon_code = models.CharField(max_length=40, blank=True, db_index=True)
    coupon_discount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    # Pay-now incentive: when the buyer chooses to pay immediately (razorpay /
    # wallet) we apply EARLY_PAYMENT_DISCOUNT_PCT off the subtotal. Stored on
    # the order so invoices reflect the actual discount given.
    payment_type = models.CharField(
        max_length=12,
        choices=[('immediate', 'Immediate'), ('credit', 'On Credit'), ('cod', 'COD')],
        default='immediate', db_index=True,
        help_text='Whether the order is paid now, on credit, or COD; drives early-payment discount.',
    )
    early_payment_discount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_status = models.CharField(
        max_length=10, choices=PAYMENT_STATUS_CHOICES, default='PENDING', db_index=True
    )
    order_status = models.CharField(
        max_length=12, choices=ORDER_STATUS_CHOICES, default='CREATED', db_index=True
    )
    packing_status = models.CharField(
        max_length=10, choices=PACKING_STATUS_CHOICES, default='pending', db_index=True
    )
    shipping_status = models.CharField(
        max_length=12, choices=SHIPPING_STATUS_CHOICES, default='not_shipped', db_index=True
    )
    tracking_carrier = models.CharField(max_length=80, blank=True)
    tracking_number = models.CharField(max_length=80, blank=True)
    shipped_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    cancellation_reason = models.TextField(blank=True)
    # Dealer / B2B fields
    payment_method = models.CharField(
        max_length=20, default='razorpay',
        help_text="razorpay / cod / credit (dealer-only) / wallet (dealer-only).",
    )
    po_number = models.CharField(max_length=80, blank=True,
                                 help_text='Purchase order number (dealer).')
    dealer_note = models.TextField(blank=True)
    preferred_carrier = models.CharField(max_length=80, blank=True)
    # GST snapshot — frozen at order time so a dealer who later updates their
    # profile GSTIN doesn't retroactively change historical invoices. This is
    # a legal compliance requirement under Indian GST rules.
    billing_gstin = models.CharField(
        max_length=15, blank=True,
        help_text='GSTIN snapshotted at order time. Empty for B2C.',
    )
    billing_company_name = models.CharField(
        max_length=200, blank=True,
        help_text='Company name snapshotted at order time (dealers only).',
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
    # Dealer backorder: when an active dealer requests more than current stock,
    # we accept the line and ship as inventory comes in. The expected restock
    # date is set from store policy (default = today + 14d) so dealers know.
    is_backorder = models.BooleanField(default=False, db_index=True)
    backorder_quantity = models.PositiveIntegerField(default=0)
    expected_restock_date = models.DateField(null=True, blank=True)

    class Meta:
        db_table = 'order_items'

    @property
    def subtotal(self):
        return Decimal(str(self.price)) * self.quantity

    def __str__(self):
        return f'{self.product.name} × {self.quantity}'


class OrderReturn(models.Model):
    STATUS_CHOICES = [
        ('requested', 'Requested'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('received', 'Received'),
        ('refunded', 'Refunded'),
    ]
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='returns')
    requested_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='return_requests',
    )
    reason = models.TextField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='requested', db_index=True)
    refund_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    admin_note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'order_returns'
        ordering = ['-created_at']

    def __str__(self):
        return f'Return for {self.order.order_id} ({self.status})'


class Refund(models.Model):
    GATEWAY_CHOICES = [
        ('razorpay', 'Razorpay'),
        ('manual', 'Manual'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('success', 'Success'),
        ('failed', 'Failed'),
    ]
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='refunds')
    return_request = models.ForeignKey(
        OrderReturn, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='refunds',
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    gateway = models.CharField(max_length=10, choices=GATEWAY_CHOICES, default='manual')
    gateway_refund_id = models.CharField(max_length=100, blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending', db_index=True)
    note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'refunds'
        ordering = ['-created_at']

    def __str__(self):
        return f'Refund {self.amount} for {self.order.order_id} ({self.status})'
