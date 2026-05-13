/**
 * API Service Layer
 *
 * Centralized Axios client with JWT auth interceptors.
 * - Access token kept in window.__accessToken (memory, not localStorage) to limit XSS risk.
 * - Refresh token stored in localStorage so sessions survive page reload.
 * - On 401 the response interceptor transparently refreshes and retries the request,
 *   queueing concurrent failures so they all share one refresh round-trip.
 */

import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_BASE_URL || '/api';

const api = axios.create({
  baseURL: API_BASE,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
});

// Heavy endpoints (order create, payment verify, ERP retry) hit a remote DB
// on GoDaddy and can legitimately take longer than the global 15s ceiling.
// Pass `longTimeout: true` via the per-call config to extend just those.
const LONG_TIMEOUT_MS = 60000;

// ─── Request Interceptor: attach access token ───────────────────────
api.interceptors.request.use(
  (config) => {
    const accessToken = window.__accessToken;
    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// ─── Response Interceptor: auto-refresh on 401 ──────────────────────
let isRefreshing = false;
let failedQueue = [];

const processQueue = (error, token = null) => {
  failedQueue.forEach((p) => {
    if (error) p.reject(error);
    else p.resolve(token);
  });
  failedQueue = [];
};

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    const status = error.response?.status;

    // Don't recurse if the failing call IS the refresh endpoint
    const isRefreshCall = originalRequest?.url?.includes('/auth/token/refresh');

    if (status === 401 && !originalRequest._retry && !isRefreshCall) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then((token) => {
          originalRequest.headers.Authorization = `Bearer ${token}`;
          return api(originalRequest);
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      const refreshToken = localStorage.getItem('furnishop_refresh_token');
      if (!refreshToken) {
        isRefreshing = false;
        return Promise.reject(error);
      }

      try {
        const res = await axios.post(`${API_BASE}/auth/token/refresh/`, {
          refresh: refreshToken,
        });
        const newAccessToken = res.data.access;
        // Backend has ROTATE_REFRESH_TOKENS=True, so the response also returns
        // a fresh refresh token that *replaces* the one we just used (the old
        // one is blacklisted server-side). If we don't persist the new value,
        // the next session restore in another tab / after reload will try to
        // refresh with a blacklisted token and the user gets bounced to /login.
        const newRefreshToken = res.data.refresh;
        if (newRefreshToken) {
          localStorage.setItem('furnishop_refresh_token', newRefreshToken);
        }
        window.__accessToken = newAccessToken;
        processQueue(null, newAccessToken);
        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError, null);
        window.__accessToken = null;
        localStorage.removeItem('furnishop_refresh_token');
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);

// ─── Products ───────────────────────────────────────────────────────
export const fetchProducts = (params = {}) =>
  api.get('/products/', { params }).then((r) => r.data);

export const fetchProduct = (slug) =>
  api.get(`/products/${slug}/`).then((r) => r.data);

export const fetchSimilarProducts = (productId) =>
  api.get(`/products/similar/${productId}/`).then((r) => r.data);

export const fetchLimitedOffers = (params = {}) =>
  api.get('/products/limited-offers/', { params }).then((r) => r.data);

export const fetchCategories = () =>
  api.get('/products/categories/').then((r) => r.data);

// Admin product CRUD (Backend Prompt 5).
// Pass `mediaFiles` (File[]) to upload images/videos; we switch to multipart and
// the backend forwards each file to Cloudinary via ProductMedia(file=…).
const buildProductFormData = (data, mediaFiles) => {
  const fd = new FormData();
  Object.entries(data).forEach(([k, v]) => {
    if (v === undefined || v === null) return;
    fd.append(k, typeof v === 'boolean' ? (v ? 'true' : 'false') : v);
  });
  mediaFiles.forEach((f) => fd.append('media', f));
  return fd;
};

export const adminCreateProduct = (data, { mediaFiles = [] } = {}) => {
  if (mediaFiles.length > 0) {
    return api.post('/products/admin/', buildProductFormData(data, mediaFiles), {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data);
  }
  return api.post('/products/admin/', data).then((r) => r.data);
};

export const adminUpdateProduct = (id, data, { mediaFiles = [] } = {}) => {
  if (mediaFiles.length > 0) {
    return api.put(`/products/admin/${id}/`, buildProductFormData(data, mediaFiles), {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data);
  }
  return api.put(`/products/admin/${id}/`, data).then((r) => r.data);
};

export const adminDeleteProductMedia = (mediaId) =>
  api.delete(`/products/media/${mediaId}/`).then((r) => r.data);

// Best Sellers — backend ranks by units sold in the trailing window.
// Returns { window_days, count, results: [...products with units_sold_in_window] }.
export const fetchBestSellers = ({ days = 30, limit = 12 } = {}) =>
  api.get('/products/best-sellers/', { params: { days, limit } }).then((r) => r.data);

// Quantity-aware delivery ETA for the PDP.
// Optional pincode adds the shipping-zone delay on top of the product rule.
export const fetchProductEta = (slug, { qty = 1, pincode } = {}) =>
  api.get(`/products/${slug}/eta/`, { params: { qty, ...(pincode ? { pincode } : {}) } })
    .then((r) => r.data);

// ─── Tags / keywords ──────────────────────────────────────────────
export const fetchTags = (params = {}) =>
  api.get('/products/tags/', { params }).then((r) => r.data);

export const fetchNavTags = () =>
  api.get('/products/nav-tags/').then((r) => r.data);

export const fetchAdminTags = () =>
  api.get('/products/admin/tags/').then((r) => r.data);

export const adminCreateTag = (data) =>
  api.post('/products/admin/tags/', data).then((r) => r.data);

export const adminUpdateTag = (id, data) =>
  api.patch(`/products/admin/tags/${id}/`, data).then((r) => r.data);

export const adminDeleteTag = (id) =>
  api.delete(`/products/admin/tags/${id}/`).then((r) => r.data);

export const adminDeleteProduct = (id) =>
  api.delete(`/products/admin/${id}/`).then((r) => r.data);

// ─── Auth ───────────────────────────────────────────────────────────
export const registerUser = (data) =>
  api.post('/auth/register/', data).then((r) => r.data);

export const loginUser = (data) =>
  api.post('/auth/login/', data).then((r) => r.data);

export const logoutUser = (refresh) =>
  api.post('/auth/logout/', { refresh }).then((r) => r.data);

export const requestPasswordReset = (email) =>
  api.post('/auth/password-reset/request/', { email }).then((r) => r.data);

export const confirmPasswordReset = (data) =>
  api.post('/auth/password-reset/confirm/', data).then((r) => r.data);

export const requestEmailOtp = (email) =>
  api.post('/auth/otp/request/', { email }).then((r) => r.data);

export const verifyEmailOtp = (email, code) =>
  api.post('/auth/otp/verify/', { email, code }).then((r) => r.data);

export const fetchProfile = () =>
  api.get('/auth/profile/').then((r) => r.data);

export const updateProfile = (data) =>
  api.patch('/auth/profile/', data).then((r) => r.data);

export const changePassword = (data) =>
  api.post('/auth/change-password/', data).then((r) => r.data);

export const fetchAddresses = () =>
  api.get('/auth/addresses/').then((r) => r.data);

export const createAddress = (data) =>
  api.post('/auth/addresses/', data).then((r) => r.data);

export const updateAddress = (id, data) =>
  api.patch(`/auth/addresses/${id}/`, data).then((r) => r.data);

export const deleteAddress = (id) =>
  api.delete(`/auth/addresses/${id}/`).then((r) => r.data);

// ─── Notifications ───────────────────────────────────────────────
export const fetchNotifications = (params = {}) =>
  api.get('/notifications/', { params }).then((r) => r.data);

export const fetchUnreadCount = () =>
  api.get('/notifications/unread-count/').then((r) => r.data);

export const markNotificationRead = (id) =>
  api.post(`/notifications/${id}/read/`).then((r) => r.data);

export const markAllNotificationsRead = () =>
  api.post('/notifications/read-all/').then((r) => r.data);

export const fetchNotificationPreferences = () =>
  api.get('/notifications/preferences/').then((r) => r.data);

export const updateNotificationPreferences = (data) =>
  api.patch('/notifications/preferences/', data).then((r) => r.data);

export const applyForDealer = (data) =>
  api.post('/auth/dealer-apply/', data).then((r) => r.data);

export const fetchUsers = (params = {}) =>
  api.get('/auth/users/', { params }).then((r) => r.data);

export const fetchDealerTiers = async () => {
  const res = await api.get('/admin/dealers/tiers/');
  return res.data;
};

export const createDealerTier = (data) =>
  api.post('/admin/dealers/tiers/', data).then((r) => r.data);

export const updateDealerTier = (id, data) =>
  api.patch(`/admin/dealers/tiers/${id}/`, data).then((r) => r.data);

export const deleteDealerTier = (id) =>
  api.delete(`/admin/dealers/tiers/${id}/`).then((r) => r.data);

export const approveDealer = async (id, status, extra = {}) => {
  const res = await api.patch(`/auth/dealers/${id}/approve/`, { dealer_status: status, ...extra });
  return res.data;
};

// ─── Cart (session-based; secondary to localStorage CartContext) ────
export const fetchCartAPI = () =>
  api.get('/cart/').then((r) => r.data);

export const addToCartAPI = (productId, quantity = 1) =>
  api.post('/cart/add/', { product_id: productId, quantity }).then((r) => r.data);

export const removeFromCartAPI = (productId) =>
  api.post('/cart/remove/', { product_id: productId }).then((r) => r.data);

export const clearCartAPI = () =>
  api.post('/cart/clear/').then((r) => r.data);

// ─── Orders ─────────────────────────────────────────────────────────
export const createOrder = (data) =>
  api.post('/orders/create/', data, { timeout: LONG_TIMEOUT_MS }).then((r) => r.data);

export const fetchOrders = (email) =>
  api.get('/orders/', { params: email ? { email } : {} }).then((r) => r.data);

export const fetchAllOrders = (params = {}) =>
  api.get('/orders/all/', { params }).then((r) => r.data);

export const fetchOrderDetail = (orderId, email) =>
  api.get(`/orders/${orderId}/`, { params: email ? { email } : {} }).then((r) => r.data);

export const reorderOrder = (orderId) =>
  api.post(`/orders/${orderId}/reorder/`).then((r) => r.data);

export const cancelOrder = (orderId, reason = '') =>
  api.post(`/orders/${orderId}/cancel/`, { reason }).then((r) => r.data);

export const requestOrderReturn = (orderId, reason) =>
  api.post(`/orders/${orderId}/return/`, { reason }).then((r) => r.data);

// "Notify me when in stock" — anyone (guest or signed-in) can subscribe.
export const subscribeStockAlert = (slug, email) =>
  api.post(`/products/${slug}/stock-alert/`, email ? { email } : {}).then((r) => r.data);

// Admin: audit logs (read-only).
export const fetchAuditLogs = (params = {}) =>
  api.get('/audit/', { params }).then((r) => r.data);

// Admin: per-dealer negotiated prices.
export const fetchNegotiatedPrices = (dealerId) =>
  api.get(`/admin/dealers/${dealerId}/negotiated-prices/`).then((r) => r.data);
export const upsertNegotiatedPrice = (dealerId, data) =>
  api.post(`/admin/dealers/${dealerId}/negotiated-prices/`, data).then((r) => r.data);
export const deleteNegotiatedPrice = (dealerId, id) =>
  api.delete(`/admin/dealers/${dealerId}/negotiated-prices/${id}/`).then((r) => r.data);

export const updateOrderStatus = (id, orderStatus) =>
  api.patch(`/orders/${id}/status/`, { order_status: orderStatus }).then((r) => r.data);

export const retryErpSync = (orderId) =>
  api.post(`/orders/${orderId}/retry-erp/`).then((r) => r.data);

// ─── Payments ───────────────────────────────────────────────────────
export const createRazorpayOrder = (orderId) =>
  api.post('/payment/create-razorpay-order/', { order_id: orderId },
    { timeout: LONG_TIMEOUT_MS }).then((r) => r.data);

export const verifyPayment = (data) =>
  api.post('/payment/verify/', data, { timeout: LONG_TIMEOUT_MS }).then((r) => r.data);

export const simulatePayment = (orderId) =>
  api.post('/payment/success/', { order_id: orderId },
    { timeout: LONG_TIMEOUT_MS }).then((r) => r.data);

// ─── Store Settings ─────────────────────────────────────────────────
export const fetchStoreSettings = () =>
  api.get('/settings/').then((r) => r.data);

export const updateStoreSettings = (data) =>
  api.patch('/settings/', data).then((r) => r.data);

// ─── Product Media ───────────────────────────────────────────────────
export const deleteProductMedia = (mediaId) =>
  api.delete(`/products/media/${mediaId}/`).then((r) => r.data);

// ─── Discounts (Admin) ──────────────────────────────────────────────
export const fetchDiscounts = (params = {}) =>
  api.get('/discounts/', { params }).then((r) => r.data);

export const createDiscount = (data) =>
  api.post('/discounts/', data).then((r) => r.data);

export const updateDiscount = (id, data) =>
  api.put(`/discounts/${id}/`, data).then((r) => r.data);

export const deleteDiscount = (id) =>
  api.delete(`/discounts/${id}/`).then((r) => r.data);

// ─── Admin Dashboard (consolidated, cached 60s) ─────────────────────
export const fetchAdminDashboard = () =>
  api.get('/admin/dashboard/').then((r) => r.data);

// ─── Customers (Admin) ─────────────────────────────────────────────
export const fetchCustomers = (params = {}) =>
  api.get('/admin/customers/', { params }).then((r) => r.data);

export const fetchCustomerDetail = (id) =>
  api.get(`/admin/customers/${id}/`).then((r) => r.data);

export const updateCustomer = (id, data) =>
  api.patch(`/admin/customers/${id}/`, data).then((r) => r.data);

// ─── Categories (Admin) ────────────────────────────────────────────
export const fetchAdminCategories = () =>
  api.get('/categories/admin/').then((r) => r.data);

export const fetchCategoryTree = () =>
  api.get('/categories/tree/').then((r) => r.data);

export const createCategory = (data) =>
  api.post('/categories/admin/', data).then((r) => r.data);

export const updateCategory = (id, data) =>
  api.patch(`/categories/admin/${id}/`, data).then((r) => r.data);

export const deleteCategory = (id) =>
  api.delete(`/categories/admin/${id}/`).then((r) => r.data);

// ─── Inventory ─────────────────────────────────────────────────────
export const fetchWarehouses = () =>
  api.get('/inventory/warehouses/').then((r) => r.data);

export const createWarehouse = (data) =>
  api.post('/inventory/warehouses/', data).then((r) => r.data);

export const fetchStockLevels = (params = {}) =>
  api.get('/inventory/levels/', { params }).then((r) => r.data);

export const createStockLevel = (data) =>
  api.post('/inventory/levels/', data).then((r) => r.data);

export const seedStockForAllProducts = (data) =>
  api.post('/inventory/seed-all/', data).then((r) => r.data);

export const fetchStockMovements = (stockLevelId) =>
  api.get(`/inventory/levels/${stockLevelId}/movements/`).then((r) => r.data);

export const adjustStock = (data) =>
  api.post('/inventory/adjust/', data).then((r) => r.data);

export const fetchLowStock = () =>
  api.get('/inventory/low-stock/').then((r) => r.data);

// ─── CMS ───────────────────────────────────────────────────────────
export const fetchAdminBanners = () =>
  api.get('/cms/admin/banners/').then((r) => r.data);
export const createBanner = (data) =>
  api.post('/cms/admin/banners/', data).then((r) => r.data);
export const updateBanner = (id, data) =>
  api.patch(`/cms/admin/banners/${id}/`, data).then((r) => r.data);
export const deleteBanner = (id) =>
  api.delete(`/cms/admin/banners/${id}/`).then((r) => r.data);

export const fetchAdminPages = () =>
  api.get('/cms/admin/pages/').then((r) => r.data);
export const createPage = (data) =>
  api.post('/cms/admin/pages/', data).then((r) => r.data);
export const updatePage = (id, data) =>
  api.patch(`/cms/admin/pages/${id}/`, data).then((r) => r.data);
export const deletePage = (id) =>
  api.delete(`/cms/admin/pages/${id}/`).then((r) => r.data);

export const fetchAdminFAQs = () =>
  api.get('/cms/admin/faqs/').then((r) => r.data);
export const createFAQ = (data) =>
  api.post('/cms/admin/faqs/', data).then((r) => r.data);
export const updateFAQ = (id, data) =>
  api.patch(`/cms/admin/faqs/${id}/`, data).then((r) => r.data);
export const deleteFAQ = (id) =>
  api.delete(`/cms/admin/faqs/${id}/`).then((r) => r.data);

export const fetchBanners = (placement) =>
  api.get('/cms/banners/', { params: placement ? { placement } : {} }).then((r) => r.data);

export const fetchContentBlock = (key) =>
  api.get(`/cms/content/${key}/`).then((r) => r.data);

export const fetchContentBlocks = (keys = []) =>
  api.get('/cms/content/', { params: keys.length ? { keys: keys.join(',') } : {} })
    .then((r) => r.data);

export const fetchAdminContentBlocks = () =>
  api.get('/cms/admin/content/').then((r) => r.data);
export const createContentBlock = (data) =>
  api.post('/cms/admin/content/', data).then((r) => r.data);
export const updateContentBlock = (id, data) =>
  api.patch(`/cms/admin/content/${id}/`, data).then((r) => r.data);
export const deleteContentBlock = (id) =>
  api.delete(`/cms/admin/content/${id}/`).then((r) => r.data);

export const fetchNewsletterSubscribers = () =>
  api.get('/cms/admin/newsletter/subscribers/').then((r) => r.data);
export const updateNewsletterSubscriber = (id, data) =>
  api.patch(`/cms/admin/newsletter/subscribers/${id}/`, data).then((r) => r.data);
export const fetchNewsletterCampaigns = () =>
  api.get('/cms/admin/newsletter/campaigns/').then((r) => r.data);
export const createNewsletterCampaign = (data) =>
  api.post('/cms/admin/newsletter/campaigns/', data).then((r) => r.data);
export const updateNewsletterCampaign = (id, data) =>
  api.patch(`/cms/admin/newsletter/campaigns/${id}/`, data).then((r) => r.data);

export const fetchNewsletterStats = () =>
  api.get('/cms/admin/newsletter/stats/').then((r) => r.data);

export const sendNewsletterCampaign = (data) =>
  api.post('/cms/admin/newsletter/send/', data).then((r) => r.data);

export const fetchNewsletterRecipients = (params = {}) =>
  api.get('/cms/admin/newsletter/recipients/', { params }).then((r) => r.data);

export const subscribeNewsletter = (email) =>
  api.post('/cms/newsletter/subscribe/', { email }).then((r) => r.data);

// ─── Invoices ──────────────────────────────────────────────────────
export const fetchInvoices = (params = {}) =>
  api.get('/invoices/', { params }).then((r) => r.data);

export const fetchInvoice = (id) =>
  api.get(`/invoices/${id}/`).then((r) => r.data);

// PDF endpoint URL — pass to <a href> or window.open. Browser tab handles auth-less link
// gracefully by failing the API call and we refetch — but to keep it simple, we surface a
// helper that fetches the blob and opens an object URL.
export const fetchInvoicePDFBlob = async (id, { download = false } = {}) => {
  const response = await api.get(`/invoices/${id}/pdf/`, {
    params: download ? { download: 1 } : {},
    responseType: 'blob',
  });
  return response.data;
};

export const emailInvoice = (id, email) =>
  api.post(`/invoices/${id}/email/`, email ? { email } : {}).then((r) => r.data);

export const regenerateInvoice = (orderPk) =>
  api.post(`/invoices/regenerate/${orderPk}/`).then((r) => r.data);

// ─── Reviews & Ratings ─────────────────────────────────────────────
export const fetchProductReviews = (productId, params = {}) =>
  api.get('/reviews/', { params: { product_id: productId, ...params } }).then((r) => r.data);

export const fetchReviewSummary = (productId) =>
  api.get('/reviews/summary/', { params: { product_id: productId } }).then((r) => r.data);

export const createReview = (data) =>
  api.post('/reviews/create/', data).then((r) => r.data);

export const toggleReviewHelpful = (id) =>
  api.post(`/reviews/${id}/helpful/`).then((r) => r.data);

// Admin
export const fetchAdminReviews = (params = {}) =>
  api.get('/reviews/admin/', { params }).then((r) => r.data);

export const moderateReview = (id, status) =>
  api.patch(`/reviews/admin/${id}/`, { status }).then((r) => r.data);

export const deleteAdminReview = (id) =>
  api.delete(`/reviews/admin/${id}/`).then((r) => r.data);

// ─── Wishlist ──────────────────────────────────────────────────────
export const fetchWishlist = () =>
  api.get('/wishlist/').then((r) => r.data);

export const toggleWishlist = (productId, on) =>
  on
    ? api.post(`/wishlist/${productId}/`).then((r) => r.data)
    : api.delete(`/wishlist/${productId}/`).then((r) => r.data);

// ─── Dealer / B2B portal ───────────────────────────────────────────
export const fetchDealerDashboard = () =>
  api.get('/dealer/dashboard/').then((r) => r.data);

export const fetchDealerCredit = () =>
  api.get('/dealer/credit/').then((r) => r.data);

export const fetchDealerInvoices = (params = {}) =>
  api.get('/dealer/invoices/', { params }).then((r) => r.data);

export const fetchDealerPayments = (params = {}) =>
  api.get('/dealer/payments/', { params }).then((r) => r.data);

export const fetchDealerLedger = (params = {}) =>
  api.get('/dealer/ledger/', { params }).then((r) => r.data);

// Admin
export const fetchAdminDealerCredit = (dealerId) =>
  api.get(`/admin/dealers/${dealerId}/credit/`).then((r) => r.data);

export const updateAdminDealerCredit = (dealerId, data) =>
  api.patch(`/admin/dealers/${dealerId}/credit/`, data).then((r) => r.data);

export const recordAdminDealerPayment = (dealerId, data) =>
  api.post(`/admin/dealers/${dealerId}/payments/`, data).then((r) => r.data);

// ─── Notifications ─────────────────────────────────────────────────
// ─── Coupons ────────────────────────────────────────────────────────
export const validateCoupon = (code, subtotal) =>
  api.post('/coupons/validate/', { code, subtotal }).then((r) => r.data);

export const fetchAdminCoupons = () =>
  api.get('/coupons/admin/').then((r) => r.data);

export const createAdminCoupon = (data) =>
  api.post('/coupons/admin/', data).then((r) => r.data);

export const updateAdminCoupon = (id, data) =>
  api.patch(`/coupons/admin/${id}/`, data).then((r) => r.data);

export const deleteAdminCoupon = (id) =>
  api.delete(`/coupons/admin/${id}/`).then((r) => r.data);

// ─── Shipping ───────────────────────────────────────────────────────
export const estimateShipping = (data) =>
  api.post('/shipping/estimate/', data).then((r) => r.data);

export const fetchShippingZones = () =>
  api.get('/shipping/zones/admin/').then((r) => r.data);

export const createShippingZone = (data) =>
  api.post('/shipping/zones/admin/', data).then((r) => r.data);

export const updateShippingZone = (id, data) =>
  api.patch(`/shipping/zones/admin/${id}/`, data).then((r) => r.data);

export const deleteShippingZone = (id) =>
  api.delete(`/shipping/zones/admin/${id}/`).then((r) => r.data);

// ─── Dealer wallet ──────────────────────────────────────────────────
export const fetchDealerWallet = () =>
  api.get('/dealer/wallet/').then((r) => r.data);

export const adminWalletTopup = (dealerId, data) =>
  api.post(`/admin/dealers/${dealerId}/wallet/topup/`, data).then((r) => r.data);

// ─── Support tickets ────────────────────────────────────────────────
export const fetchTickets = (params = {}) =>
  api.get('/support/tickets/', { params }).then((r) => r.data);

export const fetchTicketDetail = (id) =>
  api.get(`/support/tickets/${id}/`).then((r) => r.data);

export const createTicket = (data) =>
  api.post('/support/tickets/', data).then((r) => r.data);

export const replyToTicket = (id, body, isInternal = false, attachmentUrl = '') =>
  api.post(`/support/tickets/${id}/messages/`, {
    body, is_internal_note: isInternal, attachment_url: attachmentUrl,
  }).then((r) => r.data);

export const updateTicketStatus = (id, status) =>
  api.patch(`/support/admin/tickets/${id}/status/`, { status }).then((r) => r.data);

// ─── Dealer bulk upload ─────────────────────────────────────────────
export const dealerBulkUpload = (formData) =>
  api.post('/dealer/orders/bulk-upload/', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }).then((r) => r.data);

export default api;
