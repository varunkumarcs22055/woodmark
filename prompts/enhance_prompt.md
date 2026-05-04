# Enhancement Prompt — Run AFTER all 15 base prompts complete

## Role
You are a senior full-stack engineer. The base FurniShop app (backend prompts 1–8 + frontend prompts 1–7) is built and working. This enhancement layer adds four production capabilities that were deferred:

1. **PostgreSQL** as the production database (replacing dev-mode SQLite fallback)
2. **Cloudinary** for product image + video hosting
3. **GST singleton settings** — admin-editable rate applied to every order
4. **Product media gallery** — multiple images + videos per product, Amazon-style gallery on the detail page

> **Run order:** This prompt depends on backend prompts 1–8 and frontend prompts 1–7 already being executed. Do not start until those are complete and the app boots end-to-end.

---

## 1. PostgreSQL via Neon

### Goal
Production must use Neon PostgreSQL. SQLite fallback stays only for local dev when `DATABASE_URL` is unset.

### Backend changes — `backend/core/settings.py`
- Confirm `dj-database-url` and `psycopg2-binary` are in `requirements.txt` (already added in Backend Prompt 1).
- DATABASES block:
  ```python
  import dj_database_url
  DATABASE_URL = os.getenv('DATABASE_URL')
  if DATABASE_URL:
      DATABASES = {
          'default': dj_database_url.parse(
              DATABASE_URL,
              conn_max_age=600,
              ssl_require=True,
          ),
      }
  else:
      DATABASES = {
          'default': {
              'ENGINE': 'django.db.backends.sqlite3',
              'NAME': BASE_DIR / 'db.sqlite3',
          },
      }
  ```
- Add `.env.example` entry: `DATABASE_URL=postgresql://user:pass@ep-xxx.neon.tech/furnishop?sslmode=require`

### Migration plan
- Create the Neon project + database; copy the connection string.
- Set `DATABASE_URL` in `.env`.
- Run: `python manage.py migrate && python manage.py seed_products && python manage.py createsuperuser`

### Acceptance
- [ ] App runs against Neon when `DATABASE_URL` is set
- [ ] Falls back to SQLite when unset
- [ ] All migrations apply cleanly
- [ ] `seed_products` populates Neon

---

## 2. Cloudinary for Image + Video Hosting

### Why
Free tier covers initial usage; transformations (resize/crop/compress) happen on the CDN; product images and videos persist across deploys.

### Backend changes

**`requirements.txt`** — add:
```
cloudinary==1.41.0
django-cloudinary-storage==0.3.0
```

**`backend/core/settings.py`**:
```python
INSTALLED_APPS += [
    'cloudinary',
    'cloudinary_storage',
]

CLOUDINARY_STORAGE = {
    'CLOUD_NAME': os.getenv('CLOUDINARY_CLOUD_NAME'),
    'API_KEY':    os.getenv('CLOUDINARY_API_KEY'),
    'API_SECRET': os.getenv('CLOUDINARY_API_SECRET'),
}

# Default file storage stays local; Cloudinary fields opt-in per model
```

**`backend/products/models.py`** — add new model `ProductMedia` and update `Product`:
```python
from cloudinary.models import CloudinaryField

class Product(models.Model):
    # ... existing fields ...
    # Keep image_url for backward compat; new uploads go to ProductMedia
    image_url = models.URLField(max_length=500, blank=True)

class ProductMedia(models.Model):
    MEDIA_KIND = [('image', 'Image'), ('video', 'Video')]
    product   = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='media')
    kind      = models.CharField(max_length=8, choices=MEDIA_KIND, default='image')
    file      = CloudinaryField('media', resource_type='auto')  # auto = image or video
    is_primary = models.BooleanField(default=False)
    order     = models.PositiveIntegerField(default=0)
    alt_text  = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'product_media'
        ordering = ['order', 'id']
        indexes = [models.Index(fields=['product', 'is_primary'])]

    @property
    def url(self):
        return self.file.url if self.file else None
```

**Backfill migration** — data migration that copies the legacy `image_url` into a `ProductMedia(kind='image', is_primary=True)` row for every existing product.

**`backend/products/serializers.py`** — add `media` array to ProductDetailSerializer:
```python
class ProductMediaSerializer(serializers.ModelSerializer):
    url = serializers.CharField(read_only=True)
    class Meta:
        model = ProductMedia
        fields = ['id', 'kind', 'url', 'is_primary', 'order', 'alt_text']

class ProductDetailSerializer(...):
    media = ProductMediaSerializer(many=True, read_only=True)
    primary_image = serializers.SerializerMethodField()

    def get_primary_image(self, obj):
        primary = obj.media.filter(is_primary=True).first() or obj.media.first()
        return primary.url if primary else obj.image_url
```

**Admin product CRUD endpoint** — accept `media[]` uploads via multipart/form-data; create one `ProductMedia` row per file. Use `request.FILES.getlist('media')`.

### Acceptance
- [ ] `CLOUDINARY_*` env vars configured
- [ ] `ProductMedia` table created and backfilled from legacy `image_url`
- [ ] Admin can upload N images + videos per product via the AdminProducts modal
- [ ] First uploaded image becomes `is_primary=True` automatically
- [ ] Admin can re-order media and toggle which is primary

---

## 3. GST Singleton Settings Model

### Goal
Admin sets a single GST percentage (e.g., 18%) applicable to ALL products. Saved in DB. Order totals include GST. Admin can change anytime.

### Backend

**New app:** `backend/settings_app/` (or merge into an existing `core` config app)

**Model:**
```python
class StoreSettings(models.Model):
    """Singleton — only one row should exist."""
    gst_percent  = models.DecimalField(max_digits=5, decimal_places=2, default=18.00,
                                       validators=[MinValueValidator(0), MaxValueValidator(100)])
    free_shipping_threshold = models.DecimalField(max_digits=10, decimal_places=2, default=2999.00)
    standard_shipping_fee   = models.DecimalField(max_digits=10, decimal_places=2, default=499.00)
    updated_at  = models.DateTimeField(auto_now=True)
    updated_by  = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True)

    class Meta:
        db_table = 'store_settings'

    def save(self, *args, **kwargs):
        # Enforce singleton — always pk=1
        self.pk = 1
        super().save(*args, **kwargs)

    @classmethod
    def current(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj
```

**Endpoints:**
- `GET /api/settings/` — public; returns `{ gst_percent, free_shipping_threshold, standard_shipping_fee }`
- `PATCH /api/settings/` — admin only; updates fields

**Order calculation update** — in `OrderCreateSerializer.create()`:
```python
settings = StoreSettings.current()
gst_amount = (subtotal * settings.gst_percent / 100).quantize(Decimal('0.01'))
shipping = 0 if subtotal >= settings.free_shipping_threshold else settings.standard_shipping_fee
total = subtotal + gst_amount + shipping
```

**Order model** — add fields:
```python
gst_percent = models.DecimalField(max_digits=5, decimal_places=2)   # snapshot
gst_amount  = models.DecimalField(max_digits=10, decimal_places=2)  # snapshot
shipping_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
```

### Frontend

**Admin panel — new section** `AdminSettings.jsx`:
- Card with current GST %, free-shipping threshold, shipping fee
- Edit-in-place with save button
- Toast on save: "Settings updated. New orders will use the updated GST."

**Cart + Checkout updates:**
- `GET /api/settings/` on app load (cache in AuthContext or new SettingsContext)
- CartPage shows: Subtotal · GST (X%) · Shipping · Total — all using live settings
- CheckoutPage order summary shows the same breakdown
- OrderCard displays the GST line for historical accuracy (uses snapshot fields)

### Acceptance
- [ ] StoreSettings singleton always has exactly one row
- [ ] GST defaults to 18% on first load
- [ ] Admin can change GST and changes apply to NEW orders only
- [ ] Existing orders show the GST that was active when they were placed
- [ ] Cart, checkout, and order receipts all show the GST line

---

## 4. Product Detail Gallery (Amazon-style)

### Goal
Detail page shows hero image at top, gallery (multiple images + videos) BELOW the product info section. Click a thumbnail to view full-size in a lightbox.

### Frontend changes

**`src/components/ProductGallery.jsx`** — new component:
- Props: `media: ProductMedia[]`
- Layout:
  - Top row: large hero (the currently selected media item)
  - Below: horizontal scrollable thumbnail strip with all media
  - Videos render as `<video controls poster=...>` when selected; thumbnails show a play overlay
- Click thumbnail → swap hero
- Click hero → open Lightbox modal with prev/next arrows + keyboard nav (arrows + Esc)

**`src/components/MediaLightbox.jsx`** — fullscreen overlay:
- Renders current media full-bleed
- Arrow keys navigate, Esc closes
- Click outside closes
- For videos: autoplay disabled, controls enabled

**`ProductDetailPage.jsx` updates:**
- Replace single `<img>` with `<ProductGallery media={product.media} />`
- Move existing single-image hero into the gallery's first position if `media` is empty (legacy products)

**CSS:**
- Mobile: gallery becomes a swiper carousel (use existing `swiper` package)
- Desktop: thumbnail strip + hero, plus optional zoom-on-hover for images

### Acceptance
- [ ] Detail page hero swaps to clicked thumbnail
- [ ] Videos play inline when selected
- [ ] Lightbox works on click; keyboard nav works
- [ ] Mobile swiper carousel below 768px
- [ ] Falls back gracefully when `product.media` is empty (uses legacy `image_url`)

---

## Final integration checklist

Run in this order after the 15 base prompts:
1. Switch DB to Neon, run migrations, re-seed
2. Set up Cloudinary account + env vars
3. Add `ProductMedia` model + migration + backfill
4. Add `StoreSettings` model + migration + default row
5. Update `OrderCreateSerializer` for GST snapshot
6. Build `AdminSettings` page in admin dashboard
7. Build `ProductGallery` + `MediaLightbox` components
8. Wire `media[]` field into AdminProducts upload form
9. Verify end-to-end: create product with 5 images + 1 video → checkout shows GST line → order receipt shows snapshot
10. Add tests: gallery click swap, GST calc, singleton enforcement, Cloudinary upload mock

---

## Notes for the implementing agent

- The base prompts already include `AdminProducts.jsx` and `ProductDetailPage.jsx` — modify them rather than rewrite.
- Existing `image_url` field stays on `Product` for backward compat; new uploads use `ProductMedia` exclusively.
- Cloudinary uploads happen via `request.FILES` — no client-side Cloudinary widget needed.
- GST applies AFTER discount (subtotal already uses `effective_price`), BEFORE shipping calc.
- Don't break the existing `formatPrice` util — GST is just another summary line.
