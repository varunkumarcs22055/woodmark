import logging
from decimal import Decimal
from datetime import timedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from rest_framework.permissions import AllowAny, IsAuthenticated
from users.permissions import IsAdminRole
from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone
from audit.mixins import AuditedMixin
from .models import Order, OrderReturn
from .serializers import (
    OrderCreateSerializer, OrderSerializer, OrderStatusUpdateSerializer,
    OrderReturnSerializer, RefundSerializer,
)

CANCEL_WINDOW_MINUTES = 60

logger = logging.getLogger(__name__)


def _is_owner_or_admin(request, order):
    """Auth check shared by self-service cancel + return endpoints."""
    user = request.user if request.user.is_authenticated else None
    if user is None:
        return False
    if order.user_id == user.id:
        return True
    if getattr(user, 'role', '') == 'admin' or user.is_superuser:
        return True
    return False


def _notify_return_email(order, status_label, note=''):
    """Best-effort return status email (non-blocking)."""
    try:
        subject = f'Return Update — {order.order_id} ({status_label})'
        body = (
            f'Hello {order.user_name},\n\n'
            f'Your return request for order {order.order_id} is now: {status_label}.\n'
            + (f'Note: {note}\n' if note else '')
            + '\nThank you,\nFurnoTech Support\n'
        )
        send_mail(subject, body, settings.DEFAULT_FROM_EMAIL,
                  [order.user_email], fail_silently=True)
    except Exception:
        logger.exception('Return status email failed for %s', order.order_id)


class OrderCreateView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            order = serializer.save()
            # Fire the confirmation email + SMS + ERP sync the moment the
            # order is committed for every "no gateway redirect" path:
            #   COD    — payment collected on delivery, email shows amount to pay
            #   credit — dealer credit terms; email shows amount due + Net-N days
            #   wallet — already debited in serializer.create(); email confirms
            # Razorpay orders skip this branch — their notifications + ERP fire
            # from confirm_order_and_sync_erp once the signature verifies, so
            # we don't notify or push to ERP before the money actually lands.
            method = (order.payment_method or '').lower()
            if method in ('cod', 'credit', 'wallet'):
                # 1. ERP sync — the warehouse must see the order, otherwise
                #    nothing ships. Previously only Razorpay-paid orders made
                #    it into ERP; COD/credit/wallet were invisible to fulfilment.
                try:
                    from services.erp import send_order_to_erp
                    order_with_items = order.__class__.objects.prefetch_related(
                        'items__product',
                    ).get(pk=order.pk)
                    erp = send_order_to_erp(order_with_items)
                    if erp and erp.get('erp_order_id'):
                        order.erp_order_id = erp['erp_order_id']
                        order.erp_sync_status = 'synced'
                    else:
                        order.erp_sync_status = 'failed'
                    # COD/credit/wallet orders are committed — bump to
                    # CONFIRMED so the status timeline shows progress and the
                    # admin queue surfaces them. The order_status field stays
                    # PENDING/CREATED for Razorpay until verify clears it.
                    if order.order_status == 'CREATED':
                        order.order_status = 'CONFIRMED'
                    order.save(update_fields=['erp_order_id', 'erp_sync_status', 'order_status'])
                except Exception:
                    logger.exception('%s ERP sync failed for %s',
                                     method.upper(), order.order_id)

                # 2. Email + SMS confirmation. Idempotent via Payment.*_sent_at
                #    so a retry never double-sends.
                try:
                    from payments.notifications import (
                        send_order_confirmation_email,
                        send_order_confirmation_sms,
                    )
                    from payments.models import Payment
                    payment, _ = Payment.objects.get_or_create(
                        order=order,
                        defaults={'amount': order.total_amount},
                    )
                    from django.utils import timezone as _tz
                    if not payment.email_sent_at and send_order_confirmation_email(order):
                        payment.email_sent_at = _tz.now()
                        payment.save(update_fields=['email_sent_at'])
                    if not payment.sms_sent_at and send_order_confirmation_sms(order):
                        payment.sms_sent_at = _tz.now()
                        payment.save(update_fields=['sms_sent_at'])
                except Exception:
                    logger.exception('%s confirmation notify failed for %s',
                                     method.upper(), order.order_id)

            return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        if request.user.is_authenticated:
            orders = Order.objects.filter(user=request.user).prefetch_related(
                'items__product', 'returns__refunds', 'refunds',
            )
        else:
            email = request.query_params.get('email')
            if not email:
                return Response(
                    {'error': 'Email is required for guest order lookup.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            orders = Order.objects.filter(user_email=email).prefetch_related(
                'items__product', 'returns__refunds', 'refunds',
            )
        return Response(OrderSerializer(orders, many=True).data)


class OrderAdminListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAdminRole]
    filterset_fields = ['payment_status', 'order_status']
    search_fields = ['order_id', 'user_email', 'user_name']
    ordering_fields = ['created_at', 'total_amount']
    ordering = ['-created_at']

    def get_queryset(self):
        return Order.objects.prefetch_related(
            'items__product', 'returns__refunds', 'refunds',
        ).all()


class OrderStatusUpdateView(APIView):
    permission_classes = [IsAdminRole]

    def patch(self, request, pk):
        try:
            order = Order.objects.get(pk=pk)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = OrderStatusUpdateSerializer(order, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            logger.info(f'Order {order.order_id} status → {order.order_status} by {request.user.email}')
            return Response(OrderSerializer(order).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderDetailView(APIView):
    """
    GET /api/orders/<order_id>/ — detail for the order's owner or admin.

    Looks up by the human-readable order_id (e.g. ORD-XXXX), not pk, so the
    URL is shareable from the order confirmation screen.
    """
    permission_classes = [AllowAny]

    def get(self, request, order_id):
        try:
            order = (Order.objects
                     .prefetch_related('items__product', 'returns__refunds', 'refunds')
                     .get(order_id=order_id))
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Auth gate: owner OR admin OR matching guest email.
        user = request.user if request.user.is_authenticated else None
        is_owner = user is not None and order.user_id == user.id
        is_admin = user is not None and (getattr(user, 'role', '') == 'admin' or user.is_superuser)
        guest_email = request.query_params.get('email', '').strip().lower()
        is_guest_match = (order.user_id is None
                          and guest_email
                          and guest_email == (order.user_email or '').lower())

        if not (is_owner or is_admin or is_guest_match):
            return Response({'error': 'Not authorized to view this order.'},
                            status=status.HTTP_403_FORBIDDEN)

        return Response(OrderSerializer(order).data)


class OrderReorderView(APIView):
    """
    POST /api/orders/<order_id>/reorder/  — clones an order's lines into a
    new CREATED order at *current* prices (not the original line price).

    Useful for dealer reorder buttons. Skips lines whose product is now
    out of stock or unpublished, and reports what was skipped in `skipped`.
    """
    from rest_framework.permissions import IsAuthenticated
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        try:
            original = Order.objects.prefetch_related('items__product').get(order_id=order_id)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        if original.user_id != request.user.id and getattr(request.user, 'role', '') != 'admin':
            return Response({'error': 'Not authorized to reorder this.'},
                            status=status.HTTP_403_FORBIDDEN)

        items = []
        skipped = []
        for line in original.items.all():
            p = line.product
            if p is None or getattr(p, 'is_deleted', False):
                skipped.append({'name': line.product_name if hasattr(line, 'product_name') else 'unknown',
                                'reason': 'product unavailable'})
                continue
            if getattr(p, 'status', 'active') != 'active':
                skipped.append({'name': p.name, 'reason': 'product no longer published'})
                continue
            qty = min(line.quantity, p.stock) if p.stock else 0
            if qty <= 0:
                skipped.append({'name': p.name, 'reason': 'out of stock'})
                continue
            moq = getattr(p, 'min_order_quantity', 1) or 1
            if qty < moq:
                qty = moq
                if qty > p.stock:
                    skipped.append({'name': p.name, 'reason': f'cannot meet MOQ of {moq}'})
                    continue
            items.append({'product_id': p.id, 'quantity': qty})

        if not items:
            return Response(
                {'error': 'None of the original items can be reordered.', 'skipped': skipped},
                status=status.HTTP_400_BAD_REQUEST,
            )

        payload = {
            'user_name': original.user_name,
            'user_email': original.user_email,
            'phone': original.phone,
            'address': original.address,
            'payment_method': original.payment_method or 'razorpay',
            'po_number': original.po_number or '',
            'dealer_note': f'Reorder of {original.order_id}',
            'preferred_carrier': original.preferred_carrier or '',
            'items': items,
        }
        serializer = OrderCreateSerializer(data=payload, context={'request': request})
        if not serializer.is_valid():
            return Response({'error': 'Could not create reorder.',
                             'detail': serializer.errors, 'skipped': skipped},
                            status=status.HTTP_400_BAD_REQUEST)
        new_order = serializer.save()
        return Response({
            'order': OrderSerializer(new_order).data,
            'skipped': skipped,
        }, status=status.HTTP_201_CREATED)


class OrderCancelView(APIView):
    """
    POST /api/orders/<order_id>/cancel/   {reason?}

    Self-service cancellation by the buyer (or admin). Only allowed while the
    order is in CREATED state — once it's CONFIRMED the warehouse has already
    started picking, and a refund/return flow must be used instead.

    Side effects:
      - Flips order_status to CANCELLED and records `cancellation_reason`.
      - Restocks every line item (`Product.stock += quantity`).
      - If payment had already succeeded, payment_status becomes 'FAILED'
        so the admin's refund queue picks it up.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        try:
            order = Order.objects.prefetch_related('items__product').get(order_id=order_id)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not _is_owner_or_admin(request, order):
            return Response({'error': 'Not authorized to cancel this order.'},
                            status=status.HTTP_403_FORBIDDEN)

        if order.order_status not in ('CREATED', 'CONFIRMED'):
            return Response(
                {'error': f"Cannot cancel an order in '{order.order_status}' state. "
                          f"For shipped/delivered orders, request a return instead."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # 1-hour self-service cancellation window.
        deadline = order.created_at + timedelta(minutes=CANCEL_WINDOW_MINUTES)
        if timezone.now() > deadline:
            return Response(
                {'error': 'Cancellation window expired. Please request a return instead.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Block cancellation if a return is already in progress.
        if order.returns.filter(status__in=('requested', 'approved', 'received', 'refunded')).exists():
            return Response(
                {'error': 'A return request is already in progress for this order.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        reason = (request.data.get('reason') or '').strip()[:500]

        from django.db.models import F
        from products.models import Product
        for line in order.items.all():
            Product.objects.filter(pk=line.product_id).update(
                stock=F('stock') + line.quantity,
            )

        order.order_status = 'CANCELLED'
        order.cancellation_reason = reason or 'Cancelled by buyer.'
        if order.payment_status == 'SUCCESS':
            # Mark payment as needing refund — admin reviews in /admin/orders.
            order.payment_status = 'FAILED'
        order.save(update_fields=['order_status', 'cancellation_reason',
                                  'payment_status', 'updated_at'])

        logger.info('order %s cancelled by user_id=%s reason=%s',
                    order.order_id, request.user.id, reason)
        return Response(OrderSerializer(order).data)


class OrderReturnRequestView(APIView):
    """
    POST /api/orders/<order_id>/return/   {reason}

    Buyer-initiated return request. Only valid once the order has been
    delivered (or shipped — some buyers cancel mid-shipment). Creates an
    `OrderReturn` row in 'requested' status; admin processes it from
    /admin-dashboard/orders → Returns tab.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        try:
            order = Order.objects.get(order_id=order_id)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not _is_owner_or_admin(request, order):
            return Response({'error': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        if order.order_status not in ('SHIPPED', 'DELIVERED'):
            return Response(
                {'error': f"Returns can only be requested for shipped/delivered orders. "
                          f"Current status: {order.order_status}."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if order.returns.filter(status__in=('requested', 'approved', 'received')).exists():
            return Response(
                {'error': 'A return request is already in progress for this order.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        reason = (request.data.get('reason') or '').strip()
        if not reason:
            return Response({'reason': ['Please tell us why you\'re returning the order.']},
                            status=status.HTTP_400_BAD_REQUEST)

        ret = OrderReturn.objects.create(
            order=order,
            requested_by=request.user,
            reason=reason[:2000],
            status='requested',
        )
        logger.info('return requested for order %s by user_id=%s ret_id=%s',
                    order.order_id, request.user.id, ret.id)
        return Response({
            'id': ret.id,
            'order_id': order.order_id,
            'status': ret.status,
            'reason': ret.reason,
            'created_at': ret.created_at.isoformat(),
        }, status=status.HTTP_201_CREATED)


class AdminReturnListView(generics.ListAPIView):
    permission_classes = [IsAdminRole]
    serializer_class = OrderReturnSerializer
    ordering_fields = ['created_at', 'status']
    ordering = ['-created_at']

    def get_queryset(self):
        qs = (OrderReturn.objects
              .select_related('order', 'requested_by')
              .prefetch_related('refunds'))
        status_q = self.request.query_params.get('status')
        if status_q:
            qs = qs.filter(status=status_q)
        order_id = self.request.query_params.get('order_id')
        if order_id:
            qs = qs.filter(order__order_id=order_id)
        email = self.request.query_params.get('email')
        if email:
            qs = qs.filter(order__user_email__icontains=email)
        return qs


class AdminReturnDetailView(AuditedMixin, APIView):
    permission_classes = [IsAdminRole]
    audit_target_type = 'order_return'

    ALLOWED = {
        'requested': {'approved', 'rejected'},
        'approved': {'received', 'rejected'},
        'received': {'refunded'},
        'rejected': set(),
        'refunded': set(),
    }

    def patch(self, request, pk):
        try:
            ret = OrderReturn.objects.select_related('order').get(pk=pk)
        except OrderReturn.DoesNotExist:
            return Response({'detail': 'Return not found.'}, status=status.HTTP_404_NOT_FOUND)
        prev_status = ret.status
        new_status = request.data.get('status')
        if new_status:
            if new_status == 'refunded':
                return Response(
                    {'detail': 'Use the refund endpoint to mark refunded.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            allowed = self.ALLOWED.get(ret.status, set())
            if new_status not in allowed:
                return Response(
                    {'detail': f'Cannot move from {ret.status} to {new_status}.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            ret.status = new_status

        if 'admin_note' in request.data:
            ret.admin_note = (request.data.get('admin_note') or '')[:2000]
        if 'refund_amount' in request.data:
            try:
                ret.refund_amount = Decimal(str(request.data.get('refund_amount') or '0'))
            except Exception:
                return Response({'detail': 'Invalid refund amount.'}, status=status.HTTP_400_BAD_REQUEST)
            if ret.refund_amount > ret.order.total_amount:
                return Response({'detail': 'Refund amount cannot exceed order total.'},
                                status=status.HTTP_400_BAD_REQUEST)

        ret.save(update_fields=['status', 'admin_note', 'refund_amount', 'updated_at'])
        self.audit_write(request, action='update', target_id=ret.id,
                         payload={'status': ret.status})
        if new_status and new_status != prev_status:
            _notify_return_email(ret.order, ret.status, ret.admin_note or '')
        return Response(OrderReturnSerializer(ret).data)


class AdminReturnRefundView(AuditedMixin, APIView):
    permission_classes = [IsAdminRole]
    audit_target_type = 'refund'

    def post(self, request, pk):
        try:
            ret = OrderReturn.objects.select_related('order').get(pk=pk)
        except OrderReturn.DoesNotExist:
            return Response({'detail': 'Return not found.'}, status=status.HTTP_404_NOT_FOUND)

        if ret.status not in ('approved', 'received'):
            return Response(
                {'detail': 'Return must be approved/received before refunding.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        amount = request.data.get('amount') or ret.refund_amount or ret.order.total_amount
        try:
            amount_dec = Decimal(str(amount))
        except Exception:
            return Response({'detail': 'Invalid amount.'}, status=status.HTTP_400_BAD_REQUEST)
        if amount_dec <= 0:
            return Response({'detail': 'Refund amount must be positive.'}, status=status.HTTP_400_BAD_REQUEST)
        if amount_dec > ret.order.total_amount:
            return Response({'detail': 'Refund amount cannot exceed order total.'},
                            status=status.HTTP_400_BAD_REQUEST)

        # Idempotent: return existing refund if already present.
        existing = ret.refunds.order_by('-created_at').first()
        if existing and existing.status in ('pending', 'success'):
            return Response(RefundSerializer(existing).data)

        from payments.refunds import create_refund
        refund = create_refund(
            order=ret.order,
            amount=amount_dec,
            return_request=ret,
            reason=request.data.get('note', '') or 'Return approved',
        )

        ret.refund_amount = amount_dec
        if refund.status == 'success':
            ret.status = 'refunded'
        ret.save(update_fields=['refund_amount', 'status', 'updated_at'])

        if refund.status == 'success':
            _notify_return_email(ret.order, 'refunded', request.data.get('note', '') or '')

        self.audit_write(request, action='refund', target_id=refund.id,
                         payload={'order_id': ret.order.order_id, 'amount': str(amount_dec)})
        return Response(RefundSerializer(refund).data)
