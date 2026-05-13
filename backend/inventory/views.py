"""
  GET    /api/inventory/warehouses/                   list active
  POST   /api/inventory/warehouses/                   create
  GET    /api/inventory/levels/?warehouse=&low=true   list with filters
  POST   /api/inventory/levels/                       seed one (product, [variant,] warehouse, qty)
  GET    /api/inventory/levels/{id}/movements/        ledger
  POST   /api/inventory/adjust/                       {stock_level, delta, reason, note}
  POST   /api/inventory/seed-all/                     bulk-create empty rows for every (product × warehouse)
  GET    /api/inventory/low-stock/                    items at-or-below threshold
"""
from django.core.exceptions import ValidationError
from django.db import transaction
from rest_framework import generics, serializers, status
from rest_framework.response import Response
from rest_framework.views import APIView

from audit.mixins import AuditedMixin
from core.permissions import IsAdminUser
from products.models import Product

from .models import Warehouse, StockLevel, StockMovement


class WarehouseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Warehouse
        fields = ['id', 'name', 'code', 'address', 'is_active', 'created_at']


class StockLevelSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_sku = serializers.CharField(source='product.sku', read_only=True)
    variant_label = serializers.SerializerMethodField()
    warehouse_code = serializers.CharField(source='warehouse.code', read_only=True)
    warehouse_name = serializers.CharField(source='warehouse.name', read_only=True)
    is_low = serializers.BooleanField(read_only=True)

    class Meta:
        model = StockLevel
        fields = [
            'id', 'product', 'product_name', 'product_sku',
            'variant', 'variant_label',
            'warehouse', 'warehouse_code', 'warehouse_name',
            'quantity', 'low_threshold', 'is_low', 'updated_at',
        ]

    def get_variant_label(self, obj):
        if not obj.variant_id:
            return None
        return f'{obj.variant.option_name}: {obj.variant.option_value}'


class StockMovementSerializer(serializers.ModelSerializer):
    actor_email = serializers.CharField(source='actor.email', read_only=True, default=None)

    class Meta:
        model = StockMovement
        fields = [
            'id', 'stock_level', 'delta', 'reason',
            'reference', 'note', 'actor_email', 'created_at',
        ]


class WarehouseListView(generics.ListCreateAPIView):
    permission_classes = [IsAdminUser]
    serializer_class = WarehouseSerializer

    def get_queryset(self):
        return Warehouse.objects.all()


class StockLevelListView(generics.ListCreateAPIView):
    """
    GET: list stock levels with optional filters.
    POST: seed one stock level — payload {product, warehouse, [variant], quantity, low_threshold}.
    """
    permission_classes = [IsAdminUser]
    serializer_class = StockLevelSerializer

    def get_queryset(self):
        qs = StockLevel.objects.select_related(
            'product', 'variant', 'warehouse'
        ).order_by('product__name')
        warehouse = self.request.query_params.get('warehouse')
        if warehouse:
            qs = qs.filter(warehouse_id=warehouse)
        if self.request.query_params.get('low') in ('1', 'true'):
            from django.db.models import F
            qs = qs.filter(quantity__lte=F('low_threshold'))
        return qs

    def create(self, request, *args, **kwargs):
        data = request.data
        try:
            product_id = int(data.get('product'))
            warehouse_id = int(data.get('warehouse'))
        except (TypeError, ValueError):
            return Response(
                {'detail': 'Both product and warehouse are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        variant_id = data.get('variant') or None
        try:
            quantity = max(0, int(data.get('quantity', 0)))
            low_threshold = max(0, int(data.get('low_threshold', 5)))
        except (TypeError, ValueError):
            return Response(
                {'detail': "'quantity' and 'low_threshold' must be integers."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        defaults = {'quantity': quantity, 'low_threshold': low_threshold}
        try:
            level, created = StockLevel.objects.get_or_create(
                product_id=product_id,
                warehouse_id=warehouse_id,
                variant_id=variant_id,
                defaults=defaults,
            )
        except Exception as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_400_BAD_REQUEST)

        if not created:
            # If the row already existed, treat as an update of the seed values.
            level.quantity = quantity
            level.low_threshold = low_threshold
            level.save(update_fields=['quantity', 'low_threshold', 'updated_at'])

        return Response(
            StockLevelSerializer(level).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class StockLevelBulkSeedView(APIView):
    """
    POST /api/inventory/seed-all/
      body: {warehouse: <id>, [quantity: 0, low_threshold: 5, only_missing: true]}
    Creates a StockLevel row for every active, non-deleted product (no
    variants — those need explicit seeding) in the given warehouse. Idempotent
    when `only_missing` is true (default).
    """
    permission_classes = [IsAdminUser]

    def post(self, request):
        try:
            warehouse_id = int(request.data.get('warehouse'))
        except (TypeError, ValueError):
            return Response(
                {'detail': "'warehouse' is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            warehouse = Warehouse.objects.get(pk=warehouse_id, is_active=True)
        except Warehouse.DoesNotExist:
            return Response(
                {'detail': 'Active warehouse not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        try:
            qty = max(0, int(request.data.get('quantity', 0)))
            low = max(0, int(request.data.get('low_threshold', 5)))
        except (TypeError, ValueError):
            return Response(
                {'detail': "'quantity' and 'low_threshold' must be integers."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        only_missing = request.data.get('only_missing', True)

        eligible = Product.objects.filter(is_deleted=False, status='active')
        existing_product_ids = set(
            StockLevel.objects.filter(warehouse=warehouse, variant__isnull=True)
            .values_list('product_id', flat=True)
        )

        created_count = 0
        updated_count = 0
        with transaction.atomic():
            for p in eligible:
                if p.id in existing_product_ids:
                    if not only_missing:
                        StockLevel.objects.filter(
                            warehouse=warehouse, product=p, variant__isnull=True
                        ).update(quantity=qty, low_threshold=low)
                        updated_count += 1
                    continue
                StockLevel.objects.create(
                    product=p, warehouse=warehouse,
                    quantity=qty, low_threshold=low,
                )
                created_count += 1

        return Response({
            'warehouse': warehouse.code,
            'created': created_count,
            'updated': updated_count,
            'skipped': eligible.count() - created_count - updated_count,
        }, status=status.HTTP_201_CREATED)


class StockLevelMovementsView(generics.ListAPIView):
    permission_classes = [IsAdminUser]
    serializer_class = StockMovementSerializer

    def get_queryset(self):
        return StockMovement.objects.filter(
            stock_level_id=self.kwargs['pk']
        ).select_related('actor').order_by('-created_at')


class StockAdjustView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'stock_movement'

    def post(self, request):
        sl_id = request.data.get('stock_level')
        delta = request.data.get('delta')
        reason = request.data.get('reason', 'adjustment')
        note = request.data.get('note', '')
        reference = request.data.get('reference', '')

        if not sl_id or delta in (None, ''):
            return Response(
                {'detail': "Both 'stock_level' and 'delta' are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            delta_int = int(delta)
        except (TypeError, ValueError):
            return Response(
                {'detail': "'delta' must be an integer."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if reason not in dict(StockMovement.REASON_CHOICES):
            return Response(
                {'detail': f"'reason' must be one of {list(dict(StockMovement.REASON_CHOICES))}."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            level = StockLevel.objects.get(pk=sl_id)
        except StockLevel.DoesNotExist:
            return Response({'detail': 'Stock level not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            mvt = StockMovement(
                stock_level=level, delta=delta_int, reason=reason,
                reference=reference, note=note, actor=request.user,
            )
            mvt.save()
        except ValidationError as exc:
            return Response({'detail': exc.messages[0]}, status=status.HTTP_400_BAD_REQUEST)

        self.audit_write(
            request, action='update', target_id=mvt.id,
            payload={'stock_level': sl_id, 'delta': delta_int, 'reason': reason},
        )
        return Response(StockMovementSerializer(mvt).data, status=status.HTTP_201_CREATED)


class LowStockView(generics.ListAPIView):
    permission_classes = [IsAdminUser]
    serializer_class = StockLevelSerializer

    def get_queryset(self):
        from django.db.models import F
        return (
            StockLevel.objects
            .filter(quantity__lte=F('low_threshold'))
            .select_related('product', 'variant', 'warehouse')
            .order_by('quantity')
        )
