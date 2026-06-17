# Woodmark (FurniShop) — B2C & B2B Furniture E-commerce Platform

Woodmark is an enterprise-grade, dual-model e-commerce platform built to serve both retail customers (B2C) and wholesale dealers (B2B). Using a decoupled architecture consisting of a **React 18** frontend (Vite) and a **Django 5 & Django REST Framework (DRF)** backend, the platform supports complex wholesale pricing tier calculations, integrated B2B financial controls (dealer credit limits and wallets), a tax-compliant invoice generator, real-time ERP syncing, and dynamic image optimization via Cloudinary.

---

## 🚀 Technology Stack

### Frontend (SPA)
*   **Core**: React 18.3.1 (powered by Vite 8.0)
*   **Routing**: React Router DOM v6 (supports role-based routing and full-screen dashboard toggles)
*   **HTTP Client**: Axios (configured with response interceptors for automatic JWT access token refresh on 401 errors)
*   **Styling**: Responsive Vanilla CSS (optimized with fluid grids, flexbox, and modern HSL variables for dark mode support)
*   **UI Components & Utilities**:
    *   **React Icons**: SVG icon packs for navigation and layout indicators.
    *   **React Hot Toast**: Micro-animations for feedback, toast popups, and alert triggers.
    *   **Swiper**: Slider controls for responsive carousels on the product detail and landing pages.
    *   **JWT Decode**: Decodes token payloads to check permissions and user details.

### Backend (REST API)
*   **Core**: Django 5.1 & Django REST Framework (DRF) 3.15
*   **API Filters**: `django-filter` (enables search filters, price ranges, categories, and tags)
*   **Authentication**: SimpleJWT (secure JSON Web Token auth via headers)
*   **Social Sign-In**: `social-auth-app-django` & `social-auth-core` (pre-wired for Google OAuth integration)
*   **Database Integration**:
    *   **SQLite**: Used as a fast, configuration-free database for local development.
    *   **GoDaddy MariaDB**: Integrated via `PyMySQL` and `cryptography` driver settings for cost-efficient staging/production databases.
    *   **Neon Postgres**: Fully configured database adapter with `psycopg2-binary` and `dj-database-url` for cloud-hosted environments.
*   **Media Hosting & CDN**: `cloudinary` and `django-cloudinary-storage` for product image storage and delivery optimization.
*   **Transactional Messaging**: `django-anymail[brevo]` (Brevo integration for transactional email templates)
*   **Reporting & Exporters**:
    *   **ReportLab**: Generates PDF invoices and shipping labels.
    *   **OpenPyXL**: Processes Excel uploads for dealer bulk ordering and inventory sheets.

---

## 🎨 System Architecture

```
┌──────────────────┐       ┌──────────────────┐
│  Frontend (Vite) │  ──>  │  React Router    │
│  React 18, Axios │       │  Public + Admin  │
└──────────────────┘       └──────────────────┘
            │
            │ HTTPS  /api/*  (JWT bearer)
            v
┌─────────────────────────────────────────────────────┐
│              Django + DRF (8000)                    │
│                                                     │
│  Apps:                                              │
│   • users         (auth, dealer, admin permissions) │
│   • products      (catalog + variants + media)      │
│   • cart          (session-based)                   │
│   • orders        (order, items, returns, refunds)  │
│   • invoices      (billing + PDF invoicing)         │
│   • payments      (Razorpay + COD)                  │
│   • discounts     (per-tier, time-bound)            │
│   • inventory     (warehouses + stock movements)    │
│   • shipping      (zones + delivery estimator)      │
│   • notifications (in-app + email + sms stub)       │
│   • reviews       (ratings + moderation queue)      │
│   • wishlist      (wishlists)                       │
│   • cms           (banners, pages, faqs, blogs)     │
│   • media_lib     (Cloudinary asset registry)       │
│   • store_settings (global parameters)              │
│   • audit         (admin mutation log)              │
│                                                     │
│  Cross-cutting Services:                            │
│   • core/permissions.py   (IsAdminUser, IsDealer)   │
│   • services/erp.py       (ERP synchronization)     │
│   • services/notifications.py                       │
│   • services/invoice_pdf.py  (ReportLab rendering)  │
└─────────────────────────────────────────────────────┘
            │                                │
            v                                v
┌─────────────────────┐         ┌────────────────────────┐
│  Postgres / MariaDB │         │ External Services      │
│  All tables         │         │  • Cloudinary (media)  │
│  + audit log        │         │  • Razorpay (payments) │
│                     │         │  • Brevo / SMTP (mail) │
│                     │         │  • Twilio / SMS (stub) │
└─────────────────────┘         └────────────────────────┘
```

---

## 💡 What Makes Woodmark Unique? (Core Highlights)

1.  **Unified Front-Facing Storefront**: Rather than maintaining separate portals, both retail buyers and wholesale dealers shop on the exact same site layout. Backend middleware decodes JWT roles to dynamically adjust prices, payment methods, and dashboard links.
2.  **Tiered Pricing & Volume Precedence Engine**:
    *   Wholesale prices are resolved dynamically in the database matching a strict priority hierarchy:
        $$\text{Negotiated Price Override} \succ \text{Dealer Tier Base Discount} \times \text{Quantity-based Volume discount (Ladder Pricing)} \succ \text{Retail catalog Price}$$
    *   Calculations are processed on the backend and mapped to frontend page requests instantly to prevent layout flickering.
3.  **B2B Financial Operations**:
    *   Authorized dealers can order products on credit terms (**Credit Limit**) or use a prepaid B2B **Wallet**.
    *   Administrators can review and adjust credit limits, toggle credit eligibility, and check dealer transactions.
4.  **Tax Split Calculations (GST) & HSN Tracking**:
    *   Checks the shipping pincode to determine state lines: applies **CGST + SGST** (50/50 split) for intra-state transactions and **IGST** for inter-state transactions.
    *   Logs product-specific **HSN Codes** at checkout to render professional tax-compliant invoice records.
5.  **ERP Sync Monitor**:
    *   Integrates order dispatch status directly with external ERP databases.
    *   Provides administrators with detailed connection failure logs, status trackers, and single-click manual synchronization retries.
6.  **Granular Admin Mutation Auditing**:
    *   Saves a record of every administrative database update (price modifications, customer status adjustments, wallet changes) to verify operational compliance.
7.  **B2B Bulk CSV Ordering**:
    *   Enables B2B dealers to upload a simple Excel/CSV listing SKUs and quantities to add hundreds of items to their cart in seconds.

---

## 🖥️ Frontend Functionality (Views & Portals)

The React SPA implements three primary operational interfaces:

### 1. B2C Retail User Views
*   **Landing Page**: Interactive sliders, category grids, brand cards, and limited-time offer boards.
*   **Product Detail Page (PDP)**: Swatch triggers for color and size variants, video players, PDF downloads, star reviews list, and a real-time shipping estimator.
*   **Checkout Flow**: Address selector, coupon code application, payment gateway options (Razorpay/COD), and billing totals summary.
*   **Account Hub**: Customer profile editor, order history checklist, wishlist dashboard, and notifications inbox.

### 2. B2B Dealer Portal (`/dealer-dashboard/*`)
*   **Dashboard Overview**: Financial widget tracking current credit limit, outstanding balance, wallet funds, and active billing terms.
*   **Bulk Order Uploader**: drag-and-drop CSV parser.
*   **Invoices Dashboard**: Detailed breakdown of generated invoice PDFs with direct download buttons.
*   **Support & Profile**: Support ticket launcher and company address registers.

### 3. Admin Control Board (`/admin-dashboard/*`)
*   **Business Overview**: Multi-KPI analytical blocks showing sales charts, visitor signups, low-stock warnings, and active orders.
*   **Catalog & Category Manager**: Detailed product forms (specs, variants, media upload fields) and recursive cycle-protected category tree grids.
*   **Customer & Dealer Approval List**: Grid listing dealer applicants, profile summaries, GSTIN validations, and buttons to approve, deny, or block users.
*   **ERP Sync Monitor**: Detailed dashboard for retrying failed synchronizations.
*   **CMS Controller**: Homepage banner visual designer, static legal pages generator, and FAQ cards editor.
*   **Review Queue**: Moderation checkboard to read pending reviews, verify purchases, and approve or delete comments.

---

## ⚙️ Backend Functionality (Django Apps)

The server codebase is structured into modular apps:
*   [users](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/users): Customer, dealer, and admin models. Manages profiles, dealer approvals, and token rules.
*   [products](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/products): Products catalog database, variants mapping, and specification lists.
*   [cart](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/cart): Server-side shopping cart storage backup.
*   [orders](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/orders): Order state engine (`CREATED` ➔ `CONFIRMED` ➔ `SHIPPED` ➔ `DELIVERED` / `CANCELLED`), returns tracker, and stock decrements.
*   [invoices](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/invoices): Compiles CGST/SGST/IGST tax splits and outputs ReportLab PDF documents.
*   [payments](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/payments): Razorpay handshake handlers, payment verification, and webhook signature checkers.
*   [discounts](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/discounts): Holds B2B tiered discounts, promotion campaigns, and voucher coupons.
*   [inventory](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/inventory): Warehouse listings, stock transfers, and low-stock indicators.
*   [shipping](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/shipping): Delivery zones, rates database, and SLA lookup maps.
*   [notifications](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/notifications): Formats in-app dashboard updates, email logs, and SMS notifications.
*   [reviews](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/reviews) / [wishlist](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/wishlist): User reviews database and personalized wishlist registries.
*   [cms](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/cms): Models for FAQs, banners, and dynamic markdown pages.
*   [audit](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/audit): Track logs for security auditing.
*   [store_settings](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/store_settings): Global settings singleton (flat-rate limits, free-shipping values).

---

## ☁️ Cloudinary Integration

Woodmark offloads asset serving to Cloudinary for optimized performance:
*   **Media Catalog Sync**: Product media uploads are sent to Cloudinary and registered under the `ProductMedia` model.
*   **Asset Delivery & Optimization**: Auto-delivers optimized images (WebP/AVIF format) customized for the requesting client browser size using Cloudinary parameters.
*   **Promotional CMS Headers**: Landing page hero images are dynamically cropped and cached directly on edge servers to speed up content delivery.

---

## 🚀 Deployment Guide

### 1. Backend Service (Render)
1. Navigate to the **Render Console** and select **New + ➔ Blueprint**.
2. Connect your repository. Render reads [render.yaml](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/render.yaml) to initialize resources.
3. Supply the following environment variables:
   *   `DATABASE_URL`: Staging database URI (e.g. `mysql://user:pass@host:3306/db` or Postgres URI).
   *   `CLOUDINARY_CLOUD_NAME` / `CLOUDINARY_API_KEY` / `CLOUDINARY_API_SECRET`: Credentials from the Cloudinary dashboard.
   *   `CORS_ALLOWED_ORIGINS`: Address of your Vercel deployment (e.g. `https://<project>.vercel.app`).
   *   `FRONTEND_URL`: URL pointing to the deployed Vercel frontend.
   *   `VITE_RAZORPAY_ENABLED`: Set to `true` if active payment gateway keys are present.
   *   `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET` / `RAZORPAY_WEBHOOK_SECRET`: Live credentials from the Razorpay panel.
4. Render runs [build.sh](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/backend/build.sh), installing libraries from `requirements.txt`, collecting admin assets via WhiteNoise (`collectstatic`), and running migrations (`migrate`).

### 2. Frontend SPA (Vercel)
1. Open the **Vercel Dashboard** and click **Add New ➔ Project**.
2. Select your repository and set the **Root Directory** to `frontend`.
3. Vercel automatically detects the Vite config using the [vercel.json](file:///c:/Users/Lenovo/OneDrive/Desktop/woodmark/frontend/vercel.json) build instructions.
4. Configure the environment variables:
   *   `VITE_API_BASE_URL`: Deployed backend endpoint URL (e.g., `https://<service>.onrender.com/api`).
   *   `VITE_RAZORPAY_ENABLED`: Set to `false` for payment simulations, or `true` for live checkouts.
5. Trigger the production build and deployment.

---

## 🛠️ Local Development Setup

Ensure you have Python 3.10+ and Node.js 18+ installed.

### Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Set up and activate a Python virtual environment:
   ```bash
   python -m venv venv
   # Windows:
   .\venv\Scripts\activate
   # macOS/Linux:
   source venv/bin/activate
   ```
3. Install the required Python packages:
   ```bash
   pip install -r requirements.txt
   ```
4. Copy the environment variables example file:
   ```bash
   cp .env.example .env
   ```
5. Apply database migrations:
   ```bash
   python manage.py migrate
   ```
6. Seed development and testing users:
   ```bash
   python manage.py seed_admin
   ```
   *This initializes default testing credentials: admin (`dev-admin@woodmark.local`), retail user (`dev-user@woodmark.local`), and dealer (`dev-dealer@woodmark.local`). The password for all generated accounts is `password`.*
7. Run the local development server:
   ```bash
   python manage.py runserver
   ```
   The backend API will run on `http://127.0.0.1:8000`.

### Frontend Setup
1. Open a new terminal and navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Install npm packages:
   ```bash
   npm install
   ```
3. Run the development server:
   ```bash
   npm run dev
   ```
   The frontend UI will run on `http://localhost:5173`.

### Developer Quick-Login Panel
In development mode, the `/login` page displays a yellow helper panel. Click **As User**, **As Dealer**, or **As Admin** to instantly synthesize a testing JWT and access the corresponding dashboard, bypassing manual authentication.

---

## 📍 Project Roadmap & Improvements
*   [ ] **Typeahead Instant Search**: Live product suggestions overlay as the user types in the search bar.
*   [ ] **Detailed Ledger Statements**: Expand the Wallet panel to list line-item debit/credit transactions for dealers.
*   [ ] **Negotiated Price Grid Interface**: Build admin-panel tables to easily manage dealer-specific override entries.
*   [ ] **Review Uploader**: Allow customers to upload photos and videos to product reviews.
*   [ ] **SMTP Background Workers**: Set up Celery and Redis to handle asynchronous newsletter mail blasts and transactional queues.
