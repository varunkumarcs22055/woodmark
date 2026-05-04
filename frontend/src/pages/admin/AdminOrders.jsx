/**
 * AdminOrders — filterable order table + side drawer with status update + ERP retry.
 */
import { useEffect, useState, useMemo } from 'react';
import { FiSearch, FiX, FiRefreshCw } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchAllOrders, updateOrderStatus, retryErpSync } from '../../api';
import { formatPrice, formatDateTime } from '../../utils/format';

const STATUS_OPTIONS = ['CREATED', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

export default function AdminOrders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState('ALL');
  const [filterPayment, setFilterPayment] = useState('ALL');
  const [drawerOrder, setDrawerOrder] = useState(null);

  const loadOrders = async () => {
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

  useEffect(() => { loadOrders(); }, []);

  const filtered = useMemo(() => {
    return orders.filter((o) => {
      if (filterStatus !== 'ALL' && o.order_status !== filterStatus) return false;
      if (filterPayment !== 'ALL' && o.payment_status !== filterPayment) return false;
      if (search && !o.order_id.toLowerCase().includes(search.toLowerCase()) &&
          !(o.user_email || '').toLowerCase().includes(search.toLowerCase())) return false;
      return true;
    });
  }, [orders, filterStatus, filterPayment, search]);

  const handleStatusChange = async (orderId, newStatus) => {
    try {
      await updateOrderStatus(orderId, newStatus);
      toast.success(`Order moved to ${newStatus}`);
      await loadOrders();
      if (drawerOrder?.order_id === orderId) {
        setDrawerOrder({ ...drawerOrder, order_status: newStatus });
      }
    } catch {
      toast.error('Failed to update status');
    }
  };

  const handleErpRetry = async (orderId) => {
    try {
      const r = await retryErpSync(orderId);
      toast.success(`ERP synced (${r.erp_order_id || 'OK'})`);
      await loadOrders();
    } catch {
      toast.error('ERP retry failed');
    }
  };

  return (
    <div className="admin-page">
      <h2 className="admin-page__title">Orders</h2>

      <div className="admin-toolbar">
        <div className="admin-toolbar__search">
          <FiSearch />
          <input type="search" placeholder="Search by Order ID or email…"
            value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <select value={filterStatus} onChange={(e) => setFilterStatus(e.target.value)}>
          <option value="ALL">All statuses</option>
          {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
        </select>
        <select value={filterPayment} onChange={(e) => setFilterPayment(e.target.value)}>
          <option value="ALL">All payments</option>
          <option value="PAID">PAID</option>
          <option value="PENDING">PENDING</option>
          <option value="FAILED">FAILED</option>
        </select>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : filtered.length === 0 ? (
          <p className="admin-empty">No orders match.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Total</th>
                <th>Status</th>
                <th>Payment</th>
                <th>ERP</th>
                <th>Date</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((o) => (
                <tr key={o.order_id}>
                  <td><code>{o.order_id}</code></td>
                  <td>
                    {o.user_name}
                    <span className="admin-meta-line">{o.user_email}</span>
                  </td>
                  <td>{formatPrice(o.total_amount)}</td>
                  <td>
                    <span className={`status-badge status-badge--${(o.order_status || '').toLowerCase()}`}>
                      {o.order_status}
                    </span>
                  </td>
                  <td>
                    <span className={`status-badge status-badge--${o.payment_status === 'PAID' ? 'confirmed' : o.payment_status === 'FAILED' ? 'cancelled' : 'created'}`}>
                      {o.payment_status}
                    </span>
                  </td>
                  <td>
                    {o.erp_order_id
                      ? <span className="status-badge status-badge--synced">Synced</span>
                      : <span className="status-badge status-badge--failed">No sync</span>}
                  </td>
                  <td>{formatDateTime(o.created_at)}</td>
                  <td>
                    <button className="admin-icon-btn" onClick={() => setDrawerOrder(o)}>
                      View
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {drawerOrder && (
        <OrderDrawer
          order={drawerOrder}
          onClose={() => setDrawerOrder(null)}
          onStatusChange={handleStatusChange}
          onErpRetry={handleErpRetry}
        />
      )}
    </div>
  );
}

function OrderDrawer({ order, onClose, onStatusChange, onErpRetry }) {
  return (
    <>
      <div className="admin-drawer-backdrop" onClick={onClose} />
      <aside className="admin-drawer">
        <div className="admin-drawer__header">
          <div>
            <h3>{order.order_id}</h3>
            <span className="admin-meta-line">{formatDateTime(order.created_at)}</span>
          </div>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>

        <div className="admin-drawer__body">
          <section className="admin-drawer__section">
            <h4>Customer</h4>
            <p><strong>{order.user_name}</strong></p>
            <p>{order.user_email}</p>
            <p>{order.phone}</p>
            <p style={{ whiteSpace: 'pre-wrap' }}>{order.address}</p>
          </section>

          <section className="admin-drawer__section">
            <h4>Items</h4>
            {(order.items || []).map((item, i) => (
              <div key={i} className="admin-drawer__item">
                <img src={item.product_image} alt="" />
                <div className="admin-drawer__item-info">
                  <strong>{item.product_name}</strong>
                  <span className="admin-meta-line">
                    Qty: {item.quantity} × {formatPrice(item.price)}
                  </span>
                </div>
                <span>{formatPrice(item.subtotal)}</span>
              </div>
            ))}
          </section>

          <section className="admin-drawer__section">
            <h4>Status</h4>
            <select value={order.order_status}
              onChange={(e) => onStatusChange(order.order_id, e.target.value)}
              className="admin-drawer__select">
              {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
            </select>
          </section>

          <section className="admin-drawer__section">
            <h4>ERP Sync</h4>
            {order.erp_order_id ? (
              <p>✓ Synced as <code>{order.erp_order_id}</code></p>
            ) : (
              <>
                <p>Not yet synced to ERP.</p>
                <button className="btn-outline" onClick={() => onErpRetry(order.order_id)}>
                  <FiRefreshCw size={14} /> Retry ERP Sync
                </button>
              </>
            )}
          </section>

          <section className="admin-drawer__section">
            <h4>Total</h4>
            <p style={{ fontSize: 'var(--text-2xl)', fontWeight: 700 }}>
              {formatPrice(order.total_amount)}
            </p>
            <p>Payment: <strong>{order.payment_status}</strong></p>
          </section>
        </div>
      </aside>
    </>
  );
}
