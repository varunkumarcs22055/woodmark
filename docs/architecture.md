# FurniShop — Full Platform Architecture

This document is the source-of-truth for what the platform should contain at production scale, what already exists, and what's still missing. Everything below maps to the user's 20-area spec.

Status legend used throughout:

- ✅ **Built** — model + API + frontend all working in main
- 🟡 **Partial** — some layer exists; gaps called out per row
- ❌ **Missing** — needs to be built

---

## 1. Authentication & Authorization

| Feature | Status | Notes |
|---|---|---|
| Email/password register, login, logout | ✅ | `users.LoginView`, JWT (SimpleJWT) |
| JWT access + refresh, auto-refresh on 401 | ✅ | `frontend/src/api/index.js` interceptor |
| Role-based access (`user` / `dealer` / `admin`) | ✅ | `users.permissions.IsAdminRole`, `IsDealer`, `IsAdminOrDealer` |
| Dealer apply + admin approve / reject | ✅ | `users.DealerApprovalView` |
| Block customer (`is_blocked` → 403 on login) | ✅ | `users.LoginView` checks; `/admin/customers/{id}/` toggles |
| Dev quick-login (admin / dealer / user) | ✅ | `/api/auth/dev-login/` (DEBUG only) |
| Forgot password (token email) | ❌ | Needs `PasswordResetTokenGenerator` + email backend |
| Reset password page | ❌ | New public route + form |
| Google OAuth | 🟡 | `social-auth-app-django` wired, needs `GOOGLE_CLIENT_ID` |
| Audit log on every admin mutation | ✅ | `audit.AuditLog` + `AuditedMixin` |

**API surface:** `POST /api/auth/{register,login,logout,token/refresh,dev-login}/`, `GET/PATCH /api/auth/profile/`, `POST /api/auth/dealer-apply/`, `PATCH /api/auth/dealers/{id}/approve/`.

---

## 2. Product Catalog (Amazon-style)

| Feature | Status | Notes |
|---|---|---|
| Product CRUD | ✅ | `ProductAdminViewSet` |
| Auto-SKU generation | ✅ | `Product._generate_sku()` |
| Status (`draft` / `active` / `archived`) | ✅ | Index on `status` |
| Variants (color / size / option) | ✅ | `ProductVariant` model w/ unique `(product, option_name, option_value)` |
| Specifications (label-value table) | ✅ | `ProductSpecification` |
| Cloudinary media gallery | ✅ | `ProductMedia` w/ `is_primary` + `order` |
| **Brand** | ❌ | Add `brand` CharField on Product |
| **HSN code** (GST classification) | ❌ | Add `hsn_code` CharField on Product |
| **Meta title / description / OG image** (SEO) | ❌ | Add `meta_title`, `meta_description`, `og_image_url` |
| **Bullet points / highlights** | ❌ | Add `highlights` JSONField (list of strings) |
| **Average rating + review count** (denorm) | ❌ | Add `rating_avg`, `rating_count`; updated by Review signal |
| **Delivery estimate days** (default) | ❌ | Add `delivery_estimate_days` — fallback when pincode rules don't match |
| Featured / homepage flag | ✅ | `is_featured` boolean |
| Search (name, description, color) | ✅ | DRF `SearchFilter` |
| Filters (category, material, price range, status) | ✅ | `ProductFilter` (django_filter) |
| Similar products | ✅ | `SimilarProductsView` |
| Limited-time offers feed | ✅ | `LimitedOffersView` (sorts by soonest `ends_at`) |

---

## 3. Categories

| Feature | Status | Notes |
|---|---|---|
| CRUD | ✅ | `CategoryAdminListView` / `CategoryAdminDetailView` |
| Parent / child nesting (depth ≤ 3) | ✅ | Cycle guard in `Category.clean()` |
| Banner image (Cloudinary) | ✅ | `Category.banner_image` |
| Active / inactive flag | ✅ | Soft-delete when products attached |
| Tree endpoint | ✅ | `/api/categories/tree/` |

---

## 4. Cart

| Feature | Status | Notes |
|---|---|---|
| LocalStorage cart (slim items) | ✅ | `CartContext.jsx` |
| Server-side session cart (legacy) | ✅ | `cart` app |
| Tier-aware pricing per cart line | ✅ | `get_effective_price(product, role, quantity)` |

---

## 5. Order Management

| Feature | Status | Notes |
|---|---|---|
| Place order (guest + logged in) | ✅ | `OrderCreateView` |
| Stock decrement at order time | ✅ | `OrderCreateSerializer.create()` uses `F('stock')-qty` |
| Order status state machine (CREATED → CONFIRMED → SHIPPED → DELIVERED / CANCELLED) | ✅ | `OrderStatusUpdateSerializer.ALLOWED_TRANSITIONS` |
| Packing status (`pending` / `packed`) | ✅ | Field exists; admin endpoint needs wiring |
| Shipping status + carrier + tracking | ✅ | Fields exist; admin endpoint needs wiring |
| Cancel order + reason | 🟡 | Field exists; cancel endpoint needs wiring |
| **Auto-create invoice on confirm/payment** | ❌ | Signal that creates `Invoice` + `InvoiceItem` rows |
| ERP sync (legacy hook) | ✅ | `services/erp.py` |

---

## 6. Invoice System (NEW — to build)

| Feature | Status | Notes |
|---|---|---|
| `Invoice` table (number, dates, totals, footer) | ❌ | See `database-schema.md` |
| `InvoiceItem` table (product, qty, unit, tax, total) | ❌ | See schema |
| Numbering: `INV-YYYY-#####` (year-prefixed, zero-padded) | ❌ | `InvoiceCounter` table or year-prefixed atomic seq |
| Auto-create on order confirmation OR payment success | ❌ | Django signal |
| **GST invoice** with CGST/SGST split | ❌ | If buyer state = store state → CGST + SGST; else IGST |
| HSN per line | ❌ | Pull from `Product.hsn_code` at invoice-create time |
| PDF generation | ❌ | `reportlab` (already in requirements) — `services/invoice_pdf.py` |
| **Download PDF** endpoint | ❌ | `GET /api/invoices/{id}/pdf/` returns `application/pdf` |
| **Email invoice to customer** | ❌ | Async (queued) — for now sync `send_mail` |
| **Print** | ❌ | Same PDF, opened in new tab via `<a target=_blank>` — no extra backend needed |
| Admin list & search | ❌ | New page `/admin-dashboard/invoices` |

**Endpoints:**
- `GET /api/invoices/?search=&status=` (admin)
- `GET /api/invoices/{id}/` (admin or order owner)
- `GET /api/invoices/{id}/pdf/` (PDF stream)
- `POST /api/invoices/{id}/email/` (re-send)
- `POST /api/invoices/regenerate/{order_id}/` (admin recovery)

---

## 7. Shipping System

| Feature | Status | Notes |
|---|---|---|
| Flat shipping fee + free-shipping threshold | ✅ | `StoreSettings.standard_shipping_fee`, `free_shipping_threshold` |
| **Pincode coverage check** | ❌ | `ShippingZone(pincode_pattern, courier, sla_days, charge)` |
| **Delivery estimate** on product / cart | ❌ | Function `estimate_delivery(pincode, product) -> {min_days, max_days, courier}` |
| Shipment tracking (carrier + tracking number) | 🟡 | Fields on Order; needs courier-API integration |
| Shipping label PDF | ❌ | `services/shipping_label.py` (reportlab) |
| Courier assignment (manual or rule-based) | ❌ | `Order.shipping_zone` FK populated from pincode |

**New model:** `ShippingZone(name, pincode_prefix, courier_name, base_charge, per_kg_charge, sla_min_days, sla_max_days, cod_supported, is_active)`.

---

## 8. Payment System

| Feature | Status | Notes |
|---|---|---|
| Razorpay create-order + verify | ✅ | `payments` app |
| Simulated success (`/api/payment/success/`) for dev | ✅ | When `VITE_RAZORPAY_ENABLED` is unset |
| **COD** | 🟡 | `StoreSettings.cod_enabled` field exists; checkout flow needs branching |
| **Webhook** verification (signed payloads) | 🟡 | Stub exists; needs production signature check |
| Failed-payment handling (retry CTA, expire after N min) | ❌ | New endpoint + UI |
| **Refunds** via Razorpay | 🟡 | `Refund` model exists; gateway call not wired |

---

## 9. Tax / GST System

| Feature | Status | Notes |
|---|---|---|
| Flat `gst_percent` per order (current) | ✅ | `Order.gst_percent`, `Order.gst_amount` |
| **CGST / SGST split** (intra-state) | ❌ | Add `cgst_amount`, `sgst_amount`, `igst_amount` on Order + Invoice |
| **HSN code** per product line | ❌ | New field on Product, copied to InvoiceItem |
| **Tax-inclusive listings toggle** | ✅ | `StoreSettings.tax_inclusive` |
| **Tax reports** (HSN-wise, GSTR-1 export) | ❌ | New report under `/admin-dashboard/reports` |

**Algorithm:**
1. Determine buyer state from billing-address pincode (or address text).
2. If buyer state = store state → `cgst = sgst = total_gst / 2`, `igst = 0`.
3. Else → `igst = total_gst`, `cgst = sgst = 0`.

---

## 10. Notifications

| Feature | Status | Notes |
|---|---|---|
| In-app notification list | ✅ | `notifications.Notification` |
| Email channel (console backend in DEBUG) | ✅ | `services/notifications.notify(...)` |
| **SMTP / Resend in prod** | ❌ | Swap `EMAIL_BACKEND` based on env; add `resend` Python SDK if user wants |
| Order confirmation email | ❌ | Signal on `Order.post_save` (status=CREATED) |
| Invoice email | ❌ | Triggered on `Invoice.post_save` |
| Shipping update email | ❌ | Signal on shipping-status transition |
| Refund update email | ❌ | Signal on `Refund.post_save` |
| **SMS OTP** for login / phone-verify | ❌ | Stub channel exists; integrate Twilio or MSG91 |
| Order updates SMS | ❌ | Same SMS pipeline |

---

## 11. Reviews & Ratings (NEW)

| Feature | Status | Notes |
|---|---|---|
| `Review` table (user, product, rating, title, body, verified_purchase, status) | ❌ | See schema |
| Star rating widget | ❌ | Frontend |
| Verified-purchase badge | ❌ | True if `OrderItem` exists for this user+product |
| Moderation (`pending` / `approved` / `rejected`) | ❌ | Admin moderation page |
| Display on product detail | ❌ | Reviews list + write form |
| Aggregate `rating_avg`, `rating_count` on Product | ❌ | Denorm via signal on Review save |

---

## 12. Wishlist (NEW)

| Feature | Status | Notes |
|---|---|---|
| `Wishlist` table (user, product, added_at) | ❌ | Composite unique `(user, product)` |
| Add / remove API | ❌ | `POST/DELETE /api/wishlist/{product_id}/` |
| Move-to-cart action | ❌ | Frontend convenience: add to cart + remove from wishlist |
| Wishlist sync across devices | ✅ | Free once it's user-FK in DB |

---

## 13. Returns & Refunds

| Feature | Status | Notes |
|---|---|---|
| `OrderReturn` model | ✅ | Exists |
| `Refund` model | ✅ | Exists |
| Customer return-request form | ❌ | Frontend |
| Admin moderate (approve / reject / mark received) | ❌ | Admin page extension |
| **Exchange handling** | ❌ | New flow: replace SKU instead of refund |
| Restock on return-received | ❌ | Wire into inventory `StockMovement(reason='return')` |

---

## 14. Analytics & Reports

| Feature | Status | Notes |
|---|---|---|
| Admin dashboard (totals + 30-day series + recent + low-stock) | ✅ | `/api/admin/dashboard/` (cached 60s) |
| **Sales report** (date range, group by day/week/month) | ❌ | `/api/admin/reports/sales/` |
| **Best-selling products** | ❌ | Aggregate over `OrderItem.quantity` |
| **Customer growth** | ❌ | Date-truncated count of new users |
| **Conversion rate** | 🟡 | Needs cart events tracked |
| **CSV / XLSX export** | ❌ | `?export=csv` or `?export=xlsx` (openpyxl in requirements) |

---

## 15. CMS

| Feature | Status | Notes |
|---|---|---|
| Banner CRUD (placement + date window) | ✅ | `cms.Banner` |
| Page CRUD (markdown body) | ✅ | `cms.Page` (terms, privacy, shipping, about) |
| FAQ CRUD | ✅ | `cms.FAQ` |
| **Storefront banner display** | ❌ | HomePage doesn't yet fetch `/api/cms/banners/` |
| **Storefront `/pages/<slug>` route** | ❌ | New React route + Markdown render |
| **Blog system** (Article model) | ❌ | New model + admin + storefront |

---

## 16. SEO

| Feature | Status | Notes |
|---|---|---|
| Per-product meta title / description | ❌ | Fields on Product |
| `<meta name="description">` rendered | ❌ | React Helmet (or Vite plugin); needs SSR-ish handling for crawlers — for now meta in `index.html` updated client-side |
| Open Graph tags (og:title, og:image) | ❌ | Same path |
| **Sitemap.xml** | ❌ | `django.contrib.sitemaps` |
| **Robots.txt** | ❌ | Static file in `frontend/public/` |
| **JSON-LD product schema** | ❌ | `<script type="application/ld+json">` injected on product detail |

---

## 17. Performance

| Feature | Status | Notes |
|---|---|---|
| Cloudinary auto-image optimization | ✅ | Cloudinary delivers WebP / responsive |
| **Lazy loading** images | 🟡 | `<img loading="lazy">` not consistently used |
| **Caching** dashboard payload (60s) | ✅ | Django local-memory cache |
| **CDN** | 🟡 | Cloudinary for media; static assets served by Vite |
| Pagination | ✅ | DRF default |
| **Query optimization** (`select_related`, `prefetch_related`) | ✅ | Most admin views; double-check on `OrderAdminListView` |

---

## 18. Database Architecture

See [database-schema.md](database-schema.md) for the full table list.

---

## 19. Production Hygiene

| Feature | Status | Notes |
|---|---|---|
| Audit logs | ✅ | `audit.AuditLog` |
| **Soft delete** | ❌ | Add `is_deleted` + `deleted_at` to Product, Category, Order; manager that filters by default |
| **Background jobs** (Celery / django-q) | ❌ | Needs broker (Redis); for now sync sends |
| **Cron jobs** (cleanup, daily reports) | ❌ | django-cron or APScheduler; not critical for v1 |
| **Webhooks** | 🟡 | Razorpay incoming exists; outgoing webhooks for partners — future |
| **Email queue** | ❌ | When Celery is in: `notify(...)` becomes `notify.delay(...)` |
| **Error monitoring** | ❌ | Add Sentry SDK; gate by env var |
| **Admin permissions** (granular) | 🟡 | Currently flat `IsAdminUser`; group-based perms — future |
| **Data backup** | ❌ | Postgres `pg_dump` cron in prod env (out of code scope) |
| **API rate limiting** | ❌ | DRF `AnonRateThrottle`, `UserRateThrottle` config |

---

## 20. Full System Architecture

```
┌──────────────────┐       ┌──────────────────┐
│  Frontend (Vite) │  ──>  │  React Router    │
│  React 18, Axios │       │  Public + Admin  │
└──────────────────┘       └──────────────────┘
            │
            │ HTTPS  /api/*  (JWT bearer)
            v
┌─────────────────────────────────────────────────────┐
│              Django + DRF (8000)                    │
│                                                     │
│  Apps:                                              │
│   • users         (auth, dealer, admin permissions) │
│   • products      (catalog + variants + media)      │
│   • cart          (session-based)                   │
│   • orders        (order, items, returns, refunds)  │
│   • invoices      (NEW)                             │
│   • payments      (Razorpay + COD)                  │
│   • discounts     (per-tier, time-bound)            │
│   • inventory     (warehouses + stock movements)    │
│   • shipping      (NEW: zones + estimator)          │
│   • notifications (in-app + email + sms stub)       │
│   • reviews       (NEW)                             │
│   • wishlist      (NEW)                             │
│   • cms           (banners, pages, faqs, blog?)     │
│   • media_lib     (Cloudinary asset registry)       │
│   • store_settings (singleton)                      │
│   • audit         (admin mutation log)              │
│                                                     │
│  Cross-cutting:                                     │
│   • core/permissions.py   IsAdminUser etc.          │
│   • core/exceptions.py    error envelope            │
│   • services/erp.py       ERP push                  │
│   • services/notifications.py                       │
│   • services/invoice_pdf.py    (NEW)                │
│   • services/shipping_label.py (NEW)                │
└─────────────────────────────────────────────────────┘
            │                                │
            v                                v
┌─────────────────────┐         ┌────────────────────────┐
│  Postgres (Neon)    │         │ External Services      │
│  All tables         │         │  • Cloudinary (media)  │
│  + audit log        │         │  • Razorpay (payments) │
└─────────────────────┘         │  • Resend / SMTP (mail)│
                                │  • Twilio / MSG91 (SMS)│
                                │  • Sentry (errors)     │
                                └────────────────────────┘
```

Frontend ports: 5173 (Vite dev). Backend port: 8000. Frontend never talks directly to external services — every external call is server-side so secrets stay out of the browser.
