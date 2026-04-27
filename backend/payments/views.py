"""
Payments app — Views.

Handles payment simulation and future Razorpay integration.

CURRENT BEHAVIOR (Simulated):
    - POST /api/payment/success/ with order_id
    - Marks order as paid immediately
    - Triggers ERP integration

FUTURE BEHAVIOR (Razorpay):
    - Replace the dummy logic in PaymentSuccessView with Razorpay
      signature verification using razorpay.Client.utility.verify_payment_signature()
    - The rest of the flow (Payment model, ERP call) stays the same
"""

import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from orders.models import Order
from .models import Payment
from .serializers import PaymentSerializer
from services.erp import send_order_to_erp

logger = logging.getLogger(__name__)


class PaymentSuccessView(APIView):
    """
    POST /api/payment/success/

    Simulate payment success for an order.

    Request body:
    {
        "order_id": "ORD-XXXXXXXX"
    }

    What happens:
    1. Creates a Payment record with status=SUCCESS
    2. Updates Order.payment_status to SUCCESS
    3. Sends order data to ERP system
    4. Stores erp_order_id in Order model

    To integrate Razorpay later:
    - Add razorpay_order_id, razorpay_payment_id, razorpay_signature to request body
    - Verify signature before marking as success
    - Everything else remains unchanged
    """
    def post(self, request):
        order_id = request.data.get('order_id')

        if not order_id:
            return Response(
                {'error': 'order_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Find the order
        try:
            order = Order.objects.prefetch_related('items__product').get(
                order_id=order_id
            )
        except Order.DoesNotExist:
            return Response(
                {'error': f'Order {order_id} not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        # Check if already paid
        if order.payment_status == 'SUCCESS':
            return Response(
                {'error': 'Order is already paid'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ─── SIMULATED PAYMENT SUCCESS ───────────────────────────────
        # In the future, replace this section with Razorpay verification:
        #
        # razorpay_order_id = request.data.get('razorpay_order_id')
        # razorpay_payment_id = request.data.get('razorpay_payment_id')
        # razorpay_signature = request.data.get('razorpay_signature')
        #
        # client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))
        # client.utility.verify_payment_signature({
        #     'razorpay_order_id': razorpay_order_id,
        #     'razorpay_payment_id': razorpay_payment_id,
        #     'razorpay_signature': razorpay_signature,
        # })
        # ─────────────────────────────────────────────────────────────

        # Create payment record
        payment, created = Payment.objects.get_or_create(
            order=order,
            defaults={
                'status': 'SUCCESS',
                'amount': order.total_amount,
                # razorpay_order_id and razorpay_payment_id left null for now
            }
        )

        if not created:
            payment.status = 'SUCCESS'
            payment.save()

        # Update order payment status
        order.payment_status = 'SUCCESS'
        order.order_status = 'CONFIRMED'
        order.save()

        # ─── ERP INTEGRATION ────────────────────────────────────────
        # Send order to external ERP system
        erp_result = send_order_to_erp(order)
        if erp_result and erp_result.get('erp_order_id'):
            order.erp_order_id = erp_result['erp_order_id']
            order.save()
            logger.info(
                f'Order {order.order_id} synced to ERP: {order.erp_order_id}'
            )
        else:
            logger.warning(
                f'ERP sync failed for order {order.order_id}. '
                f'Will retry later.'
            )
        # ─────────────────────────────────────────────────────────────

        return Response({
            'message': 'Payment successful',
            'order_id': order.order_id,
            'payment': PaymentSerializer(payment).data,
            'erp_order_id': order.erp_order_id,
        })
