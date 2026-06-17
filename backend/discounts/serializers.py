from rest_framework import serializers
from .models import Discount


class DiscountSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    units_remaining = serializers.SerializerMethodField()
    created_by_email = serializers.CharField(source='created_by.email', read_only=True)

    class Meta:
        model = Discount
        fields = [
            'id', 'product', 'product_name', 'discount_type', 'mode', 'value',
            'min_quantity',
            'count_limit', 'units_sold', 'units_remaining', 'active',
            'starts_at', 'ends_at', 'created_by_email', 'created_at',
        ]
        read_only_fields = ['id', 'units_sold', 'created_at', 'product_name', 'units_remaining']

    def get_units_remaining(self, obj):
        return obj.units_remaining

    def validate_min_quantity(self, value):
        if value < 1:
            raise serializers.ValidationError('min_quantity must be at least 1.')
        return value

    def validate(self, data):
        if data.get('mode') == 'percent':
            if not (0 < data.get('value', 0) <= 100):
                raise serializers.ValidationError({'value': 'Percentage must be between 1 and 100.'})
        if data.get('mode') == 'flat':
            if data.get('value', 0) <= 0:
                raise serializers.ValidationError({'value': 'Flat discount amount must be greater than 0.'})
        return data


class DiscountWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Discount
        fields = [
            'product', 'discount_type', 'mode', 'value',
            'min_quantity', 'count_limit', 'active', 'starts_at', 'ends_at',
        ]

    def validate_min_quantity(self, value):
        if value is None:
            return 1
        if value < 1:
            raise serializers.ValidationError('min_quantity must be at least 1.')
        return value

    def validate(self, data):
        # Merge payload with the existing instance's fields to support partial updates (PATCH)
        instance = self.instance
        product = data.get('product') or (instance.product if instance else None)
        discount_type = data.get('discount_type') or (instance.discount_type if instance else None)
        min_qty = data.get('min_quantity') if 'min_quantity' in data else (instance.min_quantity if instance else 1)
        mode = data.get('mode') or (instance.mode if instance else None)
        value = data.get('value') if 'value' in data else (instance.value if instance else 0)

        # Multiple tiers per (product, type) are now allowed, but each tier
        # must have a distinct min_quantity so the ladder is unambiguous.
        if product and discount_type:
            qs = Discount.objects.filter(
                product=product, discount_type=discount_type, min_quantity=min_qty,
            )
            if instance:
                qs = qs.exclude(pk=instance.pk)
            if qs.exists():
                raise serializers.ValidationError(
                    f'A {discount_type} tier with min_quantity={min_qty} already exists '
                    f'for this product. Use a different min_quantity to add another tier.'
                )

        if mode == 'percent' and not (0 < value <= 100):
            raise serializers.ValidationError({'value': 'Percentage must be between 1 and 100.'})
        if mode == 'flat' and value <= 0:
            raise serializers.ValidationError({'value': 'Flat discount amount must be greater than 0.'})

        return data


class DiscountTierSerializer(serializers.ModelSerializer):
    """Compact representation used inside ProductDetailSerializer.discount_tiers."""
    is_exhausted = serializers.BooleanField(read_only=True)

    class Meta:
        model = Discount
        fields = [
            'id', 'discount_type', 'mode', 'value',
            'min_quantity', 'count_limit', 'units_sold', 'is_exhausted',
            'starts_at', 'ends_at',
        ]
