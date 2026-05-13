from rest_framework import serializers
from .models import SupportTicket, TicketMessage


class TicketMessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source='sender.full_name', read_only=True)
    sender_role = serializers.CharField(source='sender.role', read_only=True)

    class Meta:
        model = TicketMessage
        fields = [
            'id', 'sender', 'sender_name', 'sender_role',
            'body', 'is_internal_note', 'attachment_url', 'created_at',
        ]
        read_only_fields = ['sender', 'created_at']


class SupportTicketSerializer(serializers.ModelSerializer):
    messages = TicketMessageSerializer(many=True, read_only=True)
    user_email = serializers.SerializerMethodField()
    user_name = serializers.SerializerMethodField()
    related_order_id = serializers.CharField(source='related_order.order_id', read_only=True)

    def get_user_email(self, obj):
        return obj.user.email if obj.user else obj.guest_email

    def get_user_name(self, obj):
        return obj.user.full_name if obj.user else obj.guest_name

    class Meta:
        model = SupportTicket
        fields = [
            'id', 'ticket_number', 'subject', 'category', 'priority', 'status',
            'user', 'user_email', 'user_name',
            'guest_email', 'guest_name',
            'related_order', 'related_order_id',
            'assigned_to', 'created_at', 'updated_at', 'resolved_at', 'closed_at',
            'messages',
        ]
        read_only_fields = ['ticket_number', 'user', 'status', 'assigned_to',
                            'resolved_at', 'closed_at']


class SupportTicketCreateSerializer(serializers.Serializer):
    subject = serializers.CharField(max_length=200)
    category = serializers.ChoiceField(choices=SupportTicket.CATEGORY_CHOICES, default='other')
    priority = serializers.ChoiceField(choices=SupportTicket.PRIORITY_CHOICES, default='normal')
    related_order = serializers.PrimaryKeyRelatedField(
        queryset=__import__('orders.models', fromlist=['Order']).Order.objects.all(),
        required=False, allow_null=True,
    )
    guest_email = serializers.EmailField(required=False, allow_null=True)
    guest_name = serializers.CharField(required=False, allow_null=True)
    body = serializers.CharField(help_text='First message in the thread.')


class TicketStatusSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=SupportTicket.STATUS_CHOICES)
