from django.conf import settings
from django.db import models


class InvoiceCounter(models.Model):
    """
    Atomic counter per fiscal year. Use `select_for_update()` when
    incrementing so concurrent invoice creates can't collide on the sequence.
    """
    year = models.PositiveIntegerField(primary_key=True)
    last_seq = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = 'invoice_counters'

    def __str__(self):
        return f'{self.year}: {self.last_seq}'


class Invoice(models.Model):
    PAYMENT_STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
        ('REFUNDED', 'Refunded'),
    ]

    invoice_number = models.CharField(max_length=20, unique=True, db_index=True)
    order = models.OneToOneField(
        'orders.Order', on_delete=models.PROTECT, related_name='invoice',
    )
    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='invoices',
    )

    # Snapshot — stored at create time so renames in Settings/Order
    # don't retroactively change historical invoices.
    billing_name = models.CharField(max_length=120)
    billing_address_text = models.TextField()
    billing_pincode = models.CharField(max_length=10, blank=True)
    billing_state = models.CharField(max_length=80, blank=True)
    shipping_address_text = models.TextField(blank=True)

    store_name = models.CharField(max_length=120)
    store_legal_name = models.CharField(max_length=200, blank=True)
    store_gstin = models.CharField(max_length=15, blank=True)
    store_address = models.TextField(blank=True)
    store_email = models.EmailField(blank=True)
    store_phone = models.CharField(max_length=20, blank=True)

    subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    discount_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    cgst_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    sgst_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    igst_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    shipping_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    grand_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    payment_status = models.CharField(
        max_length=10, choices=PAYMENT_STATUS_CHOICES, default='PENDING', db_index=True,
    )
    payment_method = models.CharField(max_length=20, default='razorpay')

    # Running balance — for dealer credit invoices that get paid in
    # tranches. For B2C invoices, payment_status='SUCCESS' and
    # amount_paid == grand_total at create time.
    amount_paid = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    amount_due = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    invoice_date = models.DateField()
    due_date = models.DateField(null=True, blank=True)
    pdf_url = models.URLField(max_length=500, blank=True)
    emailed_at = models.DateTimeField(null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'invoices'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['payment_status', '-created_at']),
            models.Index(fields=['customer', '-created_at']),
        ]

    def __str__(self):
        return f'{self.invoice_number} ({self.payment_status})'


class InvoiceItem(models.Model):
    invoice = models.ForeignKey(Invoice, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(
        'products.Product', on_delete=models.PROTECT, related_name='invoice_items',
    )
    variant = models.ForeignKey(
        'products.ProductVariant', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='invoice_items',
    )

    # Snapshot fields — survive product rename / SKU regeneration / variant deletion.
    product_name = models.CharField(max_length=255)
    product_sku = models.CharField(max_length=40, blank=True)
    variant_label = models.CharField(max_length=120, blank=True)
    hsn_code = models.CharField(max_length=10, blank=True)

    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=10, decimal_places=2,
                                     help_text='Net of discount, pre-tax.')
    original_unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    line_subtotal = models.DecimalField(max_digits=10, decimal_places=2,
                                        help_text='unit_price × quantity (pre-tax).')
    line_discount = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    cgst_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    sgst_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    igst_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    cgst_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    sgst_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    igst_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    line_total = models.DecimalField(max_digits=10, decimal_places=2,
                                     help_text='subtotal − discount + taxes.')

    class Meta:
        db_table = 'invoice_items'
        ordering = ['id']

    def __str__(self):
        return f'{self.product_name} × {self.quantity}'
