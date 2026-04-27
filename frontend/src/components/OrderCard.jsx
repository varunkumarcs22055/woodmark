/**
 * OrderCard Component — Displays a single order summary.
 */
import './OrderCard.css';

export default function OrderCard({ order }) {
  const formatPrice = (price) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(price);

  const formatDate = (dateStr) =>
    new Date(dateStr).toLocaleDateString('en-IN', { year: 'numeric', month: 'short', day: 'numeric' });

  const statusColors = {
    CREATED: 'info', CONFIRMED: 'info', SHIPPED: 'warning', DELIVERED: 'success', CANCELLED: 'error',
  };
  const paymentColors = { PENDING: 'warning', SUCCESS: 'success', FAILED: 'error' };

  return (
    <div className="order-card fade-in" id={`order-${order.order_id}`}>
      <div className="order-card-header">
        <div>
          <span className="order-id">{order.order_id}</span>
          <span className="order-date">{formatDate(order.created_at)}</span>
        </div>
        <div className="order-badges">
          <span className={`badge badge-${paymentColors[order.payment_status]}`}>
            {order.payment_status}
          </span>
          <span className={`badge badge-${statusColors[order.order_status]}`}>
            {order.order_status}
          </span>
        </div>
      </div>

      <div className="order-items-list">
        {order.items?.map((item, idx) => (
          <div key={idx} className="order-item-row">
            <img src={item.product_image} alt={item.product_name} className="order-item-thumb" />
            <div className="order-item-info">
              <span className="order-item-name">{item.product_name}</span>
              <span className="order-item-qty">Qty: {item.quantity} × {formatPrice(item.price)}</span>
            </div>
            <span className="order-item-subtotal">{formatPrice(item.subtotal)}</span>
          </div>
        ))}
      </div>

      <div className="order-card-footer">
        <div className="order-meta">
          <span>Ship to: {order.user_name}</span>
          {order.erp_order_id && <span className="erp-id">ERP: {order.erp_order_id}</span>}
        </div>
        <div className="order-total">
          <span className="total-label">Total</span>
          <span className="total-value">{formatPrice(order.total_amount)}</span>
        </div>
      </div>
    </div>
  );
}
