# Amazon-Style Product Listing — Field Spec

What every product card on the listings page must show, what every product detail page must show, and which backend field maps to each.

Status legend: ✅ exists in API today · 🟡 field exists but not on serializer · ❌ needs to be added

---

## A. Product Card (grid view — homepage / category / search results)

| Slot | Source field | Status | Notes |
|---|---|---|---|
| Primary image | `product.primary_image` (falls back to `image_url`) | ✅ | Cloudinary auto-WebP |
| Hover/secondary image | second `media[]` entry where `kind='image'` | ✅ | Optional |
| Brand line | `product.brand` | ❌ | Add to model |
| Title (1–2 lines, truncated) | `product.name` | ✅ | |
| Star rating | `product.rating_avg` | ❌ | Denorm from reviews |
| Rating count | `product.rating_count` | ❌ | Denorm |
| **Effective price** (large) | `product.effective_price` | ✅ | Role + qty aware |
| **MRP / strike-through** | `product.price` (when different) | ✅ | |
| Discount badge ("20% off") | computed `(price-effective)/price` | ✅ | |
| **Limited-time tag** ("Ends in 2h") | `product.time_offer.ends_at` | ✅ | From `/api/products/limited-offers/` |
| Stock indicator | `product.in_stock`, `product.stock` | ✅ | "Only 3 left" when `stock <= 5` |
| Delivery estimate | from `/api/shipping/estimate/?pincode=&product_id=` | ❌ | Pincode-aware |
| Wishlist heart icon | reads `/api/wishlist/` | ❌ | Toggles row |
| Add-to-cart button | client-side via `CartContext` | ✅ | |
| Sponsored badge | `product.is_sponsored` | ❌ | Optional, future ad system |
| Variant chips (color swatches) | `product.variants[]` | 🟡 | Model exists; expose on list serializer |

**Card layout (mobile-first):**
```
┌──────────────────────┐
│                      │
│      product image   │  ← 4:5 aspect
│                      │
│  ♡  20% OFF          │  ← top-right wishlist + top-left badge
│  ⏱ Ends in 2h        │  ← time-offer banner (only when time-bound)
└──────────────────────┘
  BRAND NAME
  Product name in two lines
  ★★★★☆ 4.2 (1,248)
  ₹10,399  ₹12,999  20% off
  [● ● ● ● ●] color chips
  Free delivery by Mon, May 12
  [    Add to Cart    ]
```

---

## B. Product Detail Page (PDP — `/product/<slug>`)

### Above-the-fold (left column = gallery, right column = buy box)

| Slot | Source | Status |
|---|---|---|
| Image gallery (zoomable, swipeable) | `product.media[]` ordered by `order` | ✅ via `ProductGallery` |
| 360° / video | media item with `kind='video'` | ✅ |
| Breadcrumb | category trail | ✅ |
| Brand | `product.brand` | ❌ |
| Title (h1) | `product.name` | ✅ |
| Star rating + reviews count → anchor link | `rating_avg`, `rating_count` | ❌ |
| Q&A count | aggregate from `/api/qa/?product_id=` | ❌ (future) |
| **Pricing block** | `effective_price`, `price`, `discount_applied`, **`discount_tiers`** | ✅ |
| Tier ladder ("Buy 2: ₹X, 5: ₹Y") | `discount_tiers[]` | ✅ shipped |
| Time-offer countdown | `time_offer.ends_at` | ✅ on listings; ❌ on PDP |
| GST inclusive note | from `StoreSettings.tax_inclusive` | ✅ via `SettingsContext` |
| **Pincode delivery checker** input | `/api/shipping/estimate/` | ❌ |
| Variant selector (color/size) | `product.variants[]` | 🟡 |
| Quantity stepper | local | ✅ |
| **Add to Cart** | client | ✅ |
| **Buy Now** (skip cart, go straight to checkout) | client | ❌ |
| Wishlist heart | `/api/wishlist/` | ❌ |
| Share | client | ❌ optional |
| Stock status | `in_stock`, `stock` | ✅ |
| **Highlights bullet list** ("3-year warranty · Solid sheesham") | `product.highlights[]` | ❌ |

### Below the fold

| Section | Source |
|---|---|
| Specifications table | `product.specifications[]` ✅ |
| Long description | `product.description` ✅ |
| Shipping & returns policy excerpt | `cms.Page(slug='shipping')`, `cms.Page(slug='returns')` ❌ wire-up |
| **Reviews section** (sortable: newest / most-helpful / by rating) | `/api/reviews/?product_id=` ❌ |
| **Review summary histogram** (% of 5★, 4★, …) | aggregate ❌ |
| Write-a-review CTA (only if user purchased) | `OrderItem` exists for user+product ❌ |
| Q&A | future |
| **Similar / frequently bought together** | `/api/products/similar/{id}/` ✅ for "similar"; FBT ❌ |
| Recently viewed | localStorage ❌ |
| Sponsored "from this brand" | `?brand=` filter ❌ |

### SEO / metadata (rendered into `<head>` on PDP)

| Tag | Source |
|---|---|
| `<title>` | `product.meta_title` or `product.name` ❌ |
| `<meta name="description">` | `product.meta_description` ❌ |
| `<meta property="og:title">` | same ❌ |
| `<meta property="og:image">` | `product.og_image_url` or `primary_image` ❌ |
| `<meta property="og:price:amount">` | `effective_price` ❌ |
| JSON-LD `Product` schema | computed from product + reviews ❌ |
| `<link rel="canonical">` | `/product/<slug>` ❌ |

---

## C. Required API additions to support the spec above

### 1. Augment `ProductListSerializer` (used by listings)

```python
fields += [
    'brand',
    'rating_avg', 'rating_count',
    'highlights',
    'time_offer',          # only on /limited-offers/, but keep optional
    'variants_summary',    # array of {color, swatch_url} for chip rendering
]
```

### 2. Augment `ProductDetailSerializer` (used by PDP)

```python
fields += [
    'brand', 'hsn_code',
    'rating_avg', 'rating_count', 'rating_histogram',
    'highlights',
    'meta_title', 'meta_description', 'og_image_url',
    'delivery_estimate_days',
    'reviews_summary',     # {avg, count, by_star: {1: n, 2: n, …}}
]
```

### 3. New endpoints

| Path | Returns |
|---|---|
| `GET /api/shipping/estimate/?pincode=560001&product_id=42` | `{available, courier, sla_min_days, sla_max_days, cod_supported, charge}` |
| `GET /api/wishlist/` | current user's wishlist items |
| `POST /api/wishlist/{product_id}/` | add (idempotent) |
| `DELETE /api/wishlist/{product_id}/` | remove |
| `GET /api/reviews/?product_id=&ordering=` | paginated approved reviews |
| `POST /api/reviews/` | create (status=pending, sets verified_purchase if matching order item) |
| `GET /api/reviews/summary/?product_id=` | `{avg, count, by_star}` |
| `POST /api/reviews/{id}/helpful/` | toggle helpful vote |
| `PATCH /api/admin/reviews/{id}/` | admin moderation |

---

## D. Frontend components to add / update

| Component | Status | Notes |
|---|---|---|
| `components/StarRating.jsx` | ❌ NEW | Display + input variants; props `{rating, count?, interactive?}` |
| `components/PincodeChecker.jsx` | ❌ NEW | Input + result chip; uses `/shipping/estimate/` |
| `components/WishlistButton.jsx` | ❌ NEW | Heart icon, optimistic toggle |
| `components/ReviewForm.jsx` | ❌ NEW | star-picker + title + body |
| `components/ReviewList.jsx` | ❌ NEW | sortable, paginated |
| `components/ReviewSummary.jsx` | ❌ NEW | histogram bar |
| `components/CountdownPill.jsx` | ❌ NEW | "ends in 2h 13m" — re-renders every minute |
| `components/ProductCard.jsx` | ✅ extend | add brand, rating, stock, time-offer slots |
| `components/ProductGallery.jsx` | ✅ | already supports images + video |
| `pages/ProductDetailPage.jsx` | ✅ extend | wire all new components |
| `pages/WishlistPage.jsx` | ❌ NEW | `/wishlist` route |

---

## E. Rendering rules / acceptance

1. **Card MUST render with whatever it has.** If `rating_count = 0`, hide the rating block; if `brand` is null, hide that line; never show the literal string "null". Don't crash on missing `time_offer`.
2. **Pricing always uses backend numbers.** No client-side `price * 0.8` math except for the live tier-preview already shipped.
3. **Lazy-load images below the fold.** `<img loading="lazy">` on every card image.
4. **Truncate names with CSS, not by slicing.** `-webkit-line-clamp: 2`.
5. **Skeletons** during fetch — already have `.product-skeleton`.
6. **Empty states** — when no products match filter, show friendly message + clear-filters CTA (already done).
