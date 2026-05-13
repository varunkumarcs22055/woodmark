"""
CSV bulk-order upload endpoint for dealers.

Expected CSV columns (header row required):
    sku,quantity,po_number(optional),notes(optional)

Behavior:
  - Lines whose SKU doesn't match an active product are skipped and reported.
  - Quantities < MOQ get bumped to MOQ if stock allows; otherwise skipped.
  - All valid lines collapse into ONE order (so freight is paid once).
  - Returns {created_order, skipped, summary}.
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
                if moq <= product.stock:
                    qty = moq
                else:
                    skipped.append({'line': idx, 'sku': sku, 'reason': f'cannot meet MOQ {moq}'})
                    continue
            if qty > product.stock:
                skipped.append({'line': idx, 'sku': sku,
                                'reason': f'requested {qty} but only {product.stock} in stock'})
                continue

            items.append({'product_id': product.id, 'quantity': qty})

        if not items:
            return Response(
                {'error': 'No valid rows to order.', 'skipped': skipped},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = request.user
        payload = {
            'user_name': user.full_name or user.email,
            'user_email': user.email,
            'phone': user.phone or '0000000000',
            'address': (request.data.get('address') or 'Default dealer address').strip(),
            'payment_method': (request.data.get('payment_method') or 'razorpay').strip(),
            'po_number': (request.data.get('po_number') or '').strip(),
            'dealer_note': (request.data.get('dealer_note') or 'CSV bulk upload').strip(),
            'items': items,
        }
        ser = OrderCreateSerializer(data=payload, context={'request': request})
        if not ser.is_valid():
            return Response(
                {'error': 'Order validation failed.', 'detail': ser.errors, 'skipped': skipped},
                status=status.HTTP_400_BAD_REQUEST,
            )
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
