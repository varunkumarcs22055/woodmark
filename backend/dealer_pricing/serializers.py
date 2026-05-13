from rest_framework import serializers
from .models import DealerTier, NegotiatedPrice


class DealerTierSerializer(serializers.ModelSerializer):
    class Meta:
        model = DealerTier
        fields = ['id', 'slug', 'name', 'default_discount_pct', 'sort_order',
                  'is_active', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']


class NegotiatedPriceSerializer(serializers.ModelSerializer):
    """Per-(dealer, product) price override with optional validity window."""
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_sku = serializers.CharField(source='product.sku', read_only=True)
    dealer_email = serializers.CharField(source='dealer.email', read_only=True)
    is_currently_valid = serializers.SerializerMethodField()

    class Meta:
        model = NegotiatedPrice
        fields = [
            'id', 'dealer', 'dealer_email', 'product', 'product_name', 'product_sku',
            'agreed_price', 'valid_from', 'valid_until', 'note',
            'is_currently_valid', 'created_at', 'updated_at',
        ]
        read_only_fields = ['product_name', 'product_sku', 'dealer_email',
                            'is_currently_valid', 'created_at', 'updated_at']

    def get_is_currently_valid(self, obj):
        return bool(obj.is_currently_valid())
