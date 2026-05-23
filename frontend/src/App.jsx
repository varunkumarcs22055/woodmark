/**
 * App — Root component with routing and layout.
 *
 * The Admin and Dealer dashboards are full-screen apps with their own
 * sidebar navigation, so we hide the global Navbar / Footer / main-content
 * padding on those routes via useLocation.
 */
import { lazy, Suspense } from 'react';
import { Routes, Route, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import ScrollToTop from './components/ScrollToTop';
import ErrorBoundary from './components/ErrorBoundary';
import { RoleRoute } from './components/ProtectedRoute';

import './App.css';

const HomePage = lazy(() => import('./pages/HomePage'));
const ProductDetailPage = lazy(() => import('./pages/ProductDetailPage'));
const CartPage = lazy(() => import('./pages/CartPage'));
const CheckoutPage = lazy(() => import('./pages/CheckoutPage'));
const OrdersPage = lazy(() => import('./pages/OrdersPage'));
const OrderDetailPage = lazy(() => import('./pages/OrderDetailPage'));
const BestSellersPage = lazy(() => import('./pages/BestSellersPage'));
const AccountPage = lazy(() => import('./pages/AccountPage'));
const LoginPage = lazy(() => import('./pages/LoginPage'));
const SignupPage = lazy(() => import('./pages/SignupPage'));
const AuthCallbackPage = lazy(() => import('./pages/AuthCallbackPage'));
const ForgotPasswordPage = lazy(() => import('./pages/ForgotPasswordPage'));
const ResetPasswordPage = lazy(() => import('./pages/ResetPasswordPage'));
const DealerApplyPage = lazy(() => import('./pages/DealerApplyPage'));
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'));
const DealerDashboard = lazy(() => import('./pages/dealer/DealerDashboard'));
const SupportInboxPage = lazy(() => import('./pages/SupportInbox'));
const FAQPage = lazy(() => import('./pages/InfoPages').then((m) => ({ default: m.FAQPage })));
const ShippingPolicyPage = lazy(() => import('./pages/InfoPages').then((m) => ({ default: m.ShippingPolicyPage })));
const ReturnPolicyPage = lazy(() => import('./pages/InfoPages').then((m) => ({ default: m.ReturnPolicyPage })));
const PrivacyPolicyPage = lazy(() => import('./pages/InfoPages').then((m) => ({ default: m.PrivacyPolicyPage })));
const ContactPage = lazy(() => import('./pages/InfoPages').then((m) => ({ default: m.ContactPage })));
const SupportPage = lazy(() => import('./pages/InfoPages').then((m) => ({ default: m.SupportPage })));

const PageFallback = () => (
  <div className="page-loading">
    Loading...
  </div>
);

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
          <Suspense fallback={<PageFallback />}>
            <Routes>
              {/* Public */}
              <Route path="/" element={<HomePage />} />
              <Route path="/product/:slug" element={<ProductDetailPage />} />
              <Route path="/cart" element={<CartPage />} />
              <Route path="/checkout" element={<CheckoutPage />} />
              <Route path="/account" element={<AccountPage />} />
              <Route
                path="/account/support"
                element={
                  <RoleRoute allowedRoles={['user']}>
                    <SupportInboxPage />
                  </RoleRoute>
                }
              />
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
          </Suspense>
        </ErrorBoundary>
      </main>

      {!isFullscreenLayout && <Footer />}
    </div>
  );
}
