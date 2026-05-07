from unittest.mock import patch, MagicMock
from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product
from orders.models import Order, OrderItem
from payments.models import Payment
from users.models import User


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

    def test_simulate_payment_missing_order_id_returns_400(self):
        with self.settings(DEBUG=True):
            response = self.client.post('/api/payment/success/', {})
            self.assertEqual(response.status_code, 400)

    def test_simulate_payment_invalid_order_id_returns_404(self):
        with self.settings(DEBUG=True):
            response = self.client.post('/api/payment/success/', {'order_id': 'ORD-NOTREAL'})
            self.assertEqual(response.status_code, 404)

    def test_simulate_creates_payment_record(self):
        with self.settings(DEBUG=True):
            self.client.post('/api/payment/success/', {'order_id': self.order.order_id})
            self.assertTrue(Payment.objects.filter(order=self.order, status='SUCCESS').exists())

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
        self.assertIn('prefill', response.data)

    def test_create_razorpay_order_missing_order_id_returns_400(self):
        response = self.client.post('/api/payment/create-razorpay-order/', {})
        self.assertEqual(response.status_code, 400)

    def test_create_razorpay_order_invalid_order_returns_404(self):
        response = self.client.post('/api/payment/create-razorpay-order/', {'order_id': 'ORD-NOTREAL'})
        self.assertEqual(response.status_code, 404)

    def test_create_razorpay_order_already_paid_returns_400(self):
        self.order.payment_status = 'SUCCESS'
        self.order.save()
        response = self.client.post('/api/payment/create-razorpay-order/', {'order_id': self.order.order_id})
        self.assertEqual(response.status_code, 400)


class PaymentVerifyViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.order = make_order()

    def test_verify_missing_fields_returns_400(self):
        response = self.client.post('/api/payment/verify/', {'order_id': self.order.order_id}, format='json')
        self.assertEqual(response.status_code, 400)

    @patch('payments.views.get_razorpay_client')
    def test_verify_invalid_signature_returns_400(self, mock_client):
        import razorpay.errors
        mock_rzp = MagicMock()
        mock_rzp.utility.verify_payment_signature.side_effect = razorpay.errors.SignatureVerificationError(
            'bad sig', 'verify_payment_signature'
        )
        mock_client.return_value = mock_rzp

        response = self.client.post('/api/payment/verify/', {
            'order_id': self.order.order_id,
            'razorpay_order_id': 'order_xxx',
            'razorpay_payment_id': 'pay_xxx',
            'razorpay_signature': 'bad_sig',
        }, format='json')
        self.assertEqual(response.status_code, 400)
        self.order.refresh_from_db()
        self.assertEqual(self.order.payment_status, 'FAILED')

    @patch('payments.views.get_razorpay_client')
    def test_verify_valid_signature_confirms_order(self, mock_client):
        mock_rzp = MagicMock()
        mock_rzp.utility.verify_payment_signature.return_value = None
        mock_client.return_value = mock_rzp

        response = self.client.post('/api/payment/verify/', {
            'order_id': self.order.order_id,
            'razorpay_order_id': 'order_xxx',
            'razorpay_payment_id': 'pay_xxx',
            'razorpay_signature': 'valid_sig',
        }, format='json')
        self.assertEqual(response.status_code, 200)
        self.order.refresh_from_db()
        self.assertEqual(self.order.payment_status, 'SUCCESS')
        self.assertEqual(self.order.order_status, 'CONFIRMED')


class ERPRetryViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.admin = User.objects.create_user(
            email='admin@test.com', username='admin@test.com',
            password='pass', role='admin'
        )
        self.user = User.objects.create_user(
            email='user@test.com', username='user@test.com',
            password='pass', role='user'
        )
        self.order = make_order()

    def _auth(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        token = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {str(token.access_token)}')

    def test_non_admin_cannot_retry_erp(self):
        self._auth(self.user)
        response = self.client.post(f'/api/orders/{self.order.pk}/retry-erp/')
        self.assertEqual(response.status_code, 403)

    def test_admin_retry_erp_unpaid_order_returns_400(self):
        self._auth(self.admin)
        response = self.client.post(f'/api/orders/{self.order.pk}/retry-erp/')
        self.assertEqual(response.status_code, 400)

    def test_admin_retry_erp_missing_order_returns_404(self):
        self._auth(self.admin)
        response = self.client.post('/api/orders/99999/retry-erp/')
        self.assertEqual(response.status_code, 404)

    def test_admin_retry_erp_paid_order_success(self):
        self.order.payment_status = 'SUCCESS'
        self.order.save()
        self._auth(self.admin)
        response = self.client.post(f'/api/orders/{self.order.pk}/retry-erp/')
        self.assertIn(response.status_code, [200, 503])
