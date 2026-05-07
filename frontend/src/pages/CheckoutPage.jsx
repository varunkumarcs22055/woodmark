/**
 * CheckoutPage — full Razorpay integration.
 *
 * Flow:
 *   1. User fills shipping form → validate
 *   2. POST /api/orders/create/        → returns our internal order
 *   3a. DEV (VITE_DEV_MODE=true): POST /api/payment/success/ to simulate
 *   3b. PROD: load Razorpay SDK from CDN, POST /api/payment/create-razorpay-order/,
 *       open the modal, on handler callback POST /api/payment/verify/ with the
 *       three Razorpay IDs to verify the signature server-side
 *   4. On success: clear cart, show success screen with order ID + ERP ref
 *
 * Four UI states: form | processing | success | error
 */
import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { FiLock, FiCheckCircle, FiAlertCircle } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import { useSettings } from '../context/SettingsContext';
import {
  createOrder, simulatePayment, createRazorpayOrder, verifyPayment,
} from '../api';
import { formatPrice } from '../utils/format';
import './CheckoutPage.css';

/**
 * Razorpay is opt-in. Until VITE_RAZORPAY_ENABLED=true is set in `.env`,
 * checkout uses the simulated /api/payment/success/ endpoint so the full
 * design + flow can be tested end-to-end without Razorpay credentials.
 * Flip the flag once the Razorpay backend (Backend Prompt 8) is wired up
 * and you have your test/live API keys.
 */
const RAZORPAY_ENABLED = import.meta.env.VITE_RAZORPAY_ENABLED === 'true';
const DEV_MODE = !RAZORPAY_ENABLED;

const loadRazorpayScript = () =>
  new Promise((resolve) => {
    if (window.Razorpay) return resolve(true);
    const script = document.createElement('script');
    script.src = 'https://checkout.razorpay.com/v1/checkout.js';
    script.onload = () => resolve(true);
    script.onerror = () => resolve(false);
    document.body.appendChild(script);
  });

export default function CheckoutPage() {
  const { cartItems, cartTotal, cartCount, clearCart } = useCart();
  const { user } = useAuth();
  const { gst_percent, free_shipping_threshold, standard_shipping_fee } = useSettings();
  const navigate = useNavigate();

  const [step, setStep] = useState('form'); // form | processing | success | error
  const [createdOrder, setCreatedOrder] = useState(null);
  const [errors, setErrors] = useState({});

  const [form, setForm] = useState({
    user_name: user?.full_name || '',
    user_email: user?.email || '',
    phone: user?.phone || '',
    address: '',
  });

  // Re-prefill if user logs in mid-flow
  useEffect(() => {
    if (user && step === 'form') {
      setForm((f) => ({
        user_name: f.user_name || user.full_name || '',
        user_email: f.user_email || user.email || '',
        phone: f.phone || user.phone || '',
        address: f.address,
      }));
    }
  }, [user]); // eslint-disable-line react-hooks/exhaustive-deps

  // Preload Razorpay SDK in production so the modal opens instantly
  useEffect(() => {
    if (!DEV_MODE) loadRazorpayScript();
  }, []);

  // Guard: empty cart → bounce back to /cart (only while on the form step)
  useEffect(() => {
    if (cartCount === 0 && step === 'form') {
      navigate('/cart', { replace: true });
    }
  }, [cartCount, step, navigate]);

  // ─── Pricing summary ───────────────────────────────────────────
  const subtotal = cartTotal;
  const originalTotal = cartItems.reduce(
    (sum, item) => sum + parseFloat(item.product.price) * item.quantity, 0
  );
  const savings = originalTotal - subtotal;
  const gstPercent = parseFloat(gst_percent);
  const gstAmount = Math.round(subtotal * gstPercent) / 100;
  const freeThreshold = parseFloat(free_shipping_threshold);
  const shippingFee = parseFloat(standard_shipping_fee);
  const shipping = subtotal >= freeThreshold ? 0 : shippingFee;
  const grandTotal = subtotal + gstAmount + shipping;

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    if (errors[e.target.name]) {
      setErrors((p) => ({ ...p, [e.target.name]: undefined }));
    }
  };

  const validate = () => {
    const errs = {};
    if (!form.user_name.trim()) errs.user_name = 'Full name is required';
    if (!form.user_email) errs.user_email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(form.user_email))
      errs.user_email = 'Invalid email address';
    if (!form.phone) errs.phone = 'Phone is required';
    else if (!/^\d{10}$/.test(form.phone.replace(/\D/g, '').slice(-10)))
      errs.phone = 'Enter a valid 10-digit mobile number';
    if (!form.address.trim()) errs.address = 'Delivery address is required';
    else if (form.address.trim().length < 20)
      errs.address = 'Please enter a complete address (min 20 characters)';
    return errs;
  };

  // ─── Main flow ──────────────────────────────────────────────────
  const handleCheckout = async (e) => {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    setErrors({});
    setStep('processing');

    // Step 1 — create order
    let order;
    try {
      const items = cartItems.map((item) => ({
        product_id: item.product.id,
        quantity: item.quantity,
      }));
      order = await createOrder({ ...form, items });
      setCreatedOrder(order);
    } catch (err) {
      const msg =
        err.response?.data?.items?.[0] ||
        err.response?.data?.detail ||
        'Failed to create order. Please try again.';
      toast.error(msg);
      setStep('form');
      return;
    }

    // Step 2A — DEV: simulated payment
    if (DEV_MODE) {
      try {
        const result = await simulatePayment(order.order_id);
        clearCart();
        setCreatedOrder({ ...order, erp_order_id: result.erp_order_id });
        setStep('success');
      } catch {
        toast.error('Payment simulation failed.');
        setStep('form');
      }
      return;
    }

    // Step 2B — PROD: real Razorpay
    const ok = await loadRazorpayScript();
    if (!ok) {
      toast.error('Payment gateway failed to load. Please refresh and try again.');
      setStep('form');
      return;
    }

    let rzOrder;
    try {
      rzOrder = await createRazorpayOrder(order.order_id);
    } catch {
      toast.error('Failed to initialize payment. Please try again.');
      setStep('form');
      return;
    }

    const options = {
      key: rzOrder.key_id,
      amount: rzOrder.amount,
      currency: rzOrder.currency,
      name: 'FurniShop',
      description: `Order ${order.order_id}`,
      order_id: rzOrder.razorpay_order_id,
      prefill: rzOrder.prefill || {
        name: form.user_name,
        email: form.user_email,
        contact: form.phone,
      },
      notes: { furnishop_order_id: order.order_id },
      theme: { color: '#00736A' },
      modal: {
        ondismiss: () => {
          toast.error('Payment cancelled. Your order is saved — you can pay later from My Orders.');
          setStep('form');
        },
      },
      handler: async (response) => {
        try {
          const verifyResult = await verifyPayment({
            order_id: order.order_id,
            razorpay_order_id: response.razorpay_order_id,
            razorpay_payment_id: response.razorpay_payment_id,
            razorpay_signature: response.razorpay_signature,
          });
          clearCart();
          setCreatedOrder({ ...order, erp_order_id: verifyResult.erp_order_id });
          setStep('success');
        } catch {
          toast.error('Payment verification failed. Please contact support.');
          setStep('error');
        }
      },
    };

    const rzp = new window.Razorpay(options);
    rzp.on('payment.failed', (resp) => {
      toast.error(`Payment failed: ${resp.error?.description || 'Unknown error'}`);
      setStep('form');
    });
    rzp.open();
  };

  // ─── Render: Processing ─────────────────────────────────────────
  if (step === 'processing') {
    return (
      <div className="checkout-page container">
        <div className="checkout-processing">
          <div className="checkout-processing__spinner" />
          <h3>Creating your order…</h3>
          <p>Please do not close this page.</p>
        </div>
      </div>
    );
  }

  // ─── Render: Success ────────────────────────────────────────────
  if (step === 'success' && createdOrder) {
    return (
      <div className="checkout-page container">
        <div className="checkout-success" data-testid="checkout-success">
          <div className="checkout-success__icon">
            <FiCheckCircle size={64} />
          </div>
          <h2>Order Placed Successfully!</h2>
          <p>Thank you for shopping with FurniShop.</p>

          <div className="checkout-success__details">
            <div className="checkout-success__detail-row">
              <span>Order ID</span>
              <strong data-testid="success-order-id">{createdOrder.order_id}</strong>
            </div>
            {createdOrder.erp_order_id && (
              <div className="checkout-success__detail-row">
                <span>ERP Reference</span>
                <strong>{createdOrder.erp_order_id}</strong>
              </div>
            )}
            <div className="checkout-success__detail-row">
              <span>Email</span>
              <strong>{form.user_email}</strong>
            </div>
            <div className="checkout-success__detail-row">
              <span>Total Paid</span>
              <strong>{formatPrice(createdOrder.total_amount || grandTotal)}</strong>
            </div>
          </div>

          <div className="checkout-success__actions">
            <Link to="/orders" className="btn-primary">View My Orders</Link>
            <Link to="/" className="btn-outline">Continue Shopping</Link>
          </div>

          <p className="checkout-success__note">
            A confirmation will be sent to {form.user_email}. Your order will be confirmed shortly.
          </p>
        </div>
      </div>
    );
  }

  // ─── Render: Error ──────────────────────────────────────────────
  if (step === 'error') {
    return (
      <div className="checkout-page container">
        <div className="checkout-error">
          <FiAlertCircle size={64} color="var(--color-error)" />
          <h2>Payment Verification Failed</h2>
          <p>Your payment may have been processed but we couldn't verify it.</p>
          <p>
            Please contact support with your Order ID:{' '}
            <strong>{createdOrder?.order_id}</strong>
          </p>
          <div className="checkout-error__actions">
            <Link to="/orders" className="btn-primary">Check Order Status</Link>
            <a href="mailto:support@furnishop.com" className="btn-outline">Contact Support</a>
          </div>
        </div>
      </div>
    );
  }

  // ─── Render: Form ───────────────────────────────────────────────
  return (
    <div className="checkout-page container">
      <h1>Checkout</h1>

      <div className="checkout-layout">
        {/* Address Form */}
        <form className="checkout-form" onSubmit={handleCheckout} id="checkout-form" noValidate>
          <h3>Delivery Details</h3>

          <div className={`form-group ${errors.user_name ? 'form-group--error' : ''}`}>
            <label className="form-label" htmlFor="user_name">Full Name</label>
            <input
              className="form-input" id="user_name" name="user_name"
              value={form.user_name} onChange={handleChange}
              placeholder="John Doe" autoComplete="name"
            />
            {errors.user_name && <span className="form-error">{errors.user_name}</span>}
          </div>

          <div className="form-row">
            <div className={`form-group ${errors.user_email ? 'form-group--error' : ''}`}>
              <label className="form-label" htmlFor="user_email">Email</label>
              <input
                className="form-input" id="user_email" name="user_email" type="email"
                value={form.user_email} onChange={handleChange}
                placeholder="john@example.com" autoComplete="email"
              />
              {errors.user_email && <span className="form-error">{errors.user_email}</span>}
            </div>
            <div className={`form-group ${errors.phone ? 'form-group--error' : ''}`}>
              <label className="form-label" htmlFor="phone">Phone</label>
              <input
                className="form-input" id="phone" name="phone"
                value={form.phone} onChange={handleChange}
                placeholder="98765 43210" autoComplete="tel"
                maxLength={10}
              />
              {errors.phone && <span className="form-error">{errors.phone}</span>}
            </div>
          </div>

          <div className={`form-group ${errors.address ? 'form-group--error' : ''}`}>
            <label className="form-label" htmlFor="address">Delivery Address</label>
            <textarea
              className="form-input" id="address" name="address"
              value={form.address} onChange={handleChange}
              placeholder="House/flat number, street, area, city, state, PIN code"
              rows={4} autoComplete="street-address"
            />
            {errors.address && <span className="form-error">{errors.address}</span>}
          </div>

          <button type="submit" className="btn-primary pay-btn checkout-pay-btn" id="pay-now-btn">
            <FiLock size={16} />
            {DEV_MODE ? `Pay Now (Simulated) — ${formatPrice(grandTotal)}` : `Pay Securely — ${formatPrice(grandTotal)}`}
          </button>

          <p className="checkout-razorpay-badge">
            <FiLock size={12} />
            {DEV_MODE
              ? 'Development mode — payment will be simulated, no real charge'
              : 'Secured by Razorpay · 256-bit SSL encryption'}
          </p>
        </form>

        {/* Order Summary */}
        <aside className="checkout-summary">
          <h3>Order Summary</h3>
          <div className="checkout-items">
            {cartItems.map((item) => {
              const eff = parseFloat(item.product.effective_price ?? item.product.price);
              return (
                <div key={item.product.id} className="checkout-item">
                  <img src={item.product.image_url} alt={item.product.name} />
                  <div className="checkout-item-info">
                    <span className="checkout-item-name">{item.product.name}</span>
                    <span className="checkout-item-qty">Qty: {item.quantity}</span>
                  </div>
                  <span className="checkout-item-price">
                    {formatPrice(eff * item.quantity)}
                  </span>
                </div>
              );
            })}
          </div>

          <div className="checkout-summary__rows">
            <div className="checkout-summary__row">
              <span>Subtotal</span>
              <span>{formatPrice(originalTotal)}</span>
            </div>
            {savings > 0 && (
              <div className="checkout-summary__row checkout-summary__row--savings">
                <span>You Save</span>
                <span>−{formatPrice(savings)}</span>
              </div>
            )}
            <div className="checkout-summary__row">
              <span>GST ({gstPercent}%)</span>
              <span>{formatPrice(gstAmount)}</span>
            </div>
            <div className="checkout-summary__row">
              <span>Shipping</span>
              <span style={{ color: shipping === 0 ? 'var(--color-success)' : 'inherit' }}>
                {shipping === 0 ? 'FREE' : formatPrice(shipping)}
              </span>
            </div>
          </div>

          <div className="checkout-total">
            <span>Total</span>
            <span>{formatPrice(grandTotal)}</span>
          </div>
        </aside>
      </div>
    </div>
  );
}
