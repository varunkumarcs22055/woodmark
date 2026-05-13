import django_filters
from .models import Product


class ProductFilter(django_filters.FilterSet):
    category = django_filters.CharFilter(field_name='category__slug', lookup_expr='exact')
    price_min = django_filters.NumberFilter(field_name='price', lookup_expr='gte')
    price_max = django_filters.NumberFilter(field_name='price', lookup_expr='lte')
    material = django_filters.CharFilter(field_name='material', lookup_expr='exact')
    in_stock = django_filters.BooleanFilter(method='filter_in_stock')
    # Tag filter — single slug or comma-separated list (ANY-match semantics so
    # "office,executive" returns products tagged with either).
    tag = django_filters.CharFilter(method='filter_tags')
    tags = django_filters.CharFilter(method='filter_tags')

    class Meta:
        model = Product
        fields = ['category', 'price_min', 'price_max', 'material', 'in_stock', 'tag', 'tags']

    def filter_in_stock(self, queryset, name, value):
        if value:
            return queryset.filter(stock__gt=0)
        return queryset.filter(stock=0)

    def filter_tags(self, queryset, name, value):
        slugs = [s.strip() for s in (value or '').split(',') if s.strip()]
        if not slugs:
            return queryset
        return queryset.filter(tags__slug__in=slugs).distinct()
