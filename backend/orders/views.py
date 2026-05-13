import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from rest_framework.permissions import AllowAny, IsAuthenticated
from users.permissions import IsAdminRole
from django.core.mail import send_mail
from .models import Order, OrderReturn
from .serializers import OrderCreateSerializer, OrderSerializer, OrderStatusUpdateSerializer

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


class OrderCreateView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            order = serializer.save()
            # Try to send confirmation email
            try:
                subject = f"Order Confirmation - {order.order_id}"
                message = f"Hello {order.user_name},\n\nThank you for shopping with FurniShop! Your order #{order.order_id} has been received.\n\nYou can track your order status here: {request.build_absolute_uri('/')}orders/{order.order_id}/\n\nTotal Amount: ₹{order.total_amount}\n\nWarm regards,\nFurniShop Team"
                send_mail(
                    subject,
                    message,
                    'no-reply@furnishop.in',
                    [order.user_email],
                    fail_silently=True,
                )
            except Exception as e:
                logger.error(f"Failed to send order confirmation for {order.order_id}: {e}")
            
            return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        if request.user.is_authenticated:
            orders = Order.objects.filter(user=request.user).prefetch_related('items__product')
        else:
            email = request.query_params.get('email')
            if not email:
                return Response(
                    {'error': 'Email is required for guest order lookup.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            orders = Order.objects.filter(user_email=email).prefetch_related('items__product')
        return Response(OrderSerializer(orders, many=True).data)


class OrderAdminListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAdminRole]
    filterset_fields = ['payment_status', 'order_status']
    search_fields = ['order_id', 'user_email', 'user_name']
    ordering_fields = ['created_at', 'total_amount']
    ordering = ['-created_at']

    def get_queryset(self):
        return Order.objects.prefetch_related('items__product').all()


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
                     .prefetch_related('items__product')
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
