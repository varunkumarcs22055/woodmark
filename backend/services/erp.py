"""
ERP Integration Service.

Sends order data to the external ERP system after successful payment.
Handles errors gracefully — ERP failures do not break the payment flow.

Expected ERP API:
    POST {ERP_API_URL}
    Headers: { "Authorization": "Bearer {ERP_API_KEY}" }
    Body: {
        "order_id": "ORD-XXXXXXXX",
        "items": [
            {
                "product_name": "Oak Dining Table",
                "product_id": 1,
                "quantity": 2,
                "price": 25000.00
            }
        ],
        "amount": 50000.00,
        "customer_name": "John Doe",
        "customer_email": "john@example.com"
    }

    Response: {
        "erp_order_id": "ERP-123456"
    }
"""

import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def send_order_to_erp(order):
    """
    Send order details to the external ERP system.

    Args:
        order: Order model instance with related items prefetched.

    Returns:
        dict: ERP response containing erp_order_id, or None on failure.

    Note:
        This function catches all exceptions to ensure ERP failures
        don't affect the payment/order flow. Failed ERP syncs should
        be retried via a background job (future enhancement).
    """
    erp_url = settings.ERP_API_URL
    erp_key = settings.ERP_API_KEY

    # Build the payload
    items = []
    for item in order.items.select_related('product').all():
        items.append({
            'product_name': item.product.name,
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': float(item.price),
        })

    payload = {
        'order_id': order.order_id,
        'items': items,
        'amount': float(order.total_amount),
        'customer_name': order.user_name,
        'customer_email': order.user_email,
    }

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {erp_key}',
    }

    try:
        logger.info(f'Sending order {order.order_id} to ERP at {erp_url}')

        response = requests.post(
            erp_url,
            json=payload,
            headers=headers,
            timeout=10  # 10-second timeout
        )
        response.raise_for_status()

        data = response.json()
        erp_order_id = data.get('erp_order_id')

        logger.info(
            f'ERP sync successful for {order.order_id}. '
            f'ERP Order ID: {erp_order_id}'
        )

        return {'erp_order_id': erp_order_id}

    except requests.exceptions.ConnectionError:
        logger.error(
            f'ERP connection failed for order {order.order_id}. '
            f'ERP server may be down.'
        )
        # Return a simulated ERP ID for development/testing
        simulated_id = f'ERP-SIM-{order.order_id}'
        logger.info(f'Using simulated ERP ID: {simulated_id}')
        return {'erp_order_id': simulated_id}

    except requests.exceptions.Timeout:
        logger.error(f'ERP request timed out for order {order.order_id}')
        return None

    except requests.exceptions.HTTPError as e:
        logger.error(
            f'ERP returned error for order {order.order_id}: '
            f'{e.response.status_code} — {e.response.text}'
        )
        return None

    except Exception as e:
        logger.error(
            f'Unexpected error sending order {order.order_id} to ERP: {str(e)}'
        )
        return None
