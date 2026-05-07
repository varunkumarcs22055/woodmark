from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product
from users.models import User


class ProductListViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.cat_sofa = Category.objects.create(name='Sofas', slug='sofas')
        self.cat_chair = Category.objects.create(name='Chairs', slug='chairs')
        for i in range(3):
            Product.objects.create(
                name=f'Sofa {i}', price=10000 + i * 1000,
                category=self.cat_sofa, material='fabric',
                color='Blue', dimensions='200x80x80',
                image_url='https://test.com/img.jpg', stock=5,
            )
        Product.objects.create(
            name='Chair 1', price=5000, category=self.cat_chair,
            material='wood', color='Brown', dimensions='70x70x90',
            image_url='https://test.com/img.jpg', stock=3,
        )

    def test_list_returns_all_products(self):
        response = self.client.get('/api/products/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 4)

    def test_filter_by_category_slug(self):
        response = self.client.get('/api/products/?category=sofas')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 3)

    def test_filter_by_price_range(self):
        response = self.client.get('/api/products/?price_min=10000&price_max=11000')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 2)

    def test_search_by_name(self):
        response = self.client.get('/api/products/?search=Chair')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 1)

    def test_product_detail_by_slug(self):
        product = Product.objects.get(name='Chair 1')
        response = self.client.get(f'/api/products/{product.slug}/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['name'], 'Chair 1')

    def test_product_detail_404_for_nonexistent_slug(self):
        response = self.client.get('/api/products/nonexistent-slug/')
        self.assertEqual(response.status_code, 404)

    def test_categories_endpoint(self):
        response = self.client.get('/api/products/categories/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 2)

    def test_similar_products(self):
        sofa = Product.objects.filter(category=self.cat_sofa).first()
        response = self.client.get(f'/api/products/similar/{sofa.pk}/')
        self.assertEqual(response.status_code, 200)
        self.assertLessEqual(len(response.data), 4)
        for p in response.data:
            self.assertNotEqual(p['id'], sofa.pk)

    def test_similar_products_404(self):
        response = self.client.get('/api/products/similar/99999/')
        self.assertEqual(response.status_code, 404)


class ProductAdminViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.cat = Category.objects.create(name='Sofas', slug='sofas')
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

    def test_admin_can_create_product(self):
        self._auth(self.admin)
        data = {
            'name': 'Test Sofa', 'description': 'A test sofa',
            'price': '9999.00', 'category': self.cat.pk,
            'material': 'fabric', 'color': 'Red',
            'dimensions': '200x80x80', 'image_url': 'https://test.com/img.jpg',
            'stock': 5, 'is_featured': False,
        }
        response = self.client.post('/api/products/admin/', data, format='json')
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['name'], 'Test Sofa')

    def test_non_admin_gets_403(self):
        self._auth(self.user)
        response = self.client.post('/api/products/admin/', {}, format='json')
        self.assertEqual(response.status_code, 403)

    def test_unauthenticated_gets_401(self):
        response = self.client.post('/api/products/admin/', {}, format='json')
        self.assertEqual(response.status_code, 401)
