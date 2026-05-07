from rest_framework import serializers
from .models import Category, Product, ProductMedia
from discounts.services import get_effective_price


class ProductMediaSerializer(serializers.ModelSerializer):
    url = serializers.CharField(read_only=True)

    class Meta:
        model = ProductMedia
        fields = ['id', 'kind', 'url', 'is_primary', 'order', 'alt_text']


class CategorySerializer(serializers.ModelSerializer):
    product_count = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'description', 'product_count']

    def get_product_count(self, obj):
        return obj.products.count()


class DiscountInfoMixin:
    """
    Mixin that adds discount-aware pricing to product serializers.
    Reads the request user's role from the serializer context.
    """

    def _get_pricing(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return obj.price, None, None
        role = getattr(request.user, 'role', 'user')
        return get_effective_price(obj, role)

    def get_effective_price(self, obj):
        price, _, _ = self._get_pricing(obj)
        return str(price)

    def get_discount_applied(self, obj):
        _, discount, _ = self._get_pricing(obj)
        if discount is None:
            return None
        return {
            'mode': discount.mode,
            'value': str(discount.value),
            'type': discount.discount_type,
            'display': f'{discount.value}{"%" if discount.mode == "percent" else "₹"} off'
        }

    def get_discount_units_remaining(self, obj):
        _, _, remaining = self._get_pricing(obj)
        return remaining


class ProductListSerializer(DiscountInfoMixin, serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_slug = serializers.CharField(source='category.slug', read_only=True)
    effective_price = serializers.SerializerMethodField()
    discount_applied = serializers.SerializerMethodField()
    discount_units_remaining = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'price', 'effective_price',
            'discount_applied', 'discount_units_remaining',
            'category', 'category_name', 'category_slug',
            'material', 'color', 'dimensions', 'image_url',
            'stock', 'in_stock', 'is_featured', 'created_at',
        ]


class ProductDetailSerializer(DiscountInfoMixin, serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    effective_price = serializers.SerializerMethodField()
    discount_applied = serializers.SerializerMethodField()
    discount_units_remaining = serializers.SerializerMethodField()
    media = ProductMediaSerializer(many=True, read_only=True)
    primary_image = serializers.SerializerMethodField()

    def get_primary_image(self, obj):
        primary = obj.media.filter(is_primary=True).first() or obj.media.first()
        return primary.url if primary else obj.image_url

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'description', 'price', 'effective_price',
            'discount_applied', 'discount_units_remaining',
            'category', 'material', 'color', 'dimensions', 'image_url',
            'stock', 'in_stock', 'is_featured', 'created_at',
            'media', 'primary_image',
        ]


class ProductWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            'name', 'description', 'price', 'category',
            'material', 'color', 'dimensions', 'image_url', 'stock', 'is_featured',
        ]

    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError('Price must be greater than 0.')
        return value

    def validate_stock(self, value):
        if value < 0:
            raise serializers.ValidationError('Stock cannot be negative.')
        return value
