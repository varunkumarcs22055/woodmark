/**
 * App — Root component with routing and layout.
 *
 * The Admin and Dealer dashboards are full-screen apps with their own
 * sidebar navigation, so we hide the global Navbar / Footer / main-content
 * padding on those routes via useLocation.
 */
import { Routes, Route, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import ScrollToTop from './components/ScrollToTop';
import ErrorBoundary from './components/ErrorBoundary';
import { RoleRoute } from './components/ProtectedRoute';

import HomePage from './pages/HomePage';
import ProductDetailPage from './pages/ProductDetailPage';
import CartPage from './pages/CartPage';
import CheckoutPage from './pages/CheckoutPage';
import OrdersPage from './pages/OrdersPage';
import OrderDetailPage from './pages/OrderDetailPage';
import BestSellersPage from './pages/BestSellersPage';
import AccountPage from './pages/AccountPage';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import AuthCallbackPage from './pages/AuthCallbackPage';
import ForgotPasswordPage from './pages/ForgotPasswordPage';
import ResetPasswordPage from './pages/ResetPasswordPage';
import DealerApplyPage from './pages/DealerApplyPage';
import AdminDashboard from './pages/AdminDashboard';
import DealerDashboard from './pages/dealer/DealerDashboard';
import {
  FAQPage, ShippingPolicyPage, ReturnPolicyPage,
  PrivacyPolicyPage, ContactPage, SupportPage,
} from './pages/InfoPages';

import './App.css';

const FULLSCREEN_PREFIXES = ['/admin-dashboard', '/dealer-dashboard'];

export default function App() {
  const location = useLocation();
  const isFullscreenLayout = FULLSCREEN_PREFIXES.some((p) =>
    location.pathname.startsWith(p)
  );

  return (
    <div className={`app ${isFullscreenLayout ? 'app--fullscreen' : ''}`}>
      <ScrollToTop />
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

      {!isFullscreenLayout && <Navbar />}

      <main className={isFullscreenLayout ? 'main-content--fullscreen' : 'main-content'}>
        <ErrorBoundary>
        <Routes>
          {/* Public */}
          <Route path="/" element={<HomePage />} />
          <Route path="/product/:slug" element={<ProductDetailPage />} />
          <Route path="/cart" element={<CartPage />} />
          <Route path="/checkout" element={<CheckoutPage />} />
          <Route path="/account" element={<AccountPage />} />
          <Route path="/orders" element={<OrdersPage />} />
          <Route path="/orders/:orderId" element={<OrderDetailPage />} />
          <Route path="/best-sellers" element={<BestSellersPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
          <Route path="/forgot-password" element={<ForgotPasswordPage />} />
          <Route path="/reset-password" element={<ResetPasswordPage />} />
          <Route path="/auth-callback" element={<AuthCallbackPage />} />
          <Route path="/dealer-apply" element={<DealerApplyPage />} />

          {/* Static info / support pages */}
          <Route path="/faq" element={<FAQPage />} />
          <Route path="/shipping-policy" element={<ShippingPolicyPage />} />
          <Route path="/return-policy" element={<ReturnPolicyPage />} />
          <Route path="/privacy-policy" element={<PrivacyPolicyPage />} />
          <Route path="/contact" element={<ContactPage />} />
          <Route path="/contact-us" element={<ContactPage />} />
          <Route path="/support" element={<SupportPage />} />

          {/* Dealer-only — full-screen */}
          <Route
            path="/dealer-dashboard/*"
            element={
              <RoleRoute allowedRoles={['dealer']}>
                <DealerDashboard />
              </RoleRoute>
            }
          />

          {/* Admin-only — full-screen */}
          <Route
            path="/admin-dashboard/*"
            element={
              <RoleRoute allowedRoles={['admin']}>
                <AdminDashboard />
              </RoleRoute>
            }
          />
        </Routes>
        </ErrorBoundary>
      </main>

      {!isFullscreenLayout && <Footer />}
    </div>
  );
}
