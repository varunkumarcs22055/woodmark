from decimal import Decimal
from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product
from users.models import User
from discounts.models import Discount


class DiscountViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=self.cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=50
        )
        self.admin = User.objects.create_user(
            email='admin@test.com', username='admin@test.com',
            password='pass', role='admin',
        )
        self.user = User.objects.create_user(
            email='user@test.com', username='user@test.com',
            password='pass', role='user',
        )

    def _auth(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        token = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {str(token.access_token)}')

    def test_admin_can_create_discount(self):
        self._auth(self.admin)
        data = {
            'product': self.product.pk,
            'discount_type': 'user',
            'mode': 'percent',
            'value': '15.00',
            'active': True,
        }
        response = self.client.post('/api/discounts/', data, format='json')
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['discount_type'], 'user')

    def test_non_admin_cannot_create_discount(self):
        self._auth(self.user)
        response = self.client.post('/api/discounts/', {}, format='json')
        self.assertEqual(response.status_code, 403)

    def test_unauthenticated_gets_401(self):
        response = self.client.post('/api/discounts/', {}, format='json')
        self.assertEqual(response.status_code, 401)

    def test_duplicate_discount_type_returns_400(self):
        self._auth(self.admin)
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'), active=True
        )
        data = {
            'product': self.product.pk,
            'discount_type': 'user',
            'mode': 'flat',
            'value': '500.00',
            'active': True,
        }
        response = self.client.post('/api/discounts/', data, format='json')
        self.assertEqual(response.status_code, 400)

    def test_admin_can_list_discounts(self):
        self._auth(self.admin)
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'), active=True
        )
        response = self.client.get('/api/discounts/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)

    def test_admin_can_filter_by_type(self):
        self._auth(self.admin)
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'), active=True
        )
        response = self.client.get('/api/discounts/?type=dealer')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 0)

    def test_admin_can_update_discount(self):
        self._auth(self.admin)
        discount = Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'), active=True
        )
        response = self.client.put(
            f'/api/discounts/{discount.pk}/',
            {'active': False}, format='json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertFalse(response.data['active'])

    def test_admin_can_delete_discount(self):
        self._auth(self.admin)
        discount = Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'), active=True
        )
        response = self.client.delete(f'/api/discounts/{discount.pk}/')
        self.assertEqual(response.status_code, 204)
        self.assertEqual(Discount.objects.count(), 0)

    def test_detail_404_for_missing(self):
        self._auth(self.admin)
        response = self.client.get('/api/discounts/99999/')
        self.assertEqual(response.status_code, 404)


class ProductPricingIntegrationTest(TestCase):
    """Test that product list returns effective_price based on user role."""

    def setUp(self):
        self.client = APIClient()
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=50
        )
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('20'), active=True
        )
        Discount.objects.create(
            product=self.product, discount_type='dealer',
            mode='flat', value=Decimal('3000'), active=True
        )
        self.user = User.objects.create_user(
            email='user@test.com', username='user@test.com',
            password='pass', role='user',
        )
        self.dealer = User.objects.create_user(
            email='dealer@test.com', username='dealer@test.com',
            password='pass', role='dealer', dealer_status='active',
        )

    def _auth(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        token = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {str(token.access_token)}')

    def test_guest_gets_full_price(self):
        response = self.client.get('/api/products/')
        self.assertEqual(response.status_code, 200)
        item = response.data['results'][0]
        self.assertEqual(item['effective_price'], '10000.00')
        self.assertIsNone(item['discount_applied'])

    def test_user_gets_user_discount(self):
        self._auth(self.user)
        response = self.client.get('/api/products/')
        self.assertEqual(response.status_code, 200)
        item = response.data['results'][0]
        self.assertEqual(item['effective_price'], '8000.00')
        self.assertIsNotNone(item['discount_applied'])
        self.assertEqual(item['discount_applied']['type'], 'user')

    def test_dealer_gets_dealer_discount(self):
        self._auth(self.dealer)
        response = self.client.get('/api/products/')
        self.assertEqual(response.status_code, 200)
        item = response.data['results'][0]
        self.assertEqual(item['effective_price'], '7000.00')
        self.assertIsNotNone(item['discount_applied'])
        self.assertEqual(item['discount_applied']['type'], 'dealer')
