import logging

from django.db.models import Q
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from users.permissions import IsAdminRole
from django.db.models import Count
from .models import Product, Category, ProductMedia, DeliveryRule, Tag, StockAlert
from .serializers import (
    ProductListSerializer, ProductDetailSerializer,
    CategorySerializer, ProductWriteSerializer, TagSerializer,
)
from .filters import ProductFilter

logger = logging.getLogger(__name__)


class StockAlertSubscribeView(APIView):
    """
    POST /api/products/<slug>/stock-alert/  {email}

    Anyone (guest or signed-in) can subscribe to a "notify me when in stock"
    alert. Idempotent — a duplicate (product, email) silently merges with the
    open subscription instead of erroring. Logged-in users get the user FK
    attached so they can see / unsubscribe later.
    """
    permission_classes = [AllowAny]

    def post(self, request, slug):
        try:
            product = Product.objects.get(slug=slug, is_deleted=False)
        except Product.DoesNotExist:
            return Response({'error': 'Product not found.'},
                            status=status.HTTP_404_NOT_FOUND)

        email = (request.data.get('email') or '').strip().lower()
        if request.user.is_authenticated and not email:
            email = request.user.email
        if not email or '@' not in email:
            return Response({'email': ['Enter a valid email.']},
                            status=status.HTTP_400_BAD_REQUEST)

        defaults = {
            'user': request.user if request.user.is_authenticated else None,
        }
        alert, created = StockAlert.objects.get_or_create(
            product=product, email=email, notified=False,
            defaults=defaults,
        )
        return Response({
            'subscribed': True,
            'product': product.slug,
            'email': email,
            'created': created,
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


def _hide_dealer_only_for(user):
    """Active dealers + admins can see dealer_only products; everyone else can't."""
    if user is None or not getattr(user, 'is_authenticated', False):
        return True
    role = getattr(user, 'role', 'user')
    if role == 'admin' or getattr(user, 'is_superuser', False):
        return False
    if role == 'dealer' and getattr(user, 'dealer_status', None) == 'active':
        return False
    return True


@method_decorator([cache_page(30), vary_on_headers('Authorization')], name='dispatch')
class ProductListView(generics.ListAPIView):
    serializer_class = ProductListSerializer
    filterset_class = ProductFilter
    # Tag name + slug are included so navbar dropdown searches
    # (?search=keyword) match products that admins have tagged with that
    # keyword, not only products with the keyword in the name/description.
    search_fields = ['name', 'description', 'color', 'tags__name', 'tags__slug',
                     'sku', 'brand']
    ordering_fields = ['price', 'created_at', 'name', 'stock']
    ordering = ['-created_at']
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = (Product.objects
              .select_related('category')
              .prefetch_related('tags', 'discounts', 'negotiated_prices')
              .defer(
                  'description', 'short_description', 'highlights',
                  'feature_blocks', 'perks', 'youtube_url',
                  'care_instructions', 'return_policy_days',
                  'meta_title', 'meta_description', 'og_image_url',
                  'hsn_code', 'weight_grams',
              )
              .filter(is_deleted=False))
        if _hide_dealer_only_for(self.request.user):
            qs = qs.filter(dealer_only=False)
        return qs


class LimitedOffersView(APIView):
    """
    Products that currently have at least one ACTIVE time-bound discount
    (i.e. a Discount row whose `ends_at` is set and not yet in the past).

    Returns a flat list of products, each enriched with `time_offer`:
        {
          "ends_at":      ISO-8601 string of the soonest-ending active offer,
          "starts_at":    ISO-8601 (may be null),
          "discount_type": "user" | "dealer",
          "mode":         "percent" | "flat",
          "value":        "20.00",
          "min_quantity": 1,
        }

    Sorted by `ends_at` ascending (soonest expiry first) so the UI naturally
    surfaces "ends in 2 hours" deals at the top.

    Public — no auth required. Anonymous users see the user-tier offer; logged-in
    dealers see dealer-tier offers if any exist (else fall back to user-tier).
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from discounts.models import Discount

        now = timezone.now()
        role = 'user'
        if request.user.is_authenticated:
            role = getattr(request.user, 'role', 'user')
            if role not in ('user', 'dealer'):
                role = 'user'

        active_qs = Discount.objects.filter(
            active=True,
            ends_at__isnull=False,
            ends_at__gte=now,
        ).filter(
            Q(starts_at__isnull=True) | Q(starts_at__lte=now)
        )

        # Prefer the requested role's discount, but fall back to 'user' if the
        # dealer-only response would be empty.
        primary = active_qs.filter(discount_type=role).select_related('product__category')
        offers = list(primary)
        if role == 'dealer' and not offers:
            offers = list(active_qs.filter(discount_type='user').select_related('product__category'))

        # Group by product → keep the offer with the soonest ends_at per product.
        by_product = {}
        for d in offers:
            existing = by_product.get(d.product_id)
            if existing is None or d.ends_at < existing.ends_at:
                by_product[d.product_id] = d

        # Sort by ends_at ascending and serialize.
        chosen = sorted(by_product.values(), key=lambda d: d.ends_at)
        max_results = int(request.query_params.get('limit', 12))
        chosen = chosen[:max(1, min(max_results, 50))]

        serializer = ProductListSerializer(
            [d.product for d in chosen],
            many=True,
            context={'request': request},
        )
        result = serializer.data
        for product_payload, discount in zip(result, chosen):
            product_payload['time_offer'] = {
                'ends_at': discount.ends_at.isoformat(),
                'starts_at': discount.starts_at.isoformat() if discount.starts_at else None,
                'discount_type': discount.discount_type,
                'mode': discount.mode,
                'value': str(discount.value),
                'min_quantity': discount.min_quantity,
            }
        return Response(result)


@method_decorator([cache_page(120), vary_on_headers('Authorization')], name='dispatch')
class ProductDetailView(generics.RetrieveAPIView):
    serializer_class = ProductDetailSerializer
    lookup_field = 'slug'
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = (Product.objects
              .select_related('category')
              .prefetch_related('media', 'specifications', 'tags')
              .filter(is_deleted=False))
        if _hide_dealer_only_for(self.request.user):
            qs = qs.filter(dealer_only=False)
        return qs


class ProductDeliveryEtaView(APIView):
    """
    GET /api/products/<slug>/eta/?qty=N&pincode=XXXXXX

    Combines per-product DeliveryRule (qty tiers) with the shipping zone ETD
    so PDPs can show "Order 5 — delivered in 5–8 days to 110001" without the
    buyer having to start checkout. All inputs are optional; falls back to
    `product.delivery_estimate_days`.
    """
    permission_classes = [AllowAny]

    def get(self, request, slug):
        try:
            product = Product.objects.get(slug=slug, is_deleted=False)
        except Product.DoesNotExist:
            return Response({'error': 'Product not found.'},
                            status=status.HTTP_404_NOT_FOUND)

        try:
            qty = max(1, int(request.query_params.get('qty', 1)))
        except (TypeError, ValueError):
            qty = 1
        pincode = (request.query_params.get('pincode') or '').strip()

        # 1. Pick the matching DeliveryRule (longest-narrow first since rules
        #    are ordered by min_qty asc — last match wins for overlapping rules).
        rule = (product.delivery_rules
                .filter(min_qty__lte=qty, max_qty__gte=qty)
                .order_by('-min_qty')
                .first())
        if rule:
            etd_min = rule.etd_days_min
            etd_max = rule.etd_days_max
            note = rule.note
            source = 'rule'
        else:
            etd_min = max(1, product.delivery_estimate_days - 1)
            etd_max = product.delivery_estimate_days
            note = ''
            source = 'fallback'

        # 2. Stack zone-level ETD on top of the product rule (zones live on
        #    shipping ZIP; they delay further on top of the make-time).
        zone_info = None
        if pincode and len(pincode) >= 3:
            from shipping.services import estimate as shipping_estimate
            ship = shipping_estimate(pincode, subtotal=0)
            zone_info = {
                'zone_name': ship.get('zone_name'),
                'cod_available': ship.get('cod_available'),
                'etd_days_min': ship.get('etd_days_min'),
                'etd_days_max': ship.get('etd_days_max'),
                'message': ship.get('message'),
            }
            if ship.get('etd_days_min'):
                etd_min += int(ship['etd_days_min'])
                etd_max += int(ship['etd_days_max'] or ship['etd_days_min'])

        return Response({
            'product_slug': slug,
            'qty': qty,
            'pincode': pincode or None,
            'etd_days_min': etd_min,
            'etd_days_max': etd_max,
            'source': source,
            'note': note,
            'zone': zone_info,
        })


class SimilarProductsView(APIView):
    """
    GET /api/products/similar/<pk>/?limit=8

    Ranking strategy:
      1. Tag overlap — products that share more tags rank higher.
      2. Same category — if no tag matches, falls back to category siblings.
      3. Excludes archived / dealer-only (for non-dealers) / soft-deleted.

    Tag overlap is computed in SQL via annotate(Count(filtered M2M)).
    """
    permission_classes = [AllowAny]

    def get(self, request, pk):
        try:
            product = (Product.objects
                       .prefetch_related('tags')
                       .get(pk=pk, is_deleted=False))
        except Product.DoesNotExist:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)

        try:
            limit = max(1, min(int(request.query_params.get('limit', 4)), 12))
        except (TypeError, ValueError):
            limit = 4

        my_tag_ids = list(product.tags.values_list('id', flat=True))
        base = (Product.objects
                .filter(is_deleted=False, status='active')
                .exclude(pk=product.pk)
                .select_related('category'))
        if _hide_dealer_only_for(request.user):
            base = base.filter(dealer_only=False)

        results = []
        if my_tag_ids:
            from django.db.models import Q, Count as _Count
            ranked = (
                base.filter(tags__id__in=my_tag_ids)
                .annotate(shared_tags=_Count(
                    'tags', filter=Q(tags__id__in=my_tag_ids), distinct=True,
                ))
                .order_by('-shared_tags', '-rating_avg', '-created_at')
            )
            results = list(ranked[:limit])

        # Pad with category siblings if tag matches were sparse.
        if len(results) < limit:
            seen = {p.pk for p in results}
            extras = (base.filter(category=product.category)
                      .exclude(pk__in=seen)
                      .order_by('-rating_avg', '-created_at')[:limit - len(results)])
            results.extend(extras)

        # Last-resort pad: featured / top-rated products from ANY category so
        # the "You May Also Like" grid never shows fewer than `limit` cards.
        # Without this, sparse categories (e.g. only 2 products in Outdoor)
        # render a single lonely card and the layout looks broken.
        if len(results) < limit:
            seen = {p.pk for p in results}
            fillers = (base.exclude(pk__in=seen)
                       .order_by('-is_featured', '-rating_avg', '-rating_count')
                       [:limit - len(results)])
            results.extend(fillers)

        return Response(
            ProductListSerializer(results, many=True, context={'request': request}).data
        )


class BestSellersView(APIView):
    """
    GET /api/products/best-sellers/?days=30&limit=12

    Ranking strategy (production-grade):
      1. Sum of `OrderItem.quantity` across paid orders in the last N days.
      2. Tie-break by `rating_count` (more reviewed wins).
      3. Final tie-break by `rating_avg`.

    Why "paid in last N days":
      - Excludes failed/cancelled orders so window-shoppers don't skew it.
      - Recency window means a viral product 2 years ago doesn't squat in
        the chart forever — current demand wins.

    Falls back to highest-rated products with reviews if no orders matched
    in the window (so a fresh deployment isn't empty).
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from datetime import timedelta
        from django.db.models import Sum
        from orders.models import OrderItem

        try:
            days = max(1, min(int(request.query_params.get('days', 30)), 365))
        except (TypeError, ValueError):
            days = 30
        try:
            limit = max(1, min(int(request.query_params.get('limit', 12)), 24))
        except (TypeError, ValueError):
            limit = 12

        since = timezone.now() - timedelta(days=days)

        # Aggregate units sold per product over the window. We filter on the
        # parent Order's payment_status so only successful sales count.
        agg = (OrderItem.objects
               .filter(order__payment_status='SUCCESS',
                       order__created_at__gte=since,
                       product__is_deleted=False,
                       product__status='active')
               .values('product_id')
               .annotate(units=Sum('quantity'))
               .order_by('-units'))

        # Hide dealer-only items from non-dealers.
        if _hide_dealer_only_for(request.user):
            agg = agg.filter(product__dealer_only=False)

        ranked_ids = [r['product_id'] for r in agg[:limit]]
        units_by_id = {r['product_id']: r['units'] for r in agg[:limit]}

        if ranked_ids:
            # Preserve the aggregate order — Postgres can't ORDER BY array.
            qs = (Product.objects
                  .filter(pk__in=ranked_ids)
                  .select_related('category'))
            products = sorted(qs, key=lambda p: ranked_ids.index(p.pk))
        else:
            # Cold-start fallback: best-rated products with at least one review.
            qs = (Product.objects
                  .filter(is_deleted=False, status='active', rating_count__gt=0)
                  .select_related('category')
                  .order_by('-rating_avg', '-rating_count', '-created_at'))
            if _hide_dealer_only_for(request.user):
                qs = qs.filter(dealer_only=False)
            products = list(qs[:limit])

        data = ProductListSerializer(products, many=True, context={'request': request}).data
        # Annotate units sold so the storefront can render "1,200 sold this month".
        for row in data:
            row['units_sold_in_window'] = units_by_id.get(row['id'], 0)
        return Response({
            'window_days': days,
            'count': len(data),
            'results': data,
        })


class TagListView(generics.ListAPIView):
    """
    GET /api/products/tags/
    Public — returns every tag with its product count for tag-cloud / autocomplete.
    Optional `?nav=1` returns only tags flagged for navbar surfacing.
    """
    serializer_class = TagSerializer
    pagination_class = None
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = Tag.objects.select_related('category').annotate(
            product_count=Count('products', distinct=True),
        )
        if self.request.query_params.get('nav') in ('1', 'true', 'yes'):
            qs = qs.filter(is_navigation=True)
        return qs


class NavTagsView(APIView):
    """
    GET /api/products/nav-tags/
    Returns the mega-menu structure for the storefront Navbar:

      [
        { "category": {slug, name}, "tags": [{slug, label, nav_order}, …] },
        …
      ]

    Tags with no category (`category=null`) are grouped under a synthetic
    "Featured" bucket so they always render somewhere.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        tags = (
            Tag.objects
            .filter(is_navigation=True)
            .select_related('category')
            .order_by('category__sort_order', 'category__name', 'nav_order', 'name')
        )
        groups = {}
        for t in tags:
            key = t.category_id or 0
            if key not in groups:
                groups[key] = {
                    'category': (
                        {'slug': t.category.slug, 'name': t.category.name}
                        if t.category_id else None
                    ),
                    'tags': [],
                }
            groups[key]['tags'].append({
                'slug': t.slug,
                'label': t.nav_label or t.name,
                'nav_order': t.nav_order,
            })
        # Stable order: real categories first, "uncategorized" last.
        ordered = [v for k, v in sorted(groups.items(), key=lambda kv: (kv[0] == 0, kv[0]))]
        return Response(ordered)


class TagAdminListCreateView(generics.ListCreateAPIView):
    """Admin tag CRUD (list + create)."""
    serializer_class = TagSerializer
    permission_classes = [IsAdminRole]
    pagination_class = None

    def get_queryset(self):
        return Tag.objects.select_related('category').annotate(
            product_count=Count('products', distinct=True),
        )


class TagAdminDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = TagSerializer
    permission_classes = [IsAdminRole]
    queryset = Tag.objects.select_related('category')


class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    pagination_class = None
    permission_classes = [AllowAny]


class NavMenuView(APIView):
    """
    GET /api/products/nav-menu/

    Returns the navbar mega-menu tree in one call:

        [
          {
            "name": "Sofas",
            "slug": "sofas",
            "product_count": 2,
            "children": [],            # child categories if any exist
            "top_products": [          # falls back to top N products if no children
              {"id": 1, "slug": "...", "name": "...", "image_url": "..."},
              ...
            ]
          },
          ...
        ]

    The frontend renders each top-level row as a navbar header. If `children`
    is non-empty, those are the sub-items; otherwise `top_products` is shown
    so the dropdown is never empty.

    Cached for 5 min — this is the single most-hit endpoint on the storefront.
    """
    permission_classes = [AllowAny]

    @method_decorator(cache_page(60 * 5))
    def get(self, request):
        TOP_N = 6
        roots = (Category.objects.filter(parent__isnull=True, is_active=True)
                 .order_by('sort_order', 'name'))
        out = []
        for cat in roots:
            children = list(
                cat.children.filter(is_active=True)
                   .order_by('sort_order', 'name')
                   .values('id', 'name', 'slug')
            )
            # Annotate child product counts in one pass
            if children:
                child_ids = [c['id'] for c in children]
                counts = dict(
                    Product.objects.filter(category_id__in=child_ids,
                                           is_deleted=False, status='active')
                                   .values_list('category_id')
                                   .annotate(n=Count('id'))
                                   .values_list('category_id', 'n')
                )
                for c in children:
                    c['product_count'] = counts.get(c['id'], 0)

            top_products = []
            if not children:
                qs = (Product.objects.filter(category=cat, is_deleted=False,
                                             status='active')
                                     .order_by('-is_featured', '-rating_avg',
                                               '-created_at')[:TOP_N])
                for p in qs:
                    top_products.append({
                        'id': p.id,
                        'slug': p.slug,
                        'name': p.name,
                        'image_url': p.image_url or '',
                    })

            total = Product.objects.filter(
                category=cat, is_deleted=False, status='active'
            ).count()

            out.append({
                'id': cat.id,
                'name': cat.name,
                'slug': cat.slug,
                'product_count': total,
                'children': children,
                'top_products': top_products,
            })
        return Response(out)


class ProductAdminViewSet(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        products = Product.objects.select_related('category').filter(is_deleted=False)
        serializer = ProductListSerializer(products, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = ProductWriteSerializer(data=request.data)
        if serializer.is_valid():
            product = serializer.save()
            self._attach_media(request, product)
            self._sync_primary_image_url(product)
            data = ProductDetailSerializer(product).data
            warnings = getattr(request, '_image_quality_warnings', [])
            if warnings:
                data['image_quality_warnings'] = warnings
            return Response(data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def _attach_media(self, request, product):
        files = request.FILES.getlist('media')
        existing = product.media.exists()
        quality_warnings = []
        if not files:
            logger.warning(
                'No media files in request.FILES for product=%s (got %d files). '
                'Content-Type was %r. Frontend may have sent multipart with a '
                'bad boundary or no files at all.',
                product.slug, len(files), request.content_type,
            )
            request._image_quality_warnings = []
            return
        for i, f in enumerate(files):
            is_image = not f.content_type.startswith('video')
            # ── Image quality enforcement (relaxed) ──
            # We *warn* rather than reject for size/dimension so the admin
            # can still publish low-res placeholders or stock photos. Only
            # truly broken files (zero bytes) are rejected outright.
            if is_image:
                file_size = f.size if hasattr(f, 'size') else 0
                if file_size <= 0:
                    quality_warnings.append(
                        f'{f.name}: empty file (0 bytes). Upload rejected.'
                    )
                    continue
                if file_size < 20_000:  # < 20KB usually means thumbnail/icon
                    quality_warnings.append(
                        f'{f.name}: small file ({file_size // 1000}KB) — upload accepted but quality may suffer.'
                    )
                try:
                    from PIL import Image as PILImage
                    img = PILImage.open(f)
                    w, h = img.size
                    f.seek(0)
                    if w < 400 or h < 400:
                        quality_warnings.append(
                            f'{f.name}: {w}x{h} — upload accepted but resolution is low.'
                        )
                except Exception:
                    pass  # PIL unavailable or unreadable — don't block upload

            # Per-product Cloudinary folder so every product keeps its
            # media tidily grouped under furnishop/products/<slug>/.
            # Cloudinary auto-generates a public_id inside that folder so
            # multiple uploads with the same filename don't collide.
            from django.utils.text import slugify
            slug = product.slug or slugify(product.name)
            folder = f'furnishop/products/{slug}'
            kind = 'video' if f.content_type.startswith('video') else 'image'

            # Route through the central helper so eager thumb/card
            # transforms, retries, and audit logging happen in one place.
            # Falls back to FileSystemStorage when Cloudinary creds aren't
            # configured (e.g. local dev with no internet).
            from services import cloudinary as cdn
            file_value = f
            uploaded_to_cdn = False
            if cdn.is_configured():
                try:
                    eager = None if kind == 'video' else ('thumb', 'card')
                    result = cdn.upload(f, folder=folder, kind=kind, eager=eager)
                    file_value = result['public_id']
                    if kind == 'video':
                        file_value = f"video/upload/{result['public_id']}"
                    uploaded_to_cdn = True
                except Exception:
                    logger.exception(
                        'Cloudinary upload failed for %s (product=%s, folder=%s) — '
                        'falling back to CloudinaryField default upload.',
                        f.name, product.slug, folder,
                    )
                    f.seek(0)
                    file_value = f
            else:
                logger.warning(
                    'Cloudinary not configured — media for product=%s will use '
                    'whichever DEFAULT_FILE_STORAGE is active. Set '
                    'CLOUDINARY_CLOUD_NAME / API_KEY / API_SECRET env vars to enable.',
                    product.slug,
                )

            ProductMedia.objects.create(
                product=product,
                kind=kind,
                file=file_value,
                is_primary=(i == 0 and not existing),
                order=product.media.count(),
            )
            logger.info(
                'ProductMedia attached: product=%s file=%s uploaded_to_cdn=%s',
                product.slug,
                file_value if isinstance(file_value, str) else getattr(f, 'name', '<file>'),
                uploaded_to_cdn,
            )
        # Stash warnings so the view can return them.
        request._image_quality_warnings = quality_warnings

    def _sync_primary_image_url(self, product):
        """If image_url is empty, copy the primary (or first) media URL onto it
        so list views — which still render image_url — show the uploaded image."""
        if product.image_url:
            return
        primary = product.media.filter(is_primary=True).first() or product.media.first()
        if primary and primary.url:
            product.image_url = primary.url
            product.save(update_fields=['image_url'])


class ProductMediaDeleteView(APIView):
    permission_classes = [IsAdminRole]

    def delete(self, request, pk):
        try:
            media = ProductMedia.objects.get(pk=pk)
        except ProductMedia.DoesNotExist:
            return Response({'error': 'Media not found.'}, status=status.HTTP_404_NOT_FOUND)
        media.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ProductAdminDetailView(APIView):
    permission_classes = [IsAdminRole]

    def get_object(self, pk):
        try:
            return Product.objects.get(pk=pk)
        except Product.DoesNotExist:
            return None

    def put(self, request, pk):
        product = self.get_object(pk)
        if not product:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ProductWriteSerializer(product, data=request.data, partial=True)
        if serializer.is_valid():
            product = serializer.save()
            ProductAdminViewSet._attach_media(self, request, product)
            ProductAdminViewSet._sync_primary_image_url(self, product)
            data = ProductDetailSerializer(product).data
            warnings = getattr(request, '_image_quality_warnings', [])
            if warnings:
                data['image_quality_warnings'] = warnings
            return Response(data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        product = self.get_object(pk)
        if not product:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)
        product.is_deleted = True
        product.deleted_at = timezone.now()
        product.save()
        return Response(status=status.HTTP_204_NO_CONTENT)
