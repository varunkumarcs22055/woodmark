import logging
import uuid
from decimal import Decimal

import razorpay
from django.conf import settings

from orders.models import Refund

logger = logging.getLogger(__name__)


def _razorpay_client():
    return razorpay.Client(
        auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
    )


def create_refund(*, order, amount, return_request=None, reason=''):
    """
    Create a refund record. Uses Razorpay if credentials + payment id exist,
    else simulates (dev) or marks manual.
    """
    amount = Decimal(str(amount))
    if amount <= 0:
        raise ValueError('Refund amount must be positive.')

    existing = Refund.objects.filter(
        order=order,
        return_request=return_request,
        amount=amount,
        status__in=('pending', 'success'),
    ).first()
    if existing:
        return existing

    payment = getattr(order, 'payment', None)
    has_gateway = bool(
        settings.RAZORPAY_KEY_ID
        and settings.RAZORPAY_KEY_SECRET
        and payment is not None
        and payment.razorpay_payment_id
    )

    gateway = 'manual'
    status = 'pending'
    gateway_refund_id = ''
    payload = {}
    note = (reason or '').strip()

    if has_gateway:
        gateway = 'razorpay'
        try:
            client = _razorpay_client()
            rp_refund = client.payment.refund(
                payment.razorpay_payment_id,
                {
                    'amount': int(amount * 100),
                    'notes': {
                        'order_id': order.order_id,
                        'reason': note[:100],
                    },
                },
            )
            gateway_refund_id = rp_refund.get('id', '')
            payload = rp_refund
            status = 'success' if rp_refund.get('status') in ('processed', 'success') else 'pending'
        except Exception as exc:
            logger.error('Razorpay refund failed for %s: %s', order.order_id, exc)
            status = 'failed'
            payload = {'error': str(exc)}
    else:
        # Simulated refund path (dev / missing credentials).
        gateway = 'razorpay' if payment and payment.razorpay_payment_id else 'manual'
        gateway_refund_id = f'sim_refund_{uuid.uuid4().hex[:12]}'
        status = 'success'
        payload = {
            'simulated': True,
            'amount': str(amount),
            'reason': note,
        }

    refund = Refund.objects.create(
        order=order,
        return_request=return_request,
        amount=amount,
        gateway=gateway,
        gateway_refund_id=gateway_refund_id,
        gateway_payload=payload,
        status=status,
        note=note,
    )
    return refund


def update_refund_from_webhook(refund_data):
    """Update refund status from Razorpay webhook payload."""
    refund_id = refund_data.get('id')
    if not refund_id:
        return None
    try:
        refund = Refund.objects.get(gateway_refund_id=refund_id)
    except Refund.DoesNotExist:
        return None

    status_map = {
        'processed': 'success',
        'success': 'success',
        'failed': 'failed',
    }
    new_status = status_map.get(refund_data.get('status'), refund.status)
    refund.status = new_status
    refund.gateway_payload = refund_data
    refund.save(update_fields=['status', 'gateway_payload'])
    if new_status == 'success' and refund.return_request and refund.return_request.status != 'refunded':
        refund.return_request.status = 'refunded'
        refund.return_request.save(update_fields=['status', 'updated_at'])
    return refund
