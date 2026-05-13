from rest_framework import serializers
from .models import Invoice, InvoiceItem


class InvoiceItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = InvoiceItem
        fields = [
            'id', 'product_name', 'product_sku', 'variant_label',
            'hsn_code', 'quantity',
            'unit_price', 'original_unit_price',
            'line_subtotal', 'line_discount',
            'cgst_rate', 'sgst_rate', 'igst_rate',
            'cgst_amount', 'sgst_amount', 'igst_amount',
            'line_total',
        ]


class InvoiceSerializer(serializers.ModelSerializer):
    items = InvoiceItemSerializer(many=True, read_only=True)
    customer_email = serializers.CharField(source='customer.email', read_only=True, default='')
    order_id_human = serializers.CharField(source='order.order_id', read_only=True)

    class Meta:
        model = Invoice
        fields = [
            'id', 'invoice_number', 'order', 'order_id_human', 'customer', 'customer_email',
            'billing_name', 'billing_address_text', 'billing_pincode', 'billing_state',
            'shipping_address_text',
            'store_name', 'store_legal_name', 'store_gstin',
            'store_address', 'store_email', 'store_phone',
            'subtotal', 'discount_total',
            'cgst_total', 'sgst_total', 'igst_total',
            'shipping_total', 'grand_total',
            'amount_paid', 'amount_due',
            'payment_status', 'payment_method',
            'invoice_date', 'due_date', 'pdf_url',
            'emailed_at', 'notes',
            'created_at', 'updated_at',
            'items',
        ]
