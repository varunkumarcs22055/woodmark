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

from django.shortcuts import redirect
from django.conf import settings


def save_user_role(backend, user, response, *args, **kwargs):
    """Assign default role to OAuth users. Dealers/admins must be assigned via admin panel."""
    changed = False
    if not user.role:
        user.role = 'user'
        changed = True
    if not user.username or user.username != user.email:
        user.username = user.email
        changed = True
    if changed:
        user.save(update_fields=['role', 'username'])


def issue_jwt_and_redirect(backend, user, response, *args, **kwargs):
    """Final pipeline step: issue JWT tokens and redirect to frontend."""
    from .views import get_tokens_for_user
    tokens = get_tokens_for_user(user)
    redirect_url = (
        f"{settings.FRONTEND_URL}/auth-callback"
        f"?access={tokens['access']}"
        f"&refresh={tokens['refresh']}"
    )
    return redirect(redirect_url)
