from rest_framework import serializers
from .models import Category, Product, ProductMedia, Tag
from discounts.services import get_effective_price


class TagSerializer(serializers.ModelSerializer):
    category_slug = serializers.CharField(source='category.slug', read_only=True)
    category_name = serializers.CharField(source='category.name', read_only=True)
    product_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Tag
        fields = [
            'id', 'name', 'slug', 'description',
            'is_navigation', 'nav_label', 'nav_order',
            'category', 'category_slug', 'category_name',
            'product_count',
        ]
        read_only_fields = ['slug']

    def validate_name(self, value):
        v = (value or '').strip()
        if not v:
            raise serializers.ValidationError('Name is required.')
        return v


class ProductMediaSerializer(serializers.ModelSerializer):
    url = serializers.CharField(read_only=True)

    class Meta:
        model = ProductMedia
        fields = ['id', 'kind', 'url', 'is_primary', 'order', 'alt_text']


class CategorySerializer(serializers.ModelSerializer):
    product_count = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'description', 'product_count']

    def get_product_count(self, obj):
        return obj.products.count()


class DiscountInfoMixin:
    """
    Mixin that adds discount-aware pricing to product serializers.
    Reads the request user's role from the serializer context.

    The optional `?qty=N` query param picks the right tier for a volume
    discount — defaults to 1 (single-unit price) when not provided.
    """

    def _requested_qty(self):
        request = self.context.get('request')
        if not request:
            return 1
        try:
            qty = int(request.query_params.get('qty', 1))
            return max(1, qty)
        except (TypeError, ValueError):
            return 1

    def _get_pricing(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return obj.price, None, None
        role = getattr(request.user, 'role', 'user')

        # Dealer-only branch: resolve via the dealer pricing service so
        # tier discounts stack with quantity-tier ladders and per-dealer
        # negotiated prices win outright.
        if role == 'dealer':
            from dealer_pricing.service import resolve as resolve_dealer
            res = resolve_dealer(obj, request.user, quantity=self._requested_qty())
            # Build a synthetic discount-shaped object for downstream consumers.
            if res['source'] == 'none':
                return obj.price, None, None
            from types import SimpleNamespace
            synthetic = SimpleNamespace(
                mode='percent' if res['source'] != 'negotiated' else 'flat',
                # Use the *effective* savings ratio so the on-card "X% off"
                # badge reflects the combined tier+qty discount, not the
                # tier alone.
                value=(((res['mrp'] - res['effective_price']) / res['mrp']) * 100
                       ).quantize(__import__('decimal').Decimal('0.01'))
                       if res['mrp'] else 0,
                discount_type='dealer',
                min_quantity=res['qty_tier_min'] or 1,
            )
            return res['effective_price'], synthetic, None

        return get_effective_price(obj, role, quantity=self._requested_qty())

    def get_effective_price(self, obj):
        price, _, _ = self._get_pricing(obj)
        return str(price)

    def get_discount_applied(self, obj):
        _, discount, _ = self._get_pricing(obj)
        if discount is None:
            return None
        return {
            'mode': discount.mode,
            'value': str(discount.value),
            'type': discount.discount_type,
            'min_quantity': discount.min_quantity,
            'display': f'{discount.value}{"%" if discount.mode == "percent" else "₹"} off'
                       + (f' on {discount.min_quantity}+ units' if discount.min_quantity > 1 else ''),
        }

    def get_discount_units_remaining(self, obj):
        _, _, remaining = self._get_pricing(obj)
        return remaining


class ProductListSerializer(DiscountInfoMixin, serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_slug = serializers.CharField(source='category.slug', read_only=True)
    effective_price = serializers.SerializerMethodField()
    discount_applied = serializers.SerializerMethodField()
    discount_units_remaining = serializers.SerializerMethodField()
    tag_slugs = serializers.SerializerMethodField()
    # Override image_url with a safe getter that falls back to primary media's
    # URL if the column is empty OR contains a bare public_id (no http scheme).
    # Without this, products created before the Cloudinary URL-sync fix render
    # broken <img> tags on the storefront list/grid.
    image_url = serializers.SerializerMethodField()

    def get_tag_slugs(self, obj):
        # Cheap: returns just slugs (used for client-side filter chips).
        return list(obj.tags.values_list('slug', flat=True))

    def get_image_url(self, obj):
        raw = obj.image_url or ''
        if raw.startswith(('http://', 'https://', '//')):
            return raw
        # Fallback: read primary media's resolved URL (handles legacy rows
        # where image_url was never set OR was set to a bare public_id).
        primary = obj.media.filter(is_primary=True).first() or obj.media.first()
        if primary:
            url = primary.url or ''
            if url.startswith(('http://', 'https://', '//')):
                return url
        return raw  # last-resort: return whatever we had (lets admin spot it)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'sku', 'brand',
            'price', 'effective_price',
            'discount_applied', 'discount_units_remaining',
            'category', 'category_name', 'category_slug',
            'material', 'color', 'dimensions', 'image_url',
            'stock', 'in_stock', 'is_featured',
            'dealer_only', 'min_order_quantity',
            'rating_avg', 'rating_count',
            'delivery_estimate_days',
            'tag_slugs',
            'created_at',
        ]


class ProductSpecificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = __import__('products').models.ProductSpecification
        fields = ['id', 'label', 'value', 'sort_order']


class ProductDetailSerializer(DiscountInfoMixin, serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    effective_price = serializers.SerializerMethodField()
    discount_applied = serializers.SerializerMethodField()
    discount_units_remaining = serializers.SerializerMethodField()
    discount_tiers = serializers.SerializerMethodField()
    media = ProductMediaSerializer(many=True, read_only=True)
    specifications = ProductSpecificationSerializer(many=True, read_only=True)
    tags = TagSerializer(many=True, read_only=True)
    primary_image = serializers.SerializerMethodField()
    youtube_embed_url = serializers.SerializerMethodField()

    def get_youtube_embed_url(self, obj):
        url = (obj.youtube_url or '').strip()
        if not url:
            return ''
        # Normalize every common YouTube URL shape into an /embed/ URL so the
        # iframe loads reliably. Patterns covered:
        #   https://www.youtube.com/watch?v=ID&t=10s
        #   https://m.youtube.com/watch?v=ID
        #   https://youtu.be/ID?si=...
        #   https://www.youtube.com/embed/ID
        #   https://www.youtube.com/shorts/ID
        #   https://www.youtube.com/live/ID
        import re
        m = re.search(
            r'(?:v=|youtu\.be/|/embed/|/shorts/|/live/|/v/)([A-Za-z0-9_-]{11})',
            url,
        )
        if m:
            return f'https://www.youtube.com/embed/{m.group(1)}?rel=0'
        # Already an embed URL we can't reparse — return as-is, the iframe will
        # try to load it.
        return url

    def get_primary_image(self, obj):
        primary = obj.media.filter(is_primary=True).first() or obj.media.first()
        return primary.url if primary else obj.image_url

    def get_discount_tiers(self, obj):
        """
        Return active tiers for the requesting user's role so the storefront
        can render a volume-pricing ladder ("Buy 5 for 30% off").
        Anonymous users get an empty list.
        """
        from discounts.services import get_discount_tiers
        from discounts.serializers import DiscountTierSerializer
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return []
        role = getattr(request.user, 'role', 'user')
        if role not in ('user', 'dealer'):
            return []
        tiers = get_discount_tiers(obj, role)
        return DiscountTierSerializer(tiers, many=True).data

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'sku', 'brand',
            'description', 'short_description', 'highlights',
            'feature_blocks', 'perks',
            'youtube_url', 'youtube_embed_url',
            'warranty_years', 'installation_required',
            'care_instructions', 'return_policy_days',
            'hsn_code', 'weight_grams',
            'price', 'effective_price',
            'discount_applied', 'discount_units_remaining', 'discount_tiers',
            'category', 'material', 'color', 'dimensions', 'image_url',
            'stock', 'in_stock', 'is_featured',
            'dealer_only', 'min_order_quantity',
            'rating_avg', 'rating_count', 'delivery_estimate_days',
            'meta_title', 'meta_description', 'og_image_url',
            'created_at',
            'media', 'primary_image', 'specifications',
            'tags',
        ]


class ProductWriteSerializer(serializers.ModelSerializer):
    # image_url becomes optional when the admin uploads media via Cloudinary —
    # the view auto-fills it from the first uploaded ProductMedia after save.
    image_url = serializers.URLField(required=False, allow_blank=True)
    # Free-form JSON inputs — coerce strings on submit (multipart sends JSON
    # arrays as strings) so the admin form can post FormData directly.
    highlights = serializers.JSONField(required=False)
    feature_blocks = serializers.JSONField(required=False)
    perks = serializers.JSONField(required=False)
    # Inline child rows. Posted as a JSON array; we replace-all on save.
    specifications = serializers.JSONField(required=False, write_only=True)
    # Tag input. Accepts list of names OR slugs OR IDs — get-or-create by name
    # so admins can type new keywords without going to a separate Tags page.
    tags = serializers.JSONField(required=False, write_only=True)

    class Meta:
        model = Product
        fields = [
            'name', 'brand', 'description', 'short_description', 'highlights',
            'feature_blocks', 'perks',
            'youtube_url', 'warranty_years', 'installation_required',
            'care_instructions', 'return_policy_days',
            'price', 'category',
            'material', 'color', 'dimensions',
            'hsn_code', 'weight_grams',
            'image_url', 'stock', 'is_featured', 'status',
            'dealer_only', 'min_order_quantity',
            'delivery_estimate_days',
            'meta_title', 'meta_description', 'og_image_url',
            'specifications', 'tags',
        ]

    def _coerce_json(self, attrs, key):
        """Multipart submits send JSON values as strings — decode them."""
        raw = attrs.get(key)
        if isinstance(raw, str) and raw.strip():
            import json
            try:
                attrs[key] = json.loads(raw)
            except json.JSONDecodeError:
                raise serializers.ValidationError({key: 'Must be a valid JSON array/object.'})
        return attrs

    def validate(self, attrs):
        for k in ('highlights', 'feature_blocks', 'perks', 'specifications', 'tags'):
            attrs = self._coerce_json(attrs, k)
        return attrs

    def _replace_tags(self, product, tags):
        """Accept a list of strings (names) and/or ints (IDs); idempotent.
        Names get slugified + get_or_create so admins can add keywords inline."""
        if tags is None:
            return
        from django.utils.text import slugify as _slug
        from .models import Tag
        if not isinstance(tags, list):
            return
        resolved = []
        for raw in tags:
            if isinstance(raw, int):
                t = Tag.objects.filter(pk=raw).first()
                if t:
                    resolved.append(t)
            elif isinstance(raw, str):
                name = raw.strip()
                if not name:
                    continue
                slug = _slug(name)[:100]
                # Match on slug to avoid case-only collisions ("Office" vs "office").
                t = Tag.objects.filter(slug=slug).first()
                if not t:
                    t = Tag.objects.create(name=name[:80], slug=slug)
                resolved.append(t)
        product.tags.set(resolved)

    def _replace_specs(self, product, specs):
        if specs is None:
            return
        from .models import ProductSpecification
        product.specifications.all().delete()
        if isinstance(specs, list):
            ProductSpecification.objects.bulk_create([
                ProductSpecification(
                    product=product,
                    label=(s.get('label') or '').strip()[:100],
                    value=(s.get('value') or '').strip()[:200],
                    sort_order=int(s.get('sort_order', i)),
                ) for i, s in enumerate(specs)
                if (s.get('label') or '').strip() and (s.get('value') or '').strip()
            ])

    def create(self, validated_data):
        specs = validated_data.pop('specifications', None)
        tags = validated_data.pop('tags', None)
        product = super().create(validated_data)
        self._replace_specs(product, specs)
        self._replace_tags(product, tags)
        return product

    def update(self, instance, validated_data):
        specs = validated_data.pop('specifications', None)
        tags = validated_data.pop('tags', None)
        product = super().update(instance, validated_data)
        self._replace_specs(product, specs)
        self._replace_tags(product, tags)
        return product

    def validate_min_order_quantity(self, value):
        if value < 1:
            raise serializers.ValidationError('Minimum order quantity must be at least 1.')
        return value

    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError('Price must be greater than 0.')
        return value

    def validate_stock(self, value):
        if value < 0:
            raise serializers.ValidationError('Stock cannot be negative.')
        return value
