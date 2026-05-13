from rest_framework import serializers
from .models import Coupon


class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = Coupon
        fields = [
            'id', 'code', 'description', 'type', 'value',
            'min_subtotal', 'max_discount',
            'max_uses', 'used_count', 'per_user_limit',
            'allowed_role', 'valid_from', 'valid_until',
            'is_active', 'created_at', 'updated_at',
        ]
        read_only_fields = ['used_count', 'created_at', 'updated_at']

    def validate_code(self, value):
        return (value or '').strip().upper()


class CouponValidateSerializer(serializers.Serializer):
    code = serializers.CharField()
    subtotal = serializers.DecimalField(max_digits=12, decimal_places=2)
