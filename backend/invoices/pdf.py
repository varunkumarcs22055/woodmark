"""
Reportlab-based PDF generator for an Invoice.

Design language (matches the two reference mockups the client supplied):
  * Dark navy header bar with the document name in white and the invoice
    number on the right in an orange accent badge.
  * Two side-by-side blocks for "SELLER" and "BILL TO" with orange section
    labels and bold name lines.
  * Single-color line-items table with a dark header row, zero vertical
    rules, and a faint horizontal separator between rows.
  * Totals stack right-aligned, capped by an orange "GRAND TOTAL" bar in
    white text — visually the most prominent element on the page.
  * Footer carries terms and a thank-you note.

Returns a `bytes` blob; the view streams it back as `application/pdf`.
"""
from io import BytesIO

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether,
)


# ─── Palette ─────────────────────────────────────────────────────────────
NAVY        = colors.HexColor('#1F2937')
NAVY_DARK   = colors.HexColor('#111827')
ORANGE      = colors.HexColor('#F97316')
ORANGE_SOFT = colors.HexColor('#FFF7ED')
ORANGE_BAR  = colors.HexColor('#EA580C')
INK         = colors.HexColor('#0F172A')
MUTED       = colors.HexColor('#6B7280')
LINE        = colors.HexColor('#E5E7EB')
ZEBRA       = colors.HexColor('#FFFBF5')
WHITE       = colors.white


def _money(value):
    """Format money with a thousands separator and the rupee symbol."""
    try:
        amount = float(value)
    except (TypeError, ValueError):
        return str(value)
    # Use 'Rs.' instead of the ₹ glyph — Helvetica (Reportlab default) does
    # not ship a glyph for it and renders a black box on most viewers.
    return f'Rs. {amount:,.2f}'


def _para(text, style):
    return Paragraph(text or '', style)


def render_invoice_pdf(invoice) -> bytes:
    buffer = BytesIO()
    doc = SimpleDocTemplate(
        buffer, pagesize=A4,
        leftMargin=14 * mm, rightMargin=14 * mm,
        topMargin=14 * mm, bottomMargin=14 * mm,
        title=f'Invoice {invoice.invoice_number}',
    )

    # ─── Styles ──────────────────────────────────────────────────────
    styles = getSampleStyleSheet()
    body = ParagraphStyle('body', parent=styles['BodyText'], fontSize=9.5,
                          textColor=INK, leading=13)
    small = ParagraphStyle('small', parent=body, fontSize=8.5,
                           textColor=MUTED, leading=11)
    section_label = ParagraphStyle(
        'section_label', parent=body, fontSize=9, textColor=ORANGE_BAR,
        fontName='Helvetica-Bold', leading=12, spaceAfter=2,
    )
    bold_line = ParagraphStyle(
        'bold_line', parent=body, fontSize=10.5, textColor=INK,
        fontName='Helvetica-Bold', leading=13,
    )
    h_title = ParagraphStyle(
        'title', parent=body, fontSize=22, leading=24,
        textColor=WHITE, fontName='Helvetica-Bold',
    )
    h_inv_label = ParagraphStyle(
        'inv_label', parent=body, fontSize=9, textColor=WHITE,
        fontName='Helvetica', leading=11, alignment=2,
    )
    h_inv_no = ParagraphStyle(
        'inv_no', parent=body, fontSize=15, textColor=ORANGE,
        fontName='Helvetica-Bold', leading=18, alignment=2,
    )
    totals_label = ParagraphStyle('tl', parent=body, fontSize=10, alignment=2,
                                  textColor=INK, leading=14)
    totals_value = ParagraphStyle('tv', parent=body, fontSize=10, alignment=2,
                                  textColor=INK, fontName='Helvetica-Bold',
                                  leading=14)
    grand_label = ParagraphStyle('gl', parent=body, fontSize=12, alignment=0,
                                 textColor=WHITE, fontName='Helvetica-Bold',
                                 leading=16)
    grand_value = ParagraphStyle('gv', parent=body, fontSize=14, alignment=2,
                                 textColor=WHITE, fontName='Helvetica-Bold',
                                 leading=16)

    story = []

    # ─── 1. Dark header bar ─────────────────────────────────────────
    header_left = [
        _para(invoice.store_name.upper() if invoice.store_name else 'INVOICE', h_title),
        _para('TAX INVOICE', ParagraphStyle('sub', parent=body, fontSize=8.5,
              textColor=colors.HexColor('#FED7AA'), fontName='Helvetica-Bold',
              leading=11)),
    ]
    header_right = [
        _para('# ' + (invoice.invoice_number or '—'), h_inv_no),
        _para(invoice.payment_status or '', h_inv_label),
    ]
    header = Table(
        [[header_left, header_right]],
        colWidths=[120 * mm, 62 * mm],
    )
    header.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), NAVY),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 18),
        ('RIGHTPADDING', (0, 0), (-1, -1), 18),
        ('TOPPADDING', (0, 0), (-1, -1), 14),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 14),
    ]))
    story.append(header)
    story.append(Spacer(1, 14))

    # ─── 2. Meta strip — Invoice date, Due date, Payment method ──────
    invoice_date = invoice.invoice_date.strftime('%d %b %Y') if invoice.invoice_date else '—'
    due_date = invoice.due_date.strftime('%d %b %Y') if invoice.due_date else '—'
    meta = Table([[
        [_para('Invoice Date', small), _para(invoice_date, bold_line)],
        [_para('Due Date', small), _para(due_date, bold_line)],
        [_para('Order #', small),
         _para(invoice.order.order_id if invoice.order_id else '—', bold_line)],
        [_para('Payment', small),
         _para(f'{(invoice.payment_method or "—").upper()}', bold_line)],
    ]], colWidths=[45 * mm, 45 * mm, 45 * mm, 47 * mm])
    meta.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
        ('TOPPADDING', (0, 0), (-1, -1), 2),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
    ]))
    story.append(meta)
    story.append(Spacer(1, 14))

    # ─── 3. Seller / Bill-to blocks ─────────────────────────────────
    seller_cell = [
        _para('SELLER', section_label),
        _para(invoice.store_legal_name or invoice.store_name or '—', bold_line),
    ]
    if invoice.store_address:
        seller_cell.append(_para(invoice.store_address.replace('\n', '<br/>'), small))
    contact_bits = ' · '.join(filter(None, [invoice.store_email, invoice.store_phone]))
    if contact_bits:
        seller_cell.append(_para(contact_bits, small))
    if invoice.store_gstin:
        seller_cell.append(_para(f'GSTIN: <b>{invoice.store_gstin}</b>', small))

    buyer_cell = [
        _para('BILL TO', section_label),
        _para(invoice.billing_name or '—', bold_line),
    ]
    if invoice.billing_address_text:
        buyer_cell.append(_para(invoice.billing_address_text.replace('\n', '<br/>'), small))
    if invoice.billing_state:
        buyer_cell.append(_para(f'State: {invoice.billing_state}', small))
    if invoice.customer and getattr(invoice.customer, 'email', None):
        buyer_cell.append(_para(invoice.customer.email, small))

    parties = Table([[seller_cell, buyer_cell]],
                    colWidths=[91 * mm, 91 * mm])
    parties.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(parties)
    story.append(Spacer(1, 18))

    # ─── 4. Line items table ────────────────────────────────────────
    items = list(invoice.items.all())
    has_igst = any((it.igst_amount or 0) > 0 for it in items)

    if has_igst:
        line_header = ['CODE', 'DESCRIPTION', 'HSN', 'QTY', 'UNIT', 'IGST', 'TOTAL']
        widths = [22 * mm, 60 * mm, 16 * mm, 12 * mm, 24 * mm, 22 * mm, 26 * mm]
    else:
        line_header = ['CODE', 'DESCRIPTION', 'HSN', 'QTY', 'UNIT', 'CGST', 'SGST', 'TOTAL']
        widths = [20 * mm, 50 * mm, 14 * mm, 10 * mm, 22 * mm, 18 * mm, 18 * mm, 30 * mm]

    rows = [line_header]
    for it in items:
        code = it.product_sku or f'#{it.product_id or "—"}'
        desc = it.product_name or '—'
        if it.variant_label:
            desc = f'{desc} — {it.variant_label}'
        row = [
            code, desc, it.hsn_code or '—', str(it.quantity), _money(it.unit_price),
        ]
        if has_igst:
            row.append(_money(it.igst_amount) if it.igst_amount else '—')
        else:
            row.extend([
                _money(it.cgst_amount) if it.cgst_amount else '—',
                _money(it.sgst_amount) if it.sgst_amount else '—',
            ])
        row.append(_money(it.line_total))
        rows.append(row)

    items_table = Table(rows, colWidths=widths, repeatRows=1)
    style = TableStyle([
        # Header row
        ('BACKGROUND', (0, 0), (-1, 0), NAVY_DARK),
        ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 8.5),
        ('ALIGN', (0, 0), (-1, 0), 'LEFT'),
        ('ALIGN', (3, 0), (-1, 0), 'RIGHT'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
        ('TOPPADDING', (0, 0), (-1, 0), 8),

        # Body rows
        ('FONTSIZE', (0, 1), (-1, -1), 9),
        ('TEXTCOLOR', (0, 1), (-1, -1), INK),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('ALIGN', (3, 1), (-1, -1), 'RIGHT'),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 1), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 8),

        # Total column emphasis
        ('TEXTCOLOR', (-1, 1), (-1, -1), ORANGE_BAR),
        ('FONTNAME', (-1, 1), (-1, -1), 'Helvetica-Bold'),

        # Code column emphasis (orange like the reference)
        ('TEXTCOLOR', (0, 1), (0, -1), ORANGE_BAR),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),

        # Faint row separators
        ('LINEBELOW', (0, 0), (-1, -1), 0.4, LINE),
    ])
    # Zebra striping
    for i in range(1, len(rows)):
        if i % 2 == 0:
            style.add('BACKGROUND', (0, i), (-1, i), ZEBRA)
    items_table.setStyle(style)
    story.append(items_table)
    story.append(Spacer(1, 4))
    story.append(Table(
        [['']],
        colWidths=[182 * mm],
        style=TableStyle([
            ('LINEBELOW', (0, 0), (-1, -1), 1.2, ORANGE_BAR),
        ]),
        rowHeights=[2],
    ))
    story.append(Spacer(1, 14))

    # ─── 5. Totals stack + Grand total bar ──────────────────────────
    totals_rows = []

    def _add(label, val, bold=False):
        ls = totals_label if not bold else ParagraphStyle(
            'tl_b', parent=totals_label, fontName='Helvetica-Bold',
        )
        vs = totals_value
        totals_rows.append([_para(label, ls), _para(_money(val), vs)])

    _add('Subtotal', invoice.subtotal)
    if invoice.discount_total and float(invoice.discount_total) > 0:
        totals_rows.append([_para('Discount', totals_label),
                            _para(f'- {_money(invoice.discount_total)}', totals_value)])
    if invoice.cgst_total and float(invoice.cgst_total) > 0:
        _add('CGST', invoice.cgst_total)
    if invoice.sgst_total and float(invoice.sgst_total) > 0:
        _add('SGST', invoice.sgst_total)
    if invoice.igst_total and float(invoice.igst_total) > 0:
        _add('IGST', invoice.igst_total)
    if invoice.shipping_total and float(invoice.shipping_total) > 0:
        _add('Shipping', invoice.shipping_total)

    totals_block = Table(totals_rows, colWidths=[44 * mm, 36 * mm], hAlign='RIGHT')
    totals_block.setStyle(TableStyle([
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))

    # Item count strip + totals → side-by-side
    summary_row = Table(
        [[
            _para(f'{len(items)} item{"s" if len(items) != 1 else ""} '
                  f'in this invoice.', small),
            totals_block,
        ]],
        colWidths=[102 * mm, 80 * mm],
    )
    summary_row.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    story.append(summary_row)
    story.append(Spacer(1, 6))

    # GRAND TOTAL — orange bar, right-aligned (full-width)
    grand_bar = Table(
        [[_para('GRAND TOTAL', grand_label),
          _para(_money(invoice.grand_total), grand_value)]],
        colWidths=[100 * mm, 82 * mm],
    )
    grand_bar.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), ORANGE_BAR),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 18),
        ('RIGHTPADDING', (0, 0), (-1, -1), 18),
        ('TOPPADDING', (0, 0), (-1, -1), 14),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 14),
    ]))
    story.append(Spacer(1, 6))
    story.append(grand_bar)

    # Outstanding balance (only when partially paid, e.g. dealer credit)
    if invoice.amount_due and float(invoice.amount_due) > 0 and \
       float(invoice.amount_due) < float(invoice.grand_total):
        due_strip = Table(
            [[_para('Balance Due', bold_line),
              _para(_money(invoice.amount_due), bold_line)]],
            colWidths=[100 * mm, 82 * mm],
        )
        due_strip.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), ORANGE_SOFT),
            ('TEXTCOLOR', (0, 0), (-1, -1), ORANGE_BAR),
            ('LEFTPADDING', (0, 0), (-1, -1), 18),
            ('RIGHTPADDING', (0, 0), (-1, -1), 18),
            ('TOPPADDING', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
            ('ALIGN', (1, 0), (1, 0), 'RIGHT'),
        ]))
        story.append(due_strip)

    story.append(Spacer(1, 22))

    # ─── 6. Footer: Notes + Terms ────────────────────────────────────
    notes_title = ParagraphStyle('nt', parent=section_label, fontSize=10)
    notes_text = ParagraphStyle('nx', parent=small, fontSize=8.5, textColor=INK,
                                leading=12)

    footer_blocks = []
    footer_blocks.append(KeepTogether([
        _para('NOTES', notes_title),
        _para(
            invoice.notes
            or 'All products are subject to our standard return policy. '
               'Returns accepted within 14 days of delivery in original condition '
               'and packaging. Goods once sold cannot be exchanged unless defective.',
            notes_text,
        ),
        Spacer(1, 10),
        _para('TERMS &amp; CONDITIONS', notes_title),
        _para(
            '· Payment is due as per the terms shown above. '
            'Late payments may attract interest as per applicable laws. '
            '· This is a computer-generated invoice and does not require '
            'a physical signature. '
            '· For queries, contact us at the email/phone listed above and '
            'quote the invoice number for fastest service.',
            notes_text,
        ),
        Spacer(1, 14),
        _para(f'<b>Thank you for your business — {invoice.store_name}.</b>',
              ParagraphStyle('thx', parent=body, fontSize=10.5,
                             textColor=ORANGE_BAR, fontName='Helvetica-Bold')),
    ]))
    story.extend(footer_blocks)

    doc.build(story)
    return buffer.getvalue()
