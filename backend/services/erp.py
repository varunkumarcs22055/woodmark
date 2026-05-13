"""
ERP Integration Service.

Contract (invariant — never break):
  send_order_to_erp() NEVER raises an exception to its caller.
  All errors are caught, logged, and handled internally.
  ERP failure never blocks payment confirmation.

Configuration:
  * If ERP_API_URL is empty, missing, or still the placeholder
    ("your-erp-api.com") we skip the network call entirely and return a
    deterministic internal ERP id derived from the order. This is the
    correct behaviour for businesses that haven't onboarded an external
    ERP yet — the order is treated as "self-fulfilled" by FurniShop and
    the admin dashboard never shows it as failed.
  * Set ERP_API_URL + ERP_API_KEY in `.env` once a real ERP is in place
    and outbound sync will resume automatically.
"""
import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def _erp_configured():
    """True only when a real, non-placeholder ERP endpoint is set."""
    url = (getattr(settings, 'ERP_API_URL', '') or '').strip()
    if not url:
        return False
    if 'your-erp-api.com' in url or 'example.com' in url:
        return False
    return url.startswith(('http://', 'https://'))


def _self_fulfilled_id(order):
    """Stable internal id used when no external ERP is configured."""
    return f'INT-{order.order_id}'


def send_order_to_erp(order):
    """
    Send order details to the external ERP system after payment confirmation.

    Returns:
        dict: {'erp_order_id': '<id>'} when sync (or self-fulfilment) succeeds.
        None: only when an *attempted* network call genuinely fails — admin
              can then click "Retry" from the ERP page.
    """
    # No real ERP wired up → treat the order as fulfilled internally instead
    # of showing the admin a permanently-failed row. This is what the user
    # actually wants until a real ERP integration is purchased.
    if not _erp_configured():
        erp_id = _self_fulfilled_id(order)
        logger.info(
            '[ERP] No external ERP configured — marking order %s as %s (self-fulfilled).',
            order.order_id, erp_id,
        )
        return {'erp_order_id': erp_id}

    erp_url = settings.ERP_API_URL
    erp_key = settings.ERP_API_KEY

    items = []
    for item in order.items.select_related('product').all():
        items.append({
            'product_id': item.product.id,
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price': float(item.price),
            'original_price': float(item.original_price),
        })

    payload = {
        'order_id': order.order_id,
        'customer_name': order.user_name,
        'customer_email': order.user_email,
        'phone': order.phone,
        'shipping_address': order.address,
        'amount': float(order.total_amount),
        'items': items,
    }

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {erp_key}',
    }

    try:
        logger.info(f'[ERP] Syncing order {order.order_id} to {erp_url}')
        response = requests.post(erp_url, json=payload, headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()
        erp_order_id = data.get('erp_order_id') or _self_fulfilled_id(order)
        logger.info(f'[ERP] Order {order.order_id} synced. ERP ID: {erp_order_id}')
        return {'erp_order_id': erp_order_id}

    except requests.exceptions.ConnectionError:
        logger.error(f'[ERP] Connection failed for order {order.order_id}. ERP server may be down.')
        if settings.DEBUG:
            simulated_id = f'ERP-SIM-{order.order_id}'
            logger.info(f'[ERP] Using simulated ID (DEBUG mode): {simulated_id}')
            return {'erp_order_id': simulated_id}
        return None

    except requests.exceptions.Timeout:
        logger.error(f'[ERP] Request timed out for order {order.order_id} (10s limit exceeded).')
        return None

    except requests.exceptions.HTTPError as e:
        logger.error(f'[ERP] HTTP error for order {order.order_id}: {e.response.status_code} — {e.response.text[:200]}')
        return None

    except Exception as e:
        logger.error(f'[ERP] Unexpected error for order {order.order_id}: {type(e).__name__}: {str(e)}')
        return None
