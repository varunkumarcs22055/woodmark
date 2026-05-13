# Dealer / B2B Portal — Implementation Prompt

## Role
Senior full-stack engineer (FAANG bar). You are the lead on the B2B portal. Read `docs/dealer-architecture.md` and `docs/dealer-database-schema.md` first — they're the source of truth.

You don't ask clarifying questions. Don't restate the spec. End with a single sentence and stop.

## Stack lock-ins
Same as the rest of the platform (Django 5 + DRF, React 18 + Vite, Cloudinary, reportlab, Razorpay, JWT). All four systems share the same backend; the dealer portal is a route + role gate, not a separate service.

## Phasing — implement strictly in order

### Phase 1 — Pricing tiers (P0, prerequisite for everything else)

1. New app `dealer_pricing/`. Models: `DealerTier`, `NegotiatedPrice`. Seed three tiers (`standard 25%`, `premium 31%`, `platinum 36%`) in a data migration.
2. Add `User.dealer_tier` FK and `User.dealer_territory`.
3. Service `services/dealer_pricing.py::resolve(product, dealer, quantity) -> {effective, mrp, savings, tier_label, qty_tier_min, source}`.
4. Wire into `products.serializers.DiscountInfoMixin._get_pricing` — when `user.role == 'dealer'`, call `dealer_pricing.resolve` and short-circuit the existing `discounts.services.get_effective_price`. The existing per-product `Discount(discount_type='dealer')` ladder still applies on top of the tier discount via the resolver (multiplicative).
5. Resolution priority:
   1. `NegotiatedPrice(dealer, product, valid_now)` → return `agreed_price` flat
   2. Else: `effective = mrp × (1 − tier_pct) × (1 − qty_tier_pct)`, both fractions; floor at 0; round to 2dp
6. Admin endpoint to set `User.dealer_tier`, `User.dealer_territory`, and to CRUD `NegotiatedPrice`.
7. Acceptance: dealer with `tier=premium` (31% off) on a ₹10,000 product with a `min_qty=5 → 10%` quantity tier sees ₹6,210 at qty 5 (10000 × 0.69 × 0.90).

### Phase 2 — Credit & payments (P0)

1. New app `dealer_credit/` with `DealerCredit` (singleton per dealer) and `DealerPayment`.
2. Add `Order.payment_method='credit'` branch:
   - `OrderCreateSerializer.create` checks `request.user.role == 'dealer'` and `payment_method == 'credit'`
   - Validates `dealer_credit.remaining >= total_amount`
   - Sets `payment_status='PENDING'`, `order_status='CREATED'`
3. Add `Invoice.amount_paid`, `Invoice.amount_due` columns. Compute `amount_due = grand_total - amount_paid`. On invoice create with `payment_method='credit'`, increment `DealerCredit.amount_used`.
4. Endpoints:
   - `GET /api/dealer/credit/`
   - `GET /api/dealer/payments/`
   - `GET /api/dealer/invoices/?status=open|paid`
   - `GET /api/dealer/ledger/`
   - Admin: `GET/PATCH /api/admin/dealers/{id}/credit/`, `POST /api/admin/dealers/{id}/payments/`
5. When admin records a payment, decrement `Invoice.amount_due` (and roll back `DealerCredit.amount_used` if invoice fully paid).
6. Acceptance: dealer with credit_limit=500000, places ₹50000 order on credit → credit.amount_used=50000, remaining=450000. Admin records ₹50000 payment → amount_due=0, credit.amount_used=0.

### Phase 3 — Dealer dashboard widgets

1. Endpoint `GET /api/dealer/dashboard/` — single payload with credit, outstanding, recent orders, recent payments.
2. Extend `DealerOverview.jsx` with three KPI cards (credit available / outstanding / lifetime spend) + a `recharts` line chart of monthly spend (12 months).
3. Update sidebar nav to add: My Invoices, Payments, Credit, Bulk Order, Marketing, Support.

### Phase 4 — Order detail + reorder

1. New page `DealerOrderDetail.jsx` at `/dealer-dashboard/orders/:id`.
2. Endpoint `POST /api/dealer/orders/{id}/reorder/` — copies items into a preview payload (frontend then injects them into `CartContext`).
3. "Reorder" button on each row in `DealerOrders.jsx`.

### Phase 5 — Bulk-order CSV upload

1. Endpoint `POST /api/dealer/bulk-order/preview/` — body: `multipart/form-data` with `file` (CSV with `sku,quantity`). Returns parsed rows + per-line errors + totals.
2. Endpoint `POST /api/dealer/bulk-order/commit/` — accepts `{items, payment_method, po_number, dealer_note}` and creates an order.
3. New page `DealerBulkOrder.jsx` with file picker, preview table (editable quantity), submit.

### Phase 6 — Dealer-only catalog flags

1. Add `Product.dealer_only`, `Product.dealer_moq`. Storefront `/api/products/` filter `dealer_only=False` for non-dealer requests; show all for dealers.
2. Cart enforces MOQ at add-to-cart time (frontend + server validation in `OrderCreateSerializer`).
3. Admin Products UI gets the toggle + MOQ field.

### Phase 7 — Catalog PDF export

1. `GET /api/dealer/catalog.pdf?category=&include_negotiated=1` — renders product table with columns Name / SKU / MRP / Your Price / Stock.
2. Reuses `reportlab` — new `services/dealer_catalog_pdf.py`.

### Phase 8 — Support tickets

1. New app `support/` with `SupportTicket` (number = `TKT-YYYY-#####`, atomic counter same pattern as invoices) and `TicketReply`.
2. Premium / platinum tier auto-bumps default priority to `high` / `urgent`.
3. Endpoints: `POST /api/support/tickets/`, `GET /api/support/tickets/`, `GET /tickets/{id}/`, `POST /tickets/{id}/replies/`. Admin moderation page.

### Phase 9 — Marketing assets

1. `MarketingAsset` model + admin upload + dealer list endpoint.

### Phase 10 — Dealer notifications wiring

Use existing `services/notifications.notify(...)`:
- New product (`Product.post_save, created=True, status='active'`) → notify all active dealers with `kind='dealer.new_product'`
- Stock low for dealer's recently-purchased product → `kind='dealer.stock_alert'`
- Invoice age > terms_days/2 with `amount_due > 0` → `kind='dealer.payment_reminder'` (called from a daily management command)

### Phase 11 — Wallet (P2, defer if context tight)

`DealerWallet`, `WalletTransaction`, optional cashback signal on `Invoice.payment_status → SUCCESS`.

## Cross-cutting

- All dealer-only endpoints use a new permission class `IsActiveDealer` (`role=='dealer' AND dealer_status=='active' AND not is_blocked`). Define once in `core/permissions.py`.
- Every list endpoint paginated with DRF default.
- Every mutation wrapped in `transaction.atomic()`.
- Every admin mutation writes `AuditLog`.
- All money math uses `Decimal`, never float.
- Dealer-side endpoints filter on `request.user` automatically — never trust a client-supplied `dealer_id`.

## Frontend conventions
- New dealer pages at `frontend/src/pages/dealer/Dealer<Name>.jsx`, registered in `DealerDashboard.jsx` (NAV_ITEMS + Routes).
- API helpers in `frontend/src/api/index.js`.
- Reuse existing AdminPanel.css patterns where possible; dealer-specific CSS goes in `DealerDashboard.css`.

## Acceptance gates

| Phase | Smoke test |
|---|---|
| 1 | dev-dealer logs in, opens a product → effective price reflects tier × qty-tier ladder. |
| 2 | dev-dealer places `payment_method='credit'` order → credit.amount_used jumps. Admin records payment → it drops back. |
| 3 | DealerOverview shows real KPIs from `/api/dealer/dashboard/`. |
| 4 | Reorder button on a past order populates the cart. |
| 5 | CSV upload of `sku,quantity` rows produces a valid order. |
| 6 | A `dealer_only=True` product is invisible at `/api/products/` (anon) but appears for `dev-dealer`. |
| 7 | `/api/dealer/catalog.pdf` returns a `%PDF-1.4` blob. |
| 8 | dealer files a ticket → admin sees it in queue → admin replies → dealer sees the reply. |

## Token discipline

- Use `Edit` for changes <50 LOC, `Write` only for new files.
- Don't recap. End with one sentence: `"Dealer phase X complete. Run <one command>."`

## Out of scope

- Live chat, multi-branch dealers, franchise hierarchy, sales-rep assignments, commission tracking
- SMS reminders (use email channel only)
- Region-wise pricing keyed off pincode (deferred until Phase E shipping is built)
- Dealer wallet (P2; build if context allows after Phase 1–9)

End of prompt.
