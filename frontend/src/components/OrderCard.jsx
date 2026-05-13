/**
 * OrderCard — single order summary with color-coded status dots.
 */
import { Link } from 'react-router-dom';
import { FiFileText, FiArrowRight } from 'react-icons/fi';
import { formatPrice, formatDate } from '../utils/format';
import './OrderCard.css';

const STATUS_DOT_COLORS = {
  CREATED: '#8A8A8A',
  CONFIRMED: '#00736A',
  SHIPPED: '#1565C0',
  DELIVERED: '#2E7D32',
  CANCELLED: '#C62828',
};

const STATUS_BADGE_CLASS = {
  CREATED: 'info',
  CONFIRMED: 'info',
  SHIPPED: 'warning',
  DELIVERED: 'success',
  CANCELLED: 'error',
};

const PAYMENT_BADGE_CLASS = {
  PENDING: 'warning',
  SUCCESS: 'success',
  PAID: 'success',
  FAILED: 'error',
};

export default function OrderCard({ order }) {
  const dotColor = STATUS_DOT_COLORS[order.order_status] || '#8A8A8A';

  return (
    <div className="order-card fade-in" id={`order-${order.order_id}`}>
      <div className="order-card-header">
        <div>
          <span className="order-id">{order.order_id}</span>
          <span className="order-date">{formatDate(order.created_at)}</span>
        </div>
        <div className="order-badges">
          <span className={`badge badge-${PAYMENT_BADGE_CLASS[order.payment_status] || 'info'}`}>
            {order.payment_status}
          </span>
          <span
            className={`badge badge-${STATUS_BADGE_CLASS[order.order_status] || 'info'}`}
          >
            <span
              className="order-status-dot"
              style={{ background: dotColor }}
            />
            {order.order_status}
          </span>
        </div>
      </div>

      <div className="order-items-list">
        {order.items?.map((item, idx) => (
          <div key={item.id ?? idx} className="order-item-row">
            <img
              src={item.product_image}
              alt={item.product_name}
              className="order-item-thumb"
            />
            <div className="order-item-info">
              <span className="order-item-name">{item.product_name}</span>
              <span className="order-item-qty">
                Qty: {item.quantity} × {formatPrice(item.price)}
              </span>
            </div>
            <span className="order-item-subtotal">{formatPrice(item.subtotal)}</span>
          </div>
        ))}
      </div>

      <div className="order-card-footer">
        <div className="order-meta">
          <span>Ship to: {order.user_name}</span>
          {order.erp_order_id && (
            <span className="erp-id">ERP: {order.erp_order_id}</span>
          )}
          {order.invoice_number && (
            <span className="erp-id" style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
              <FiFileText size={12} /> {order.invoice_number}
            </span>
          )}
        </div>
        <div className="order-total">
          <span className="total-label">Total</span>
          <span className="total-value">{formatPrice(order.total_amount)}</span>
        </div>
      </div>

      <div style={{ padding: '10px 16px', borderTop: '1px solid #F3F4F6',
                    display: 'flex', justifyContent: 'flex-end' }}>
        <Link to={`/orders/${order.order_id}`}
              style={{ display: 'inline-flex', alignItems: 'center', gap: 4,
                       fontSize: 13, fontWeight: 500, color: '#0E766E' }}>
          View details &amp; invoice <FiArrowRight size={13} />
        </Link>
      </div>
    </div>
  );
}
