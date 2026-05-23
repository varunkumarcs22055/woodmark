import csv
import io
import re

from rest_framework import serializers
from .models import Contact, Campaign, Delivery, normalize_phone


class ContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = Contact
        fields = ['id', 'phone', 'name', 'tag', 'source', 'is_active', 'created_at']
        read_only_fields = ['created_at']

    def validate_phone(self, value):
        normalized = normalize_phone(value)
        digits = re.sub(r'\D', '', normalized)
        if len(digits) < 10:
            raise serializers.ValidationError('Phone number must be at least 10 digits.')
        return normalized


class ContactBulkSerializer(serializers.Serializer):
    """
    Accepts either:
      - `numbers` (string): one number per line, or comma-separated.
      - `csv_file` (file): CSV with columns: phone (required), name, tag.
    Both fields are optional; at least one must be provided.
    """
    numbers = serializers.CharField(required=False, allow_blank=True)
    tag = serializers.CharField(max_length=80, required=False, allow_blank=True)

    def validate_numbers(self, value):
        if not value:
            return []
        # Split by newlines, commas, or semicolons.
        raw = re.split(r'[,;\n]+', value.strip())
        out = []
        for r in raw:
            r = r.strip()
            if not r:
                continue
            n = normalize_phone(r)
            digits = re.sub(r'\D', '', n)
            if len(digits) >= 10:
                out.append(n)
        return out


class CampaignSerializer(serializers.ModelSerializer):
    class Meta:
        model = Campaign
        fields = [
            'id', 'uid', 'name', 'message', 'audience', 'audience_tag',
            'status', 'total_count', 'sent_count', 'failed_count',
            'error_log', 'created_at', 'sent_at',
        ]
        read_only_fields = [
            'uid', 'status', 'total_count', 'sent_count', 'failed_count',
            'error_log', 'created_at', 'sent_at',
        ]


class DeliverySerializer(serializers.ModelSerializer):
    class Meta:
        model = Delivery
        fields = ['id', 'phone', 'name', 'status', 'provider_response', 'sent_at']
