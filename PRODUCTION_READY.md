# Production Readiness Checklist (FurniShop)

This is a practical, scoped checklist for production readiness. It focuses on missing or risky items found from the current codebase structure and common e-commerce needs.

---

## 1) Environment & Deployment
- Set `DEBUG=False` and ensure `SECRET_KEY` is set in environment.
- Configure `ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS`, and `CSRF_TRUSTED_ORIGINS` for your domain.
- Ensure `DATABASE_URL` points to the production DB and migrations are applied.
- Configure `FRONTEND_URL` for password reset links and notifications.
- Ensure `STATIC_ROOT` is collected and served (WhiteNoise is configured).
- Add a process manager (Render/Gunicorn/Procfile is already present).
- Configure persistent cache (Redis) for view caching and sessions if needed.

## 2) Database & Migrations
- Run all migrations on production (`users` currently shows a pending migration warning in dev logs).
- Enable database backups and point-in-time recovery.
- Add read replicas if traffic grows.

## 3) Security
- Enforce HTTPS, HSTS, secure cookies (already configured when `DEBUG=False`).
- Add rate limiting for auth endpoints (login, OTP, reset) to prevent abuse.
- Add audit logging for sensitive actions (some audit already exists).
- Harden admin routes behind role checks (in place) and IP allowlist (optional).

## 4) Monitoring & Observability
- Centralized logging (Sentry, Logtail, etc.).
- APM for slow queries and request tracing.
- Uptime monitoring on frontend + backend.
- Alerting for payment failures, ERP failures, and inventory issues.

## 5) Payments & Orders
- Razorpay keys and webhook verification configured.
- Automatic retries on payment verification if gateway is slow.
- Order cancellation workflow and refund status tracking.
- Invoice email sending reliability and queueing.

## 6) ERP Sync
- Background job/queue for ERP sync retries (Celery or RQ).
- Store ERP error messages on the order for admin visibility.
- Scheduled task to retry failed ERP syncs.

## 7) Performance
- CDN for images (Cloudinary configured, verify caching).
- Cache product list/detail responses in production (cache backend needed).
- DB indexes for filters used on home/shop (category, price, created_at).
- Use pagination for all list endpoints (already set globally).

## 8) User Features (Common Expectations)
- Address book (implemented).
- Order history and detail (implemented).
- Wishlist (implemented).
- Notifications inbox (implemented).
- Password reset (implemented) and in-session password change (implemented).
- Email/SMS preferences (framework added; wire to provider).

## 9) Dealer Features
- Dealer pricing (implemented).
- Dealer wallet/credit views (implemented).
- Dealer invoices / ledger export (optional but common).
- Dealer bulk reorder file upload (exists for orders; verify in UI).

## 10) Admin Features
- Product, inventory, orders, coupons, discounts, CMS (implemented).
- Reviews moderation (implemented).
- ERP status view (implemented).
- Admin-only notifications + approvals queue (optional).
- Export CSV for orders/products (common requirement).

## 11) Frontend UX
- Proper error boundaries in React (add global ErrorBoundary for white-screen prevention).
- Loading/skeletons for all lists (mostly present).
- Graceful empty states (mostly present).
- Accessibility: labels, focus states, keyboard navigation.

---

## Open Questions
- Do you want a full account preference system (email/SMS) wired to a provider now?
- Should returns/refunds be added, or is that out of scope?
- Should admin exports (orders/invoices) be prioritized?

---

## Quick Priorities (Recommended)
1) Production cache backend (Redis) + Celery for async tasks
2) Rate limiting and audit for auth endpoints
3) Finalize notifications/SMS/Email provider wiring
4) ERP retry scheduler + error visibility in admin
