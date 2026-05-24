"""
CSV bulk-order upload endpoint for dealers.

Expected CSV columns (header row required):
    sku,quantity,po_number(optional),notes(optional)

Behavior:
  - Lines whose SKU doesn't match an active product are skipped and reported.
  - Quantities < MOQ get bumped to MOQ if stock allows; otherwise skipped.
  - Quantities > stock are ACCEPTED for active dealers — the order serializer
    creates a backorder with `is_backorder=True` and expected restock date.
    The bulk path used to hard-reject these, so dealers had to wait for
    restock to use this feature at all. Now we mirror the regular checkout
    behaviour for parity.
  - dry_run=true returns the preview payload (line items, prices, total)
    without creating the order — so dealers can review before committing.
  - All valid lines collapse into ONE order (so freight is paid once).
  - Returns {order|preview, skipped, summary}.
"""
import csv
import io
from decimal import Decimal

from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsActiveDealer
from orders.serializers import OrderCreateSerializer, OrderSerializer
from products.models import Product


class DealerBulkUploadView(APIView):
    """
    POST /api/dealer/orders/bulk-upload/

    multipart/form-data:
      - file: the CSV blob
      - po_number (optional)
      - dealer_note (optional)
      - payment_method (default: razorpay; credit/wallet allowed)
      - address (optional override)
    """
    permission_classes = [IsAuthenticated, IsActiveDealer]
    parser_classes = [MultiPartParser, FormParser]

    REQUIRED_HEADERS = {'sku', 'quantity'}

    def post(self, request):
        f = request.FILES.get('file')
        if not f:
            return Response({'error': 'Upload a CSV file in the `file` field.'},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            text = f.read().decode('utf-8-sig')
        except UnicodeDecodeError:
            return Response({'error': 'File must be UTF-8 encoded.'},
                            status=status.HTTP_400_BAD_REQUEST)

        reader = csv.DictReader(io.StringIO(text))
        if not reader.fieldnames or not self.REQUIRED_HEADERS.issubset(
                {h.strip().lower() for h in reader.fieldnames}):
            return Response(
                {'error': 'CSV must include columns: sku, quantity.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        items = []
        skipped = []
        for idx, raw in enumerate(reader, start=2):  # start=2 to account for header
            row = {(k or '').strip().lower(): (v or '').strip() for k, v in raw.items()}
            sku = row.get('sku', '')
            try:
                qty = int(row.get('quantity', '0') or '0')
            except ValueError:
                skipped.append({'line': idx, 'sku': sku, 'reason': 'invalid quantity'})
                continue

            if not sku:
                skipped.append({'line': idx, 'sku': '', 'reason': 'missing sku'})
                continue
            if qty <= 0:
                skipped.append({'line': idx, 'sku': sku, 'reason': 'qty must be > 0'})
                continue

            product = Product.objects.filter(sku__iexact=sku, is_deleted=False).first()
            if product is None:
                skipped.append({'line': idx, 'sku': sku, 'reason': 'sku not found'})
                continue
            if getattr(product, 'status', 'active') != 'active':
                skipped.append({'line': idx, 'sku': sku, 'reason': 'product not active'})
                continue
            moq = getattr(product, 'min_order_quantity', 1) or 1
            if qty < moq:
                # Always bump to MOQ — backorder downstream will handle the
                # case where stock can't cover it yet (active dealers only).
                qty = moq
            # Active dealers can place backorders for the shortfall — don't
            # reject. The OrderCreateSerializer handles split between
            # in-stock + backordered units. Inactive dealers and customers
            # still get rejected there.
            items.append({'product_id': product.id, 'quantity': qty})

        if not items:
            return Response(
                {'error': 'No valid rows to order.', 'skipped': skipped},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = request.user

        # Pull dealer's default shipping address if they haven't passed one
        # explicitly. The placeholder string "Default dealer address" used
        # to leak onto real invoices and shipping labels.
        explicit_address = (request.data.get('address') or '').strip()
        address = explicit_address
        if not address:
            from users.models import UserAddress
            default_addr = (UserAddress.objects
                            .filter(user=user, is_default_shipping=True)
                            .first()
                            or UserAddress.objects.filter(user=user).first())
            if default_addr:
                parts = [
                    default_addr.line1, default_addr.line2, default_addr.landmark,
                    f'{default_addr.city}, {default_addr.state} {default_addr.postal_code}',
                    default_addr.country,
                ]
                address = '\n'.join(p for p in parts if p)
        if not address:
            return Response(
                {'error': 'No shipping address — add one in your dealer profile '
                          'or include an `address` field in the upload form.',
                 'skipped': skipped},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not (user.phone or '').strip():
            return Response(
                {'error': 'Your dealer account has no phone number on file. '
                          'Add one in Profile so we can call you about this order.',
                 'skipped': skipped},
                status=status.HTTP_400_BAD_REQUEST,
            )

        payload = {
            'user_name': user.full_name or user.email,
            'user_email': user.email,
            'phone': user.phone,
            'address': address,
            'payment_method': (request.data.get('payment_method') or 'razorpay').strip(),
            'po_number': (request.data.get('po_number') or '').strip(),
            'dealer_note': (request.data.get('dealer_note') or 'CSV bulk upload').strip(),
            'items': items,
        }

        dry_run = str(request.data.get('dry_run', '')).lower() in ('1', 'true', 'yes')

        ser = OrderCreateSerializer(data=payload, context={'request': request})
        if not ser.is_valid():
            return Response(
                {'error': 'Order validation failed.', 'detail': ser.errors, 'skipped': skipped},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if dry_run:
            # Build a preview WITHOUT persisting. Use the dealer pricing
            # service per-line so the preview shows the actual dealer rates.
            from dealer_pricing.service import resolve as resolve_dealer
            preview_lines = []
            subtotal = Decimal('0')
            for it in items:
                product = Product.objects.get(pk=it['product_id'])
                qty = it['quantity']
                res = resolve_dealer(product, user, quantity=qty)
                eff = Decimal(str(res['effective_price']))
                line_total = eff * qty
                subtotal += line_total
                preview_lines.append({
                    'product_id': product.id,
                    'product_name': product.name,
                    'sku': product.sku,
                    'quantity': qty,
                    'unit_price': str(eff),
                    'mrp': str(res['mrp']),
                    'line_total': str(line_total),
                    'in_stock': qty <= product.stock,
                    'backorder_qty': max(0, qty - product.stock),
                })
            return Response({
                'preview': True,
                'address': address,
                'phone': user.phone,
                'payment_method': payload['payment_method'],
                'lines': preview_lines,
                'subtotal': str(subtotal),
                'skipped': skipped,
                'summary': {
                    'lines_accepted': len(items),
                    'lines_skipped': len(skipped),
                    'units_total': str(sum(it['quantity'] for it in items)),
                },
                'note': ('Final totals (GST, shipping, dealer discounts) will be '
                         'computed on confirm. Set dry_run=false to place the order.'),
            })

        order = ser.save()

        line_total = sum(Decimal(str(it['quantity'])) for it in items)
        return Response({
            'order': OrderSerializer(order).data,
            'skipped': skipped,
            'summary': {
                'lines_accepted': len(items),
                'lines_skipped': len(skipped),
                'units_total': str(line_total),
            },
        }, status=status.HTTP_201_CREATED)
