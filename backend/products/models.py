import secrets
from django.core.exceptions import ValidationError
from django.db import models
from django.utils.text import slugify
from cloudinary.models import CloudinaryField


class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True, blank=True)
    description = models.TextField(blank=True)
    parent = models.ForeignKey(
        'self', null=True, blank=True, on_delete=models.PROTECT,
        related_name='children',
    )
    banner_image = CloudinaryField('banner', blank=True, null=True)
    is_active = models.BooleanField(default=True)
    sort_order = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'categories'
        verbose_name_plural = 'Categories'
        ordering = ['sort_order', 'name']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def clean(self):
        # Reject parent cycles. Walks up the parent chain looking for self.
        seen = set()
        node = self.parent
        while node is not None:
            if node.pk == self.pk:
                raise ValidationError({'parent': 'Cycle detected: a category cannot be its own ancestor.'})
            if node.pk in seen:
                break
            seen.add(node.pk)
            node = node.parent

    @property
    def banner_url(self):
        if self.banner_image:
            try:
                return self.banner_image.url
            except Exception:
                return str(self.banner_image)
        return None

    def __str__(self):
        return self.name


class Tag(models.Model):
    """
    Free-form keyword applied to a product.

    Drives two storefront features:
      1. **Similar products** — products that share more tags rank higher than
         category-only matches.
      2. **Navbar mega-menu** — when `is_navigation` is set, the tag becomes
         a sub-link under its `category` (or as a top-level link if category is
         null). The frontend hits `/api/products/nav-tags/` and renders the
         menu without redeploying.

    Slugs are auto-derived from name and used in the URL: `/?tag=<slug>`.
    """
    name = models.CharField(max_length=80, unique=True)
    slug = models.SlugField(max_length=100, unique=True, blank=True, db_index=True)
    description = models.CharField(max_length=200, blank=True)
    # Navigation surfacing
    is_navigation = models.BooleanField(
        default=False, db_index=True,
        help_text='Show this tag in the storefront navbar.',
    )
    nav_label = models.CharField(
        max_length=80, blank=True,
        help_text='Optional display name for navbar (defaults to `name`).',
    )
    nav_order = models.PositiveIntegerField(default=0)
    # Group navbar links under a top-level category column. Null = floats free.
    category = models.ForeignKey(
        Category, null=True, blank=True, on_delete=models.SET_NULL,
        related_name='nav_tags',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'product_tags'
        ordering = ['nav_order', 'name']
        indexes = [
            models.Index(fields=['is_navigation', 'nav_order']),
            models.Index(fields=['category', 'is_navigation']),
        ]

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class Product(models.Model):
    MATERIAL_CHOICES = [
        ('wood', 'Wood'),
        ('metal', 'Metal'),
        ('fabric', 'Fabric'),
        ('leather', 'Leather'),
        ('glass', 'Glass'),
        ('plastic', 'Plastic'),
        ('marble', 'Marble'),
        ('rattan', 'Rattan'),
    ]
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('active', 'Active'),
        ('archived', 'Archived'),
    ]

    name = models.CharField(max_length=200)
    slug = models.SlugField(max_length=200, unique=True, blank=True)
    sku = models.CharField(max_length=32, unique=True, blank=True, db_index=True)
    brand = models.CharField(max_length=80, blank=True, db_index=True)
    description = models.TextField()
    short_description = models.CharField(
        max_length=240, blank=True,
        help_text='One-line summary shown above the bullet highlights on the PDP.',
    )
    highlights = models.JSONField(default=list, blank=True,
                                  help_text='Bullet-point highlights shown on PDP.')
    # Rich-PDP marketing blocks. Each entry shape:
    # { "title": "...", "body": "...", "image_url": "...",
    #   "image_alignment": "left"|"right"|"full", "order": 1 }
    feature_blocks = models.JSONField(
        default=list, blank=True,
        help_text='Alternating image + text marketing blocks rendered below the buy box.',
    )
    # Top-of-page perks (e.g. Quick Installation / Warranty / Delivery time).
    perks = models.JSONField(
        default=list, blank=True,
        help_text='Trust strip; each item: {icon, title, subtitle}. Optional.',
    )
    # Embedded YouTube assembly/marketing video.
    youtube_url = models.URLField(max_length=500, blank=True)
    warranty_years = models.PositiveSmallIntegerField(default=1)
    installation_required = models.BooleanField(
        default=False,
        help_text='Show DIY assembly notice and surface assembly video.',
    )
    care_instructions = models.TextField(
        blank=True,
        help_text='Optional cleaning / maintenance instructions.',
    )
    return_policy_days = models.PositiveSmallIntegerField(default=7)
    # Free-form keywords. Drives "similar products" via tag overlap and
    # navbar mega-menu via Tag.is_navigation. Editable in the admin form.
    tags = models.ManyToManyField(
        Tag, blank=True, related_name='products',
        help_text='Keywords that link this product to navbar entries and similar-product surfaces.',
    )
    price = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='products')
    material = models.CharField(max_length=50, choices=MATERIAL_CHOICES)
    color = models.CharField(max_length=50)
    dimensions = models.CharField(max_length=100, help_text='e.g., 120x60x75 cm')
    weight_grams = models.PositiveIntegerField(null=True, blank=True,
                                               help_text='Used by shipping cost estimator.')
    hsn_code = models.CharField(max_length=10, blank=True,
                                help_text='GST classification code; copied to invoice line.')
    image_url = models.URLField(max_length=500, blank=True, null=True)
    stock = models.PositiveIntegerField(default=0)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active', db_index=True)
    is_featured = models.BooleanField(default=False)
    dealer_only = models.BooleanField(
        default=False, db_index=True,
        help_text='Hide from public storefront; only visible to authenticated dealers.',
    )
    min_order_quantity = models.PositiveIntegerField(
        default=1,
        help_text='Minimum quantity per order (MOQ). Enforced at add-to-cart and checkout.',
    )
    delivery_estimate_days = models.PositiveIntegerField(default=7,
                                                         help_text='Fallback when pincode rules do not match.')
    # Reviews denorm — recomputed by signal on Review save.
    rating_avg = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    rating_count = models.PositiveIntegerField(default=0)
    # SEO
    meta_title = models.CharField(max_length=160, blank=True)
    meta_description = models.CharField(max_length=320, blank=True)
    og_image_url = models.URLField(max_length=500, blank=True)
    # Soft delete
    is_deleted = models.BooleanField(default=False, db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['category']),
            models.Index(fields=['material']),
            models.Index(fields=['price']),
            models.Index(fields=['status']),
        ]

    def _generate_sku(self):
        base = (self.category.slug[:3].upper() if self.category_id else 'PRD')
        for _ in range(5):
            candidate = f'{base}-{secrets.token_hex(3).upper()}'
            if not Product.objects.filter(sku=candidate).exclude(pk=self.pk).exists():
                return candidate
        # Extremely unlikely; fall back to longer suffix.
        return f'{base}-{secrets.token_hex(6).upper()}'

    def save(self, *args, **kwargs):
        if not self.slug:
            base_slug = slugify(self.name)
            slug = base_slug
            counter = 1
            while Product.objects.filter(slug=slug).exclude(pk=self.pk).exists():
                slug = f'{base_slug}-{counter}'
                counter += 1
            self.slug = slug
        if not self.sku:
            self.sku = self._generate_sku()
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    @property
    def in_stock(self):
        return self.stock > 0


class ProductMedia(models.Model):
    MEDIA_KIND = [('image', 'Image'), ('video', 'Video')]
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='media')
    kind = models.CharField(max_length=8, choices=MEDIA_KIND, default='image')
    file = CloudinaryField('media', resource_type='auto', blank=True, null=True)
    is_primary = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)
    alt_text = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'product_media'
        ordering = ['order', 'id']
        indexes = [models.Index(fields=['product', 'is_primary'])]

    @property
    def url(self):
        if not self.file:
            return None
        # We always rebuild the URL with the explicit resource_type matching
        # `self.kind`. The CloudinaryField on this model is declared with
        # resource_type='auto', so its built-in .url produces
        # `/auto/upload/...` URLs which Cloudinary's CDN rejects with 400.
        # Build the proper `/image/upload/...` or `/video/upload/...` URL
        # using the helper so the storefront can actually render the asset.
        resource_type = 'video' if self.kind == 'video' else 'image'
        public_id = self._get_public_id()
        if public_id:
            try:
                from services import cloudinary as cdn
                if cdn.is_configured():
                    built = cdn.transform_url(
                        public_id,
                        resource_type=resource_type,
                        secure=True,
                    )
                    if built:
                        return built
            except Exception:
                pass
        # Last-resort: try the CloudinaryField's own .url (may be wrong but
        # better than nothing for legacy rows without explicit public_id).
        try:
            return self.file.url
        except Exception:
            return str(self.file) if self.file else None

    def _get_public_id(self):
        """Best-effort extraction of the Cloudinary public_id from
        whatever shape `self.file` happens to be in (CloudinaryResource,
        raw string, or FieldFile)."""
        f = self.file
        if not f:
            return None
        for attr in ('public_id', 'name'):
            val = getattr(f, attr, None)
            if val:
                return val
        s = str(f)
        # `/image/upload/v123/path/file.ext` → `path/file`
        if 'upload/' in s:
            tail = s.split('upload/', 1)[1]
            if tail.startswith('v') and '/' in tail[1:]:
                tail = tail.split('/', 1)[1]
            # Strip extension
            if '.' in tail.rsplit('/', 1)[-1]:
                tail = tail.rsplit('.', 1)[0]
            return tail
        return s

    def __str__(self):
        return f'{self.product.name} — {self.kind} ({self.id})'


class ProductVariant(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='variants')
    sku = models.CharField(max_length=40, unique=True, blank=True, db_index=True)
    option_name = models.CharField(max_length=50, help_text='e.g. Color, Size')
    option_value = models.CharField(max_length=50, help_text='e.g. Walnut, Large')
    price_delta = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    stock = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'product_variants'
        unique_together = [('product', 'option_name', 'option_value')]
        ordering = ['option_name', 'option_value']

    def save(self, *args, **kwargs):
        if not self.sku:
            parent = self.product.sku or 'VAR'
            for _ in range(5):
                candidate = f'{parent}-{secrets.token_hex(2).upper()}'
                if not ProductVariant.objects.filter(sku=candidate).exclude(pk=self.pk).exists():
                    self.sku = candidate
                    break
            else:
                self.sku = f'{parent}-{secrets.token_hex(4).upper()}'
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.product.name} · {self.option_name}: {self.option_value}'


class ProductSpecification(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='specifications')
    label = models.CharField(max_length=100, help_text='e.g. Weight, Warranty')
    value = models.CharField(max_length=200, help_text='e.g. 12 kg, 2 years')
    sort_order = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = 'product_specifications'
        ordering = ['sort_order', 'id']

    def __str__(self):
        return f'{self.label}: {self.value}'


class DeliveryRule(models.Model):
    """
    Quantity-tiered delivery ETA for a product.

    Lookup picks the row whose [min_qty, max_qty] range contains the requested
    quantity. If none match, callers fall back to product.delivery_estimate_days.

    Typical setup:
       1–10 units  → 3-5 days  (in stock, ships fast)
       11–50      → 7-10 days  (assembly)
       51+        → 14-21 days (made-to-order batch)
    """
    product = models.ForeignKey(
        Product, on_delete=models.CASCADE, related_name='delivery_rules',
    )
    min_qty = models.PositiveIntegerField(default=1)
    max_qty = models.PositiveIntegerField(
        default=1_000_000,
        help_text='Inclusive upper bound. Use a large number for "and above".',
    )
    etd_days_min = models.PositiveSmallIntegerField()
    etd_days_max = models.PositiveSmallIntegerField()
    note = models.CharField(
        max_length=160, blank=True,
        help_text='Optional human-readable note shown on the PDP.',
    )

    class Meta:
        db_table = 'product_delivery_rules'
        ordering = ['product', 'min_qty']
        indexes = [models.Index(fields=['product', 'min_qty'])]

    def __str__(self):
        return f'{self.product.name}: {self.min_qty}-{self.max_qty} → {self.etd_days_min}-{self.etd_days_max}d'


class StockAlert(models.Model):
    """
    "Notify me when this product is back in stock" subscription.
    One row per (product, email). When stock crosses from 0 → positive, the
    notification worker fires an email to every active subscriber and flips
    `notified` to True so we don't spam them again on the next restock cycle.
    """
    product = models.ForeignKey(
        Product, on_delete=models.CASCADE, related_name='stock_alerts',
    )
    email = models.EmailField(db_index=True)
    user = models.ForeignKey(
        'users.User', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='stock_alerts',
        help_text='Set when a signed-in user subscribed; null for guests.',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    notified = models.BooleanField(default=False, db_index=True)
    notified_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'product_stock_alerts'
        ordering = ['-created_at']
        constraints = [
            # Dedup — one open subscription per (product, email).
            models.UniqueConstraint(
                fields=['product', 'email'],
                condition=models.Q(notified=False),
                name='uniq_open_stock_alert_per_email',
            ),
        ]
        indexes = [
            models.Index(fields=['product', 'notified']),
        ]

    def __str__(self):
        return f'{self.email} → {self.product.name}'
