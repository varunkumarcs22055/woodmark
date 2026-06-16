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
import toast from 'react-hot-toast';
import {
  FiShoppingBag, FiDollarSign, FiTag, FiPackage, FiArrowRight, FiTrendingUp,
  FiCreditCard, FiAlertCircle, FiCheckCircle, FiX,
} from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';
import {
  fetchDealerDashboard, initDealerCreditPay, verifyDealerCreditPay,
} from '../../api';
import { formatPrice } from '../../utils/format';
import useModalDismiss from '../../utils/useModalDismiss';

const loadRazorpayScript = () =>
  new Promise((resolve) => {
    if (window.Razorpay) return resolve(true);
    const s = document.createElement('script');
    s.src = 'https://checkout.razorpay.com/v1/checkout.js';
    s.onload = () => resolve(true);
    s.onerror = () => resolve(false);
    document.body.appendChild(s);
  });

export default function DealerOverview() {
  const { user } = useAuth();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [payModal, setPayModal] = useState({ open: false });

  const refresh = () => fetchDealerDashboard()
    .then(setData)
    .catch(() => {});

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
        <>
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

          {parseFloat(credit.amount_used || 0) > 0 && (
            <section className="dealer-paycredit-card">
              <div className="dealer-paycredit-card__body">
                <div className="dealer-paycredit-card__icon-wrap">
                  <FiCreditCard size={24} />
                </div>
                <div>
                  <h2>Pay Back Used Credit</h2>
                  <p>
                    You've used <strong>{formatPrice(parseFloat(credit.amount_used))}</strong> of your{' '}
                    {formatPrice(parseFloat(credit.credit_limit))} limit. Clear it via Razorpay
                    and the amount instantly returns to your available credit.
                  </p>
                </div>
              </div>
              <button
                className="btn-primary"
                onClick={() => setPayModal({
                  open: true,
                  amount: String(credit.amount_used),
                  max: parseFloat(credit.amount_used),
                })}
              >
                Pay Now <FiArrowRight size={16} />
              </button>
            </section>
          )}

          {payModal.open && (
            <PayCreditModal
              maxAmount={payModal.max}
              defaultAmount={payModal.amount}
              dealerEmail={user?.email}
              dealerName={user?.full_name || user?.dealer_company_name}
              onClose={() => setPayModal({ open: false })}
              onSuccess={() => { setPayModal({ open: false }); refresh(); }}
            />
          )}
        </>
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

function PayCreditModal({ maxAmount, defaultAmount, dealerEmail, dealerName, onClose, onSuccess }) {
  const [amount, setAmount] = useState(defaultAmount);
  const [busy, setBusy] = useState(false);
  useModalDismiss(true, onClose);

  const submit = async (e) => {
    e.preventDefault();
    const value = parseFloat(amount);
    if (!Number.isFinite(value) || value <= 0) {
      toast.error('Enter a valid amount.');
      return;
    }
    if (value > maxAmount + 0.001) {
      toast.error(`Amount cannot exceed used credit (${maxAmount}).`);
      return;
    }
    setBusy(true);
    try {
      const init = await initDealerCreditPay(value);
      if (init.simulated) {
        // No Razorpay creds — settle directly.
        const result = await verifyDealerCreditPay({ amount: value });
        toast.success(`Cleared ${formatPrice(value)} of credit (simulated).`);
        onSuccess(result);
        return;
      }
      const sdkOk = await loadRazorpayScript();
      if (!sdkOk) {
        toast.error('Could not load Razorpay. Check your connection.');
        return;
      }
      const rzp = new window.Razorpay({
        key: init.key_id,
        amount: init.amount_paise,
        currency: init.currency,
        order_id: init.razorpay_order_id,
        name: 'Woodmark — Credit Repayment',
        description: 'Pay back your used dealer credit',
        prefill: init.prefill || { name: dealerName, email: dealerEmail },
        theme: { color: '#2D2E5F' },
        modal: { ondismiss: () => setBusy(false) },
        handler: async (response) => {
          try {
            const result = await verifyDealerCreditPay({
              amount: value,
              razorpay_order_id: response.razorpay_order_id,
              razorpay_payment_id: response.razorpay_payment_id,
              razorpay_signature: response.razorpay_signature,
            });
            toast.success(`Paid ${formatPrice(value)}. Credit restored.`);
            onSuccess(result);
          } catch (err) {
            toast.error(err.response?.data?.detail || 'Verification failed.');
          } finally {
            setBusy(false);
          }
        },
      });
      rzp.open();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Could not start payment.');
      setBusy(false);
    }
  };

  return (
    <div className="dealer-paymodal__overlay" onClick={onClose}>
      <div className="dealer-paymodal" onClick={(e) => e.stopPropagation()}>
        <div className="dealer-paymodal__header">
          <h3>Pay Back Credit</h3>
          <button type="button" onClick={onClose} aria-label="Close" className="dealer-paymodal__close">
            <FiX size={18} />
          </button>
        </div>
        <form onSubmit={submit}>
          <div className="dealer-paymodal__body">
            <p className="dealer-paymodal__hint">
              Maximum repayment: <strong>{formatPrice(maxAmount)}</strong>
              <br />
              Your available credit will increase by this amount once paid.
            </p>
            <label className="dealer-paymodal__field">
              <span>Amount to pay (₹)</span>
              <input
                type="number"
                min="1"
                max={maxAmount}
                step="0.01"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                required
                autoFocus
              />
            </label>
            <div className="dealer-paymodal__quick">
              <button type="button" onClick={() => setAmount(String(Math.round(maxAmount / 2)))}>
                Half
              </button>
              <button type="button" onClick={() => setAmount(String(maxAmount))}>
                Full {formatPrice(maxAmount)}
              </button>
            </div>
          </div>
          <div className="dealer-paymodal__footer">
            <button type="button" className="btn-outline" onClick={onClose} disabled={busy}>
              Cancel
            </button>
            <button type="submit" className="btn-primary" disabled={busy}>
              {busy ? 'Processing…' : <>Pay {formatPrice(parseFloat(amount) || 0)} <FiCheckCircle size={16} /></>}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
