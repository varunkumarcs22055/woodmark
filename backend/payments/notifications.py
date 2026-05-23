"""
Transactional emails for the payment / order lifecycle.

Two public functions:

  - send_order_confirmation_email(order):
      Fired on (a) Razorpay payment.captured and (b) COD order placement.
      Subject + body adapt to payment_method.

  - send_order_status_email(order, *, new_status):
      Fired when admin marks an order SHIPPED / DELIVERED / CANCELLED.

Both functions are idempotent at the caller level — callers should check
`order.confirmation_email_sent_at` (or similar) and skip if already sent.
Network failures NEVER bubble: they are logged and swallowed so a flaky
Brevo never crashes the checkout request.

Channel: django.core.mail.EmailMultiAlternatives — when BREVO_API_KEY is
set in env, `core.settings` switches EmailBackend to anymail's Brevo
HTTP backend automatically. Otherwise the message logs to console
(useful in dev without exposing the key).
"""
from __future__ import annotations

import logging
from decimal import Decimal

from django.conf import settings
from django.core.mail import EmailMultiAlternatives
from django.utils.html import escape

logger = logging.getLogger(__name__)


def _fmt_money(amount) -> str:
    if amount is None:
        return '-'
    try:
        n = Decimal(amount)
    except Exception:
        return str(amount)
    return f'Rs. {n:,.2f}'


def _order_items(order):
    """Yield (name, qty, line_total) for each line. Tolerates missing FKs."""
    items_qs = getattr(order, 'items', None)
    if not items_qs:
        return []
    rows = []
    for it in items_qs.all():
        try:
            name = getattr(getattr(it, 'product', None), 'name', None) or it.product_snapshot.get('name', 'Item')
        except Exception:
            name = 'Item'
        qty = getattr(it, 'quantity', 1)
        line = getattr(it, 'line_total', None)
        if line is None:
            unit = getattr(it, 'unit_price', 0) or 0
            line = Decimal(unit) * qty
        rows.append((name, qty, line))
    return rows


def _build_html(order, *, paid: bool) -> str:
    rows_html = ''.join(
        f'<tr>'
        f'<td style="padding:10px 8px;border-bottom:1px solid #eee">{escape(str(name))}</td>'
        f'<td style="padding:10px 8px;border-bottom:1px solid #eee;text-align:center">{int(qty)}</td>'
        f'<td style="padding:10px 8px;border-bottom:1px solid #eee;text-align:right">{_fmt_money(line)}</td>'
        f'</tr>'
        for (name, qty, line) in _order_items(order)
    )
    method_label = 'Razorpay (Paid Online)' if paid else 'Cash on Delivery'
    badge_bg = '#00736A' if paid else '#C77900'
    badge_text = 'PAYMENT RECEIVED' if paid else 'COD CONFIRMED'
    site_url = getattr(settings, 'SITE_URL', 'http://localhost:5174')
    track_url = f"{site_url.rstrip('/')}/orders"

    return f"""
<!doctype html>
<html><body style="margin:0;padding:0;background:#f6f6f4;font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif;color:#222">
  <div style="max-width:560px;margin:24px auto;background:#fff;border-radius:8px;overflow:hidden;border:1px solid #e8e8e3">
    <div style="background:#00736A;color:#fff;padding:20px 24px">
      <div style="font-size:20px;font-weight:700">FurnoTech</div>
      <div style="opacity:.85;font-size:13px;margin-top:2px">Order #{escape(order.order_id)}</div>
    </div>
    <div style="padding:24px">
      <div style="display:inline-block;background:{badge_bg};color:#fff;font-size:11px;font-weight:700;letter-spacing:.08em;padding:5px 10px;border-radius:999px;margin-bottom:14px">
        {badge_text}
      </div>
      <p style="margin:0 0 14px;line-height:1.55">
        Hi {escape(order.user_name or 'there')}, thanks for your order. We've recorded it and you'll
        get another email when it ships.
      </p>

      <table style="width:100%;border-collapse:collapse;font-size:14px;margin:16px 0">
        <thead><tr style="background:#fafaf6">
          <th style="text-align:left;padding:10px 8px;border-bottom:1px solid #eee">Item</th>
          <th style="padding:10px 8px;border-bottom:1px solid #eee;width:60px">Qty</th>
          <th style="text-align:right;padding:10px 8px;border-bottom:1px solid #eee;width:120px">Total</th>
        </tr></thead>
        <tbody>{rows_html}</tbody>
      </table>

      <table style="width:100%;font-size:14px;margin-top:8px">
        <tr><td style="padding:4px 0;color:#666">Payment method</td>
            <td style="padding:4px 0;text-align:right">{method_label}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Order total</td>
            <td style="padding:4px 0;text-align:right;font-weight:700">{_fmt_money(order.total_amount)}</td></tr>
      </table>

      <div style="margin:22px 0 0;text-align:center">
        <a href="{track_url}" style="display:inline-block;background:#00736A;color:#fff;text-decoration:none;padding:11px 22px;border-radius:6px;font-weight:600;font-size:14px">
          Track Your Order
        </a>
      </div>

      <p style="font-size:12px;color:#888;margin:20px 0 0;line-height:1.5">
        Need help? Reply to this email or write to support@furnishop.in.
        Shipping address on file: {escape(getattr(order, 'shipping_address', '') or 'as confirmed at checkout')}.
      </p>
    </div>
  </div>
</body></html>
"""


def _build_text(order, *, paid: bool) -> str:
    method_label = 'Razorpay (Paid)' if paid else 'Cash on Delivery'
    lines = [
        f'Hi {order.user_name or "there"},',
        '',
        f'Thanks for your order. Order #{order.order_id} has been confirmed.',
        '',
        'Items:',
    ]
    for name, qty, line in _order_items(order):
        lines.append(f'  - {name} x {qty}  {_fmt_money(line)}')
    lines += [
        '',
        f'Payment method: {method_label}',
        f'Total: {_fmt_money(order.total_amount)}',
        '',
        f'Track: {settings.SITE_URL.rstrip("/")}/orders',
        '',
        '— FurnoTech',
    ]
    return '\n'.join(lines)


def send_order_confirmation_sms(order) -> bool:
    """
    Fire a short transactional SMS confirming the order. Used for both
    Razorpay-paid orders and COD placements. Stub provider just logs in
    dev — switches to MSG91 the moment MSG91_AUTH_KEY is set in env.

    Idempotency: caller should guard on Payment.sms_sent_at so a webhook
    retry doesn't double-send.
    """
    phone = getattr(order, 'phone', None)
    if not phone:
        return False
    from sms_campaigns.services import send_transactional_sms
    paid = (getattr(order, 'payment_status', '') == 'SUCCESS')
    method_label = 'paid' if paid else 'COD'
    msg = (f'FurnoTech: Order {order.order_id} confirmed ({method_label}). '
           f'Total Rs.{order.total_amount}. Track at '
           f'{settings.SITE_URL.rstrip("/")}/orders')
    result = send_transactional_sms(phone, msg, name=order.user_name or '')
    return result.get('status') == 'sent'


def send_order_confirmation_email(order) -> bool:
    """
    Send the confirmation email. Returns True on success, False otherwise.
    Caller decides whether to mark `confirmation_email_sent_at` on order.
    """
    if not getattr(order, 'user_email', None):
        return False

    paid = (getattr(order, 'payment_status', '') == 'SUCCESS')
    subject_tail = 'Payment Received' if paid else 'Cash on Delivery'
    subject = f'Order Confirmed - {order.order_id} ({subject_tail})'

    try:
        msg = EmailMultiAlternatives(
            subject=subject,
            body=_build_text(order, paid=paid),
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[order.user_email],
        )
        msg.attach_alternative(_build_html(order, paid=paid), 'text/html')
        msg.send(fail_silently=False)
        logger.info('Order confirmation email sent for %s -> %s',
                    order.order_id, order.user_email)
        return True
    except Exception:
        logger.exception('Order confirmation email FAILED for %s', order.order_id)
        return False


def send_order_status_email(order, *, new_status: str) -> bool:
    """Lightweight status-change email (SHIPPED / DELIVERED / CANCELLED)."""
    if not getattr(order, 'user_email', None):
        return False
    status_label = (new_status or '').upper()
    subject = f'Order {order.order_id} - {status_label.title()}'
    body = (
        f'Hi {order.user_name or "there"},\n\n'
        f'Update on order #{order.order_id}: status is now {status_label}.\n\n'
        f'Track: {settings.SITE_URL.rstrip("/")}/orders\n\n'
        f'— FurnoTech'
    )
    try:
        msg = EmailMultiAlternatives(
            subject=subject, body=body,
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[order.user_email],
        )
        msg.send(fail_silently=False)
        return True
    except Exception:
        logger.exception('Order status email FAILED for %s', order.order_id)
        return False
