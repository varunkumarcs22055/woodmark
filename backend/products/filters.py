"""
Products app — Filters.

django-filter FilterSets for product listing API.
Supports filtering by category, price range, and material.
"""

import django_filters
from .models import Product


class ProductFilter(django_filters.FilterSet):
    """
    Filter products by:
    - category: filter by category slug (e.g., ?category=sofas)
    - price_min / price_max: filter by price range
    - material: filter by material type
    """
    category = django_filters.CharFilter(
        field_name='category__slug',
        lookup_expr='exact',
        label='Category Slug'
    )
    price_min = django_filters.NumberFilter(
        field_name='price',
        lookup_expr='gte',
        label='Minimum Price'
    )
    price_max = django_filters.NumberFilter(
        field_name='price',
        lookup_expr='lte',
        label='Maximum Price'
    )
    material = django_filters.CharFilter(
        field_name='material',
        lookup_expr='exact',
        label='Material'
    )

    class Meta:
        model = Product
        fields = ['category', 'price_min', 'price_max', 'material']
