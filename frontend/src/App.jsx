/**
 * App — Root component with routing and layout.
 */
import { Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import { RoleRoute } from './components/ProtectedRoute';

import HomePage from './pages/HomePage';
import ProductDetailPage from './pages/ProductDetailPage';
import CartPage from './pages/CartPage';
import CheckoutPage from './pages/CheckoutPage';
import OrdersPage from './pages/OrdersPage';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import AuthCallbackPage from './pages/AuthCallbackPage';
import DealerApplyPage from './pages/DealerApplyPage';
import AdminDashboard from './pages/AdminDashboard';
import DealerDashboard from './pages/dealer/DealerDashboard';

import './App.css';

export default function App() {
  return (
    <div className="app">
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

          {/* Dealer-only */}
          <Route
            path="/dealer-dashboard/*"
            element={
              <RoleRoute allowedRoles={['dealer']}>
                <DealerDashboard />
              </RoleRoute>
            }
          />

          {/* Admin-only */}
          <Route
            path="/admin-dashboard/*"
            element={
              <RoleRoute allowedRoles={['admin']}>
                <AdminDashboard />
              </RoleRoute>
            }
          />
        </Routes>
      </main>
      <Footer />
    </div>
  );
}
