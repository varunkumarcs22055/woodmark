from django.test import TestCase
from products.models import Category, Product
from orders.models import Order, OrderItem


class OrderModelTest(TestCase):
    def setUp(self):
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=50
        )

    def test_order_id_auto_generated(self):
        order = Order.objects.create(
            user_name='John Doe', user_email='john@test.com',
            phone='9876543210', address='123 Main St',
            total_amount='10000.00'
        )
        self.assertTrue(order.order_id.startswith('ORD-'))
        self.assertEqual(len(order.order_id), 12)

    def test_order_default_statuses(self):
        order = Order.objects.create(
            user_name='Jane', user_email='jane@test.com',
            phone='9999999999', address='456 Oak Ave',
            total_amount='5000.00'
        )
        self.assertEqual(order.payment_status, 'PENDING')
        self.assertEqual(order.order_status, 'CREATED')
        self.assertEqual(order.erp_sync_status, 'pending')

    def test_order_item_subtotal(self):
        order = Order.objects.create(
            user_name='Test', user_email='test@test.com',
            phone='1234567890', address='Test Addr',
            total_amount='20000.00'
        )
        item = OrderItem.objects.create(
            order=order, product=self.product,
            quantity=2, price='9000.00', original_price='10000.00'
        )
        from decimal import Decimal
        self.assertEqual(item.subtotal, Decimal('18000.00'))

    def test_order_str_representation(self):
        order = Order.objects.create(
            user_name='Alice', user_email='alice@test.com',
            phone='1111111111', address='Addr',
            total_amount='1000.00'
        )
        self.assertIn('ORD-', str(order))
        self.assertIn('Alice', str(order))
