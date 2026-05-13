from django.conf import settings
from django.db import models


class DealerTier(models.Model):
    """
    Named pricing tier (standard / premium / platinum). Each tier has a
    default percentage discount applied on top of MRP. The actual effective
    price is computed in `services/dealer_pricing.py::resolve` so per-product
    quantity-tier discounts (existing `Discount` rows) can stack
    multiplicatively.
    """
    slug = models.SlugField(max_length=20, unique=True)
    name = models.CharField(max_length=80)
    default_discount_pct = models.DecimalField(
        max_digits=5, decimal_places=2, default=0,
        help_text='Percent off MRP for dealers in this tier (0–100).',
    )
    sort_order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'dealer_tiers'
        ordering = ['sort_order', 'slug']

    def __str__(self):
        return f'{self.name} ({self.default_discount_pct}%)'


class NegotiatedPrice(models.Model):
    """
    Per-dealer per-product price override. When a non-expired row exists for a
    (dealer, product), the resolver returns `agreed_price` flat and ignores
    tier + quantity-tier ladders.
    """
    dealer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='negotiated_prices',
    )
    product = models.ForeignKey(
        'products.Product', on_delete=models.CASCADE,
        related_name='negotiated_prices',
    )
    agreed_price = models.DecimalField(max_digits=10, decimal_places=2)
    valid_from = models.DateTimeField(null=True, blank=True)
    valid_until = models.DateTimeField(null=True, blank=True)
    note = models.TextField(blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='created_negotiated_prices',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'negotiated_prices'
        constraints = [
            models.UniqueConstraint(
                fields=['dealer', 'product'],
                name='one_negotiated_price_per_dealer_product',
            ),
        ]
        indexes = [
            models.Index(fields=['dealer', 'product']),
        ]

    def is_currently_valid(self, now=None):
        from django.utils import timezone
        now = now or timezone.now()
        if self.valid_from and now < self.valid_from:
            return False
        if self.valid_until and now > self.valid_until:
            return False
        return True

    def __str__(self):
        return f'{self.dealer_id}/{self.product_id}: {self.agreed_price}'
