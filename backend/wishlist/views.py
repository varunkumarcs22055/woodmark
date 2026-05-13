"""
  GET    /api/wishlist/                    list (current user)
  POST   /api/wishlist/{product_id}/       idempotent add
  DELETE /api/wishlist/{product_id}/       remove
"""
from rest_framework import generics, serializers, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from products.models import Product
from products.serializers import ProductListSerializer

from .models import WishlistItem


class WishlistItemSerializer(serializers.ModelSerializer):
    product_detail = ProductListSerializer(source='product', read_only=True)

    class Meta:
        model = WishlistItem
        fields = ['id', 'product', 'product_detail', 'variant', 'added_at']
        read_only_fields = ['added_at']


class WishlistListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = WishlistItemSerializer
    pagination_class = None

    def get_queryset(self):
        return (
            WishlistItem.objects
            .filter(user=self.request.user)
            .select_related('product', 'product__category', 'variant')
        )


class WishlistToggleView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, product_id):
        try:
            product = Product.objects.get(pk=product_id)
        except Product.DoesNotExist:
            return Response({'detail': 'Product not found.'}, status=status.HTTP_404_NOT_FOUND)
        obj, created = WishlistItem.objects.get_or_create(
            user=request.user, product=product, variant=None,
        )
        return Response(
            {'wishlisted': True, 'created': created, 'id': obj.id},
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    def delete(self, request, product_id):
        deleted, _ = WishlistItem.objects.filter(
            user=request.user, product_id=product_id, variant=None,
        ).delete()
        return Response({'wishlisted': False, 'deleted': bool(deleted)})
