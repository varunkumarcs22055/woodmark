"""
Admin CRUD for per-dealer negotiated product prices.

  GET    /api/admin/dealers/<int:dealer_id>/negotiated-prices/
  POST   /api/admin/dealers/<int:dealer_id>/negotiated-prices/
  PATCH  /api/admin/dealers/<int:dealer_id>/negotiated-prices/<int:pk>/
  DELETE /api/admin/dealers/<int:dealer_id>/negotiated-prices/<int:pk>/

The resolver in `dealer_pricing/service.py` already short-circuits to this
override when it exists, so wiring this CRUD makes the database-backed
feature actually usable from the admin UI.
"""
from rest_framework import generics, serializers
from rest_framework.response import Response
from rest_framework.exceptions import NotFound

from users.permissions import IsAdminRole
from users.models import User
from products.models import Product

from .models import NegotiatedPrice, DealerTier
from .serializers import NegotiatedPriceSerializer, DealerTierSerializer


class NegotiatedPriceSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_sku = serializers.CharField(source='product.sku', read_only=True)
    product_mrp = serializers.DecimalField(
        source='product.price', read_only=True, max_digits=10, decimal_places=2,
    )

    class Meta:
        model = NegotiatedPrice
        fields = [
            'id', 'dealer', 'product', 'product_name', 'product_sku', 'product_mrp',
            'agreed_price', 'valid_from', 'valid_until', 'note',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['dealer', 'created_at', 'updated_at']


class _DealerScopedMixin:
    """Common dealer lookup + permission for all negotiated-price endpoints."""
    permission_classes = [IsAdminRole]
    serializer_class = NegotiatedPriceSerializer

    def get_dealer(self):
        dealer_id = self.kwargs.get('dealer_id')
        try:
            return User.objects.get(pk=dealer_id, role='dealer')
        except User.DoesNotExist:
            raise NotFound('Dealer not found.')


class NegotiatedPriceListCreateView(_DealerScopedMixin, generics.ListCreateAPIView):
    def get_queryset(self):
        dealer = self.get_dealer()
        return (NegotiatedPrice.objects
                .filter(dealer=dealer)
                .select_related('product')
                .order_by('product__name'))

    def create(self, request, *args, **kwargs):
        dealer = self.get_dealer()
        product_id = request.data.get('product')
        if not product_id:
            return Response({'product': ['This field is required.']}, status=400)
        if not Product.objects.filter(pk=product_id).exists():
            return Response({'product': ['Product not found.']}, status=400)

        # Upsert — if a row already exists for (dealer, product), update its
        # agreed_price instead of erroring on the unique constraint.
        instance, created = NegotiatedPrice.objects.update_or_create(
            dealer=dealer, product_id=product_id,
            defaults={
                'agreed_price': request.data.get('agreed_price', 0),
                'valid_from': request.data.get('valid_from') or None,
                'valid_until': request.data.get('valid_until') or None,
                'note': (request.data.get('note') or '').strip(),
                'created_by': request.user,
            },
        )
        return Response(
            self.get_serializer(instance).data,
            status=201 if created else 200,
        )


class NegotiatedPriceDetailView(_DealerScopedMixin, generics.RetrieveUpdateDestroyAPIView):
    def get_queryset(self):
        dealer = self.get_dealer()
        return NegotiatedPrice.objects.filter(dealer=dealer).select_related('product')


class DealerTierListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAdminRole]
    serializer_class = DealerTierSerializer
    queryset = DealerTier.objects.all().order_by('sort_order', 'id')


class DealerTierDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAdminRole]
    serializer_class = DealerTierSerializer
    queryset = DealerTier.objects.all()
