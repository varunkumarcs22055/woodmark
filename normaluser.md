# FurniShop Retail User (B2C) Workflow Analysis

This document outlines the current state of the retail customer experience, covering discovery, purchase, and post-purchase engagement.

## 🟢 What is WORKING (Production Ready)

### 1. Premium Product Experience
- **Dynamic Product Pages**: High-quality gallery with zoom, technical specifications, DIY/Assembly notices, and YouTube video embeds.
- **Delivery ETA**: Real-time pincode-based delivery estimation logic is integrated into the product detail page.
- **SEO Optimization**: Automatic generation of Meta Titles, Descriptions, and JSON-LD Product Schema for search engine visibility.

### 2. Discovery & Personalization
- **Wishlist System**: Fully functional wishlist buttons with persistent storage for logged-in users.
- **Advanced Filtering**: Support for categories, price ranges, and status-based filtering (e.g., Best Sellers).
- **Related Products**: Smart "You May Also Like" suggestions based on category similarity.

### 3. Trust & Social Proof
- **Review System**: Comprehensive review module with star ratings, verified purchase labels, and a visual star histogram (5-star breakdown).
- **Moderation Workflow**: Backend supports a moderation queue (reviews stay pending until Admin approval).

### 4. Checkout & Payments
- **Guest Checkout**: Supported without requiring an account.
- **Razorpay Integration**: Fully functional payment gateway (simulated in dev mode).
- **Coupon System**: Coupon code application with real-time discount validation.

---

## 🔴 What is MISSING / NOT WORKING (The Gaps)

### 1. Advanced Discovery
- **Visual Search Suggestions**: The search bar is a standard text input; it lacks real-time "Product Snapshots" or "Category Hints" as you type (FAANG level would have Algolia-style instant search).
- **Product Comparison**: No "Compare" tool to see specs of two chairs side-by-side.

### 2. Post-Purchase UI
- **Self-Service Cancellations**: Users can view orders but cannot trigger a "Cancel Order" request directly from the UI if the order is still in `CREATED` status.
- **Return Requests**: No frontend form for users to initiate a return/refund request (model exists but UI is missing).
- **Live Tracking Map**: Tracking is text-based (Carrier + ID). Integration with a map/tracking API (e.g., AfterShip) is not present.

### 3. Engagement & Retention
- **In-Stock Notifications**: If a product is "Out of Stock," there is no "Notify me when available" email signup button.
- **Loyalty/Wallet**: The Wallet system is currently exclusive to Dealers. Regular users do not have a "Store Credit" or "Rewards Points" system.
- **Review Media**: The review form is text-only. It does not support customer-uploaded photos or videos of the furniture in their homes.

### 4. Communication
- **SMTP Limitations**: Like the dealer portal, automated emails for "Order Confirmed" or "Welcome" rely on a skeleton SMTP setup and may fail silently without real server credentials.

---

## 🛠️ Recommended Roadmap for Retail
1. **Instant Search**: Implement a debounced search overlay with product thumbnails.
2. **Review Photos**: Add `ImageField` support to `ProductReview` model and a file-uploader to the frontend.
3. **Cancel/Return Buttons**: Add an "Action Menu" to the Order Detail page for self-service requests.
4. **Stock Alerts**: Create a `StockNotification` model to capture emails for OOS products.
