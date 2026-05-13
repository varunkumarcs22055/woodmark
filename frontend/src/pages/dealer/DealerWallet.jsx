/**
 * DealerWallet — pre-paid wallet view for dealers.
 * Read-only from the dealer's perspective; admins top up via the admin panel.
 */
import { useEffect, useState } from 'react';
import { FiCreditCard, FiArrowDown, FiArrowUp } from 'react-icons/fi';
import { fetchDealerWallet } from '../../api';
import { formatPrice } from '../../utils/format';

export default function DealerWallet() {
  const [wallet, setWallet] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let live = true;
    fetchDealerWallet()
      .then((d) => { if (live) setWallet(d); })
      .catch(() => { if (live) setWallet(null); })
      .finally(() => { if (live) setLoading(false); });
    return () => { live = false; };
  }, []);

  if (loading) return <div className="dealer-overview__empty">Loading wallet…</div>;

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Wallet</h1>
        <p>
          Pre-paid balance for instant checkouts. Use <code>payment_method=wallet</code> at
          checkout to deduct from this balance — no credit limit consumed.
        </p>
      </header>

      <section className="dealer-stats">
        <div className="dealer-stat-card dealer-stat-card--good" style={{ minWidth: 280 }}>
          <div className="dealer-stat-card__icon"><FiCreditCard /></div>
          <div className="dealer-stat-card__body">
            <span className="dealer-stat-card__label">Wallet Balance</span>
            <span className="dealer-stat-card__value">
              {formatPrice(parseFloat(wallet?.balance || 0))}
            </span>
            <span className="dealer-stat-card__sub">
              {wallet?.is_active ? 'Active' : 'Disabled — contact support'}
            </span>
          </div>
        </div>
      </section>

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header"><h2>Transactions</h2></div>
        {(!wallet?.transactions || wallet.transactions.length === 0) ? (
          <div className="dealer-overview__empty">
            <p>No transactions yet. Ask your account manager to add a top-up.</p>
          </div>
        ) : (
          <table className="admin-table admin-table--compact">
            <thead>
              <tr><th>When</th><th>Type</th><th>Amount</th><th>Balance</th><th>Reason</th></tr>
            </thead>
            <tbody>
              {wallet.transactions.map((t) => (
                <tr key={t.id}>
                  <td>{new Date(t.created_at).toLocaleString()}</td>
                  <td>
                    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                      {t.kind === 'credit' ? <FiArrowDown style={{ color: '#16A34A' }} /> : <FiArrowUp style={{ color: '#DC2626' }} />}
                      {t.kind}
                    </span>
                  </td>
                  <td style={{ color: t.kind === 'credit' ? '#16A34A' : '#DC2626', fontWeight: 600 }}>
                    {t.kind === 'credit' ? '+' : '−'}{formatPrice(parseFloat(t.amount))}
                  </td>
                  <td>{formatPrice(parseFloat(t.balance_after))}</td>
                  <td>
                    {t.reason}
                    {t.reference && <span className="admin-meta-line">ref {t.reference}</span>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
