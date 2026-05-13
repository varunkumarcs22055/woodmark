"""
Coupon — site-wide promo code applied at checkout.

Distinct from `discounts.Discount`: discounts are per-product / per-quantity-tier
and apply to listing/PDP pricing automatically. Coupons are typed in by the
shopper at checkout, apply once to the cart subtotal, and cannot stack with
each other (one coupon per order).
"""
from decimal import Decimal

from django.conf import settings
from django.db import models
from django.utils import timezone


class Coupon(models.Model):
    TYPE_CHOICES = [
        ('percent', 'Percent off subtotal'),
        ('flat', 'Flat amount off subtotal'),
        ('shipping', 'Free shipping'),
    ]
    ROLE_CHOICES = [('user', 'Customer'), ('dealer', 'Dealer'), ('any', 'Any')]

    code = models.CharField(max_length=40, unique=True, db_index=True)
    description = models.CharField(max_length=200, blank=True)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES, default='percent')
    value = models.DecimalField(
        max_digits=10, decimal_places=2, default=0,
        help_text='Percent (0-100) for type=percent, INR for type=flat. Ignored for shipping.',
    )
    min_subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    max_discount = models.DecimalField(
        max_digits=10, decimal_places=2, default=0,
        help_text='Cap for percent coupons. 0 = no cap.',
    )

    max_uses = models.PositiveIntegerField(
        default=0, help_text='Total uses across all users. 0 = unlimited.',
    )
    used_count = models.PositiveIntegerField(default=0)
    per_user_limit = models.PositiveSmallIntegerField(
        default=1, help_text='How many times one account can use it. 0 = unlimited.',
    )

    allowed_role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='any')
    valid_from = models.DateTimeField(null=True, blank=True)
    valid_until = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'coupons'
        ordering = ['-created_at']

    def __str__(self):
        return self.code

    def is_currently_valid(self):
        now = timezone.now()
        if not self.is_active:
            return False, 'This coupon is disabled.'
        if self.valid_from and now < self.valid_from:
            return False, 'This coupon is not yet active.'
        if self.valid_until and now > self.valid_until:
            return False, 'This coupon has expired.'
        if self.max_uses and self.used_count >= self.max_uses:
            return False, 'This coupon has reached its usage limit.'
        return True, None


class CouponRedemption(models.Model):
    """One row per successful coupon application — used to enforce per_user_limit."""
    coupon = models.ForeignKey(Coupon, on_delete=models.CASCADE, related_name='redemptions')
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='coupon_redemptions',
    )
    order = models.ForeignKey(
        'orders.Order', on_delete=models.SET_NULL, null=True, blank=True,
        related_name='coupon_redemptions',
    )
    discount_amount = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    redeemed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'coupon_redemptions'
        ordering = ['-redeemed_at']
