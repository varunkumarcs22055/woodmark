from decimal import Decimal
from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product
from users.models import User
from orders.models import Order


class OrderCreateViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=20
        )
        self.admin = User.objects.create_user(
            email='admin@test.com', username='admin@test.com',
            password='pass', role='admin'
        )
        self.user = User.objects.create_user(
            email='user@test.com', username='user@test.com',
            password='pass', role='user'
        )

    def _auth(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        token = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {str(token.access_token)}')

    def _payload(self, qty=1):
        return {
            'user_name': 'Test User',
            'user_email': 'test@test.com',
            'phone': '9876543210',
            'address': '123 Test St',
            'items': [{'product_id': self.product.pk, 'quantity': qty}],
        }

    def test_guest_can_create_order(self):
        response = self.client.post('/api/orders/create/', self._payload(), format='json')
        self.assertEqual(response.status_code, 201)
        self.assertTrue(response.data['order_id'].startswith('ORD-'))
        self.assertIsNone(response.data.get('user'))

    def test_order_id_format(self):
        response = self.client.post('/api/orders/create/', self._payload(), format='json')
        self.assertRegex(response.data['order_id'], r'^ORD-[A-F0-9]{8}$')

    def test_stock_decremented_after_order(self):
        self.client.post('/api/orders/create/', self._payload(3), format='json')
        self.product.refresh_from_db()
        self.assertEqual(self.product.stock, 17)

    def test_insufficient_stock_returns_400(self):
        response = self.client.post('/api/orders/create/', self._payload(99), format='json')
        self.assertEqual(response.status_code, 400)
        self.assertIn('items', response.data)

    def test_authenticated_user_linked_to_order(self):
        self._auth(self.user)
        response = self.client.post('/api/orders/create/', self._payload(), format='json')
        self.assertEqual(response.status_code, 201)
        order = Order.objects.get(order_id=response.data['order_id'])
        self.assertEqual(order.user, self.user)

    def test_missing_required_fields_returns_400(self):
        response = self.client.post('/api/orders/create/', {'user_name': 'X'}, format='json')
        self.assertEqual(response.status_code, 400)


class OrderListViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=50
        )
        self.user = User.objects.create_user(
            email='user@test.com', username='user@test.com',
            password='pass', role='user'
        )

    def _auth(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        token = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {str(token.access_token)}')

    def _create_order(self, email='test@test.com'):
        return self.client.post('/api/orders/create/', {
            'user_name': 'Test', 'user_email': email,
            'phone': '9876543210', 'address': 'Addr',
            'items': [{'product_id': self.product.pk, 'quantity': 1}],
        }, format='json')

    def test_guest_lookup_by_email(self):
        self._create_order('guest@test.com')
        response = self.client.get('/api/orders/?email=guest@test.com')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)

    def test_guest_without_email_returns_400(self):
        response = self.client.get('/api/orders/')
        self.assertEqual(response.status_code, 400)

    def test_authenticated_user_sees_their_orders(self):
        self._auth(self.user)
        self._create_order('user@test.com')
        response = self.client.get('/api/orders/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)

    def test_authenticated_user_does_not_see_others_orders(self):
        self._create_order('other@test.com')
        self._auth(self.user)
        response = self.client.get('/api/orders/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 0)


class OrderAdminViewTest(TestCase):
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
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=50
        )
        self.order = Order.objects.create(
            user_name='Test', user_email='test@test.com',
            phone='9876543210', address='Addr',
            total_amount='10000.00'
        )

    def _auth(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        token = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {str(token.access_token)}')

    def test_admin_can_list_all_orders(self):
        self._auth(self.admin)
        response = self.client.get('/api/orders/all/')
        self.assertEqual(response.status_code, 200)

    def test_non_admin_cannot_list_all_orders(self):
        self._auth(self.user)
        response = self.client.get('/api/orders/all/')
        self.assertEqual(response.status_code, 403)

    def test_admin_can_update_order_status(self):
        self._auth(self.admin)
        response = self.client.patch(
            f'/api/orders/{self.order.pk}/status/',
            {'order_status': 'CONFIRMED'}, format='json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['order_status'], 'CONFIRMED')

    def test_invalid_status_returns_400(self):
        self._auth(self.admin)
        response = self.client.patch(
            f'/api/orders/{self.order.pk}/status/',
            {'order_status': 'INVALID'}, format='json'
        )
        self.assertEqual(response.status_code, 400)

    def test_status_update_for_missing_order_returns_404(self):
        self._auth(self.admin)
        response = self.client.patch('/api/orders/99999/status/', {'order_status': 'CONFIRMED'}, format='json')
        self.assertEqual(response.status_code, 404)

    def test_non_admin_cannot_update_order_status(self):
        self._auth(self.user)
        response = self.client.patch(
            f'/api/orders/{self.order.pk}/status/',
            {'order_status': 'CONFIRMED'}, format='json'
        )
        self.assertEqual(response.status_code, 403)
