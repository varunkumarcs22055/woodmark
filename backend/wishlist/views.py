"""
  GET    /api/wishlist/                    list (current user)
  POST   /api/wishlist/{product_id}/       idempotent add
  DELETE /api/wishlist/{product_id}/       remove
"""
from rest_framework import generics, serializers, status
from rest_framework.permissions import IsAuthenticated
from users.permissions import IsAdminRole
from rest_framework.response import Response
from rest_framework.views import APIView

from products.models import Product
from orders.models import Order
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


class AdminAllWishlistsView(APIView):
    """
    GET /api/wishlist/admin/all/?search=&page=&page_size=

    Browse every wishlist item across every user. Useful for spotting
    which products are heavily wishlisted (purchasing signal) and which
    customers are window-shopping which categories (retargeting signal).

    Response:
      {
        count, page, page_size, total_pages,
        results: [{
          id, added_at,
          user: {id, email, name, phone},
          product: {id, slug, name, image_url, price, category},
        }, ...]
      }

    `search` matches against user.email / user.full_name / product.name.
    """
    permission_classes = [IsAdminRole]

    def get(self, request):
        from django.db.models import Q
        from django.core.paginator import Paginator

        search = (request.query_params.get('search') or '').strip()
        # Price range filters operate on the wishlisted product's current
        # price. Use this to find e.g. "all wishlisted items priced >= 50k"
        # or "users coveting affordable products under 5k".
        min_price = request.query_params.get('min_price')
        max_price = request.query_params.get('max_price')

        try:
            page = max(1, int(request.query_params.get('page', 1)))
        except (TypeError, ValueError):
            page = 1
        try:
            page_size = min(100, max(5, int(request.query_params.get('page_size', 25))))
        except (TypeError, ValueError):
            page_size = 25

        qs = (WishlistItem.objects
              .select_related('user', 'product', 'product__category', 'variant')
              .order_by('-added_at'))
        if search:
            qs = qs.filter(
                Q(user__email__icontains=search)
                | Q(user__full_name__icontains=search)
                | Q(product__name__icontains=search)
            )
        if min_price:
            try:
                qs = qs.filter(product__price__gte=float(min_price))
            except (TypeError, ValueError):
                pass
        if max_price:
            try:
                qs = qs.filter(product__price__lte=float(max_price))
            except (TypeError, ValueError):
                pass

        paginator = Paginator(qs, page_size)
        page_obj = paginator.get_page(page)
        results = []
        for w in page_obj.object_list:
            results.append({
                'id': w.id,
                'added_at': w.added_at,
                'user': {
                    'id': w.user_id,
                    'email': w.user.email,
                    'name': w.user.full_name or '',
                    'phone': getattr(w.user, 'phone', '') or '',
                },
                'product': {
                    'id': w.product_id,
                    'slug': w.product.slug,
                    'name': w.product.name,
                    'image_url': w.product.image_url or '',
                    'price': float(w.product.price or 0),
                    'category': w.product.category.name if w.product.category else '',
                },
            })
        return Response({
            'count': paginator.count,
            'page': page_obj.number,
            'page_size': page_size,
            'total_pages': paginator.num_pages,
            'results': results,
        })


class AdminHighValueWishlistView(APIView):
    """
    GET /api/wishlist/admin/high-value/?min_value=50000

    Returns users whose wishlisted-product total is >= min_value, ranked by
    that total. Use this from the admin SMS / newsletter screens to import
    a targeting list ("send 10%-off SMS to anyone whose wishlist is >= 50k").

    Response shape:
      {
        threshold: 50000,
        count: <n>,
        results: [
          {user_id, name, email, phone, wishlist_value, item_count}
        ]
      }
    """
    permission_classes = [IsAdminRole]

    def get(self, request):
        from decimal import Decimal
        from django.db.models import Sum, Count, F
        from django.contrib.auth import get_user_model

        try:
            min_value = Decimal(request.query_params.get('min_value', '50000'))
        except Exception:
            min_value = Decimal('50000')

        # Sum the *effective* price of each wishlisted product per user.
        # We use product.price directly (post-discount unit). Variants would
        # complicate this — fall back to product price if variant has none.
        rows = (
            WishlistItem.objects
            .values('user_id')
            .annotate(
                wishlist_value=Sum('product__price'),
                item_count=Count('id'),
            )
            .filter(wishlist_value__gte=min_value)
            .order_by('-wishlist_value')
        )
        user_ids = [r['user_id'] for r in rows]
        users = {
            u.pk: u for u in get_user_model().objects.filter(pk__in=user_ids)
        }
        results = []
        for r in rows:
            u = users.get(r['user_id'])
            if not u:
                continue
            results.append({
                'user_id': u.pk,
                'name': u.full_name or '',
                'email': u.email,
                'phone': getattr(u, 'phone', '') or '',
                'wishlist_value': float(r['wishlist_value'] or 0),
                'item_count': r['item_count'],
            })
        return Response({
            'threshold': float(min_value),
            'count': len(results),
            'results': results,
        })


class AdminWishlistByOrderView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request, order_id):
        try:
            order = Order.objects.select_related('user').get(pk=order_id)
        except Order.DoesNotExist:
            return Response({'detail': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not order.user_id:
            return Response({'count': 0, 'results': [], 'guest': True})

        qs = (WishlistItem.objects
              .filter(user=order.user)
              .select_related('product', 'product__category', 'variant'))
        data = WishlistItemSerializer(qs, many=True, context={'request': request}).data
        return Response({'count': len(data), 'results': data, 'guest': False})
