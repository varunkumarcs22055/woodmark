/**
 * OrdersPage — order history.
 *
 * - Authenticated users: orders auto-load on mount; no email form shown.
 * - Guest users: must enter the email used at checkout to look up orders.
 */
import { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { FiSearch, FiPackage, FiArrowRight } from 'react-icons/fi';
import { fetchOrders } from '../api';
import { useAuth } from '../context/AuthContext';
import OrderCard from '../components/OrderCard';
import './OrdersPage.css';

export default function OrdersPage() {
  const { user, loading: authLoading } = useAuth();
  const [email, setEmail] = useState('');
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);

  const loadOrders = useCallback(async (lookupEmail) => {
    setLoading(true);
    setSearched(true);
    try {
      const data = await fetchOrders(lookupEmail);
      setOrders(Array.isArray(data) ? data : data?.results || []);
    } catch (err) {
      console.error('Failed to fetch orders:', err);
      setOrders([]);
    } finally {
      setLoading(false);
    }
  }, []);

  // Auto-load for authenticated users
  useEffect(() => {
    if (!authLoading && user) {
      loadOrders();
    }
  }, [authLoading, user, loadOrders]);

  const handleSearch = (e) => {
    e.preventDefault();
    if (!email.trim()) return;
    loadOrders(email.trim());
  };

  return (
    <div className="orders-page container">
      <div className="orders-header">
        <h1>{user ? 'My Orders' : 'Track an Order'}</h1>
        <p>
          {user
            ? `Welcome back, ${user.full_name || user.email}. Here's your order history.`
            : 'Enter the email you used at checkout to view your orders.'}
        </p>
      </div>

      {/* Guest email lookup (hidden for authenticated users) */}
      {!user && (
        <form className="orders-search" onSubmit={handleSearch} id="orders-search-form">
          <div className="orders-search-input-wrap">
            <FiSearch className="orders-search-icon" size={18} />
            <input
              type="email"
              placeholder="Enter your email address..."
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="form-input orders-email-input"
              id="orders-email-input"
              required
            />
          </div>
          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Searching...' : 'Find Orders'}
          </button>
        </form>
      )}

      {/* Sign-in nudge for guests */}
      {!user && !searched && (
        <div className="orders-signin-nudge">
          <span>Have an account?</span>
          <Link to="/login" className="orders-signin-link">
            Sign in to see all your orders <FiArrowRight size={14} />
          </Link>
        </div>
      )}

      {/* Results */}
      <div className="orders-results">
        {loading ? (
          <div className="orders-loading">
            {[1, 2].map((i) => (
              <div
                key={i}
                className="skeleton"
                style={{ height: 200, borderRadius: 16, marginBottom: 16 }}
              />
            ))}
          </div>
        ) : searched && orders.length === 0 ? (
          <div className="orders-empty fade-in">
            <FiPackage size={48} className="orders-empty-icon" />
            <h3>No orders found</h3>
            <p>
              {user
                ? "You haven't placed any orders yet."
                : (
                  <>We couldn't find any orders for <strong>{email}</strong>.</>
                )}
            </p>
            <Link to="/" className="btn-primary" style={{ marginTop: '1rem' }}>
              Start Shopping
            </Link>
          </div>
        ) : (
          <div className="orders-list">
            {orders.map((order) => (
              <OrderCard key={order.id || order.order_id} order={order} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
