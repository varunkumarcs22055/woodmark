from django.db import models
from django.conf import settings


class Discount(models.Model):
    DISCOUNT_TYPE_CHOICES = [
        ('user', 'User Discount'),
        ('dealer', 'Dealer Discount'),
    ]
    MODE_CHOICES = [
        ('percent', 'Percentage'),
        ('flat', 'Flat Amount (₹)'),
    ]

    product = models.ForeignKey(
        'products.Product',
        on_delete=models.CASCADE,
        related_name='discounts'
    )
    discount_type = models.CharField(max_length=10, choices=DISCOUNT_TYPE_CHOICES)
    mode = models.CharField(max_length=10, choices=MODE_CHOICES)
    value = models.DecimalField(
        max_digits=10, decimal_places=2,
        help_text='15 for 15%, or 2000 for ₹2000 off'
    )
    count_limit = models.PositiveIntegerField(
        null=True, blank=True,
        help_text='Maximum units at discounted price. NULL = unlimited.'
    )
    units_sold = models.PositiveIntegerField(
        default=0,
        help_text='Auto-incremented when a discounted unit is ordered.'
    )
    active = models.BooleanField(default=True)
    starts_at = models.DateTimeField(null=True, blank=True)
    ends_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='created_discounts'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'discounts'
        unique_together = [('product', 'discount_type')]
        indexes = [
            models.Index(fields=['product', 'discount_type']),
            models.Index(fields=['active']),
        ]

    def __str__(self):
        return f'{self.get_discount_type_display()} on {self.product.name} — {self.value}{"%" if self.mode == "percent" else "₹"}'

    @property
    def units_remaining(self):
        if self.count_limit is None:
            return None
        return max(0, self.count_limit - self.units_sold)

    @property
    def is_exhausted(self):
        if self.count_limit is None:
            return False
        return self.units_sold >= self.count_limit
