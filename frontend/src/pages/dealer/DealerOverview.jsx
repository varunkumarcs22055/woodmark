/**
 * DealerOverview — KPI cards + recent orders + CTA to shop the public catalog.
 * The dealer shops on the regular site (where backend serves dealer prices),
 * so this page is a B2B account hub, not a parallel storefront.
 */
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  FiShoppingBag, FiDollarSign, FiTag, FiPackage, FiArrowRight, FiTrendingUp,
} from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';
import { fetchOrders } from '../../api';
import { formatPrice } from '../../utils/format';
import OrderCard from '../../components/OrderCard';

export default function DealerOverview() {
  const { user } = useAuth();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let live = true;
    fetchOrders()
      .then((data) => {
        if (!live) return;
        setOrders(Array.isArray(data) ? data : data?.results || []);
      })
      .catch(() => setOrders([]))
      .finally(() => live && setLoading(false));
    return () => { live = false; };
  }, []);

  const totalSpent = orders
    .filter((o) => o.payment_status === 'PAID' || o.payment_status === 'SUCCESS')
    .reduce((sum, o) => sum + parseFloat(o.total_amount || 0), 0);

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Welcome back, {user?.dealer_company_name || user?.full_name}</h1>
        <p>
          Your dealer account is active. Browse the catalog as usual — your
          exclusive dealer prices are applied automatically across the site.
        </p>
      </header>

      {/* CTA banner — primary path for dealers is shopping the public catalog */}
      <section className="dealer-overview__cta">
        <div className="dealer-overview__cta-body">
          <FiTrendingUp className="dealer-overview__cta-icon" />
          <div>
            <h2>Shop the Catalog at Dealer Prices</h2>
            <p>
              Same products. Same site. Your dealer pricing is applied
              automatically — look for the gold "Dealer Price" badge.
            </p>
          </div>
        </div>
        <Link to="/" className="btn-primary dealer-overview__cta-btn">
          Browse Products <FiArrowRight size={16} />
        </Link>
      </section>

      <section className="dealer-stats">
        <StatCard icon={<FiShoppingBag />} label="Total Orders" value={orders.length} />
        <StatCard icon={<FiDollarSign />} label="Total Spent" value={formatPrice(totalSpent)} />
        <StatCard
          icon={<FiPackage />}
          label="In Transit"
          value={orders.filter((o) => o.order_status === 'CONFIRMED' || o.order_status === 'SHIPPED').length}
        />
        <StatCard
          icon={<FiTag />}
          label="Delivered"
          value={orders.filter((o) => o.order_status === 'DELIVERED').length}
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
            <p>
              No orders yet.{' '}
              <Link to="/" className="dealer-overview__link">Browse the catalog →</Link>
            </p>
          </div>
        ) : (
          <div className="dealer-overview__orders">
            {orders.slice(0, 3).map((o) => (
              <OrderCard key={o.order_id} order={o} />
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
