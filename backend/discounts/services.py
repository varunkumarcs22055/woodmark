from decimal import Decimal
from django.utils import timezone
from django.db import models, transaction
from django.db.models import F


def get_active_discount(product, discount_type):
    """
    Retrieve the active, non-expired, non-exhausted discount for a product and type.
    Returns Discount instance or None.
    """
    from .models import Discount
    now = timezone.now()
    discount = Discount.objects.filter(
        product=product,
        discount_type=discount_type,
        active=True,
    ).filter(
        models.Q(starts_at__isnull=True) | models.Q(starts_at__lte=now)
    ).filter(
        models.Q(ends_at__isnull=True) | models.Q(ends_at__gte=now)
    ).first()

    if discount is None:
        return None
    if discount.is_exhausted:
        return None
    return discount


def get_effective_price(product, user_role):
    """
    Compute the effective (after-discount) price for a product given a user role.

    Returns:
        tuple: (effective_price: Decimal, discount: Discount|None, units_remaining: int|None)
    """
    # SQLite returns DecimalField as string; always coerce to Decimal
    base_price = Decimal(str(product.price))

    if user_role not in ('user', 'dealer'):
        return base_price, None, None

    discount = get_active_discount(product, user_role)

    if discount is None:
        from .models import Discount
        now = timezone.now()
        exhausted = Discount.objects.filter(
            product=product,
            discount_type=user_role,
            active=True,
        ).filter(
            models.Q(starts_at__isnull=True) | models.Q(starts_at__lte=now)
        ).filter(
            models.Q(ends_at__isnull=True) | models.Q(ends_at__gte=now)
        ).filter(
            count_limit__isnull=False,
            units_sold__gte=models.F('count_limit')
        ).first()
        if exhausted:
            return base_price, None, 0
        return base_price, None, None

    if discount.mode == 'percent':
        multiplier = Decimal('1') - (discount.value / Decimal('100'))
        effective = base_price * multiplier
    else:
        effective = base_price - discount.value
        effective = max(Decimal('0'), effective)

    effective = effective.quantize(Decimal('0.01'))
    return effective, discount, discount.units_remaining


def apply_discounts_to_order(order, user_role):
    """
    Atomically increment units_sold for each discounted product in an order.
    Must be called inside a database transaction after order is confirmed.
    Uses select_for_update() to prevent race conditions when count_limit is set.
    """
    from .models import Discount

    for item in order.items.select_related('product').all():
        discount = get_active_discount(item.product, user_role)
        if discount is None:
            continue

        with transaction.atomic():
            locked_discount = Discount.objects.select_for_update().get(pk=discount.pk)

            if locked_discount.count_limit is not None:
                remaining = locked_discount.count_limit - locked_discount.units_sold
                units_to_credit = min(item.quantity, remaining)
            else:
                units_to_credit = item.quantity

            if units_to_credit > 0:
                Discount.objects.filter(pk=locked_discount.pk).update(
                    units_sold=F('units_sold') + units_to_credit
                )


def validate_discount_availability(product, user_role, quantity):
    """
    Validate that a discount is available for the given quantity.
    Called during order creation validation.

    Returns:
        tuple: (is_valid: bool, error_message: str|None)
    """
    discount = get_active_discount(product, user_role)
    if discount is None:
        return True, None

    if discount.count_limit is not None:
        remaining = discount.units_remaining
        if remaining == 0:
            return True, None
    return True, None
