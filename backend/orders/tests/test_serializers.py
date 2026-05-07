from decimal import Decimal
from django.test import TestCase, RequestFactory
from rest_framework.test import APIRequestFactory
from products.models import Category, Product
from discounts.models import Discount
from users.models import User
from orders.serializers import OrderCreateSerializer


class OrderCreateSerializerTest(TestCase):
    def setUp(self):
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=20
        )
        self.user = User.objects.create_user(
            email='user@test.com', username='user@test.com',
            password='pass', role='user'
        )

    def _payload(self, qty=2):
        return {
            'user_name': 'Test User',
            'user_email': 'test@test.com',
            'phone': '9876543210',
            'address': '123 Test St',
            'items': [{'product_id': self.product.pk, 'quantity': qty}],
        }

    def test_creates_order_at_full_price_when_no_discount(self):
        s = OrderCreateSerializer(data=self._payload(2))
        self.assertTrue(s.is_valid(), s.errors)
        order = s.save()
        self.assertEqual(order.total_amount, Decimal('20000.00'))
        item = order.items.first()
        self.assertEqual(item.original_price, Decimal('10000.00'))
        self.assertEqual(item.price, Decimal('10000.00'))

    def test_creates_order_at_discounted_price_for_user_role(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('20'), active=True
        )
        factory = APIRequestFactory()
        request = factory.post('/')
        request.user = self.user
        s = OrderCreateSerializer(data=self._payload(1), context={'request': request})
        self.assertTrue(s.is_valid(), s.errors)
        order = s.save()
        self.assertEqual(order.total_amount, Decimal('8000.00'))
        self.assertEqual(order.user, self.user)

    def test_stock_validation_rejects_over_stock(self):
        s = OrderCreateSerializer(data=self._payload(99))
        self.assertFalse(s.is_valid())
        self.assertIn('items', s.errors)

    def test_empty_items_rejected(self):
        payload = self._payload()
        payload['items'] = []
        s = OrderCreateSerializer(data=payload)
        self.assertFalse(s.is_valid())

    def test_nonexistent_product_rejected(self):
        payload = self._payload()
        payload['items'] = [{'product_id': 99999, 'quantity': 1}]
        s = OrderCreateSerializer(data=payload)
        self.assertFalse(s.is_valid())

    def test_stock_decremented_after_order(self):
        s = OrderCreateSerializer(data=self._payload(3))
        self.assertTrue(s.is_valid(), s.errors)
        s.save()
        self.product.refresh_from_db()
        self.assertEqual(self.product.stock, 17)
