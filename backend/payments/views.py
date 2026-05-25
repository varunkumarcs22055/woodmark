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
from .notifications import send_order_confirmation_email, send_order_confirmation_sms
from .refunds import update_refund_from_webhook
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

    # Idempotent confirmation email + SMS — both fire on first verify or
    # webhook, whichever wins the race. Per-channel guards (email_sent_at /
    # sms_sent_at) ensure no double sends across retries.
    if not payment.email_sent_at and send_order_confirmation_email(order):
        payment.email_sent_at = timezone.now()
        payment.save(update_fields=['email_sent_at'])
    if not payment.sms_sent_at and send_order_confirmation_sms(order):
        payment.sms_sent_at = timezone.now()
        payment.save(update_fields=['sms_sent_at'])

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
            try:
                from .notifications import send_payment_failed_email
                send_payment_failed_email(order, reason='Signature mismatch')
            except Exception:
                logger.exception('payment-failed email error for %s', order_id)
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

            if event and event.startswith('refund.'):
                refund_data = payload.get('payload', {}).get('refund', {}).get('entity', {})
                update_refund_from_webhook(refund_data)
                return Response({'status': 'ok'})

            # Handle both successful captures and explicit failures. Refund
            # events are routed to update_refund_from_webhook elsewhere.
            if event not in ('payment.captured', 'payment.failed'):
                return Response({'status': f'event {event} ignored'})

            payment_data = payload['payload']['payment']['entity']
            razorpay_order_id = payment_data.get('order_id')

            if not razorpay_order_id:
                return Response({'status': 'no order_id in payload'})

            # payment.failed → flag the order + email the buyer so they
            # know to retry. Razorpay sends these when a card is declined,
            # OTP expires, etc. Without this hook the order would just sit
            # in their history with no explanation.
            if event == 'payment.failed':
                try:
                    pr = Payment.objects.select_related('order').get(
                        razorpay_order_id=razorpay_order_id,
                    )
                    o = pr.order
                except Payment.DoesNotExist:
                    fid = payment_data.get('notes', {}).get('furnishop_order_id')
                    o = Order.objects.filter(order_id=fid).first() if fid else None
                if o is not None and o.payment_status != 'SUCCESS':
                    o.payment_status = 'FAILED'
                    o.save(update_fields=['payment_status'])
                    try:
                        from .notifications import send_payment_failed_email
                        send_payment_failed_email(
                            o,
                            reason=payment_data.get('error_description', '') or '',
                        )
                    except Exception:
                        logger.exception('payment-failed email error for %s', o.order_id)
                return Response({'status': 'failure recorded'})

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
        # Allow in dev OR when ALLOW_DEV_LOGIN=true is set (Render staging).
        # Same gate the dev-login uses — if you're using fake auth you're
        # already accepting that the payment is also faked.
        import os
        allowed = (
            settings.DEBUG
            or os.getenv('ALLOW_DEV_LOGIN', '').lower() in ('1', 'true', 'yes')
        )
        if not allowed:
            return Response({'error': 'This endpoint is only available in development.'},
                            status=status.HTTP_403_FORBIDDEN)

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


class PaymentReconcileView(APIView):
    """
    POST /api/payment/reconcile/  body={order_id}

    Self-service payment reconciliation. Customer says "I paid but it's
    not showing." We hit Razorpay directly to see what THEY think happened
    and reconcile our DB:

      Razorpay says CAPTURED → mark our order SUCCESS, fire ERP sync
      Razorpay says AUTHORIZED → still SUCCESS (will auto-capture)
      Razorpay says FAILED → mark FAILED so the buyer can retry
      No payment on Razorpay's side → leave as-is, tell the buyer

    This covers the case where the verify endpoint never got called
    (browser crash, network blip after debit) OR the webhook failed.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        order_id = request.data.get('order_id')
        if not order_id:
            return Response({'error': 'order_id is required.'},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            order = Order.objects.get(order_id=order_id)
        except Order.DoesNotExist:
            return Response({'error': f'Order {order_id} not found.'},
                            status=status.HTTP_404_NOT_FOUND)

        # Already paid? Just tell the caller — idempotent.
        if order.payment_status == 'SUCCESS':
            return Response({
                'order_id': order.order_id,
                'payment_status': order.payment_status,
                'reconciled': False,
                'message': 'Order is already marked as paid.',
            })

        try:
            payment_row = order.payment
            rzp_order_id = payment_row.razorpay_order_id if payment_row else ''
        except Exception:
            rzp_order_id = ''

        if not rzp_order_id:
            return Response({
                'order_id': order.order_id,
                'payment_status': order.payment_status,
                'reconciled': False,
                'message': 'No Razorpay order linked yet. If you paid through '
                           'Razorpay and your bank shows the debit, please '
                           'share the Razorpay payment ID with support.',
            })

        # Ask Razorpay for the truth.
        try:
            client = get_razorpay_client()
            payments = client.order.payments(rzp_order_id)
        except Exception as exc:
            logger.exception('Razorpay reconcile failed for %s', order_id)
            return Response(
                {'error': 'Could not reach Razorpay right now. Try again in a minute.'},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        items = (payments or {}).get('items', [])
        captured = next((p for p in items if p.get('status') == 'captured'), None)
        authorized = next((p for p in items if p.get('status') == 'authorized'), None)
        winning = captured or authorized

        if winning:
            payment = confirm_order_and_sync_erp(
                order,
                razorpay_order_id=rzp_order_id,
                razorpay_payment_id=winning.get('id', ''),
                razorpay_signature='',  # webhook-style sync, signature N/A
            )
            # Buyer asked us to find their payment and we did — send them a
            # dedicated "we matched it" email so they have proof in their inbox
            # that we accepted responsibility for the gap.
            try:
                from .notifications import send_payment_reconciled_email
                send_payment_reconciled_email(order)
            except Exception:
                logger.exception('reconcile email error for %s', order_id)
            return Response({
                'order_id': order.order_id,
                'payment_status': 'SUCCESS',
                'reconciled': True,
                'razorpay_payment_id': winning.get('id'),
                'amount': winning.get('amount', 0) / 100,
                'erp_order_id': order.erp_order_id,
                'message': 'Payment confirmed via Razorpay. Your order is now active.',
                'payment': PaymentSerializer(payment).data,
            })

        # Razorpay knows the order but no successful payment recorded.
        any_failed = any(p.get('status') == 'failed' for p in items)
        if any_failed and order.payment_status != 'FAILED':
            order.payment_status = 'FAILED'
            order.save(update_fields=['payment_status'])

        return Response({
            'order_id': order.order_id,
            'payment_status': order.payment_status,
            'reconciled': False,
            'razorpay_payments_count': len(items),
            'message': (
                'Razorpay shows no successful payment for this order. If your '
                'bank confirms the debit, please contact support with the bank '
                'reference — refunds for un-captured payments are processed '
                'automatically by Razorpay within 5–7 business days.'
            ),
        })
