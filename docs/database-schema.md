# FurniShop — Complete Database Schema

This is every table that should exist in production, with every column, type, and key relationship. Tables marked **EXISTS** are already in the codebase; tables marked **NEW** need to be created. Columns marked `+` are net-new on existing tables.

Conventions: all tables get `id BIGSERIAL PK`, `created_at`, `updated_at` unless stated otherwise. FK names follow `<table>_id`. All money columns are `DECIMAL(10, 2)` unless noted.

---

## 1. Users & Auth (EXISTS, with additions)

### `users` — EXISTS
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | Django auto |
| email | VARCHAR(254) UNIQUE | login key |
| username | VARCHAR(150) UNIQUE | mirror of email |
| password | VARCHAR(128) | Django-hashed |
| first_name, last_name | VARCHAR | |
| phone | VARCHAR(15) NULL | |
| role | VARCHAR(10) | `user` / `dealer` / `admin` |
| dealer_status | VARCHAR(10) NULL | `pending` / `active` / `rejected` |
| dealer_company_name | VARCHAR(200) NULL | |
| dealer_gst_number | VARCHAR(15) NULL | |
| is_blocked | BOOL DEFAULT FALSE | login → 403 if true |
| is_active, is_staff, is_superuser | BOOL | Django auth |
| date_joined | TIMESTAMPTZ | |
| `+ default_billing_address_id` | FK → addresses NULL | NEW |
| `+ default_shipping_address_id` | FK → addresses NULL | NEW |
| `+ phone_verified` | BOOL DEFAULT FALSE | NEW (for OTP) |

### `addresses` — NEW
A user can have many addresses (billing & shipping reuse the same table).

| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| user_id | FK → users CASCADE | |
| label | VARCHAR(40) | e.g. "Home", "Office" |
| recipient_name | VARCHAR(120) | |
| phone | VARCHAR(15) | |
| line1, line2 | VARCHAR(255), VARCHAR(255) NULL | |
| city, state | VARCHAR(80), VARCHAR(80) | |
| pincode | VARCHAR(10) INDEX | India PIN |
| country | VARCHAR(2) DEFAULT 'IN' | ISO-3166 |
| is_default_billing, is_default_shipping | BOOL | |
| created_at, updated_at | TIMESTAMPTZ | |

---

## 2. Catalog

### `categories` — EXISTS
Already has: `name`, `slug` UNIQUE, `description`, `parent_id` (self-FK), `banner_image`, `is_active`, `sort_order`, `created_at`.

### `products` — EXISTS, with additions
| Column | Type | Status |
|---|---|---|
| id, name, slug UNIQUE, description, price, category_id, material, color, dimensions, image_url, stock, status, is_featured, sku UNIQUE, created_at, updated_at | — | EXISTS |
| `+ brand` | VARCHAR(80) NULL | NEW |
| `+ hsn_code` | VARCHAR(10) NULL | NEW (GST classification) |
| `+ highlights` | JSONB DEFAULT '[]' | NEW (bullet points list) |
| `+ meta_title` | VARCHAR(160) NULL | NEW (SEO) |
| `+ meta_description` | VARCHAR(320) NULL | NEW (SEO) |
| `+ og_image_url` | VARCHAR(500) NULL | NEW (social preview) |
| `+ rating_avg` | DECIMAL(3,2) DEFAULT 0 | NEW (denorm of reviews) |
| `+ rating_count` | INT DEFAULT 0 | NEW |
| `+ delivery_estimate_days` | INT DEFAULT 7 | NEW (fallback) |
| `+ weight_grams` | INT NULL | NEW (for shipping) |
| `+ is_deleted` | BOOL DEFAULT FALSE | NEW (soft-delete) |
| `+ deleted_at` | TIMESTAMPTZ NULL | NEW |

### `product_variants` — EXISTS
Already has: `product_id`, `sku` UNIQUE, `option_name`, `option_value`, `price_delta`, `stock`, `is_active`, `created_at`. UNIQUE(`product_id, option_name, option_value`).

### `product_specifications` — EXISTS
Already has: `product_id`, `label`, `value`, `sort_order`.

### `product_media` — EXISTS
Already has: `product_id`, `kind` (image/video), `file` (Cloudinary), `is_primary`, `order`, `alt_text`, `created_at`.

---

## 3. Inventory (EXISTS)

### `warehouses`
`name UNIQUE, code UNIQUE, address, is_active, created_at`.

### `stock_levels`
`product_id, variant_id NULL, warehouse_id, quantity INT, low_threshold, updated_at`. UNIQUE(`product, variant, warehouse`).

### `stock_movements`
`stock_level_id, delta INT, reason, reference, note, actor_id NULL, created_at`. Append-only ledger.

---

## 4. Cart (EXISTS, session-based)

### `carts`, `cart_items`
Session-based. Frontend primarily uses `localStorage` (`furnishop_cart`). Backend `cart` app is a fallback.

---

## 5. Orders & Returns (EXISTS, with additions)

### `orders` — EXISTS, with additions
Already has: `order_id` UNIQUE (e.g. `ORD-XXXX`), `user_name`, `user_email`, `phone`, `address`, `user_id` NULL, `subtotal_amount`, `gst_percent`, `gst_amount`, `shipping_amount`, `total_amount`, `payment_status`, `order_status`, `packing_status`, `shipping_status`, `tracking_carrier`, `tracking_number`, `shipped_at`, `delivered_at`, `cancellation_reason`, `erp_order_id`, `erp_sync_status`, `created_at`, `updated_at`.

| Column | Type | Status |
|---|---|---|
| `+ billing_address_id` | FK → addresses NULL | NEW |
| `+ shipping_address_id` | FK → addresses NULL | NEW |
| `+ pincode` | VARCHAR(10) | NEW (denorm for analytics) |
| `+ cgst_amount` | DECIMAL(10,2) DEFAULT 0 | NEW |
| `+ sgst_amount` | DECIMAL(10,2) DEFAULT 0 | NEW |
| `+ igst_amount` | DECIMAL(10,2) DEFAULT 0 | NEW |
| `+ discount_amount` | DECIMAL(10,2) DEFAULT 0 | NEW (sum of line discounts for invoice) |
| `+ shipping_zone_id` | FK → shipping_zones NULL | NEW |
| `+ payment_method` | VARCHAR(20) DEFAULT 'razorpay' | NEW (`razorpay` / `cod`) |
| `+ is_deleted` | BOOL DEFAULT FALSE | NEW (soft delete) |

### `order_items` — EXISTS
Already has: `order_id, product_id, quantity, price (effective), original_price`. Add `+ variant_id NULL` (FK), `+ tax_amount` (per-line GST snapshot).

### `order_returns` — EXISTS
`order_id, requested_by_id, reason, status, refund_amount, admin_note, created_at, updated_at`.

### `refunds` — EXISTS
`order_id, return_request_id NULL, amount, gateway, gateway_refund_id, status, note, created_at`.

---

## 6. Invoices — NEW (very important)

### `invoices`
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| invoice_number | VARCHAR(20) UNIQUE INDEX | `INV-YYYY-#####`, year-prefixed |
| order_id | FK → orders ON DELETE PROTECT | one invoice per order (1:1) |
| customer_id | FK → users NULL | for guest orders, NULL |
| billing_name | VARCHAR(120) | snapshot |
| billing_address_text | TEXT | snapshot of full address |
| billing_pincode | VARCHAR(10) | |
| billing_state | VARCHAR(80) | for GST jurisdiction |
| shipping_address_text | TEXT NULL | if different |
| store_name | VARCHAR(120) | snapshot from StoreSettings at invoice time |
| store_gstin | VARCHAR(15) | snapshot |
| store_address | TEXT | snapshot |
| store_email, store_phone | VARCHAR | snapshot |
| subtotal | DECIMAL(10,2) | sum of items.total_excl_tax |
| discount_total | DECIMAL(10,2) DEFAULT 0 | |
| cgst_total | DECIMAL(10,2) DEFAULT 0 | |
| sgst_total | DECIMAL(10,2) DEFAULT 0 | |
| igst_total | DECIMAL(10,2) DEFAULT 0 | |
| shipping_total | DECIMAL(10,2) DEFAULT 0 | |
| grand_total | DECIMAL(10,2) | |
| payment_status | VARCHAR(10) | mirrors order at invoice-create time |
| invoice_date | DATE | |
| due_date | DATE NULL | |
| pdf_url | VARCHAR(500) NULL | Cloudinary, populated lazily |
| emailed_at | TIMESTAMPTZ NULL | |
| created_at | TIMESTAMPTZ | |

### `invoice_items`
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| invoice_id | FK → invoices CASCADE | |
| product_id | FK → products PROTECT | |
| variant_id | FK → product_variants NULL | |
| product_name | VARCHAR(255) | snapshot (handles future renames) |
| product_sku | VARCHAR(40) | snapshot |
| hsn_code | VARCHAR(10) | snapshot |
| quantity | INT | |
| unit_price | DECIMAL(10,2) | net of discount, pre-tax |
| original_unit_price | DECIMAL(10,2) | MRP at order time |
| line_subtotal | DECIMAL(10,2) | unit_price × quantity |
| line_discount | DECIMAL(10,2) DEFAULT 0 | |
| cgst_rate | DECIMAL(5,2) | e.g. 9.00 |
| sgst_rate | DECIMAL(5,2) | |
| igst_rate | DECIMAL(5,2) | mutually exclusive with CGST/SGST |
| cgst_amount, sgst_amount, igst_amount | DECIMAL(10,2) | |
| line_total | DECIMAL(10,2) | subtotal − discount + taxes |

### `invoice_counters` (helper table for atomic numbering)
| Column | Type | Notes |
|---|---|---|
| year | INT PK | e.g. 2026 |
| last_seq | INT DEFAULT 0 | atomic increment via `SELECT … FOR UPDATE` |

Numbering: `INV-{year}-{seq:05d}` → `INV-2026-00001`, `INV-2026-00002`, …

---

## 7. Payments (EXISTS, with additions)

### `payments` — EXISTS (Razorpay)
Already tracks Razorpay order/payment IDs and verification.

| Column | Type | Notes |
|---|---|---|
| `+ method` | VARCHAR(20) | `razorpay` / `cod` |
| `+ webhook_event_id` | VARCHAR(80) NULL | for idempotency |
| `+ failure_reason` | TEXT NULL | |

### `webhook_events` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| provider | VARCHAR(20) | `razorpay`, `resend`, … |
| event_id | VARCHAR(80) UNIQUE | provider's event ID for dedup |
| event_type | VARCHAR(80) | e.g. `payment.captured` |
| payload | JSONB | full body |
| signature | VARCHAR(256) | for audit |
| processed_at | TIMESTAMPTZ NULL | |
| status | VARCHAR(10) DEFAULT 'received' | `received` / `processed` / `failed` |
| error_message | TEXT NULL | |
| created_at | TIMESTAMPTZ | |

---

## 8. Discounts / Coupons (EXISTS, with additions)

### `discounts` — EXISTS
Already has: `product_id, discount_type (user/dealer), mode (percent/flat), value, min_quantity, count_limit, units_sold, active, starts_at, ends_at, created_by_id, created_at, updated_at`. UNIQUE(`product, discount_type, min_quantity`).

### `coupons` — NEW (separate from per-product discounts)
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| code | VARCHAR(40) UNIQUE | uppercased on save |
| description | VARCHAR(200) NULL | |
| kind | VARCHAR(10) | `percent` / `fixed` |
| value | DECIMAL(10,2) | |
| min_subtotal | DECIMAL(10,2) DEFAULT 0 | |
| max_discount | DECIMAL(10,2) NULL | caps % discounts |
| valid_from, valid_until | TIMESTAMPTZ | |
| usage_limit | INT NULL | NULL = unlimited |
| per_user_limit | INT NULL | |
| times_used | INT DEFAULT 0 | |
| is_active | BOOL DEFAULT TRUE | |
| created_at, updated_at | TIMESTAMPTZ | |

### `coupon_categories` (M2M)
`coupon_id, category_id` — empty list = "all categories".

### `coupon_usages` — NEW (per-user / per-order tracking)
| id | BIGSERIAL PK |
| coupon_id | FK |
| user_id | FK NULL |
| order_id | FK |
| amount_applied | DECIMAL(10,2) |
| used_at | TIMESTAMPTZ |

---

## 9. Reviews & Ratings — NEW

### `reviews`
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| product_id | FK → products CASCADE | |
| user_id | FK → users CASCADE | |
| order_item_id | FK → order_items NULL | sets verified_purchase=TRUE if non-null |
| rating | INT (CHECK 1..5) | |
| title | VARCHAR(120) NULL | |
| body | TEXT | |
| verified_purchase | BOOL DEFAULT FALSE | |
| status | VARCHAR(10) DEFAULT 'pending' | `pending` / `approved` / `rejected` |
| helpful_count | INT DEFAULT 0 | |
| moderator_id | FK → users NULL | |
| moderated_at | TIMESTAMPTZ NULL | |
| created_at, updated_at | TIMESTAMPTZ | |

UNIQUE(`product_id, user_id`) — one review per user per product.

### `review_votes` (optional helpful/not-helpful)
`review_id, user_id, value INT (-1 or +1), created_at`. UNIQUE(review_id, user_id).

---

## 10. Wishlist — NEW

### `wishlist_items`
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| user_id | FK → users CASCADE | |
| product_id | FK → products CASCADE | |
| variant_id | FK → product_variants NULL | |
| added_at | TIMESTAMPTZ | |

UNIQUE(`user_id, product_id, variant_id`).

---

## 11. Shipping — NEW

### `shipping_zones`
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| name | VARCHAR(80) | "Metro Tier 1", "Northeast" |
| pincode_prefix | VARCHAR(4) INDEX | leftmost 1–4 digits of PIN |
| courier_name | VARCHAR(80) | Bluedart, Delhivery, … |
| base_charge | DECIMAL(10,2) | |
| per_kg_charge | DECIMAL(10,2) DEFAULT 0 | |
| free_above | DECIMAL(10,2) NULL | order subtotal threshold |
| sla_min_days, sla_max_days | INT, INT | delivery estimate |
| cod_supported | BOOL DEFAULT TRUE | |
| is_active | BOOL DEFAULT TRUE | |

Algorithm to pick zone for a pincode: longest matching `pincode_prefix` wins. No match → falls back to `StoreSettings.standard_shipping_fee`.

### `shipments` — NEW (1:1 with order, but separate so we can support split shipments later)
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| order_id | FK → orders | |
| courier_name | VARCHAR | |
| tracking_number | VARCHAR(80) | |
| label_url | VARCHAR(500) NULL | Cloudinary |
| status | VARCHAR(20) | `created` / `picked_up` / `in_transit` / `out_for_delivery` / `delivered` / `failed` |
| shipped_at, delivered_at | TIMESTAMPTZ NULL | |
| tracking_events | JSONB | array of `{at, status, location, note}` |

For v1, shipments duplicate fields on `Order` — but the model lets us split a single order into multiple shipments later.

---

## 12. Notifications (EXISTS)

### `notifications`
`user_id, kind, title, body, payload JSONB, is_read, created_at`.

### `notification_preferences` — NEW
| Column | Type | Notes |
|---|---|---|
| user_id | FK → users PK | one row per user |
| email_order_updates | BOOL DEFAULT TRUE | |
| email_marketing | BOOL DEFAULT FALSE | |
| sms_order_updates | BOOL DEFAULT TRUE | |
| sms_marketing | BOOL DEFAULT FALSE | |

---

## 13. CMS (EXISTS, with additions)

### `cms_banners`, `cms_pages`, `cms_faqs` — EXISTS

### `blog_articles` — NEW (optional v2)
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| slug UNIQUE | VARCHAR(100) | |
| title | VARCHAR(200) | |
| excerpt | VARCHAR(400) | |
| body_md | TEXT | |
| cover_image | Cloudinary | |
| author_id | FK → users NULL | |
| tags | JSONB DEFAULT '[]' | |
| is_published | BOOL DEFAULT FALSE | |
| published_at | TIMESTAMPTZ NULL | |
| meta_title, meta_description | VARCHAR | |
| created_at, updated_at | | |

---

## 14. Audit & System

### `audit_logs` — EXISTS
`actor_id, action, target_type, target_id, payload JSONB, ip, user_agent, created_at`.

### `media_assets` — EXISTS
`public_id UNIQUE, secure_url, kind, bytes, width, height, folder, tags JSONB, uploaded_by_id, created_at`.

### `store_settings` — EXISTS (singleton row)
Already has: `name, gst_percent, free_shipping_threshold, standard_shipping_fee, cod_enabled, currency_code/symbol, …`.

| Column | Type | Status |
|---|---|---|
| `+ legal_name` | VARCHAR(200) | NEW |
| `+ gstin` | VARCHAR(15) | NEW |
| `+ store_state` | VARCHAR(80) | NEW (for CGST/SGST jurisdiction) |
| `+ store_pincode` | VARCHAR(10) | NEW |

---

## 15. Background / Reliability — NEW

### `email_outbox` (optional, when no Celery yet)
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| to_email | VARCHAR(254) | |
| subject | VARCHAR(255) | |
| body_text | TEXT | |
| body_html | TEXT NULL | |
| status | VARCHAR(10) DEFAULT 'pending' | `pending` / `sent` / `failed` |
| attempts | INT DEFAULT 0 | |
| last_error | TEXT NULL | |
| send_after | TIMESTAMPTZ DEFAULT NOW() | |
| sent_at | TIMESTAMPTZ NULL | |
| created_at | TIMESTAMPTZ | |

A management command `python manage.py drain_email_outbox` runs every minute (cron) and sends pending rows. Once Celery is in, this table goes away.

---

## ER summary

```
users 1───* addresses
users 1───* orders ──┐
users 1───* reviews  │
users 1───* wishlist │
users 1───* notifications
                     │
orders 1───* order_items ──* products ──* product_variants
orders 1───1 invoices ──* invoice_items
orders 1───1 shipments
orders 1───* refunds
orders 1───1 payments
orders 1───* order_returns

products *───1 categories ──┐ self-FK parent
products 1───* product_media
products 1───* product_variants
products 1───* product_specifications
products 1───* discounts (per-tier)
products 1───* reviews

shipping_zones (pincode-prefix lookup table)
warehouses 1───* stock_levels ──* products
stock_levels 1───* stock_movements
```

---

## Migration ordering (so foreign-keys exist before tables that reference them)

1. `users.0004_add_address_default_fks_phone_verified` (additions only — actual `addresses` table created in step 2)
2. `addresses.0001_initial`
3. `products.0007_add_seo_brand_hsn_rating_softdelete`
4. `shipping.0001_initial` (zones + shipments)
5. `invoices.0001_initial` (invoices, invoice_items, invoice_counters)
6. `reviews.0001_initial`
7. `wishlist.0001_initial`
8. `coupons.0001_initial` (coupons, coupon_categories, coupon_usages)
9. `payments.000X_add_method_webhook_event_failure`
10. `webhooks.0001_initial`
11. `orders.000X_add_addresses_gst_split_shipping_zone_method`
12. `notifications.0002_preferences`
13. `store_settings.000X_add_legal_gstin_state_pincode`

Each migration is reversible. Data migrations (e.g. backfilling `Order.pincode` from `Order.address`) use `RunPython` with a no-op reverse.
