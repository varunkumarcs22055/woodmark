"""
Pure-function pincode → shipping estimate.
"""
from decimal import Decimal
from typing import Optional

from .models import ShippingZone


def _match_zone(pincode: str) -> Optional[ShippingZone]:
    """Longest-prefix match against active zones."""
    pincode = (pincode or '').strip()
    if not pincode.isdigit():
        return None
    candidates = (ShippingZone.objects
                  .filter(is_active=True)
                  .order_by('-pincode_prefix'))
    for z in candidates:
        if pincode.startswith(z.pincode_prefix):
            return z
    return None


def estimate(pincode: str, *, subtotal=0, weight_grams=0, prefer_cod=False):
    """
    Returns: {ok, fee, etd_days_min, etd_days_max, zone_name, cod_available, message}
    """
    subtotal = Decimal(str(subtotal or 0))
    weight_kg = Decimal(str(weight_grams or 0)) / Decimal('1000')

    zone = _match_zone(pincode)

    if zone is None:
        # Fall back to store-wide flat shipping (no ETD info available).
        from store_settings.models import StoreSettings
        store = StoreSettings.current()
        free = subtotal >= store.free_shipping_threshold
        fee = Decimal('0') if free else Decimal(str(store.standard_shipping_fee))
        return {
            'ok': True,
            'fee': str(fee),
            'etd_days_min': None,
            'etd_days_max': None,
            'zone_name': None,
            'cod_available': True,
            'message': 'Standard rate (no zone match for this pincode).',
        }

    if zone.free_shipping_threshold and subtotal >= zone.free_shipping_threshold:
        fee = Decimal('0')
        msg = f'Free shipping to {zone.name}.'
    else:
        weight_extra = max(weight_kg - Decimal('1'), Decimal('0'))
        fee = zone.base_fee + (weight_extra * zone.per_kg_fee)
        msg = f'Shipping to {zone.name}.'

    if prefer_cod and not zone.cod_available:
        msg += ' Note: COD is not available for this pincode.'

    return {
        'ok': True,
        'fee': str(fee.quantize(Decimal('0.01'))),
        'etd_days_min': zone.etd_days_min,
        'etd_days_max': zone.etd_days_max,
        'zone_name': zone.name,
        'cod_available': zone.cod_available,
        'message': msg,
    }
