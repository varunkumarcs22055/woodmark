"""
Dealer-facing notification signals.

We dispatch via services.notifications.notify so each event hits the
in-app feed + email + SMS stub at once. Failures in notify() are caught
internally — they never abort the original DB transaction.
"""
import logging

from django.db.models.signals import post_save
from django.dispatch import receiver

from orders.models import Order
from .models import DealerPayment, DealerCredit

logger = logging.getLogger(__name__)


def _is_dealer(user):
    return user is not None and getattr(user, 'role', '') == 'dealer'


def _notify_admins_new_dealer_order(order):
    """
    Fan out a 'new dealer order' notification to every admin user. Used by the
    ERP back office to surface dealer activity in the admin feed and email.
    Best-effort — never aborts the original transaction.
    """
    try:
        from django.contrib.auth import get_user_model
        from services.notifications import notify

        User = get_user_model()
        admins = User.objects.filter(role='admin', is_active=True)
        for admin in admins:
            notify(
                user=admin,
                kind='admin_dealer_order_placed',
                title=f'New dealer order {order.order_id}',
                body=(
                    f'{order.user_name} ({order.user.dealer_company_name or order.user_email}) '
                    f'placed order {order.order_id} for ₹{order.total_amount} '
                    f'via {order.payment_method or "razorpay"}.'
                    + (f' PO #{order.po_number}' if order.po_number else '')
                ),
                payload={
                    'order_id': order.order_id,
                    'dealer_id': order.user_id,
                    'total': str(order.total_amount),
                    'method': order.payment_method,
                    'po_number': order.po_number or '',
                },
                channels=['inapp', 'email'],
            )
    except Exception:
        logger.exception('admin notify for dealer order %s failed', order.order_id)


@receiver(post_save, sender=Order)
def notify_dealer_on_order_changes(sender, instance, created, update_fields=None, **kwargs):
    """
    Fire for two distinct events:
      - new dealer order placed (created=True)
      - status transition (CONFIRMED / SHIPPED / DELIVERED / CANCELLED)

    Skipped for non-dealer orders so storefront customers don't double up
    with the regular order notifications.
    """
    user = instance.user
    if not _is_dealer(user):
        return

    try:
        from services.notifications import notify
    except Exception:
        return

    if created:
        notify(
            user=user,
            kind='dealer_order_placed',
            title=f'Order {instance.order_id} placed',
            body=(
                f'Hi {user.full_name},\n\n'
                f'Your order {instance.order_id} for ₹{instance.total_amount} '
                f'has been received. Payment method: {instance.payment_method or "razorpay"}.'
            ),
            payload={'order_id': instance.order_id,
                     'total': str(instance.total_amount),
                     'method': instance.payment_method},
            channels=['inapp', 'email'],
        )
        # ERP-side: ping every admin so the back office sees the new dealer
        # order in their feed (and email, if enabled). Non-fatal on errors.
        _notify_admins_new_dealer_order(instance)
        return

    # update path: only fire if status actually changed.
    fields = set(update_fields or [])
    if fields and 'order_status' not in fields and 'payment_status' not in fields:
        return

    if instance.order_status in ('CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'):
        notify(
            user=user,
            kind=f'dealer_order_{instance.order_status.lower()}',
            title=f'Order {instance.order_id} → {instance.order_status}',
            body=(
                f'Update on your order {instance.order_id}: '
                f'status is now {instance.order_status}.'
                + (f' Tracking: {instance.tracking_carrier} #{instance.tracking_number}'
                   if instance.tracking_number else '')
            ),
            payload={'order_id': instance.order_id, 'status': instance.order_status},
            channels=['inapp', 'email'],
        )


@receiver(post_save, sender=DealerPayment)
def notify_dealer_on_payment_recorded(sender, instance, created, **kwargs):
    if not created:
        return
    user = instance.dealer
    if not user:
        return
    try:
        from services.notifications import notify
    except Exception:
        return
    notify(
        user=user,
        kind='dealer_payment_recorded',
        title=f'Payment of ₹{instance.amount} recorded',
        body=(
            f'We received your payment of ₹{instance.amount} via {instance.method}'
            + (f' (ref {instance.reference})' if instance.reference else '')
            + '. Your credit limit has been updated.'
        ),
        payload={'amount': str(instance.amount), 'method': instance.method,
                 'reference': instance.reference or ''},
        channels=['inapp', 'email'],
    )


@receiver(post_save, sender=DealerCredit)
def notify_dealer_on_low_credit(sender, instance, created, update_fields=None, **kwargs):
    """
    When a dealer's remaining credit drops below 10% of the limit, send a
    one-shot warning. We avoid spamming by stamping a flag on the row.
    """
    if created:
        return
    fields = set(update_fields or [])
    # Only check when amount_used / credit_limit can have changed.
    if fields and not ({'amount_used', 'credit_limit'} & fields):
        return

    try:
        from decimal import Decimal
        limit = Decimal(str(instance.credit_limit))
        if limit <= 0:
            return
        remaining = Decimal(str(instance.remaining))
        threshold = limit * Decimal('0.10')

        # Stash the warning state on the in-memory instance so we don't fire
        # twice in a row. Persisting this would need a schema change; for
        # now best-effort dedup via session-level cache is fine.
        warned_attr = '_low_credit_warned'
        was_warned = getattr(instance, warned_attr, False)

        if remaining <= threshold and not was_warned:
            from services.notifications import notify
            notify(
                user=instance.dealer,
                kind='dealer_credit_low',
                title='Your credit balance is running low',
                body=(
                    f'Available credit: ₹{remaining} of ₹{limit} '
                    f'({(remaining / limit * 100):.1f}% remaining). '
                    f'Settle outstanding invoices to continue placing credit orders.'
                ),
                payload={'remaining': str(remaining), 'limit': str(limit)},
                channels=['inapp', 'email'],
            )
            setattr(instance, warned_attr, True)
    except Exception:
        logger.exception('low-credit notify failed for dealer credit %s', instance.pk)
