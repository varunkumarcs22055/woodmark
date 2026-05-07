from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product


class CartViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80',
            image_url='https://test.com/img.jpg', stock=10
        )

    def test_empty_cart_returns_zero(self):
        response = self.client.get('/api/cart/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 0)
        self.assertEqual(response.data['total'], '0.00')

    def test_add_item_to_cart(self):
        response = self.client.post('/api/cart/add/', {'product_id': self.product.pk, 'quantity': 2}, format='json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['quantity'], 2)
        self.assertEqual(response.data['cart_count'], 2)

    def test_add_item_missing_product_id_returns_400(self):
        response = self.client.post('/api/cart/add/', {}, format='json')
        self.assertEqual(response.status_code, 400)

    def test_add_nonexistent_product_returns_404(self):
        response = self.client.post('/api/cart/add/', {'product_id': 99999, 'quantity': 1}, format='json')
        self.assertEqual(response.status_code, 404)

    def test_add_exceeds_stock_returns_400(self):
        response = self.client.post('/api/cart/add/', {'product_id': self.product.pk, 'quantity': 99}, format='json')
        self.assertEqual(response.status_code, 400)
        self.assertIn('Only', response.data['error'])

    def test_cumulative_add_exceeds_stock_returns_400(self):
        self.client.post('/api/cart/add/', {'product_id': self.product.pk, 'quantity': 8}, format='json')
        response = self.client.post('/api/cart/add/', {'product_id': self.product.pk, 'quantity': 5}, format='json')
        self.assertEqual(response.status_code, 400)

    def test_get_cart_returns_item_details(self):
        self.client.post('/api/cart/add/', {'product_id': self.product.pk, 'quantity': 3}, format='json')
        response = self.client.get('/api/cart/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 3)
        self.assertEqual(len(response.data['items']), 1)
        self.assertEqual(response.data['items'][0]['quantity'], 3)

    def test_remove_item_from_cart(self):
        self.client.post('/api/cart/add/', {'product_id': self.product.pk, 'quantity': 1}, format='json')
        response = self.client.post('/api/cart/remove/', {'product_id': self.product.pk}, format='json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['cart_count'], 0)

    def test_remove_missing_product_id_returns_400(self):
        response = self.client.post('/api/cart/remove/', {}, format='json')
        self.assertEqual(response.status_code, 400)

    def test_clear_cart(self):
        self.client.post('/api/cart/add/', {'product_id': self.product.pk, 'quantity': 2}, format='json')
        response = self.client.post('/api/cart/clear/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['cart_count'], 0)
        cart_response = self.client.get('/api/cart/')
        self.assertEqual(cart_response.data['count'], 0)
