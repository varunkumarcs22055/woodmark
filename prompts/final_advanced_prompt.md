# Final Advanced Prompt (May 2026)

## Role
You are a staff-level full-stack engineer. Build the missing systems and fix the gaps described below. Do not ask clarifying questions. Make reasonable defaults and proceed. Keep the existing stack and patterns.

## Read first (source of truth)
- docs/architecture.md
- docs/database-schema.md
- docs/product-listing-spec.md
- furnotech_ecommerce/PRODUCTION_READY.md
- furnotech_ecommerce/IMPROVEMENT.md
- furnotech_ecommerce/improvement.md
- furnotech_ecommerce/admin.md
- furnotech_ecommerce/dealer.md
- furnotech_ecommerce/normaluser.md
- furnotech_ecommerce/scheme.md

## Local diagnosis (verified)
- POST /api/shipping/estimate/ with pincode 110001 returns ok but message: "Standard rate (no zone match for this pincode)."
- GET /api/shipping/zones/admin/ returns count 0.
- GET /api/products/samir/eta/?qty=1&pincode=110001 returns fallback ETA with no zone.

Conclusion: pincode checks look broken because shipping zones are empty and the UI only shows fallback. Fix this end to end.

## P0 objectives (must deliver)

### 1) Cancel order time limit: 1 hour (user and dealer)
- Enforce in backend: self-service cancel is allowed only within 60 minutes of order creation time and only while order_status is CREATED or CONFIRMED.
- Keep admin override via admin status update, but self-service endpoint must reject after 1 hour.
- Return a clear 400 error message that includes remaining minutes or a fixed "Cancellation window expired" message.
- Update frontend (OrderDetailPage) to hide or disable "Cancel order" when the window is expired and show a clear reason.
- Apply equally for user and dealer flows (same endpoint, same UI).

### 2) Return flow: full working loop
- Ensure OrderReturn is fully wired end to end: create request, admin review, approve/reject, and refund record creation.
- Add admin UI in AdminOrders to show returns, status, and action buttons (approve, reject, mark received, refund).
- Add backend endpoints to list and mutate returns with proper permissions and audit logs.
- Ensure cancellations and returns are mutually exclusive (no double actions).
- Add email notification stubs for return status changes (reuse existing email config).

### 2b) Razorpay refund simulation + ready-to-integrate flow
- Implement refund flow that supports both simulated refunds (dev) and real Razorpay refunds (prod) using the same API surface.
- Add env vars for Razorpay refund integration and use them if present: RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET, RAZORPAY_WEBHOOK_SECRET.
- Create a refund service layer that:
  - In dev: returns a simulated refund id and marks refund status as SUCCESS.
  - In prod: calls Razorpay refund API with payment id, amount, and notes, then stores refund id + status.
- Update return approval path to trigger refund creation (full or partial) and store gateway response payload.
- Add an admin "Refund" action that is idempotent and safe (do not double-refund).
- Add webhook handling for refund status updates when real credentials are present.
- Ensure all refund records are visible in AdminOrders and linked to the original order and return request.

### 3) Pincode check: make it real
- Add seeded ShippingZone rows in seed_admin (or a dedicated seed command) with valid pincode prefixes.
- Validate ShippingZone input: pincode_prefix must be 2 to 6 digits, no blanks.
- Update ShippingZone admin UI to show validation errors clearly.
- Update shipping estimate UI to show explicit fallback message when no zone matches.
- Add a small set of default zones (Delhi, Mumbai, Bengaluru, etc) so local dev works.

### 4) High value orders (> 50000 INR): show wishlist to admin
- If order.total_amount >= 50000, surface a "High value" badge in AdminOrders list and drawer.
- Add admin API to fetch the order owner wishlist (products, timestamps). If order is guest, return empty.
- Show the wishlist in the order drawer with product images, names, and prices.
- Add "Contact customer" actions (mailto, tel, and a shortcut to the new SMS campaign composer).

### 5) Photo quality enforcement
- Enforce minimum image quality for product images and review photos.
- Server-side validation: reject uploads below a minimum size (example: 1000x1000) or too small file size (example: < 80 KB).
- Frontend: show upload guidance and warn before submit when images are low quality.
- Add an admin-only flag or warning badge on products with low-quality images.

### 6) Bulk SMS offers and contact outreach
- Build a bulk SMS system with a real data model, admin UI, and a sending pipeline that can handle 16k numbers.
- Contacts model: store normalized E.164 numbers, name (optional), tags, source, and status.
- Campaign model: message body, audience selection, status, counts, and error log.
- Delivery model: per-recipient status and provider response.
- Admin UI:
  - Import contacts: multi-line textarea and CSV upload.
  - Single add: one-by-one entry.
  - Compose campaign: choose segments (all, customers, dealers, manual list, wishlist owners, high value orders).
  - Send: queue and process in batches with progress.
- Provide strict input format (display on UI):
  - Preferred: +91XXXXXXXXXX (E.164)
  - Also accept: 10 digit numbers, auto-normalize to +91.
  - CSV columns: phone (required), name (optional), tag (optional)
- Provider integration:
  - Implement a provider interface with at least one real provider (Twilio/Msg91/Exotel). Choose one and wire via env vars.
  - If env vars are missing, log and mark as failed; do not silently succeed.
- Add basic rate limiting (batch size and delay) and retry for transient failures.

## P1 objectives (close remaining gaps)

### Admin gaps (from admin.md and IMPROVEMENT.md)
- Fix admin product edit modal data loss (description, weight, HSN, etc).
- Fix admin product delete action (currently no-op).
- Add negotiated pricing UI for dealer-specific price overrides.
- Add credit note processing for dealer returns (partial refunds to credit limit).
- Add audit log viewer page (search/filter).
- Add bulk product import/export (CSV) for inventory and price updates.
- Newsletter send should actually deliver (SMTP worker or synchronous send with error reporting).

### Dealer gaps (from dealer.md)
- Add dealer transaction ledger (wallet and credit history) and UI.
- Snapshot dealer GSTIN and billing info onto order at purchase time.
- Add dealer return request UI (if dealer uses same OrderDetailPage, make sure it is accessible).
- Add rule to exclude dealers from retail coupons when configured.

### Retail user gaps (from normaluser.md and IMPROVEMENT.md)
- Order confirmation email must actually deliver (real SMTP and failure visibility).
- Fix "My Orders" visibility race (orders missing after placement).
- Add review media uploads (images) with validation.
- Fix broken support links and add missing routes (/support, /contact-us, /faq) if still missing.
- Add stock alert signup for out-of-stock products (if not already working).

## Testing and acceptance
- Cancel order: succeeds within 60 minutes, fails after 60 minutes with clear message.
- Return request: creates return and appears in admin returns list; admin can approve and mark refunded.
- Pincode: /api/shipping/estimate returns a matched zone for known pincodes.
- High value order: admin drawer shows wishlist for order owner.
- SMS: import 16k numbers, create a campaign, queue, and send with visible progress and logs.
- Photo quality: low-res upload is rejected or flagged with a clear message.

## Implementation notes
- Reuse existing patterns for admin pages and API helpers.
- Ensure all new admin mutations write audit logs.
- Keep pagination for all list endpoints.
- Use transactions for multi-step mutations (send campaign, refund, etc).

End of prompt.
