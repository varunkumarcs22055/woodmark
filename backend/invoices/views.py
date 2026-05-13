"""
  GET    /api/invoices/                     admin: paginated list with filters
  GET    /api/invoices/{id}/                admin OR order owner
  GET    /api/invoices/{id}/pdf/            PDF stream
  POST   /api/invoices/{id}/email/          admin: re-send the PDF as email
  POST   /api/invoices/regenerate/{order_id}/   admin: rebuild from order
"""
from datetime import date

from django.core.mail import EmailMessage
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from audit.mixins import AuditedMixin
from core.permissions import IsAdminUser
from orders.models import Order

from .factory import create_invoice_from_order
from .models import Invoice
from .pdf import render_invoice_pdf
from .serializers import InvoiceSerializer


class InvoiceListView(generics.ListAPIView):
    permission_classes = [IsAdminUser]
    serializer_class = InvoiceSerializer
    search_fields = ['invoice_number', 'order__order_id', 'billing_name', 'customer__email']
    ordering_fields = ['created_at', 'invoice_date', 'grand_total']
    ordering = ['-created_at']

    def get_queryset(self):
        qs = Invoice.objects.select_related('order', 'customer').prefetch_related('items')
        ps = self.request.query_params.get('payment_status')
        if ps:
            qs = qs.filter(payment_status=ps)
        date_from = self.request.query_params.get('from')
        date_to = self.request.query_params.get('to')
        if date_from:
            qs = qs.filter(invoice_date__gte=date_from)
        if date_to:
            qs = qs.filter(invoice_date__lte=date_to)
        return qs


class InvoiceDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        invoice = get_object_or_404(
            Invoice.objects.select_related('order', 'customer').prefetch_related('items'),
            pk=pk,
        )
        # Admin OR the customer who owns the order may read.
        is_admin = (request.user.role == 'admin' or request.user.is_superuser)
        is_owner = invoice.customer_id == request.user.id
        if not (is_admin or is_owner):
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)
        return Response(InvoiceSerializer(invoice).data)


class InvoicePDFView(APIView):
    """Returns the PDF inline so a browser tab can render it; downloads with `?download=1`."""
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        invoice = get_object_or_404(
            Invoice.objects.select_related('order', 'customer').prefetch_related('items'),
            pk=pk,
        )
        is_admin = (request.user.role == 'admin' or request.user.is_superuser)
        is_owner = invoice.customer_id == request.user.id
        if not (is_admin or is_owner):
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        pdf_bytes = render_invoice_pdf(invoice)
        disp = 'attachment' if request.query_params.get('download') else 'inline'
        response = HttpResponse(pdf_bytes, content_type='application/pdf')
        response['Content-Disposition'] = f'{disp}; filename="{invoice.invoice_number}.pdf"'
        return response


class InvoiceEmailView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'invoice'

    def post(self, request, pk):
        invoice = get_object_or_404(
            Invoice.objects.select_related('order', 'customer').prefetch_related('items'),
            pk=pk,
        )
        recipient = (request.data.get('email')
                     or (invoice.customer.email if invoice.customer else None)
                     or invoice.order.user_email)
        if not recipient:
            return Response(
                {'detail': 'No recipient email available; pass `email` in body.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        pdf_bytes = render_invoice_pdf(invoice)
        msg = EmailMessage(
            subject=f'Invoice {invoice.invoice_number} from {invoice.store_name}',
            body=(
                f'Hi {invoice.billing_name},\n\n'
                f'Please find attached your invoice {invoice.invoice_number} for order '
                f'{invoice.order.order_id}.\n\n'
                f'Thank you for shopping with us.\n— {invoice.store_name}'
            ),
            from_email=invoice.store_email or 'no-reply@furnishop.local',
            to=[recipient],
        )
        msg.attach(f'{invoice.invoice_number}.pdf', pdf_bytes, 'application/pdf')
        msg.send(fail_silently=True)

        from django.utils import timezone
        invoice.emailed_at = timezone.now()
        invoice.save(update_fields=['emailed_at'])
        self.audit_write(request, action='other', target_id=invoice.id,
                         payload={'emailed_to': recipient, 'kind': 'invoice_email'})
        return Response({'emailed_to': recipient, 'emailed_at': invoice.emailed_at})


class InvoiceRegenerateView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'invoice'

    def post(self, request, order_id):
        order = get_object_or_404(Order, pk=order_id)
        invoice = create_invoice_from_order(order, force=True)
        self.audit_write(request, action='other', target_id=invoice.id,
                         payload={'order': order.pk, 'kind': 'invoice_regenerate'})
        return Response(InvoiceSerializer(invoice).data, status=status.HTTP_201_CREATED)
