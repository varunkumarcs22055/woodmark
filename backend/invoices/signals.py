"""
Auto-create an invoice when a paid order arrives or is marked SUCCESS.
"""
from django.db.models.signals import post_save
from django.dispatch import receiver

from orders.models import Order

from .factory import create_invoice_from_order


@receiver(post_save, sender=Order)
def auto_invoice_on_paid_order(sender, instance, created, **kwargs):
    # Only fire on a transition to SUCCESS (Razorpay / COD path). Brand-new
    # orders have no items yet (items are written AFTER Order.objects.create),
    # so creating an invoice here would yield a zero-total row. Credit-method
    # orders are handled by an explicit call from OrderCreateSerializer once
    # the items and stock decrements are committed.
    if created or instance.payment_status != 'SUCCESS':
        return
    try:
        create_invoice_from_order(instance)
    except Exception:  # pragma: no cover — never let invoice errors crash payment flow
        import logging
        logging.getLogger(__name__).exception(
            'Auto-invoice failed for order %s', instance.pk,
        )
