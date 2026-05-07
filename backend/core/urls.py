"""
Root URL configuration for FurniShop.

All API endpoints are mounted under /api/.
Django admin is available at /admin/.
"""

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
    path('api/settings/', include('store_settings.urls')),
    path('social-auth/', include('social_django.urls', namespace='social')),
]
