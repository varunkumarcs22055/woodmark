# Backend Prompt 3 — JWT Authentication API (Register, Login, Refresh, Logout, Profile)

## Role
You are a senior backend engineer. Build all authentication endpoints for FurniShop: email/password registration, login, token refresh, logout (with token blacklisting), user profile, and dealer application submission and admin approval.

---

## Context
This prompt implements the `users` app API views and URLs. JWT is issued by `djangorestframework-simplejwt`. All auth flows are stateless (no server sessions for auth — sessions are only used for the cart). 

**Depends on:** Backend Prompts 1 (settings, SimpleJWT config) and 2 (User model, serializers, permissions)
**Required by:** Backend Prompt 4 (Google OAuth), all protected endpoints

---

## Files to Create/Modify

```
backend/users/
├── views.py        ← All auth views
└── urls.py         ← URL routing for /api/auth/
```

---

## Views — `users/views.py`

Implement these views:

### 1. RegisterView
- `POST /api/auth/register/`
- Permission: AllowAny
- Uses `UserRegistrationSerializer`
- On success: creates user, issues JWT pair via `RefreshToken.for_user(user)`, returns tokens + user profile
- On duplicate email: returns `400` with `{"email": ["A user with this email already exists."]}`

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .models import User
from .serializers import (
    UserRegistrationSerializer, UserLoginSerializer,
    UserProfileSerializer, DealerApplicationSerializer,
    AdminDealerApprovalSerializer
)
from .permissions import IsAdminRole


def get_tokens_for_user(user):
    """Generate JWT access + refresh token pair for a user."""
    refresh = RefreshToken.for_user(user)
    # Inject custom claims
    refresh['role'] = user.role
    refresh['email'] = user.email
    if user.role == 'dealer':
        refresh['dealer_status'] = user.dealer_status or 'pending'
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            tokens = get_tokens_for_user(user)
            return Response({
                **tokens,
                'user': UserProfileSerializer(user).data,
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
```

### 2. LoginView
- `POST /api/auth/login/`
- Permission: AllowAny
- Authenticates via email + password using Django's `authenticate()`
- On success: returns JWT pair + user profile
- On failure: returns `401` with `{"detail": "Invalid email or password."}`
- Inactive accounts: returns `401` with `{"detail": "Account is disabled."}`

### 3. LogoutView
- `POST /api/auth/logout/`
- Permission: IsAuthenticated
- Blacklists the provided refresh token
- Request body: `{"refresh": "<token>"}`
- On success: `200 {"detail": "Logged out successfully."}`
- On invalid token: `400 {"detail": "Token is invalid or expired."}`

```python
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({'detail': 'Logged out successfully.'}, status=status.HTTP_200_OK)
        except TokenError:
            return Response({'detail': 'Token is invalid or expired.'}, status=status.HTTP_400_BAD_REQUEST)
```

### 4. UserProfileView
- `GET /api/auth/profile/` — returns current user's profile
- `PATCH /api/auth/profile/` — update `first_name`, `last_name`, `phone`
- Permission: IsAuthenticated
- Uses `UserProfileSerializer`

### 5. DealerApplicationView
- `POST /api/auth/dealer-apply/`
- Permission: AllowAny
- Uses `DealerApplicationSerializer`
- Creates user with `role='dealer'`, `dealer_status='pending'`
- Returns `201` with `{"detail": "Application submitted. You will be notified once approved.", "email": "<email>"}`
- Does NOT issue JWT on registration — dealer must wait for admin approval before login grants dealer pricing

### 6. DealerApprovalView
- `GET /api/auth/dealers/pending/` — list pending dealer applications
- `PATCH /api/auth/dealers/{id}/approve/` — approve or reject a dealer
- Permission: IsAdminRole (both endpoints)
- `PATCH` uses `AdminDealerApprovalSerializer` — sets `dealer_status` to `active` or `rejected`
- On approval: optionally send email notification (log it if email not configured)

### 7. UserListView (Admin only)
- `GET /api/auth/users/`
- Permission: IsAdminRole
- Query params: `?role=dealer`, `?dealer_status=pending`
- Returns paginated list of users using `UserProfileSerializer`

---

## URLs — `users/urls.py`

```python
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    # Auth
    path('register/', views.RegisterView.as_view(), name='auth-register'),
    path('login/', views.LoginView.as_view(), name='auth-login'),
    path('logout/', views.LogoutView.as_view(), name='auth-logout'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    # Profile
    path('profile/', views.UserProfileView.as_view(), name='auth-profile'),
    # Dealer
    path('dealer-apply/', views.DealerApplicationView.as_view(), name='dealer-apply'),
    path('dealers/pending/', views.DealerApprovalView.as_view(), name='dealers-pending'),
    path('dealers/<int:pk>/approve/', views.DealerApprovalView.as_view(), name='dealer-approve'),
    # Admin
    path('users/', views.UserListView.as_view(), name='user-list'),
]
```

---

## JWT Custom Claims

Override SimpleJWT's `RefreshToken.for_user` to inject role into the token payload by using the `get_tokens_for_user()` helper defined above. This means the frontend can decode the access token and read the `role` without an extra API call.

The access token payload will look like:
```json
{
  "user_id": 42,
  "email": "dealer@example.com",
  "role": "dealer",
  "dealer_status": "active",
  "exp": 1756000000,
  "iat": 1755913600,
  "jti": "abc123...",
  "token_type": "access"
}
```

---

## Error Response Format

Maintain consistent error format across all auth endpoints:
```json
{
  "detail": "Human-readable error message"
}
```
Or for field-level validation:
```json
{
  "email": ["A user with this email already exists."],
  "password": ["This password is too common."]
}
```

---

## Tests — `users/tests/test_views.py`

Write tests covering:

```python
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
            'full_name': 'Test User'
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

    def test_dealer_application_creates_pending_dealer(self):
        data = {
            'email': 'dealer@company.com',
            'password': 'SecurePass@123',
            'confirm_password': 'SecurePass@123',
            'first_name': 'Dealer',
            'last_name': 'One',
            'phone': '9999999999',
            'dealer_company_name': 'Acme Furniture Co',
            'dealer_gst_number': '27AAPFU0939F1ZV'
        }
        response = self.client.post('/api/auth/dealer-apply/', data)
        self.assertEqual(response.status_code, 201)
        user = User.objects.get(email='dealer@company.com')
        self.assertEqual(user.role, 'dealer')
        self.assertEqual(user.dealer_status, 'pending')
```

---

## Acceptance Criteria

- [ ] `POST /api/auth/register/` creates user, returns `access` + `refresh` + `user` object
- [ ] `POST /api/auth/login/` with valid credentials returns JWT pair
- [ ] `POST /api/auth/login/` with wrong password returns `401`
- [ ] `GET /api/auth/profile/` without token returns `401`
- [ ] `GET /api/auth/profile/` with valid Bearer token returns user profile
- [ ] `POST /api/auth/token/refresh/` with valid refresh token returns new access token
- [ ] `POST /api/auth/logout/` blacklists the refresh token — subsequent refresh attempts return `401`
- [ ] `POST /api/auth/dealer-apply/` creates user with `role='dealer'`, `dealer_status='pending'`
- [ ] `PATCH /api/auth/dealers/{id}/approve/` with `{"dealer_status": "active"}` from admin updates status
- [ ] Non-admin cannot access `GET /api/auth/users/` — returns `403`
- [ ] All tests pass: `python manage.py test users`
