from django.test import TestCase, Client
from users.models import User


class GoogleOAuthPipelineTest(TestCase):
    def test_save_user_role_assigns_user_role_to_new_user(self):
        user = User.objects.create_user(
            email='oauth@test.com',
            username='oauth@test.com',
            password='',
            role='',
        )
        from users.pipeline import save_user_role
        save_user_role(backend=None, user=user, response=None)
        user.refresh_from_db()
        self.assertEqual(user.role, 'user')

    def test_save_user_role_does_not_overwrite_existing_role(self):
        user = User.objects.create_user(
            email='admin@test.com',
            username='admin@test.com',
            password='',
            role='admin',
        )
        from users.pipeline import save_user_role
        save_user_role(backend=None, user=user, response=None)
        user.refresh_from_db()
        self.assertEqual(user.role, 'admin')

    def test_google_login_redirect_returns_redirect(self):
        client = Client()
        response = client.get('/api/auth/google/')
        self.assertEqual(response.status_code, 302)
        self.assertIn('/social-auth/login/google-oauth2/', response['Location'])
