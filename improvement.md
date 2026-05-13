# FurniShop Platform Improvements & Roadmap

This document outlines the identified functional gaps, UI/UX bugs, and architectural enhancements required to transition FurniShop from a "feature-complete" prototype to a FAANG-level production system.

## 🛠️ Critical Bug Fixes (Completed in this Audit)

### 1. Pricing Precedence & PDP Flicker
- **Issue**: Dealers sometimes see retail prices briefly on the Product Detail Page (PDP) before it resolves to their tier. Increasing quantity sometimes fails to trigger the next ladder rung in the UI.
- **Fix**: Harmonized client-side calculation to use backend `effective_price` as the baseline. Ensured quantity changes trigger re-validation of dealer-specific tiers.

### 2. Wallet & Credit Discrepancy
- **Issue**: The Wallet dashboard showed "Disabled" even when balance was available, and Checkout did not respect the `is_active` flag for B2B payment methods.
- **Fix**: Updated `CheckoutPage` to strictly check `is_active` for both Dealer Credit and Dealer Wallet. Updated `DealerWallet.jsx` to correctly reflect backend status.

---

## 📈 Roadmap: Functional Gaps

### 🛡️ Admin Portal (Governance & B2B)
- [ ] **Negotiated Prices UI**: Implement a grid in the Dealer Detail view to set per-product price overrides (Backend already supports `NegotiatedPrice` model).
- [ ] **Audit Logs Dashboard**: Add the missing "Audit Logs" sidebar item to view line-by-line admin activity (captured in the `audit` app).
- [ ] **Newsletter Execution**: Connect `AdminNewsletterSendView` to a real SMTP provider (SendGrid/Postmark) and a background worker (Celery/Redis) to process the `queued` campaigns.
- [ ] **Inventory Movement History**: Add a view to see every "In/Out" movement for a SKU across warehouses.

### 💼 Dealer Portal (B2B Efficiency)
- [ ] **Transaction Ledger**: Expand the Wallet view to include a paginated transaction history showing debits for specific Order IDs.
- [ ] **GST Snapshotting**: Ensure that when a dealer places an order, their current GSTIN and billing address are snapshotted into the Order record (Legal compliance).
- [ ] **Bulk Order CSV Export**: Allow dealers to export their order history as CSV for their own ERP reconciliation.

### 🛒 Normal User (B2C UX)
- [ ] **Instant Search (Typeahead)**: Add real-time suggestions and "Live Results" dropdown as the user types in the search bar.
- [ ] **Self-Service Returns**: Implement a "Request Return" button in the Order Detail view that creates a support ticket automatically.
- [ ] **Review Media**: Enable image uploads for product reviews to increase social proof.

---

## 🏗️ Technical Debt & Infrastructure
- [ ] **SMTP Integration**: Move from console-based email logging to a production SMTP queue.
- [ ] **Image Optimization**: Implement responsive images (`srcset`) using Cloudinary's dynamic resizing to improve PDP load times.
- [ ] **Error Boundary**: Add a global React Error Boundary to catch and report UI crashes gracefully.
- [ ] **Unit Testing**: Add Vitest/Jest suites for the `dealer_pricing` resolution logic to prevent regressions in discount stacking.

---

## 🎨 Aesthetic Polish
- [ ] **Skeleton Transitions**: Smoother transitions between skeleton states and real content on the Home Page.
- [ ] **Micro-animations**: Add subtle "Add to Cart" spring animations and success checkmarks.
- [ ] **Dark Mode Sync**: Ensure system-level dark mode preference is respected or provide a toggle.
