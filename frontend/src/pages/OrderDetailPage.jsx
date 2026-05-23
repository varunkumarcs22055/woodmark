/**
 * OrderDetailPage — single order view at /orders/:orderId.
 *
 * Mounted for both authenticated buyers and guests (guests pass ?email=).
 * Shows line items, totals, shipping, status timeline, and invoice access:
 *   - "View Invoice" opens PDF in a new tab (inline disposition)
 *   - "Download Invoice" forces the browser to save the PDF
 */
import { useEffect, useState } from 'react';
import { useParams, useSearchParams, Link } from 'react-router-dom';
import {
  FiArrowLeft, FiDownload, FiFileText, FiPackage, FiTruck, FiCheckCircle,
  FiXCircle, FiRotateCcw,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchOrderDetail, fetchInvoicePDFBlob, cancelOrder, requestOrderReturn,
} from '../api';
import { useAuth } from '../context/AuthContext';
import { formatPrice, formatDate } from '../utils/format';

const STATUS_BADGE_CLASS = {
  CREATED: 'info', CONFIRMED: 'info', SHIPPED: 'warning',
  DELIVERED: 'success', CANCELLED: 'error',
};
const PAYMENT_BADGE_CLASS = {
  PENDING: 'warning', SUCCESS: 'success', PAID: 'success', FAILED: 'error',
};

export default function OrderDetailPage() {
  const { orderId } = useParams();
  const [searchParams] = useSearchParams();
  const { user } = useAuth();
  const guestEmail = searchParams.get('email');

  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let live = true;
    setLoading(true);
    setError('');
    fetchOrderDetail(orderId, !user ? guestEmail : undefined)
      .then((data) => { if (live) setOrder(data); })
      .catch((err) => {
        if (!live) return;
        setError(err.response?.data?.detail || 'Order not found.');
      })
      .finally(() => { if (live) setLoading(false); });
    return () => { live = false; };
  }, [orderId, user, guestEmail]);

  const [acting, setActing] = useState(null); // 'cancel' | 'return' | null

  const handleCancel = async () => {
    if (!order?.can_cancel) {
      toast.error('Cancellation window expired. Please request a return instead.');
      return;
    }
    const reason = window.prompt(
      'Why are you cancelling this order? (optional — helps us improve)',
      ''
    );
    if (reason === null) return; // user dismissed
    setActing('cancel');
    try {
      const updated = await cancelOrder(order.order_id, reason || '');
      setOrder(updated);
      toast.success('Order cancelled. Stock has been released.');
    } catch (err) {
      toast.error(err.response?.data?.error || 'Could not cancel the order.');
    } finally {
      setActing(null);
    }
  };

  const handleReturn = async () => {
    const reason = window.prompt(
      'Tell us why you\'re returning — e.g. damaged on arrival, wrong item, etc.',
      ''
    );
    if (!reason || !reason.trim()) return;
    setActing('return');
    try {
      await requestOrderReturn(order.order_id, reason.trim());
      toast.success('Return request submitted. We\'ll be in touch within 1 business day.');
    } catch (err) {
      toast.error(err.response?.data?.error || 'Could not submit return.');
    } finally {
      setActing(null);
    }
  };

  const openInvoice = async (download) => {
    if (!order?.invoice_id) {
      toast.error('Invoice is not yet generated for this order.');
      return;
    }
    try {
      const blob = await fetchInvoicePDFBlob(order.invoice_id, { download });
      const url = URL.createObjectURL(blob);
      if (download) {
        const a = document.createElement('a');
        a.href = url;
        a.download = `${order.invoice_number || order.order_id}.pdf`;
        a.click();
      } else {
        window.open(url, '_blank', 'noopener,noreferrer');
      }
      // Revoke after a beat so the new tab finishes reading.
      setTimeout(() => URL.revokeObjectURL(url), 30_000);
    } catch {
      toast.error('Could not load invoice PDF.');
    }
  };

  if (loading) {
    return (
      <div className="orders-page container">
        <div className="skeleton" style={{ height: 320, borderRadius: 16 }} />
      </div>
    );
  }

  if (error || !order) {
    return (
      <div className="orders-page container">
        <Link to="/orders" className="orders-signin-link" style={{ marginBottom: 16, display: 'inline-flex' }}>
          <FiArrowLeft size={14} /> Back to My Orders
        </Link>
        <div className="orders-empty fade-in">
          <FiPackage size={48} className="orders-empty-icon" />
          <h3>Order not found</h3>
          <p>{error || `We couldn't find order ${orderId}.`}</p>
        </div>
      </div>
    );
  }

  const subtotal = parseFloat(order.subtotal_amount || 0);
  const gst = parseFloat(order.gst_amount || 0);
  const shipping = parseFloat(order.shipping_amount || 0);
  const couponDisc = parseFloat(order.coupon_discount || 0);
  const total = parseFloat(order.total_amount || 0);
  const canCancel = !!order.can_cancel;
  const cancelMins = Number.isFinite(order.cancel_minutes_remaining)
    ? order.cancel_minutes_remaining
    : 0;

  return (
    <div className="orders-page container">
      <Link to="/orders" className="orders-signin-link" style={{ marginBottom: 16, display: 'inline-flex' }}>
        <FiArrowLeft size={14} /> Back to My Orders
      </Link>

      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 16, marginBottom: 24 }}>
        <div>
          <h1 style={{ marginBottom: 4 }}>Order {order.order_id}</h1>
          <p style={{ color: '#6B7280', margin: 0 }}>
            Placed {formatDate(order.created_at)}
            {order.po_number && <> · PO #{order.po_number}</>}
          </p>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6, alignItems: 'flex-end' }}>
          <span className={`badge badge-${PAYMENT_BADGE_CLASS[order.payment_status] || 'info'}`}>
            {order.payment_status}
          </span>
          <span className={`badge badge-${STATUS_BADGE_CLASS[order.order_status] || 'info'}`}>
            {order.order_status}
          </span>
        </div>
      </header>

      {/* Self-service actions — cancel while CREATED/CONFIRMED, return while SHIPPED/DELIVERED */}
      {(['CREATED', 'CONFIRMED'].includes(order.order_status)
        || ['SHIPPED', 'DELIVERED'].includes(order.order_status)) && (
        <section style={{ ...cardStyle, display: 'flex', gap: 10, flexWrap: 'wrap',
                          alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <strong style={{ color: '#111827', display: 'block' }}>
              Need to make a change?
            </strong>
            <span style={{ color: '#6B7280', fontSize: 13 }}>
              {['CREATED', 'CONFIRMED'].includes(order.order_status)
                ? (canCancel
                    ? `Cancel within ${cancelMins} minute${cancelMins === 1 ? '' : 's'} (1-hour window).`
                    : 'Cancellation window expired. Please request a return after delivery.')
                : 'Request a return within 14 days of delivery.'}
            </span>
          </div>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {['CREATED', 'CONFIRMED'].includes(order.order_status) && (
                    <button onClick={handleCancel} disabled={acting === 'cancel' || !canCancel}
                      className="btn-outline"
                      style={{ display: 'inline-flex', alignItems: 'center', gap: 6,
                               color: '#B91C1C', borderColor: '#FECACA' }}>
                <FiXCircle size={14} />
                {acting === 'cancel' ? 'Cancelling…' : (canCancel ? 'Cancel order' : 'Cancel unavailable')}
              </button>
            )}
            {['SHIPPED', 'DELIVERED'].includes(order.order_status) && (
              <button onClick={handleReturn} disabled={acting === 'return'}
                      className="btn-outline"
                      style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                <FiRotateCcw size={14} />
                {acting === 'return' ? 'Submitting…' : 'Request return'}
              </button>
            )}
          </div>
        </section>
      )}

      {/* Invoice actions — only when an invoice exists */}
      {order.invoice_id ? (
        <section style={invoiceCardStyle}>
          <div style={{ display: 'flex', justifyContent: 'space-between',
                        alignItems: 'flex-start', flexWrap: 'wrap', gap: 14 }}>
            <div>
              <span style={invoiceLabelStyle}>TAX INVOICE</span>
              <h3 style={{ margin: '6px 0 4px', color: '#fff', fontSize: 22 }}>
                {order.invoice_number}
              </h3>
              <p style={{ color: '#FED7AA', margin: 0, fontSize: 13 }}>
                GST-compliant — available now. Total {formatPrice(total)}.
              </p>
            </div>
            <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
              <button onClick={() => openInvoice(false)} style={ghostBtnStyle}>
                <FiFileText /> View
              </button>
              <button onClick={() => openInvoice(true)} style={primaryBtnStyle}>
                <FiDownload /> Download PDF
              </button>
            </div>
          </div>
        </section>
      ) : (
        // When an order is created but unpaid, the invoice is generated only
        // after payment success. Surface that clearly so the buyer doesn't
        // wonder where their invoice is.
        <section style={{
          ...cardStyle,
          background: 'linear-gradient(135deg, #FFFBEB 0%, #FFFFFF 100%)',
          borderColor: '#FDE68A',
        }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12,
                        flexWrap: 'wrap', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
              <FiFileText size={22} style={{ color: '#92400E', marginTop: 2 }} />
              <div>
                <strong style={{ display: 'block', color: '#78350F', fontSize: 15 }}>
                  Invoice pending
                </strong>
                <p style={{ margin: '2px 0 0', color: '#92400E', fontSize: 13.5, lineHeight: 1.5 }}>
                  {order.payment_status === 'SUCCESS'
                    ? 'Your payment was received — the tax invoice is being generated and will appear here shortly.'
                    : 'A GST invoice is created automatically once payment is confirmed. Pay this order to receive your invoice.'}
                </p>
              </div>
            </div>
            {order.payment_status !== 'SUCCESS' && (
              <Link to="/checkout" state={{ pendingOrderId: order.order_id }}
                    className="btn-primary"
                    style={{ display: 'inline-flex', alignItems: 'center', gap: 6,
                             padding: '8px 16px', fontSize: 13, fontWeight: 600 }}>
                Pay now
              </Link>
            )}
          </div>
        </section>
      )}

      {/* Status timeline (simple inline pills) */}
      <section style={cardStyle}>
        <h3 style={{ marginTop: 0 }}>Status</h3>
        <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
          <Pill icon={<FiCheckCircle />} active label="Placed" />
          <Pill icon={<FiCheckCircle />} active={['CONFIRMED', 'SHIPPED', 'DELIVERED'].includes(order.order_status)} label="Confirmed" />
          <Pill icon={<FiTruck />} active={['SHIPPED', 'DELIVERED'].includes(order.order_status)} label="Shipped" />
          <Pill icon={<FiPackage />} active={order.order_status === 'DELIVERED'} label="Delivered" />
        </div>
        {(order.tracking_carrier || order.tracking_number) && (
          <p style={{ marginTop: 12, color: '#374151' }}>
            <strong>Tracking:</strong> {order.tracking_carrier || '—'}{' '}
            {order.tracking_number && <code>{order.tracking_number}</code>}
          </p>
        )}
      </section>

      {/* Items */}
      <section style={cardStyle}>
        <h3 style={{ marginTop: 0 }}>Items ({order.items?.length || 0})</h3>
        <div style={{ overflowX: 'auto' }}>
        <table className="admin-table admin-table--compact" style={{ minWidth: 520 }}>
          <thead>
            <tr><th>Product</th><th style={{ textAlign: 'right' }}>Qty</th><th style={{ textAlign: 'right' }}>Price</th><th style={{ textAlign: 'right' }}>Subtotal</th></tr>
          </thead>
          <tbody>
            {order.items?.map((it) => (
              <tr key={it.id}>
                <td>
                  <div style={{ display: 'flex', gap: 10, alignItems: 'center', minWidth: 0 }}>
                  {it.product_image && <img src={it.product_image} alt="" style={{ width: 44, height: 44, objectFit: 'cover', borderRadius: 6, flexShrink: 0 }} />}
                  <div style={{ minWidth: 0 }}>
                    <strong style={{ display: 'block', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{it.product_name}</strong>
                    {it.product_slug && (
                      <div><Link to={`/product/${it.product_slug}`} style={{ fontSize: 12 }}>View product →</Link></div>
                    )}
                    {it.is_backorder && (
                      <div style={{ marginTop: 4 }}>
                        <span style={{
                          background: '#FEF3C7', color: '#92400E', fontSize: 11,
                          padding: '2px 6px', borderRadius: 8, fontWeight: 500,
                        }}>
                          Backorder · {it.backorder_quantity} units
                          {it.expected_restock_date && ` · ETA ${formatDate(it.expected_restock_date)}`}
                        </span>
                      </div>
                    )}
                  </div>
                  </div>
                </td>
                <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>{it.quantity}</td>
                <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>{formatPrice(it.price)}</td>
                <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>{formatPrice(it.subtotal)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        </div>
      </section>

      {/* Totals */}
      <section style={cardStyle}>
        <h3 style={{ marginTop: 0 }}>Totals</h3>
        <Row label="Subtotal" value={formatPrice(subtotal)} />
        {couponDisc > 0 && (
          <Row label={`Coupon ${order.coupon_code ? `(${order.coupon_code})` : ''}`} value={`− ${formatPrice(couponDisc)}`} />
        )}
        <Row label={`GST (${order.gst_percent}%)`} value={formatPrice(gst)} />
        <Row label="Shipping" value={shipping > 0 ? formatPrice(shipping) : 'Free'} />
        <Row label="Total" value={formatPrice(total)} bold />
        <p style={{ color: '#6B7280', fontSize: 13, marginTop: 8 }}>
          Paid via <strong>{order.payment_method || 'razorpay'}</strong>
        </p>
      </section>

      {/* Address */}
      <section style={cardStyle}>
        <h3 style={{ marginTop: 0 }}>Shipping Address</h3>
        <p style={{ whiteSpace: 'pre-wrap', margin: 0 }}>
          <strong>{order.user_name}</strong>
          {'\n'}{order.address}
          {'\n'}{order.phone}
          {order.user_email && <>{'\n'}{order.user_email}</>}
        </p>
      </section>
    </div>
  );
}

function Row({ label, value, bold }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0',
                  borderTop: '1px solid #F3F4F6', fontWeight: bold ? 600 : 400 }}>
      <span>{label}</span>
      <span>{value}</span>
    </div>
  );
}

function Pill({ icon, active, label }) {
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '6px 12px', borderRadius: 18,
      background: active ? '#DCFCE7' : '#F3F4F6',
      color: active ? '#15803D' : '#6B7280',
      fontSize: 13, fontWeight: 500,
    }}>
      {icon} {label}
    </span>
  );
}

const cardStyle = {
  background: '#fff',
  border: '1px solid #E5E7EB',
  borderRadius: 12,
  padding: 18,
  marginBottom: 16,
};

const invoiceCardStyle = {
  background: 'linear-gradient(135deg, #1F2937 0%, #111827 100%)',
  borderRadius: 14,
  padding: '22px 22px',
  marginBottom: 16,
  boxShadow: '0 8px 28px -12px rgba(17,24,39,0.45)',
};

const invoiceLabelStyle = {
  display: 'inline-block',
  padding: '3px 10px',
  borderRadius: 999,
  background: '#EA580C',
  color: '#fff',
  fontSize: 10.5,
  fontWeight: 700,
  letterSpacing: '0.08em',
};

const primaryBtnStyle = {
  display: 'inline-flex', alignItems: 'center', gap: 6,
  padding: '9px 14px',
  background: '#F97316', color: '#fff',
  border: 0, borderRadius: 8,
  fontWeight: 600, fontSize: 13.5, cursor: 'pointer',
};

const ghostBtnStyle = {
  display: 'inline-flex', alignItems: 'center', gap: 6,
  padding: '9px 14px',
  background: 'rgba(255,255,255,0.08)', color: '#fff',
  border: '1px solid rgba(255,255,255,0.25)', borderRadius: 8,
  fontWeight: 500, fontSize: 13.5, cursor: 'pointer',
};
