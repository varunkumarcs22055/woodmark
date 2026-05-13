# FurniShop Dealer Workflow Analysis

This document outlines the current state of the B2B Dealer Management system, highlighting what is functional and identifying gaps in the "Senior Level / FAANG Level" implementation requested.

## 🟢 What is WORKING (Production Ready)

### 1. Pricing Engine
- **Precedence Logic**: Backend correctly resolves prices in the order: `NegotiatedPrice` (Override) > `DealerTier` + `Quantity-Ladder` (Multiplicative).
- **Tiered Discounts**: Admin can assign `DealerTiers` (Standard/Premium/Platinum) which apply a base % discount on MRP.
- **Ladder Pricing**: Quantity-based volume discounts are correctly fetched and applied.
- **Cart Integration**: Cart re-fetches effective prices when quantities change, ensuring dealers always see accurate B2B rates.

### 2. Financial Management
- **Credit Limits**: Dealers have an assigned credit limit; orders can be placed "On Credit" if the limit is sufficient.
- **Wallet System**: Dealers can maintain a prepaid wallet balance for instant payments.
- **Admin Control**: Admins can adjust credit limits, toggle credit status, and top up dealer wallets.

### 3. Order Operations
- **Bulk Upload**: Dealers can upload a CSV with SKUs and Quantities to place large consolidated orders.
- **Payment Methods**: specialized B2B options (Dealer Credit, Wallet) are integrated into the checkout flow.
- **Backorders**: Line-item support for backordering items that exceed current stock.

---

## 🔴 What is MISSING / NOT WORKING (The Gaps)

### 1. Admin UI Gaps
- **Negotiated Price UI**: While the database models exist for specific per-product price overrides for specific dealers, there is **no User Interface** in the Admin Dashboard to manage these. They must be set via Django Admin or direct DB access.
- **Detailed Audit Log UI**: We have the `write_audit` mixin, but there is no frontend view for Admins to see "Who changed Dealer X's credit limit and when?".

### 2. Communication & Marketing (The "Skeleton" Phase)
- **Newsletter SMTP**: The "Send Newsletter" functionality creates a `queued` campaign in the database but **does not actually send emails**. SMTP integration (e.g., SendGrid, Mailgun) is missing.
- **Order Notifications**: Order confirmation emails are using a basic `send_mail` template with `fail_silently=True`. There is no rich HTML email template system or production-ready mail server configuration.

### 3. Financial Integrity & Compliance
- **GST Snapshotting**: The `Order` model does NOT store the Dealer's GSTIN at the time of purchase. It fetches it from the Profile. If a dealer changes their GSTIN next year, historical orders will incorrectly show the new GSTIN on generated invoices.
- **Transaction Ledger UI**: Dealers can see their current balance, but they **cannot see a historical ledger** (a line-by-line list of all debits/credits to their wallet or credit limit).
- **Credit Notes / Returns UI**: The `OrderReturn` model exists on the backend, but there is **no UI** in the Dealer Portal for a dealer to request a return or for an Admin to issue a Credit Note.

### 4. Technical Gaps
- **Coupon Exclusion**: Dealers can currently stack store-wide coupons on top of their tiered B2B discounts. There is no flag to "Exclude Dealers" from specific retail coupons.
- **N+1 Optimization in Detail Views**: While List Views are optimized, some detail views still perform individual queries for pricing resolution instead of using prefetched data.

---

## 🛠️ Recommended Roadmap to "FAANG Level"
1. **SMTP Integration**: Connect to a real mail service and implement a worker (Celery) to handle the newsletter queue.
2. **Ledger System**: Create a `DealerTransaction` table to log every change to Wallet/Credit and expose this as a "Statement" in the portal.
3. **Admin Negotiated Prices**: Build a grid UI where Admins can search for a Product + Dealer and set a fixed price.
4. **GST Persistence**: Add a `billing_gstin` field to the `Order` model to snapshot the tax ID at order time.
