"""
Single round-trip dashboard payload for the admin Overview page.

  GET /api/admin/dashboard/    (cached 60s)

Returns:
  {
    "totals": {orders, revenue, customers, products, low_stock_count, pending_orders, pending_dealers, failed_erp},
    "revenue_timeseries": [{date, revenue, orders}, ...],     # last 30 days
    "sales_by_category":   [{category, revenue}, ...],         # top 8
    "recent_orders":       [...],
    "low_stock":           [...]
  }
"""
from datetime import timedelta, timezone as dt_timezone
from decimal import Decimal

from django.core.cache import cache
from django.db.models import Sum, Count, F, Q
from django.db.models.functions import TruncDate
from django.utils import timezone
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAdminUser
from orders.models import Order, OrderItem
from products.models import Product
from users.models import User


CACHE_KEY = 'admin:dashboard:v1'
CACHE_TTL = 60


def _build_payload():
    now = timezone.now()
    thirty_days_ago = now - timedelta(days=30)

    paid_orders_qs = Order.objects.filter(payment_status='SUCCESS')

    totals = {
        'orders': Order.objects.count(),
        'revenue': str(paid_orders_qs.aggregate(s=Sum('total_amount'))['s'] or Decimal('0')),
        'customers': User.objects.filter(role='user').count(),
        'products': Product.objects.count(),
        'low_stock_count': Product.objects.filter(stock__lte=5).count(),
        'pending_orders': Order.objects.filter(order_status='CREATED').count(),
        'pending_dealers': User.objects.filter(role='dealer', dealer_status='pending').count(),
        'failed_erp': Order.objects.filter(erp_sync_status='failed').count(),
    }

    # tzinfo=UTC avoids CONVERT_TZ at the SQL layer, which fails on shared
    # MariaDB hosts (GoDaddy) that don't have the mysql.time_zone_name tables.
    revenue_series = list(
        paid_orders_qs.filter(created_at__gte=thirty_days_ago)
        .annotate(date=TruncDate('created_at', tzinfo=dt_timezone.utc))
        .values('date')
        .annotate(revenue=Sum('total_amount'), orders=Count('id'))
        .order_by('date')
    )
    for row in revenue_series:
        row['revenue'] = str(row['revenue'] or Decimal('0'))
        row['date'] = row['date'].isoformat()

    sales_by_category = list(
        OrderItem.objects.filter(order__payment_status='SUCCESS')
        .values('product__category__name')
        .annotate(revenue=Sum(F('price') * F('quantity')))
        .order_by('-revenue')[:8]
    )
    sales_by_category = [
        {'category': row['product__category__name'] or '—',
         'revenue': str(row['revenue'] or Decimal('0'))}
        for row in sales_by_category
    ]

    recent_orders = list(
        Order.objects.order_by('-created_at')
        .values('id', 'order_id', 'user_name', 'user_email',
                'total_amount', 'order_status', 'payment_status', 'created_at')[:5]
    )
    for row in recent_orders:
        row['total_amount'] = str(row['total_amount'])

    low_stock = list(
        Product.objects.filter(stock__lte=5).select_related('category')
        .order_by('stock')
        .values('id', 'name', 'sku', 'stock', 'category__name')[:5]
    )
    low_stock = [
        {**row, 'category_name': row.pop('category__name', None)}
        for row in low_stock
    ]

    return {
        'totals': totals,
        'revenue_timeseries': revenue_series,
        'sales_by_category': sales_by_category,
        'recent_orders': recent_orders,
        'low_stock': low_stock,
        'generated_at': now.isoformat(),
    }


class AdminDashboardView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        payload = cache.get(CACHE_KEY)
        if payload is None:
            payload = _build_payload()
            cache.set(CACHE_KEY, payload, CACHE_TTL)
        return Response(payload)
