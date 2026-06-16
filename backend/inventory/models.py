from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models, transaction
from products.models import Product, ProductVariant


class Warehouse(models.Model):
    name = models.CharField(max_length=100, unique=True)
    code = models.CharField(max_length=10, unique=True)
    address = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'warehouses'
        ordering = ['name']

    def __str__(self):
        return f'{self.name} [{self.code}]'


class StockLevel(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='stock_levels')
    variant = models.ForeignKey(
        ProductVariant, null=True, blank=True,
        on_delete=models.CASCADE, related_name='stock_levels',
    )
    warehouse = models.ForeignKey(Warehouse, on_delete=models.PROTECT, related_name='stock_levels')
    quantity = models.IntegerField(default=0)
    low_threshold = models.PositiveIntegerField(default=5)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'stock_levels'
        unique_together = [('product', 'variant', 'warehouse')]
        indexes = [
            models.Index(fields=['warehouse', 'product']),
        ]

    def clean(self):
        if self.quantity < 0:
            raise ValidationError({'quantity': 'Stock level cannot be negative.'})

    @property
    def is_low(self):
        return self.quantity <= self.low_threshold

    def __str__(self):
        var = f' / {self.variant.option_value}' if self.variant_id else ''
        return f'{self.product.name}{var} @ {self.warehouse.code}: {self.quantity}'


class StockMovement(models.Model):
    REASON_CHOICES = [
        ('inbound', 'Inbound'),
        ('order', 'Order Fulfillment'),
        ('return', 'Return Restock'),
        ('adjustment', 'Manual Adjustment'),
    ]

    stock_level = models.ForeignKey(StockLevel, on_delete=models.PROTECT, related_name='movements')
    delta = models.IntegerField(help_text='Positive = inbound, negative = outbound.')
    reason = models.CharField(max_length=20, choices=REASON_CHOICES)
    reference = models.CharField(max_length=64, blank=True, help_text='e.g. order_id, PO number')
    note = models.TextField(blank=True)
    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='stock_movements',
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = 'stock_movements'
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        # Atomic: lock the stock level row, validate non-negative result, apply
        # delta, AND propagate the delta onto Product.stock so the customer-
        # facing storefront sees the new quantity immediately. Without that
        # second update, warehouse adjustments were invisible to shoppers —
        # admin saw 50 in stock, storefront still said "Out of stock".
        from django.db.models import F
        from products.models import Product
        with transaction.atomic():
            level = StockLevel.objects.select_for_update().get(pk=self.stock_level_id)
            new_quantity = level.quantity + self.delta
            if new_quantity < 0:
                raise ValidationError(
                    f'Movement would drive stock negative ({level.quantity} + {self.delta}).'
                )
            level.quantity = new_quantity
            level.save(update_fields=['quantity', 'updated_at'])
            # Capture the storefront stock BEFORE we bump it, so we can detect a
            # 0 -> positive transition and fire back-in-stock alerts.
            prev_stock = (Product.objects.filter(pk=level.product_id)
                          .values_list('stock', flat=True).first()) or 0
            # Propagate to Product.stock. F-expression keeps it atomic vs
            # concurrent order placements that also touch product.stock.
            Product.objects.filter(pk=level.product_id).update(
                stock=F('stock') + self.delta,
            )
            super().save(*args, **kwargs)
            # Restock transition → notify subscribers AFTER commit (email I/O
            # must never roll back the movement).
            if self.delta > 0 and prev_stock <= 0:
                pid = level.product_id
                from products.stock_alerts import notify_back_in_stock
                transaction.on_commit(lambda: notify_back_in_stock(pid))

    def __str__(self):
        sign = '+' if self.delta >= 0 else ''
        return f'{sign}{self.delta} ({self.reason}) on {self.stock_level}'
