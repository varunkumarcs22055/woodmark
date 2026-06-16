"""
Award loyalty points when an order is confirmed, and pay out referral bonuses
on a referee's first confirmed order. All work is idempotent (keyed on the
order) and wrapped so a rewards hiccup never blocks an order save.
"""
import logging
from decimal import Decimal, ROUND_DOWN

from django.db.models.signals import post_save
from django.dispatch import receiver

from orders.models import Order
from .models import (
    LoyaltyAccount, LoyaltyTransaction, Referral,
    EARN_RATE, REFERRAL_BONUS,
)

logger = logging.getLogger(__name__)

EARNING_STATUSES = {'CONFIRMED', 'PACKED', 'SHIPPED', 'DELIVERED'}


@receiver(post_save, sender=Order)
def grant_rewards_on_confirm(sender, instance, **kwargs):
    order = instance
    try:
        if not order.user_id:
            return
        if order.order_status not in EARNING_STATUSES:
            return
        # Loyalty is a retail (B2C) perk; dealers use wallet/credit instead.
        if getattr(order.user, 'role', 'user') == 'dealer':
            return
        # Idempotent: only earn once per order.
        if LoyaltyTransaction.objects.filter(order=order, kind='earn').exists():
            return

        points = int((Decimal(str(order.total_amount)) * EARN_RATE / 100)
                     .to_integral_value(rounding=ROUND_DOWN))
        acc = LoyaltyAccount.for_user(order.user)
        if points > 0:
            acc.earn(points, order=order, reason=f'Order {order.order_id}')

        # Referral payout — referee's first confirmed order.
        ref = Referral.objects.filter(referee=order.user, rewarded=False).first()
        if ref and ref.referrer_id and ref.referrer_id != order.user_id:
            LoyaltyAccount.for_user(ref.referrer).earn(
                REFERRAL_BONUS, reason=f'Referral bonus ({order.user.email})')
            acc.earn(REFERRAL_BONUS, reason='Welcome referral bonus')
            ref.rewarded = True
            ref.save(update_fields=['rewarded'])
    except Exception:  # noqa: BLE001
        logger.exception('rewards: failed to grant for order %s', getattr(order, 'order_id', '?'))
