/**
 * DealerOverview — single round-trip dashboard.
 *
 * Reads /api/dealer/dashboard/ which returns:
 *   {credit, totals, recent_orders, recent_payments, monthly_spend, tier}
 *
 * The dealer shops on the public storefront (with role-aware pricing applied
 * server-side), so this page is a B2B account hub: credit summary, KPIs,
 * recent orders, recent payments — not a parallel catalog.
 */
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  FiShoppingBag, FiDollarSign, FiTag, FiPackage, FiArrowRight, FiTrendingUp,
  FiCreditCard, FiAlertCircle,
} from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';
import { fetchDealerDashboard } from '../../api';
import { formatPrice } from '../../utils/format';

export default function DealerOverview() {
  const { user } = useAuth();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let live = true;
    fetchDealerDashboard()
      .then((d) => { if (live) setData(d); })
      .catch(() => { if (live) setData(null); })
      .finally(() => { if (live) setLoading(false); });
    return () => { live = false; };
  }, []);

  const credit = data?.credit;
  const totals = data?.totals || {};
  const recentOrders = data?.recent_orders || [];
  const recentPayments = data?.recent_payments || [];
  const tier = data?.tier;

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Welcome back, {user?.dealer_company_name || user?.full_name}</h1>
        <p>
          {tier?.name ? (
            <>You're on the <strong>{tier.name}</strong> ({tier.discount_pct}% off MRP) tier — pricing applied automatically across the site.</>
          ) : (
            <>Your dealer account is active. Browse the catalog as usual — exclusive dealer prices are applied automatically.</>
          )}
        </p>
      </header>

      <section className="dealer-overview__cta">
        <div className="dealer-overview__cta-body">
          <FiTrendingUp className="dealer-overview__cta-icon" />
          <div>
            <h2>Shop the Catalog at Dealer Prices</h2>
            <p>
              Same products. Same site. Look for the gold "Dealer Price" badge.
              Bulk orders unlock additional volume tiers automatically.
            </p>
          </div>
        </div>
        <Link to="/" className="btn-primary dealer-overview__cta-btn">
          Browse Products <FiArrowRight size={16} />
        </Link>
      </section>

      {credit && (
        <section className="dealer-stats">
          <StatCard
            icon={<FiCreditCard />}
            label="Credit Available"
            value={formatPrice(parseFloat(credit.remaining || 0))}
            sub={`Limit ${formatPrice(parseFloat(credit.credit_limit || 0))} · Net-${credit.terms_days}`}
            accent={parseFloat(credit.remaining) <= parseFloat(credit.credit_limit) * 0.1 ? 'warn' : 'good'}
          />
          <StatCard
            icon={<FiAlertCircle />}
            label="Outstanding"
            value={formatPrice(parseFloat(totals.outstanding || 0))}
            sub="Across open invoices"
            accent={parseFloat(totals.outstanding || 0) > 0 ? 'warn' : 'good'}
          />
          <StatCard
            icon={<FiShoppingBag />}
            label="Total Orders"
            value={totals.orders ?? 0}
            sub={`${totals.pending_orders ?? 0} pending`}
          />
          <StatCard
            icon={<FiDollarSign />}
            label="Lifetime Spend"
            value={formatPrice(parseFloat(totals.lifetime_revenue || 0))}
            sub="Successful orders only"
          />
        </section>
      )}

      <div className="dealer-overview__grid">
        <section className="dealer-overview__section">
          <div className="dealer-overview__section-header">
            <h2>Recent Orders</h2>
            <Link to="orders" className="dealer-overview__link">View All →</Link>
          </div>
          {loading ? (
            <div className="dealer-overview__empty">Loading…</div>
          ) : recentOrders.length === 0 ? (
            <div className="dealer-overview__empty">
              <p>
                No orders yet.{' '}
                <Link to="/" className="dealer-overview__link">Browse the catalog →</Link>
              </p>
            </div>
          ) : (
            <table className="admin-table admin-table--compact">
              <thead>
                <tr><th>Order</th><th>Total</th><th>Method</th><th>Status</th></tr>
              </thead>
              <tbody>
                {recentOrders.map((o) => (
                  <tr key={o.id}>
                    <td><code>{o.order_id}</code></td>
                    <td>{formatPrice(parseFloat(o.total_amount))}</td>
                    <td>{o.payment_method || 'razorpay'}</td>
                    <td>
                      <span className={`status-badge status-badge--${(o.order_status || '').toLowerCase()}`}>
                        {o.order_status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </section>

        <section className="dealer-overview__section">
          <div className="dealer-overview__section-header">
            <h2>Recent Payments</h2>
          </div>
          {recentPayments.length === 0 ? (
            <div className="dealer-overview__empty">
              <p>No payments recorded yet.</p>
            </div>
          ) : (
            <table className="admin-table admin-table--compact">
              <thead>
                <tr><th>Date</th><th>Amount</th><th>Method</th><th>Reference</th></tr>
              </thead>
              <tbody>
                {recentPayments.map((p) => (
                  <tr key={p.id}>
                    <td>{(p.received_at || '').slice(0, 10)}</td>
                    <td><strong>{formatPrice(parseFloat(p.amount))}</strong></td>
                    <td>{p.method}</td>
                    <td>
                      {p.reference || '—'}
                      {p.invoice_number && (
                        <span className="admin-meta-line">vs {p.invoice_number}</span>
                      )}
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

function StatCard({ icon, label, value, sub, accent }) {
  return (
    <div className={`dealer-stat-card ${accent ? `dealer-stat-card--${accent}` : ''}`}>
      <div className="dealer-stat-card__icon">{icon}</div>
      <div className="dealer-stat-card__body">
        <span className="dealer-stat-card__label">{label}</span>
        <span className="dealer-stat-card__value">{value}</span>
        {sub && <span className="dealer-stat-card__sub">{sub}</span>}
      </div>
    </div>
  );
}
