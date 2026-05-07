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
            'count_limit', 'units_sold', 'units_remaining', 'active',
            'starts_at', 'ends_at', 'created_by_email', 'created_at'
        ]
        read_only_fields = ['id', 'units_sold', 'created_at', 'product_name', 'units_remaining']

    def get_units_remaining(self, obj):
        return obj.units_remaining

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
        fields = ['product', 'discount_type', 'mode', 'value', 'count_limit', 'active', 'starts_at', 'ends_at']

    def validate(self, data):
        product = data.get('product')
        discount_type = data.get('discount_type')
        if product and discount_type:
            qs = Discount.objects.filter(product=product, discount_type=discount_type)
            if self.instance:
                qs = qs.exclude(pk=self.instance.pk)
            if qs.exists():
                raise serializers.ValidationError(
                    f'A {discount_type} discount already exists for this product. Deactivate it first.'
                )
        return data
