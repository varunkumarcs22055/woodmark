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

export const fetchCategories = () =>
  api.get('/products/categories/').then((r) => r.data);

// Admin product CRUD (planned — Backend Prompt 5)
export const adminCreateProduct = (data) =>
  api.post('/products/admin/', data).then((r) => r.data);

export const adminUpdateProduct = (id, data) =>
  api.put(`/products/admin/${id}/`, data).then((r) => r.data);

export const adminDeleteProduct = (id) =>
  api.delete(`/products/admin/${id}/`).then((r) => r.data);

// ─── Auth ───────────────────────────────────────────────────────────
export const registerUser = (data) =>
  api.post('/auth/register/', data).then((r) => r.data);

export const loginUser = (data) =>
  api.post('/auth/login/', data).then((r) => r.data);

export const logoutUser = (refresh) =>
  api.post('/auth/logout/', { refresh }).then((r) => r.data);

export const fetchProfile = () =>
  api.get('/auth/profile/').then((r) => r.data);

export const updateProfile = (data) =>
  api.patch('/auth/profile/', data).then((r) => r.data);

export const applyForDealer = (data) =>
  api.post('/auth/dealer-apply/', data).then((r) => r.data);

export const fetchUsers = (params = {}) =>
  api.get('/auth/users/', { params }).then((r) => r.data);

export const approveDealer = (userId, action) =>
  api.patch(`/auth/dealers/${userId}/approve/`, { dealer_status: action }).then((r) => r.data);

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
  api.post('/orders/create/', data).then((r) => r.data);

export const fetchOrders = (email) =>
  api.get('/orders/', { params: email ? { email } : {} }).then((r) => r.data);

export const fetchAllOrders = (params = {}) =>
  api.get('/orders/all/', { params }).then((r) => r.data);

export const updateOrderStatus = (id, orderStatus) =>
  api.patch(`/orders/${id}/status/`, { order_status: orderStatus }).then((r) => r.data);

export const retryErpSync = (orderId) =>
  api.post(`/orders/${orderId}/retry-erp/`).then((r) => r.data);

// ─── Payments ───────────────────────────────────────────────────────
export const createRazorpayOrder = (orderId) =>
  api.post('/payment/create-razorpay-order/', { order_id: orderId }).then((r) => r.data);

export const verifyPayment = (data) =>
  api.post('/payment/verify/', data).then((r) => r.data);

export const simulatePayment = (orderId) =>
  api.post('/payment/success/', { order_id: orderId }).then((r) => r.data);

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

export default api;
