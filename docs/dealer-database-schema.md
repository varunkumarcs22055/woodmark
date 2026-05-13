# Dealer Portal — Database Schema (delta on top of `database-schema.md`)

This file lists ONLY the new tables / new columns specific to the dealer system. All other tables (orders, invoices, payments, …) stay shared between B2C and B2B.

---

## A. Pricing

### `dealer_tiers` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| slug | VARCHAR(20) UNIQUE | e.g. `standard`, `premium`, `platinum` |
| name | VARCHAR(80) | Display label |
| default_discount_pct | DECIMAL(5,2) | percent off MRP, e.g. 25.00 |
| sort_order | INT | for admin display |
| is_active | BOOL DEFAULT TRUE | |
| created_at, updated_at | | |

### `users` (additions)
| Column | Type | Notes |
|---|---|---|
| `+ dealer_tier_id` | FK → dealer_tiers NULL | NULL for non-dealers |
| `+ dealer_territory` | VARCHAR(80) NULL | free-text region label |

### `negotiated_prices` — NEW
Optional per-dealer per-product override that wins over tier-based pricing.

| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| dealer_id | FK → users CASCADE | |
| product_id | FK → products CASCADE | |
| agreed_price | DECIMAL(10,2) | absolute, post-tax-handling-rule price |
| valid_from, valid_until | TIMESTAMPTZ NULL | |
| note | TEXT blank | |
| created_by_id | FK → users NULL | admin |
| created_at, updated_at | | |
| UNIQUE | (dealer_id, product_id) | |

---

## B. Credit & Payments

### `dealer_credit` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| dealer_id | OneToOne → users CASCADE | |
| credit_limit | DECIMAL(12,2) DEFAULT 0 | |
| amount_used | DECIMAL(12,2) DEFAULT 0 | denorm — sum of unpaid credit-method invoices |
| terms_days | INT DEFAULT 30 | net-N |
| is_active | BOOL DEFAULT TRUE | admin can pause |
| created_at, updated_at | | |

### `dealer_payments` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| dealer_id | FK → users CASCADE | |
| invoice_id | FK → invoices NULL | NULL = on-account / advance |
| amount | DECIMAL(12,2) | |
| method | VARCHAR(20) | `bank_transfer` / `cheque` / `upi` / `cash` / `razorpay` |
| reference | VARCHAR(80) blank | UTR / cheque # / transaction id |
| recorded_by_id | FK → users NULL | admin who created the row |
| note | TEXT blank | |
| received_at | TIMESTAMPTZ | when funds were actually received |
| created_at | | |
| INDEX | (dealer_id, -received_at) | |

### `invoices` (additions)
| Column | Type | Notes |
|---|---|---|
| `+ amount_paid` | DECIMAL(12,2) DEFAULT 0 | running total of `dealer_payments.amount` for this invoice |
| `+ amount_due` | DECIMAL(12,2) DEFAULT 0 | computed: `grand_total − amount_paid` |
| `+ due_date` | already exists | for net-30 calculation |

### `orders` (additions for B2B fields)
| Column | Type | Notes |
|---|---|---|
| `+ payment_method` | already exists; extend choices with `'credit'` | |
| `+ po_number` | VARCHAR(80) blank | Purchase Order number from dealer |
| `+ dealer_note` | TEXT blank | special instructions |
| `+ preferred_carrier` | VARCHAR(80) blank | optional dealer choice |

---

## C. Wallet (Optional / Phase later)

### `dealer_wallets` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| dealer_id | OneToOne → users CASCADE | |
| balance | DECIMAL(12,2) DEFAULT 0 | |
| currency | VARCHAR(3) DEFAULT 'INR' | |
| created_at, updated_at | | |

### `wallet_transactions` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| wallet_id | FK → dealer_wallets CASCADE | |
| kind | VARCHAR(20) | `cashback` / `reward` / `redeem` / `adjustment` |
| amount | DECIMAL(12,2) | signed: + credit, − debit |
| reference | VARCHAR(80) blank | order_id / invoice_id / promo_code |
| note | TEXT blank | |
| balance_after | DECIMAL(12,2) | denorm for fast statement rendering |
| created_by_id | FK → users NULL | |
| created_at | | |

---

## D. Catalog (Dealer-only flags)

### `products` (additions)
| Column | Type | Notes |
|---|---|---|
| `+ dealer_only` | BOOL DEFAULT FALSE | hidden from B2C `/api/products/` |
| `+ dealer_moq` | INT DEFAULT 1 | Minimum-order-quantity for dealers |
| `+ wholesale_pack_size` | INT NULL | future use |

---

## E. Support tickets

### `support_tickets` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| ticket_number | VARCHAR(20) UNIQUE | `TKT-YYYY-#####` |
| dealer_id | FK → users CASCADE | |
| subject | VARCHAR(200) | |
| body | TEXT | |
| status | VARCHAR(15) DEFAULT 'open' | `open` / `in_progress` / `resolved` / `closed` |
| priority | VARCHAR(10) DEFAULT 'normal' | `normal` / `high` / `urgent` (premium dealers default to `high`) |
| category | VARCHAR(40) blank | `order` / `payment` / `product` / `other` |
| assigned_to_id | FK → users NULL | admin |
| order_id | FK → orders NULL | optional related order |
| resolved_at | TIMESTAMPTZ NULL | |
| created_at, updated_at | | |

### `ticket_replies` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| ticket_id | FK → support_tickets CASCADE | |
| author_id | FK → users CASCADE | |
| body | TEXT | |
| is_internal | BOOL DEFAULT FALSE | admin-only note |
| created_at | | |

---

## F. Marketing assets

### `marketing_assets` — NEW
| Column | Type | Notes |
|---|---|---|
| id | BIGSERIAL PK | |
| title | VARCHAR(200) | |
| kind | VARCHAR(20) | `brochure` / `product_pdf` / `brand_asset` / `banner` |
| file_url | VARCHAR(500) | Cloudinary or external |
| thumbnail_url | VARCHAR(500) blank | |
| category_id | FK → categories NULL | |
| is_published | BOOL DEFAULT TRUE | |
| audience | VARCHAR(20) DEFAULT 'all_dealers' | `all_dealers` / `premium` / `platinum` |
| created_by_id | FK → users NULL | |
| created_at, updated_at | | |

---

## ER summary (deltas only)

```
users 1───* dealer_tier (FK)
users 1───1 dealer_credit
users 1───* dealer_payments ──* invoices (NULL)
users 1───* negotiated_prices ──* products
users 1───1 dealer_wallets 1───* wallet_transactions
users 1───* support_tickets 1───* ticket_replies

products *───── flags: dealer_only, dealer_moq

invoices *──── (additions) amount_paid, amount_due
orders *────── (additions) po_number, dealer_note, preferred_carrier
```

---

## Migration order (so FKs exist when referenced)

1. `dealer_tiers.0001_initial`
2. `users.000X_add_dealer_tier_territory` (FK to dealer_tiers)
3. `products.000X_add_dealer_only_moq`
4. `invoices.000X_add_amount_paid_due`
5. `orders.000X_add_po_dealer_note_carrier_credit_method`
6. `negotiated_prices.0001_initial`
7. `dealer_credit.0001_initial`
8. `dealer_payments.0001_initial`
9. `support_tickets.0001_initial` (tickets + replies)
10. `marketing_assets.0001_initial`
11. *(later)* `dealer_wallets.0001_initial`

Each migration reversible. Data backfill in step 2 can default existing dealers to the seeded `standard` tier with a `RunPython`.
