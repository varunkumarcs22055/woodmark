/**
 * DealerOrderDetail — full breakdown of a single dealer order with line
 * items + a Reorder button that re-creates the same lines at current
 * prices via /api/orders/<order_id>/reorder/.
 */
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { FiArrowLeft, FiRotateCw, FiTruck, FiFileText } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchOrderDetail, reorderOrder } from '../../api';
import { formatPrice } from '../../utils/format';

export default function DealerOrderDetail() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [reordering, setReordering] = useState(false);

  useEffect(() => {
    let live = true;
    setLoading(true);
    fetchOrderDetail(orderId)
      .then((d) => { if (live) setOrder(d); })
      .catch(() => { if (live) setOrder(null); })
      .finally(() => { if (live) setLoading(false); });
    return () => { live = false; };
  }, [orderId]);

  const handleReorder = async () => {
    setReordering(true);
    try {
      const res = await reorderOrder(orderId);
      if (res?.skipped?.length) {
        toast(`Skipped ${res.skipped.length} item(s) — see new order for details.`, { icon: 'ℹ️' });
      } else {
        toast.success(`Reorder created: ${res.order.order_id}`);
      }
      navigate(`/dealer-dashboard/orders/${res.order.order_id}`);
    } catch (err) {
      const msg = err.response?.data?.error || err.response?.data?.detail
        || 'Could not create reorder.';
      toast.error(msg);
    } finally {
      setReordering(false);
    }
  };

  if (loading) {
    return <div className="dealer-overview__empty">Loading order…</div>;
  }
  if (!order) {
    return (
      <div className="dealer-overview__empty">
        <p>Order not found.</p>
        <Link to="../orders" className="dealer-overview__link">← Back to orders</Link>
      </div>
    );
  }

  return (
    <div className="dealer-overview">
      <Link to="../orders" className="dealer-overview__link" style={{ marginBottom: 16, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
        <FiArrowLeft /> Back to orders
      </Link>

      <header className="dealer-overview__header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 16 }}>
        <div>
          <h1>Order <code>{order.order_id}</code></h1>
          <p>
            Placed on {new Date(order.created_at).toLocaleString()} ·
            {' '}<span className={`status-badge status-badge--${(order.order_status || '').toLowerCase()}`}>{order.order_status}</span>
            {' '}<span className={`status-badge status-badge--${(order.payment_status || '').toLowerCase()}`}>{order.payment_status}</span>
          </p>
          {order.po_number && <p>PO #: <strong>{order.po_number}</strong></p>}
        </div>
        <button
          onClick={handleReorder}
          disabled={reordering}
          className="btn-primary"
          style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}
        >
          <FiRotateCw /> {reordering ? 'Reordering…' : 'Reorder'}
        </button>
      </header>

      <section className="dealer-stats" style={{ marginBottom: 24 }}>
        <div className="dealer-stat-card">
          <div className="dealer-stat-card__body">
            <span className="dealer-stat-card__label">Subtotal</span>
            <span className="dealer-stat-card__value">{formatPrice(parseFloat(order.subtotal_amount || 0))}</span>
          </div>
        </div>
        <div className="dealer-stat-card">
          <div className="dealer-stat-card__body">
            <span className="dealer-stat-card__label">GST ({order.gst_percent}%)</span>
            <span className="dealer-stat-card__value">{formatPrice(parseFloat(order.gst_amount || 0))}</span>
          </div>
        </div>
        <div className="dealer-stat-card">
          <div className="dealer-stat-card__body">
            <span className="dealer-stat-card__label">Shipping</span>
            <span className="dealer-stat-card__value">{formatPrice(parseFloat(order.shipping_amount || 0))}</span>
          </div>
        </div>
        <div className="dealer-stat-card dealer-stat-card--good">
          <div className="dealer-stat-card__body">
            <span className="dealer-stat-card__label">Total</span>
            <span className="dealer-stat-card__value">{formatPrice(parseFloat(order.total_amount || 0))}</span>
            <span className="dealer-stat-card__sub">via {order.payment_method || 'razorpay'}</span>
          </div>
        </div>
      </section>

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header"><h2>Line Items</h2></div>
        <table className="admin-table admin-table--compact">
          <thead>
            <tr><th>Product</th><th>Qty</th><th>Unit</th><th>Subtotal</th></tr>
          </thead>
          <tbody>
            {(order.items || []).map((it) => (
              <tr key={it.id}>
                <td>
                  <Link to={`/product/${it.product_slug}`} target="_blank" rel="noreferrer">
                    {it.product_name}
                  </Link>
                </td>
                <td>{it.quantity}</td>
                <td>
                  {formatPrice(parseFloat(it.price))}
                  {it.original_price && parseFloat(it.original_price) > parseFloat(it.price) && (
                    <span style={{ color: '#9CA3AF', textDecoration: 'line-through', marginLeft: 6, fontSize: 12 }}>
                      {formatPrice(parseFloat(it.original_price))}
                    </span>
                  )}
                </td>
                <td><strong>{formatPrice(parseFloat(it.subtotal || (parseFloat(it.price) * it.quantity)))}</strong></td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      <section className="dealer-overview__section" style={{ marginTop: 24 }}>
        <div className="dealer-overview__section-header"><h2>Shipping & Delivery</h2></div>
        <p style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <FiTruck /> {order.tracking_carrier || 'Carrier TBD'}
          {order.tracking_number && <> · Tracking #{order.tracking_number}</>}
        </p>
        <p>Address: {order.address}</p>
        {order.preferred_carrier && <p>Preferred carrier: {order.preferred_carrier}</p>}
        {order.dealer_note && (
          <p style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <FiFileText /> {order.dealer_note}
          </p>
        )}
      </section>
    </div>
  );
}
