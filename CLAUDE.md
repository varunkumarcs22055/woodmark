# FurniShop — Claude Code working rules

This file is read at the start of every Claude Code session in this repo.
Keep it tight — every line here is sent to the model on every turn.

## Token discipline (read first)

**Be terse.** No end-of-turn summaries, no "here's what changed" bullet lists,
no "Files created:" recaps. The user reads diffs themselves. State the result
in one sentence. Skip the victory lap.

**Edit > Write.** For changes under ~50 lines, use Edit (sends only the diff).
Reserve Write for new files or full rewrites.

**Don't re-read files.** If a file was read this session, work from memory or
read just the section you need (`offset` + `limit`).

**Don't verify trivially.** One compile/lint check at the end of a feature, not
after every edit. The user can refresh the browser themselves.

**Use Grep > Bash grep.** Use Edit > sed. Use Glob > find. The dedicated tools
have lower overhead.

## End-of-prompt protocol

When you finish executing a prompt file (e.g., `frontend_prompt5.md`):

1. State result in ONE sentence: "Frontend Prompt N complete. <key change>."
2. Tell the user: **"Run `/compact` before the next prompt."** Do not run it
   yourself; only the user can.
3. Do NOT enumerate every file you touched. Do NOT recap what was built.
4. If the next logical prompt is obvious, ask "Continue with Prompt N+1?" in
   one line. Do not preview its contents.

## Project facts (so you don't re-derive them)

- **Stack:** Django 5 + DRF backend, React 18 + Vite frontend, SQLite (dev) →
  Neon Postgres (prod planned)
- **Backend port:** 127.0.0.1:8000 — start with
  `cd backend && source venv/Scripts/activate && python manage.py runserver`
- **Frontend port:** 5173 (5174 if 5173 is busy) — start with
  `cd frontend && npm run dev`
- **Backend currently running?** Check with `curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8000/api/products/` — 200 = up, 000 = down.
- **Seed data slugs:** `sofas, tables, chairs, beds, storage, desks, dining-sets, outdoor` — use these EXACTLY in nav links and category filters
- **Cart storage key:** `furnishop_cart` in localStorage. Stored items are SLIM
  (no `description` field) per CartContext.slimProduct
- **JWT:** access token in `window.__accessToken` (memory), refresh token in
  `localStorage.furnishop_refresh_token`
- **Dev quick-login:** LoginPage has yellow panel (only visible when
  `import.meta.env.DEV`). 3 buttons: As User / As Dealer / As Admin. Synthesizes
  fake JWT, no backend needed.

## Architecture decisions (don't re-debate)

- **Single-interface dealer model.** Dealers shop on the public site `/`,
  backend serves dealer prices via JWT role. The Dealer Portal at
  `/dealer-dashboard/*` is an account hub only (Overview / Orders / Profile).
  **There is NO `DealerCatalog.jsx` and NO `DealerProductCard.jsx`** — they
  were deliberately removed. Don't recreate them.
- **Admin & Dealer dashboards are full-screen.** App.jsx hides global
  Navbar/Footer on `/admin-dashboard/*` and `/dealer-dashboard/*` via a
  `useLocation` check. Don't re-add the Navbar inside those routes.
- **Razorpay is opt-in.** `VITE_RAZORPAY_ENABLED=true` enables it. Default
  (unset) uses simulated `/api/payment/success/` so checkout flow works
  without Razorpay credentials.
- **Pricing is backend-driven.** Frontend reads `effective_price`,
  `discount_applied`, `discount_units_remaining` from API responses. Never
  compute discount % on the frontend.

## Status of prompt execution

Track in `prompts/STATUS.md` (TODO: maintain this). At a glance:

- **Frontend Prompts 1–7:** ✅ Built, all compile
- **Backend Prompts 1–8:** ❌ Not yet executed — most admin actions, auth,
  Razorpay, discount CRUD return 404
- **Enhancement Prompt:** Pending (Postgres + Cloudinary + GST + product gallery)

## Common pitfalls — already learned, don't repeat

- Don't write the full product object into CartContext — store only slim fields
  (`slimProduct` in CartContext.jsx) or you'll hit localStorage quota.
- Don't put announcement bars or fixed positioning inside dashboard routes —
  the dashboard sidebar is `position: sticky; top: 0; height: 100vh` and will
  collide with anything fixed.
- Don't use capitalized category values like `"Sofas"` in filter URLs — backend
  matches exact lowercase slugs (`"sofas"`).
- Don't try to verify dealer/admin features without first using the Dev Quick
  Login on `/login` — RoleRoute will bounce you back to `/` otherwise.
