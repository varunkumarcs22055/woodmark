# Frontend Prompt 1 — Project Setup, Design System, Global Layout & API Layer

## Role
You are a senior frontend engineer at a FAANG company. Build the production-grade React foundation for FurniShop: Vite project setup, global design system (CSS variables), API service layer with JWT interceptors, AuthContext, CartContext, App routing, Navbar, and Footer.

**Use Claude Artifacts / Design tool for visual design decisions. Use Claude Opus for the implementation.**

---

## Context
This is **Frontend Prompt 1 of 7** — the foundation everything else depends on. The design language is premium and clean, inspired by Featherlite and Livspace: warm off-white backgrounds, deep charcoal text, teal/green accent colors, generous white space, elegant serif/sans-serif type pairing.

**Backend API:** Django at `http://127.0.0.1:8000/api` (proxied via Vite as `/api` in development)
**Depends on:** Backend Prompts 1–3 must be running
**Required by:** All other frontend prompts

---

## Target File Structure

```
frontend/
├── public/
│   └── favicon.ico
├── src/
│   ├── App.jsx
│   ├── App.css
│   ├── main.jsx
│   ├── index.css              ← Global CSS variables & reset
│   ├── api/
│   │   └── index.js           ← Axios instance + all API functions
│   ├── context/
│   │   ├── CartContext.jsx    ← Cart state (useReducer + localStorage)
│   │   └── AuthContext.jsx    ← JWT auth state + role
│   ├── hooks/
│   │   └── useAuth.js         ← Convenience hook
│   ├── utils/
│   │   └── format.js          ← Price formatting, date helpers
│   ├── components/
│   │   ├── Navbar.jsx
│   │   ├── Navbar.css
│   │   ├── Footer.jsx
│   │   ├── Footer.css
│   │   ├── ProtectedRoute.jsx
│   │   └── RoleRoute.jsx
│   └── pages/
│       └── (empty — populated in later prompts)
├── index.html
├── vite.config.js
└── package.json
```

---

## Dependencies — `package.json`

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.0",
    "axios": "^1.7.0",
    "swiper": "^12.1.3",
    "react-hot-toast": "^2.4.1",
    "react-icons": "^5.3.0",
    "jwt-decode": "^4.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.0",
    "vite": "^5.4.0"
  }
}
```

Install: `npm install`

---

## Vite Config — `vite.config.js`

```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
      },
      '/social-auth': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
      },
    },
  },
});
```

---

## Global Design System — `src/index.css`

Define CSS custom properties for the entire design system. Do not use Tailwind.

```css
/* ─── Design Tokens ─────────────────────────────────────────── */
:root {
  /* Brand Colors */
  --color-primary: #00736A;        /* Teal — main brand color */
  --color-primary-dark: #005C54;   /* Darker teal for hover */
  --color-primary-light: #E6F4F3;  /* Light teal for backgrounds */
  --color-accent: #C8A97E;         /* Warm gold accent */
  --color-accent-dark: #A8894E;

  /* Neutrals */
  --color-bg: #FAFAF7;             /* Warm off-white page background */
  --color-surface: #FFFFFF;        /* Card/panel background */
  --color-border: #E8E8E3;         /* Subtle borders */
  --color-border-dark: #C8C8C0;    /* Stronger borders */

  /* Text */
  --color-text-primary: #1A1A1A;   /* Near-black heading text */
  --color-text-secondary: #5A5A5A; /* Body text */
  --color-text-muted: #8A8A8A;     /* Captions, metadata */
  --color-text-inverse: #FAFAF7;   /* Text on dark backgrounds */

  /* Status Colors */
  --color-success: #2E7D32;
  --color-success-bg: #E8F5E9;
  --color-error: #C62828;
  --color-error-bg: #FFEBEE;
  --color-warning: #E65100;
  --color-warning-bg: #FFF3E0;

  /* Typography */
  --font-heading: 'Georgia', 'Times New Roman', serif;
  --font-body: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', monospace;

  /* Font Sizes */
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;
  --text-4xl: 2.25rem;
  --text-5xl: 3rem;

  /* Spacing */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-5: 1.25rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-10: 2.5rem;
  --space-12: 3rem;
  --space-16: 4rem;
  --space-20: 5rem;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.06);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
  --shadow-lg: 0 8px 24px rgba(0,0,0,0.12);
  --shadow-xl: 0 16px 48px rgba(0,0,0,0.16);

  /* Transitions */
  --transition-fast: 0.15s ease;
  --transition-base: 0.2s ease;
  --transition-slow: 0.3s ease;

  /* Layout */
  --max-width: 1440px;
  --container-padding: 1.5rem;
  --navbar-height: 72px;
}

/* ─── Reset ─────────────────────────────────────────────────── */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}
html { scroll-behavior: smooth; }
body {
  font-family: var(--font-body);
  background-color: var(--color-bg);
  color: var(--color-text-primary);
  font-size: var(--text-base);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
}
img { max-width: 100%; height: auto; display: block; }
a { text-decoration: none; color: inherit; }
button { cursor: pointer; border: none; background: none; font-family: inherit; }
input, textarea, select { font-family: inherit; }

/* ─── Utility Classes ────────────────────────────────────────── */
.container {
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 var(--container-padding);
}
.sr-only {
  position: absolute; width: 1px; height: 1px; padding: 0;
  margin: -1px; overflow: hidden; clip: rect(0,0,0,0); border: 0;
}
.btn-primary {
  display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem;
  background: var(--color-primary); color: var(--color-text-inverse);
  padding: 0.75rem 1.5rem; border-radius: var(--radius-md);
  font-size: var(--text-base); font-weight: 600;
  transition: background var(--transition-base), transform var(--transition-fast);
}
.btn-primary:hover { background: var(--color-primary-dark); transform: translateY(-1px); }
.btn-primary:active { transform: translateY(0); }
.btn-outline {
  display: inline-flex; align-items: center; justify-content: center;
  border: 1.5px solid var(--color-primary); color: var(--color-primary);
  padding: 0.75rem 1.5rem; border-radius: var(--radius-md);
  font-size: var(--text-base); font-weight: 600;
  transition: all var(--transition-base);
}
.btn-outline:hover { background: var(--color-primary-light); }
.badge {
  display: inline-flex; align-items: center;
  padding: 0.25rem 0.625rem; border-radius: var(--radius-full);
  font-size: var(--text-xs); font-weight: 600; letter-spacing: 0.03em;
}
.badge-success { background: var(--color-success-bg); color: var(--color-success); }
.badge-error { background: var(--color-error-bg); color: var(--color-error); }
.badge-warning { background: var(--color-warning-bg); color: var(--color-warning); }

/* ─── Scrollbar ──────────────────────────────────────────────── */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: var(--color-bg); }
::-webkit-scrollbar-thumb { background: var(--color-border-dark); border-radius: var(--radius-full); }
```

---

## API Layer — `src/api/index.js`

```javascript
import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_BASE_URL || '/api';

const api = axios.create({
  baseURL: API_BASE,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
});

// ── Request Interceptor: Attach JWT access token ──────────────
api.interceptors.request.use(
  (config) => {
    const accessToken = window.__accessToken;  // Stored in memory (not localStorage)
    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// ── Response Interceptor: Auto-refresh on 401 ─────────────────
let isRefreshing = false;
let failedQueue = [];

const processQueue = (error, token = null) => {
  failedQueue.forEach((prom) => {
    if (error) prom.reject(error);
    else prom.resolve(token);
  });
  failedQueue = [];
};

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
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
        const res = await axios.post(`${API_BASE}/auth/token/refresh/`, { refresh: refreshToken });
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

// ── Products ──────────────────────────────────────────────────
export const fetchProducts = (params = {}) =>
  api.get('/products/', { params }).then((r) => r.data);

export const fetchProduct = (slug) =>
  api.get(`/products/${slug}/`).then((r) => r.data);

export const fetchSimilarProducts = (productId) =>
  api.get(`/products/similar/${productId}/`).then((r) => r.data);

export const fetchCategories = () =>
  api.get('/products/categories/').then((r) => r.data);

// ── Auth ──────────────────────────────────────────────────────
export const registerUser = (data) =>
  api.post('/auth/register/', data).then((r) => r.data);

export const loginUser = (data) =>
  api.post('/auth/login/', data).then((r) => r.data);

export const logoutUser = (refresh) =>
  api.post('/auth/logout/', { refresh }).then((r) => r.data);

export const fetchProfile = () =>
  api.get('/auth/profile/').then((r) => r.data);

export const applyForDealer = (data) =>
  api.post('/auth/dealer-apply/', data).then((r) => r.data);

// ── Cart (session-based) ──────────────────────────────────────
export const fetchCartAPI = () =>
  api.get('/cart/').then((r) => r.data);

export const addToCartAPI = (productId, quantity = 1) =>
  api.post('/cart/add/', { product_id: productId, quantity }).then((r) => r.data);

export const removeFromCartAPI = (productId) =>
  api.post('/cart/remove/', { product_id: productId }).then((r) => r.data);

export const clearCartAPI = () =>
  api.post('/cart/clear/').then((r) => r.data);

// ── Orders ────────────────────────────────────────────────────
export const createOrder = (data) =>
  api.post('/orders/create/', data).then((r) => r.data);

export const fetchOrders = (email) =>
  api.get('/orders/', { params: email ? { email } : {} }).then((r) => r.data);

export const fetchAllOrders = (params = {}) =>
  api.get('/orders/all/', { params }).then((r) => r.data);

export const updateOrderStatus = (id, orderStatus) =>
  api.patch(`/orders/${id}/status/`, { order_status: orderStatus }).then((r) => r.data);

// ── Payments ──────────────────────────────────────────────────
export const createRazorpayOrder = (orderId) =>
  api.post('/payment/create-razorpay-order/', { order_id: orderId }).then((r) => r.data);

export const verifyPayment = (data) =>
  api.post('/payment/verify/', data).then((r) => r.data);

export const simulatePayment = (orderId) =>
  api.post('/payment/success/', { order_id: orderId }).then((r) => r.data);

// ── Discounts (Admin) ─────────────────────────────────────────
export const fetchDiscounts = (params = {}) =>
  api.get('/discounts/', { params }).then((r) => r.data);

export const createDiscount = (data) =>
  api.post('/discounts/', data).then((r) => r.data);

export const updateDiscount = (id, data) =>
  api.put(`/discounts/${id}/`, data).then((r) => r.data);

export const deleteDiscount = (id) =>
  api.delete(`/discounts/${id}/`).then((r) => r.data);

export default api;
```

---

## CartContext — `src/context/CartContext.jsx`

```javascript
import { createContext, useContext, useReducer } from 'react';

const CartContext = createContext();

const STORAGE_KEY = 'furnishop_cart';

const loadCart = () => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored ? JSON.parse(stored) : [];
  } catch {
    return [];
  }
};

const saveCart = (items) => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
};

const cartReducer = (state, action) => {
  let next;
  switch (action.type) {
    case 'ADD_ITEM': {
      const { product, quantity = 1 } = action.payload;
      const idx = state.findIndex((i) => i.product.id === product.id);
      if (idx >= 0) {
        next = state.map((item, i) =>
          i === idx ? { ...item, quantity: item.quantity + quantity } : item
        );
      } else {
        next = [...state, { product, quantity }];
      }
      break;
    }
    case 'REMOVE_ITEM':
      next = state.filter((i) => i.product.id !== action.payload);
      break;
    case 'UPDATE_QUANTITY': {
      const { productId, quantity } = action.payload;
      if (quantity <= 0) {
        next = state.filter((i) => i.product.id !== productId);
      } else {
        next = state.map((i) =>
          i.product.id === productId ? { ...i, quantity } : i
        );
      }
      break;
    }
    case 'CLEAR_CART':
      next = [];
      break;
    default:
      return state;
  }
  saveCart(next);
  return next;
};

export function CartProvider({ children }) {
  const [cartItems, dispatch] = useReducer(cartReducer, [], loadCart);

  const cartTotal = cartItems.reduce(
    (sum, item) =>
      sum + parseFloat(item.product.effective_price ?? item.product.price) * item.quantity,
    0
  );
  const cartCount = cartItems.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <CartContext.Provider value={{
      cartItems,
      cartTotal,
      cartCount,
      addToCart: (product, qty = 1) => dispatch({ type: 'ADD_ITEM', payload: { product, quantity: qty } }),
      removeFromCart: (id) => dispatch({ type: 'REMOVE_ITEM', payload: id }),
      updateQuantity: (id, qty) => dispatch({ type: 'UPDATE_QUANTITY', payload: { productId: id, quantity: qty } }),
      clearCart: () => dispatch({ type: 'CLEAR_CART' }),
    }}>
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart must be used inside CartProvider');
  return ctx;
}
```

---

## AuthContext — `src/context/AuthContext.jsx`

```javascript
import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { jwtDecode } from 'jwt-decode';
import { fetchProfile, logoutUser } from '../api';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);      // { id, email, role, full_name, ... }
  const [loading, setLoading] = useState(true); // true while checking stored token

  // On mount: try to restore session from stored refresh token
  useEffect(() => {
    const restore = async () => {
      const refresh = localStorage.getItem('furnishop_refresh_token');
      if (!refresh) { setLoading(false); return; }
      try {
        // Trigger the Axios interceptor which will auto-refresh
        const profile = await fetchProfile();
        setUser(profile);
      } catch {
        localStorage.removeItem('furnishop_refresh_token');
      } finally {
        setLoading(false);
      }
    };
    restore();
  }, []);

  const login = useCallback((tokens, userProfile) => {
    window.__accessToken = tokens.access;
    localStorage.setItem('furnishop_refresh_token', tokens.refresh);
    setUser(userProfile);
  }, []);

  const logout = useCallback(async () => {
    const refresh = localStorage.getItem('furnishop_refresh_token');
    if (refresh) {
      try { await logoutUser(refresh); } catch { /* ignore */ }
    }
    window.__accessToken = null;
    localStorage.removeItem('furnishop_refresh_token');
    setUser(null);
  }, []);

  // Called from AuthCallbackPage after OAuth redirect
  const loginFromTokens = useCallback(async (tokens) => {
    window.__accessToken = tokens.access;
    localStorage.setItem('furnishop_refresh_token', tokens.refresh);
    try {
      const profile = await fetchProfile();
      setUser(profile);
    } catch {
      window.__accessToken = null;
      localStorage.removeItem('furnishop_refresh_token');
    }
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, loginFromTokens }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
```

---

## ProtectedRoute & RoleRoute — `src/components/ProtectedRoute.jsx`

```javascript
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <div className="loading-spinner">Loading...</div>;
  if (!user) return <Navigate to="/login" state={{ from: location }} replace />;
  return children;
}

export function RoleRoute({ children, allowedRoles }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <div className="loading-spinner">Loading...</div>;
  if (!user) return <Navigate to="/login" state={{ from: location }} replace />;
  if (!allowedRoles.includes(user.role)) {
    return <Navigate to="/" replace />;
  }
  return children;
}
```

---

## App.jsx — `src/App.jsx`

```javascript
import { Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import { ProtectedRoute, RoleRoute } from './components/ProtectedRoute';

// Pages (imported progressively as later prompts are completed)
import HomePage from './pages/HomePage';
import ProductDetailPage from './pages/ProductDetailPage';
import CartPage from './pages/CartPage';
import CheckoutPage from './pages/CheckoutPage';
import OrdersPage from './pages/OrdersPage';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import AuthCallbackPage from './pages/AuthCallbackPage';
import DealerApplyPage from './pages/DealerApplyPage';
import DealerDashboard from './pages/DealerDashboard';
import AdminDashboard from './pages/AdminDashboard';

import './App.css';

export default function App() {
  return (
    <>
      <Toaster
        position="top-right"
        toastOptions={{
          duration: 3000,
          style: {
            borderRadius: '10px',
            background: '#1A1A1A',
            color: '#FAFAF7',
            fontSize: '14px',
          },
        }}
      />
      <Navbar />
      <main className="main-content">
        <Routes>
          {/* Public */}
          <Route path="/" element={<HomePage />} />
          <Route path="/product/:slug" element={<ProductDetailPage />} />
          <Route path="/cart" element={<CartPage />} />
          <Route path="/checkout" element={<CheckoutPage />} />
          <Route path="/orders" element={<OrdersPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
          <Route path="/auth-callback" element={<AuthCallbackPage />} />
          <Route path="/dealer-apply" element={<DealerApplyPage />} />

          {/* Dealer only */}
          <Route path="/dealer-dashboard" element={
            <RoleRoute allowedRoles={['dealer']}>
              <DealerDashboard />
            </RoleRoute>
          } />

          {/* Admin only */}
          <Route path="/admin-dashboard/*" element={
            <RoleRoute allowedRoles={['admin']}>
              <AdminDashboard />
            </RoleRoute>
          } />
        </Routes>
      </main>
      <Footer />
    </>
  );
}
```

---

## main.jsx — `src/main.jsx`

```javascript
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { CartProvider } from './context/CartContext';
import { AuthProvider } from './context/AuthContext';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <AuthProvider>
        <CartProvider>
          <App />
        </CartProvider>
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>
);
```

---

## Utility Functions — `src/utils/format.js`

```javascript
export const formatPrice = (value) => {
  const num = typeof value === 'string' ? parseFloat(value) : value;
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(num);
};

export const formatDate = (isoString) => {
  return new Date(isoString).toLocaleDateString('en-IN', {
    day: 'numeric', month: 'short', year: 'numeric',
  });
};

export const truncate = (str, n = 80) =>
  str && str.length > n ? `${str.slice(0, n)}…` : str;

export const calcDiscountPercent = (original, effective) => {
  if (!effective || parseFloat(original) === 0) return 0;
  return Math.round((1 - parseFloat(effective) / parseFloat(original)) * 100);
};
```

---

## Navbar Component — `src/components/Navbar.jsx`

Build a **production-grade mega-menu navbar** with these sections:
1. **Announcement bar** (top strip):
   - **Default:** "Free shipping on orders above ₹2,999 | Call us: 1800-XXX-XXXX" (teal background)
   - **When `user.role === 'dealer'`:** swap to a **gold-gradient "Dealer Rates Active" ribbon** with copy *"💼 Dealer rates active · Your B2B prices are applied automatically across the site"* and a **"Dealer Portal →"** link on the right. This is critical — it's how dealers know they're seeing trade pricing while shopping on the public site.
2. **Main nav row**: Logo left, desktop nav links center, icon actions right (search, account, cart badge)
3. **Mega menu**: Dropdown with multi-column layout for each category. Each column shows a heading and items. Items link via `goTo(slug)` which navigates to `/?category=${slug}`.
4. **Search overlay**: Full-width search input with product suggestions on type
5. **Mobile drawer**: Hamburger → side drawer with accordion nav
6. **Account icon behavior**: If logged in → show user menu (Profile, My Orders, [Admin Dashboard or Dealer Portal based on role], Logout). If not logged in → link to `/login`.

**Note on full-screen routes:** App.jsx hides the global Navbar AND Footer on
`/admin-dashboard/*` and `/dealer-dashboard/*` (they have their own sidebar
shells). Detect this via `useLocation().pathname` and skip rendering the
Navbar/Footer when those prefixes match.

**NAV_ITEMS array** (slugs MUST match seeded category slugs exactly):
```javascript
const NAV_ITEMS = [
  {
    label: 'Sofas & Seating',
    columns: [
      { heading: 'Sofas', items: [
        { label: 'All Sofas', slug: 'sofas' },
        { label: 'Corner Sofas', slug: 'sofas' },
        { label: 'Recliners', slug: 'sofas' },
      ]},
      { heading: 'Chairs', items: [
        { label: 'All Chairs', slug: 'chairs' },
        { label: 'Accent Chairs', slug: 'chairs' },
        { label: 'Office Chairs', slug: 'chairs' },
      ]},
    ],
  },
  {
    label: 'Tables',
    columns: [
      { heading: 'Tables', items: [
        { label: 'Dining Tables', slug: 'tables' },
        { label: 'Coffee Tables', slug: 'tables' },
        { label: 'Marble Tables', slug: 'tables' },
      ]},
      { heading: 'Dining Sets', items: [
        { label: 'All Dining Sets', slug: 'dining-sets' },
        { label: '4-Seater Sets', slug: 'dining-sets' },
        { label: '6-Seater Sets', slug: 'dining-sets' },
      ]},
    ],
  },
  {
    label: 'Bedroom',
    columns: [
      { heading: 'Beds', items: [
        { label: 'All Beds', slug: 'beds' },
        { label: 'King Size', slug: 'beds' },
        { label: 'Queen Size', slug: 'beds' },
      ]},
      { heading: 'Storage', items: [
        { label: 'Wardrobes', slug: 'storage' },
        { label: 'Bookshelves', slug: 'storage' },
        { label: 'All Storage', slug: 'storage' },
      ]},
    ],
  },
  {
    label: 'Work & Study',
    columns: [
      { heading: 'Desks', items: [
        { label: 'All Desks', slug: 'desks' },
        { label: 'Standing Desks', slug: 'desks' },
        { label: 'Writing Desks', slug: 'desks' },
      ]},
    ],
  },
  {
    label: 'Outdoor',
    columns: [
      { heading: 'Outdoor', items: [
        { label: 'All Outdoor', slug: 'outdoor' },
        { label: 'Garden Benches', slug: 'outdoor' },
        { label: 'Lounge Sets', slug: 'outdoor' },
      ]},
    ],
  },
];
```

---

## Footer Component — `src/components/Footer.jsx`

Clean 4-column footer:
- Column 1: Logo, brand tagline, social icons (Instagram, Facebook, Pinterest)
- Column 2: Quick Links (Home, Products, About, Contact)
- Column 3: Customer Service (Track Order, Returns & Exchanges, FAQs, Contact Us)
- Column 4: Contact Info (address, phone, email, hours)
- Bottom bar: Copyright, Privacy Policy, Terms of Service

---

## Acceptance Criteria

- [ ] `npm run dev` starts dev server at `http://localhost:5173` with no errors
- [ ] `GET /api/products/` returns data in the browser (proxy working)
- [ ] CartContext persists items to localStorage — items survive page refresh
- [ ] AuthContext restores session from localStorage refresh token on page load
- [ ] `ProtectedRoute` redirects unauthenticated users to `/login`
- [ ] `RoleRoute` redirects users with wrong role to `/`
- [ ] Navbar renders mega menu on desktop (hover/click categories)
- [ ] Navbar renders mobile drawer on small screens
- [ ] Cart icon shows badge with item count
- [ ] Account icon shows login link when logged out, user menu when logged in
- [ ] Navbar category links navigate to `/?category=<slug>`
- [ ] Footer renders with all 4 columns
- [ ] No console errors in browser
