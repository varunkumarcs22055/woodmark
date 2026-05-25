"""
Transactional emails for the payment / order lifecycle — production-grade.

Public surface:
  - send_order_confirmation_email(order):
      Fired on (a) COD/credit/wallet placement (from OrderCreateView) and
      (b) Razorpay payment.captured (from confirm_order_and_sync_erp).
      Subject + body adapt to payment_method so the buyer immediately sees
      what they owe (or that they're paid up).

  - send_order_status_email(order, *, new_status):
      Fired when admin marks an order SHIPPED / DELIVERED / CANCELLED.

  - send_order_confirmation_sms(order):
      Short transactional SMS — same trigger as the email.

Idempotency: callers guard on `Payment.email_sent_at` / `sms_sent_at`.
Network failures NEVER bubble: logged + swallowed so a flaky Brevo never
crashes the checkout request.

Channel: django.core.mail.EmailMultiAlternatives — when BREVO_API_KEY is
set in env, core.settings switches EmailBackend to anymail's Brevo HTTP
backend automatically. Otherwise the message logs to console (dev).
"""
from __future__ import annotations

import logging
from decimal import Decimal

from django.conf import settings
from django.core.mail import EmailMultiAlternatives
from django.utils.html import escape

logger = logging.getLogger(__name__)


# ── Brand palette ──────────────────────────────────────────────────────
BRAND_NAVY = '#2D2E5F'      # primary indigo (matches FurnoTech wordmark)
BRAND_NAVY_DARK = '#1B1C42'
BRAND_ORANGE = '#E47D2A'    # accent (the "F" mark)
INK = '#111827'
MUTED = '#6B7280'
LINE = '#E5E7EB'
BG_PAGE = '#F6F6F4'
BG_CARD = '#FFFFFF'
SUCCESS = '#0F766E'
WARN = '#B45309'


def _fmt_money(amount) -> str:
    if amount is None:
        return '-'
    try:
        n = Decimal(amount)
    except Exception:
        return str(amount)
    return f'₹{n:,.2f}'   # ₹ rupee sign (most modern email clients render it)


def _order_items(order):
    """Yield (name, qty, line_total) for each line. Tolerates missing FKs."""
    items_qs = getattr(order, 'items', None)
    if not items_qs:
        return []
    rows = []
    for it in items_qs.all():
        try:
            name = (getattr(getattr(it, 'product', None), 'name', None)
                    or (it.product_snapshot or {}).get('name', 'Item'))
        except Exception:
            name = 'Item'
        qty = getattr(it, 'quantity', 1)
        line = getattr(it, 'line_total', None)
        if line is None:
            unit = getattr(it, 'unit_price', 0) or 0
            try:
                line = Decimal(unit) * qty
            except Exception:
                line = 0
        rows.append((name, qty, line))
    return rows


def _payment_context(order):
    """
    Build a payment-method-aware context for the headline strip.
    Returns dict with: state ('paid'|'cod'|'credit'|'wallet'),
        accent (hex), headline, sub, cta_label, cta_url, amount_label.
    """
    method = (getattr(order, 'payment_method', '') or '').lower()
    paid = (getattr(order, 'payment_status', '') == 'SUCCESS')
    site = (getattr(settings, 'SITE_URL', '') or 'https://furnotech.in').rstrip('/')
    track = f'{site}/orders/{order.order_id}'

    if method == 'cod':
        return {
            'state': 'cod',
            'accent': WARN,
            'headline': 'Cash on Delivery — keep this amount ready',
            'sub': "Our delivery partner will collect it when they hand off your order. Cash, UPI, or card swipe accepted on most routes.",
            'amount_label': 'Amount to pay on delivery',
            'amount': _fmt_money(order.total_amount),
            'track_url': track,
        }
    if method == 'credit' and not paid:
        terms = ''
        try:
            from dealer_credit.models import DealerCredit
            credit = DealerCredit.objects.filter(dealer=order.user).first()
            if credit and credit.terms_days:
                terms = f' (Net-{credit.terms_days})'
        except Exception:
            pass
        return {
            'state': 'credit',
            'accent': BRAND_NAVY,
            'headline': f'On credit{terms}',
            'sub': 'A GST invoice is attached to your dealer account. Settle from the Dealer Portal → Invoices when convenient.',
            'amount_label': 'Amount due',
            'amount': _fmt_money(order.total_amount),
            'track_url': track,
        }
    if method == 'wallet':
        balance_after = ''
        try:
            from dealer_wallet.models import DealerWallet
            w = DealerWallet.objects.filter(dealer=order.user).first()
            if w is not None:
                balance_after = f' Wallet balance: {_fmt_money(w.balance)}.'
        except Exception:
            pass
        return {
            'state': 'wallet',
            'accent': SUCCESS,
            'headline': 'Paid from your wallet',
            'sub': f'Order debited against your pre-paid balance.{balance_after}',
            'amount_label': 'Amount debited',
            'amount': _fmt_money(order.total_amount),
            'track_url': track,
        }
    # Razorpay / online paid
    return {
        'state': 'paid',
        'accent': SUCCESS,
        'headline': 'Payment received ✓',
        'sub': 'Your card / UPI / netbanking transaction settled successfully. A GST invoice will be available in your account once dispatched.',
        'amount_label': 'Amount paid',
        'amount': _fmt_money(order.total_amount),
        'track_url': track,
    }


def _build_html(order) -> str:
    ctx = _payment_context(order)

    rows_html = ''.join(
        f'<tr>'
        f'<td style="padding:12px 8px;border-bottom:1px solid {LINE};font-size:14px">{escape(str(name))}</td>'
        f'<td style="padding:12px 8px;border-bottom:1px solid {LINE};text-align:center;font-size:14px;color:{MUTED}">×{int(qty)}</td>'
        f'<td style="padding:12px 8px;border-bottom:1px solid {LINE};text-align:right;font-size:14px;font-weight:600">{_fmt_money(line)}</td>'
        f'</tr>'
        for (name, qty, line) in _order_items(order)
    ) or (
        f'<tr><td colspan="3" style="padding:14px 8px;color:{MUTED};font-style:italic;font-size:14px">'
        f'(item details will appear on the invoice)</td></tr>'
    )

    # Optional GST + shipping line if the order has them.
    extras = []
    sub = getattr(order, 'subtotal_amount', None)
    gst = getattr(order, 'gst_amount', None)
    ship = getattr(order, 'shipping_amount', None)
    coupon = getattr(order, 'coupon_discount', None)
    if sub:
        extras.append(('Subtotal', _fmt_money(sub)))
    if coupon and Decimal(str(coupon or 0)) > 0:
        extras.append((f"Coupon ({getattr(order, 'coupon_code', '') or 'applied'})",
                       f'− {_fmt_money(coupon)}'))
    if gst and Decimal(str(gst or 0)) > 0:
        extras.append(('GST', _fmt_money(gst)))
    if ship is not None:
        extras.append(('Shipping',
                       'Free' if Decimal(str(ship or 0)) == 0 else _fmt_money(ship)))
    extras_html = ''.join(
        f'<tr><td style="padding:4px 0;color:{MUTED};font-size:13px">{escape(lbl)}</td>'
        f'<td style="padding:4px 0;text-align:right;font-size:13px">{escape(val)}</td></tr>'
        for lbl, val in extras
    )

    addr = escape(getattr(order, 'address', '') or 'as confirmed at checkout').replace('\n', '<br/>')
    delivery_days = getattr(order, 'delivery_estimate_days', None) or 7
    customer_greet = escape(order.user_name or 'there')

    return f"""<!doctype html>
<html><body style="margin:0;padding:0;background:{BG_PAGE};font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:{INK}">
  <!-- Pre-header (hidden in inbox preview pane on most clients) -->
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;visibility:hidden;mso-hide:all">
    Order {escape(order.order_id)} confirmed — {ctx['amount_label']}: {ctx['amount']}.
  </div>

  <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" style="background:{BG_PAGE};padding:24px 0">
    <tr><td align="center">
      <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="600" style="max-width:600px;background:{BG_CARD};border-radius:12px;overflow:hidden;border:1px solid {LINE};box-shadow:0 1px 3px rgba(0,0,0,0.04)">

        <!-- Brand header -->
        <tr><td style="background:{BRAND_NAVY};padding:22px 28px;color:#fff">
          <table role="presentation" width="100%"><tr>
            <td style="font-size:22px;font-weight:800;letter-spacing:-0.01em">
              Furno<span style="color:{BRAND_ORANGE}">Tech</span>
            </td>
            <td style="text-align:right;font-size:12px;opacity:0.85">
              Order <strong style="color:#fff">#{escape(order.order_id)}</strong>
            </td>
          </tr></table>
        </td></tr>

        <!-- Hero greeting + payment strip -->
        <tr><td style="padding:28px 28px 8px">
          <p style="margin:0 0 6px;font-size:14px;color:{MUTED}">Thanks for your order,</p>
          <h1 style="margin:0 0 16px;font-size:24px;font-weight:800;letter-spacing:-0.02em;color:{INK}">
            {customer_greet}.
          </h1>

          <!-- Big payment-status callout -->
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:linear-gradient(135deg,#FFFFFF 0%,#FAFAF7 100%);border:1px solid {LINE};border-left:4px solid {ctx['accent']};border-radius:10px;margin:8px 0 20px">
            <tr><td style="padding:18px 20px">
              <div style="font-size:11px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:{ctx['accent']};margin-bottom:6px">
                {escape(ctx['headline'])}
              </div>
              <div style="display:flex;align-items:baseline;gap:10px;margin:4px 0 8px">
                <span style="font-size:12px;color:{MUTED}">{escape(ctx['amount_label'])}:</span>
                <span style="font-size:26px;font-weight:800;color:{INK};letter-spacing:-0.01em">{ctx['amount']}</span>
              </div>
              <div style="font-size:13px;color:{MUTED};line-height:1.5">{escape(ctx['sub'])}</div>
            </td></tr>
          </table>
        </td></tr>

        <!-- Items table -->
        <tr><td style="padding:0 28px">
          <div style="font-size:11px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:{MUTED};margin-bottom:6px">
            Order Summary
          </div>
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
            <thead><tr>
              <th style="text-align:left;padding:10px 8px;border-bottom:2px solid {INK};font-size:11px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:{INK}">Item</th>
              <th style="padding:10px 8px;border-bottom:2px solid {INK};width:60px;font-size:11px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:{INK}">Qty</th>
              <th style="text-align:right;padding:10px 8px;border-bottom:2px solid {INK};width:120px;font-size:11px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:{INK}">Total</th>
            </tr></thead>
            <tbody>{rows_html}</tbody>
          </table>
        </td></tr>

        <!-- Totals -->
        <tr><td style="padding:14px 28px 0">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
            {extras_html}
            <tr><td style="padding:12px 0 4px;border-top:1px solid {LINE};font-size:14px;font-weight:700">Grand Total</td>
                <td style="padding:12px 0 4px;border-top:1px solid {LINE};text-align:right;font-size:18px;font-weight:800;color:{INK}">{_fmt_money(order.total_amount)}</td></tr>
          </table>
        </td></tr>

        <!-- Delivery card -->
        <tr><td style="padding:24px 28px 0">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#FAFAF7;border-radius:10px;border:1px solid {LINE}">
            <tr><td style="padding:14px 16px;font-size:13px;color:{INK};line-height:1.55">
              <div style="font-size:11px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:{MUTED};margin-bottom:4px">Delivering to</div>
              <strong>{escape(order.user_name or '')}</strong><br/>
              {addr}<br/>
              <span style="color:{MUTED};font-size:12px">Phone: {escape(getattr(order, 'phone', '') or '—')}</span>
              <div style="margin-top:8px;color:{MUTED};font-size:12px">
                Estimated arrival in <strong style="color:{INK}">{delivery_days} day{'s' if int(delivery_days) != 1 else ''}</strong> from confirmation.
              </div>
            </td></tr>
          </table>
        </td></tr>

        <!-- CTA -->
        <tr><td style="padding:22px 28px 4px;text-align:center">
          <a href="{ctx['track_url']}" style="display:inline-block;background:{BRAND_NAVY};color:#fff;text-decoration:none;padding:12px 28px;border-radius:8px;font-weight:700;font-size:14px;letter-spacing:0.02em">
            Track Your Order →
          </a>
        </td></tr>

        <!-- Footer -->
        <tr><td style="padding:22px 28px 26px">
          <hr style="border:0;border-top:1px solid {LINE};margin:0 0 14px"/>
          <p style="margin:0 0 6px;font-size:12px;color:{MUTED};line-height:1.55">
            Questions about this order? Reply directly to this email or write to
            <a href="mailto:hello@furnotech.in" style="color:{BRAND_NAVY}">hello@furnotech.in</a>.
            Quote your order number for the fastest response.
          </p>
          <p style="margin:0;font-size:11px;color:{MUTED}">
            FurnoTech • Premium furniture for the modern Indian home •
            This is a transactional email about your purchase.
          </p>
        </td></tr>

      </table>
    </td></tr>
  </table>
</body></html>
"""


def _build_text(order) -> str:
    ctx = _payment_context(order)
    lines = [
        f'Hi {order.user_name or "there"},',
        '',
        f'Thanks for your order. Order #{order.order_id} is confirmed.',
        '',
        f'{ctx["amount_label"]}: {ctx["amount"]}',
        f'  {ctx["headline"]} — {ctx["sub"]}',
        '',
        'Items:',
    ]
    for name, qty, line in _order_items(order):
        lines.append(f'  - {name} x {qty}  {_fmt_money(line)}')
    lines += [
        '',
        f'Grand Total: {_fmt_money(order.total_amount)}',
        '',
        f'Delivering to:',
        f'  {order.user_name or ""}',
        f'  {(order.address or "").replace(chr(10), ", ")}',
        f'  Phone: {getattr(order, "phone", "") or "-"}',
        '',
        f'Track your order: {ctx["track_url"]}',
        '',
        'Reply to this email for help, or write to hello@furnotech.in.',
        '',
        '— FurnoTech',
    ]
    return '\n'.join(lines)


def send_order_confirmation_sms(order) -> bool:
    """
    Short transactional SMS. Fires for COD, credit, wallet, and Razorpay paid
    orders alike. Idempotency: caller guards on Payment.sms_sent_at.
    """
    phone = getattr(order, 'phone', None)
    if not phone:
        return False
    from sms_campaigns.services import send_transactional_sms
    method = (getattr(order, 'payment_method', '') or '').lower()
    paid = (getattr(order, 'payment_status', '') == 'SUCCESS')
    if method == 'cod':
        tag = f'pay {_fmt_money(order.total_amount)} on delivery'
    elif method == 'credit' and not paid:
        tag = f'{_fmt_money(order.total_amount)} due on credit'
    elif method == 'wallet':
        tag = f'{_fmt_money(order.total_amount)} debited from wallet'
    else:
        tag = f'paid {_fmt_money(order.total_amount)}'
    site = (settings.SITE_URL or '').rstrip('/') or 'https://furnotech.in'
    msg = (f'FurnoTech: Order {order.order_id} confirmed ({tag}). '
           f'Track: {site}/orders/{order.order_id}')
    result = send_transactional_sms(phone, msg, name=order.user_name or '')
    return result.get('status') == 'sent'


def send_order_confirmation_email(order) -> bool:
    """
    Send the confirmation email. Returns True on success, False otherwise.
    Caller decides whether to mark `Payment.email_sent_at` on order.
    """
    if not getattr(order, 'user_email', None):
        return False

    ctx = _payment_context(order)
    short = {
        'cod':    f'Pay {ctx["amount"]} on Delivery',
        'credit': f'On Credit — {ctx["amount"]} Due',
        'wallet': f'Paid {ctx["amount"]} from Wallet',
        'paid':   f'Payment Received — {ctx["amount"]}',
    }.get(ctx['state'], f'Order Confirmed — {ctx["amount"]}')
    subject = f'Order #{order.order_id} confirmed • {short}'

    try:
        msg = EmailMultiAlternatives(
            subject=subject,
            body=_build_text(order),
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[order.user_email],
            reply_to=['hello@furnotech.in'],
        )
        msg.attach_alternative(_build_html(order), 'text/html')
        msg.send(fail_silently=False)
        logger.info('Order confirmation email sent for %s -> %s (state=%s)',
                    order.order_id, order.user_email, ctx['state'])
        return True
    except Exception:
        logger.exception('Order confirmation email FAILED for %s', order.order_id)
        return False


def send_order_status_email(order, *, new_status: str) -> bool:
    """Lightweight status-change email (SHIPPED / DELIVERED / CANCELLED)."""
    if not getattr(order, 'user_email', None):
        return False
    status_label = (new_status or '').upper()
    pretty = {
        'CONFIRMED': 'Order confirmed and being prepared',
        'SHIPPED':   'Your order has shipped',
        'DELIVERED': 'Order delivered — enjoy!',
        'CANCELLED': 'Order cancelled',
    }.get(status_label, f'Order {status_label.title()}')
    subject = f'#{order.order_id} • {pretty}'
    site = (settings.SITE_URL or '').rstrip('/') or 'https://furnotech.in'
    track = f'{site}/orders/{order.order_id}'

    html = f"""<!doctype html>
<html><body style="margin:0;padding:0;background:{BG_PAGE};font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:{INK}">
  <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" style="padding:24px 0">
    <tr><td align="center">
      <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="540" style="max-width:540px;background:{BG_CARD};border-radius:12px;overflow:hidden;border:1px solid {LINE}">
        <tr><td style="background:{BRAND_NAVY};padding:20px 26px;color:#fff;font-size:18px;font-weight:800">
          Furno<span style="color:{BRAND_ORANGE}">Tech</span>
        </td></tr>
        <tr><td style="padding:26px">
          <div style="font-size:11px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:{MUTED};margin-bottom:6px">
            Order #{escape(order.order_id)}
          </div>
          <h1 style="margin:0 0 12px;font-size:22px;font-weight:800;color:{INK}">{escape(pretty)}</h1>
          <p style="margin:0 0 18px;font-size:14px;color:{MUTED};line-height:1.6">
            Hi {escape(order.user_name or 'there')}, status of your order is now <strong style="color:{INK}">{escape(status_label)}</strong>.
          </p>
          <a href="{track}" style="display:inline-block;background:{BRAND_NAVY};color:#fff;text-decoration:none;padding:10px 22px;border-radius:8px;font-weight:700;font-size:14px">Track Order →</a>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>"""
    body = (
        f'Hi {order.user_name or "there"},\n\n'
        f'Order #{order.order_id} — {pretty}.\n\n'
        f'Track: {track}\n\n'
        f'— FurnoTech'
    )
    try:
        msg = EmailMultiAlternatives(
            subject=subject, body=body,
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[order.user_email],
            reply_to=['hello@furnotech.in'],
        )
        msg.attach_alternative(html, 'text/html')
        msg.send(fail_silently=False)
        return True
    except Exception:
        logger.exception('Order status email FAILED for %s', order.order_id)
        return False
