/**
 * AdminERP — order ERP-sync status table with retry button.
 */
import { useEffect, useState } from 'react';
import { FiRefreshCw } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchAllOrders, retryErpSync } from '../../api';
import { formatDateTime } from '../../utils/format';

export default function AdminERP() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    setLoading(true);
    try {
      const data = await fetchAllOrders({ page_size: 100 });
      setOrders(data.results || data || []);
    } catch {
      toast.error('Failed to load orders');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const handleRetry = async (orderId) => {
    try {
      const r = await retryErpSync(orderId);
      toast.success(`Synced as ${r.erp_order_id || 'OK'}`);
      await load();
    } catch {
      toast.error('Sync failed. Check server logs.');
    }
  };

  const synced = orders.filter((o) => o.erp_order_id);
  const failed = orders.filter((o) => !o.erp_order_id && o.payment_status === 'PAID');

  return (
    <div className="admin-page">
      <h2 className="admin-page__title">ERP Sync Status</h2>

      <div className="admin-stats-grid admin-stats-grid--compact">
        <div className="admin-stat-card admin-stat-card--success">
          <span className="admin-stat-card__value">{synced.length}</span>
          <span className="admin-stat-card__label">Synced</span>
        </div>
        <div className="admin-stat-card admin-stat-card--error">
          <span className="admin-stat-card__value">{failed.length}</span>
          <span className="admin-stat-card__label">Failed / Missing</span>
        </div>
        <div className="admin-stat-card">
          <span className="admin-stat-card__value">{orders.length}</span>
          <span className="admin-stat-card__label">Total Paid Orders</span>
        </div>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : orders.length === 0 ? (
          <p className="admin-empty">No orders yet.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer Email</th>
                <th>ERP Order ID</th>
                <th>Status</th>
                <th>Date</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {orders.map((o) => (
                <tr key={o.order_id}>
                  <td><code>{o.order_id}</code></td>
                  <td>{o.user_email}</td>
                  <td>{o.erp_order_id ? <code>{o.erp_order_id}</code> : '—'}</td>
                  <td>
                    {o.erp_order_id
                      ? <span className="status-badge status-badge--synced">✓ Synced</span>
                      : <span className="status-badge status-badge--failed">✗ Not synced</span>}
                  </td>
                  <td>{formatDateTime(o.created_at)}</td>
                  <td>
                    {!o.erp_order_id && (
                      <button className="admin-icon-btn" onClick={() => handleRetry(o.order_id)}>
                        <FiRefreshCw size={14} /> Retry
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
