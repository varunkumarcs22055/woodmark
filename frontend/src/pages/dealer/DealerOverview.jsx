/**
 * DealerOverview — KPI cards, recent orders, featured products at dealer prices.
 */
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  FiShoppingBag, FiDollarSign, FiTag, FiPackage,
} from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';
import { fetchOrders, fetchProducts } from '../../api';
import { formatPrice } from '../../utils/format';
import OrderCard from '../../components/OrderCard';
import DealerProductCard from '../../components/dealer/DealerProductCard';

export default function DealerOverview() {
  const { user } = useAuth();
  const [orders, setOrders] = useState([]);
  const [featured, setFeatured] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let live = true;
    Promise.allSettled([
      fetchOrders(),
      fetchProducts({ ordering: '-created_at', page_size: 8 }),
    ]).then(([ordersRes, productsRes]) => {
      if (!live) return;
      setOrders(ordersRes.status === 'fulfilled'
        ? (Array.isArray(ordersRes.value) ? ordersRes.value : ordersRes.value?.results || []) : []);
      setFeatured(productsRes.status === 'fulfilled'
        ? (productsRes.value.results || productsRes.value || []) : []);
      setLoading(false);
    });
    return () => { live = false; };
  }, []);

  const totalSpent = orders
    .filter((o) => o.payment_status === 'PAID' || o.payment_status === 'SUCCESS')
    .reduce((sum, o) => sum + parseFloat(o.total_amount || 0), 0);

  const activeDiscounted = featured.filter(
    (p) => p.discount_applied && p.discount_units_remaining !== 0
  ).length;

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Welcome back, {user?.dealer_company_name || user?.full_name}</h1>
        <p>Your dealer account is active. Browse the catalog at exclusive B2B prices.</p>
      </header>

      <section className="dealer-stats">
        <StatCard icon={<FiShoppingBag />} label="Total Orders" value={orders.length} />
        <StatCard icon={<FiDollarSign />} label="Total Spent" value={formatPrice(totalSpent)} />
        <StatCard icon={<FiTag />} label="Active Discounts" value={activeDiscounted} />
        <StatCard
          icon={<FiPackage />}
          label="Pending Shipments"
          value={orders.filter((o) => o.order_status === 'CONFIRMED').length}
        />
      </section>

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header">
          <h2>Recent Orders</h2>
          <Link to="orders" className="dealer-overview__link">View All →</Link>
        </div>
        {loading ? (
          <div className="dealer-overview__empty">Loading…</div>
        ) : orders.length === 0 ? (
          <div className="dealer-overview__empty">
            <p>No orders yet. <Link to="catalog">Browse the catalog →</Link></p>
          </div>
        ) : (
          <div className="dealer-overview__orders">
            {orders.slice(0, 3).map((o) => (
              <OrderCard key={o.order_id} order={o} />
            ))}
          </div>
        )}
      </section>

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header">
          <h2>Featured at Dealer Prices</h2>
          <Link to="catalog" className="dealer-overview__link">Browse Catalog →</Link>
        </div>
        {loading ? (
          <div className="dealer-overview__empty">Loading…</div>
        ) : featured.length === 0 ? (
          <div className="dealer-overview__empty">No products available right now.</div>
        ) : (
          <div className="dealer-overview__products">
            {featured.slice(0, 4).map((p) => (
              <DealerProductCard key={p.id} product={p} />
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

function StatCard({ icon, label, value }) {
  return (
    <div className="dealer-stat-card">
      <div className="dealer-stat-card__icon">{icon}</div>
      <div className="dealer-stat-card__body">
        <span className="dealer-stat-card__label">{label}</span>
        <span className="dealer-stat-card__value">{value}</span>
      </div>
    </div>
  );
}
