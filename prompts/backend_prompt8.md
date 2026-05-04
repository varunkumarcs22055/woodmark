# Backend Prompt 8 — Payments (Razorpay), ERP Integration & Admin Endpoints

## Role
You are a senior backend engineer. Implement the complete Razorpay payment gateway integration, webhook verification, ERP order sync, and admin-only endpoints for ERP retry and order management.

---

## Context
This is the final backend prompt. After an order is created (Prompt 7), it must be paid via Razorpay. The payment flow has three server-side steps: (1) create Razorpay order, (2) verify signature after frontend completes payment, (3) handle webhook as a fallback. After payment confirmation, orders are synced to the external ERP system.

**Depends on:** Backend Prompts 1–7
**Required by:** Frontend Prompt 6 (Razorpay checkout)

---

## Files to Create/Modify

```
backend/payments/
├── models.py
├── serializers.py
├── views.py
├── urls.py
├── admin.py
└── tests/
    ├── __init__.py
    ├── test_views.py
    └── test_razorpay.py

backend/services/
└── erp.py              ← Full implementation (not a stub)
```

---

## Payment Model — `payments/models.py`

```python
from django.db import models
from orders.models import Order


class Payment(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
    ]

    order = models.OneToOneField(Order, on_delete=models.CASCADE, related_name='payment')
    razorpay_order_id = models.CharField(max_length=100, blank=True, null=True)
    razorpay_payment_id = models.CharField(max_length=100, blank=True, null=True)
    razorpay_signature = models.CharField(max_length=256, blank=True, null=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='PENDING')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    failure_reason = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'payments'

    def __str__(self):
        return f'Payment for {self.order.order_id} — {self.status}'
```

---

## ERP Service — `services/erp.py` (Full Implementation)

```python
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
```

---

## Payment Views — `payments/views.py`

```python
import hashlib
import hmac
import json
import logging

import razorpay
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated

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
    # Create or update Payment record
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

    # Update order status
    order.payment_status = 'SUCCESS'
    order.order_status = 'CONFIRMED'
    order.save(update_fields=['payment_status', 'order_status'])

    # Sync to ERP
    order_with_items = Order.objects.prefetch_related('items__product').get(pk=order.pk)
    erp_result = send_order_to_erp(order_with_items)
    if erp_result and erp_result.get('erp_order_id'):
        order.erp_order_id = erp_result['erp_order_id']
        order.erp_sync_status = 'synced'
    else:
        order.erp_sync_status = 'failed'
        logger.warning(f'ERP sync failed for order {order.order_id}')
    order.save(update_fields=['erp_order_id', 'erp_sync_status'])

    # Increment discount units_sold
    try:
        from discounts.services import apply_discounts_to_order
        user_role = getattr(order.user, 'role', 'user') if order.user else 'user'
        apply_discounts_to_order(order_with_items, user_role)
    except Exception as e:
        logger.error(f'Failed to update discount units_sold for order {order.order_id}: {e}')

    return payment


class CreateRazorpayOrderView(APIView):
    """
    POST /api/payment/create-razorpay-order/
    Body: {"order_id": "ORD-XXXXXXXX"}
    Creates a Razorpay order and returns the order details for the frontend modal.
    """
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
                'amount': int(order.total_amount * 100),  # Razorpay expects paise
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
    """
    POST /api/payment/verify/
    Body: {
      "order_id": "ORD-XXXXXXXX",
      "razorpay_order_id": "order_xxx",
      "razorpay_payment_id": "pay_xxx",
      "razorpay_signature": "<hmac-sha256-hex>"
    }
    Verifies Razorpay signature and confirms the order.
    """
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

        # Verify Razorpay signature
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
    """
    POST /api/payment/webhook/
    Razorpay webhook receiver for 'payment.captured' events.
    Verifies the webhook signature via X-Razorpay-Signature header.
    This is the fallback for cases where the frontend callback fails.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        webhook_signature = request.META.get('HTTP_X_RAZORPAY_SIGNATURE', '')
        webhook_secret = settings.RAZORPAY_WEBHOOK_SECRET

        if not webhook_secret:
            logger.error('RAZORPAY_WEBHOOK_SECRET not configured. Skipping webhook.')
            return Response({'status': 'ignored'})

        # Verify webhook signature
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

            # Find the Payment record by razorpay_order_id
            try:
                payment_record = Payment.objects.select_related('order').get(
                    razorpay_order_id=razorpay_order_id
                )
                order = payment_record.order
            except Payment.DoesNotExist:
                # Try to find order via notes
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
    """
    POST /api/payment/success/
    DEVELOPMENT ONLY — simulates payment without Razorpay.
    This endpoint should be disabled in production (guarded by DEBUG check).
    """
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
    """
    POST /api/orders/{id}/retry-erp/
    Admin-only: retry ERP sync for a failed order.
    """
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
```

---

## Payment Serializer — `payments/serializers.py`

```python
from rest_framework import serializers
from .models import Payment


class PaymentSerializer(serializers.ModelSerializer):
    order_id = serializers.CharField(source='order.order_id', read_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'order_id', 'razorpay_order_id', 'razorpay_payment_id',
            'status', 'amount', 'created_at'
        ]
```

---

## Payment URLs — `payments/urls.py`

```python
from django.urls import path
from . import views

urlpatterns = [
    path('create-razorpay-order/', views.CreateRazorpayOrderView.as_view(), name='create-razorpay-order'),
    path('verify/', views.PaymentVerifyView.as_view(), name='payment-verify'),
    path('webhook/', views.RazorpayWebhookView.as_view(), name='razorpay-webhook'),
    path('success/', views.PaymentSimulateView.as_view(), name='payment-simulate'),
]
```

**Also add ERP retry URL to `orders/urls.py`:**
```python
from payments.views import ERPRetryView
path('<int:pk>/retry-erp/', ERPRetryView.as_view(), name='order-retry-erp'),
```

---

## Payment Admin — `payments/admin.py`

```python
from django.contrib import admin
from .models import Payment


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ('order', 'status', 'amount_display', 'razorpay_payment_id', 'created_at')
    list_filter = ('status',)
    search_fields = ('order__order_id', 'razorpay_payment_id', 'order__user_email')
    readonly_fields = ('order', 'razorpay_order_id', 'razorpay_payment_id', 'razorpay_signature', 'created_at', 'updated_at')

    def amount_display(self, obj):
        return f'₹{obj.amount:,.2f}'
    amount_display.short_description = 'Amount'
```

---

## Razorpay Test Mode Setup

```
# For development testing:
1. Sign up at https://dashboard.razorpay.com
2. Go to Settings → API Keys → Test Mode
3. Copy Key ID and Key Secret → set in .env:
   RAZORPAY_KEY_ID=rzp_test_XXXXXXXXXX
   RAZORPAY_KEY_SECRET=your-test-secret
4. Use test card: 4111 1111 1111 1111, any future expiry, any CVV
5. For webhook testing locally: use ngrok (https://ngrok.com)
   ngrok http 8000
   Use the HTTPS ngrok URL in Razorpay webhook settings
```

---

## Tests — `payments/tests/test_views.py`

```python
from unittest.mock import patch, MagicMock
from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product
from orders.models import Order, OrderItem
from payments.models import Payment


def make_order():
    cat = Category.objects.create(name='Test Cat', slug='test-cat')
    product = Product.objects.create(
        name='Test Product', price='10000.00',
        category=cat, material='wood', color='Brown',
        dimensions='100x50', image_url='https://test.com/img.jpg', stock=10
    )
    order = Order.objects.create(
        user_name='Test', user_email='test@test.com',
        phone='9999999999', address='Test Address', total_amount='10000.00'
    )
    OrderItem.objects.create(
        order=order, product=product, quantity=1,
        price='10000.00', original_price='10000.00'
    )
    return order


class PaymentSimulateViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.order = make_order()

    def test_simulate_payment_success(self):
        with self.settings(DEBUG=True):
            response = self.client.post('/api/payment/success/', {'order_id': self.order.order_id})
            self.assertEqual(response.status_code, 200)
            self.order.refresh_from_db()
            self.assertEqual(self.order.payment_status, 'SUCCESS')
            self.assertEqual(self.order.order_status, 'CONFIRMED')

    def test_simulate_payment_not_available_in_production(self):
        with self.settings(DEBUG=False):
            response = self.client.post('/api/payment/success/', {'order_id': self.order.order_id})
            self.assertEqual(response.status_code, 403)

    def test_simulate_payment_already_paid_returns_400(self):
        with self.settings(DEBUG=True):
            self.client.post('/api/payment/success/', {'order_id': self.order.order_id})
            response = self.client.post('/api/payment/success/', {'order_id': self.order.order_id})
            self.assertEqual(response.status_code, 400)

    @patch('payments.views.get_razorpay_client')
    def test_create_razorpay_order_returns_required_fields(self, mock_client):
        mock_rzp = MagicMock()
        mock_rzp.order.create.return_value = {
            'id': 'order_test123',
            'amount': 1000000,
            'currency': 'INR',
        }
        mock_client.return_value = mock_rzp

        response = self.client.post(
            '/api/payment/create-razorpay-order/',
            {'order_id': self.order.order_id}
        )
        self.assertEqual(response.status_code, 200)
        self.assertIn('razorpay_order_id', response.data)
        self.assertIn('key_id', response.data)
        self.assertIn('amount', response.data)
```

---

## Acceptance Criteria

- [ ] `POST /api/payment/success/` (with `DEBUG=True`) confirms order and returns `erp_order_id`
- [ ] `POST /api/payment/success/` with `DEBUG=False` returns `403`
- [ ] `POST /api/payment/create-razorpay-order/` creates a Razorpay order (requires test API keys)
- [ ] `POST /api/payment/verify/` with valid Razorpay signature confirms order
- [ ] `POST /api/payment/verify/` with invalid signature returns `400`
- [ ] `POST /api/payment/webhook/` with valid `X-Razorpay-Signature` header processes event
- [ ] `POST /api/payment/webhook/` with invalid signature returns `400`
- [ ] Order `payment_status` becomes `SUCCESS` and `order_status` becomes `CONFIRMED` after payment
- [ ] `erp_sync_status` is set to `synced` on successful ERP sync or `failed` on ERP error
- [ ] Admin can retry ERP sync via `POST /api/orders/{id}/retry-erp/`
- [ ] Non-admin gets `403` on ERP retry endpoint
- [ ] ERP failure (connection error, timeout) does NOT fail the payment response
- [ ] All tests pass: `python manage.py test payments`
