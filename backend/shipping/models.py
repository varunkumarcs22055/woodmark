"""
ShippingZone — pincode-prefix → fee + ETD lookup.

A zone matches by `pincode_prefix` (the leading digits of an Indian PIN code).
The longest matching prefix wins, so '110' overrides '1' for Delhi-specific
rules. If no zone matches we fall back to StoreSettings.standard_shipping_fee.
"""
from decimal import Decimal
from django.db import models


class ShippingZone(models.Model):
    name = models.CharField(max_length=80)
    pincode_prefix = models.CharField(
        max_length=6, db_index=True,
        help_text='Leading digits of pincode. Longer = more specific.',
    )
    base_fee = models.DecimalField(max_digits=8, decimal_places=2, default=Decimal('0'))
    per_kg_fee = models.DecimalField(
        max_digits=8, decimal_places=2, default=Decimal('0'),
        help_text='Additional fee per kilogram (charged on items > 1 kg).',
    )
    free_shipping_threshold = models.DecimalField(
        max_digits=10, decimal_places=2, default=Decimal('0'),
        help_text='Cart subtotal at/above which shipping is free for this zone. 0 = always charge.',
    )
    etd_days_min = models.PositiveSmallIntegerField(default=3)
    etd_days_max = models.PositiveSmallIntegerField(default=7)
    cod_available = models.BooleanField(default=True)
    is_active = models.BooleanField(default=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'shipping_zones'
        ordering = ['-pincode_prefix']  # longer prefixes first when ties broken in code

    def __str__(self):
        return f'{self.name} ({self.pincode_prefix}*)'
