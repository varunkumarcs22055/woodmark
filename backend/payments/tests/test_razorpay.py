import hashlib
import hmac
import json
from unittest.mock import patch, MagicMock
from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product
from orders.models import Order, OrderItem
from payments.models import Payment


def make_paid_order():
    cat = Category.objects.create(name='Razorpay Cat', slug='razorpay-cat')
    product = Product.objects.create(
        name='RZ Product', price='5000.00',
        category=cat, material='metal', color='Silver',
        dimensions='50x50', image_url='https://test.com/img.jpg', stock=10
    )
    order = Order.objects.create(
        user_name='RZ User', user_email='rz@test.com',
        phone='8888888888', address='RZ Address', total_amount='5000.00',
        payment_status='SUCCESS', order_status='CONFIRMED'
    )
    OrderItem.objects.create(
        order=order, product=product, quantity=1,
        price='5000.00', original_price='5000.00'
    )
    Payment.objects.create(
        order=order, amount='5000.00', status='SUCCESS',
        razorpay_order_id='order_existing123',
    )
    return order


class RazorpayWebhookTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.webhook_secret = 'test_webhook_secret'

    def _sign(self, body_bytes):
        return hmac.new(
            self.webhook_secret.encode('utf-8'),
            body_bytes,
            hashlib.sha256
        ).hexdigest()

    def _make_unpaid_order(self):
        cat = Category.objects.create(name='WH Cat', slug='wh-cat')
        product = Product.objects.create(
            name='WH Product', price='3000.00',
            category=cat, material='wood', color='Oak',
            dimensions='80x40', image_url='https://test.com/img.jpg', stock=5
        )
        order = Order.objects.create(
            user_name='WH User', user_email='wh@test.com',
            phone='7777777777', address='WH Address', total_amount='3000.00'
        )
        OrderItem.objects.create(
            order=order, product=product, quantity=1,
            price='3000.00', original_price='3000.00'
        )
        return order

    def test_webhook_invalid_signature_returns_400(self):
        with self.settings(RAZORPAY_WEBHOOK_SECRET=self.webhook_secret):
            payload = json.dumps({'event': 'payment.captured'}).encode()
            response = self.client.post(
                '/api/payment/webhook/',
                data=payload,
                content_type='application/json',
                HTTP_X_RAZORPAY_SIGNATURE='invalidsig',
            )
            self.assertEqual(response.status_code, 400)

    def test_webhook_no_secret_configured_returns_ignored(self):
        with self.settings(RAZORPAY_WEBHOOK_SECRET=''):
            payload = json.dumps({'event': 'payment.captured'}).encode()
            response = self.client.post(
                '/api/payment/webhook/',
                data=payload,
                content_type='application/json',
                HTTP_X_RAZORPAY_SIGNATURE='anysig',
            )
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data['status'], 'ignored')

    def test_webhook_non_captured_event_is_ignored(self):
        with self.settings(RAZORPAY_WEBHOOK_SECRET=self.webhook_secret):
            payload = json.dumps({'event': 'order.paid'}).encode()
            sig = self._sign(payload)
            response = self.client.post(
                '/api/payment/webhook/',
                data=payload,
                content_type='application/json',
                HTTP_X_RAZORPAY_SIGNATURE=sig,
            )
            self.assertEqual(response.status_code, 200)
            self.assertIn('ignored', response.data['status'])

    def test_webhook_already_paid_order_returns_already_processed(self):
        order = make_paid_order()
        with self.settings(RAZORPAY_WEBHOOK_SECRET=self.webhook_secret):
            payload = json.dumps({
                'event': 'payment.captured',
                'payload': {
                    'payment': {
                        'entity': {
                            'id': 'pay_new123',
                            'order_id': 'order_existing123',
                        }
                    }
                }
            }).encode()
            sig = self._sign(payload)
            response = self.client.post(
                '/api/payment/webhook/',
                data=payload,
                content_type='application/json',
                HTTP_X_RAZORPAY_SIGNATURE=sig,
            )
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data['status'], 'already processed')

    def test_webhook_valid_signature_processes_payment(self):
        order = self._make_unpaid_order()
        Payment.objects.create(
            order=order, amount='3000.00', status='PENDING',
            razorpay_order_id='order_newwh123',
        )
        with self.settings(RAZORPAY_WEBHOOK_SECRET=self.webhook_secret):
            payload = json.dumps({
                'event': 'payment.captured',
                'payload': {
                    'payment': {
                        'entity': {
                            'id': 'pay_wh123',
                            'order_id': 'order_newwh123',
                        }
                    }
                }
            }).encode()
            sig = self._sign(payload)
            response = self.client.post(
                '/api/payment/webhook/',
                data=payload,
                content_type='application/json',
                HTTP_X_RAZORPAY_SIGNATURE=sig,
            )
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data['status'], 'ok')
            order.refresh_from_db()
            self.assertEqual(order.payment_status, 'SUCCESS')
