# Backend Prompt 4 — Google OAuth Integration

## Role
You are a senior backend engineer. Implement Google OAuth2 login for FurniShop using `social-auth-app-django`. After successful Google authentication, issue a JWT pair and redirect the browser back to the React frontend with the tokens.

---

## Context
This prompt adds Google "Login with Google" to the auth system. The user clicks a button on the React frontend, gets redirected to Google, authorizes, and returns to the frontend already logged in with a JWT. The social-auth pipeline from Prompt 1 settings is already registered — now implement the callback view that converts the social-auth result into JWT tokens.

**Depends on:** Backend Prompts 1 (social-auth settings), 2 (User model, pipeline.py), 3 (get_tokens_for_user helper)
**Required by:** Frontend Prompt 5 (OAuth button)

---

## How the Flow Works

```
1. User visits GET /social-auth/login/google-oauth2/
   → social-auth-app-django handles the OAuth redirect to Google

2. Google redirects to GET /social-auth/complete/google-oauth2/
   → social-auth-app-django exchanges code, fetches profile,
     runs the pipeline (creates/retrieves user, assigns role='user')

3. social-auth calls LOGIN_REDIRECT_URL = '/'
   BUT we override this with a custom backend that intercepts
   the completed authentication and issues JWT instead.

4. Backend redirects to:
   {FRONTEND_URL}/auth-callback?access=<token>&refresh=<token>

5. Frontend AuthCallbackPage reads tokens from URL,
   stores them, and redirects to home.
```

---

## Implementation

### Option A: Custom social-auth Pipeline Step (Recommended)

Add a pipeline function that issues JWT and redirects. This is the cleanest approach — no view override needed.

**`users/pipeline.py` (update from Prompt 2):**

```python
from django.shortcuts import redirect
from django.conf import settings
from .views import get_tokens_for_user  # The helper from Prompt 3


def save_user_role(backend, user, response, *args, **kwargs):
    """Assign default role to OAuth users."""
    changed = False
    if not user.role:
        user.role = 'user'
        changed = True
    # If this is a new social user, set username from email
    if not user.username or user.username != user.email:
        user.username = user.email
        changed = True
    if changed:
        user.save(update_fields=['role', 'username'])


def issue_jwt_and_redirect(backend, user, response, *args, **kwargs):
    """
    Final pipeline step: issue JWT tokens and redirect to frontend.
    This step runs after user creation/retrieval.
    The redirect happens via a special pipeline return.
    """
    tokens = get_tokens_for_user(user)
    frontend_url = settings.FRONTEND_URL
    redirect_url = (
        f"{frontend_url}/auth-callback"
        f"?access={tokens['access']}"
        f"&refresh={tokens['refresh']}"
    )
    return redirect(redirect_url)
```

**Update `settings.py` SOCIAL_AUTH_PIPELINE to include the new step:**

```python
SOCIAL_AUTH_PIPELINE = (
    'social_core.pipeline.social_auth.social_details',
    'social_core.pipeline.social_auth.social_uid',
    'social_core.pipeline.social_auth.auth_allowed',
    'social_core.pipeline.social_auth.social_user',
    'social_core.pipeline.user.get_username',
    'social_core.pipeline.user.create_user',
    'social_core.pipeline.social_auth.associate_user',
    'social_core.pipeline.social_auth.load_extra_data',
    'users.pipeline.save_user_role',
    'users.pipeline.issue_jwt_and_redirect',  # ← Must be last
)
```

---

### OAuth Initiation View

The frontend sends the user to `GET /social-auth/login/google-oauth2/`. This URL is registered by `social_django.urls` (already in `core/urls.py` from Prompt 1). No additional view needed.

Add this endpoint to `users/urls.py` for frontend convenience (just documents the URL, handled by social_django):
```
GET /api/auth/google/   → redirects to /social-auth/login/google-oauth2/
```

```python
# users/views.py — add this view
from django.shortcuts import redirect as django_redirect

class GoogleLoginRedirectView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return django_redirect('/social-auth/login/google-oauth2/')
```

Add to `users/urls.py`:
```python
path('google/', views.GoogleLoginRedirectView.as_view(), name='google-login'),
```

---

## Google Cloud Console Setup

Document these steps in a comment at the top of `users/pipeline.py`:

```
# Google OAuth2 Setup:
# 1. Go to https://console.cloud.google.com
# 2. Create a new project (or select existing)
# 3. APIs & Services → OAuth consent screen → External → Fill app name, support email
# 4. APIs & Services → Credentials → Create Credentials → OAuth 2.0 Client IDs
# 5. Application type: Web application
# 6. Authorized redirect URIs:
#    - http://localhost:8000/social-auth/complete/google-oauth2/ (development)
#    - https://api.furnishop.com/social-auth/complete/google-oauth2/ (production)
# 7. Copy Client ID → GOOGLE_CLIENT_ID in .env
# 8. Copy Client Secret → GOOGLE_CLIENT_SECRET in .env
```

---

## Security Considerations

- **Token in URL query params:** This is a deliberate trade-off. The frontend immediately reads and clears the tokens from the URL (using `history.replaceState`). Tokens should not persist in browser history. Document this in the frontend prompt.
- **State parameter:** social-auth-app-django handles CSRF protection via the `state` parameter automatically.
- **Scope:** Only request `email` and `profile` — never request unnecessary Google permissions.
- **New vs existing user:** If a user already registered with email/password and then tries Google OAuth with the same email, social-auth will associate the Google account with the existing user (via `social_core.pipeline.social_auth.associate_user`).

---

## Testing

Since OAuth cannot be unit tested without mocking the Google servers, write integration-style tests using `unittest.mock`:

```python
# users/tests/test_oauth.py
from unittest.mock import patch, MagicMock
from django.test import TestCase, Client
from users.models import User


class GoogleOAuthPipelineTest(TestCase):
    def test_save_user_role_assigns_user_role_to_new_user(self):
        user = User.objects.create_user(
            email='oauth@test.com',
            username='oauth@test.com',
            password='',
            role='',  # Simulate new OAuth user with no role yet
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
        self.assertEqual(user.role, 'admin')  # Should not change

    def test_google_login_redirect_returns_redirect(self):
        client = Client()
        response = client.get('/api/auth/google/')
        self.assertEqual(response.status_code, 302)
        self.assertIn('/social-auth/login/google-oauth2/', response['Location'])
```

---

## Acceptance Criteria

- [ ] `GET /api/auth/google/` returns a 302 redirect to Google OAuth URL
- [ ] After successful Google auth (manual test), browser is redirected to `{FRONTEND_URL}/auth-callback?access=<token>&refresh=<token>`
- [ ] New Google user is created with `role='user'`
- [ ] Existing email/password user who logs in with Google is NOT duplicated — same user account is used
- [ ] OAuth user's `role` field is never changed to something other than `user` by the pipeline
- [ ] JWT tokens issued via OAuth are valid — `GET /api/auth/profile/` with the access token returns the user profile
- [ ] Pipeline tests pass: `python manage.py test users.tests.test_oauth`
