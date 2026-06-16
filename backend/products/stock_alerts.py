"""
Back-in-stock notifications.

When a product transitions from out-of-stock to in-stock, email everyone who
subscribed via StockAlert and mark those alerts `notified=True` so the next
restock cycle doesn't spam them again. Email failures are swallowed — a
delivery hiccup must never roll back a stock movement.
"""
import logging

from django.conf import settings
from django.core.mail import EmailMultiAlternatives

logger = logging.getLogger(__name__)


def notify_back_in_stock(product_id):
    from .models import Product, StockAlert

    try:
        product = Product.objects.get(pk=product_id)
    except Product.DoesNotExist:
        return
    if (product.stock or 0) <= 0:
        return

    alerts = list(StockAlert.objects.filter(product=product, notified=False))
    if not alerts:
        return

    site = (getattr(settings, 'SITE_URL', '') or '').rstrip('/') or 'https://woodmark.in'
    url = f'{site}/product/{product.slug}'
    from_email = getattr(settings, 'DEFAULT_FROM_EMAIL', 'hello@woodmark.in')
    sent_ids = []

    for alert in alerts:
        to = alert.email
        if not to:
            continue
        try:
            subject = f'{product.name} is back in stock at Woodmark'
            text = (
                f"Good news! {product.name} is available again.\n\n"
                f"View it here: {url}\n\n"
                f"Stock is limited — order soon.\n— Woodmark"
            )
            html = (
                f'<div style="font-family:Arial,sans-serif;max-width:520px;margin:auto">'
                f'<h2 style="color:#2D2E5F">Back in stock 🎉</h2>'
                f'<p><strong>{product.name}</strong> is available again at Woodmark.</p>'
                f'<p><a href="{url}" style="display:inline-block;background:#E47D2A;color:#fff;'
                f'padding:11px 22px;border-radius:8px;text-decoration:none;font-weight:600">'
                f'View product</a></p>'
                f'<p style="color:#6B7280;font-size:13px">Stock is limited — order soon.</p>'
                f'</div>'
            )
            msg = EmailMultiAlternatives(subject, text, from_email, [to])
            msg.attach_alternative(html, 'text/html')
            msg.send(fail_silently=False)
            sent_ids.append(alert.id)
        except Exception as exc:  # noqa: BLE001
            logger.warning('Back-in-stock email failed for %s: %s', to, exc)

    if sent_ids:
        StockAlert.objects.filter(id__in=sent_ids).update(notified=True)
    logger.info('Back-in-stock: notified %d/%d for product %s',
                len(sent_ids), len(alerts), product.slug)
