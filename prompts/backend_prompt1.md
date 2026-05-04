# Backend Prompt 1 — Django Project Foundation & Core Configuration

## Role
You are a senior backend engineer at a FAANG company. You are setting up the production-grade foundation for **FurniShop**, a furniture e-commerce platform. Write clean, secure, well-structured Django code with zero shortcuts.

---

## What You Are Building
The base Django project skeleton for FurniShop. This includes the project configuration, database setup (PostgreSQL via Neon with SQLite fallback), DRF configuration, CORS, sessions, environment management, and the complete `requirements.txt`.

This is **Prompt 1 of 8** for the backend. Nothing depends on this prompt — everything else depends on it.

---

## Target File Structure

```
backend/
├── core/
│   ├── __init__.py
│   ├── settings.py         ← Main configuration (all environments)
│   ├── urls.py             ← Root URL router
│   ├── asgi.py
│   └── wsgi.py
├── users/                  ← App stub (models/views/admin populated in Prompt 2)
│   ├── __init__.py
│   ├── models.py
│   ├── admin.py
│   ├── apps.py
│   └── migrations/
│       └── __init__.py
├── products/               ← App stub (populated in Prompt 5)
│   ├── __init__.py
│   ├── models.py
│   ├── apps.py
│   └── migrations/
│       └── __init__.py
├── cart/                   ← App stub (populated in Prompt 7)
│   ├── __init__.py
│   ├── apps.py
│   └── migrations/
│       └── __init__.py
├── orders/                 ← App stub (populated in Prompt 7)
│   ├── __init__.py
│   ├── apps.py
│   └── migrations/
│       └── __init__.py
├── payments/               ← App stub (populated in Prompt 8)
│   ├── __init__.py
│   ├── apps.py
│   └── migrations/
│       └── __init__.py
├── discounts/              ← App stub (populated in Prompt 6)
│   ├── __init__.py
│   ├── apps.py
│   └── migrations/
│       └── __init__.py
├── services/
│   ├── __init__.py
│   └── erp.py              ← ERP integration (stub)
├── .env
├── .env.example
├── requirements.txt
├── manage.py
└── Procfile                ← For Railway/Render deployment
```

---

## Dependencies

Write this exact `requirements.txt`:

```
Django>=5.1,<6.0
djangorestframework>=3.15,<4.0
django-cors-headers>=4.3,<5.0
django-filter>=24.0,<25.0
psycopg2-binary>=2.9,<3.0
dj-database-url>=2.1,<3.0
python-dotenv>=1.0,<2.0
requests>=2.31,<3.0
gunicorn>=22.0,<23.0
razorpay>=1.4
djangorestframework-simplejwt>=5.3,<6.0
social-auth-app-django>=5.4,<6.0
social-auth-core>=4.5,<5.0
django-storages>=1.14,<2.0
Pillow>=10.0,<11.0
```

---

## Settings — `core/settings.py`

Write a single `settings.py` that handles both development and production via environment variables. No separate `settings_dev.py` / `settings_prod.py`.

### Required configuration blocks:

**1. Imports and env loading:**
```python
import os
from pathlib import Path
from dotenv import load_dotenv
import dj_database_url

load_dotenv()
BASE_DIR = Path(__file__).resolve().parent.parent
```

**2. Security:**
```python
SECRET_KEY = os.getenv('SECRET_KEY', 'django-insecure-change-me-in-production')
DEBUG = os.getenv('DEBUG', 'True').lower() in ('true', '1', 'yes')
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', 'localhost,127.0.0.1').split(',')
```

**3. INSTALLED_APPS (in this exact order):**
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Third-party
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'django_filters',
    'social_django',
    # Local apps
    'users',
    'products',
    'cart',
    'orders',
    'payments',
    'discounts',
]
```

**4. Middleware (CORS must be before CommonMiddleware):**
```python
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'social_django.middleware.SocialAuthExceptionMiddleware',
]
```

**5. Database (PostgreSQL with SQLite fallback):**
```python
DATABASE_URL = os.getenv('DATABASE_URL')
if DATABASE_URL:
    DATABASES = {
        'default': dj_database_url.config(
            default=DATABASE_URL,
            conn_max_age=600,
            conn_health_checks=True,
        )
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }
```

**6. Custom user model:**
```python
AUTH_USER_MODEL = 'users.User'
```

**7. DRF configuration:**
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticatedOrReadOnly',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 12,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}
```

**8. SimpleJWT configuration:**
```python
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}
```

**9. CORS:**
```python
CORS_ALLOWED_ORIGINS = os.getenv(
    'CORS_ALLOWED_ORIGINS', 'http://localhost:5173,http://localhost:3000'
).split(',')
CORS_ALLOW_CREDENTIALS = True
```

**10. Sessions (for cart):**
```python
SESSION_ENGINE = 'django.contrib.sessions.backends.db'
SESSION_COOKIE_AGE = 86400 * 7
SESSION_COOKIE_SAMESITE = 'Lax'
SESSION_COOKIE_SECURE = not DEBUG
```

**11. Security headers (applied in production):**
```python
if not DEBUG:
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
```

**12. Static files:**
```python
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
```

**13. Google OAuth (social-auth):**
```python
AUTHENTICATION_BACKENDS = [
    'social_core.backends.google.GoogleOAuth2',
    'django.contrib.auth.backends.ModelBackend',
]
SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = os.getenv('GOOGLE_CLIENT_ID', '')
SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = os.getenv('GOOGLE_CLIENT_SECRET', '')
SOCIAL_AUTH_GOOGLE_OAUTH2_SCOPE = ['email', 'profile']
SOCIAL_AUTH_PIPELINE = (
    'social_core.pipeline.social_auth.social_details',
    'social_core.pipeline.social_auth.social_uid',
    'social_core.pipeline.social_auth.auth_allowed',
    'social_core.pipeline.social_auth.social_user',
    'social_core.pipeline.user.get_username',
    'social_core.pipeline.user.create_user',
    'social_core.pipeline.social_auth.associate_user',
    'social_core.pipeline.social_auth.load_extra_data',
    'users.pipeline.save_user_role',           # Custom: assign role=user
    'social_core.pipeline.user.user_details',
)
SOCIAL_AUTH_URL_NAMESPACE = 'social'
LOGIN_URL = '/api/auth/login/'
LOGIN_REDIRECT_URL = '/'
```

**14. ERP + Razorpay:**
```python
ERP_API_URL = os.getenv('ERP_API_URL', 'https://your-erp-api.com/api/orders')
ERP_API_KEY = os.getenv('ERP_API_KEY', '')
RAZORPAY_KEY_ID = os.getenv('RAZORPAY_KEY_ID', '')
RAZORPAY_KEY_SECRET = os.getenv('RAZORPAY_KEY_SECRET', '')
RAZORPAY_WEBHOOK_SECRET = os.getenv('RAZORPAY_WEBHOOK_SECRET', '')
FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:5173')
```

**15. Internationalization:**
```python
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Asia/Kolkata'
USE_I18N = True
USE_TZ = True
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
```

---

## Root URL Config — `core/urls.py`

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('users.urls')),
    path('api/products/', include('products.urls')),
    path('api/cart/', include('cart.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/payment/', include('payments.urls')),
    path('api/discounts/', include('discounts.urls')),
    path('social-auth/', include('social_django.urls', namespace='social')),
]
```

---

## Environment File — `.env.example`

```
# Django Core
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=postgresql://user:password@host/dbname

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:5173

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Razorpay
RAZORPAY_KEY_ID=rzp_test_XXXXX
RAZORPAY_KEY_SECRET=your-razorpay-secret
RAZORPAY_WEBHOOK_SECRET=your-webhook-secret

# ERP Integration
ERP_API_URL=https://your-erp.com/api/orders
ERP_API_KEY=your-erp-api-key

# Frontend (for OAuth redirect)
FRONTEND_URL=http://localhost:5173
```

---

## ERP Stub — `services/erp.py`

Write the full ERP service with proper error handling. See `doc.md` Section 5.7 for the full specification. Key rules:
- Never raise exceptions to caller
- 10-second HTTP timeout
- On `ConnectionError`: return simulated ID `ERP-SIM-{order_id}` (dev only when `DEBUG=True`)
- On `Timeout` or `HTTPError`: return `None`, log error
- Log all outcomes (success and failure)

---

## Procfile

```
web: gunicorn core.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 60
```

---

## Acceptance Criteria

After running this setup:
```bash
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

- [ ] Server starts at `http://127.0.0.1:8000` with no errors
- [ ] Django admin accessible at `/admin/` (after creating superuser)
- [ ] `GET http://127.0.0.1:8000/api/products/` returns `{}` or empty list (no 500 error)
- [ ] All migrations apply cleanly
- [ ] No import errors in settings
