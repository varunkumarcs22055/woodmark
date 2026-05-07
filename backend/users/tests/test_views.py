from django.test import TestCase
from rest_framework.test import APIClient
from users.models import User


class AuthEndpointsTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.register_url = '/api/auth/register/'
        self.login_url = '/api/auth/login/'

    def test_register_creates_user_and_returns_tokens(self):
        data = {
            'email': 'new@test.com',
            'password': 'SecurePass@123',
            'confirm_password': 'SecurePass@123',
            'full_name': 'Test User',
        }
        response = self.client.post(self.register_url, data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertEqual(response.data['user']['role'], 'user')

    def test_register_duplicate_email_returns_400(self):
        User.objects.create_user(email='existing@test.com', username='existing@test.com', password='pass')
        data = {'email': 'existing@test.com', 'password': 'SecurePass@123', 'confirm_password': 'SecurePass@123'}
        response = self.client.post(self.register_url, data)
        self.assertEqual(response.status_code, 400)

    def test_login_returns_tokens(self):
        User.objects.create_user(email='user@test.com', username='user@test.com', password='SecurePass@123')
        response = self.client.post(self.login_url, {'email': 'user@test.com', 'password': 'SecurePass@123'})
        self.assertEqual(response.status_code, 200)
        self.assertIn('access', response.data)

    def test_login_wrong_password_returns_401(self):
        User.objects.create_user(email='user@test.com', username='user@test.com', password='correct')
        response = self.client.post(self.login_url, {'email': 'user@test.com', 'password': 'wrong'})
        self.assertEqual(response.status_code, 401)

    def test_profile_requires_authentication(self):
        response = self.client.get('/api/auth/profile/')
        self.assertEqual(response.status_code, 401)

    def test_profile_returns_user_data_with_token(self):
        user = User.objects.create_user(email='user@test.com', username='user@test.com', password='SecurePass@123')
        login = self.client.post(self.login_url, {'email': 'user@test.com', 'password': 'SecurePass@123'})
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {login.data["access"]}')
        response = self.client.get('/api/auth/profile/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['email'], user.email)

    def test_dealer_application_creates_pending_dealer(self):
        data = {
            'email': 'dealer@company.com',
            'password': 'SecurePass@123',
            'confirm_password': 'SecurePass@123',
            'first_name': 'Dealer',
            'last_name': 'One',
            'phone': '9999999999',
            'dealer_company_name': 'Acme Furniture Co',
            'dealer_gst_number': '27AAPFU0939F1ZV',
        }
        response = self.client.post('/api/auth/dealer-apply/', data)
        self.assertEqual(response.status_code, 201)
        user = User.objects.get(email='dealer@company.com')
        self.assertEqual(user.role, 'dealer')
        self.assertEqual(user.dealer_status, 'pending')

    def test_logout_blacklists_refresh_token(self):
        User.objects.create_user(email='user@test.com', username='user@test.com', password='SecurePass@123')
        login = self.client.post(self.login_url, {'email': 'user@test.com', 'password': 'SecurePass@123'})
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {login.data["access"]}')
        response = self.client.post('/api/auth/logout/', {'refresh': login.data['refresh']})
        self.assertEqual(response.status_code, 200)

    def test_non_admin_cannot_list_users(self):
        User.objects.create_user(email='user@test.com', username='user@test.com', password='SecurePass@123', role='user')
        login = self.client.post(self.login_url, {'email': 'user@test.com', 'password': 'SecurePass@123'})
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {login.data["access"]}')
        response = self.client.get('/api/auth/users/')
        self.assertEqual(response.status_code, 403)
