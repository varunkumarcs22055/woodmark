"""
Root URL configuration for Woodmark.

All API endpoints are mounted under /api/.
Django admin is available at /admin/.
"""

from django.contrib import admin
from django.urls import path, include

from core.admin_views import AdminDashboardView
from core.seo_views import sitemap_xml, robots_txt
from users.admin_views import CustomerListView, CustomerDetailView
from products.admin_category_views import (
    CategoryAdminListView, CategoryAdminDetailView, CategoryTreeView,
)
from dealer_credit.views import (
    AdminDealerCreditView, AdminDealerPaymentRecordView,
)
from dealer_wallet.views import AdminWalletTopupView
from dealer_pricing.views import (
    NegotiatedPriceListCreateView, NegotiatedPriceDetailView,
    DealerTierListCreateView, DealerTierDetailView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('users.urls')),
    path('api/products/', include('products.urls')),
    path('api/cart/', include('cart.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/payment/', include('payments.urls')),
    path('api/discounts/', include('discounts.urls')),
    path('api/settings/', include('store_settings.urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/inventory/', include('inventory.urls')),
    path('api/cms/', include('cms.urls')),
    path('api/invoices/', include('invoices.urls')),
    path('api/reviews/', include('reviews.urls')),
    path('api/wishlist/', include('wishlist.urls')),
    path('api/dealer/', include('dealer_credit.urls')),
    path('api/dealer/wallet/', include('dealer_wallet.urls')),
    path('api/coupons/', include('coupons.urls')),
    path('api/shipping/', include('shipping.urls')),
    path('api/support/', include('support.urls')),
    path('api/audit/', include('audit.urls')),
    path('api/sms/', include('sms_campaigns.urls')),
    path('api/rewards/', include('rewards.urls')),

    # Admin-only consolidated endpoints
    path('api/admin/dashboard/', AdminDashboardView.as_view(), name='admin-dashboard'),
    path('api/admin/customers/', CustomerListView.as_view(), name='admin-customers'),
    path('api/admin/customers/<int:pk>/', CustomerDetailView.as_view(), name='admin-customer-detail'),
    path('api/categories/admin/', CategoryAdminListView.as_view(), name='admin-categories'),
    path('api/categories/admin/<int:pk>/', CategoryAdminDetailView.as_view(), name='admin-category-detail'),
    path('api/categories/tree/', CategoryTreeView.as_view(), name='categories-tree'),
    path('api/admin/dealers/<int:pk>/credit/', AdminDealerCreditView.as_view(), name='admin-dealer-credit'),
    path('api/admin/dealers/<int:pk>/payments/', AdminDealerPaymentRecordView.as_view(), name='admin-dealer-payment'),
    path('api/admin/dealers/<int:pk>/wallet/topup/', AdminWalletTopupView.as_view(), name='admin-dealer-wallet-topup'),
    path('api/admin/dealers/<int:dealer_id>/negotiated-prices/',
         NegotiatedPriceListCreateView.as_view(), name='admin-dealer-negotiated-list'),
    path('api/admin/dealers/<int:dealer_id>/negotiated-prices/<int:pk>/',
         NegotiatedPriceDetailView.as_view(), name='admin-dealer-negotiated-detail'),
    path('api/admin/dealers/tiers/', DealerTierListCreateView.as_view(), name='admin-dealer-tiers'),
    path('api/admin/dealers/tiers/<int:pk>/', DealerTierDetailView.as_view(), name='admin-dealer-tier-detail'),

    path('social-auth/', include('social_django.urls', namespace='social')),

    # SEO surfaces (root paths, no /api/ prefix — crawlers expect them here)
    path('sitemap.xml', sitemap_xml, name='sitemap-xml'),
    path('robots.txt', robots_txt, name='robots-txt'),
]
