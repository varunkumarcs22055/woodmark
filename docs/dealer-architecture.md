# FurniShop — Dealer / B2B Portal Architecture

You are building **four interlocking systems**:

1. **Customer storefront** (B2C) — `/`, public, anonymous-friendly
2. **Dealer portal** (B2B) — `/dealer-dashboard/*`, role=`dealer`, dealer-only
3. **Admin / ERP** — `/admin-dashboard/*`, role=`admin`
4. **Inventory & Order System** — backend services shared by all three

This doc covers system #2. Status legend: ✅ exists · 🟡 partial · ❌ missing.

---

## 1. Authentication & onboarding

| Feature | Status | Notes |
|---|---|---|
| Dealer registration request | ✅ | `/api/auth/dealer-apply/` (`User.role='dealer', dealer_status='pending'`) |
| Admin approval / rejection | ✅ | `/api/auth/dealers/{id}/approve/` writes `dealer_status='active'\|'rejected'` |
| Dealer login → role-based redirect | ✅ | `RoleRoute({ allowedRoles: ['dealer'] })` |
| Dealer status gate (pending / rejected screens) | ✅ | `DealerPendingScreen`, `DealerRejectedScreen` |
| Dealer profile page | ✅ | `DealerProfile.jsx` |
| **Profile completion: GST upload, address, contact person** | ❌ | Add to `DealerProfile` form |
| **Block / suspend dealer** | 🟡 | `is_blocked` already exists on User; admin Customers page already has the toggle |

---

## 2. Dashboard metrics

`DealerOverview.jsx` exists but shows generic stats. Needs:

| Metric | Source |
|---|---|
| Total orders | `Order.objects.filter(user=self.request.user).count()` |
| Pending orders | `…filter(order_status__in=['CREATED','CONFIRMED'])` |
| Lifetime revenue | `…aggregate(Sum('total_amount'))` |
| **Outstanding payments** | `DealerInvoice.amount_due` aggregate (NEW) |
| **Available credit** | `DealerCredit.credit_limit − amount_used` (NEW) |
| Recent activity | last 5 orders + last 5 payments |

Backend: new endpoint `GET /api/dealer/dashboard/` (cached 60s).

---

## 3. Dealer product catalog

| Feature | Status | Notes |
|---|---|---|
| Dealer-specific price (single tier) | ✅ | Per-product `Discount(discount_type='dealer', value)` |
| **Tiered / volume pricing** | ✅ | `Discount.min_quantity` ladder (already shipped) |
| **MOQ** (minimum order quantity, dealer-specific) | ❌ | New field `Product.dealer_moq` (default=1) |
| **Region-wise pricing** | ❌ | New `DealerPricingRule` keyed on territory |
| **Premium-tier dealer pricing** | ❌ | Add `User.dealer_tier` (`standard`/`premium`/`platinum`); pricing service picks tier |
| **Dealer-exclusive products** (hidden from customers) | ❌ | `Product.dealer_only` boolean; storefront filter excludes |
| Product specifications | ✅ | Already exists |
| **Catalog PDF export** | ❌ | New endpoint `GET /api/dealer/catalog.pdf?category=` (reportlab) |

---

## 4. Dealer pricing system (P0)

### Three pricing axes

```
┌────────────────────────────────────────────────────────┐
│ Effective price for a dealer's cart line:              │
│                                                        │
│   final = max(                                         │
│     0,                                                 │
│     base_price                                         │
│     × (1 - tier_discount_pct[dealer.tier])             │
│     × (1 - quantity_tier_discount_pct[min_qty])        │
│   ) − negotiated_offset                                │
└────────────────────────────────────────────────────────┘
```

- **Base price** — `Product.price` (customer-facing MRP)
- **Tier discount** — comes from a new `DealerTier` table (`standard 25%`, `premium 31%`, `platinum 36%`)
- **Quantity tier** — existing `Discount.min_quantity` ladder
- **Negotiated price** — optional row in `NegotiatedPrice(dealer, product, agreed_price)` overrides everything when present

### Resolution order

1. If `NegotiatedPrice(dealer, product)` exists → use `agreed_price`
2. Else compute `tier_pct + qty_tier_pct` (multiplicative, not additive — avoid stacking that goes ≤0)
3. Floor at 0; round to 2 decimals
4. Return `{effective, mrp, dealer_savings, tier_label, qty_tier_min}`

### What changes vs today

The existing `discounts` app stays as-is. We add:
- `DealerTier(slug, name, default_discount_pct, sort_order)` — seeded with `standard / premium / platinum`
- `User.dealer_tier_id` FK (NULL for non-dealers)
- `NegotiatedPrice(dealer, product, agreed_price, valid_from, valid_until, note)`
- `services/dealer_pricing.py::resolve(product, dealer, quantity) -> {…}`
- `DiscountInfoMixin._get_pricing` calls `dealer_pricing.resolve` when `user.role == 'dealer'`, falls back to existing `discounts.services.get_effective_price`

---

## 5. Bulk order management

| Feature | Status |
|---|---|
| Bulk quantity selector (already works via cart) | ✅ |
| **CSV upload** (SKU,quantity) → adds to cart | ❌ — new endpoint `POST /api/dealer/bulk-order/preview/` returns parsed cart |
| **Quick reorder** from past order | ❌ — button on each `DealerOrder` row |
| **Repeat previous orders** | ❌ — same as above |
| **Bulk cart** | 🟡 — existing `CartContext` works; just need a "load from CSV" button |

Backend additions:
- `POST /api/dealer/bulk-order/preview/` — body: `{rows: [{sku, quantity}, ...]}` → `{items, errors[], totals}`
- `POST /api/dealer/bulk-order/commit/` — accepts the previewed payload + payment_method + po_number → creates an order
- `POST /api/dealer/orders/{order_id}/reorder/` — copies items into the dealer's cart (or returns a preview)

---

## 6. Dealer cart & checkout

| Feature | Status |
|---|---|
| GST calculation | ✅ shared with B2C |
| **Credit-payment option at checkout** | ❌ — `payment_method='credit'` flag |
| **PO number capture** | ❌ — new field `Order.po_number` |
| **Dealer notes** | ❌ — new field `Order.dealer_note` |
| **Shipping preferences** (carrier choice) | ❌ — `Order.preferred_carrier` |

Reuses the existing checkout flow with branches.

---

## 7. Credit & payment system (P0)

### `DealerCredit` (new)

| Column | Type | Notes |
|---|---|---|
| dealer | OneToOneField → User | one row per dealer |
| credit_limit | DECIMAL(12,2) | admin-set, e.g. 500000.00 |
| amount_used | DECIMAL(12,2) DEFAULT 0 | sum of unpaid credit invoices |
| terms_days | INT DEFAULT 30 | net-30 by default |
| is_active | BOOL DEFAULT TRUE | |
| created_at, updated_at | | |

### `DealerPayment` (new)

| Column | Type | Notes |
|---|---|---|
| dealer | FK → User | |
| invoice | FK → invoices.Invoice NULL | NULL = on-account / advance |
| amount | DECIMAL(12,2) | |
| method | VARCHAR(20) | `bank_transfer` / `cheque` / `upi` / `cash` / `razorpay` |
| reference | VARCHAR(80) blank | UTR / cheque #, etc. |
| recorded_by | FK → User NULL | admin who recorded the payment |
| note | TEXT blank | |
| received_at | DATETIME | |
| created_at | | |

### Credit usage update

- On `Order.create` with `payment_method='credit'` → check `credit.remaining >= total_amount`; reject if not
- On `Invoice.create_for_dealer_credit_order` → `credit.amount_used += grand_total`
- On `DealerPayment.create(invoice=X)` → reduce `invoice.amount_due`; if it hits 0, reduce `credit.amount_used`

### Endpoints

- `GET /api/dealer/credit/` → `{credit_limit, amount_used, remaining, terms_days, is_active}`
- `GET /api/dealer/payments/?from=&to=`
- `GET /api/dealer/invoices/?status=open|paid`
- `GET /api/dealer/ledger/?from=&to=` → time-ordered list of invoices + payments (running balance)
- Admin:
  - `GET/PATCH /api/admin/dealers/{id}/credit/` — set credit_limit, terms
  - `POST /api/admin/dealers/{id}/payments/` — record payment
  - `GET /api/admin/dealers/{id}/ledger/` — same shape as dealer's view

---

## 8. Dealer invoices

Reuse the existing `invoices` app. Filter `Invoice.objects.filter(customer=request.user)` for the dealer view. Per the spec:

- `GET /api/dealer/invoices/?status=open|paid`
- `GET /api/dealer/invoices/{id}/pdf/` (already implemented for any owner)
- **Bulk download** — `GET /api/dealer/invoices/zip/?from=&to=` returns a ZIP of PDFs

---

## 9. Dealer order tracking

Reuses existing `Order` + `Shipment` (see main schema doc). Dealer view:

- `GET /api/dealer/orders/` — paginated, filterable by status / date
- `GET /api/dealer/orders/{id}/` — detail with timeline (state transitions from audit_log)
- Return request flow: `POST /api/dealer/orders/{id}/return/`

---

## 10. Dealer wallet (Optional — P2)

| Feature | Notes |
|---|---|
| `DealerWallet(dealer, balance, currency)` table | NEW |
| `WalletTransaction(wallet, kind, amount, reference, note)` | NEW; kinds: `cashback`, `reward`, `redeem`, `adjustment` |
| Auto-cashback rule per order (admin-configurable) | NEW; e.g. 1% on orders > ₹50,000 |
| Use wallet at checkout | NEW; `payment_method='wallet'` branch |

Defer until credit + invoices are stable.

---

## 11. Dealer support

| Feature | Notes |
|---|---|
| `SupportTicket(dealer, subject, body, status, priority, assigned_to)` | NEW |
| `TicketReply(ticket, author, body, attachments)` | NEW |
| **Priority** routing for premium-tier dealers | NEW |
| Admin queue + reply UI | NEW page |
| **Live chat** | OUT OF SCOPE for v1 — pure ticketing only |

---

## 12. Dealer analytics

Backend: `GET /api/dealer/analytics/` returns:

```json
{
  "monthly_spend": [{"month": "2026-04", "amount": "..."}, ...],
  "best_selling": [{"product_id": …, "name": …, "qty": …}, ...],
  "average_order_value": "...",
  "purchase_trend": "up" | "flat" | "down"
}
```

Frontend: chart on dealer overview using `recharts` (already in `package.json` plan).

---

## 13. Dealer inventory visibility

Already covered by `inventory` app. Dealer view:

- `GET /api/dealer/inventory/?product_id=` → per-warehouse stock + ETA for incoming stock (from `StockMovement(reason='inbound')` rows scheduled in the future)

---

## 14. Marketing materials

| Feature | Notes |
|---|---|
| `MarketingAsset(title, kind, file, category, is_published)` | NEW |
| Kinds: `brochure`, `product_pdf`, `brand_asset`, `banner` | |
| Dealer endpoint `GET /api/dealer/marketing/` | filtered, paginated |
| Admin upload via existing CMS pattern | reuse |

---

## 15. Dealer notifications

Reuse the existing `notifications` app. Add new `kind` values: `dealer.new_product`, `dealer.stock_alert`, `dealer.payment_reminder`, `dealer.offer`. Signals:

- New product (`Product.post_save, created=True, dealer_only=False or True`) → notify all active dealers
- Stock low for a product on dealer's recent purchase list → notify those dealers
- Invoice `amount_due > 0 AND days_since_invoice >= terms_days/2` → payment reminder
- New `Discount(discount_type='dealer')` → offer notification

---

## 16. Dealer return management

Reuses `OrderReturn`. New endpoints:

- `POST /api/dealer/orders/{id}/returns/` — create return (reasons: `damaged`, `wrong_item`, `not_as_described`, `quality`, `other`)
- `POST /api/dealer/orders/{id}/replacement/` — request replacement instead of refund
- Admin: existing return moderation + new "replacement" status branch

---

## 17. Admin: dealer management

Already partly in the admin Customers page. Add:

- Set / edit `dealer_tier`
- Set / edit `credit_limit`, `terms_days`
- View dealer ledger
- Suspend (uses existing `is_blocked` on User)
- Assign territory (`dealer_territory`)
- View dealer performance dashboard (revenue, AOV, orders, returns)

---

## Suggested route map (dealer side)

| Route | Page | Status |
|---|---|---|
| `/dealer-dashboard/` | DealerOverview (with credit + outstanding widgets) | ✅ + extend |
| `/dealer-dashboard/orders` | DealerOrders | ✅ + extend with reorder buttons |
| `/dealer-dashboard/orders/:id` | DealerOrderDetail (NEW) | ❌ |
| `/dealer-dashboard/invoices` | DealerInvoices (NEW) | ❌ |
| `/dealer-dashboard/payments` | DealerPayments (NEW) | ❌ |
| `/dealer-dashboard/credit` | DealerCredit (NEW) | ❌ |
| `/dealer-dashboard/bulk-order` | DealerBulkOrder (NEW — CSV upload) | ❌ |
| `/dealer-dashboard/marketing` | DealerMarketing (NEW) | ❌ |
| `/dealer-dashboard/support` | DealerSupport (NEW) | ❌ |
| `/dealer-dashboard/profile` | DealerProfile | ✅ |

---

## Workflow recap

```
Dealer registers
  ↓
Admin approves + assigns tier (standard/premium/platinum)
       + sets credit_limit (e.g. ₹5L)
       + assigns territory
  ↓
Dealer logs in → sees `effective_price` adjusted by their tier
  ↓
Places order:
  - via product page (single)
  - or bulk-order CSV upload
  - selects payment_method = razorpay / cod / credit
  - enters po_number, dealer_note
  ↓
ERP confirms order → stock decrements → invoice auto-creates
  ↓
If credit: invoice.amount_due > 0 → DealerCredit.amount_used += grand_total
  ↓
Shipment → tracking → delivered
  ↓
Admin records payment → invoice paid → credit released
```
