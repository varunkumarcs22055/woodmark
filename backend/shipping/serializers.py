from rest_framework import serializers
from .models import ShippingZone


class ShippingZoneSerializer(serializers.ModelSerializer):
    class Meta:
        model = ShippingZone
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']


class EstimateSerializer(serializers.Serializer):
    pincode = serializers.CharField(min_length=6, max_length=6)
    subtotal = serializers.DecimalField(max_digits=12, decimal_places=2, required=False, default=0)
    weight_grams = serializers.IntegerField(required=False, default=0, min_value=0)
    prefer_cod = serializers.BooleanField(required=False, default=False)
