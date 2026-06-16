"""
Rewards — loyalty points, referral program, and gift cards.

Design notes
------------
* Points are an integer ledger. 1 point is worth `POINT_VALUE` rupees when
  redeemed (default ₹1). Customers earn `EARN_RATE`% of an order's value back
  as points on confirmation.
* Referral: every account gets a short code. When a new user signs up with a
  code, a Referral row links them. On the referee's first confirmed order both
  sides get `REFERRAL_BONUS` points.
* Gift cards carry a standalone balance, redeemable at checkout. They are not
  tied to a user until redeemed (anyone with the code can spend it).
"""
import secrets
import string
from decimal import Decimal

from django.conf import settings
from django.db import models, transaction

# Tunables (could be promoted to StoreSettings later).
EARN_RATE = Decimal('2')        # earn 2% of order value back as points
POINT_VALUE = Decimal('1')      # 1 point == ₹1 on redemption
REFERRAL_BONUS = 200            # points to referrer AND referee on first order
MAX_REDEEM_FRACTION = Decimal('0.50')  # points can cover at most 50% of a bill


def _gen_code(length, alphabet):
    return ''.join(secrets.choice(alphabet) for _ in range(length))


class LoyaltyAccount(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='loyalty',
    )
    points_balance = models.IntegerField(default=0)
    lifetime_earned = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'loyalty_accounts'

    def __str__(self):
        return f'Loyalty({self.user_id}) {self.points_balance} pts'

    @classmethod
    def for_user(cls, user):
        acc, _ = cls.objects.get_or_create(user=user)
        return acc

    @transaction.atomic
    def earn(self, points, *, order=None, reason=''):
        points = int(points)
        if points <= 0:
            return None
        LoyaltyAccount.objects.filter(pk=self.pk).update(
            points_balance=models.F('points_balance') + points,
            lifetime_earned=models.F('lifetime_earned') + points,
        )
        self.refresh_from_db(fields=['points_balance', 'lifetime_earned'])
        return LoyaltyTransaction.objects.create(
            account=self, kind='earn', points=points,
            balance_after=self.points_balance, order=order, reason=reason,
        )

    @transaction.atomic
    def redeem(self, points, *, order=None, reason=''):
        points = int(points)
        if points <= 0:
            raise ValueError('Redeem amount must be positive.')
        if self.points_balance < points:
            raise ValueError('Insufficient points.')
        LoyaltyAccount.objects.filter(pk=self.pk).update(
            points_balance=models.F('points_balance') - points,
        )
        self.refresh_from_db(fields=['points_balance'])
        return LoyaltyTransaction.objects.create(
            account=self, kind='redeem', points=-points,
            balance_after=self.points_balance, order=order, reason=reason,
        )


class LoyaltyTransaction(models.Model):
    KIND_CHOICES = [('earn', 'Earned'), ('redeem', 'Redeemed'), ('referral', 'Referral bonus')]
    account = models.ForeignKey(LoyaltyAccount, on_delete=models.CASCADE, related_name='transactions')
    kind = models.CharField(max_length=10, choices=KIND_CHOICES)
    points = models.IntegerField(help_text='Positive for credit, negative for debit.')
    balance_after = models.IntegerField()
    order = models.ForeignKey('orders.Order', null=True, blank=True,
                              on_delete=models.SET_NULL, related_name='loyalty_transactions')
    reason = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'loyalty_transactions'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.account_id}: {self.points:+d} ({self.kind})'


class Referral(models.Model):
    code = models.CharField(max_length=12, unique=True, db_index=True)
    referrer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='referrals_made',
    )
    referee = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='referred_by',
        help_text='The user who signed up with this code (one row per referee).',
    )
    rewarded = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'referrals'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.code} by {self.referrer_id} -> {self.referee_id}'

    @staticmethod
    def code_for(user):
        """Return (creating if needed) a stable personal share code for a user.
        Stored as a Referral row with referee=None acting as the user's anchor."""
        anchor = Referral.objects.filter(referrer=user, referee__isnull=True).first()
        if anchor:
            return anchor.code
        alphabet = string.ascii_uppercase + string.digits
        for _ in range(10):
            code = _gen_code(8, alphabet)
            if not Referral.objects.filter(code=code).exists():
                return Referral.objects.create(code=code, referrer=user).code
        # Extremely unlikely collisions — fall back to a longer code.
        return Referral.objects.create(code=_gen_code(12, alphabet), referrer=user).code


class GiftCard(models.Model):
    code = models.CharField(max_length=19, unique=True, db_index=True)
    initial_amount = models.DecimalField(max_digits=10, decimal_places=2)
    balance = models.DecimalField(max_digits=10, decimal_places=2)
    purchaser = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='gift_cards_bought',
    )
    recipient_email = models.EmailField(blank=True)
    message = models.CharField(max_length=240, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'gift_cards'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.code} (₹{self.balance})'

    @staticmethod
    def generate_code():
        alphabet = string.ascii_uppercase + string.digits
        while True:
            raw = _gen_code(16, alphabet)
            code = '-'.join(raw[i:i + 4] for i in range(0, 16, 4))
            if not GiftCard.objects.filter(code=code).exists():
                return code

    @classmethod
    def issue(cls, amount, *, purchaser=None, recipient_email='', message=''):
        amount = Decimal(str(amount))
        return cls.objects.create(
            code=cls.generate_code(), initial_amount=amount, balance=amount,
            purchaser=purchaser, recipient_email=recipient_email, message=message,
        )

    @transaction.atomic
    def redeem(self, amount, *, order=None):
        amount = Decimal(str(amount))
        if amount <= 0:
            raise ValueError('Redeem amount must be positive.')
        if not self.is_active:
            raise ValueError('Gift card is inactive.')
        if self.balance < amount:
            raise ValueError('Insufficient gift card balance.')
        GiftCard.objects.filter(pk=self.pk).update(balance=models.F('balance') - amount)
        self.refresh_from_db(fields=['balance'])
        GiftCardTransaction.objects.create(
            gift_card=self, amount=-amount, balance_after=self.balance, order=order,
        )
        return self.balance


class GiftCardTransaction(models.Model):
    gift_card = models.ForeignKey(GiftCard, on_delete=models.CASCADE, related_name='transactions')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    balance_after = models.DecimalField(max_digits=10, decimal_places=2)
    order = models.ForeignKey('orders.Order', null=True, blank=True,
                              on_delete=models.SET_NULL, related_name='gift_card_transactions')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'gift_card_transactions'
        ordering = ['-created_at']
