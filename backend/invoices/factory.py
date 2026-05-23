"""
Build an Invoice + InvoiceItem rows from a paid Order.

Tax algorithm:
  buyer_state == store_state  →  CGST + SGST split (gst_rate / 2 each)
  otherwise                   →  IGST (full gst_rate)

`gst_rate` is read from `StoreSettings.gst_percent`. The order already stores a
single `gst_amount` so we use it as the source of truth and split per line.
"""
from datetime import date
from decimal import Decimal

from django.db import transaction
from django.utils import timezone

from .models import Invoice, InvoiceCounter, InvoiceItem


@transaction.atomic
def next_invoice_number(year=None):
    year = year or timezone.now().year
    counter, _ = InvoiceCounter.objects.select_for_update().get_or_create(
        year=year, defaults={'last_seq': 0},
    )
    counter.last_seq += 1
    counter.save(update_fields=['last_seq'])
    return f'INV-{year}-{counter.last_seq:05d}'


def _buyer_state_from_pincode(pincode):
    """
    Best-effort state lookup from the leading two digits of a PIN.
    Out-of-scope for v1: a real implementation hits an India Post API. For
    now we fall back to None and treat as inter-state (IGST).
    """
    if not pincode or len(pincode) < 2:
        return None
    # Coarse mapping. Used only for the GST split heuristic; the customer's
    # billing address text remains the legal source-of-truth.
    PREFIX_TO_STATE = {
        '11': 'Delhi',
        '12': 'Haryana', '13': 'Haryana',
        '14': 'Punjab', '15': 'Punjab', '16': 'Punjab',
        '17': 'Himachal Pradesh',
        '18': 'Jammu and Kashmir', '19': 'Jammu and Kashmir',
        '20': 'Uttar Pradesh', '21': 'Uttar Pradesh', '22': 'Uttar Pradesh',
        '23': 'Uttar Pradesh', '24': 'Uttar Pradesh', '25': 'Uttar Pradesh',
        '26': 'Uttar Pradesh', '27': 'Uttar Pradesh', '28': 'Uttar Pradesh',
        '30': 'Rajasthan', '31': 'Rajasthan', '32': 'Rajasthan',
        '33': 'Rajasthan', '34': 'Rajasthan',
        '36': 'Gujarat', '37': 'Gujarat', '38': 'Gujarat', '39': 'Gujarat',
        '40': 'Maharashtra', '41': 'Maharashtra', '42': 'Maharashtra',
        '43': 'Maharashtra', '44': 'Maharashtra',
        '45': 'Madhya Pradesh', '46': 'Madhya Pradesh', '47': 'Madhya Pradesh',
        '48': 'Madhya Pradesh', '49': 'Madhya Pradesh',
        '50': 'Telangana', '51': 'Andhra Pradesh', '52': 'Andhra Pradesh',
        '53': 'Andhra Pradesh',
        '56': 'Karnataka', '57': 'Karnataka', '58': 'Karnataka', '59': 'Karnataka',
        '60': 'Tamil Nadu', '61': 'Tamil Nadu', '62': 'Tamil Nadu',
        '63': 'Tamil Nadu', '64': 'Tamil Nadu',
        '67': 'Kerala', '68': 'Kerala', '69': 'Kerala',
        '70': 'West Bengal', '71': 'West Bengal', '72': 'West Bengal',
        '73': 'West Bengal', '74': 'West Bengal',
        '75': 'Odisha', '76': 'Odisha', '77': 'Odisha',
        '78': 'Assam', '79': 'Arunachal Pradesh',
        '80': 'Bihar', '81': 'Bihar', '82': 'Bihar', '83': 'Bihar', '84': 'Jharkhand',
        '85': 'Jharkhand',
    }
    return PREFIX_TO_STATE.get(pincode[:2])


@transaction.atomic
def create_invoice_from_order(order, *, force=False):
    """
    Idempotent: if an invoice already exists for this order, return it
    unchanged unless `force=True` (admin recovery).
    """
    if not force:
        existing = Invoice.objects.filter(order=order).first()
        if existing is not None:
            return existing
    else:
        Invoice.objects.filter(order=order).delete()

    from store_settings.models import StoreSettings
    store = StoreSettings.current()

    # Extract pincode best-effort: last 6-digit token in the address text.
    import re
    pin_match = re.search(r'\b(\d{6})\b', order.address or '')
    billing_pincode = pin_match.group(1) if pin_match else ''
    buyer_state = _buyer_state_from_pincode(billing_pincode)
    store_state = getattr(store, 'store_state', '') or ''

    is_intrastate = bool(buyer_state and store_state and
                         buyer_state.lower() == store_state.lower())

    gst_rate = Decimal(str(order.gst_percent or 0))
    if is_intrastate:
        cgst_rate = sgst_rate = (gst_rate / 2).quantize(Decimal('0.01'))
        igst_rate = Decimal('0.00')
    else:
        cgst_rate = sgst_rate = Decimal('0.00')
        igst_rate = gst_rate.quantize(Decimal('0.01'))

    invoice = Invoice.objects.create(
        invoice_number=next_invoice_number(),
        order=order,
        customer=order.user,
        billing_name=order.user_name,
        billing_address_text=order.address,
        billing_pincode=billing_pincode,
        billing_state=buyer_state or '',
        shipping_address_text='',  # we don't track separate shipping yet
        store_name=getattr(store, 'name', 'FurnoTech'),
        store_legal_name=getattr(store, 'legal_name', '') or '',
        store_gstin=getattr(store, 'gstin', '') or '',
        store_address=getattr(store, 'address', '') or '',
        store_email=getattr(store, 'email', '') or '',
        store_phone=getattr(store, 'phone', '') or '',
        subtotal=Decimal('0'),
        discount_total=Decimal('0'),
        shipping_total=Decimal(str(order.shipping_amount or 0)),
        invoice_date=timezone.now().date(),
        payment_status=order.payment_status,
        payment_method=getattr(order, 'payment_method', 'razorpay') or 'razorpay',
    )

    subtotal = Decimal('0')
    discount_total = Decimal('0')
    cgst_total = Decimal('0')
    sgst_total = Decimal('0')
    igst_total = Decimal('0')

    for item in order.items.select_related('product').all():
        unit = Decimal(str(item.price))                   # post-discount unit price
        original = Decimal(str(item.original_price))
        qty = item.quantity
        line_subtotal = (unit * qty).quantize(Decimal('0.01'))
        line_discount = ((original - unit) * qty).quantize(Decimal('0.01'))

        # Per-line tax — apportion the order's GST proportionally so the
        # totals reconcile to the order even with mixed-rate scenarios later.
        if is_intrastate:
            cgst_amt = (line_subtotal * cgst_rate / Decimal('100')).quantize(Decimal('0.01'))
            sgst_amt = (line_subtotal * sgst_rate / Decimal('100')).quantize(Decimal('0.01'))
            igst_amt = Decimal('0.00')
        else:
            cgst_amt = sgst_amt = Decimal('0.00')
            igst_amt = (line_subtotal * igst_rate / Decimal('100')).quantize(Decimal('0.01'))

        line_total = line_subtotal + cgst_amt + sgst_amt + igst_amt

        InvoiceItem.objects.create(
            invoice=invoice,
            product=item.product,
            variant=getattr(item, 'variant', None),
            product_name=item.product.name,
            product_sku=item.product.sku or '',
            variant_label='',
            hsn_code=getattr(item.product, 'hsn_code', '') or '',
            quantity=qty,
            unit_price=unit,
            original_unit_price=original,
            line_subtotal=line_subtotal,
            line_discount=line_discount,
            cgst_rate=cgst_rate, sgst_rate=sgst_rate, igst_rate=igst_rate,
            cgst_amount=cgst_amt, sgst_amount=sgst_amt, igst_amount=igst_amt,
            line_total=line_total,
        )

        subtotal += line_subtotal
        discount_total += line_discount
        cgst_total += cgst_amt
        sgst_total += sgst_amt
        igst_total += igst_amt

    # Order-level coupon discount — applied AFTER per-line discounts and
    # BEFORE tax in the displayed math, but our taxes are already computed
    # off the post-line-discount subtotal (matches the Order's `subtotal_amount`
    # which already reflects line discounts). Subtracting the coupon at the
    # grand-total stage matches what was actually charged on the order.
    coupon_discount = Decimal(str(getattr(order, 'coupon_discount', 0) or 0))
    coupon_code = getattr(order, 'coupon_code', '') or ''

    grand_total = (subtotal + cgst_total + sgst_total + igst_total
                   + Decimal(str(order.shipping_amount or 0))
                   - coupon_discount)

    invoice.subtotal = subtotal
    # discount_total surfaces ALL savings on the PDF — line discounts + coupon.
    invoice.discount_total = discount_total + coupon_discount
    invoice.coupon_code = coupon_code
    invoice.coupon_discount = coupon_discount
    invoice.cgst_total = cgst_total
    invoice.sgst_total = sgst_total
    invoice.igst_total = igst_total
    invoice.grand_total = grand_total.quantize(Decimal('0.01'))

    # Credit-method invoices stay open (amount_due > 0). Razorpay/COD/wallet
    # invoices are paid at create time.
    is_credit = (invoice.payment_method == 'credit')
    if is_credit:
        invoice.amount_paid = Decimal('0')
        invoice.amount_due = invoice.grand_total
        invoice.payment_status = 'PENDING'
    else:
        invoice.amount_paid = invoice.grand_total
        invoice.amount_due = Decimal('0')

    invoice.save(update_fields=[
        'subtotal', 'discount_total', 'coupon_code', 'coupon_discount',
        'cgst_total', 'sgst_total', 'igst_total', 'grand_total',
        'amount_paid', 'amount_due', 'payment_status',
    ])

    # If this is a dealer credit invoice, eat into the dealer's credit limit.
    if is_credit and order.user_id:
        try:
            from dealer_credit.models import DealerCredit
            credit, _ = DealerCredit.objects.get_or_create(
                dealer=order.user,
                defaults={'credit_limit': 0, 'amount_used': 0,
                          'terms_days': 30, 'is_active': True},
            )
            credit.amount_used = (credit.amount_used or Decimal('0')) + invoice.grand_total
            credit.save(update_fields=['amount_used', 'updated_at'])
        except Exception:
            import logging
            logging.getLogger(__name__).exception(
                'Failed to update DealerCredit for invoice %s', invoice.invoice_number,
            )

    return invoice
