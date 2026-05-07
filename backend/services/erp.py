"""
ERP Integration Service.

Contract (invariant — never break):
  send_order_to_erp() NEVER raises an exception to its caller.
  All errors are caught, logged, and handled internally.
  ERP failure never blocks payment confirmation.
"""
import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def send_order_to_erp(order):
    """
    Send order details to the external ERP system after payment confirmation.

    Args:
        order: Order instance with related items prefetched.

    Returns:
        dict: {'erp_order_id': '<id>'} on success
        dict: {'erp_order_id': 'ERP-SIM-<order_id>'} on ConnectionError (dev only)
        None: on Timeout or HTTPError
    """
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
        erp_order_id = data.get('erp_order_id')
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
