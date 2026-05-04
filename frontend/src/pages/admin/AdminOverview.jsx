/**
 * AdminOverview — KPI cards + recent orders + low-stock alerts.
 * All data loaded in parallel; failures degrade gracefully.
 */
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  FiPackage, FiShoppingBag, FiClock, FiAlertTriangle, FiTrendingUp,
} from 'react-icons/fi';
import { fetchAllOrders, fetchProducts, fetchUsers } from '../../api';
import { formatPrice, formatDate } from '../../utils/format';

export default function AdminOverview() {
  const [stats, setStats] = useState({
    totalProducts: 0, totalOrders: 0, pendingOrders: 0,
    failedERP: 0, pendingDealers: 0, totalRevenue: 0,
  });
  const [recentOrders, setRecentOrders] = useState([]);
  const [lowStock, setLowStock] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let live = true;
    Promise.allSettled([
      fetchAllOrders({ page_size: 10 }),
      fetchProducts({ page_size: 100 }),
      fetchUsers({ role: 'dealer', dealer_status: 'pending' }),
    ]).then(([ordersRes, productsRes, dealersRes]) => {
      if (!live) return;
      const orders = ordersRes.status === 'fulfilled'
        ? (ordersRes.value.results || ordersRes.value || [])
        : [];
      const ordersCount = ordersRes.status === 'fulfilled'
        ? (ordersRes.value.count ?? orders.length) : 0;
      const products = productsRes.status === 'fulfilled'
        ? (productsRes.value.results || productsRes.value || [])
        : [];
      const productCount = productsRes.status === 'fulfilled'
        ? (productsRes.value.count ?? products.length) : 0;
      const dealers = dealersRes.status === 'fulfilled'
        ? (dealersRes.value.results || dealersRes.value || []) : [];

      setStats({
        totalProducts: productCount,
        totalOrders: ordersCount,
        pendingOrders: orders.filter((o) => o.order_status === 'CREATED').length,
        failedERP: orders.filter((o) => o.erp_sync_status === 'failed').length,
        pendingDealers: dealers.length,
        totalRevenue: orders
          .filter((o) => o.payment_status === 'PAID' || o.payment_status === 'SUCCESS')
          .reduce((s, o) => s + parseFloat(o.total_amount || 0), 0),
      });
      setRecentOrders(orders.slice(0, 5));
      setLowStock(products.filter((p) => (p.stock ?? 0) <= 5).slice(0, 5));
      setLoading(false);
    });
    return () => { live = false; };
  }, []);

  return (
    <div className="admin-page">
      <h2 className="admin-page__title">Overview</h2>

      <div className="admin-stats-grid">
        <StatCard icon={<FiPackage />} label="Total Products" value={stats.totalProducts} link="products" />
        <StatCard icon={<FiShoppingBag />} label="Total Orders" value={stats.totalOrders} link="orders" />
        <StatCard icon={<FiClock />} label="Pending Orders" value={stats.pendingOrders} accent="warn" link="orders" />
        <StatCard icon={<FiAlertTriangle />} label="ERP Sync Failures" value={stats.failedERP} accent="error" link="erp" />
        <StatCard icon={<FiUsers />} label="Pending Dealers" value={stats.pendingDealers} link="dealers" />
        <StatCard icon={<FiTrendingUp />} label="Total Revenue" value={formatPrice(stats.totalRevenue)} accent="success" />
      </div>

      <div className="admin-grid-2">
        <section className="admin-card">
          <div className="admin-card__header">
            <h3>Recent Orders</h3>
            <Link to="orders" className="admin-link">View all →</Link>
          </div>
          {loading ? (
            <p className="admin-empty">Loading…</p>
          ) : recentOrders.length === 0 ? (
            <p className="admin-empty">No recent orders</p>
          ) : (
            <table className="admin-table admin-table--compact">
              <thead>
                <tr><th>Order ID</th><th>Customer</th><th>Total</th><th>Status</th><th>Date</th></tr>
              </thead>
              <tbody>
                {recentOrders.map((o) => (
                  <tr key={o.order_id}>
                    <td><code>{o.order_id}</code></td>
                    <td>{o.user_name}</td>
                    <td>{formatPrice(o.total_amount)}</td>
                    <td><StatusBadge status={o.order_status} /></td>
                    <td>{formatDate(o.created_at)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </section>

        <section className="admin-card">
          <div className="admin-card__header">
            <h3>Low Stock Alerts</h3>
            <Link to="products" className="admin-link">Manage →</Link>
          </div>
          {loading ? (
            <p className="admin-empty">Loading…</p>
          ) : lowStock.length === 0 ? (
            <p className="admin-empty">All products well-stocked ✓</p>
          ) : (
            <table className="admin-table admin-table--compact">
              <thead>
                <tr><th>Product</th><th>Category</th><th>Stock</th></tr>
              </thead>
              <tbody>
                {lowStock.map((p) => (
                  <tr key={p.id}>
                    <td>{p.name}</td>
                    <td>{p.category_name}</td>
                    <td>
                      <span className={`status-badge ${p.stock === 0 ? 'status-badge--cancelled' : 'status-badge--shipped'}`}>
                        {p.stock === 0 ? 'Out' : `${p.stock} left`}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </section>
      </div>
    </div>
  );
}

function StatCard({ icon, label, value, accent, link }) {
  const Inner = (
    <div className={`admin-stat-card ${accent ? `admin-stat-card--${accent}` : ''}`}>
      <span className="admin-stat-card__icon">{icon}</span>
      <span className="admin-stat-card__value">{value}</span>
      <span className="admin-stat-card__label">{label}</span>
    </div>
  );
  return link ? <Link to={link}>{Inner}</Link> : Inner;
}

function StatusBadge({ status }) {
  const cls = `status-badge status-badge--${(status || 'created').toLowerCase()}`;
  return <span className={cls}>{status}</span>;
}

// Local re-import to avoid touching outer file
function FiUsers(props) {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
      strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  );
}
