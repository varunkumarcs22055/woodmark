from rest_framework import serializers

from .models import (
    LoyaltyAccount, LoyaltyTransaction, GiftCard,
    POINT_VALUE, EARN_RATE, REFERRAL_BONUS, MAX_REDEEM_FRACTION,
)


class LoyaltyTransactionSerializer(serializers.ModelSerializer):
    order_id = serializers.CharField(source='order.order_id', read_only=True, default=None)

    class Meta:
        model = LoyaltyTransaction
        fields = ['id', 'kind', 'points', 'balance_after', 'order_id', 'reason', 'created_at']


class LoyaltyAccountSerializer(serializers.ModelSerializer):
    transactions = serializers.SerializerMethodField()
    point_value = serializers.SerializerMethodField()
    earn_rate = serializers.SerializerMethodField()
    max_redeem_fraction = serializers.SerializerMethodField()

    class Meta:
        model = LoyaltyAccount
        fields = ['points_balance', 'lifetime_earned', 'point_value', 'earn_rate',
                  'max_redeem_fraction', 'transactions']

    def get_transactions(self, obj):
        return LoyaltyTransactionSerializer(obj.transactions.all()[:20], many=True).data

    def get_point_value(self, obj):
        return str(POINT_VALUE)

    def get_earn_rate(self, obj):
        return str(EARN_RATE)

    def get_max_redeem_fraction(self, obj):
        return str(MAX_REDEEM_FRACTION)


class GiftCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = GiftCard
        fields = ['code', 'initial_amount', 'balance', 'recipient_email',
                  'message', 'is_active', 'created_at']
        read_only_fields = fields
