import hashlib
import hmac
import json
import logging

import razorpay
from django.conf import settings
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny

from orders.models import Order
from users.permissions import IsAdminRole
from services.erp import send_order_to_erp
from .models import Payment
from .serializers import PaymentSerializer

logger = logging.getLogger(__name__)


def get_razorpay_client():
    return razorpay.Client(
        auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
    )


def confirm_order_and_sync_erp(order, razorpay_order_id=None, razorpay_payment_id=None, razorpay_signature=None):
    """
    Mark order as paid, create/update Payment record, and sync to ERP.
    Can be called from both PaymentVerifyView and the webhook.
    Returns the Payment instance.
    """
    payment, _ = Payment.objects.get_or_create(
        order=order,
        defaults={'amount': order.total_amount}
    )
    payment.status = 'SUCCESS'
    payment.amount = order.total_amount
    if razorpay_order_id:
        payment.razorpay_order_id = razorpay_order_id
    if razorpay_payment_id:
        payment.razorpay_payment_id = razorpay_payment_id
    if razorpay_signature:
        payment.razorpay_signature = razorpay_signature
    payment.save()

    order.payment_status = 'SUCCESS'
    order.order_status = 'CONFIRMED'
    order.save(update_fields=['payment_status', 'order_status'])

    order_with_items = Order.objects.prefetch_related('items__product').get(pk=order.pk)
    erp_result = send_order_to_erp(order_with_items)
    if erp_result and erp_result.get('erp_order_id'):
        order.erp_order_id = erp_result['erp_order_id']
        order.erp_sync_status = 'synced'
    else:
        order.erp_sync_status = 'failed'
        logger.warning(f'ERP sync failed for order {order.order_id}')
    order.save(update_fields=['erp_order_id', 'erp_sync_status'])

    try:
        from discounts.services import apply_discounts_to_order
        user_role = getattr(order.user, 'role', 'user') if order.user else 'user'
        apply_discounts_to_order(order_with_items, user_role)
    except Exception as e:
        logger.error(f'Failed to update discount units_sold for order {order.order_id}: {e}')

    # Mirror dealer payments into the DealerPayment ledger so the dealer's
    # "Recent Payments" panel shows gateway-confirmed payments (Razorpay /
    # simulated success), not only admin-recorded credit reconciliations.
    _record_dealer_payment_for_order(order, method='razorpay',
                                     reference=razorpay_payment_id or '')

    return payment


def _record_dealer_payment_for_order(order, *, method, reference=''):
    """
    Best-effort ledger write for dealer-attributed orders. Idempotent: a
    DealerPayment row keyed on the order's invoice (or reference fallback)
    is only created once per order.
    """
    user = getattr(order, 'user', None)
    if not user or getattr(user, 'role', None) != 'dealer':
        return
    try:
        from dealer_credit.models import DealerPayment
        invoice = getattr(order, 'invoice', None)
        # Dedupe — don't double-write if a payment row already exists for
        # this invoice or this order_id reference.
        ref = reference or order.order_id
        already = DealerPayment.objects.filter(
            dealer=user, reference=ref,
        ).exists()
        if already:
            return
        DealerPayment.objects.create(
            dealer=user,
            invoice=invoice if invoice is not None else None,
            amount=order.total_amount,
            method=method if method in dict(DealerPayment.METHOD_CHOICES) else 'razorpay',
            reference=ref,
            note=f'Auto-recorded from order {order.order_id} ({method})',
            received_at=timezone.now(),
        )
    except Exception:
        logger.exception(
            'Failed to mirror DealerPayment for order %s', order.order_id,
        )


class CreateRazorpayOrderView(APIView):
    """POST /api/payment/create-razorpay-order/"""
    permission_classes = [AllowAny]

    def post(self, request):
        order_id = request.data.get('order_id')
        if not order_id:
            return Response({'error': 'order_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            order = Order.objects.get(order_id=order_id)
        except Order.DoesNotExist:
            return Response({'error': f'Order {order_id} not found.'}, status=status.HTTP_404_NOT_FOUND)

        if order.payment_status == 'SUCCESS':
            return Response({'error': 'Order is already paid.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            client = get_razorpay_client()
            razorpay_order = client.order.create({
                'amount': int(order.total_amount * 100),
                'currency': 'INR',
                'receipt': order.order_id,
                'notes': {
                    'furnishop_order_id': order.order_id,
                    'customer_email': order.user_email,
                },
            })
        except Exception as e:
            logger.error(f'Razorpay order creation failed for {order_id}: {e}')
            return Response(
                {'error': 'Payment gateway error. Please try again.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )

        return Response({
            'razorpay_order_id': razorpay_order['id'],
            'amount': razorpay_order['amount'],
            'currency': razorpay_order['currency'],
            'key_id': settings.RAZORPAY_KEY_ID,
            'order_id': order.order_id,
            'prefill': {
                'name': order.user_name,
                'email': order.user_email,
                'contact': order.phone,
            },
        })


class PaymentVerifyView(APIView):
    """POST /api/payment/verify/"""
    permission_classes = [AllowAny]

    def post(self, request):
        order_id = request.data.get('order_id')
        razorpay_order_id = request.data.get('razorpay_order_id')
        razorpay_payment_id = request.data.get('razorpay_payment_id')
        razorpay_signature = request.data.get('razorpay_signature')

        if not all([order_id, razorpay_order_id, razorpay_payment_id, razorpay_signature]):
            return Response({'error': 'All payment fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            order = Order.objects.get(order_id=order_id)
        except Order.DoesNotExist:
            return Response({'error': f'Order {order_id} not found.'}, status=status.HTTP_404_NOT_FOUND)

        if order.payment_status == 'SUCCESS':
            return Response({'error': 'Order is already paid.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            client = get_razorpay_client()
            client.utility.verify_payment_signature({
                'razorpay_order_id': razorpay_order_id,
                'razorpay_payment_id': razorpay_payment_id,
                'razorpay_signature': razorpay_signature,
            })
        except razorpay.errors.SignatureVerificationError:
            logger.warning(f'Razorpay signature verification failed for order {order_id}')
            order.payment_status = 'FAILED'
            order.save(update_fields=['payment_status'])
            return Response({'error': 'Payment verification failed. Invalid signature.'}, status=status.HTTP_400_BAD_REQUEST)

        payment = confirm_order_and_sync_erp(
            order, razorpay_order_id, razorpay_payment_id, razorpay_signature
        )

        return Response({
            'message': 'Payment verified successfully.',
            'order_id': order.order_id,
            'erp_order_id': order.erp_order_id,
            'payment': PaymentSerializer(payment).data,
        })


@method_decorator(csrf_exempt, name='dispatch')
class RazorpayWebhookView(APIView):
    """POST /api/payment/webhook/"""
    permission_classes = [AllowAny]

    def post(self, request):
        webhook_signature = request.META.get('HTTP_X_RAZORPAY_SIGNATURE', '')
        webhook_secret = settings.RAZORPAY_WEBHOOK_SECRET

        if not webhook_secret:
            logger.error('RAZORPAY_WEBHOOK_SECRET not configured. Skipping webhook.')
            return Response({'status': 'ignored'})

        expected = hmac.new(
            webhook_secret.encode('utf-8'),
            request.body,
            hashlib.sha256
        ).hexdigest()

        if not hmac.compare_digest(expected, webhook_signature):
            logger.warning('Razorpay webhook signature mismatch.')
            return Response({'error': 'Invalid signature'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            payload = json.loads(request.body)
            event = payload.get('event')

            if event != 'payment.captured':
                return Response({'status': f'event {event} ignored'})

            payment_data = payload['payload']['payment']['entity']
            razorpay_order_id = payment_data.get('order_id')

            if not razorpay_order_id:
                return Response({'status': 'no order_id in payload'})

            try:
                payment_record = Payment.objects.select_related('order').get(
                    razorpay_order_id=razorpay_order_id
                )
                order = payment_record.order
            except Payment.DoesNotExist:
                furnishop_order_id = payment_data.get('notes', {}).get('furnishop_order_id')
                if not furnishop_order_id:
                    return Response({'status': 'order not found'})
                try:
                    order = Order.objects.get(order_id=furnishop_order_id)
                except Order.DoesNotExist:
                    return Response({'status': 'order not found'})

            if order.payment_status == 'SUCCESS':
                return Response({'status': 'already processed'})

            confirm_order_and_sync_erp(
                order,
                razorpay_order_id=razorpay_order_id,
                razorpay_payment_id=payment_data.get('id'),
            )
            logger.info(f'Webhook processed successfully for order {order.order_id}')

        except Exception as e:
            logger.error(f'Webhook processing error: {type(e).__name__}: {e}')

        return Response({'status': 'ok'})


class PaymentSimulateView(APIView):
    """POST /api/payment/success/ — dev only"""
    permission_classes = [AllowAny]

    def post(self, request):
        if not settings.DEBUG:
            return Response({'error': 'This endpoint is only available in development.'}, status=status.HTTP_403_FORBIDDEN)

        order_id = request.data.get('order_id')
        if not order_id:
            return Response({'error': 'order_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            order = Order.objects.get(order_id=order_id)
        except Order.DoesNotExist:
            return Response({'error': f'Order {order_id} not found.'}, status=status.HTTP_404_NOT_FOUND)

        if order.payment_status == 'SUCCESS':
            return Response({'error': 'Order is already paid.'}, status=status.HTTP_400_BAD_REQUEST)

        payment = confirm_order_and_sync_erp(order)

        return Response({
            'message': 'Payment successful (simulated).',
            'order_id': order.order_id,
            'erp_order_id': order.erp_order_id,
            'payment': PaymentSerializer(payment).data,
        })


class ERPRetryView(APIView):
    """POST /api/orders/{id}/retry-erp/ — admin only"""
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        try:
            order = Order.objects.prefetch_related('items__product').get(pk=pk)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        if order.payment_status != 'SUCCESS':
            return Response({'error': 'Can only retry ERP sync for paid orders.'}, status=status.HTTP_400_BAD_REQUEST)

        erp_result = send_order_to_erp(order)
        if erp_result and erp_result.get('erp_order_id'):
            order.erp_order_id = erp_result['erp_order_id']
            order.erp_sync_status = 'synced'
            order.save(update_fields=['erp_order_id', 'erp_sync_status'])
            return Response({
                'message': 'ERP sync successful.',
                'erp_order_id': order.erp_order_id,
            })
        else:
            return Response(
                {'error': 'ERP sync failed. Check server logs for details.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
