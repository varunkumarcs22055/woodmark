/**
 * API Service Layer
 *
 * Centralized API client using Axios.
 * All backend communication goes through these functions.
 * Base URL is configured via Vite proxy (/api → Django backend).
 */

import axios from 'axios';

// Create Axios instance with defaults
const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 15000, // 15 second timeout
});

// ─── Products API ──────────────────────────────────────────────────

/**
 * Fetch paginated product list with optional filters.
 * @param {Object} params - Query parameters
 * @param {string} [params.category] - Category slug filter
 * @param {number} [params.price_min] - Minimum price
 * @param {number} [params.price_max] - Maximum price
 * @param {string} [params.material] - Material filter
 * @param {string} [params.search] - Search query
 * @param {string} [params.ordering] - Sort field (e.g., 'price', '-price', '-created_at')
 * @param {number} [params.page] - Page number
 */
export const fetchProducts = async (params = {}) => {
  const response = await api.get('/products/', { params });
  return response.data;
};

/**
 * Fetch single product by slug.
 * @param {string} slug - Product slug
 */
export const fetchProduct = async (slug) => {
  const response = await api.get(`/products/${slug}/`);
  return response.data;
};

/**
 * Fetch similar products by product ID.
 * @param {number} productId - Product ID
 */
export const fetchSimilarProducts = async (productId) => {
  const response = await api.get(`/products/similar/${productId}/`);
  return response.data;
};

/**
 * Fetch all categories.
 */
export const fetchCategories = async () => {
  const response = await api.get('/products/categories/');
  return response.data;
};

// ─── Orders API ────────────────────────────────────────────────────

/**
 * Create a new order.
 * @param {Object} orderData - Order payload
 * @param {string} orderData.user_name
 * @param {string} orderData.user_email
 * @param {string} orderData.phone
 * @param {string} orderData.address
 * @param {Array} orderData.items - [{product_id, quantity}]
 */
export const createOrder = async (orderData) => {
  const response = await api.post('/orders/create/', orderData);
  return response.data;
};

/**
 * Fetch orders by email.
 * @param {string} email - Customer email
 */
export const fetchOrders = async (email) => {
  const response = await api.get('/orders/', { params: { email } });
  return response.data;
};

// ─── Payment API ───────────────────────────────────────────────────

/**
 * Simulate payment success for an order.
 * @param {string} orderId - The order_id (e.g., "ORD-XXXXXXXX")
 */
export const simulatePayment = async (orderId) => {
  const response = await api.post('/payment/success/', { order_id: orderId });
  return response.data;
};

export default api;
