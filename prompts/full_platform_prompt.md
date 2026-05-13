# Full Platform Implementation Prompt

## Role
You are a Staff-level full-stack engineer (FAANG bar). You are extending FurniShop from "admin-panel demo" to "real e-commerce" by building the missing systems documented in `docs/architecture.md`, `docs/database-schema.md`, and `docs/product-listing-spec.md`. Read those three first; they are the source of truth.

You don't ask clarifying questions. You don't restate the spec. When you finish, you state the result in one sentence and stop.

## Stack lock-ins (don't re-debate)
- Django 5.2 + DRF + SimpleJWT + Cloudinary + Razorpay (existing)
- React 18 + Vite + Axios + react-hot-toast + react-icons/fi (existing)
- PDFs: `reportlab` (already in `requirements.txt`)
- Excel: `openpyxl` (already in `requirements.txt`)
- Email in dev: console backend. In prod: SMTP via env vars (Resend later)
- SMS: stub (Twilio integration is out of scope for this prompt)
- Payments: Razorpay (existing) + COD (new branch in checkout)

## Phasing — implement in this order, do not interleave

### Phase A — Schema migrations (run first, no business logic)
Add the model fields and new tables documented in `docs/database-schema.md`. One migration per app, all reversible, all backfill-safe. Specifically:

1. `users.User` → `+phone_verified`, `+default_billing_address_id`, `+default_shipping_address_id`
2. `addresses` (new app) → `Address` model
3. `products.Product` → `+brand`, `+hsn_code`, `+highlights`, `+meta_title`, `+meta_description`, `+og_image_url`, `+rating_avg`, `+rating_count`, `+delivery_estimate_days`, `+weight_grams`, `+is_deleted`, `+deleted_at`
4. `shipping` (new app) → `ShippingZone`, `Shipment`
5. `invoices` (new app) → `Invoice`, `InvoiceItem`, `InvoiceCounter`
6. `reviews` (new app) → `Review`, `ReviewVote`
7. `wishlist` (new app) → `WishlistItem`
8. `coupons` (new app) → `Coupon`, `CouponUsage`, M2M `coupon_categories`
9. `payments.Payment` → `+method`, `+webhook_event_id`, `+failure_reason`
10. `webhooks` (new app) → `WebhookEvent`
11. `orders.Order` → `+billing_address_id`, `+shipping_address_id`, `+pincode`, `+cgst_amount`, `+sgst_amount`, `+igst_amount`, `+discount_amount`, `+shipping_zone_id`, `+payment_method`, `+is_deleted`
12. `orders.OrderItem` → `+variant_id`, `+tax_amount`
13. `notifications` → `NotificationPreference`
14. `store_settings.StoreSettings` → `+legal_name`, `+gstin`, `+store_state`, `+store_pincode`

After **each** model change: run `makemigrations <app>` and verify migration applies cleanly.

For data backfill (e.g. `Order.pincode` from existing `Order.address` text): use a `RunPython` step inside the same migration with a no-op reverse.

### Phase B — Invoice system (P0)
The user explicitly called this out as VERY IMPORTANT.

1. Numbering helper `services/invoice_number.py` — `next_invoice_number()` uses `select_for_update()` on `InvoiceCounter` (atomic).
2. Service `services/invoice_factory.py::create_invoice_from_order(order)` — snapshots store + customer info, computes CGST/SGST split (intra-state) vs IGST (inter-state) using `StoreSettings.store_state` ↔ derived buyer state, populates `InvoiceItem` rows, copies `hsn_code` per line.
3. PDF generator `services/invoice_pdf.py::render_invoice_pdf(invoice) -> bytes`. Use `reportlab.platypus` (`SimpleDocTemplate`, `Paragraph`, `Table`, `TableStyle`). Layout: header with store name + GSTIN, billing/shipping blocks, line-item table with `S.No / Item / HSN / Qty / Unit Price / CGST / SGST / IGST / Total`, totals block, footer with terms-and-conditions text from `cms.Page(slug='invoice-terms')` (fall back to a hard-coded default), signature line.
4. Endpoints under `/api/invoices/`:
   - `GET /` — admin: paginated, filterable (status, date range, search by invoice_number/order_id/customer email)
   - `GET /{id}/` — admin OR order owner
   - `GET /{id}/pdf/` — returns `application/pdf` with `Content-Disposition: attachment; filename="<invoice_number>.pdf"`
   - `POST /{id}/email/` — admin: queue/send the PDF as email attachment
   - `POST /regenerate/{order_id}/` — admin recovery (deletes existing invoice + recreates)
5. Auto-create on `Order.payment_status` transition to `SUCCESS` via `post_save` signal — guard with `Invoice.objects.filter(order=order).exists()` so it's idempotent.
6. Frontend admin page `/admin-dashboard/invoices` — list with date range + search + Download PDF + Email buttons. Order detail drawer gets a "Download Invoice" button that hits the same PDF endpoint.

### Phase C — Reviews & ratings (P0)

1. `Review` model with `verified_purchase` derived from existence of an `OrderItem(user=author, product=this)`. Set in `Review.save()` if not provided.
2. Endpoints:
   - `GET /api/reviews/?product_id=&ordering=`
   - `GET /api/reviews/summary/?product_id=` → `{avg, count, by_star: {1: n, …, 5: n}}`
   - `POST /api/reviews/` (auth required)
   - `POST /api/reviews/{id}/helpful/` (toggle)
   - `PATCH /api/admin/reviews/{id}/` (moderation)
3. Signal on `Review.save` (when `status='approved'`) → recompute `Product.rating_avg` + `rating_count`.
4. Frontend:
   - `components/StarRating.jsx` (display + interactive)
   - `components/ReviewForm.jsx`
   - `components/ReviewList.jsx`
   - `components/ReviewSummary.jsx`
   - PDP integration below the spec table.
   - Admin page `/admin-dashboard/reviews` with status filter + bulk approve/reject.

### Phase D — Wishlist

1. `WishlistItem` model. Endpoints `GET /api/wishlist/`, `POST /api/wishlist/{product_id}/`, `DELETE /api/wishlist/{product_id}/`.
2. Frontend: `components/WishlistButton.jsx` injected into `ProductCard` and PDP. New page `pages/WishlistPage.jsx` (route `/wishlist`).
3. Move-to-cart action.

### Phase E — Shipping (pincode + estimate + zones)

1. `ShippingZone`, `Shipment` models. Seed 4–6 zones in `seed_admin`.
2. Function `services/shipping.py::estimate(pincode, subtotal, weight_grams) -> {courier, charge, sla_min_days, sla_max_days, cod_supported}`. Longest-prefix match wins; falls back to `StoreSettings`.
3. Endpoint `GET /api/shipping/estimate/?pincode=&product_id=&qty=`.
4. Frontend `components/PincodeChecker.jsx` on PDP and Cart page.
5. Admin `/admin-dashboard/shipping` to CRUD zones.

### Phase F — GST CGST/SGST split + HSN

1. Add `cgst_amount`, `sgst_amount`, `igst_amount` to Order; backfill from existing `gst_amount` (assume IGST for legacy rows since we don't know buyer state).
2. `OrderCreateSerializer.create()` — derive buyer state from billing pincode (use a small JSON map of pincode-prefix → state, ship in `services/pincodes.py`); split tax accordingly. Set `Order.shipping_zone` from pincode.
3. Show CGST/SGST split on invoice (already covered in Phase B).
4. Admin StoreSettings tab gets `legal_name`, `gstin`, `store_state`, `store_pincode` fields.

### Phase G — Limited Time Offers HomePage (carry-over)

The previous turn left this half-built. Finish it:

1. Remove "Shop by Category" section from `HomePage.jsx` (lines 293–323). Drop the `CATEGORIES` constant if unused after removal.
2. Add a "Limited Time Offers" section that fetches `/api/products/limited-offers/?limit=8` and renders ProductCard with a `CountdownPill` overlay. Re-render the countdown every 60s via `useEffect` interval. Hide the section when the response is empty.

### Phase H — Coupons (separate from per-product discounts)

1. Models from `database-schema.md`. Admin CRUD page.
2. Endpoint `POST /api/coupons/validate/` body `{code, subtotal, user_id, category_ids}` returns `{valid, discount_amount, message}`.
3. Apply at checkout: cart calls validate → checkout sends `coupon_code` → `OrderCreateSerializer` re-validates server-side and writes `CouponUsage`.

### Phase I — SEO basics

1. Product fields already in Phase A. Render into `<head>` on PDP via `react-helmet-async` (add to `package.json`).
2. JSON-LD `Product` schema injected as `<script type="application/ld+json">`.
3. `django.contrib.sitemaps` for `/sitemap.xml` (products + categories + pages).
4. Static `frontend/public/robots.txt`.

### Phase J — Polish (defer to a later prompt if context tight)

- Notification preferences page
- Email outbox + cron drain
- Soft-delete managers everywhere
- Sentry / rate limiting
- Blog system

## Cross-cutting (every endpoint)

- `permission_classes = [IsAdminUser]` for admin endpoints, `[IsAuthenticated]` for user endpoints, `[AllowAny]` only when truly public.
- Pagination via DRF default (already configured `PAGE_SIZE=12`; admin pages can pass `?page_size=`).
- `filterset_class = …FilterSet` with explicit allowed fields.
- All mutations wrapped in `transaction.atomic()` if they touch >1 row.
- Admin mutations write `AuditLog` via `AuditedMixin.audit_write(...)`.
- Errors returned in DRF default shape (don't enable the envelope handler — it would break existing frontend code).

## Frontend conventions

- New API helpers go in `frontend/src/api/index.js`. No raw axios in components.
- New admin pages go in `frontend/src/pages/admin/Admin<Name>.jsx`, registered in `AdminDashboard.jsx` (NAV_ITEMS + Routes).
- New storefront pages go in `frontend/src/pages/`.
- Reuse `AdminPanel.css` / `index.css` classes; add scoped CSS only for genuinely new UI.

## Acceptance gates per phase

- Phase A: `python manage.py migrate` clean; `python manage.py seed_admin` still idempotent.
- Phase B: place a paid order → invoice row auto-created → admin can download PDF → `/api/invoices/{id}/pdf/` returns valid PDF (open it, render the layout).
- Phase C: write a 5-star review on an ordered product → status pending → admin approves → `Product.rating_avg` updates → PDP shows the review and the star count.
- Phase D: heart icon toggles; reload page; wishlist persists; "Move to cart" works.
- Phase E: `/api/shipping/estimate/?pincode=560001` returns a courier + charge + sla; PDP shows the estimate.
- Phase F: place an order with a pincode in the same state as `StoreSettings.store_state` → CGST + SGST populated, IGST = 0; place one in a different state → IGST populated, CGST = SGST = 0.
- Phase G: HomePage renders the offers strip, no "Shop by Category" section.
- Phase H: bad/expired coupon → 400 with reason; valid → applied at checkout; usage incremented.
- Phase I: View source on a PDP → meta tags + JSON-LD present. `curl /sitemap.xml` returns valid XML.

## Token discipline

- Use `Edit` for changes <50 LOC, `Write` only for new files.
- Don't recap. Don't restate the prompt. Single-sentence end statement: `"Phase X complete. Run <one command>."`
- If you hit ambiguity, make the FAANG-default choice (security > convenience, server-driven > client-driven, correctness > cleverness) and proceed silently.

## Out of scope for this prompt

- Twilio SMS, Resend integration (stubs only)
- Celery / Redis (use sync sends, leave a `TODO: Celery` if appropriate)
- Soft-delete rollout across every model (just on `Product` and `Order` for now)
- Sentry, rate limiting, data backup
- Blog system
- Frontend SSR (CSR + meta updates is acceptable; SSR is a separate effort)

End of prompt.
