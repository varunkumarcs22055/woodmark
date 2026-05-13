"""
Admin Category management.

  GET    /api/categories/admin/        list
  POST   /api/categories/admin/        create
  GET    /api/categories/admin/{id}/   detail
  PATCH  /api/categories/admin/{id}/   update
  DELETE /api/categories/admin/{id}/   soft (deactivate) if products exist; hard otherwise
  GET    /api/categories/tree/         nested tree (depth cap = 3)
"""
from rest_framework import serializers, status
from rest_framework.response import Response
from rest_framework.views import APIView

from audit.mixins import AuditedMixin
from core.permissions import IsAdminUser

from .models import Category


MAX_TREE_DEPTH = 3


class CategoryAdminSerializer(serializers.ModelSerializer):
    product_count = serializers.IntegerField(source='products.count', read_only=True)
    banner_url = serializers.CharField(read_only=True)
    child_count = serializers.IntegerField(source='children.count', read_only=True)

    class Meta:
        model = Category
        fields = [
            'id', 'name', 'slug', 'description',
            'parent', 'banner_url', 'is_active', 'sort_order',
            'product_count', 'child_count', 'created_at',
        ]
        read_only_fields = ['slug', 'banner_url', 'created_at']

    def validate(self, data):
        # Cycle check: parent cannot be self or a descendant of self.
        parent = data.get('parent')
        if parent is None:
            return data
        instance = getattr(self, 'instance', None)
        if instance and parent.pk == instance.pk:
            raise serializers.ValidationError({'parent': 'A category cannot be its own parent.'})
        if instance:
            node = parent
            seen = set()
            while node is not None and node.pk not in seen:
                if node.pk == instance.pk:
                    raise serializers.ValidationError(
                        {'parent': 'Cycle: parent is a descendant of this category.'}
                    )
                seen.add(node.pk)
                node = node.parent
        return data


class CategoryAdminListView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'category'

    def get(self, request):
        qs = Category.objects.all().order_by('sort_order', 'name')
        return Response(CategoryAdminSerializer(qs, many=True).data)

    def post(self, request):
        ser = CategoryAdminSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        obj = ser.save()
        self.audit_write(request, action='create', target_id=obj.id, payload=request.data)
        return Response(CategoryAdminSerializer(obj).data, status=status.HTTP_201_CREATED)


class CategoryAdminDetailView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'category'

    def _get(self, pk):
        try:
            return Category.objects.get(pk=pk)
        except Category.DoesNotExist:
            return None

    def get(self, request, pk):
        obj = self._get(pk)
        if obj is None:
            return Response({'detail': 'Category not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(CategoryAdminSerializer(obj).data)

    def patch(self, request, pk):
        obj = self._get(pk)
        if obj is None:
            return Response({'detail': 'Category not found.'}, status=status.HTTP_404_NOT_FOUND)
        ser = CategoryAdminSerializer(obj, data=request.data, partial=True)
        ser.is_valid(raise_exception=True)
        ser.save()
        self.audit_write(request, action='update', target_id=obj.id, payload=request.data)
        return Response(ser.data)

    def delete(self, request, pk):
        obj = self._get(pk)
        if obj is None:
            return Response({'detail': 'Category not found.'}, status=status.HTTP_404_NOT_FOUND)
        if obj.children.exists():
            return Response(
                {'detail': 'Cannot delete: child categories exist. Reassign or remove them first.'},
                status=status.HTTP_409_CONFLICT,
            )
        if obj.products.exists():
            obj.is_active = False
            obj.save(update_fields=['is_active'])
            self.audit_write(request, action='delete', target_id=obj.id,
                             payload={'soft': True, 'reason': 'has products'})
            return Response({'soft_deleted': True}, status=status.HTTP_200_OK)
        self.audit_write(request, action='delete', target_id=obj.id, payload={'soft': False})
        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


def _serialize_tree(node, depth):
    if depth > MAX_TREE_DEPTH:
        return None
    return {
        'id': node.id,
        'name': node.name,
        'slug': node.slug,
        'is_active': node.is_active,
        'product_count': node.products.count(),
        'children': [
            sub for sub in (
                _serialize_tree(child, depth + 1)
                for child in node.children.all().order_by('sort_order', 'name')
            ) if sub is not None
        ],
    }


class CategoryTreeView(APIView):
    """Public — used by the frontend nav and the admin tree view."""
    permission_classes = []

    def get(self, request):
        roots = Category.objects.filter(parent__isnull=True).order_by('sort_order', 'name')
        return Response([_serialize_tree(n, 1) for n in roots])
