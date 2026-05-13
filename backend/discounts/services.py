"""
Discount resolution.

Tiers:
  Multiple Discount rows can exist per (product, discount_type) — one per
  `min_quantity` ladder rung. For a given cart quantity Q, the active discount
  is the row with the largest `min_quantity` ≤ Q (and not exhausted).

Example ladder for a sofa, dealer:
  min_qty=1  →  10% off
  min_qty=5  →  20% off
  min_qty=10 →  30% off

  Cart 3 units → 10% off. Cart 7 → 20%. Cart 15 → 30%.
"""
from decimal import Decimal

from django.db import transaction
from django.db.models import F, Q
from django.utils import timezone


def _now():
    return timezone.now()


def _date_window_q(now):
    return (
        (Q(starts_at__isnull=True) | Q(starts_at__lte=now))
        & (Q(ends_at__isnull=True) | Q(ends_at__gte=now))
    )


def get_discount_tiers(product, discount_type, *, only_active=True):
    """
    All applicable tier rows for (product, discount_type), ordered ascending
    by min_quantity. Used to render the ladder on product detail.
    """
    from .models import Discount
    qs = Discount.objects.filter(product=product, discount_type=discount_type)
    if only_active:
        qs = qs.filter(active=True).filter(_date_window_q(_now()))
    return list(qs.order_by('min_quantity'))


def get_active_discount(product, discount_type, quantity=1):
    """
    Return the highest-`min_quantity` tier whose `min_quantity <= quantity`,
    skipping rows that are date-expired or unit-exhausted.
    """
    now = _now()
    
    if hasattr(product, '_prefetched_objects_cache') and 'discounts' in product._prefetched_objects_cache:
        candidates = []
        for d in product.discounts.all():
            if not d.active or d.discount_type != discount_type or d.min_quantity > quantity:
                continue
            if d.starts_at and d.starts_at > now:
                continue
            if d.ends_at and d.ends_at < now:
                continue
            candidates.append(d)
        candidates.sort(key=lambda x: x.min_quantity, reverse=True)
    else:
        from .models import Discount
        candidates = (
            Discount.objects.filter(
                product=product,
                discount_type=discount_type,
                active=True,
                min_quantity__lte=quantity,
            )
            .filter(_date_window_q(now))
            .order_by('-min_quantity')
        )
    for tier in candidates:
        if not tier.is_exhausted:
            return tier
    return None


def _apply(base_price: Decimal, discount) -> Decimal:
    if discount.mode == 'percent':
        multiplier = Decimal('1') - (Decimal(str(discount.value)) / Decimal('100'))
        effective = base_price * multiplier
    else:
        effective = base_price - Decimal(str(discount.value))
        effective = max(Decimal('0'), effective)
    return effective.quantize(Decimal('0.01'))


def get_effective_price(product, user_role, quantity=1):
    """
    Compute (effective_price, discount_or_None, units_remaining_or_None) for a
    user-role, taking the cart `quantity` into account when picking the tier.
    """
    base_price = Decimal(str(product.price))

    if user_role not in ('user', 'dealer'):
        return base_price, None, None

    discount = get_active_discount(product, user_role, quantity=quantity)
    if discount is None:
        return base_price, None, None

    return _apply(base_price, discount), discount, discount.units_remaining


def apply_discounts_to_order(order, user_role):
    """
    Atomically increment units_sold for the tier each ordered item used.
    Called inside a transaction after the order is confirmed.
    """
    from .models import Discount

    for item in order.items.select_related('product').all():
        discount = get_active_discount(item.product, user_role, quantity=item.quantity)
        if discount is None:
            continue
        with transaction.atomic():
            locked = Discount.objects.select_for_update().get(pk=discount.pk)
            if locked.count_limit is not None:
                remaining = locked.count_limit - locked.units_sold
                units_to_credit = min(item.quantity, remaining)
            else:
                units_to_credit = item.quantity
            if units_to_credit > 0:
                Discount.objects.filter(pk=locked.pk).update(
                    units_sold=F('units_sold') + units_to_credit
                )


def validate_discount_availability(product, user_role, quantity):
    """
    Reserved hook for future stock-vs-cap checks. Currently always returns OK
    because the UI degrades gracefully when a tier is exhausted (we just fall
    back to a lower tier or no discount).
    """
    return True, None
