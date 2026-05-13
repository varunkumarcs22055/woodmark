# FurniShop — Production Database Schema

**Engine:** Postgres (recommended on GoDaddy / RDS / Neon). Dev uses SQLite,
prod uses Postgres — Django's ORM is engine-agnostic so `python manage.py
migrate` reproduces this schema verbatim against either.

**How to provision on GoDaddy:**

1. Create a Postgres database on GoDaddy ("PostgreSQL Hosting") and note
   `host, port, name, user, password`.
2. In the Django backend, set `DATABASE_URL=postgres://USER:PASS@HOST:PORT/DB`
   (we already use `dj-database-url`).
3. `pip install psycopg2-binary` (already in requirements).
4. `python manage.py migrate` — every table listed below is created.
5. Optionally `python manage.py createsuperuser` and load seed fixtures.

**Naming conventions:**
- All tables are explicit `db_table` (snake_case plural). No Django auto-named
  tables remain.
- Every FK uses ON DELETE per the model: `CASCADE` for child rows, `PROTECT`
  for ledger / financial integrity, `SET NULL` for soft references.
- `created_at` / `updated_at` are `timestamptz` (Django's `DateTimeField`).
- All money columns are `numeric(10,2)` unless explicitly larger
  (`amount_paid`/`amount_due` in invoices = `numeric(12,2)`).

---

## Index of tables (55 user tables)

| App | Tables |
|-----|--------|
| **users** | `users`, `email_otps`, `password_reset_tokens` |
| **products** | `categories`, `products`, `product_media`, `product_variants`, `product_specifications`, `product_delivery_rules`, `product_tags`, `products_tags` |
| **orders** | `orders`, `order_items`, `order_returns`, `refunds` |
| **invoices** | `invoices`, `invoice_items`, `invoice_counters` |
| **payments** | `payments` |
| **discounts** | `discounts` |
| **coupons** | `coupons`, `coupon_redemptions` |
| **shipping** | `shipping_zones` |
| **dealer_credit** | `dealer_credit`, `dealer_payments` |
| **dealer_pricing** | `dealer_tiers`, `negotiated_prices` |
| **dealer_wallet** | `dealer_wallets`, `wallet_transactions` |
| **inventory** | `warehouses`, `stock_levels`, `stock_movements` |
| **support** | `support_tickets`, `support_ticket_messages` |
| **reviews** | `reviews`, `review_votes` |
| **wishlist** | `wishlist_items` |
| **cms** | `cms_pages`, `cms_banners`, `cms_faqs` |
| **media_lib** | `media_assets` |
| **notifications** | `notifications` |
| **audit** | `audit_logs` |
| **store_settings** | `store_settings` |
| **Django/3rd-party** | `auth_group`, `auth_permission`, `django_content_type`, `django_session`, `django_admin_log`, `social_auth_*`, `token_blacklist_*` |

---

## 1 — Users & Auth

### `users`
The single user record for B2C, dealers, and admins. `role` discriminates.

| Column | Type | Notes |
|--------|------|-------|
| id | bigserial PK | |
| email | citext UNIQUE | login id |
| full_name | varchar(120) | |
| phone | varchar(20) | |
| password | varchar(128) | Django PBKDF2 hash |
| role | varchar(10) | `user` / `dealer` / `admin` |
| dealer_status | varchar(10) | `pending` / `active` / `rejected` (only meaningful when role=dealer) |
| dealer_company_name, dealer_gstin, dealer_address, dealer_pan | varchar | KYC fields |
| is_active, is_staff, is_superuser | bool | |
| date_joined, last_login | timestamptz | |

**GSTIN** is validated by regex `^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[0-9]{1}[A-Z]{1}[0-9A-Z]{1}$` on signup.

### `email_otps`
Short-lived OTPs (login + verification).

| Column | Type | Notes |
|--------|------|-------|
| id | bigserial | |
| user_id | FK → users | |
| code | varchar(6) | 6-digit numeric, indexed |
| purpose | varchar(20) | `login` / `verify_email` etc |
| created_at, expires_at, used_at | timestamptz | TTL = 10 min |
| attempts | int2 | brute-force guard |

### `password_reset_tokens`
| Column | Type | Notes |
|--------|------|-------|
| token | varchar(64) UNIQUE | URL-safe random |
| user_id | FK → users | |
| expires_at, used_at | timestamptz | TTL = 60 min |

---

## 2 — Catalog

### `categories`
Self-referential tree (`parent_id`). Slug auto-derived from name.

| Column | Type | Notes |
|--------|------|-------|
| id | bigserial | |
| name | varchar(100) UNIQUE | |
| slug | varchar(100) UNIQUE | URL key — **don't change in prod** |
| parent_id | FK → categories | nullable |
| description, banner_image, sort_order, is_active, created_at | … | |

**Reverse relation:** `nav_tags` (Tag.category) — keywords surfaced under this category in the navbar.

### `products`
Master catalog row. **All rich-PDP content lives here** (highlights, feature blocks, perks, video, specs are referenced).

| Column | Type | Notes |
|--------|------|-------|
| id | bigserial | |
| name | varchar(200) | |
| slug | varchar(200) UNIQUE | |
| sku | varchar(32) UNIQUE | auto-generated `<CAT>-<HEX>` |
| brand | varchar(80) | indexed |
| description | text | long-form |
| short_description | varchar(240) | one-liner above bullets |
| highlights | jsonb | `string[]` — bullets shown next to image |
| feature_blocks | jsonb | `[{title,body,image_url,image_alignment,order}]` for marketing rows |
| perks | jsonb | `[{icon,title,subtitle}]` trust strip |
| youtube_url | varchar(500) | watch / shorts / youtu.be — backend normalizes to `/embed/` |
| warranty_years | int2 | default 1 |
| installation_required | bool | shows "DIY" notice |
| care_instructions, return_policy_days | text/int2 | |
| price | numeric(10,2) | MRP |
| category_id | FK → categories ON DELETE CASCADE | |
| material | varchar(50) | enum |
| color | varchar(50) | |
| dimensions | varchar(100) | free text |
| weight_grams, hsn_code | int/varchar | shipping + GST |
| image_url | varchar(500) | fallback when no `product_media` rows; auto-filled from first uploaded media |
| stock | int | denormalized; authoritative qty in `stock_levels` per warehouse |
| status | varchar(10) | `draft` / `active` / `archived` |
| is_featured, dealer_only | bool | dealer_only hides from public storefront |
| min_order_quantity | int | MOQ enforced at checkout |
| delivery_estimate_days | int2 | fallback when no `product_delivery_rules` match |
| rating_avg, rating_count | numeric(3,2) / int | denormalized from `reviews` |
| meta_title, meta_description, og_image_url | varchar | SEO |
| is_deleted, deleted_at | bool / timestamptz | soft delete |
| created_at, updated_at | timestamptz | |
| **M2M** | `tags` → `product_tags` via `products_tags` | keywords for similar-products + navbar |

**Indexes:** `(category)`, `(material)`, `(price)`, `(status)`, `(is_deleted)`, `(dealer_only)`.

### `product_media`
Cloudinary-backed gallery rows.

| id | bigserial |
| product_id | FK → products ON DELETE CASCADE |
| kind | `image` / `video` |
| file | Cloudinary public_id (stored as text) |
| is_primary | bool |
| order | int — display order |
| alt_text | varchar(200) |
| created_at | timestamptz |

### `product_variants`
Per-option SKUs (e.g. Color: Walnut). Optional.

| id, product_id, sku UNIQUE, option_name, option_value, price_delta, stock, is_active | … |
| Constraint | UNIQUE(product_id, option_name, option_value) |

### `product_specifications`
Spec table rows shown at the bottom of the PDP. Free-form per product (works for any furniture type).

| id, product_id, label, value, sort_order | … |

### `product_delivery_rules`
Quantity-tiered ETAs.

| id, product_id, min_qty, max_qty, etd_days_min, etd_days_max, note | … |

### `product_tags`
Free-form keywords that drive **two** storefront features:

1. **Similar products** — products that share more tags rank higher than category-only matches in `/api/products/similar/<id>/`. Computed in SQL via `Count(tags filter=…)`.
2. **Navbar mega-menu** — when `is_navigation=true`, the tag is surfaced as a sub-link inside its `category` group at `/api/products/nav-tags/`. Renders in the storefront with no redeploy.

| Column | Type | Notes |
|--------|------|-------|
| id | bigserial | |
| name | varchar(80) UNIQUE | display name (e.g. "Office Chair") |
| slug | varchar(100) UNIQUE | URL key — `/?tag=<slug>` |
| description | varchar(200) | optional |
| is_navigation | bool | true → appears in navbar |
| nav_label | varchar(80) | optional override of `name` for menu display |
| nav_order | int | sort within navbar group |
| category_id | FK → categories ON DELETE SET NULL | groups the link under a top-level menu column; null → "Featured" bucket |
| created_at | timestamptz | |

**Indexes:** `(is_navigation, nav_order)`, `(category, is_navigation)`.

**Reverse relation:** `products` (M2M) — every product carrying this tag.

### `products_tags` (M2M through-table)
Auto-managed by Django for `Product.tags ManyToManyField(Tag)`.

| Column | Type | Notes |
|--------|------|-------|
| id | bigserial | |
| product_id | FK → products ON DELETE CASCADE | |
| tag_id | FK → product_tags ON DELETE CASCADE | |
| Constraint | UNIQUE(product_id, tag_id) | enforced by Django M2M default |

**Tag input pipeline (admin):** the Keywords tab on `AdminProducts.jsx` posts `tags: ["office", "executive", …]` (string array). `ProductWriteSerializer._replace_tags` slugifies each, `get_or_create`s the `Tag` row, and `product.tags.set(...)`s the M2M — so admins type new keywords inline without a separate "create tag" step.

---

## 3 — Orders, Items, Returns, Refunds

### `orders`
| Column | Type | Notes |
|--------|------|-------|
| id | bigserial | |
| order_id | varchar(20) UNIQUE | human ID `ORD-XXXXXXXX` |
| user_id | FK → users SET NULL | nullable for guest checkout |
| user_name, user_email, phone, address | … | snapshot |
| subtotal_amount, gst_percent, gst_amount, shipping_amount | numeric | |
| coupon_code, coupon_discount | varchar(40) / numeric | |
| **payment_type** | varchar(12) | `immediate` / `credit` / `cod` — drives early-payment discount |
| **early_payment_discount** | numeric(10,2) | 5% off subtotal when paid now |
| total_amount | numeric(10,2) | |
| payment_status | `PENDING` / `SUCCESS` / `FAILED` | |
| order_status | `CREATED` / `CONFIRMED` / `SHIPPED` / `DELIVERED` / `CANCELLED` | forward-only state machine |
| packing_status, shipping_status | enum | |
| tracking_carrier, tracking_number, shipped_at, delivered_at, cancellation_reason | … | |
| **B2B fields** | | |
| payment_method | `razorpay` / `cod` / `credit` / `wallet` | |
| po_number | varchar(80) | dealer purchase-order ref |
| dealer_note, preferred_carrier | text | |
| erp_order_id, erp_sync_status | … | ERP integration |
| created_at, updated_at | timestamptz | |

**Indexes:** `(user_email)`, `(payment_status, order_status)`, `(payment_type)`.

### `order_items`
| Column | Type | Notes |
|--------|------|-------|
| id, order_id (CASCADE), product_id (PROTECT) | … | |
| quantity | int | |
| price | numeric(10,2) | effective price at time of order |
| original_price | numeric(10,2) | MRP at time of order — needed for invoice "you saved" line |
| **is_backorder, backorder_quantity, expected_restock_date** | bool/int/date | dealer backorder |

### `order_returns`
| id, order_id (CASCADE), requested_by (SET NULL), reason, status, refund_amount, admin_note | … |

### `refunds`
| id, order_id (CASCADE), return_request_id (SET NULL), amount, gateway, gateway_refund_id, status, note | … |

---

## 4 — Invoices

### `invoices`
GST-compliant tax invoice. **Snapshot store** — store name / GSTIN / addresses
are stored at create time so historical invoices don't change when settings do.

| Column | Type | Notes |
|--------|------|-------|
| id | bigserial | |
| invoice_number | varchar(20) UNIQUE | `INV-YYYY-NNNNN` (atomic via `invoice_counters`) |
| order_id | FK → orders ON DELETE PROTECT | OneToOne |
| customer_id | FK → users SET NULL | |
| billing_name, billing_address_text, billing_pincode, billing_state | … | snapshot |
| shipping_address_text | text | |
| store_name, store_legal_name, store_gstin, store_address, store_email, store_phone | … | snapshot |
| subtotal, discount_total, cgst_total, sgst_total, igst_total, shipping_total, grand_total | numeric(10,2) | |
| payment_status, payment_method | enum / varchar | |
| amount_paid, amount_due | numeric(12,2) | wider for partial-payment dealer invoices |
| invoice_date, due_date | date | |
| pdf_url | varchar(500) | optional cached URL (generated on demand by reportlab) |
| emailed_at | timestamptz | |
| notes | text | |
| created_at, updated_at | timestamptz | |

### `invoice_items`
| id, invoice_id (CASCADE), product_id (PROTECT), variant_id (SET NULL) | … |
| product_name, product_sku, variant_label, hsn_code | snapshot text fields |
| quantity, unit_price, original_unit_price, line_subtotal, line_discount | numeric/int |
| cgst_rate, sgst_rate, igst_rate (numeric(5,2)); cgst_amount, sgst_amount, igst_amount, line_total (numeric(10,2)) | … |

### `invoice_counters`
| year | int PK |
| last_seq | int — bumped under `SELECT … FOR UPDATE` for atomic numbering |

---

## 5 — Payments

### `payments`
Razorpay (or other gateway) ledger. One row per payment attempt.

| id, order_id (CASCADE), gateway, gateway_order_id, gateway_payment_id, signature, amount, currency, status, raw_response (jsonb), created_at | … |

---

## 6 — Discounts & Coupons

### `discounts`
Tier-style automatic discounts (volume pricing ladders, time-limited offers).

| id, product_id (CASCADE), discount_type (`user`/`dealer`), mode (`percent`/`flat`), value (numeric(8,2)), min_quantity, count_limit, units_sold, starts_at, ends_at, active, created_at | … |

### `coupons`
Code-based discounts.

| id, code (varchar(40) UNIQUE), type (`percent`/`flat`/`shipping`), value, min_subtotal, max_discount, max_uses, used_count, per_user_limit, allowed_role, valid_from, valid_until, is_active | … |

### `coupon_redemptions`
| id, coupon_id (CASCADE), user_id (SET NULL), order_id (CASCADE), discount_amount, created_at | … |
| Constraint | UNIQUE(coupon_id, order_id) — idempotent redeem |

---

## 7 — Shipping & Inventory

### `shipping_zones`
Pincode-prefix → fee + ETD.

| id, name, pincode_prefix (varchar(6) indexed), base_fee, per_kg_fee, free_shipping_threshold, etd_days_min, etd_days_max, cod_available, is_active, created_at, updated_at | … |

Longest matching prefix wins at runtime.

### `warehouses`
| id, code, name, address, is_active | … |

### `stock_levels`
| id, product_id (CASCADE), warehouse_id (CASCADE), quantity, reserved_quantity, last_counted_at | … |
| Constraint | UNIQUE(product_id, warehouse_id) |

### `stock_movements`
Append-only ledger.

| id, product_id (CASCADE), warehouse_id (CASCADE), kind (`in`/`out`/`adjust`), quantity, reason, ref_type, ref_id, created_by (SET NULL), created_at | … |

---

## 8 — Dealer (B2B)

### `dealer_credit`
| id, dealer_id (CASCADE — UNIQUE), credit_limit, amount_used, terms_days, is_active, created_at, updated_at | … |
| Property | `remaining = credit_limit - amount_used` |

### `dealer_payments`
Append-only ledger of dealer credit-side payments.

| id, dealer_id (CASCADE), amount (numeric(10,2)), method, reference, recorded_by (SET NULL), order_id (SET NULL — payment can be cross-order), created_at | … |

### `dealer_tiers`
Dealer-level pricing rules (replace public discount tiers when role=dealer).

| id, dealer_id (CASCADE), category_id (CASCADE — nullable for "all"), discount_pct, qty_min, qty_max, valid_from, valid_until, is_active, created_at | … |

### `negotiated_prices`
Override per (dealer, product). Wins outright over tier ladders.

| id, dealer_id (CASCADE), product_id (CASCADE), price, valid_from, valid_until, created_at | … |
| Constraint | UNIQUE(dealer_id, product_id) (active overlap enforced in app code) |

### `dealer_wallets`
Pre-paid balance for instant checkouts.

| id, dealer_id (CASCADE — UNIQUE), balance (numeric(10,2)), is_active, created_at, updated_at | … |

### `wallet_transactions`
Append-only ledger.

| id, wallet_id (CASCADE), kind (`credit`/`debit`), amount, balance_after, reason, reference, order_id (SET NULL), actor_id (SET NULL — admin who recorded), created_at | … |

---

## 9 — Support, Reviews, Wishlist

### `support_tickets`
| id, ticket_number (UNIQUE — `TKT-YYYY-NNNNN`), user_id (CASCADE), subject, category, priority, status, related_order_id (SET NULL), assigned_to (SET NULL), created_at, updated_at | … |

### `support_ticket_messages`
| id, ticket_id (CASCADE), sender_id (SET NULL), body, is_internal_note, attachment_url, created_at | … |

### `reviews`
| id, product_id (CASCADE), user_id (SET NULL), rating (int 1-5), title, body, is_approved, verified_purchase, created_at, updated_at | … |
| Constraint | UNIQUE(product_id, user_id) — one review per (product, user) |

### `review_votes`
| id, review_id (CASCADE), user_id (CASCADE), is_helpful (bool), created_at | UNIQUE(review_id, user_id) |

### `wishlist_items`
| id, user_id (CASCADE), product_id (CASCADE), added_at | UNIQUE(user_id, product_id) |

---

## 10 — Content & Settings

### `cms_pages`
| id, slug (UNIQUE), title, body (text), is_published, updated_by (SET NULL), updated_at | … |

### `cms_banners`
Hero/promo banners on home.

| id, title, subtitle, image_url, link_url, sort_order, starts_at, ends_at, is_active | … |

### `cms_faqs`
| id, question, answer, category, sort_order | … |

### `media_assets`
Standalone Cloudinary uploads (not tied to a product) — used by CMS banners/feature blocks.

| id, kind, public_id, url, uploaded_by (SET NULL), tag (varchar — for organization), created_at | … |

### `store_settings`
Singleton row.

| id (always 1), gst_percent, free_shipping_threshold, standard_shipping_fee, store_name, store_legal_name, store_gstin, store_address, store_email, store_phone, updated_by (SET NULL), updated_at | … |

---

## 11 — Notifications & Audit

### `notifications`
In-app inbox.

| id, user_id (CASCADE), kind, title, body, link_url, is_read, created_at | … |

### `audit_logs`
Admin action log — every privileged write goes through `AuditedMixin`.

| id, actor_id (SET NULL), action (`create`/`update`/`delete`/`other`), target_type, target_id, payload (jsonb), ip_address, user_agent, created_at | … |

**Indexes:** `(actor_id, -created_at)`, `(target_type, target_id)`.

---

## 12 — Django / 3rd-party

These come for free with Django and the libraries we use; don't drop them.

| Table | Purpose |
|-------|---------|
| `auth_group`, `auth_permission` | Group permissions |
| `django_content_type` | model registry |
| `django_session` | server-side sessions (admin) |
| `django_admin_log` | Django admin trail |
| `django_migrations` | migration history |
| `social_auth_*` (5 tables) | Google OAuth (django-social-auth) |
| `token_blacklist_outstandingtoken`, `token_blacklist_blacklistedtoken` | SimpleJWT blacklist for logout-revocation |

---

## ER snapshot (high-level)

```
users 1───* orders 1───* order_items *───1 products *───1 categories
   │                                       │              │
   │                                       │              *──* product_tags  (Tag.category)
   │                                       │
   │                                       *───* product_media (Cloudinary)
   │                                       │
   │                                       *───* product_specifications
   │                                       │
   │                                       *───* product_delivery_rules
   │                                       │
   │                                       *───* product_variants
   │                                       │
   │                                       *──* product_tags  (M2M via products_tags;
   │                                                           Tag.is_navigation=true →
   │                                                           rendered in storefront navbar)
   │
   ├─*── reviews     ├─1 invoice ─*── invoice_items
   ├─*── wishlist    │
   ├─1── dealer_credit (only dealers)
   ├─1── dealer_wallet (only dealers)
   ├─*── support_tickets ─*── support_ticket_messages
   └─*── notifications

orders ─*── payments
orders ─*── order_returns ─*── refunds
products ─*── discounts
products ─*── stock_levels ─*── stock_movements (per warehouse)
shipping_zones (pincode prefixes — runtime longest-prefix match)
coupons ─*── coupon_redemptions
```

---

## Production checklist before pointing at GoDaddy

1. **`DATABASE_URL`** set via env (use `.env` not committed). Verify
   `python manage.py check --database default` returns OK.
2. **`SECRET_KEY`** rotated; do **not** reuse the dev key.
3. **`DEBUG=False`** + `ALLOWED_HOSTS` populated with the GoDaddy domain.
4. **`CSRF_TRUSTED_ORIGINS`** + **`CORS_ALLOWED_ORIGINS`** updated to the
   storefront origin (not `localhost`).
5. **Cloudinary**: set `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`,
   `CLOUDINARY_API_SECRET`. The frontend never touches these — uploads
   funnel through `/api/products/admin/` (multipart) and Django pushes to
   Cloudinary.
6. **Razorpay**: set `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET` and on the
   frontend `VITE_RAZORPAY_ENABLED=true`. Keep them simulated until you
   actually have keys.
7. **Email**: configure SMTP (`EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_HOST_USER`,
   `EMAIL_HOST_PASSWORD`, `EMAIL_USE_TLS=True`). Used for OTP, password
   reset, invoice email, ticket notifications.
8. **First-run**:
   ```
   python manage.py migrate
   python manage.py createsuperuser
   python manage.py loaddata seed_categories.json   # if you keep fixtures
   python manage.py collectstatic --noinput
   ```
9. **`StoreSettings`** singleton — open `/admin/store_settings/storesettings/`
   and fill in legal name, GSTIN, address, contact. These flow to every
   invoice header.
10. **Cron / queue** (nice-to-have, not required for v1):
    - Daily: `python manage.py expire_offers` (close ended discount rows)
    - Hourly: ERP retry sweep on `orders.erp_sync_status='failed'`

---

## Adding a new field to `products` later

The product model is the most-edited one. Use this pattern so future Postgres
migrations stay clean:

1. Add field to `backend/products/models.py`.
2. `python manage.py makemigrations products` — produces e.g.
   `backend/products/migrations/0011_…py`.
3. Expose it in **both** `ProductDetailSerializer` (read) and
   `ProductWriteSerializer` (write).
4. Add an input in the matching admin tab inside
   `frontend/src/pages/admin/AdminProducts.jsx` (`BasicsTab`,
   `PricingTab`, `MediaTab`, `HighlightsTab`, `SpecsTab`,
   `FeatureBlocksTab`, `KeywordsTab`, `ExtrasTab`).
5. Render it on the PDP in
   `frontend/src/pages/ProductDetailPage.jsx`.

That's the complete loop — `manage.py migrate` on prod will apply the
generated migration without downtime.
