"""
Coupon evaluation. Pure-function — does NOT mutate; the caller is responsible
for redeeming via `redeem(coupon, user, order, amount)` after the order is
saved.
"""
from decimal import Decimal, ROUND_HALF_UP
from typing import NamedTuple, Optional

from django.db import transaction
from django.db.models import F

from .models import Coupon, CouponRedemption


class CouponResult(NamedTuple):
    ok: bool
    coupon: Optional[Coupon]
    discount: Decimal      # rupees off the cart subtotal
    free_shipping: bool
    message: str           # human-readable reason on failure / success


def _round(value: Decimal) -> Decimal:
    return Decimal(value).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)


def evaluate(code: str, *, subtotal, user=None, role='user') -> CouponResult:
    """Look up + validate a coupon for a given cart context. Read-only."""
    code = (code or '').strip().upper()
    if not code:
        return CouponResult(False, None, Decimal('0'), False, 'Enter a coupon code.')

    try:
        coupon = Coupon.objects.get(code__iexact=code)
    except Coupon.DoesNotExist:
        return CouponResult(False, None, Decimal('0'), False, 'Invalid coupon code.')

    ok, reason = coupon.is_currently_valid()
    if not ok:
        return CouponResult(False, coupon, Decimal('0'), False, reason)

    subtotal = Decimal(str(subtotal or 0))
    if subtotal < coupon.min_subtotal:
        return CouponResult(
            False, coupon, Decimal('0'), False,
            f'Minimum subtotal of ₹{coupon.min_subtotal} required for this coupon.',
        )

    if coupon.allowed_role != 'any' and coupon.allowed_role != role:
        return CouponResult(
            False, coupon, Decimal('0'), False,
            f'This coupon is only for {coupon.get_allowed_role_display().lower()} accounts.',
        )

    if user is not None and getattr(user, 'is_authenticated', False) and coupon.per_user_limit:
        used = CouponRedemption.objects.filter(coupon=coupon, user=user).count()
        if used >= coupon.per_user_limit:
            return CouponResult(
                False, coupon, Decimal('0'), False,
                'You have already used this coupon the maximum number of times.',
            )

    if coupon.type == 'shipping':
        return CouponResult(True, coupon, Decimal('0'), True,
                            f'Free shipping applied with code {coupon.code}.')

    if coupon.type == 'percent':
        discount = subtotal * coupon.value / Decimal('100')
        if coupon.max_discount and coupon.max_discount > 0:
            discount = min(discount, coupon.max_discount)
    else:  # flat
        discount = min(coupon.value, subtotal)

    discount = _round(max(discount, Decimal('0')))
    return CouponResult(True, coupon, discount, False,
                        f'Coupon {coupon.code} applied — you save ₹{discount}.')


@transaction.atomic
def redeem(coupon: Coupon, *, user, order, discount_amount: Decimal):
    """Increment used_count + write a CouponRedemption row. Idempotent per order."""
    if order and CouponRedemption.objects.filter(coupon=coupon, order=order).exists():
        return
    Coupon.objects.filter(pk=coupon.pk).update(used_count=F('used_count') + 1)
    CouponRedemption.objects.create(
        coupon=coupon,
        user=user if user and user.is_authenticated else None,
        order=order,
        discount_amount=Decimal(discount_amount or 0),
    )
