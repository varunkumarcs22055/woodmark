# FurniShop — Engineering & Product Documentation

> **Version:** 1.0 (MVP) → 2.0 (Production Target)
> **Last Updated:** 2026-04-28
> **Stack:** Django 5.1 + React 18.3 + PostgreSQL (Neon)
> **Maintainer:** FurniShop Engineering

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Overview](#2-architecture-overview)
3. [Tech Stack](#3-tech-stack)
4. [User Roles & Permissions](#4-user-roles--permissions)
5. [Feature Specifications](#5-feature-specifications)
   - [5.1 Authentication](#51-authentication)
   - [5.2 Product Management](#52-product-management)
   - [5.3 Discount System](#53-discount-system)
   - [5.4 Cart](#54-cart)
   - [5.5 Orders](#55-orders)
   - [5.6 Payments — Razorpay](#56-payments--razorpay)
   - [5.7 ERP Integration](#57-erp-integration)
   - [5.8 Admin Dashboard](#58-admin-dashboard)
   - [5.9 Dealer Dashboard](#59-dealer-dashboard)
6. [Database Schema](#6-database-schema)
7. [API Reference](#7-api-reference)
8. [Frontend Component Architecture](#8-frontend-component-architecture)
9. [Navbar ↔ Product Connection](#9-navbar--product-connection)
10. [Discount System Design (Deep-Dive)](#10-discount-system-design-deep-dive)
11. [Testing Strategy](#11-testing-strategy)
12. [Environment Setup](#12-environment-setup)
13. [Deployment Guide](#13-deployment-guide)
14. [Roadmap](#14-roadmap)

---

## 1. Project Overview

FurniShop is a production-grade furniture e-commerce platform for the Indian market. It operates as both a **B2C** storefront (regular consumers) and a **B2B** channel (institutional/commercial dealers), while an internal **Admin** team manages the entire catalog, pricing, discounts, and fulfillment from a unified panel.

The product experience draws from the best of Amazon's depth — rich product pages, category filters, search, order tracking — with a premium visual style inspired by Featherlite and Livspace: hero carousels, mega-menu navigation, curated collection banners, and a clean typographic identity.

### Business Context

Three distinct audiences are served by a single platform:

| Role | Description | Key Privilege |
|------|-------------|---------------|
| **Admin** | Internal FurniShop staff | Full CRUD on catalog, discounts, orders, ERP |
| **Dealer** | B2B buyer (institutional, commercial) | Exclusive dealer-price tier, count-limited bulk discounts |
| **User (Customer)** | B2C buyer | Standard shopping + user-specific discounts |

### Current Maturity

| Phase | Status |
|-------|--------|
| Product catalog (list, filter, search, detail) | **Complete** |
| Session-based shopping cart | **Complete** |
| Guest checkout (no account required) | **Complete** |
| Simulated payment flow | **Complete** |
| ERP integration (graceful fallback) | **Complete** |
| Authentication (JWT + Google OAuth) | **Planned — Phase 2** |
| Role-based access (Admin / Dealer / User) | **Planned — Phase 2** |
| Real Razorpay payment gateway | **Planned — Phase 2** |
| Per-product count-limited discount engine | **Planned — Phase 2** |
| Custom Admin & Dealer dashboards | **Planned — Phase 2** |
| Automated test suite | **Planned — Phase 2** |

---

## 2. Architecture Overview

### 2.1 System Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        Browser (User)                        │
│              React 18 SPA — Vite build output                │
└─────────────────────────┬────────────────────────────────────┘
                          │ HTTP (Axios /api/*)
                          │
         [Dev]  Vite proxy (:5173 → :8000)
         [Prod] Direct HTTPS to backend domain
                          │
┌─────────────────────────▼────────────────────────────────────┐
│               Django 5.1 + DRF (Gunicorn)                    │
│                                                              │
│  /admin/           → Django Admin Panel                      │
│  /api/products/    → products app                            │
│  /api/cart/        → cart app (session-based)                │
│  /api/orders/      → orders app                              │
│  /api/payment/     → payments app                            │
│  /api/auth/        → users app [planned]                     │
│  /api/discounts/   → discounts app [planned]                 │
│                                                              │
└────┬──────────────┬────────────────┬────────────────┬────────┘
     │              │                │                │
     ▼              ▼                ▼                ▼
PostgreSQL      Razorpay         External ERP    Google OAuth
(Neon Cloud)    (Payment GW)     (Order Sync)    (Social Auth)
```

### 2.2 Frontend Architecture

The React SPA lives entirely in `frontend/src/`. Key structural decisions:

- **Entry point:** `main.jsx` wraps the entire app in `<CartProvider>` and `<BrowserRouter>`
- **API layer:** All HTTP calls go through `frontend/src/api/index.js` (Axios instance with `/api` base URL)
- **State:** Cart state is managed in `CartContext` via `useReducer`. No Redux — the app scope does not warrant it.
- **Routing:** `react-router-dom v6` with `<Routes>` in `App.jsx`. Future auth-protected routes will use a `<ProtectedRoute>` wrapper.
- **Styling:** Vanilla CSS per-component (`ComponentName.css`) imported in each component file. No CSS framework.

### 2.3 Backend Architecture

Django follows an **app-per-domain** pattern — each business domain is a self-contained app:

| App | Responsibility |
|-----|---------------|
| `products` | Catalog: Category & Product CRUD, listing, filters, search |
| `cart` | Session-based cart operations (no database model) |
| `orders` | Order creation, stock decrement, order history |
| `payments` | Payment record, Razorpay integration, ERP trigger |
| `users` | Custom User model, auth, roles |
| `discounts` | Per-product, per-role, count-limited discounts **[planned]** |
| `services/erp.py` | Stateless function — sends order JSON to external ERP |

All apps register their URLs in `core/urls.py`. Cross-cutting configuration lives in `core/settings.py`.

### 2.4 Order Placement — End-to-End Data Flow

```
1. User fills cart (CartContext + localStorage)
2. User fills checkout form (name, email, phone, address)
3. Frontend: POST /api/orders/create/
   → Django validates stock for each item
   → Creates Order record (status: CREATED)
   → Creates OrderItem records (price snapshot)
   → Decrements product.stock for each item
   → Returns { order_id: "ORD-XXXXXXXX" }
4. Frontend: POST /api/payment/success/  [simulated]
   OR
   Frontend: POST /api/payment/create-razorpay-order/ [production]
   → Razorpay modal opens in browser
   → User completes payment on Razorpay UI
   → Frontend receives { razorpay_payment_id, razorpay_signature }
   → Frontend: POST /api/payment/verify/
5. Django verifies Razorpay signature
   → Creates Payment record (status: SUCCESS)
   → Updates Order.payment_status = SUCCESS
   → Updates Order.order_status = CONFIRMED
6. Django calls send_order_to_erp(order) synchronously
   → ERP returns erp_order_id
   → Stored on Order.erp_order_id
7. Response returned to frontend
   → Frontend clears cart (CartContext.clearCart())
   → Success screen displayed with order_id and erp_order_id
```

### 2.5 Cart Architecture — Dual Layer

The cart uses a deliberately **frontend-primary** design:

| Layer | Implementation | Persistence |
|-------|---------------|-------------|
| Primary | `CartContext` + `useReducer` | `localStorage` key: `furnishop_cart` |
| Secondary | Django session cart (backend) | Server-side session DB |

The frontend cart is the single source of truth for all UI rendering. The backend `/api/cart/*` endpoints exist for future mobile app compatibility and server-side cart merging on login. The frontend does not currently read from the backend cart for UI purposes.

---

## 3. Tech Stack

### 3.1 Backend

| Package | Version | Purpose | Rationale |
|---------|---------|---------|-----------|
| Django | `>=5.1,<6.0` | Web framework, ORM, admin panel | Mature, batteries-included; Django Admin handles initial product management |
| djangorestframework | `>=3.15,<4.0` | REST API (serializers, views, pagination) | Industry-standard DRF; integrates seamlessly with django-filter |
| django-cors-headers | `>=4.3,<5.0` | CORS middleware for React origin | Required for cross-origin Axios requests from Vite dev server |
| django-filter | `>=24.0,<25.0` | Declarative FilterSet on product listing | Clean, testable filter logic without manual query-param parsing |
| psycopg2-binary | `>=2.9,<3.0` | PostgreSQL adapter | Neon uses PostgreSQL; binary wheel avoids compile-time deps |
| dj-database-url | `>=2.1,<3.0` | Parse `DATABASE_URL` env var | Standard Heroku/Neon URL format; enables SQLite fallback in dev |
| python-dotenv | `>=1.0,<2.0` | Load `.env` in development | Keeps all secrets out of `settings.py` |
| requests | `>=2.31,<3.0` | HTTP client for ERP calls | Used in `services/erp.py` for POST to external ERP |
| gunicorn | `>=22.0,<23.0` | WSGI production server | Standard Django production server; Railway/Render compatible |
| razorpay | `>=1.4` | Razorpay Python SDK **[planned]** | Signature verification, order creation |
| djangorestframework-simplejwt | `latest` | JWT access + refresh tokens **[planned]** | Stateless auth; enables multi-device, mobile-ready auth |
| social-auth-app-django | `latest` | Google OAuth2 **[planned]** | Handles OAuth2 code exchange, user creation, role mapping |

### 3.2 Frontend

| Package | Version | Purpose | Notes |
|---------|---------|---------|-------|
| React | `18.3.x` | UI rendering | Concurrent features, hooks-first |
| react-dom | `18.3.x` | DOM renderer | Required peer |
| Vite | `5.4.x` | Build tool + dev server | Fast HMR; `/api` proxy configured to `:8000` |
| react-router-dom | `6.x` | Client-side routing | `useSearchParams` for URL-synced filter state |
| axios | `latest` | HTTP client | 15s timeout, `baseURL: '/api'`, future JWT interceptors |
| swiper | `^12.1.3` | Hero carousel, product sliders | Touch-ready; `Autoplay`, `Pagination`, `EffectFade` modules used |
| react-hot-toast | `latest` | Toast notifications | Cart feedback, order confirmation messages |
| react-icons | `latest` | Icon set (Feather icons: `fi`) | Consistent iconography throughout Navbar, pages |

### 3.3 Infrastructure

| Layer | Service | Notes |
|-------|---------|-------|
| Database | [Neon](https://neon.tech) (PostgreSQL) | Serverless; auto-scales; connect string via `DATABASE_URL` |
| Backend Hosting | Railway or Render | Gunicorn WSGI; `PORT` env var from platform |
| Frontend Hosting | Vercel or Netlify | Static Vite build; `dist/` directory |
| Payment Gateway | Razorpay | Indian rupee; UPI, cards, net banking |
| External ERP | Customer-provided | REST API endpoint + Bearer token |
| OAuth Provider | Google | `social-auth-app-django` handles code exchange |

---

## 4. User Roles & Permissions

### 4.1 Role Definitions

**Admin** is a FurniShop internal staff member with unrestricted access. Admins manage the entire product catalog, configure discounts for both user and dealer tiers, view and update all orders, manage ERP synchronization, and can approve dealer account applications. Admins access either the Django admin panel (current) or the custom React admin dashboard (planned).

**Dealer** is a B2B institutional buyer — interior designers, hospitality companies, office spaces. Dealers receive an exclusive pricing tier (dealer discount) separate from the standard user discount. The admin controls how many units each dealer can purchase at the discounted price. Dealers must be approved by an Admin before their discount tier activates.

**User (Customer)** is a standard B2C buyer. Users may receive product-specific discounts configured by the admin. The discount applies up to a configured unit count — after which the standard price applies. Users can register via email/password or Google OAuth.

### 4.2 Capability Matrix

| Capability | Admin | Dealer | User |
|------------|:-----:|:------:|:----:|
| Browse product catalog | Yes | Yes | Yes |
| Search and filter products | Yes | Yes | Yes |
| View standard product price | Yes | Yes | Yes |
| View user-tier discounted price | — | No | Yes |
| View dealer-tier discounted price | — | Yes | No |
| See discount unit count remaining | — | Yes | Yes |
| Add items to cart | Yes | Yes | Yes |
| Checkout and place order | Yes | Yes | Yes |
| View own order history | Yes | Yes | Yes |
| **Product Management** | | | |
| Create / edit / delete products | Yes | No | No |
| Upload product images | Yes | No | No |
| Manage product categories | Yes | No | No |
| Manage product stock | Yes | No | No |
| **Discount Management** | | | |
| Create user discounts | Yes | No | No |
| Create dealer discounts | Yes | No | No |
| Set discount count limits | Yes | No | No |
| Deactivate or delete discounts | Yes | No | No |
| **Order Management** | | | |
| View all orders (all users) | Yes | No | No |
| Update order status | Yes | No | No |
| Cancel any order | Yes | No | No |
| **ERP** | | | |
| View ERP sync status per order | Yes | No | No |
| Retry failed ERP syncs | Yes | No | No |
| **Access** | | | |
| `/admin` (Django admin) | Yes | No | No |
| `/admin-dashboard` (custom React) | Yes | No | No |
| `/dealer-dashboard` | No | Yes | No |
| `/account` (user account) | No | No | Yes |

### 4.3 Role Assignment

Roles are stored on the `User` model as a `role` field with choices: `user` (default), `dealer`, `admin`.

- **Admin:** Django superuser flag (`is_superuser=True`) OR `role='admin'` on the `User` model.
- **Dealer:** `role='dealer'` + `dealer_status='active'`. Dealer registration sets `dealer_status='pending'`; an Admin must approve it before dealer pricing is shown.
- **User:** Default on registration. `role='user'`, no approval required.

### 4.4 JWT Claims Structure

After login (email/password or OAuth), the backend issues a JWT pair. The access token payload:

```json
{
  "user_id": 42,
  "email": "dealer@acmefurniture.com",
  "role": "dealer",
  "dealer_status": "active",
  "exp": 1756000000,
  "iat": 1755913600
}
```

The frontend reads `role` from the decoded access token to show/hide role-specific UI elements (dealer pricing, admin controls). The role is also verified on the backend for every protected API call.

---

## 5. Feature Specifications

### 5.1 Authentication

#### 5.1.1 Sign Up (Email / Password)

**Endpoint:** `POST /api/auth/register/`

**Request body:**
```json
{
  "full_name": "Priya Sharma",
  "email": "priya@example.com",
  "password": "SecurePass@123",
  "confirm_password": "SecurePass@123",
  "role": "user"
}
```

**Validation rules:**
- Email must be unique
- Password minimum 8 characters
- `password` must match `confirm_password`
- `role` can only be `user` on self-registration. Dealers submit a separate dealer application form; admins are created by superusers only.

**On success:**
- Creates `User` record with `role=user`
- Returns JWT access token (15-min expiry) + refresh token (7-day expiry)

#### 5.1.2 Login

**Endpoint:** `POST /api/auth/login/`

**Request body:**
```json
{
  "email": "priya@example.com",
  "password": "SecurePass@123"
}
```

**Response:**
```json
{
  "access": "<jwt-access-token>",
  "refresh": "<jwt-refresh-token>",
  "user": {
    "id": 42,
    "email": "priya@example.com",
    "full_name": "Priya Sharma",
    "role": "user"
  }
}
```

**Token storage strategy:**
- `access` token: stored in JavaScript memory (not localStorage) to mitigate XSS
- `refresh` token: stored in `localStorage` under key `furnishop_refresh_token`
- On page load: frontend attempts to refresh the access token silently using the stored refresh token

#### 5.1.3 Token Refresh

**Endpoint:** `POST /api/auth/token/refresh/`

**Request body:**
```json
{ "refresh": "<jwt-refresh-token>" }
```

**Response:**
```json
{ "access": "<new-jwt-access-token>" }
```

This endpoint is called automatically by an Axios interceptor when any API call returns `401 Unauthorized`.

#### 5.1.4 Google OAuth

**Flow:**

1. User clicks "Login with Google" button on the frontend
2. Frontend redirects to `GET /api/auth/google/` → Django backend initiates OAuth2 code-request flow via `social-auth-app-django`
3. Browser redirects to Google consent screen
4. Google redirects to `GET /api/auth/google/callback/?code=<code>` with the authorization code
5. Backend exchanges the code for a Google access token, fetches the user's profile (email, name)
6. Backend creates or retrieves a `User` record (email as unique identifier)
7. If new user: `role` defaults to `user`; if existing user: keeps current role
8. Backend issues JWT pair and redirects to the frontend with tokens as query params: `https://furnishop.com/auth-callback?access=<token>&refresh=<token>`
9. Frontend `AuthCallbackPage` reads the tokens from URL, stores them, and redirects to home

**Required environment variables:** `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`

#### 5.1.5 Logout

- Frontend clears `furnishop_refresh_token` from localStorage
- Frontend sets in-memory access token to `null`
- Optionally: `POST /api/auth/logout/` with refresh token to blacklist it (requires SimpleJWT token blacklist)

#### 5.1.6 Dealer Application Workflow

1. Dealer visits `/dealer-apply` and submits a form (business name, GST number, phone, email, expected monthly order volume)
2. `POST /api/auth/dealer-apply/` creates a `User` with `role='dealer'` and `dealer_status='pending'`
3. Admin sees pending applications in the Admin Dashboard under "Dealer Management"
4. Admin clicks "Approve" → `dealer_status='active'` → dealer can now see dealer pricing
5. Admin clicks "Reject" → `dealer_status='rejected'` → notification sent to applicant email

---

### 5.2 Product Management

#### 5.2.1 Product Listing

- Endpoint: `GET /api/products/`
- Pagination: 12 items per page (`PageNumberPagination`)
- Filters via `ProductFilter` FilterSet:

| Filter param | Field | Lookup | Example |
|-------------|-------|--------|---------|
| `category` | `category__slug` | `exact` | `?category=sofas` |
| `price_min` | `price` | `gte` | `?price_min=5000` |
| `price_max` | `price` | `lte` | `?price_max=30000` |
| `material` | `material` | `exact` | `?material=wood` |

- Search (via DRF `SearchFilter`): `?search=velvet sofa` — searches `name` and `description`
- Ordering: `?ordering=price` (asc), `?ordering=-price` (desc), `?ordering=-created_at` (newest)
- Default ordering: `-created_at` (newest first)

#### 5.2.2 Product Detail

- Endpoint: `GET /api/products/{slug}/`
- Returns full product with nested `category` object
- Lookup field: `slug` (SEO-friendly, avoids exposing DB primary keys)

#### 5.2.3 Similar Products

- Endpoint: `GET /api/products/similar/{id}/`
- Returns up to 4 products from the same category, excluding the requested product
- Ordered by `-created_at`

#### 5.2.4 Product CRUD (Admin)

Admin can create, edit, and delete products via:
1. **Django Admin panel** (`/admin/products/product/`) — available now
2. **Custom Admin Dashboard API** (`/api/admin/products/`) — planned Phase 2

**Product fields:**

| Field | Type | Validation | Notes |
|-------|------|-----------|-------|
| `name` | CharField(200) | Required | Slug auto-generated on save |
| `description` | TextField | Required | Full product description |
| `price` | DecimalField(10,2) | Required, > 0 | Indian Rupees |
| `category` | ForeignKey → Category | Required | Dropdown in admin |
| `material` | CharField, choices | Required | `wood`, `metal`, `fabric`, `leather`, `glass`, `plastic`, `marble`, `rattan` |
| `color` | CharField(50) | Required | Display color name |
| `dimensions` | CharField(100) | Required | e.g., `"220x85x80 cm"` |
| `image_url` | URLField(500) | Required | External image URL (see 5.2.5) |
| `stock` | PositiveIntegerField | Default: 0 | Decremented on order |

#### 5.2.5 Image Upload Strategy

**Current (MVP):** `image_url` stores an external URL (e.g., Unsplash CDN). Fast for development; zero storage cost.

**Planned (Phase 2):** Replace `image_url` (URLField) with `image` (ImageField) pointing to cloud storage:
1. Add `Pillow` to `requirements.txt`
2. Change `image_url = URLField(...)` to `image = models.ImageField(upload_to='products/')`
3. Configure `DEFAULT_FILE_STORAGE` to use `django-storages` with AWS S3 or Cloudinary
4. Set `MEDIA_URL` and `MEDIA_ROOT`
5. Write a data migration to preserve existing `image_url` data

Migration path must be backward-compatible — keep `image_url` as a nullable fallback during transition.

#### 5.2.6 Stock Management

- `Product.stock` (PositiveIntegerField) tracks available inventory
- Stock is validated in `OrderCreateSerializer.validate_items()` before order creation
- Stock is decremented atomically at order creation (`product.stock = F('stock') - quantity`)
- If an order is cancelled, stock should be restored (signal or service function — Phase 2)
- Admin can set/adjust stock directly from the Admin panel

---

### 5.3 Discount System

The discount engine allows the Admin to configure two independent discount tiers per product — one for regular users and one for dealers — each with an optional unit count limit.

#### 5.3.1 Discount Types

| Type | Applied To | Typical Value |
|------|-----------|--------------|
| **User Discount** | Regular customers (`role='user'`) | 10–25% off |
| **Dealer Discount** | B2B dealers (`role='dealer'`) | 20–40% off |

Both discount types are **independent** and can coexist on the same product simultaneously.

#### 5.3.2 Discount Modes

| Mode | Field Value | Example |
|------|------------|---------|
| Percentage | `'percent'` | `value=15` → 15% off |
| Flat Amount | `'flat'` | `value=2000` → ₹2,000 off |

#### 5.3.3 Count Limit

Each discount can have a `count_limit` — the maximum number of units that can be purchased at the discounted price across all buyers in that tier.

**Example:** Dealer discount for "Oslo Velvet Sofa": 25% off on first 100 units. Once 100 units have been ordered at the discounted price, the full price applies for subsequent orders.

`count_limit = NULL` means the discount is unlimited (no cap).

#### 5.3.4 Admin Discount Panel — UI Specification

The discount management panel lives in the Admin Dashboard at route `/admin-dashboard/discounts`.

**Layout:**

```
┌─────────────────────────────────────────────────────────────┐
│  Discount Manager                                           │
│  ─────────────────────────────────────────────────────────  │
│  [User Discounts]  [Dealer Discounts]   ← tabs             │
│                                                             │
│  Add Discount:                                              │
│  Product: [ Search or select product ▼ ] (combobox)        │
│  Mode:    (●) Percent (%) ○ Flat Amount (₹)                │
│  Value:   [ 15       ]                                      │
│  Count Limit: [ 100  ]  (leave blank for unlimited)        │
│  Active From: [ 2026-05-01 ]  Until: [ 2026-12-31 ]        │
│                                     [ Save Discount ]       │
│  ─────────────────────────────────────────────────────────  │
│  Active Discounts:                                          │
│  Product         Mode   Value   Limit  Used  Left  Expires │
│  Oslo Velvet...  %      15      100    23    77    Dec 31  │
│  Nordic Bed...   ₹      3000    50     50    0     —       │
│                                         [Edit] [Delete]    │
└─────────────────────────────────────────────────────────────┘
```

**Product combobox:** Searchable dropdown. Typing triggers `GET /api/products/?search=<query>` and shows matching products with current price. Supports keyboard navigation.

---

### 5.4 Cart

#### 5.4.1 Guest Cart (Current)

The cart is managed entirely in the browser via `CartContext` (`frontend/src/context/CartContext.jsx`):

```javascript
// State shape
cartItems = [
  {
    product: { id, name, slug, price, image_url, stock, ... },
    quantity: 2
  }
]
```

Persisted to `localStorage` key `furnishop_cart`. Survives page refresh. Cleared on order success via `clearCart()`.

#### 5.4.2 Logged-in Cart (Planned — Phase 2)

On login, the frontend merges the localStorage cart with the server-side session cart:
1. Fetch server cart: `GET /api/cart/`
2. For each item in localStorage cart: `POST /api/cart/add/` if not already on server
3. Replace localStorage cart with the merged server cart
4. All subsequent cart operations go to both localStorage (for instant UI) and the backend

This enables cross-device cart persistence.

#### 5.4.3 Cart Operations

| Action | CartContext Reducer | Backend (session) |
|--------|--------------------|--------------------|
| Add item | `ADD_ITEM` — merges quantity if product exists | `POST /api/cart/add/` |
| Remove item | `REMOVE_ITEM` | `POST /api/cart/remove/` |
| Update quantity | `UPDATE_QUANTITY` — removes if qty ≤ 0 | (no dedicated endpoint; remove + add) |
| Clear cart | `CLEAR_CART` | `POST /api/cart/clear/` |

#### 5.4.4 Cart Constraints

- Quantity cannot exceed `product.stock`
- Out-of-stock products (`stock = 0`) cannot be added; "Out of Stock" badge shown in place of "Add to Cart"
- After discount system is live, `cartTotal` must use `effective_price` (from API) rather than raw `product.price`

#### 5.4.5 Cart Price Calculation

**Current (without discounts):**
```javascript
const cartTotal = cartItems.reduce(
  (sum, item) => sum + parseFloat(item.product.price) * item.quantity,
  0
);
```

**Phase 2 (with discounts):** The product objects in the cart will include `effective_price` from the API. `cartTotal` becomes:
```javascript
const cartTotal = cartItems.reduce(
  (sum, item) => sum + parseFloat(item.product.effective_price ?? item.product.price) * item.quantity,
  0
);
```

---

### 5.5 Orders

#### 5.5.1 Order Creation

**Endpoint:** `POST /api/orders/create/`

**Request body:**
```json
{
  "user_name": "Priya Sharma",
  "user_email": "priya@example.com",
  "phone": "9876543210",
  "address": "12, Koramangala 4th Block, Bengaluru, Karnataka - 560034",
  "items": [
    { "product_id": 7, "quantity": 1 },
    { "product_id": 12, "quantity": 2 }
  ]
}
```

**Server-side processing:**
1. Validate all `product_id` values exist
2. Validate `quantity ≤ product.stock` for each item
3. Calculate `total_amount = Σ (product.price × quantity)`
4. Create `Order` record (auto-generate `order_id`)
5. Create `OrderItem` records (price snapshot at order time)
6. Decrement `product.stock` for each item via `F()` expression
7. Return the full order object

**Response:**
```json
{
  "id": 88,
  "order_id": "ORD-A3F2B91C",
  "user_name": "Priya Sharma",
  "user_email": "priya@example.com",
  "phone": "9876543210",
  "address": "12, Koramangala 4th Block, Bengaluru, Karnataka - 560034",
  "total_amount": "75998.00",
  "payment_status": "PENDING",
  "order_status": "CREATED",
  "erp_order_id": null,
  "created_at": "2026-04-28T10:30:00+05:30",
  "items": [
    {
      "product_name": "Oslo Velvet Sofa",
      "product_id": 7,
      "quantity": 1,
      "price": "45999.00",
      "subtotal": "45999.00"
    },
    {
      "product_name": "Nordic Dining Chair",
      "product_id": 12,
      "quantity": 2,
      "price": "14999.50",
      "subtotal": "29999.00"
    }
  ]
}
```

#### 5.5.2 Order ID Format

Auto-generated on `Order.save()` if `order_id` is not set:

```python
self.order_id = f'ORD-{uuid.uuid4().hex[:8].upper()}'
# Example: ORD-A3F2B91C
```

8 uppercase hex characters → 16^8 = 4.3 billion possible IDs. Unique constraint enforced at DB level.

#### 5.5.3 Order Status Lifecycle

```
CREATED ──────────────────────────────────────────────────┐
   │                                                       │
   │ Payment SUCCESS (POST /api/payment/verify/)           │
   ▼                                                       │
CONFIRMED                                                  │
   │                                                       │
   │ Admin action (PATCH /api/orders/{id}/status/)         │
   ▼                                                       │
SHIPPED                                                    │
   │                                                       │
   │ Admin action                                          │
   ▼                                                       │
DELIVERED                                                  │
                                                           │
   (from any state, Admin or payment failure)              │
   ▼                                                       │
CANCELLED ◄────────────────────────────────────────────────┘
```

#### 5.5.4 Order Lookup

| Scenario | Endpoint | Auth |
|----------|---------|------|
| Guest order lookup | `GET /api/orders/?email=priya@example.com` | None |
| Logged-in user's orders | `GET /api/orders/` (with JWT) | User |
| Admin: all orders | `GET /api/orders/all/` | Admin |

#### 5.5.5 Order Admin Panel

Django Admin is configured with:
- `list_display`: order_id, user_name, user_email, total_amount, payment_status, order_status, erp_order_id, created_at
- `list_editable`: order_status (quick update from list view)
- `OrderItemInline`: shows all items within the order detail view
- `search_fields`: order_id, user_email, user_name
- `list_filter`: payment_status, order_status

---

### 5.6 Payments — Razorpay

#### 5.6.1 Current Behavior (Simulated)

`POST /api/payment/success/` accepts `{ "order_id": "ORD-XXXXXXXX" }`, immediately marks the order as paid, and triggers ERP sync. **No real money is involved.** This is the current MVP behavior.

#### 5.6.2 Real Razorpay Flow (Phase 2)

**Step 1 — Create Razorpay Order (backend)**

```
POST /api/payment/create-razorpay-order/
Authorization: Bearer <jwt-token>
Body: { "order_id": "ORD-XXXXXXXX" }
```

Backend:
```python
import razorpay
client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))
razorpay_order = client.order.create({
    "amount": int(order.total_amount * 100),  # paise
    "currency": "INR",
    "receipt": order.order_id,
    "notes": {"customer_email": order.user_email}
})
```

Response:
```json
{
  "razorpay_order_id": "order_PQRstuVWXYZ123",
  "amount": 4599900,
  "currency": "INR",
  "key_id": "rzp_test_XXXXXXXXXXX"
}
```

**Step 2 — Frontend Opens Razorpay Modal**

```javascript
const options = {
  key: data.key_id,
  amount: data.amount,
  currency: data.currency,
  name: "FurniShop",
  description: `Order ${orderId}`,
  order_id: data.razorpay_order_id,
  handler: function (response) {
    verifyPayment({
      razorpay_order_id: response.razorpay_order_id,
      razorpay_payment_id: response.razorpay_payment_id,
      razorpay_signature: response.razorpay_signature,
      order_id: orderId
    });
  },
  prefill: {
    name: formData.user_name,
    email: formData.user_email,
    contact: formData.phone
  },
  theme: { color: "#00736A" }
};
const rzp = new window.Razorpay(options);
rzp.open();
```

**Step 3 — Backend Verifies Signature**

```
POST /api/payment/verify/
Body: {
  "razorpay_order_id": "order_PQRstuVWXYZ123",
  "razorpay_payment_id": "pay_ABCdefGHI456",
  "razorpay_signature": "<hmac-sha256-signature>",
  "order_id": "ORD-XXXXXXXX"
}
```

Backend:
```python
client.utility.verify_payment_signature({
    'razorpay_order_id': razorpay_order_id,
    'razorpay_payment_id': razorpay_payment_id,
    'razorpay_signature': razorpay_signature,
})
# On success: update Payment, update Order, trigger ERP
```

**Step 4 — Webhook (Production Hardening)**

Razorpay sends `payment.captured` events to `POST /api/payment/webhook/`. This serves as a safety net if the frontend callback fails (network drop, browser close).

Backend webhook handler:
1. Read `X-Razorpay-Signature` header
2. Verify HMAC-SHA256 signature using `RAZORPAY_WEBHOOK_SECRET`
3. Extract `order_id` from payload
4. If not already `SUCCESS`: update Payment, Order, trigger ERP

**Required Razorpay Dashboard setup:**
- Register webhook URL: `https://api.furnishop.com/api/payment/webhook/`
- Enable event: `payment.captured`
- Copy webhook secret to environment variable `RAZORPAY_WEBHOOK_SECRET`

---

### 5.7 ERP Integration

#### 5.7.1 Current Implementation

`backend/services/erp.py` exports a single function: `send_order_to_erp(order)`.

It is called **synchronously** inside `PaymentSuccessView.post()` immediately after payment is confirmed. It has a 10-second timeout and catches all exceptions — ERP failure never blocks the payment response.

#### 5.7.2 ERP Payload Schema

```json
POST {ERP_API_URL}
Headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer {ERP_API_KEY}"
}
Body: {
  "order_id": "ORD-A3F2B91C",
  "customer_name": "Priya Sharma",
  "customer_email": "priya@example.com",
  "amount": 75998.00,
  "items": [
    {
      "product_id": 7,
      "product_name": "Oslo Velvet Sofa",
      "quantity": 1,
      "price": 45999.00
    },
    {
      "product_id": 12,
      "product_name": "Nordic Dining Chair",
      "quantity": 2,
      "price": 14999.50
    }
  ]
}
```

#### 5.7.3 ERP Response

```json
{ "erp_order_id": "ERP-123456" }
```

The `erp_order_id` is stored in `Order.erp_order_id` and returned to the frontend for display on the success screen.

#### 5.7.4 Error Handling Policy

| Error Type | Behavior | Dev Behavior |
|-----------|---------|-------------|
| `ConnectionError` | Returns `None`, logs error | Returns simulated ID `ERP-SIM-{order_id}` |
| `Timeout` (>10s) | Returns `None`, logs error | — |
| `HTTPError` (4xx/5xx) | Returns `None`, logs status code | — |
| Any other `Exception` | Returns `None`, logs traceback | — |

**Invariant:** `send_order_to_erp` never raises an exception to its caller. All errors are caught and logged.

#### 5.7.5 Phase 2 — Async ERP via Celery

In production with high order volume, the synchronous ERP call adds 1–10 seconds to the payment confirmation response time. The Phase 2 enhancement:

1. Add Celery + Redis to the stack
2. Replace the synchronous `send_order_to_erp(order)` call with `send_order_to_erp_task.delay(order.id)`
3. The Celery task retries up to 3 times with exponential backoff on failure
4. Add `erp_sync_status` field to `Order` model: `pending`, `synced`, `failed`
5. Admin Dashboard shows a "Retry ERP Sync" button for orders with `erp_sync_status='failed'`
6. `POST /api/orders/{id}/retry-erp/` — admin-only endpoint to manually trigger a retry

---

### 5.8 Admin Dashboard (Planned — Phase 2)

A custom React SPA section at route `/admin-dashboard` (protected: `role='admin'` required). Replaces reliance on Django Admin for day-to-day operations.

**Sections and sub-routes:**

| Sub-route | Section | Key Features |
|-----------|---------|-------------|
| `/admin-dashboard` | Overview | Revenue today, orders pending, low stock alerts |
| `/admin-dashboard/products` | Product Management | Data table: name, price, stock, category. Add/edit modal with all product fields. Image URL field with preview. Delete with confirmation. |
| `/admin-dashboard/products/new` | Add Product | Full product form |
| `/admin-dashboard/discounts` | Discount Manager | User Discounts tab + Dealer Discounts tab. Searchable product combobox. Discount form. Active discounts table with remaining counts. |
| `/admin-dashboard/orders` | Order Management | Filterable order list (status, date, email). Inline order status dropdown. Order detail drawer with all items and ERP status. |
| `/admin-dashboard/dealers` | Dealer Management | Pending dealer applications list. Approve/Reject buttons. Active dealers list. |
| `/admin-dashboard/erp` | ERP Status | Orders table with `erp_sync_status`. Retry button for failed syncs. |

---

### 5.9 Dealer Dashboard (Planned — Phase 2)

A React page at route `/dealer-dashboard` (protected: `role='dealer'`, `dealer_status='active'`).

**Product listing view:**
- Same grid as the homepage but pricing shows two values per product:
  - **Your Price:** `effective_price` (with dealer discount applied) — highlighted in green
  - **MRP:** `product.price` — shown crossed out
- Badge: `"X units remaining at this price"` (shown when `discount_units_remaining` is not null)
- When discount is exhausted: `"Discount unavailable — price is MRP"` badge

**Order history:**
- List of all orders placed under this dealer's account
- Same OrderCard component as regular user, but shows dealer-specific discount applied per item

---

## 6. Database Schema

### 6.1 categories

```
Table: categories
┌──────────────┬─────────────────┬─────────────────────┬────────────────────────────┐
│ Column       │ Type            │ Constraints         │ Notes                      │
├──────────────┼─────────────────┼─────────────────────┼────────────────────────────┤
│ id           │ BIGINT          │ PK, auto-increment  │                            │
│ name         │ VARCHAR(100)    │ NOT NULL, UNIQUE     │                            │
│ slug         │ VARCHAR(100)    │ NOT NULL, UNIQUE     │ Auto-generated from name   │
└──────────────┴─────────────────┴─────────────────────┴────────────────────────────┘
```

Ordering: `ORDER BY name ASC`

### 6.2 products

```
Table: products
┌──────────────┬─────────────────┬──────────────────────────────┬──────────────────────────────────┐
│ Column       │ Type            │ Constraints                  │ Notes                            │
├──────────────┼─────────────────┼──────────────────────────────┼──────────────────────────────────┤
│ id           │ BIGINT          │ PK, auto-increment           │                                  │
│ name         │ VARCHAR(200)    │ NOT NULL                     │                                  │
│ slug         │ VARCHAR(200)    │ NOT NULL, UNIQUE             │ Auto-generated, uniqueness loop  │
│ description  │ TEXT            │ NOT NULL                     │                                  │
│ price        │ DECIMAL(10,2)   │ NOT NULL                     │ Indian Rupees                    │
│ category_id  │ BIGINT          │ FK → categories.id, CASCADE  │                                  │
│ material     │ VARCHAR(50)     │ NOT NULL, choices            │ wood/metal/fabric/leather/...    │
│ color        │ VARCHAR(50)     │ NOT NULL                     │                                  │
│ dimensions   │ VARCHAR(100)    │ NOT NULL                     │ e.g., "220x85x80 cm"             │
│ image_url    │ VARCHAR(500)    │ NOT NULL                     │ External image URL               │
│ stock        │ INTEGER         │ NOT NULL, >= 0, DEFAULT 0    │ Decremented on order create      │
│ created_at   │ TIMESTAMPTZ     │ NOT NULL, auto_now_add       │                                  │
└──────────────┴─────────────────┴──────────────────────────────┴──────────────────────────────────┘
```

Ordering: `ORDER BY created_at DESC`
Indexes: `category_id`, `material`

**Material choices:** `wood`, `metal`, `fabric`, `leather`, `glass`, `plastic`, `marble`, `rattan`

### 6.3 orders

```
Table: orders
┌────────────────┬─────────────────┬───────────────────────────┬─────────────────────────────────────────┐
│ Column         │ Type            │ Constraints               │ Notes                                   │
├────────────────┼─────────────────┼───────────────────────────┼─────────────────────────────────────────┤
│ id             │ BIGINT          │ PK, auto-increment        │                                         │
│ order_id       │ VARCHAR(20)     │ NOT NULL, UNIQUE           │ Format: ORD-XXXXXXXX (UUID-derived)     │
│ user_name      │ VARCHAR(100)    │ NOT NULL                  │ Guest checkout field                    │
│ user_email     │ VARCHAR(254)    │ NOT NULL                  │ Used for guest order lookup             │
│ phone          │ VARCHAR(15)     │ NOT NULL                  │                                         │
│ address        │ TEXT            │ NOT NULL                  │                                         │
│ total_amount   │ DECIMAL(10,2)   │ NOT NULL                  │ Snapshot at order time                  │
│ payment_status │ VARCHAR(10)     │ NOT NULL, DEFAULT PENDING │ PENDING / SUCCESS / FAILED              │
│ order_status   │ VARCHAR(12)     │ NOT NULL, DEFAULT CREATED │ CREATED/CONFIRMED/SHIPPED/DELIVERED/CANCELLED │
│ erp_order_id   │ VARCHAR(50)     │ NULLABLE                  │ Returned from ERP after sync            │
│ created_at     │ TIMESTAMPTZ     │ NOT NULL, auto_now_add    │                                         │
└────────────────┴─────────────────┴───────────────────────────┴─────────────────────────────────────────┘
```

Indexes: `user_email`, `payment_status`, `order_status`

### 6.4 order_items

```
Table: order_items
┌──────────────┬─────────────────┬────────────────────────────┬──────────────────────────────────────────┐
│ Column       │ Type            │ Constraints                │ Notes                                    │
├──────────────┼─────────────────┼────────────────────────────┼──────────────────────────────────────────┤
│ id           │ BIGINT          │ PK, auto-increment         │                                          │
│ order_id     │ BIGINT          │ FK → orders.id, CASCADE    │                                          │
│ product_id   │ BIGINT          │ FK → products.id, PROTECT  │ PROTECT prevents deleting ordered items  │
│ quantity     │ INTEGER         │ NOT NULL, > 0              │                                          │
│ price        │ DECIMAL(10,2)   │ NOT NULL                   │ Price snapshot at purchase time          │
└──────────────┴─────────────────┴────────────────────────────┴──────────────────────────────────────────┘
```

`subtotal` is a computed property (`price * quantity`), not stored in DB.

### 6.5 payments

```
Table: payments
┌──────────────────────┬─────────────────┬────────────────────────────┬────────────────────────────────────┐
│ Column               │ Type            │ Constraints                │ Notes                              │
├──────────────────────┼─────────────────┼────────────────────────────┼────────────────────────────────────┤
│ id                   │ BIGINT          │ PK, auto-increment         │                                    │
│ order_id             │ BIGINT          │ OneToOne → orders.id       │ One payment record per order       │
│ razorpay_order_id    │ VARCHAR(100)    │ NULLABLE                   │ Set when Razorpay order is created │
│ razorpay_payment_id  │ VARCHAR(100)    │ NULLABLE                   │ Set after payment success          │
│ razorpay_signature   │ VARCHAR(256)    │ NULLABLE [planned]         │ HMAC-SHA256 from Razorpay          │
│ status               │ VARCHAR(10)     │ NOT NULL, DEFAULT PENDING  │ PENDING / SUCCESS / FAILED         │
│ amount               │ DECIMAL(10,2)   │ NOT NULL                   │ INR amount                         │
│ created_at           │ TIMESTAMPTZ     │ NOT NULL, auto_now_add     │                                    │
└──────────────────────┴─────────────────┴────────────────────────────┴────────────────────────────────────┘
```

### 6.6 users (current placeholder + planned additions)

```
Table: users_user (extends Django AbstractUser)
┌─────────────────┬─────────────────┬─────────────────────┬─────────────────────────────────────┐
│ Column          │ Type            │ Constraints         │ Notes                               │
├─────────────────┼─────────────────┼─────────────────────┼─────────────────────────────────────┤
│ id              │ BIGINT          │ PK                  │ Django default                      │
│ email           │ VARCHAR(254)    │ UNIQUE, NOT NULL     │ Login identifier                    │
│ username        │ VARCHAR(150)    │ UNIQUE, NOT NULL     │ Django required field               │
│ first_name      │ VARCHAR(150)    │                     │ Part of full_name                   │
│ last_name       │ VARCHAR(150)    │                     │ Part of full_name                   │
│ password        │ VARCHAR(128)    │ NOT NULL             │ Django hashed password              │
│ is_active       │ BOOLEAN         │ DEFAULT TRUE         │ Django field                        │
│ is_staff        │ BOOLEAN         │ DEFAULT FALSE        │ Django admin access                 │
│ is_superuser    │ BOOLEAN         │ DEFAULT FALSE        │ Django admin superuser              │
│ date_joined     │ TIMESTAMPTZ     │ auto                 │ Django field                        │
│ role            │ VARCHAR(10)     │ DEFAULT 'user'       │ [PLANNED] user / dealer / admin     │
│ phone           │ VARCHAR(15)     │ NULLABLE             │ [PLANNED]                           │
│ dealer_status   │ VARCHAR(10)     │ NULLABLE             │ [PLANNED] pending / active / rejected│
└─────────────────┴─────────────────┴─────────────────────┴─────────────────────────────────────┘
```

### 6.7 discounts (Planned — Phase 2)

```
Table: discounts
┌────────────────┬─────────────────┬────────────────────────────┬───────────────────────────────────────┐
│ Column         │ Type            │ Constraints                │ Notes                                 │
├────────────────┼─────────────────┼────────────────────────────┼───────────────────────────────────────┤
│ id             │ BIGINT          │ PK, auto-increment         │                                       │
│ product_id     │ BIGINT          │ FK → products.id, CASCADE  │ Per-product discount                  │
│ discount_type  │ VARCHAR(10)     │ NOT NULL, choices          │ user / dealer                         │
│ mode           │ VARCHAR(10)     │ NOT NULL, choices          │ percent / flat                        │
│ value          │ DECIMAL(10,2)   │ NOT NULL                   │ 15 for 15%, 2000 for ₹2000 off        │
│ count_limit    │ INTEGER         │ NULLABLE, >= 0             │ NULL = unlimited units                │
│ units_sold     │ INTEGER         │ NOT NULL, DEFAULT 0        │ Atomically incremented on order       │
│ active         │ BOOLEAN         │ NOT NULL, DEFAULT TRUE     │                                       │
│ starts_at      │ TIMESTAMPTZ     │ NULLABLE                   │ NULL = immediately active             │
│ ends_at        │ TIMESTAMPTZ     │ NULLABLE                   │ NULL = never expires                  │
│ created_by_id  │ BIGINT          │ FK → users_user.id         │ Admin who created it                  │
│ created_at     │ TIMESTAMPTZ     │ NOT NULL, auto_now_add     │                                       │
└────────────────┴─────────────────┴────────────────────────────┴───────────────────────────────────────┘
```

**Unique constraint:** `(product_id, discount_type)` — only one active discount per role per product. Attempting to add a second requires deactivating or deleting the existing one.

**Indexes:** `product_id`, `discount_type`, `active`

### 6.8 Entity-Relationship Diagram (Text)

```
categories (1) ──────────────────────< products (many)
                                            │
                                            │ (per-product)
                                            │
                                       discounts
                                            │ (created_by)
                                            │
products (1) ──< order_items (many)   users_user
orders (1) ──< order_items (many)          │
orders (1) ──1 payments                    │
users_user (1) ──< orders (many)  [Phase 2, FK after auth added]
```

### 6.9 Index Strategy

| Table | Indexed Columns | Reason |
|-------|----------------|--------|
| `products` | `category_id` | Category filter queries |
| `products` | `material` | Material filter queries |
| `orders` | `user_email` | Guest order lookup by email |
| `orders` | `payment_status`, `order_status` | Admin filtering |
| `discounts` | `product_id`, `discount_type` | Discount lookup per product per role |
| `discounts` | `active` | Filter inactive discounts |

---

## 7. API Reference

All endpoints are prefixed with `/api/`. In development, the Vite proxy forwards `/api/*` to `http://127.0.0.1:8000`. In production, this is a direct HTTPS call to the backend domain.

**Auth notation:**
- `None` — publicly accessible
- `JWT` — requires `Authorization: Bearer <access-token>` header
- `Admin` — requires JWT with `role='admin'`
- `Dealer` — requires JWT with `role='dealer'` and `dealer_status='active'`

---

### Existing Endpoints (MVP)

---

#### GET /api/products/

List products with filters, search, ordering, and pagination.

**Auth:** None

**Query Parameters:**

| Param | Type | Example | Description |
|-------|------|---------|-------------|
| `category` | string | `sofas` | Filter by category slug (exact match) |
| `price_min` | number | `5000` | Minimum price (INR) |
| `price_max` | number | `50000` | Maximum price (INR) |
| `material` | string | `wood` | Filter by material (exact match) |
| `search` | string | `velvet sofa` | Full-text search on name + description |
| `ordering` | string | `-price` | Sort: `price`, `-price`, `created_at`, `-created_at`, `name` |
| `page` | number | `2` | Page number (12 items per page) |

**Response 200:**
```json
{
  "count": 48,
  "next": "/api/products/?page=2",
  "previous": null,
  "results": [
    {
      "id": 7,
      "name": "Oslo Velvet Sofa",
      "slug": "oslo-velvet-sofa",
      "price": "45999.00",
      "category": 3,
      "category_name": "Sofas",
      "material": "fabric",
      "color": "Emerald Green",
      "dimensions": "220x85x80 cm",
      "image_url": "https://images.unsplash.com/...",
      "stock": 15,
      "in_stock": true,
      "created_at": "2025-01-15T10:30:00+05:30"
    }
  ]
}
```

---

#### GET /api/products/{slug}/

Retrieve a single product by slug.

**Auth:** None

**Response 200:**
```json
{
  "id": 7,
  "name": "Oslo Velvet Sofa",
  "slug": "oslo-velvet-sofa",
  "description": "Luxurious velvet sofa with solid oak legs...",
  "price": "45999.00",
  "category": {
    "id": 3,
    "name": "Sofas",
    "slug": "sofas"
  },
  "material": "fabric",
  "color": "Emerald Green",
  "dimensions": "220x85x80 cm",
  "image_url": "https://images.unsplash.com/...",
  "stock": 15,
  "in_stock": true,
  "created_at": "2025-01-15T10:30:00+05:30"
}
```

**Response 404:**
```json
{ "detail": "No Product matches the given query." }
```

---

#### GET /api/products/similar/{id}/

Return up to 4 products from the same category, excluding the given product.

**Auth:** None

**Response 200:** Array of product list objects (same structure as product list results)

---

#### GET /api/products/categories/

Return all categories (no pagination).

**Auth:** None

**Response 200:**
```json
[
  { "id": 1, "name": "Beds", "slug": "beds" },
  { "id": 2, "name": "Chairs", "slug": "chairs" },
  { "id": 3, "name": "Sofas", "slug": "sofas" }
]
```

---

#### GET /api/cart/

Return the current session-based cart with full product details.

**Auth:** None (session cookie)

**Response 200:**
```json
{
  "items": [
    {
      "product_id": 7,
      "name": "Oslo Velvet Sofa",
      "price": "45999.00",
      "image_url": "https://...",
      "quantity": 1,
      "subtotal": "45999.00"
    }
  ],
  "total": "45999.00"
}
```

---

#### POST /api/cart/add/

Add a product to the session cart (or increment quantity if already present).

**Auth:** None (session cookie)

**Request body:**
```json
{ "product_id": 7, "quantity": 1 }
```

**Response 200:**
```json
{ "message": "Item added to cart", "cart_count": 2 }
```

**Response 400 (out of stock):**
```json
{ "error": "Insufficient stock" }
```

---

#### POST /api/cart/remove/

Remove a product from the session cart.

**Auth:** None (session cookie)

**Request body:**
```json
{ "product_id": 7 }
```

**Response 200:**
```json
{ "message": "Item removed from cart" }
```

---

#### POST /api/cart/clear/

Clear the entire session cart.

**Auth:** None (session cookie)

**Response 200:**
```json
{ "message": "Cart cleared" }
```

---

#### POST /api/orders/create/

Create a new order (guest checkout).

**Auth:** None

**Request body:**
```json
{
  "user_name": "Priya Sharma",
  "user_email": "priya@example.com",
  "phone": "9876543210",
  "address": "12, Koramangala 4th Block, Bengaluru - 560034",
  "items": [
    { "product_id": 7, "quantity": 1 }
  ]
}
```

**Response 201:** Full order object (see Section 5.5.1)

**Response 400 (stock error):**
```json
{
  "items": ["Oslo Velvet Sofa: Only 0 units in stock"]
}
```

---

#### GET /api/orders/

Lookup orders by email (guest) or return user's own orders (authenticated).

**Auth:** None (with `?email=` param) | JWT (without param)

**Query params:** `?email=priya@example.com` (guest lookup)

**Response 200:** Array of order objects

---

#### POST /api/payment/success/

Simulate payment success (current MVP — no real gateway).

**Auth:** None

**Request body:**
```json
{ "order_id": "ORD-XXXXXXXX" }
```

**Response 200:**
```json
{
  "message": "Payment successful",
  "order_id": "ORD-A3F2B91C",
  "payment": { "id": 1, "status": "SUCCESS", "amount": "45999.00" },
  "erp_order_id": "ERP-SIM-ORD-A3F2B91C"
}
```

---

### Planned Endpoints (Phase 2)

---

#### POST /api/auth/register/

Register a new user account.

**Auth:** None

**Request body:**
```json
{
  "full_name": "Priya Sharma",
  "email": "priya@example.com",
  "password": "SecurePass@123",
  "confirm_password": "SecurePass@123"
}
```

**Response 201:**
```json
{
  "access": "<jwt-access-token>",
  "refresh": "<jwt-refresh-token>",
  "user": { "id": 42, "email": "priya@example.com", "role": "user" }
}
```

---

#### POST /api/auth/login/

Login with email and password.

**Auth:** None

**Request body:**
```json
{ "email": "priya@example.com", "password": "SecurePass@123" }
```

**Response 200:** Same as register response

**Response 401:**
```json
{ "detail": "No active account found with the given credentials" }
```

---

#### POST /api/auth/token/refresh/

Refresh an expired access token.

**Auth:** None

**Request body:**
```json
{ "refresh": "<jwt-refresh-token>" }
```

**Response 200:**
```json
{ "access": "<new-jwt-access-token>" }
```

---

#### GET /api/auth/google/

Initiate Google OAuth2 flow. Redirects browser to Google consent screen.

**Auth:** None

---

#### GET /api/auth/google/callback/

Google OAuth2 callback. Handled by `social-auth-app-django`. Creates or retrieves user, issues JWT pair, redirects to frontend.

**Auth:** None (OAuth code exchange)

---

#### POST /api/payment/create-razorpay-order/

Create a Razorpay order for a FurniShop order.

**Auth:** JWT (any role)

**Request body:**
```json
{ "order_id": "ORD-XXXXXXXX" }
```

**Response 200:**
```json
{
  "razorpay_order_id": "order_PQRstuVWXYZ123",
  "amount": 4599900,
  "currency": "INR",
  "key_id": "rzp_test_XXXXXXXXXXX"
}
```

---

#### POST /api/payment/verify/

Verify Razorpay payment signature and confirm order.

**Auth:** JWT (any role)

**Request body:**
```json
{
  "order_id": "ORD-XXXXXXXX",
  "razorpay_order_id": "order_PQRstuVWXYZ123",
  "razorpay_payment_id": "pay_ABCdefGHI456",
  "razorpay_signature": "<hmac-sha256-hex>"
}
```

**Response 200:**
```json
{
  "message": "Payment verified successfully",
  "order_id": "ORD-XXXXXXXX",
  "erp_order_id": "ERP-987654"
}
```

**Response 400 (signature mismatch):**
```json
{ "error": "Payment verification failed" }
```

---

#### POST /api/payment/webhook/

Razorpay webhook receiver for `payment.captured` events.

**Auth:** Webhook signature via `X-Razorpay-Signature` header

**Request body:** Razorpay event payload (JSON)

**Response 200:** `{ "status": "ok" }`

---

#### GET /api/discounts/

List all discounts (admin) or discounts for the current user's role (authenticated user/dealer).

**Auth:** JWT

**Response 200:**
```json
[
  {
    "id": 1,
    "product_id": 7,
    "product_name": "Oslo Velvet Sofa",
    "discount_type": "user",
    "mode": "percent",
    "value": "15.00",
    "count_limit": 100,
    "units_sold": 23,
    "units_remaining": 77,
    "active": true,
    "starts_at": null,
    "ends_at": "2026-12-31T23:59:59+05:30"
  }
]
```

---

#### POST /api/discounts/

Create a new discount.

**Auth:** Admin

**Request body:**
```json
{
  "product_id": 7,
  "discount_type": "dealer",
  "mode": "percent",
  "value": 25,
  "count_limit": 50,
  "starts_at": null,
  "ends_at": "2026-12-31T23:59:59+05:30"
}
```

---

#### PUT /api/discounts/{id}/

Update an existing discount.

**Auth:** Admin

---

#### DELETE /api/discounts/{id}/

Delete a discount.

**Auth:** Admin

---

#### GET /api/orders/all/

List all orders across all users.

**Auth:** Admin

**Query params:** `?status=CONFIRMED`, `?email=user@example.com`, `?date_from=2026-01-01`

---

#### PATCH /api/orders/{id}/status/

Update order status.

**Auth:** Admin

**Request body:**
```json
{ "order_status": "SHIPPED" }
```

---

#### POST /api/orders/{id}/retry-erp/

Retry ERP synchronization for a failed order.

**Auth:** Admin

**Response 200:**
```json
{ "message": "ERP sync successful", "erp_order_id": "ERP-987654" }
```

---

## 8. Frontend Component Architecture

### 8.1 Component Tree

```
main.jsx
└── BrowserRouter
    └── CartProvider (CartContext)
        └── App.jsx
            ├── Toaster (react-hot-toast, global)
            ├── Navbar.jsx
            │   ├── Announcement Bar (shipping info, phone)
            │   ├── Logo (Link → /)
            │   ├── Desktop Nav
            │   │   └── MegaMenu (per NAV_ITEM, 6 top-level categories)
            │   ├── Search Overlay (input + suggestions)
            │   ├── Action Bar
            │   │   ├── Search icon button
            │   │   ├── Wishlist icon (placeholder)
            │   │   ├── Account icon (placeholder → LoginPage)
            │   │   └── Cart icon (badge with cartCount)
            │   └── Mobile Drawer (accordion navigation)
            │
            ├── <Routes>
            │   ├── / → HomePage.jsx
            │   │   ├── Hero Swiper (Autoplay, EffectFade, 4s intervals)
            │   │   ├── WhyUs Strip (4 trust badges)
            │   │   ├── Category Chips (6 chips → filter by category)
            │   │   ├── Featured Collections Banner (2-3 cards)
            │   │   ├── Promo Banner (40% OFF)
            │   │   └── Products Section
            │   │       ├── FilterSidebar.jsx (desktop)
            │   │       ├── Filter toggle button (mobile)
            │   │       └── ProductCard.jsx (× 12, grid layout)
            │   │           └── Pagination controls
            │   │
            │   ├── /product/:slug → ProductDetailPage.jsx
            │   │   ├── Breadcrumb (Home > Category > Product)
            │   │   ├── Product Image
            │   │   ├── Product Info
            │   │   │   ├── Name, category badge
            │   │   │   ├── Rating (hardcoded 4.0★ — placeholder)
            │   │   │   ├── Price (with 20% discount badge)
            │   │   │   ├── Material, color, dimensions
            │   │   │   ├── Stock status badge
            │   │   │   ├── Quantity selector
            │   │   │   └── Add to Cart button
            │   │   ├── Trust Badges (shipping, warranty, returns)
            │   │   └── Similar Products
            │   │       └── ProductCard.jsx (× up to 4)
            │   │
            │   ├── /cart → CartPage.jsx
            │   │   ├── CartItem.jsx (× n, with qty editor + remove)
            │   │   ├── Order Summary (subtotal, discount, shipping, total)
            │   │   └── Checkout button → /checkout
            │   │
            │   ├── /checkout → CheckoutPage.jsx
            │   │   ├── Address form (name, email, phone, address)
            │   │   ├── Order summary (items with images + quantities)
            │   │   ├── Pay Now button
            │   │   └── Success screen (order_id, erp_order_id, actions)
            │   │
            │   └── /orders → OrdersPage.jsx
            │       ├── Email input form
            │       └── OrderCard.jsx (× n, per matched order)
            │
            └── Footer.jsx
```

### 8.2 Planned New Components

| Component | Location | Purpose |
|-----------|---------|---------|
| `AuthContext.jsx` | `context/` | JWT state, login/logout actions, role |
| `ProtectedRoute.jsx` | `components/` | Redirect to /login if unauthenticated |
| `RoleRoute.jsx` | `components/` | Show 403 if wrong role |
| `LoginPage.jsx` | `pages/` | Email/password login + Google OAuth button |
| `SignupPage.jsx` | `pages/` | Registration form |
| `AuthCallbackPage.jsx` | `pages/` | Reads tokens from OAuth redirect URL |
| `DealerDashboard.jsx` | `pages/` | Dealer-specific product listing + order history |
| `AdminDashboard.jsx` | `pages/` | Multi-section admin control panel |

### 8.3 State Management

| Domain | Managed In | Persistence | Notes |
|--------|-----------|-------------|-------|
| Cart items | `CartContext` + `useReducer` | `localStorage` → `furnishop_cart` | Primary source of truth |
| Auth user + tokens | `AuthContext` + `useState` [planned] | localStorage (refresh), memory (access) | |
| Product list | `HomePage` local `useState` | None — fetched on mount/filter change | |
| Filter state | `HomePage` local `useState` + `useSearchParams` | URL query string | Shareable filter URLs |
| Checkout form | `CheckoutPage` local `useState` | None | |
| Admin discount panel | `AdminDashboard` local `useState` [planned] | None | |

### 8.4 Routing Table

| Path | Component | Auth Required | Allowed Roles |
|------|-----------|:-------------:|:-------------:|
| `/` | `HomePage` | No | All |
| `/product/:slug` | `ProductDetailPage` | No | All |
| `/cart` | `CartPage` | No | All |
| `/checkout` | `CheckoutPage` | No | All |
| `/orders` | `OrdersPage` | No | All |
| `/login` | `LoginPage` | No (guest only) | — |
| `/signup` | `SignupPage` | No (guest only) | — |
| `/auth-callback` | `AuthCallbackPage` | No | — |
| `/dealer-dashboard` | `DealerDashboard` | Yes | dealer |
| `/admin-dashboard/*` | `AdminDashboard` | Yes | admin |

---

## 9. Navbar ↔ Product Connection

### 9.1 How Navigation Works

The Navbar mega-menu and category chips both navigate by appending a `?category=<slug>` query parameter to the homepage URL. The HomePage reads this parameter and passes it as a filter to the backend.

**Full data flow:**

```
User clicks "Sofas" in Navbar mega-menu
         │
         ▼
goTo('sofas') in Navbar.jsx
         │
         ▼
navigate('/?category=sofas')  [react-router-dom]
         │
         ▼
HomePage mounts / URL changes
useSearchParams() reads searchParams.get('category') → 'sofas'
setFilters({ ...filters, category: 'sofas' })
         │
         ▼
useEffect([filters]) triggers → loadProducts()
fetchProducts({ category: 'sofas', page: 1 })
         │
         ▼
GET /api/products/?category=sofas
         │
         ▼
ProductFilter.filterset_class:
  category = CharFilter(field_name='category__slug', lookup_expr='exact')
queryset.filter(category__slug='sofas')
         │
         ▼
JSON response with paginated sofas products
         │
         ▼
ProductCard grid renders filtered products
```

### 9.2 NAV_ITEMS Structure

`Navbar.jsx` defines `NAV_ITEMS` as an array of top-level categories, each with `columns` containing `items` with a `slug` field. This `slug` value must exactly match a `Category.slug` in the database.

**Example NAV_ITEMS entry:**
```javascript
{
  label: 'Sofas & Seating',
  icon: <FiHome />,
  columns: [
    {
      heading: 'Sofas',
      items: [
        { label: 'All Sofas', slug: 'sofas' },
        { label: 'Corner Sofas', slug: 'sofas' },
        { label: 'Recliner Sofas', slug: 'sofas' },
      ]
    }
  ]
}
```

### 9.3 Known Bugs to Fix

**Bug 1 — Category chip values don't match DB slugs**

In `HomePage.jsx`, the `CATEGORIES` array uses display values like `"Beds"` (capitalized) as the filter value:

```javascript
const CATEGORIES = [
  { label: "Bed Linen", value: "Beds", emoji: "🛏️", ... },
  { label: "Sofas",     value: "Sofas", emoji: "🛋️", ... },
];
```

But the backend `ProductFilter` compares against `category__slug` which is lowercase (`beds`, `sofas`). The filter `?category=Beds` returns no results because no category slug is `"Beds"`.

**Fix:** Change `value` in the `CATEGORIES` array to match the exact DB slug (lowercase):
```javascript
{ label: "Bed Linen", value: "beds", emoji: "🛏️", ... },
{ label: "Sofas",     value: "sofas", emoji: "🛋️", ... },
```

**Bug 2 — NAV_ITEMS slugs must align with seeded category slugs**

The `seed_products.py` management command creates these category slugs: `sofas`, `tables`, `chairs`, `beds`, `storage`, `desks`, `dining-sets`, `outdoor`. The `NAV_ITEMS` in `Navbar.jsx` must use these exact slug values. Any mismatch results in empty product grids.

**Fix:** Audit every `slug` value in `NAV_ITEMS` against the seeded categories. Categories that don't exist in the DB (e.g., `bath`, `cushions`) will silently return 0 products. Either add these categories via a migration or remove the nav items.

---

## 10. Discount System Design (Deep-Dive)

### 10.1 Django Model (New `discounts` App)

```python
# backend/discounts/models.py

class Discount(models.Model):
    DISCOUNT_TYPE_CHOICES = [
        ('user', 'User'),
        ('dealer', 'Dealer'),
    ]
    MODE_CHOICES = [
        ('percent', 'Percentage'),
        ('flat', 'Flat Amount'),
    ]

    product = models.ForeignKey(
        'products.Product',
        on_delete=models.CASCADE,
        related_name='discounts'
    )
    discount_type = models.CharField(max_length=10, choices=DISCOUNT_TYPE_CHOICES)
    mode = models.CharField(max_length=10, choices=MODE_CHOICES)
    value = models.DecimalField(max_digits=10, decimal_places=2)
    count_limit = models.PositiveIntegerField(null=True, blank=True)
    units_sold = models.PositiveIntegerField(default=0)
    active = models.BooleanField(default=True)
    starts_at = models.DateTimeField(null=True, blank=True)
    ends_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'discounts'
        # One active discount per type per product
        unique_together = [('product', 'discount_type')]
```

### 10.2 Effective Price Computation

```python
# backend/discounts/services.py

from django.utils import timezone
from decimal import Decimal

def get_effective_price(product, user_role):
    """
    Returns (effective_price, discount_obj, units_remaining).
    effective_price equals product.price if no discount applies.
    """
    now = timezone.now()

    discount = Discount.objects.filter(
        product=product,
        discount_type=user_role,  # 'user' or 'dealer'
        active=True,
    ).filter(
        models.Q(starts_at__isnull=True) | models.Q(starts_at__lte=now)
    ).filter(
        models.Q(ends_at__isnull=True) | models.Q(ends_at__gte=now)
    ).first()

    if discount is None:
        return product.price, None, None

    # Check count limit
    units_remaining = None
    if discount.count_limit is not None:
        units_remaining = discount.count_limit - discount.units_sold
        if units_remaining <= 0:
            return product.price, None, 0  # Discount exhausted

    # Calculate discounted price
    if discount.mode == 'percent':
        effective = product.price * (1 - discount.value / Decimal('100'))
    else:  # flat
        effective = max(Decimal('0'), product.price - discount.value)

    return effective.quantize(Decimal('0.01')), discount, units_remaining
```

### 10.3 Serializer Integration

Product serializers return role-aware pricing when the request user is authenticated:

```python
# backend/products/serializers.py

class ProductDetailSerializer(serializers.ModelSerializer):
    effective_price = serializers.SerializerMethodField()
    discount_applied = serializers.SerializerMethodField()
    discount_units_remaining = serializers.SerializerMethodField()

    def _get_discount_data(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return obj.price, None, None
        role = getattr(request.user, 'role', 'user')
        return get_effective_price(obj, role)

    def get_effective_price(self, obj):
        price, _, _ = self._get_discount_data(obj)
        return str(price)

    def get_discount_applied(self, obj):
        _, discount, _ = self._get_discount_data(obj)
        if discount is None:
            return None
        return {
            "mode": discount.mode,
            "value": str(discount.value),
            "type": discount.discount_type
        }

    def get_discount_units_remaining(self, obj):
        _, _, remaining = self._get_discount_data(obj)
        return remaining
```

**Serializer output for a logged-in dealer:**
```json
{
  "id": 7,
  "name": "Oslo Velvet Sofa",
  "price": "45999.00",
  "effective_price": "34499.25",
  "discount_applied": {
    "mode": "percent",
    "value": "25.00",
    "type": "dealer"
  },
  "discount_units_remaining": 77
}
```

### 10.4 Atomic units_sold Increment

When an order is confirmed (payment success), `units_sold` is incremented atomically using Django's `F()` expression to prevent race conditions:

```python
# backend/discounts/services.py

from django.db.models import F

def apply_discount_to_order(order):
    for item in order.items.select_related('product').all():
        user_role = getattr(order.user, 'role', 'user') if order.user else 'user'
        Discount.objects.filter(
            product=item.product,
            discount_type=user_role,
            active=True,
        ).update(units_sold=F('units_sold') + item.quantity)
```

### 10.5 Race Condition Prevention (select_for_update)

When the discount has a `count_limit`, order processing must use `select_for_update()` to prevent two concurrent orders from both seeing `units_remaining > 0` and both claiming the last discounted units:

```python
# In OrderCreateSerializer.validate_items() or order creation service:

from django.db import transaction

with transaction.atomic():
    discount = Discount.objects.select_for_update().filter(
        product=product,
        discount_type=user_role,
        active=True,
    ).first()

    if discount and discount.count_limit is not None:
        remaining = discount.count_limit - discount.units_sold
        if quantity > remaining:
            raise ValidationError(
                f"Only {remaining} units available at the discounted price."
            )
```

### 10.6 Edge Case Policies

| Edge Case | Policy |
|-----------|--------|
| Two users buy the last discounted unit simultaneously | `select_for_update()` on the Discount row serializes access — first commit wins, second gets validation error |
| Order is cancelled after discounted purchase | `units_sold` is decremented via a signal on order cancellation. Discount "quota" is restored. |
| `quantity` ordered > `units_remaining` (partial) | V2: refuse the entire order with error "Only X units at discounted price". V3 (future): apply discount to first X units and full price to remaining units. |
| Discount `ends_at` passes mid-order | Price is locked at the time `validate_items()` runs. Once the validation passes, the discount price is guaranteed (using `select_for_update`). |
| Admin deactivates discount while orders are in cart | Carts use `product.price` (no real-time lock). Price is confirmed at checkout time. If discount is deactivated before checkout, the full price applies. |

---

## 11. Testing Strategy

### 11.1 Philosophy

Testing is layered from fast, isolated units to slow, realistic end-to-end scenarios:

```
Unit Tests        (fast, isolated)  → logic, serializers, service functions
Integration Tests (medium, real DB) → API endpoints, full request-response cycle
Component Tests   (medium, virtual DOM) → React UI behavior
E2E Tests         (slow, real browser) → critical user journeys
```

All new features in Phase 2 must have tests written before or alongside the implementation (test-alongside).

### 11.2 Backend Tests

**File structure:**

```
backend/
├── products/tests/
│   ├── __init__.py
│   ├── test_models.py          ← Category, Product slug generation, in_stock property
│   ├── test_serializers.py     ← ProductListSerializer, ProductDetailSerializer field output
│   ├── test_views.py           ← Filtering, pagination, search, 404 handling
│   └── test_filters.py         ← ProductFilter: category slug, price range, material
├── orders/tests/
│   ├── test_models.py          ← Order ID auto-generation format
│   ├── test_serializers.py     ← OrderCreateSerializer stock validation, total calculation
│   └── test_views.py           ← POST create, GET by email, stock error
├── payments/tests/
│   ├── test_views.py           ← Simulated payment success, already-paid error
│   └── test_razorpay.py        ← [planned] Razorpay signature verification
├── cart/tests/
│   └── test_views.py           ← CartView, CartAddView stock check, CartRemoveView
├── services/tests/
│   └── test_erp.py             ← send_order_to_erp success, ConnectionError fallback, Timeout
└── discounts/tests/            ← [planned]
    ├── test_models.py           ← Discount computation: percent, flat, count_limit exhaustion
    ├── test_services.py         ← get_effective_price for different roles
    └── test_views.py            ← Discount CRUD admin-only access, 403 for non-admin
```

**Example: Order serializer stock validation test**

```python
# backend/orders/tests/test_serializers.py

from django.test import TestCase
from products.models import Category, Product
from orders.serializers import OrderCreateSerializer

class OrderCreateSerializerTest(TestCase):

    def setUp(self):
        self.category = Category.objects.create(name='Sofas')
        self.product = Product.objects.create(
            name='Test Sofa',
            price='10000.00',
            category=self.category,
            material='fabric',
            color='Blue',
            dimensions='200x80x80',
            image_url='https://test.com/image.jpg',
            stock=5,
        )

    def test_valid_order_passes_validation(self):
        data = {
            'user_name': 'Test User',
            'user_email': 'test@example.com',
            'phone': '9999999999',
            'address': '123 Test Street',
            'items': [{'product_id': self.product.id, 'quantity': 2}],
        }
        serializer = OrderCreateSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)

    def test_insufficient_stock_fails_validation(self):
        data = {
            'user_name': 'Test User',
            'user_email': 'test@example.com',
            'phone': '9999999999',
            'address': '123 Test Street',
            'items': [{'product_id': self.product.id, 'quantity': 10}],
        }
        serializer = OrderCreateSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('items', serializer.errors)

    def test_total_amount_calculated_correctly(self):
        data = {
            'user_name': 'Test User',
            'user_email': 'test@example.com',
            'phone': '9999999999',
            'address': '123 Test Street',
            'items': [{'product_id': self.product.id, 'quantity': 3}],
        }
        serializer = OrderCreateSerializer(data=data)
        serializer.is_valid()
        order = serializer.save()
        self.assertEqual(order.total_amount, 30000.00)
```

**Run backend tests:**
```bash
cd backend
python manage.py test
# Or with coverage:
pip install coverage
coverage run manage.py test
coverage report -m
```

### 11.3 Frontend Tests

**Setup:** React Testing Library + Vitest (or Jest)

**File structure:**

```
frontend/src/
├── components/__tests__/
│   ├── ProductCard.test.jsx        ← renders name/price, add-to-cart click
│   ├── CartItem.test.jsx           ← quantity controls, remove button
│   ├── OrderCard.test.jsx          ← status badge colors, price formatting
│   ├── FilterSidebar.test.jsx      ← category, material, price inputs
│   └── Navbar.test.jsx             ← cart badge count, search overlay toggle
├── pages/__tests__/
│   ├── HomePage.test.jsx           ← product grid render, empty state
│   ├── CartPage.test.jsx           ← empty cart message, total calculation
│   ├── CheckoutPage.test.jsx       ← form validation, mock order creation
│   └── OrdersPage.test.jsx         ← email form, orders list render
└── context/__tests__/
    └── CartContext.test.jsx        ← addToCart, removeFromCart, updateQuantity, clearCart
```

**Example: ProductCard component test**

```javascript
// frontend/src/components/__tests__/ProductCard.test.jsx

import { render, screen, fireEvent } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { CartProvider } from '../../context/CartContext';
import ProductCard from '../ProductCard';

const mockProduct = {
  id: 1,
  name: 'Test Chair',
  slug: 'test-chair',
  price: '5000.00',
  category_name: 'Chairs',
  material: 'wood',
  image_url: 'https://test.com/chair.jpg',
  in_stock: true,
  stock: 10,
};

const wrapper = ({ children }) => (
  <BrowserRouter>
    <CartProvider>{children}</CartProvider>
  </BrowserRouter>
);

test('displays product name and price', () => {
  render(<ProductCard product={mockProduct} />, { wrapper });
  expect(screen.getByText('Test Chair')).toBeInTheDocument();
  expect(screen.getByText(/₹5,000/)).toBeInTheDocument();
});

test('add to cart button triggers cart update', () => {
  render(<ProductCard product={mockProduct} />, { wrapper });
  const button = screen.getByRole('button', { name: /add to cart/i });
  fireEvent.click(button);
  // toast should appear (tested via react-hot-toast mock)
});

test('shows out of stock when stock is zero', () => {
  const outOfStockProduct = { ...mockProduct, stock: 0, in_stock: false };
  render(<ProductCard product={outOfStockProduct} />, { wrapper });
  expect(screen.getByText(/out of stock/i)).toBeInTheDocument();
});
```

**Run frontend tests:**
```bash
cd frontend
npm test
# With coverage:
npm test -- --coverage
```

### 11.4 E2E Tests (Playwright)

**File structure:**

```
e2e/
├── playwright.config.ts
├── auth.spec.ts              ← login, signup, Google OAuth redirect, logout
├── browse.spec.ts            ← category filter, search, product detail navigation
├── cart.spec.ts              ← add/update/remove items, cart badge count
├── checkout.spec.ts          ← full guest checkout, order confirmation screen
├── orders.spec.ts            ← order lookup by email, order card display
├── discount.spec.ts          ← dealer sees dealer price, user sees user price
└── admin.spec.ts             ← admin login, add product, create discount, update order status
```

**Example: Full guest checkout E2E test**

```typescript
// e2e/checkout.spec.ts

import { test, expect } from '@playwright/test';

test.describe('Guest Checkout Flow', () => {
  test('completes full checkout and shows order ID', async ({ page }) => {
    // Navigate to homepage
    await page.goto('/');

    // Wait for products to load and click first product
    await page.waitForSelector('[data-testid="product-card"]');
    await page.click('[data-testid="product-card"]:first-child');

    // Add to cart from product detail page
    await page.waitForSelector('#add-to-cart-btn');
    await page.click('#add-to-cart-btn');

    // Navigate to checkout
    await page.goto('/checkout');

    // Fill checkout form
    await page.fill('[name="user_name"]', 'Test User');
    await page.fill('[name="user_email"]', 'test@example.com');
    await page.fill('[name="phone"]', '9876543210');
    await page.fill('[name="address"]', '123 Test Street, Bengaluru - 560034');

    // Submit payment
    await page.click('[data-testid="pay-now-btn"]');

    // Assert success screen
    await expect(page.locator('[data-testid="checkout-success"]')).toBeVisible();
    await expect(page.locator('[data-testid="success-order-id"]')).toContainText('ORD-');
  });
});
```

**Run E2E tests:**
```bash
npx playwright install
npx playwright test
npx playwright test --headed   # visible browser
npx playwright show-report     # HTML report
```

### 11.5 Test Configuration Files

**Backend — use Django's built-in test runner (no additional config file needed):**
```bash
python manage.py test                    # all tests
python manage.py test products           # single app
python manage.py test products.tests.test_views  # single file
```

**Frontend — `frontend/vitest.config.js`:**
```javascript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/setupTests.js'],
    globals: true,
  },
});
```

**Frontend — `frontend/src/setupTests.js`:**
```javascript
import '@testing-library/jest-dom';
// Add MSW setup here for API mocking in component tests
```

**E2E — `e2e/playwright.config.ts`:**
```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: 'http://localhost:5173',
    headless: true,
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: 'npm run dev',
    port: 5173,
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## 12. Environment Setup

### 12.1 Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Python | 3.11 | Backend runtime |
| pip | latest | Python package manager |
| Node.js | 20.x | Frontend runtime |
| npm | 10.x | Frontend package manager |
| Git | 2.x | Version control |

### 12.2 Backend Setup

```bash
# 1. Clone the repository
git clone <repository-url>
cd furnishop/backend

# 2. Create and activate virtual environment
python -m venv venv
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment variables
cp .env.example .env
# Edit .env with your values (see Environment Variables section below)

# 5. Run database migrations
python manage.py migrate

# 6. Seed the database with sample products and categories
python manage.py seed_products

# 7. Create a superuser (admin account)
python manage.py createsuperuser

# 8. Start the development server
python manage.py runserver
# Server runs at http://127.0.0.1:8000
# Django admin at http://127.0.0.1:8000/admin/
```

### 12.3 Frontend Setup

```bash
# In a new terminal
cd furnishop/frontend

# 1. Install dependencies
npm install

# 2. Start the development server
npm run dev
# App runs at http://localhost:5173
# All /api/* requests are proxied to http://127.0.0.1:8000
```

### 12.4 Environment Variables

Create `backend/.env` from `backend/.env.example`:

| Variable | Required | Default | Description |
|----------|:--------:|---------|-------------|
| `SECRET_KEY` | **Yes** | insecure default | Django secret key. Generate with `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"` |
| `DEBUG` | No | `True` | Set to `False` in production |
| `DATABASE_URL` | No | SQLite fallback | Neon PostgreSQL connection string: `postgresql://user:pass@host/dbname` |
| `ALLOWED_HOSTS` | No | `localhost,127.0.0.1` | Comma-separated allowed hostnames |
| `CORS_ALLOWED_ORIGINS` | No | `http://localhost:5173` | Comma-separated allowed origins for CORS |
| `ERP_API_URL` | No | placeholder | Full URL of external ERP order endpoint |
| `ERP_API_KEY` | No | *(empty)* | Bearer token for ERP API authentication |
| `RAZORPAY_KEY_ID` | Prod only | *(empty)* | Razorpay Key ID (test or live) |
| `RAZORPAY_KEY_SECRET` | Prod only | *(empty)* | Razorpay Key Secret |
| `RAZORPAY_WEBHOOK_SECRET` | Prod only | *(empty)* | Razorpay webhook signature secret |
| `GOOGLE_CLIENT_ID` | Phase 2 | *(empty)* | Google OAuth2 client ID |
| `GOOGLE_CLIENT_SECRET` | Phase 2 | *(empty)* | Google OAuth2 client secret |
| `FRONTEND_URL` | Phase 2 | `http://localhost:5173` | Used for OAuth redirect back to frontend |

### 12.5 Vite Proxy Configuration

`frontend/vite.config.js` proxies all `/api/*` requests to the Django backend during development:

```javascript
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
      }
    }
  }
});
```

In production, the proxy is not used. The frontend must set `VITE_API_BASE_URL` to the absolute backend URL, and the Axios instance must read it.

### 12.6 Seeded Data

`python manage.py seed_products` creates:

**Categories (8):** Sofas, Tables, Chairs, Beds, Storage, Desks, Dining Sets, Outdoor

**Products (16):** 2 products per category, spanning all 8 material types, with realistic names, descriptions, prices (₹3,000–₹85,000), and Unsplash image URLs.

---

## 13. Deployment Guide

### 13.1 Production Architecture

```
Users ─────────────────────────────── HTTPS ───────────────────────────────────────┐
                                                                                    │
Vercel / Netlify                                Railway / Render                    │
┌─────────────────┐                        ┌──────────────────────────────┐         │
│  React SPA      │ ── HTTPS /api/* ──────▶│  Django + Gunicorn           │         │
│  (Vite build)   │                        │  (PORT from platform env)    │         │
│  Static files   │                        │                              │         │
└─────────────────┘                        └─────────────┬────────────────┘         │
                                                         │                          │
                              ┌──────────────────────────┼──────────────────┐       │
                              │                          │                  │       │
                         Neon Cloud                  Razorpay           External   │
                         PostgreSQL                  (payment)           ERP API   │
                                                                                    │
◄───────────────────────────────────────────────────────────────────────────────────┘
```

### 13.2 Backend Deployment (Railway or Render)

**Environment variables:** Set all variables from Section 12.4 in the platform dashboard (never in code).

**Build command:**
```bash
pip install -r requirements.txt
```

**Pre-deploy hook:**
```bash
python manage.py migrate && python manage.py collectstatic --noinput
```

**Start command:**
```bash
gunicorn core.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 60
```

**Worker count:** For Railway/Render free/starter tier — `--workers 2`. For production load: `--workers $(nproc)` or `2 * num_cores + 1`.

### 13.3 Frontend Deployment (Vercel)

**Build command:**
```bash
npm run build
```

**Output directory:** `dist`

**Environment variable:**
```
VITE_API_BASE_URL=https://your-backend.onrender.com
```

**Update `frontend/src/api/index.js` for production:**
```javascript
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  ...
});
```

**Vite proxy only works in development.** In production, `VITE_API_BASE_URL` must be set to the full backend URL.

### 13.4 Database (Neon PostgreSQL)

1. Create a project at [neon.tech](https://neon.tech)
2. Copy the connection string (format: `postgresql://user:password@host/dbname?sslmode=require`)
3. Set as `DATABASE_URL` in the backend platform environment variables
4. For serverless functions or connection pooling: append `?pgbouncer=true` to the URL

**Connection settings in `settings.py`:**
```python
DATABASES = {
    'default': dj_database_url.config(
        default=DATABASE_URL,
        conn_max_age=600,          # Keep connections open 10 minutes
        conn_health_checks=True,   # Re-use only healthy connections
    )
}
```

### 13.5 Razorpay Production Checklist

- [ ] Log in to [Razorpay Dashboard](https://dashboard.razorpay.com)
- [ ] Switch from Test mode to Live mode
- [ ] Copy Live Key ID and Live Key Secret → set as `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET`
- [ ] Navigate to Settings → Webhooks → Add webhook URL: `https://api.furnishop.com/api/payment/webhook/`
- [ ] Enable event: `payment.captured`
- [ ] Copy webhook secret → set as `RAZORPAY_WEBHOOK_SECRET`
- [ ] Test with Razorpay test cards in staging before switching to live keys
- [ ] Ensure backend correctly handles amounts in paise (multiply INR by 100)

### 13.6 Security Checklist

- [ ] `DEBUG=False` in production
- [ ] `SECRET_KEY` is a long random string (not the insecure default from `.env.example`)
- [ ] `ALLOWED_HOSTS` is set to production domain(s) only — no `*`
- [ ] `CORS_ALLOWED_ORIGINS` is set to the production frontend URL only
- [ ] HTTPS enforced (Render/Railway/Vercel all provide automatic SSL)
- [ ] `SESSION_COOKIE_SECURE=True` and `SESSION_COOKIE_HTTPONLY=True` in production settings
- [ ] `CSRF_COOKIE_SECURE=True` in production settings
- [ ] Razorpay webhook signature is verified (never trust unverified webhook payloads)
- [ ] Django admin URL changed from `/admin/` to a non-obvious path in production
- [ ] Database credentials are never committed to version control

---

## 14. Roadmap

### Phase 1 — MVP (Complete)

| Feature | Status | Key Files |
|---------|--------|-----------|
| Product catalog (list, filter, search) | Done | `backend/products/` |
| Product detail page with similar products | Done | `frontend/src/pages/ProductDetailPage.jsx` |
| Category and material filters (sidebar) | Done | `frontend/src/components/FilterSidebar.jsx` |
| Hero carousel with autoplay | Done | `frontend/src/pages/HomePage.jsx` |
| Session-based cart (backend) | Done | `backend/cart/views.py` |
| Frontend cart (localStorage + Context) | Done | `frontend/src/context/CartContext.jsx` |
| Guest checkout (no account needed) | Done | `frontend/src/pages/CheckoutPage.jsx` |
| Order creation with stock validation | Done | `backend/orders/` |
| Simulated payment flow | Done | `backend/payments/views.py` |
| ERP integration (graceful fallback) | Done | `backend/services/erp.py` |
| Django admin panel for products/orders | Done | `backend/*/admin.py` |
| Mega-menu Navbar (desktop + mobile) | Done | `frontend/src/components/Navbar.jsx` |
| Seed data management command | Done | `backend/products/management/commands/seed_products.py` |
| PostgreSQL (Neon) configuration | Done | `backend/core/settings.py` |

### Phase 2 — Production Core (Planned)

| Feature | Priority | Depends On | Notes |
|---------|:--------:|-----------|-------|
| JWT authentication (SimpleJWT) | P0 | — | Blocks all role-based features |
| Google OAuth (social-auth) | P0 | Auth | |
| User model: role field, dealer_status | P0 | Auth | |
| Real Razorpay integration | P0 | Auth | |
| Discount model + app | P1 | Auth | |
| `get_effective_price` service | P1 | Discount model | |
| Discount-aware product serializers | P1 | Discount service | |
| Admin Discount Management Panel (React) | P1 | Discount model | |
| Dealer Dashboard (React) | P1 | Auth + Discounts | |
| Custom Admin Dashboard (React) | P1 | Auth | |
| Navbar-product category bug fixes | P1 | — | Fix slug casing (Section 9.3) |
| Automated backend tests | P1 | — | |
| Automated frontend tests (RTL + Vitest) | P1 | — | |
| E2E tests (Playwright) | P1 | — | |
| Product image upload (Cloudinary/S3) | P2 | — | Replace `image_url` with upload |
| Server-side cart (merge on login) | P2 | Auth | |
| Dealer application workflow | P2 | Auth | |

### Phase 3 — Growth Features (Future)

| Feature | Priority | Notes |
|---------|:--------:|-------|
| Wishlist (persistent, per user) | P2 | Backend model + API + UI |
| Product ratings and reviews | P2 | Review model, display on product page |
| Async ERP sync via Celery + Redis | P2 | Remove synchronous ERP blocking |
| Email notifications (order confirmation, shipping) | P2 | Django email + template |
| Order cancellation (user-initiated) | P2 | Status transition + stock restore |
| Partial discount on qty > count_limit | P3 | V2 refuses; V3 splits pricing |
| Coupon/promo codes | P3 | Code-based discount layer |
| Bundle discounts (buy 2 get 1) | P3 | Complex discount rules engine |
| Dealer application web form | P3 | Self-service dealer onboarding |
| Analytics dashboard | P3 | Revenue, top products, conversion rate |
| SMS notifications | P3 | Twilio or MSG91 integration |
| Advanced search (Elasticsearch) | P3 | Full-text, facets, autocomplete |

---

## Developer Notes

### Conventions

**Adding a new Django app:**
1. `python manage.py startapp <appname>`
2. Add `'<appname>'` to `INSTALLED_APPS` in `core/settings.py`
3. Create and register URLs in `<appname>/urls.py`
4. Add `path('api/<appname>/', include('<appname>.urls'))` to `core/urls.py`
5. Run `python manage.py makemigrations <appname> && python manage.py migrate`

**All frontend API calls** go through `frontend/src/api/index.js`. Add new endpoint functions there — never call Axios directly in component files.

**The ERP service contract:** `services/erp.send_order_to_erp()` must **never** raise an exception to its caller. All errors are caught internally and logged. This is an invariant — do not break it.

**Price snapshot in OrderItem:** `OrderItem.price` captures the price at order creation time. It is not a foreign key to the current product price. This means historical orders remain accurate even when product prices are updated. Always write the current `product.price` (or `effective_price`) to `OrderItem.price` at order time — never store a reference.

**Slug-based product URLs:** Products are accessed via `slug` (e.g., `/product/oslo-velvet-sofa`) rather than numeric ID. This is SEO-friendly and avoids leaking database primary keys in URLs. Do not change this to ID-based routing.

**Cart is frontend-primary:** The React Context + localStorage cart is the source of truth for all UI. The backend session cart endpoints (`/api/cart/*`) are secondary and exist for future mobile app compatibility. The frontend does not read the session cart for rendering purposes — only for merging on login (Phase 2).

### Branch Naming

| Type | Format | Example |
|------|--------|---------|
| Feature | `feature/<name>` | `feature/razorpay-integration` |
| Bug fix | `fix/<name>` | `fix/category-slug-casing` |
| Chore / infra | `chore/<name>` | `chore/add-playwright-config` |
| Documentation | `docs/<name>` | `docs/update-api-reference` |

### PR Requirements

- Backend PRs: `python manage.py test` must pass with no failures
- Frontend PRs: `npm test` must pass with no failures
- New features must include tests
- New API endpoints must include request/response documentation in a comment or in this doc
- Database schema changes require a migration — never modify tables directly

### Common Commands

```bash
# Backend
python manage.py test                       # Run all tests
python manage.py test <appname>             # Run app tests
python manage.py makemigrations <appname>   # Create migration
python manage.py migrate                    # Apply migrations
python manage.py seed_products              # Seed sample data
python manage.py shell                      # Django shell

# Frontend
npm run dev          # Start dev server (http://localhost:5173)
npm run build        # Production build (output: dist/)
npm test             # Run component tests
npm run lint         # ESLint check

# E2E
npx playwright test              # Run all E2E tests
npx playwright test checkout     # Run specific spec
npx playwright show-report       # Open HTML report
```

---

*FurniShop Engineering Documentation — v1.0*
*For issues, questions, or updates: open a PR against this file on the `main` branch.*
