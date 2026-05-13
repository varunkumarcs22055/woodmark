# FurniShop Admin Dashboard Analysis

This document outlines the current state of the administrative management interface, identifying operational strengths and critical gaps for high-scale e-commerce management.

## 🟢 What is WORKING (Production Ready)

### 1. Robust Core Management
- **Unified Product Catalog**: full CRUD support for products, including multi-tier volume pricing, inventory tracking, and rich media galleries.
- **Dynamic Order Management**: Status workflow (Created → Confirmed → Shipped → Delivered) with integrated tracking ID updates and ERP sync tracking.
- **Role-Based User Oversight**: Ability to manage retail customers, verify/approve dealers, and block fraudulent accounts.

### 2. Operational Resilience
- **ERP Integration Monitor**: A sophisticated dashboard to track synchronization with the backend ERP system, featuring single-click retries and bulk error resolution.
- **Financial Controls**: granular control over Dealer Credit limits and Wallet balances directly from the customer profile.
- **Review Moderation**: A "Verified Purchase" review queue allowing admins to approve or reject customer feedback before it goes live.

### 3. CMS & Marketing
- **Content Blocks**: Flexible management of Home Hero banners, SEO pages (About Us, Terms), and dynamic FAQs.
- **Coupon & Discount Engine**: specialized UI for creating time-bound coupons and global store-wide discount campaigns.
- **Subscriber Management**: Centralized list of newsletter subscribers with segment filtering (Customers vs. Dealers).

---

## 🔴 What is MISSING / NOT WORKING (The Gaps)

### 1. B2B Management Gaps
- **Negotiated Pricing UI**: While the database supports setting a unique price for a specific dealer (e.g., "Dealer John gets Chair X for ₹5000 fixed"), there is **no frontend UI** to manage these overrides.
- **Credit Note Processing**: No interface to issue a partial refund or "Credit Note" back to a dealer's credit limit for returned or damaged goods.

### 2. Marketing Automation
- **Email Blast Execution**: The Newsletter "Compose" tool currently only saves campaigns. It does **not trigger the actual email delivery** due to a lack of a configured SMTP worker (Celery/Redis).
- **Campaign Analytics**: No visibility into newsletter performance (Open Rates, Click-Through Rates, or Revenue Attribution).

### 3. Reporting & Advanced Logic
- **Advanced Analytics**: The dashboard provides basic totals but lacks time-series trends (e.g., "Revenue vs. Last Month"), heatmaps for best-selling regions, or top-performing categories.
- **Granular RBAC**: All admins have full power. There is no "Junior Admin" or "Support Agent" role with restricted access (e.g., "Can handle support tickets but cannot see financial revenue").
- **Bulk Product Import**: Admins must create products individually or via direct DB import; there is no UI for "Bulk Upload from CSV" for the product catalog.

### 4. Technical Debt
- **Audit Log Visibility**: Changes are recorded in the database (Audit table), but there is **no UI** for SuperAdmins to search and view these logs (e.g., "Who changed the price of SKU-123 at 3 AM?").

---

## 🛠️ Recommended Roadmap for Admin
1. **Audit Log Viewer**: Build a "System Logs" page to expose the `AuditEntry` table for security and accountability.
2. **Bulk Tools**: Add a CSV Import/Export module for bulk price and stock updates.
3. **Negotiated Price Grid**: Create a management table specifically for B2B price overrides.
4. **Email Worker**: Connect a real-world mail provider and implement a background queue for marketing campaigns.
