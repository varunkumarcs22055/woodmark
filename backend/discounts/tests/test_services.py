from decimal import Decimal
from django.test import TestCase
from products.models import Category, Product
from discounts.models import Discount
from discounts.services import get_effective_price, apply_discounts_to_order


class GetEffectivePriceTest(TestCase):
    def setUp(self):
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80', image_url='https://test.com/img.jpg', stock=50
        )

    def test_no_discount_returns_full_price(self):
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertIsNone(discount)
        self.assertIsNone(remaining)

    def test_percent_discount_applied_correctly(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('20'), active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('8000.00'))
        self.assertIsNotNone(discount)
        self.assertIsNone(remaining)

    def test_flat_discount_applied_correctly(self):
        Discount.objects.create(
            product=self.product, discount_type='dealer',
            mode='flat', value=Decimal('2500'), active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'dealer')
        self.assertEqual(price, Decimal('7500.00'))

    def test_exhausted_count_limit_returns_full_price(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'),
            count_limit=50, units_sold=50, active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertEqual(remaining, 0)

    def test_partial_count_limit_returns_remaining(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'),
            count_limit=100, units_sold=30, active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertNotEqual(price, self.product.price)
        self.assertEqual(remaining, 70)

    def test_admin_role_always_gets_full_price(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('30'), active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'admin')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertIsNone(discount)

    def test_inactive_discount_ignored(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('15'), active=False
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertIsNone(discount)

    def test_dealer_discount_not_applied_to_user(self):
        Discount.objects.create(
            product=self.product, discount_type='dealer',
            mode='percent', value=Decimal('20'), active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertIsNone(discount)
