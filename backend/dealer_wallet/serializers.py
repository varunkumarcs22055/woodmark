from rest_framework import serializers
from .models import DealerWallet, WalletTransaction


class WalletTransactionSerializer(serializers.ModelSerializer):
    actor_email = serializers.CharField(source='actor.email', read_only=True)

    class Meta:
        model = WalletTransaction
        fields = [
            'id', 'kind', 'amount', 'balance_after',
            'reason', 'reference', 'order', 'actor_email', 'created_at',
        ]


class DealerWalletSerializer(serializers.ModelSerializer):
    transactions = serializers.SerializerMethodField()

    class Meta:
        model = DealerWallet
        fields = ['id', 'balance', 'is_active', 'created_at', 'updated_at', 'transactions']

    def get_transactions(self, obj):
        # Limit to the last 50 transactions for performance optimization
        txns = obj.transactions.all()[:50]
        return WalletTransactionSerializer(txns, many=True).data


class WalletTopupSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    reason = serializers.CharField(max_length=200, required=False, allow_blank=True)
    reference = serializers.CharField(max_length=100, required=False, allow_blank=True)
