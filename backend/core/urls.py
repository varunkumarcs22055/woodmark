"""
Root URL configuration for FurniShop.

All API endpoints are mounted under /api/.
Django admin is available at /admin/.
"""

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    # Django Admin Panel
    path('admin/', admin.site.urls),

    # API endpoints
    path('api/products/', include('products.urls')),
    path('api/cart/', include('cart.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/payment/', include('payments.urls')),
]
