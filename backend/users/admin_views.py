"""
Admin-only customer management endpoints.

  GET    /api/admin/customers/?search=&role=&is_blocked=&ordering=-date_joined
  GET    /api/admin/customers/{id}/    → user + LTV / order-count / last 10 orders
  PATCH  /api/admin/customers/{id}/    → block/unblock, edit phone/name only
"""
from decimal import Decimal

from django.db.models import Sum, Count, Max, Q
from rest_framework import generics, serializers, status
from rest_framework.response import Response
from rest_framework.views import APIView

from audit.mixins import AuditedMixin
from core.permissions import IsAdminUser
from orders.models import Order

from .models import User


class CustomerListSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    order_count = serializers.IntegerField(read_only=True)
    lifetime_value = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    last_order_at = serializers.DateTimeField(read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'email', 'full_name', 'phone', 'role',
            'dealer_status', 'is_blocked', 'is_active',
            'date_joined', 'order_count', 'lifetime_value', 'last_order_at',
        ]

    def get_full_name(self, obj):
        return obj.full_name


class CustomerListView(generics.ListAPIView):
    permission_classes = [IsAdminUser]
    serializer_class = CustomerListSerializer
    search_fields = ['email', 'first_name', 'last_name', 'phone', 'dealer_company_name']
    ordering_fields = ['date_joined', 'email', 'lifetime_value', 'order_count']
    ordering = ['-date_joined']

    def get_queryset(self):
        qs = User.objects.all().annotate(
            order_count=Count('orders', distinct=True),
            lifetime_value=Sum(
                'orders__total_amount',
                filter=Q(orders__payment_status='SUCCESS'),
            ),
            last_order_at=Max('orders__created_at'),
        )
        role = self.request.query_params.get('role')
        if role in ('user', 'dealer', 'admin'):
            qs = qs.filter(role=role)
        is_blocked = self.request.query_params.get('is_blocked')
        if is_blocked in ('true', 'false'):
            qs = qs.filter(is_blocked=(is_blocked == 'true'))
        return qs


class CustomerDetailView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'customer'

    EDITABLE_FIELDS = {'is_blocked', 'phone', 'first_name', 'last_name'}

    def get(self, request, pk):
        try:
            user = User.objects.get(pk=pk)
        except User.DoesNotExist:
            return Response({'detail': 'Customer not found.'}, status=status.HTTP_404_NOT_FOUND)

        agg = user.orders.aggregate(
            order_count=Count('id'),
            lifetime_value=Sum('total_amount', filter=Q(payment_status='SUCCESS')),
            last_order_at=Max('created_at'),
        )
        recent = (
            user.orders.order_by('-created_at')
            .values('id', 'order_id', 'total_amount', 'order_status',
                    'payment_status', 'created_at')[:10]
        )
        return Response({
            'id': user.id,
            'email': user.email,
            'full_name': user.full_name,
            'phone': user.phone,
            'role': user.role,
            'dealer_status': user.dealer_status,
            'dealer_company_name': user.dealer_company_name,
            'dealer_gst_number': user.dealer_gst_number,
            'is_blocked': user.is_blocked,
            'is_active': user.is_active,
            'date_joined': user.date_joined,
            'aggregates': {
                'order_count': agg['order_count'] or 0,
                'lifetime_value': str(agg['lifetime_value'] or Decimal('0')),
                'last_order_at': agg['last_order_at'],
            },
            'recent_orders': list(recent),
        })

    def patch(self, request, pk):
        try:
            user = User.objects.get(pk=pk)
        except User.DoesNotExist:
            return Response({'detail': 'Customer not found.'}, status=status.HTTP_404_NOT_FOUND)

        if user.id == request.user.id and 'is_blocked' in request.data:
            return Response(
                {'detail': 'You cannot block your own account.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        unknown = set(request.data) - self.EDITABLE_FIELDS
        if unknown:
            return Response(
                {'detail': f'Cannot edit fields here: {sorted(unknown)}.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        prev_blocked = user.is_blocked
        for field in self.EDITABLE_FIELDS & set(request.data):
            value = request.data[field]
            if field == 'is_blocked':
                value = bool(value)
            setattr(user, field, value)
        user.save()

        if 'is_blocked' in request.data and bool(request.data['is_blocked']) != prev_blocked:
            self.audit_write(
                request,
                action='block' if user.is_blocked else 'unblock',
                target_id=user.id,
                payload={'email': user.email},
            )
        else:
            self.audit_write(request, action='update', target_id=user.id, payload=request.data)

        return Response({
            'id': user.id, 'email': user.email,
            'full_name': user.full_name, 'phone': user.phone,
            'is_blocked': user.is_blocked,
        })
