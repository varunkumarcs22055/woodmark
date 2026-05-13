"""
Dealer pricing resolver.

Order of precedence:
  1. NegotiatedPrice(dealer, product) — flat override, wins outright
  2. Tier discount (User.dealer_tier.default_discount_pct) AND
     quantity tier (existing discounts.Discount with discount_type='dealer'
     and min_quantity <= cart_qty) — multiplicative stacking

Returns:
  {
    "effective_price": Decimal,
    "mrp": Decimal,
    "savings": Decimal,
    "tier_label": str | None,        # "Premium 31%"
    "qty_tier_min": int | None,      # min_quantity rung that won, e.g. 5
    "qty_tier_pct": Decimal | None,  # the % off from the qty tier
    "source": "negotiated" | "tier" | "qty" | "tier+qty" | "none",
  }
"""
from decimal import Decimal

from .models import NegotiatedPrice


def _zero(): return Decimal('0.00')


def _round(x): return x.quantize(Decimal('0.01'))


def resolve(product, dealer, quantity=1):
    mrp = Decimal(str(product.price))

    # 1) Negotiated price short-circuit
    neg = None
    if hasattr(product, '_prefetched_objects_cache') and 'negotiated_prices' in product._prefetched_objects_cache:
        for n in product.negotiated_prices.all():
            if n.dealer_id == dealer.id:
                neg = n
                break
    else:
        neg = (
            NegotiatedPrice.objects
            .filter(dealer=dealer, product=product)
            .first()
        )
    if neg is not None and neg.is_currently_valid():
        effective = _round(Decimal(str(neg.agreed_price)))
        return {
            'effective_price': effective,
            'mrp': mrp,
            'savings': max(_zero(), mrp - effective),
            'tier_label': None,
            'qty_tier_min': None,
            'qty_tier_pct': None,
            'source': 'negotiated',
        }

    # 2) Tier + quantity-tier
    tier = getattr(dealer, 'dealer_tier', None)
    tier_pct = Decimal(str(tier.default_discount_pct)) if tier else _zero()

    # Quantity-tier — re-use the existing dealer discount ladder.
    from discounts.services import get_active_discount
    qty_tier = get_active_discount(product, 'dealer', quantity=quantity)
    qty_pct = _zero()
    qty_min = None
    if qty_tier and qty_tier.mode == 'percent':
        qty_pct = Decimal(str(qty_tier.value))
        qty_min = qty_tier.min_quantity
    elif qty_tier and qty_tier.mode == 'flat':
        # Flat discounts are applied as an absolute rupee delta after the percent step.
        qty_pct = _zero()
        qty_min = qty_tier.min_quantity

    multiplier = (Decimal('1') - tier_pct / Decimal('100')) * \
                 (Decimal('1') - qty_pct / Decimal('100'))
    multiplier = max(Decimal('0'), multiplier)

    effective = _round(mrp * multiplier)
    if qty_tier and qty_tier.mode == 'flat':
        effective = max(_zero(), effective - Decimal(str(qty_tier.value)))

    source_parts = []
    if tier_pct > 0:
        source_parts.append('tier')
    if qty_tier:
        source_parts.append('qty')
    source = '+'.join(source_parts) or 'none'

    return {
        'effective_price': effective,
        'mrp': mrp,
        'savings': max(_zero(), mrp - effective),
        'tier_label': f'{tier.name} {tier_pct}%' if tier else None,
        'qty_tier_min': qty_min,
        'qty_tier_pct': qty_pct if qty_pct else None,
        'source': source,
    }
