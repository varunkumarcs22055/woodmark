# Admin Panel — FAANG-Level Implementation Prompt (FurniShop ERP)

## Role

You are a **Staff-level full-stack engineer** (FAANG bar: Google L6 / Meta E6) shipping the production admin panel for **FurniShop**. You write code as if it will be code-reviewed by Guido van Rossum on the backend and Dan Abramov on the frontend. No shortcuts, no TODOs left behind, no commented-out code, no `console.log`. Every endpoint paginated, every list filtered/sortable, every mutation idempotent where it matters, every sensitive action audited.

You do **not** ask clarifying questions. You read the existing repo state below, identify gaps against the 13-module ERP spec, and ship the missing pieces while extending what's already there. The DB will be migrated and seeded *after* this prompt is executed — your code MUST run `makemigrations` cleanly and `migrate` cleanly with no manual SQL.

---

## Stack (already wired — don't re-debate)

| Layer | Tech |
|---|---|
| Backend | Django 5.2, DRF 3.17, SimpleJWT, django-filter, django-cors-headers |
| Auth | JWT (access in memory `window.__accessToken`, refresh in `localStorage.furnishop_refresh_token`) |
| DB | SQLite (dev) → Neon Postgres (prod) — use only portable ORM, no SQLite-specific SQL |
| Media | Cloudinary (`cloudinary`, `django-cloudinary-storage`) — `ProductMedia.file` is `CloudinaryField` |
| Payments | Razorpay (opt-in via `VITE_RAZORPAY_ENABLED`), simulated `/api/payment/success/` otherwise |
| Frontend | React 18, Vite 5, react-router-dom v6, axios, react-hot-toast, react-icons/fi |
| Charts | **Add `recharts`** — `npm i recharts` (do this; do not pick another library) |
| Excel | **Add `openpyxl`** to `requirements.txt` for `.xlsx` export. CSV uses stdlib `csv`. |
| Email | Use `django.core.mail` with console backend in dev (`EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'` if `DEBUG`); SMTP env vars for prod |

Ports: backend `127.0.0.1:8000`, frontend `5173`. Admin routes mount under `/admin-dashboard/*` (full-screen layout — Navbar/Footer hidden by `App.jsx` already).

---

## Current state (DO NOT REBUILD)

### Frontend — existing admin pages at [frontend/src/pages/admin/](frontend/src/pages/admin/)

| File | Status | Notes |
|---|---|---|
| [AdminDashboard.jsx](frontend/src/pages/AdminDashboard.jsx) | ✅ Shell exists | Sidebar w/ NavLink, role-guarded by `RoleRoute`. **Extend `NAV_ITEMS`** — do not rewrite. |
| [AdminOverview.jsx](frontend/src/pages/admin/AdminOverview.jsx) | ✅ Basic KPIs | Has totals + recent orders + low-stock. **Extend** with revenue chart, sales-over-time, customer count. |
| [AdminProducts.jsx](frontend/src/pages/admin/AdminProducts.jsx) | ✅ CRUD modal | No variants, no SKU, no specs, no gallery upload, no feature toggles. **Extend** — do not duplicate. |
| [AdminOrders.jsx](frontend/src/pages/admin/AdminOrders.jsx) | ✅ List + status update | No invoice, no packing/shipping split, no return/refund. **Extend.** |
| [AdminDiscounts.jsx](frontend/src/pages/admin/AdminDiscounts.jsx) | ✅ CRUD | Verify it covers % + ₹ + expiry + usage caps; extend if not. |
| [AdminDealers.jsx](frontend/src/pages/admin/AdminDealers.jsx) | ✅ Approve/reject | Keep — wire from new Customers page for dealer-flagged users. |
| [AdminERP.jsx](frontend/src/pages/admin/AdminERP.jsx) | ✅ Sync status | Keep as-is. |
| [AdminSettings.jsx](frontend/src/pages/admin/AdminSettings.jsx) | ✅ Store settings | Extend with GST/tax/shipping/currency tabs. |

### Backend — existing models

- [users.User](backend/users/models.py) — has `role` (`user`/`dealer`/`admin`), `dealer_status`, `dealer_company_name`, `dealer_gst_number`. **No `is_blocked` field — add it.**
- [products.Category](backend/products/models.py) — flat. **No `parent` (nesting), no `banner_image`, no `is_active` — add them.**
- [products.Product](backend/products/models.py) — **no SKU, no variants, no specifications, no `status` (draft/published/archived) — add them.**
- [products.ProductMedia](backend/products/models.py) — Cloudinary-backed, OK as-is.
- [orders.Order](backend/orders/models.py) — has `order_status` (CREATED/CONFIRMED/SHIPPED/DELIVERED/CANCELLED) and `payment_status`. **No separate `packing_status`, no `shipping_status` (carrier/tracking), no `return_status`, no refund FK — add them as new fields/models.**
- discounts, store_settings, payments — apps exist; extend serializers/views, don't recreate.

### Existing API surface ([frontend/src/api/index.js](frontend/src/api/index.js))

JWT interceptor + auto-refresh is built. Add new endpoint helpers to this file — **do not create a second axios client.**

---

## What you are building (13 modules)

For each module: list the **deltas** (what's new), the backend models/endpoints, the frontend page, and the acceptance test.

### 1. Admin Authentication

**State:** Login/logout/JWT works. Role guard works. Forgot-password and audit log do not exist.

**Deltas:**
- **Backend:**
  - `POST /api/auth/forgot-password/` — accept email, generate single-use token (`django.contrib.auth.tokens.PasswordResetTokenGenerator`), email reset link `{FRONTEND_URL}/reset-password?uid=...&token=...`. Always return 200 (never leak whether email exists).
  - `POST /api/auth/reset-password/` — validate `uid`+`token`, accept `new_password`, enforce Django's `validate_password`.
  - New app `audit/` with `AuditLog(actor, action, target_type, target_id, payload_json, ip, user_agent, created_at)`. Add a DRF mixin `AuditedModelMixin` that logs `create/update/destroy` automatically. Apply to every admin-only viewset created below.
  - Session handling: shorten admin access token to 15 min (`SIMPLE_JWT['ACCESS_TOKEN_LIFETIME']` already configured — verify; do not change global if it breaks customer flow — instead enforce server-side `IsAdmin` re-check on every admin endpoint).
- **Frontend:**
  - `pages/ForgotPasswordPage.jsx`, `pages/ResetPasswordPage.jsx` (public routes — add to `App.jsx` outside `RoleRoute`).
  - "Forgot password?" link on [LoginPage.jsx](frontend/src/pages/LoginPage.jsx).

**Acceptance:** Reset email shows in `runserver` console; submitting new password lets admin log in with it; `AuditLog` row written for every admin mutation.

---

### 2. Dashboard Module

**State:** [AdminOverview.jsx](frontend/src/pages/admin/AdminOverview.jsx) renders 6 KPI cards + recent orders + low stock. No charts, no customer count, no time-series.

**Deltas:**
- **Backend:** new endpoint `GET /api/admin/dashboard/` returning a single payload (one round-trip):
  ```json
  {
    "totals": {"orders": 0, "revenue": "0.00", "customers": 0, "products": 0, "low_stock_count": 0},
    "revenue_timeseries": [{"date": "2026-05-01", "revenue": "1234.50", "orders": 12}, ...],   // last 30 days
    "sales_by_category": [{"category": "Sofas", "revenue": "..."}, ...],
    "recent_orders": [...],
    "low_stock": [...]
  }
  ```
  Use a single `select_related`/`annotate` query per series. Cache the response for 60s with `cache.get_or_set('admin:dashboard', ..., 60)`.
- **Frontend:** Replace the `Promise.allSettled` fan-out with one call to the new endpoint. Add two `recharts` charts: `LineChart` (revenue over 30 days) and `BarChart` (sales by category). Keep the KPI cards.

**Acceptance:** Dashboard loads in one HTTP request, charts render, second load within 60s is served from cache (verify via `time` header you add).

---

### 3. Product Management

**State:** Basic CRUD, no SKU, no variants, no specs, no gallery upload, no draft/archive status.

**Deltas — backend models** (add to [products/models.py](backend/products/models.py)):

```python
class Product(models.Model):
    # existing fields...
    sku = models.CharField(max_length=32, unique=True, db_index=True)        # auto-generated, see below
    status = models.CharField(max_length=10, choices=[('draft','Draft'),('active','Active'),('archived','Archived')], default='active', db_index=True)
    # remove or keep `is_featured` (already exists) — keep

class ProductVariant(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='variants')
    sku = models.CharField(max_length=32, unique=True, db_index=True)
    option_name = models.CharField(max_length=50)   # e.g. "Color", "Size"
    option_value = models.CharField(max_length=50)  # e.g. "Walnut", "Large"
    price_delta = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    stock = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

class ProductSpecification(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='specifications')
    label = models.CharField(max_length=100)        # e.g. "Weight"
    value = models.CharField(max_length=200)        # e.g. "12 kg"
    sort_order = models.PositiveIntegerField(default=0)
    class Meta: ordering = ['sort_order', 'id']
```

**SKU generation:** signal on `pre_save` — if blank, set to `f"{category.slug[:3].upper()}-{secrets.token_hex(3).upper()}"`; on collision, regenerate (max 5 tries). Same scheme for variants prefixed with parent SKU.

**Deltas — backend endpoints** (extend `products/urls.py`):
- `POST /api/products/admin/{id}/media/` — multipart upload, accepts up to 10 files, creates `ProductMedia` rows with Cloudinary upload. Return the created media list. Set first uploaded as `is_primary=True` if product has none.
- `PATCH /api/products/admin/{id}/media/{media_id}/` — set `is_primary`, `order`, `alt_text`.
- `DELETE /api/products/media/{id}/` — already exists; verify it deletes from Cloudinary too (call `cloudinary.uploader.destroy(public_id)`).
- `POST /api/products/admin/{id}/variants/` + standard variant CRUD.
- `POST /api/products/admin/{id}/specifications/` + `PATCH`/`DELETE`.

**Deltas — frontend:** extend [AdminProducts.jsx](frontend/src/pages/admin/AdminProducts.jsx):
- Tabs in the modal: **Details · Media · Variants · Specifications · SEO**.
- Media tab: drag-to-reorder gallery (`react-beautiful-dnd` is heavy — use HTML5 drag events), set primary, alt text.
- Variants tab: inline-editable table, "+ Add variant" row.
- Specifications tab: same pattern.
- List view: status pill (Draft/Active/Archived) + bulk actions (Publish, Archive, Delete) via a toolbar shown when ≥1 row selected.
- Search debounced 300ms, filters: category, status, material, price range, in-stock.

**Acceptance:** Create a draft product with 3 variants, 5 specs, 4 images uploaded → publish it → it appears on `/` storefront.

---

### 4. Category Management

**State:** Flat `Category` model. No banner, no nesting, no admin page.

**Deltas:**
- **Backend:**
  - Add to [Category](backend/products/models.py): `parent = models.ForeignKey('self', null=True, blank=True, on_delete=models.PROTECT, related_name='children')`, `banner_image = CloudinaryField(...)`, `is_active = BooleanField(default=True)`, `sort_order = PositiveIntegerField(default=0)`.
  - Migration must guard against cycles — add `Category.clean()` that walks parents and raises `ValidationError` on cycle, called from `full_clean()`.
  - `GET/POST /api/categories/admin/`, `GET/PATCH/DELETE /api/categories/admin/{id}/`. `DELETE` must be soft (set `is_active=False`) if any products attached; hard-delete only when no FKs.
  - `GET /api/categories/tree/` — returns nested tree (recursive serializer with `depth=3` cap).
- **Frontend:** new `pages/admin/AdminCategories.jsx`. Tree view (collapsible). Click row → side panel with name/slug/parent picker/banner upload/active toggle. Drag to reorder (within same parent only).

**Acceptance:** Create `Living Room` → `Sofas` (child) with banner. Storefront filter for `sofas` still resolves (slug uniqueness preserved).

---

### 5. Inventory Management

**State:** `Product.stock` integer only. No history, no warehouse split, no notifications.

**Deltas:**
- **Backend (new app `inventory/`):**
  ```python
  class Warehouse(models.Model):
      name = models.CharField(max_length=100, unique=True)
      code = models.CharField(max_length=10, unique=True)
      address = models.TextField(blank=True)
      is_active = models.BooleanField(default=True)

  class StockLevel(models.Model):
      product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='stock_levels')
      variant = models.ForeignKey(ProductVariant, null=True, blank=True, on_delete=models.CASCADE)
      warehouse = models.ForeignKey(Warehouse, on_delete=models.PROTECT)
      quantity = models.IntegerField(default=0)        # signed; negatives blocked at validator
      low_threshold = models.PositiveIntegerField(default=5)
      class Meta:
          unique_together = [('product','variant','warehouse')]

  class StockMovement(models.Model):
      stock_level = models.ForeignKey(StockLevel, on_delete=models.PROTECT, related_name='movements')
      delta = models.IntegerField()                    # +inbound, -outbound, signed adjustment
      reason = models.CharField(max_length=20, choices=[('inbound','Inbound'),('order','Order'),('return','Return'),('adjustment','Adjustment')])
      reference = models.CharField(max_length=64, blank=True)   # e.g. order_id
      note = models.TextField(blank=True)
      actor = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL)
      created_at = models.DateTimeField(auto_now_add=True)
  ```
  - On `StockMovement.save()`: in a transaction, update `stock_level.quantity` atomically with `F('quantity') + self.delta` and refuse the save if resulting quantity would be negative (`select_for_update` on the row).
  - Order-fulfillment hook: when `Order.order_status` transitions to `CONFIRMED`, create a `StockMovement(reason='order', delta=-qty)` per order item. When transitioning to a return, create `reason='return', delta=+qty`.
  - Endpoints: `GET /api/inventory/levels/`, `GET /api/inventory/levels/{id}/movements/`, `POST /api/inventory/adjust/` (body: `{stock_level, delta, note}`), `GET /api/inventory/low-stock/`.
  - Low-stock email: signal `post_save` on `StockMovement` — if resulting `quantity <= low_threshold`, queue email to admins (use `mail_admins` for now; abstract via `services/notifications.py` so SMS can plug in later).

- **Frontend:** new `pages/admin/AdminInventory.jsx`. Tabs: Stock Levels · Movements · Warehouses. Quick adjust modal (delta + reason + note). Low-stock filter chip.

**Acceptance:** Adjust stock → row updates, movement logged, ledger reconstructable by summing deltas. Confirm an order → stock decrements automatically.

---

### 6. Order Management

**State:** [AdminOrders.jsx](frontend/src/pages/admin/AdminOrders.jsx) shows list + status update. No invoice, no packing/shipping split, no returns/refunds.

**Deltas:**
- **Backend:**
  - Add fields to [Order](backend/orders/models.py):
    - `packing_status` — `pending|packed`
    - `shipping_status` — `not_shipped|shipped|in_transit|delivered`
    - `tracking_carrier` (CharField), `tracking_number` (CharField), `shipped_at` (DateTime), `delivered_at` (DateTime)
    - `cancellation_reason` (TextField, blank)
  - New model `OrderReturn(order, requested_by, reason, status[requested|approved|rejected|received|refunded], refund_amount, created_at, updated_at)` — keep one-to-many so partial returns are possible later, but enforce one open return per order at the serializer.
  - New model `Refund(order, return_request, amount, gateway[razorpay|manual], gateway_refund_id, status[pending|success|failed], created_at)`.
  - Endpoints:
    - `PATCH /api/orders/{id}/packing/`, `PATCH /api/orders/{id}/shipping/` (sets carrier+tracking, transitions states with strict guards — cannot ship before pack, etc.)
    - `POST /api/orders/{id}/cancel/` (admin or owner if status=CREATED) — refund stock, fire refund if PAID.
    - `POST /api/orders/{id}/returns/`, `PATCH /api/orders/returns/{id}/` (admin transitions).
    - `POST /api/orders/{id}/refund/` — calls Razorpay refund API if `payment_status='SUCCESS'` and gateway txn exists; otherwise creates a `manual` refund row with `status=success`.
    - `GET /api/orders/{id}/invoice/` — returns PDF (use `reportlab` — add to requirements). Filename `INV-{order_id}.pdf`. Include line items, GST split, shipping, totals, store address (from `StoreSettings`).
- **Frontend:** extend AdminOrders into a master/detail layout: list on left, selected order detail on right with tabs **Items · Customer · Shipping · Returns · Timeline**. Buttons per state transition (disabled when not allowed). "Download Invoice" button on the detail view.

**Acceptance:** Confirm → Pack → Ship (with tracking) → Deliver flow works. A returned, refunded order shows refund row + restocked inventory.

---

### 7. Customer Management

**State:** No admin Customers page; only Dealers page exists.

**Deltas:**
- **Backend:**
  - Add `is_blocked = models.BooleanField(default=False)` to [User](backend/users/models.py). Login view rejects blocked users with 403 + clear error code (`user_blocked`).
  - `GET /api/admin/customers/?search=&role=&is_blocked=&ordering=-created_at` — paginated, filterable.
  - `GET /api/admin/customers/{id}/` — returns user + aggregates: `lifetime_value`, `order_count`, `last_order_at`, last 10 orders.
  - `PATCH /api/admin/customers/{id}/` — admin can flip `is_blocked`, edit phone/name. Cannot edit role here (role changes go through dealer-approval flow).
- **Frontend:** new `pages/admin/AdminCustomers.jsx`. Table with search, role filter, blocked filter. Click row → drawer with profile + order history + Block/Unblock button (with confirm dialog).

**Acceptance:** Block a user → their next login returns the blocked error → admin sees order history aggregates correctly.

---

### 8. Coupon & Discount Management

**State:** [AdminDiscounts.jsx](frontend/src/pages/admin/AdminDiscounts.jsx) and `discounts/` app exist. Verify and extend if missing fields.

**Deltas (verify-or-add):**
- Required model fields on `Discount`:
  - `code` (unique, uppercased on save)
  - `kind` — `percent|fixed`
  - `value` (DecimalField — % or ₹ depending on kind)
  - `min_subtotal` (DecimalField, default 0)
  - `max_discount` (DecimalField, nullable — caps % discounts)
  - `valid_from`, `valid_until` (DateTime)
  - `usage_limit` (PositiveInt nullable — null = unlimited), `per_user_limit` (PositiveInt nullable)
  - `times_used` (PositiveInt, default 0)
  - `is_active` (Boolean)
  - `applicable_categories` (M2M Category, blank — empty = all)
- Endpoint `POST /api/discounts/validate/` — body `{code, subtotal, user_id, category_ids[]}` → returns `{valid, discount_amount, message}`. Cart/checkout will use this.
- On order create, atomically increment `times_used` with `F('times_used')+1` and write to `DiscountUsage(discount, user, order, used_at)`.

**Frontend:** extend AdminDiscounts list with Active/Expired/Scheduled status pill (computed from dates). Add a "Test Coupon" inline tool that hits `/discounts/validate/` with mock subtotal.

**Acceptance:** Create a 10% coupon, cap ₹500, expires tomorrow, limit 100 uses, 1 per user → enforced at checkout.

---

### 9. CMS Management

**State:** Doesn't exist.

**Deltas:**
- **Backend (new app `cms/`):**
  ```python
  class Banner(models.Model):
      title = models.CharField(max_length=200)
      image = CloudinaryField('banner')
      link_url = models.URLField(blank=True)
      placement = models.CharField(max_length=20, choices=[('home_hero','Home Hero'),('home_strip','Home Strip'),('category_top','Category Top')])
      is_active = models.BooleanField(default=True)
      sort_order = models.PositiveIntegerField(default=0)
      starts_at = models.DateTimeField(null=True, blank=True)
      ends_at = models.DateTimeField(null=True, blank=True)

  class Page(models.Model):
      slug = models.SlugField(unique=True)               # e.g. 'about', 'terms', 'privacy', 'shipping'
      title = models.CharField(max_length=200)
      body_md = models.TextField()                        # markdown
      is_published = models.BooleanField(default=True)
      updated_at = models.DateTimeField(auto_now=True)

  class FAQ(models.Model):
      question = models.CharField(max_length=300)
      answer = models.TextField()
      category = models.CharField(max_length=50, blank=True)
      sort_order = models.PositiveIntegerField(default=0)
      is_active = models.BooleanField(default=True)
  ```
  - Public read endpoints: `GET /api/cms/banners/?placement=home_hero` (filtered by `is_active` AND date window), `GET /api/cms/pages/{slug}/`, `GET /api/cms/faqs/`.
  - Admin CRUD endpoints under `/api/cms/admin/...`.

- **Frontend:** new `pages/admin/AdminCMS.jsx` with tabs **Banners · Pages · FAQs**.
  - Banners: visual grid, drag-reorder, scheduling pickers.
  - Pages: list of slugs, click to edit. Body is markdown — use `<textarea>` + a simple preview pane (no fancy WYSIWYG; ship `react-markdown` for preview). T&C / Privacy / Shipping are seeded as Page rows.
  - FAQs: inline-editable list grouped by `category`.

**Acceptance:** Create a home_hero banner with start/end → it shows on `/` only within window. Edit the Privacy page → updates render at `/pages/privacy` (storefront route, separate from admin).

---

### 10. Media Management

**State:** Cloudinary works for product media; no central library.

**Deltas:**
- **Backend:** new app `media/` with `MediaAsset(public_id unique, secure_url, kind, bytes, width, height, folder, tags, uploaded_by FK, created_at)`. On any Cloudinary upload (product, banner, category), also write a `MediaAsset` row.
- Endpoints: `GET /api/admin/media/?folder=&kind=&search=` (paginated, default 50), `DELETE /api/admin/media/{id}/` — hard-delete from Cloudinary AND row. Reject delete if asset is referenced (FK guard via reverse lookups).
- **Frontend:** new `pages/admin/AdminMedia.jsx`. Grid of thumbnails with folder filter, kind filter, search. Click thumb → side panel with metadata, copy URL, delete button (with referenced-by warning).

**Acceptance:** Upload an image via Products page → it appears in Media library. Try to delete one in use → blocked with the list of referencing entities.

---

### 11. Reports & Analytics

**State:** Doesn't exist.

**Deltas:**
- **Backend:** new endpoints under `/api/admin/reports/`:
  - `GET /sales/?from=&to=&group_by=day|week|month` → revenue & order count series.
  - `GET /inventory/?warehouse=` → current stock + 30-day movement deltas.
  - `GET /customers/?from=&to=` → new vs returning, lifetime-value buckets.
  - `GET /revenue/?from=&to=&breakdown=category|payment_status`.
  - All four also accept `?export=csv` or `?export=xlsx` → return `Content-Disposition: attachment` with the file. CSV via stdlib `csv.writer`; xlsx via `openpyxl`.
- **Frontend:** new `pages/admin/AdminReports.jsx` with sub-tabs per report. Date range picker (default last 30 days), `recharts` charts, "Export CSV" / "Export Excel" buttons.

**Acceptance:** Each report renders, exports download correctly, dates clamp `to >= from`.

---

### 12. Notification System

**State:** Doesn't exist.

**Deltas:**
- **Backend:** new app `notifications/`:
  ```python
  class Notification(models.Model):
      user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
      kind = models.CharField(max_length=30)           # 'order.created','order.shipped','low_stock','dealer.approved', etc.
      title = models.CharField(max_length=200)
      body = models.TextField(blank=True)
      payload_json = models.JSONField(default=dict)
      is_read = models.BooleanField(default=False, db_index=True)
      created_at = models.DateTimeField(auto_now_add=True)
  ```
- A central `services/notifications.py` with `send(user, kind, title, body, payload, channels=['inapp','email'])`. Channels are pluggable — start with `inapp` (writes Notification row) and `email` (`django.core.mail.send_mail`). Stub a `sms` channel that logs and no-ops (for later Twilio integration).
- Wire signals: order created → notify customer + all admins; order shipped → notify customer; low stock → notify admins; dealer approved/rejected → notify dealer; refund issued → notify customer.
- Endpoints: `GET /api/notifications/`, `POST /api/notifications/{id}/read/`, `POST /api/notifications/read-all/`.
- **Frontend:** Bell icon in `admin-topbar` with unread count (poll every 60s — no websockets in this prompt). Dropdown lists last 10. Click a row → marks read + navigates to `payload.link` if present.

**Acceptance:** Place an order → admin sees in-app notification + console-email; mark as read → unread count decrements.

---

### 13. Settings Module

**State:** [AdminSettings.jsx](frontend/src/pages/admin/AdminSettings.jsx) and `store_settings/` app exist. Probably has store name/contact only.

**Deltas:**
- **Backend:** ensure `StoreSettings` (singleton row, enforced via `save()` override) covers:
  - **Store:** `name`, `legal_name`, `address`, `email`, `phone`, `gstin`
  - **Tax:** `default_gst_percent`, `tax_inclusive` (Boolean — whether listed prices include GST)
  - **Shipping:** `flat_shipping_amount`, `free_shipping_threshold`, `cod_enabled`
  - **Currency:** `currency_code` ('INR'), `currency_symbol` ('₹'), `decimal_places` (2)
- Endpoint: `GET/PATCH /api/settings/` — cached 5 min, invalidated on save.
- **Frontend:** restructure AdminSettings into tabs **Store · Tax · Shipping · Currency**. Each tab a separate form; PATCH only the changed section. Refresh `SettingsContext` after save so storefront pricing updates without reload.

**Acceptance:** Change `default_gst_percent` from 18 → 12 → checkout total recomputes on next page load.

---

## Production guarantees — ship-ready TODAY (P0)

The storefront integration with these admin actions will be wired in a later
prompt. **But the admin-side flows below must be production-grade right now**,
because the seed data + dev-login are the only thing the rest of the work
depends on. Treat the rest of the 13 modules as a build queue; treat these two
as a hard gate.

### P0-A: "Add Product" must work end-to-end with no shortcuts

- Endpoint already exists: `POST /api/products/admin/` ([backend/products/views.py:56](backend/products/views.py#L56)) gated by `IsAdminRole`.
- Frontend modal: [AdminProducts.jsx](frontend/src/pages/admin/AdminProducts.jsx) — already calls `adminCreateProduct`. **Hardened** to: trim strings, parse-and-validate `price` / `stock` client-side, surface `non_field_errors` and the first field error in the toast, and distinguish 401/403/network failures from validation failures.
- Backend serializer rejects `price <= 0`, `stock < 0`, malformed URL — verified.
- **Verification command** (admin token from `/api/auth/dev-login/`):
  ```
  POST /api/products/admin/ → 201 (happy)
  POST /api/products/admin/ with price=-5 → 400 {"price":["Price must be greater than 0."]}
  ```
- When you extend this flow with variants/specs/media tabs (module 3 above), **do not break the simple "Name + Price + Category + Stock + Image URL" path.** A new product must be createable with the minimum-viable set of fields without populating optional sections.

### P0-B: "Change Order Status" must work end-to-end with no shortcuts

- **Bug fixed:** the table+drawer used to pass `order.order_id` (the human "ORD-XXXX" string) to a URL pattern that requires the integer PK (`<int:pk>/status/`). Every status change was returning 404. The frontend now passes `order.id` for all mutations. **Do not regress this.** When you build returns/refunds/packing/shipping endpoints, key all of them on `order.id`.
- **State machine enforced server-side** in `OrderStatusUpdateSerializer.ALLOWED_TRANSITIONS` ([backend/orders/serializers.py](backend/orders/serializers.py)):
  ```
  CREATED   → CONFIRMED, CANCELLED
  CONFIRMED → SHIPPED, CANCELLED
  SHIPPED   → DELIVERED
  DELIVERED → (terminal)
  CANCELLED → (terminal)
  ```
  Mirrored on the frontend in `AdminOrders.jsx` (`TRANSITIONS` const). The UI hides invalid options; the backend rejects them with a 400 even if the UI is bypassed. **Both copies must stay in sync.** If you extend the graph (e.g. add `RETURNED` for module 6), update both files in the same PR.
- **Idempotence:** posting the current status (`CONFIRMED → CONFIRMED`) is a no-op (`if newStatus === order.order_status) return;` on the frontend; the serializer skips the transition check when `value == current`).
- **Terminal-state guard:** the frontend prompts `window.confirm` before moving to `DELIVERED` or `CANCELLED`. When you replace `confirm()` with a proper `<ConfirmDialog />` component (per Frontend Conventions), preserve this guard.
- **Verification commands** (admin token from `/api/auth/dev-login/`):
  ```
  PATCH /api/orders/1/status/ {"order_status":"DELIVERED"}
    when current=CONFIRMED → 400 {"order_status":["Cannot transition from CONFIRMED to DELIVERED. Allowed next states: ['CANCELLED', 'SHIPPED']"]}
  PATCH /api/orders/1/status/ {"order_status":"SHIPPED"}
    when current=CONFIRMED → 200, full order payload with order_status="SHIPPED"
  ```

### What "production-ready" means for these two flows specifically

1. **No silent failures.** Every error path either toasts a specific message or sets a per-field error. No bare `catch {}`.
2. **No simulated success.** A toast that says "Saved" must reflect a 2xx response. Optimistic UI is allowed only when the server-confirmed payload replaces the local row immediately after (already done in `setOrders((prev) => prev.map(...))`).
3. **Authentication errors are distinguishable.** A 401/403 toasts "Not authorized. Re-login as admin." rather than getting swallowed as a validation error.
4. **No stale UI.** After a mutation, the row in the list and the drawer both update. Don't re-fetch the entire list when you can patch one row in place (already done for status update).
5. **No magic strings duplicated across files.** The status enum and the transition graph are the single source of truth in the serializer; the frontend mirror exists for UX only and is kept in sync.

These two flows are the **demo path** when the storefront wiring lands. If they regress at any point during the 13-module build, stop and fix them before continuing.

---

## Cross-cutting requirements (every endpoint, no exceptions)

1. **Permissions:** every admin endpoint uses a project-level `IsAdminUser` permission class that checks `request.user.role == 'admin' OR is_superuser`. Define once in `core/permissions.py`. Don't sprinkle `if request.user.role`.
2. **Pagination:** DRF `PageNumberPagination` with `page_size=25`, `max_page_size=200`. Already configured globally — verify, don't redefine per-view.
3. **Filtering:** every list endpoint uses `django_filters.FilterSet` with explicit allowed fields. No `__exact` injection from query params.
4. **Validation:** DRF serializer `validate_*` methods, never raw `if` blocks in views. Reject unknown fields (`extra_kwargs={'<unused>': {'read_only': True}}` or strict serializer). Decimal fields validated for non-negative where applicable.
5. **Transactions:** any endpoint that mutates more than one row wraps the work in `transaction.atomic()`. Stock adjustments use `select_for_update()`.
6. **Audit:** every admin POST/PATCH/PUT/DELETE writes an `AuditLog` row with the actor, action, target, and a redacted payload (strip passwords, tokens).
7. **Errors:** consistent shape `{ "error": { "code": "snake_case", "message": "...", "details": {...} } }`. Add a custom DRF `EXCEPTION_HANDLER` in `core/exceptions.py`.
8. **N+1:** admin list endpoints use `select_related`/`prefetch_related`. Add a `django-debug-toolbar` check during dev, but **don't ship it in `INSTALLED_APPS` for prod** — gate on `DEBUG`.
9. **Tests:** for each new endpoint, add a happy-path + permission-denied test in `<app>/tests/test_admin.py`. Use DRF `APITestCase`. Aim for >80% coverage on admin views.
10. **No frontend pricing math.** The frontend reads `effective_price`, GST split, and discount info from the API. If something is missing, add it to the API rather than computing client-side.

---

## Frontend conventions (every new admin page)

- File location: `frontend/src/pages/admin/Admin<Module>.jsx`. Reuse [AdminPanel.css](frontend/src/pages/admin/AdminPanel.css) classes (`admin-page`, `admin-card`, `admin-table`, `admin-stats-grid`, `status-badge`).
- Add a route in [AdminDashboard.jsx](frontend/src/pages/AdminDashboard.jsx) `<Routes>` block AND an entry in the `NAV_ITEMS` array. Don't introduce a second router.
- API calls go through new helpers added to [frontend/src/api/index.js](frontend/src/api/index.js). Don't `axios.get` directly from a component.
- Loading state: skeleton or `"Loading…"` in `.admin-empty`. Error state: `toast.error(...)` from `react-hot-toast`.
- Forms: controlled inputs, validation errors mapped from API `error.details` into a per-field `errors` object.
- Confirmations for destructive actions: a small `<ConfirmDialog />` component (build once in `components/ConfirmDialog.jsx`, reuse everywhere).
- Tables: server-side pagination (`?page=`, `?page_size=`), search debounced 300ms, columns sortable via `?ordering=`.
- Accessibility: every button has `aria-label` if icon-only, every input has a `<label>`.

---

## Migration & DB plan (you do NOT run the DB connection — just produce clean migrations)

1. After all model edits: `python manage.py makemigrations` must produce **one migration per app**, named descriptively (e.g. `products/0003_variants_and_specs.py`).
2. Migrations must be reversible. No `RunPython` without a reverse function.
3. Any field added to an existing populated table must have a default OR `null=True`. For `is_blocked` use `default=False`. For `Order.shipped_at` use `null=True`.
4. Provide a `python manage.py seed_admin` management command in `users/management/commands/seed_admin.py` that creates: 1 admin, 2 customers, 1 dealer (active), 1 dealer (pending), 3 categories (1 with a child), 6 products with 2 variants each, 1 active discount, 1 home_hero banner, 3 FAQs, 1 warehouse with stock for all products. Idempotent (skip if data exists).

When the DB is wired up later, the run order is: `migrate` → `seed_admin` → `runserver`. Your code must produce a working admin panel after exactly that sequence with no manual fixes.

---

## Deliverables checklist

- [ ] All 13 module deltas implemented (backend + frontend)
- [ ] `requirements.txt` updated (`reportlab`, `openpyxl`)
- [ ] `package.json` updated (`recharts`, `react-markdown`)
- [ ] All new models in migrations, all migrations apply cleanly
- [ ] `seed_admin` management command works
- [ ] `core/permissions.py`, `core/exceptions.py`, `services/notifications.py`, `audit/` app
- [ ] Tests for every new admin endpoint (happy + 403)
- [ ] Sidebar updated with new modules: Customers, Inventory, Categories, CMS, Media, Reports
- [ ] No `console.log`, no commented-out code, no dead imports, no TODOs

---

## Token / output discipline (for the executing agent)

- Use `Edit` for files <50 LOC of changes; `Write` for new files only.
- Don't restate this prompt. Don't summarize what you built. Don't enumerate every file at the end.
- One sentence at the end: **"Admin panel implementation complete. Run `python manage.py makemigrations && python manage.py migrate && python manage.py seed_admin`, then `npm i` in frontend and `npm run dev`."**
- If you hit an ambiguity, make the FAANG-default choice (security > convenience, correctness > cleverness, server-driven > client-driven) and proceed silently.

---

## Out of scope (don't build)

- Multi-tenant / multi-store
- Real SMS sending (stub the channel only)
- Websockets / live notifications (poll every 60s instead)
- A full Markdown WYSIWYG (textarea + preview is enough)
- Drag-and-drop libraries beyond native HTML5 events
- New design system / Tailwind (extend [AdminPanel.css](frontend/src/pages/admin/AdminPanel.css))

End of prompt.
