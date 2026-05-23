
"""
Django settings for FurnoTech e-commerce project.

Configured for:
- Neon PostgreSQL via DATABASE_URL
- Django REST Framework with pagination & filtering
- CORS for React frontend
- Session-based cart support
"""

import os
from pathlib import Path
from datetime import timedelta
from dotenv import load_dotenv
import dj_database_url

# Load environment variables from .env file
load_dotenv()

# Build paths inside the project
BASE_DIR = Path(__file__).resolve().parent.parent

# Security settings
SECRET_KEY = os.getenv('SECRET_KEY', 'django-insecure-change-me-in-production')
DEBUG = os.getenv('DEBUG', 'True').lower() in ('true', '1', 'yes')
ALLOWED_HOSTS = [h.strip() for h in os.getenv(
    'ALLOWED_HOSTS', 'localhost,127.0.0.1'
).split(',') if h.strip()]

# Render injects RENDER_EXTERNAL_HOSTNAME at runtime; auto-allow it so the
# admin never has to remember to update ALLOWED_HOSTS when Render renames a
# service. Same trick most Render-deployed Django apps use.
_render_host = os.getenv('RENDER_EXTERNAL_HOSTNAME')
if _render_host and _render_host not in ALLOWED_HOSTS:
    ALLOWED_HOSTS.append(_render_host)

# ---------------------------------------------------------------------------
# Application definition
# ---------------------------------------------------------------------------
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

    # Cloudinary
    'cloudinary',
    'cloudinary_storage',

    # Transactional email via Brevo (formerly Sendinblue)
    'anymail',

    # Local apps
    'users',
    'products',
    'cart',
    'orders',
    'payments',
    'discounts',
    'store_settings',
    'audit',
    'inventory',
    'cms',
    'notifications',
    'media_lib',
    'invoices',
    'reviews',
    'wishlist',
    'dealer_pricing',
    'dealer_credit',
    'coupons',
    'shipping',
    'dealer_wallet',
    'support',
    'sms_campaigns',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    # WhiteNoise serves Django admin static assets in production (after
    # collectstatic). Must come right after SecurityMiddleware.
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',          # CORS — must be before CommonMiddleware
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'social_django.middleware.SocialAuthExceptionMiddleware',
]

ROOT_URLCONF = 'core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'core.wsgi.application'

# ---------------------------------------------------------------------------
# Database — Neon PostgreSQL
# Falls back to SQLite for local development if DATABASE_URL is not set
# ---------------------------------------------------------------------------
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
    # Fallback to SQLite for local development without Neon
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# Shared-hosting MariaDB (GoDaddy) does NOT have the `mysql.time_zone_name`
# tables loaded. When Django uses `TruncMonth` / `TruncDate` / etc. with
# `USE_TZ = True` and a named application TIME_ZONE different from the
# connection timezone, the driver tries to do `CONVERT_TZ(... 'UTC' ...)`
# and MySQL returns NULL → Django raises:
#   "Database returned an invalid datetime value. Are time zone definitions
#    for your database installed?"
#
# We tell Django the DB stores UTC for every MySQL/MariaDB connection so it
# skips the named-timezone conversion at the SQL layer. Application code
# still receives tz-aware datetimes (since USE_TZ stays True) and the
# frontend renders in the user's local time. No data is rewritten.
if DATABASES['default'].get('ENGINE', '').endswith('mysql'):
    DATABASES['default']['TIME_ZONE'] = 'UTC'
    opts = DATABASES['default'].setdefault('OPTIONS', {})
    opts.setdefault('init_command',
                    "SET sql_mode='STRICT_TRANS_TABLES', time_zone='+00:00'")

# ---------------------------------------------------------------------------
# Password validation
# ---------------------------------------------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ---------------------------------------------------------------------------
# Internationalization
# ---------------------------------------------------------------------------
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Asia/Kolkata'
USE_I18N = True
USE_TZ = True

# ---------------------------------------------------------------------------
# Static files (served by WhiteNoise in prod, by Django dev server locally)
# ---------------------------------------------------------------------------
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Compressed manifest storage — Django picks the right file when collectstatic
# fingerprints assets, and WhiteNoise serves them with long cache headers.
#
# Media files (ImageField / FileField) go to Cloudinary when credentials are
# configured (CLOUDINARY_CLOUD_NAME set), so admin-uploaded product photos
# and customer-uploaded review images survive every redeploy and are served
# from a global CDN. Falls back to local FileSystemStorage during dev when
# no credentials are present, so `manage.py runserver` works offline.
_use_cloudinary = bool(os.getenv('CLOUDINARY_CLOUD_NAME'))
STORAGES = {
    'default': {
        'BACKEND': 'cloudinary_storage.storage.MediaCloudinaryStorage'
                   if _use_cloudinary else
                   'django.core.files.storage.FileSystemStorage',
    },
    'staticfiles': {
        'BACKEND': 'whitenoise.storage.CompressedManifestStaticFilesStorage',
    },
}
# Legacy alias some 3rd-party Django apps still reference instead of STORAGES.
if _use_cloudinary:
    DEFAULT_FILE_STORAGE = 'cloudinary_storage.storage.MediaCloudinaryStorage'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom user model
AUTH_USER_MODEL = 'users.User'

# ---------------------------------------------------------------------------
# Django REST Framework
# ---------------------------------------------------------------------------
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

SIMPLE_JWT = {
    # Access: short window so a compromised access token can't be used long.
    # Refresh: 30 days so closing the browser overnight (or for the weekend)
    # doesn't force a re-login. Combined with ROTATE_REFRESH_TOKENS, every
    # successful refresh extends the session another 30 days — the user only
    # gets logged out if they actually idle for 30 days OR click Sign Out.
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'UPDATE_LAST_LOGIN': True,
}

# ---------------------------------------------------------------------------
# CORS Configuration
# ---------------------------------------------------------------------------
CORS_ALLOWED_ORIGINS = [o.strip() for o in os.getenv(
    'CORS_ALLOWED_ORIGINS', 'http://localhost:5173,http://127.0.0.1:5173'
).split(',') if o.strip()]

# Vercel issues a fresh *-<hash>-<team>.vercel.app preview URL on every PR.
# Allow any *.vercel.app origin so previews work without re-deploying the
# backend. Production custom domain (when added) goes into CORS_ALLOWED_ORIGINS.
CORS_ALLOWED_ORIGIN_REGEXES = [
    r'^https://.+\.vercel\.app$',
]

CORS_ALLOW_CREDENTIALS = True  # Allow cookies/sessions for cart

# CSRF must trust the frontend's origin for any cookie-bearing POSTs (admin).
CSRF_TRUSTED_ORIGINS = [o for o in CORS_ALLOWED_ORIGINS if o.startswith('http')]
if _render_host:
    CSRF_TRUSTED_ORIGINS.append(f'https://{_render_host}')

# ---------------------------------------------------------------------------
# Production hardening — kicks in only when DEBUG=False
# ---------------------------------------------------------------------------
if not DEBUG:
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = 60 * 60 * 24 * 30   # 30 days
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_REFERRER_POLICY = 'same-origin'
    X_FRAME_OPTIONS = 'DENY'

# ---------------------------------------------------------------------------
# Session configuration (for session-based cart)
# ---------------------------------------------------------------------------
SESSION_ENGINE = 'django.contrib.sessions.backends.db'
SESSION_COOKIE_AGE = 86400 * 7  # 7 days
SESSION_COOKIE_SAMESITE = 'Lax'
SESSION_COOKIE_SECURE = not DEBUG

if not DEBUG:
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True

# ---------------------------------------------------------------------------
# Google OAuth
# ---------------------------------------------------------------------------
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
    'users.pipeline.save_user_role',
    'users.pipeline.issue_jwt_and_redirect',
)
SOCIAL_AUTH_URL_NAMESPACE = 'social'
LOGIN_URL = '/api/auth/login/'
LOGIN_REDIRECT_URL = '/'
FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:5173')

# ---------------------------------------------------------------------------
# Email
# ---------------------------------------------------------------------------
# When SMTP isn't configured (dev / first deploy), use the console backend.
# The default backend is SMTP on localhost:25, which blocks for ~30s when no
# mail server is reachable — long enough to trip the frontend's 15s axios
# timeout during order creation (which fires admin low-stock notifications).
# When BREVO_API_KEY is set we route through django-anymail's Brevo backend
# (HTTP API — faster + tracked in dashboard). Otherwise fall back to whatever
# EMAIL_BACKEND env var says, defaulting to console (dev). This means the
# order/payment flow always has a working email path without crashing if
# Brevo creds aren't yet pasted in.
BREVO_API_KEY = os.getenv('BREVO_API_KEY', '')
if BREVO_API_KEY:
    EMAIL_BACKEND = 'anymail.backends.brevo.EmailBackend'
    ANYMAIL = {'BREVO_API_KEY': BREVO_API_KEY}
else:
    EMAIL_BACKEND = os.getenv(
        'EMAIL_BACKEND',
        'django.core.mail.backends.console.EmailBackend',
    )
EMAIL_HOST = os.getenv('EMAIL_HOST', '')
EMAIL_PORT = int(os.getenv('EMAIL_PORT', '587') or 587)
EMAIL_HOST_USER = os.getenv('EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD', '')
EMAIL_USE_TLS = os.getenv('EMAIL_USE_TLS', 'True').lower() in ('true', '1', 'yes')
EMAIL_TIMEOUT = 5  # seconds — never let mail block a request
DEFAULT_FROM_EMAIL = os.getenv('DEFAULT_FROM_EMAIL', 'no-reply@furnishop.local')
SITE_URL = os.getenv('SITE_URL', 'http://localhost:5174')

# ---------------------------------------------------------------------------
# ERP Integration
# ---------------------------------------------------------------------------
ERP_API_URL = os.getenv('ERP_API_URL', 'https://your-erp-api.com/api/orders')
ERP_API_KEY = os.getenv('ERP_API_KEY', '')

# ---------------------------------------------------------------------------
# Razorpay (for future integration)
# ---------------------------------------------------------------------------
RAZORPAY_KEY_ID = os.getenv('RAZORPAY_KEY_ID', '')
RAZORPAY_KEY_SECRET = os.getenv('RAZORPAY_KEY_SECRET', '')
RAZORPAY_WEBHOOK_SECRET = os.getenv('RAZORPAY_WEBHOOK_SECRET', '')

# ---------------------------------------------------------------------------
# Cloudinary — product image + video hosting
# ---------------------------------------------------------------------------
CLOUDINARY_STORAGE = {
    'CLOUD_NAME': os.getenv('CLOUDINARY_CLOUD_NAME', ''),
    'API_KEY': os.getenv('CLOUDINARY_API_KEY', ''),
    'API_SECRET': os.getenv('CLOUDINARY_API_SECRET', ''),
    # Where uploads land in Cloudinary. Keeps Console > Media Library
    # organised when one Cloudinary account is shared across staging/prod.
    'PREFIX': os.getenv('CLOUDINARY_FOLDER', 'furnishop'),
    # Reject anything that isn't an image — extra defence on top of model
    # validators. Override the type list at upload-time if we later need
    # to host PDFs (e.g. invoices) on Cloudinary too.
    'EXCLUDE_DELETE_ORPHANED_MEDIA_PATHS': (),
}
# When credentials are set, STORAGES['default'] above already routes uploads
# to Cloudinary. The block below stays a no-op when CLOUDINARY_CLOUD_NAME is
# blank, so local dev without internet still works.
