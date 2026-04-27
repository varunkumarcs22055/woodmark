/**
 * OrdersPage — Look up and display past orders by email.
 */
import { useState } from 'react';
import { fetchOrders } from '../api';
import OrderCard from '../components/OrderCard';
import { FiSearch, FiPackage } from 'react-icons/fi';
import './OrdersPage.css';

export default function OrdersPage() {
  const [email, setEmail] = useState('');
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!email) return;
    setLoading(true);
    setSearched(true);
    try {
      const data = await fetchOrders(email);
      setOrders(data);
    } catch (err) {
      console.error('Failed to fetch orders:', err);
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="orders-page container">
      <div className="orders-header">
        <h1>My Orders</h1>
        <p>Enter your email to view your order history.</p>
      </div>

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

      {/* Results */}
      <div className="orders-results">
        {loading ? (
          <div className="orders-loading">
            {[1, 2].map(i => (
              <div key={i} className="skeleton" style={{ height: 200, borderRadius: 16, marginBottom: 16 }} />
            ))}
          </div>
        ) : searched && orders.length === 0 ? (
          <div className="orders-empty fade-in">
            <FiPackage size={48} className="orders-empty-icon" />
            <h3>No orders found</h3>
            <p>We couldn't find any orders for <strong>{email}</strong>.</p>
          </div>
        ) : (
          <div className="orders-list">
            {orders.map((order) => (
              <OrderCard key={order.id} order={order} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
