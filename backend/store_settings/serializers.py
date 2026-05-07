from rest_framework import serializers
from .models import StoreSettings


class StoreSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoreSettings
        fields = ['gst_percent', 'free_shipping_threshold', 'standard_shipping_fee', 'updated_at']
        read_only_fields = ['updated_at']
