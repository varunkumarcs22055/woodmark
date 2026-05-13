"""
Dealer-side credit + payments + invoices + ledger.
Admin-side credit limit / payment recording.

  GET   /api/dealer/credit/                  → my credit summary
  GET   /api/dealer/payments/                → my payments
  GET   /api/dealer/invoices/?status=open|paid → my invoices
  GET   /api/dealer/ledger/?from=&to=        → time-ordered invoices + payments
  GET   /api/dealer/dashboard/               → consolidated KPIs

Admin:
  GET   /api/admin/dealers/{id}/credit/      → that dealer's credit summary
  PATCH /api/admin/dealers/{id}/credit/      → set limit / terms / active
  POST  /api/admin/dealers/{id}/payments/    → record a payment
"""
from datetime import timedelta
from decimal import Decimal

from django.db.models import Count, Sum, Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, serializers, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from audit.mixins import AuditedMixin
from core.permissions import IsAdminUser, IsActiveDealer
from invoices.models import Invoice
from invoices.serializers import InvoiceSerializer
from orders.models import Order
from users.models import User

from .models import DealerCredit, DealerPayment


# ─── Serializers ─────────────────────────────────────────────────────────────

class DealerCreditSerializer(serializers.ModelSerializer):
    remaining = serializers.SerializerMethodField()
    dealer_email = serializers.CharField(source='dealer.email', read_only=True)

    class Meta:
        model = DealerCredit
        fields = [
            'dealer', 'dealer_email',
            'credit_limit', 'amount_used', 'remaining',
            'terms_days', 'is_active',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['dealer', 'amount_used', 'remaining', 'created_at', 'updated_at']

    def get_remaining(self, obj):
        return str(obj.remaining)


class DealerPaymentSerializer(serializers.ModelSerializer):
    invoice_number = serializers.CharField(
        source='invoice.invoice_number', read_only=True, default=None,
    )
    recorded_by_email = serializers.CharField(
        source='recorded_by.email', read_only=True, default='',
    )

    class Meta:
        model = DealerPayment
        fields = [
            'id', 'dealer', 'invoice', 'invoice_number',
            'amount', 'method', 'reference',
            'recorded_by', 'recorded_by_email', 'note',
            'received_at', 'created_at',
        ]
        read_only_fields = ['recorded_by', 'created_at']


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _get_or_create_credit(dealer):
    obj, _ = DealerCredit.objects.get_or_create(
        dealer=dealer,
        defaults={'credit_limit': 0, 'amount_used': 0, 'terms_days': 30, 'is_active': True},
    )
    return obj


# ─── Dealer-side ─────────────────────────────────────────────────────────────

class DealerCreditView(APIView):
    permission_classes = [IsActiveDealer]

    def get(self, request):
        credit = _get_or_create_credit(request.user)
        return Response(DealerCreditSerializer(credit).data)


class DealerPaymentListView(generics.ListAPIView):
    permission_classes = [IsActiveDealer]
    serializer_class = DealerPaymentSerializer

    def get_queryset(self):
        qs = DealerPayment.objects.filter(dealer=self.request.user).select_related('invoice')
        date_from = self.request.query_params.get('from')
        date_to = self.request.query_params.get('to')
        if date_from:
            qs = qs.filter(received_at__gte=date_from)
        if date_to:
            qs = qs.filter(received_at__lte=date_to)
        return qs


class DealerInvoiceListView(generics.ListAPIView):
    permission_classes = [IsActiveDealer]
    serializer_class = InvoiceSerializer

    def get_queryset(self):
        qs = Invoice.objects.filter(customer=self.request.user).prefetch_related('items')
        flag = self.request.query_params.get('status')
        if flag == 'open':
            qs = qs.filter(amount_due__gt=0)
        elif flag == 'paid':
            qs = qs.filter(amount_due=0)
        return qs.order_by('-created_at')


class DealerLedgerView(APIView):
    """
    Combined feed of invoices and payments, time-ordered, with running balance.
    """
    permission_classes = [IsActiveDealer]

    def get(self, request):
        date_from = request.query_params.get('from')
        date_to = request.query_params.get('to')

        invoice_qs = Invoice.objects.filter(customer=request.user)
        payment_qs = DealerPayment.objects.filter(dealer=request.user)
        if date_from:
            invoice_qs = invoice_qs.filter(created_at__gte=date_from)
            payment_qs = payment_qs.filter(received_at__gte=date_from)
        if date_to:
            invoice_qs = invoice_qs.filter(created_at__lte=date_to)
            payment_qs = payment_qs.filter(received_at__lte=date_to)

        rows = []
        for inv in invoice_qs:
            rows.append({
                'kind': 'invoice',
                'at': inv.created_at,
                'reference': inv.invoice_number,
                'debit': str(inv.grand_total),     # increases what you owe
                'credit': '0',
                'note': '',
            })
        for p in payment_qs.select_related('invoice'):
            rows.append({
                'kind': 'payment',
                'at': p.received_at,
                'reference': p.reference or (p.invoice.invoice_number if p.invoice_id else 'on-account'),
                'debit': '0',
                'credit': str(p.amount),
                'note': p.method,
            })

        rows.sort(key=lambda r: r['at'])
        running = Decimal('0')
        for r in rows:
            running += Decimal(r['debit']) - Decimal(r['credit'])
            r['balance'] = str(running.quantize(Decimal('0.01')))
            r['at'] = r['at'].isoformat()
        return Response({'rows': rows, 'closing_balance': str(running.quantize(Decimal('0.01')))})


class DealerDashboardView(APIView):
    """
    Single round-trip payload for the dealer overview page.
    """
    permission_classes = [IsActiveDealer]

    def get(self, request):
        u = request.user
        credit = _get_or_create_credit(u)

        orders_qs = Order.objects.filter(user=u)
        orders_total = orders_qs.count()
        pending_orders = orders_qs.filter(
            order_status__in=['CREATED', 'CONFIRMED']
        ).count()
        lifetime_revenue = orders_qs.filter(payment_status='SUCCESS').aggregate(
            s=Sum('total_amount'),
        )['s'] or Decimal('0')

        outstanding = Invoice.objects.filter(customer=u).aggregate(
            d=Sum('amount_due'),
        )['d'] or Decimal('0')

        recent_orders = list(orders_qs.order_by('-created_at')[:5].values(
            'id', 'order_id', 'total_amount', 'order_status',
            'payment_status', 'payment_method', 'created_at',
        ))
        for r in recent_orders:
            r['total_amount'] = str(r['total_amount'])
            r['created_at'] = r['created_at'].isoformat()

        recent_payments = list(
            DealerPayment.objects.filter(dealer=u).select_related('invoice')
            .order_by('-received_at')[:5]
            .values('id', 'amount', 'method', 'reference', 'received_at',
                    'invoice__invoice_number')
        )
        for p in recent_payments:
            p['amount'] = str(p['amount'])
            p['received_at'] = p['received_at'].isoformat()
            p['invoice_number'] = p.pop('invoice__invoice_number', None)

        # 12-month spend series.
        # We pass tzinfo=UTC explicitly so the DB doesn't have to call
        # CONVERT_TZ — which fails on shared MariaDB hosts that don't have
        # the mysql.time_zone_name lookup tables installed (GoDaddy).
        from datetime import timezone as dt_timezone
        from django.db.models.functions import TruncMonth
        cutoff = timezone.now() - timedelta(days=365)
        series = list(
            orders_qs.filter(payment_status='SUCCESS', created_at__gte=cutoff)
            .annotate(month=TruncMonth('created_at', tzinfo=dt_timezone.utc))
            .values('month').annotate(amount=Sum('total_amount'))
            .order_by('month')
        )
        for row in series:
            row['amount'] = str(row['amount'] or Decimal('0'))
            row['month'] = row['month'].strftime('%Y-%m')

        return Response({
            'credit': DealerCreditSerializer(credit).data,
            'totals': {
                'orders': orders_total,
                'pending_orders': pending_orders,
                'lifetime_revenue': str(lifetime_revenue),
                'outstanding': str(outstanding),
            },
            'recent_orders': recent_orders,
            'recent_payments': recent_payments,
            'monthly_spend': series,
            'tier': {
                'slug': u.dealer_tier.slug if u.dealer_tier else None,
                'name': u.dealer_tier.name if u.dealer_tier else None,
                'discount_pct': str(u.dealer_tier.default_discount_pct) if u.dealer_tier else '0',
            },
        })


# ─── Admin-side ──────────────────────────────────────────────────────────────

class AdminDealerCreditView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'dealer_credit'

    def _dealer(self, pk):
        dealer = get_object_or_404(User, pk=pk, role='dealer')
        return dealer

    def get(self, request, pk):
        credit = _get_or_create_credit(self._dealer(pk))
        return Response(DealerCreditSerializer(credit).data)

    def patch(self, request, pk):
        dealer = self._dealer(pk)
        credit = _get_or_create_credit(dealer)
        for field in ('credit_limit', 'terms_days', 'is_active'):
            if field in request.data:
                setattr(credit, field, request.data[field])
        credit.save()
        self.audit_write(request, action='update', target_id=dealer.id,
                         payload={'fields': list(request.data)})
        return Response(DealerCreditSerializer(credit).data)


class AdminDealerPaymentRecordView(AuditedMixin, APIView):
    """
    Record a payment from a dealer. If `invoice` is set, also reduces that
    invoice's `amount_due` and (if it hits zero) the dealer's `amount_used`.
    """
    permission_classes = [IsAdminUser]
    audit_target_type = 'dealer_payment'

    def post(self, request, pk):
        dealer = get_object_or_404(User, pk=pk, role='dealer')
        amount = request.data.get('amount')
        method = request.data.get('method')
        if not amount or method not in dict(DealerPayment.METHOD_CHOICES):
            return Response(
                {'detail': 'Both amount and a valid method are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            amount_dec = Decimal(str(amount))
        except Exception:
            return Response({'detail': 'Invalid amount.'}, status=status.HTTP_400_BAD_REQUEST)
        if amount_dec <= 0:
            return Response({'detail': 'Amount must be positive.'}, status=status.HTTP_400_BAD_REQUEST)

        invoice_id = request.data.get('invoice')
        invoice = None
        if invoice_id:
            try:
                invoice = Invoice.objects.get(pk=invoice_id, customer=dealer)
            except Invoice.DoesNotExist:
                return Response(
                    {'detail': 'Invoice not found for this dealer.'},
                    status=status.HTTP_404_NOT_FOUND,
                )

        from django.db import transaction as db_tx
        with db_tx.atomic():
            payment = DealerPayment.objects.create(
                dealer=dealer,
                invoice=invoice,
                amount=amount_dec,
                method=method,
                reference=request.data.get('reference', ''),
                note=request.data.get('note', ''),
                recorded_by=request.user,
                received_at=request.data.get('received_at') or timezone.now(),
            )

            if invoice is not None:
                # Bump invoice paid / due
                Invoice.objects.filter(pk=invoice.pk).update(
                    amount_paid=invoice.amount_paid + amount_dec,
                    amount_due=max(Decimal('0'), invoice.amount_due - amount_dec),
                )
                invoice.refresh_from_db(fields=['amount_paid', 'amount_due'])

                # If invoice fully paid, release that amount from dealer credit
                if invoice.amount_due == Decimal('0') and invoice.payment_status != 'SUCCESS':
                    invoice.payment_status = 'SUCCESS'
                    invoice.save(update_fields=['payment_status'])
                    credit = _get_or_create_credit(dealer)
                    credit.amount_used = max(Decimal('0'),
                                             credit.amount_used - invoice.grand_total)
                    credit.save(update_fields=['amount_used', 'updated_at'])

        self.audit_write(
            request, action='other', target_id=payment.id,
            payload={'kind': 'dealer_payment_recorded',
                     'dealer': dealer.id, 'amount': str(amount_dec),
                     'invoice': invoice.id if invoice else None},
        )
        return Response(DealerPaymentSerializer(payment).data, status=status.HTTP_201_CREATED)
