from rest_framework import serializers
from .models import ShippingZone


class ShippingZoneSerializer(serializers.ModelSerializer):
    class Meta:
        model = ShippingZone
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']

    def validate_pincode_prefix(self, value):
        v = (value or '').strip()
        if not v.isdigit():
            raise serializers.ValidationError('Pincode prefix must be digits only.')
        if len(v) < 2 or len(v) > 6:
            raise serializers.ValidationError('Pincode prefix must be 2 to 6 digits long.')
        return v

    def validate_name(self, value):
        v = (value or '').strip()
        if not v:
            raise serializers.ValidationError('Name is required.')
        return v


class EstimateSerializer(serializers.Serializer):
    pincode = serializers.CharField(min_length=6, max_length=6)
    subtotal = serializers.DecimalField(max_digits=12, decimal_places=2, required=False, default=0)
    weight_grams = serializers.IntegerField(required=False, default=0, min_value=0)
    prefer_cod = serializers.BooleanField(required=False, default=False)
