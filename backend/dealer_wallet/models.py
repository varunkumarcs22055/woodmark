"""
DealerWallet — pre-paid balance distinct from credit.

Credit (dealer_credit.DealerCredit) is "I'll pay later, you trust me up to X".
Wallet is "I deposited X up front, deduct from there." Useful when a dealer
wants to lock in a discount campaign by topping up.

A wallet is a singleton per dealer; transactions are append-only.
"""
from decimal import Decimal

from django.conf import settings
from django.db import models, transaction


class DealerWallet(models.Model):
    dealer = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='wallet',
    )
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'dealer_wallets'

    def __str__(self):
        return f'Wallet({self.dealer.email}) ₹{self.balance}'

    @transaction.atomic
    def credit(self, amount, *, reason='', reference='', actor=None):
        amount = Decimal(str(amount))
        if amount <= 0:
            raise ValueError('Credit amount must be > 0.')
        DealerWallet.objects.filter(pk=self.pk).update(balance=models.F('balance') + amount)
        self.refresh_from_db(fields=['balance'])
        return WalletTransaction.objects.create(
            wallet=self, kind='credit', amount=amount,
            balance_after=self.balance, reason=reason, reference=reference,
            actor=actor,
        )

    @transaction.atomic
    def debit(self, amount, *, reason='', reference='', order=None, actor=None):
        amount = Decimal(str(amount))
        if amount <= 0:
            raise ValueError('Debit amount must be > 0.')
        if self.balance < amount:
            raise ValueError(f'Insufficient wallet balance: ₹{self.balance} < ₹{amount}.')
        DealerWallet.objects.filter(pk=self.pk).update(balance=models.F('balance') - amount)
        self.refresh_from_db(fields=['balance'])
        return WalletTransaction.objects.create(
            wallet=self, kind='debit', amount=amount,
            balance_after=self.balance, reason=reason, reference=reference,
            order=order, actor=actor,
        )


class WalletTransaction(models.Model):
    KIND_CHOICES = [('credit', 'Credit (deposit)'), ('debit', 'Debit (spend)')]
    wallet = models.ForeignKey(DealerWallet, on_delete=models.CASCADE, related_name='transactions')
    kind = models.CharField(max_length=8, choices=KIND_CHOICES)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    balance_after = models.DecimalField(max_digits=12, decimal_places=2)
    reason = models.CharField(max_length=200, blank=True)
    reference = models.CharField(max_length=100, blank=True)
    order = models.ForeignKey('orders.Order', null=True, blank=True,
                              on_delete=models.SET_NULL, related_name='wallet_transactions')
    actor = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, blank=True,
                              on_delete=models.SET_NULL, related_name='wallet_actions',
                              help_text='Admin who triggered the credit (if any).')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'wallet_transactions'
        ordering = ['-created_at']
