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
  validateCoupon, estimateShipping,
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
  const { user, loading: authLoading } = useAuth();
  const { settings } = useSettings();
  const { gst_percent, free_shipping_threshold, standard_shipping_fee } = settings;

  const navigate = useNavigate();

  // ─── Auth gate ────────────────────────────────────────────────────────
  // Anyone who lands on /checkout without being logged in is bounced to
  // /login?next=/checkout. After they finish login the LoginPage reads
  // ?next=… and redirects them back here with cart intact (cart lives in
  // localStorage so it survives the round-trip).
  useEffect(() => {
    if (authLoading) return;        // wait for restore() to finish
    if (!user) {
      // Stable `id` so React 18 StrictMode's double-effect-fire in dev
      // (and any future re-render that briefly clears `user`) dedupes the
      // toast — react-hot-toast treats two toasts with the same id as one.
      toast('Please sign in to continue checkout.', { id: 'checkout-auth-gate' });
      navigate('/login?next=/checkout', { replace: true });
    }
  }, [user, authLoading, navigate]);

  const [step, setStep] = useState('form'); // form | processing | success | error
  const [createdOrder, setCreatedOrder] = useState(null);
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);

  // Address is split into structured fields for a cleaner form. They are
  // joined into a single string before sending to the backend (which still
  // expects one `address` field). The textarea-everywhere look is gone.
  const [form, setForm] = useState({
    user_name: user?.full_name || '',
    user_email: user?.email || '',
    phone: user?.phone || '',
    house_no: '',
    street: '',
    landmark: '',
    city: '',
    state: '',
    pincode: '',
  });

  // Pay-now incentive: 'immediate' earns extra 5% off; 'cod' / 'credit' don't.
  // Dealers also see 'credit' if their account allows it. Backend re-derives
  // from payment_method when payment_type is omitted.
  const [paymentType, setPaymentType] = useState('immediate');
  const EARLY_DISCOUNT_PCT = 5;

  // Coupon state
  const [couponInput, setCouponInput] = useState('');
  const [couponState, setCouponState] = useState({
    code: '', discount: 0, free_shipping: false, message: '',
  });
  const [couponLoading, setCouponLoading] = useState(false);

  // Shipping estimate state (computed when pincode is entered)
  const [shipEstimate, setShipEstimate] = useState(null);
  const [shipLoading, setShipLoading] = useState(false);

  // Dealer specific state
  const [dealerCredit, setDealerCredit] = useState(null);
  const [dealerWallet, setDealerWallet] = useState(null);

  // Re-prefill if user logs in mid-flow

  useEffect(() => {
    if (user && step === 'form') {
      setForm((f) => ({
        ...f,
        user_name: f.user_name || user.full_name || '',
        user_email: f.user_email || user.email || '',
        phone: f.phone || user.phone || '',
      }));
    }
  }, [user]); // eslint-disable-line react-hooks/exhaustive-deps

  // Preload Razorpay SDK in production so the modal opens instantly
  useEffect(() => {
    if (!DEV_MODE) loadRazorpayScript();

    // Fetch dealer info if applicable
    if (user?.role === 'dealer') {
      import('../api').then(({ fetchDealerCredit, fetchDealerWallet }) => {
        fetchDealerCredit().then(setDealerCredit).catch(() => {});
        fetchDealerWallet().then(setDealerWallet).catch(() => {});
      });
    }
  }, [user]);


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

  const couponDiscount = parseFloat(couponState.discount) || 0;
  const afterCoupon = Math.max(subtotal - couponDiscount, 0);
  // Mirror backend math: pay-now discount applies AFTER coupon, BEFORE GST.
  const earlyPayDiscount = paymentType === 'immediate'
    ? Math.round(afterCoupon * EARLY_DISCOUNT_PCT) / 100
    : 0;
  const adjustedSubtotal = Math.max(afterCoupon - earlyPayDiscount, 0);
  const gstAmount = Math.round(adjustedSubtotal * gstPercent) / 100;

  const freeThreshold = parseFloat(free_shipping_threshold);
  const shippingFee = parseFloat(standard_shipping_fee);
  const baseShipping = subtotal >= freeThreshold ? 0 : shippingFee;
  // Pincode-aware shipping wins over the flat fallback once an estimate exists
  const pincodeShipping = shipEstimate ? parseFloat(shipEstimate.fee) : null;
  const shipping = couponState.free_shipping
    ? 0
    : (pincodeShipping ?? baseShipping);

  const grandTotal = adjustedSubtotal + gstAmount + shipping;

  const handleApplyCoupon = async () => {
    const code = couponInput.trim().toUpperCase();
    if (!code) return;
    setCouponLoading(true);
    try {
      const res = await validateCoupon(code, subtotal);
      setCouponState({
        code: res.code || code,
        discount: parseFloat(res.discount) || 0,
        free_shipping: !!res.free_shipping,
        message: res.message,
      });
      toast.success(res.message);
    } catch (err) {
      const msg = err.response?.data?.message || 'Invalid or inapplicable coupon.';
      setCouponState({ code: '', discount: 0, free_shipping: false, message: msg });
      toast.error(msg);
    } finally {
      setCouponLoading(false);
    }
  };

  const handleClearCoupon = () => {
    setCouponInput('');
    setCouponState({ code: '', discount: 0, free_shipping: false, message: '' });
  };

  // Auto-estimate shipping when pincode is 6 digits
  useEffect(() => {
    const pin = (form.pincode || '').trim();
    if (!/^\d{6}$/.test(pin)) {
      setShipEstimate(null);
      return undefined;
    }
    let live = true;
    setShipLoading(true);
    estimateShipping({ pincode: pin, subtotal })
      .then((r) => { if (live) setShipEstimate(r); })
      .catch(() => { if (live) setShipEstimate(null); })
      .finally(() => { if (live) setShipLoading(false); });
    return () => { live = false; };
  }, [form.pincode, subtotal]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    if (errors[e.target.name]) {
      setErrors((p) => ({ ...p, [e.target.name]: undefined }));
    }
  };

  // Build a single address string from the structured fields. Used both for
  // validation and submission so the backend keeps receiving one `address`.
  const composedAddress = () => {
    return [
      form.house_no, form.street, form.landmark,
      form.city, form.state, form.pincode,
    ].map((s) => (s || '').trim()).filter(Boolean).join(', ');
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
    if (!form.house_no.trim()) errs.house_no = 'House / flat is required';
    if (!form.street.trim()) errs.street = 'Street / area is required';
    if (!form.city.trim()) errs.city = 'City is required';
    if (!form.state.trim()) errs.state = 'State is required';
    if (!form.pincode) errs.pincode = 'Pincode is required';
    else if (!/^\d{6}$/.test(form.pincode.trim()))
      errs.pincode = 'Pincode must be 6 digits';
    return errs;
  };

  // ─── Main flow ──────────────────────────────────────────────────
  const handleCheckout = async (e) => {
    e.preventDefault();
    if (submitting) return; // guard against double-submits / impatient clickers
    const errs = validate();
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    setErrors({});
    setSubmitting(true);
    setStep('processing');

    // Step 1 — create order
    let order;
    try {
      const items = cartItems.map((item) => ({
        product_id: item.product.id,
        quantity: item.quantity,
      }));
      // Backend still expects one `address` string — compose it from our
      // structured fields. We drop the per-field keys from the payload so
      // the backend doesn't see unrecognised fields.
      const { house_no, street, landmark, city, state: stateField, ...rest } = form;
      void house_no; void street; void landmark; void city; void stateField;
      const orderPayload = {
        ...rest,
        address: composedAddress(),
        items,
        payment_type: paymentType,
      };
      // Map UI choice → backend payment_method so the right pay path runs.
      if (paymentType === 'cod') orderPayload.payment_method = 'cod';
      else if (paymentType === 'credit') orderPayload.payment_method = 'credit';
      else if (paymentType === 'wallet') orderPayload.payment_method = 'wallet';
      else orderPayload.payment_method = 'razorpay';

      if (couponState.code) orderPayload.coupon_code = couponState.code;
      order = await createOrder(orderPayload);
      setCreatedOrder(order);
      // Clear the cart the moment the order is committed. Any subsequent
      // payment failure is recoverable from "My Orders" → "Pay now" — but
      // leaving items in the cart tempts the buyer to re-checkout and
      // create duplicates. Order is the source of truth from here on.
      clearCart();
    } catch (err) {
      const status = err.response?.status;
      const msg =
        err.response?.data?.items?.[0] ||
        err.response?.data?.detail ||
        (err.code === 'ECONNABORTED'
          ? 'The server is taking longer than usual. Your order may have been placed — please check My Orders before retrying.'
          : status >= 500
            ? 'Server error while creating the order. Please try again in a moment.'
            : 'Failed to create order. Please review your details and try again.');
      toast.error(msg);
      setStep('form');
      setSubmitting(false);
      return;
    }

    // Step 2A — DEV or B2B payments: simulated/direct payment
    if (DEV_MODE || paymentType === 'credit' || paymentType === 'wallet') {
      try {
        const result = await simulatePayment(order.order_id);
        setCreatedOrder({ ...order, erp_order_id: result.erp_order_id });
        setStep('success');
      } catch {
        // Order is committed already; payment is the failing step. Show success
        // with a "Pay later from My Orders" hint instead of a hard error.
        toast.error('Payment could not be confirmed. Your order is saved — pay later from My Orders.');
        setStep('success');
      } finally {
        setSubmitting(false);
      }
      return;
    }


    // Step 2B — PROD: real Razorpay
    const ok = await loadRazorpayScript();
    if (!ok) {
      toast.error('Payment gateway failed to load. Please refresh and try again.');
      setStep('form');
      setSubmitting(false);
      return;
    }

    let rzOrder;
    try {
      rzOrder = await createRazorpayOrder(order.order_id);
    } catch {
      toast.error('Failed to initialize payment. Please try again.');
      setStep('form');
      setSubmitting(false);
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
          setSubmitting(false);
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
          setCreatedOrder({ ...order, erp_order_id: verifyResult.erp_order_id });
          setStep('success');
        } catch {
          toast.error('Payment verification failed. Please contact support.');
          setStep('error');
        } finally {
          setSubmitting(false);
        }
      },
    };

    const rzp = new window.Razorpay(options);
    rzp.on('payment.failed', (resp) => {
      toast.error(`Payment failed: ${resp.error?.description || 'Unknown error'}`);
      setStep('form');
      setSubmitting(false);
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

          {/* Structured address — no more giant textarea */}
          <div className="form-row form-row--3">
            <div className={`form-group ${errors.house_no ? 'form-group--error' : ''}`}>
              <label className="form-label" htmlFor="house_no">House / Flat / Building</label>
              <input
                className="form-input" id="house_no" name="house_no"
                value={form.house_no} onChange={handleChange}
                placeholder="e.g. Flat 302, Lotus Heights"
                autoComplete="address-line1"
              />
              {errors.house_no && <span className="form-error">{errors.house_no}</span>}
            </div>
            <div className={`form-group form-group--span-2 ${errors.street ? 'form-group--error' : ''}`}>
              <label className="form-label" htmlFor="street">Street / Area</label>
              <input
                className="form-input" id="street" name="street"
                value={form.street} onChange={handleChange}
                placeholder="MG Road, Indiranagar"
                autoComplete="address-line2"
              />
              {errors.street && <span className="form-error">{errors.street}</span>}
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="landmark">Landmark <span style={{ color: '#888', fontWeight: 400 }}>(optional)</span></label>
            <input
              className="form-input" id="landmark" name="landmark"
              value={form.landmark} onChange={handleChange}
              placeholder="Opposite Apollo Hospital"
            />
          </div>

          <div className="form-row form-row--3">
            <div className={`form-group ${errors.city ? 'form-group--error' : ''}`}>
              <label className="form-label" htmlFor="city">City</label>
              <input
                className="form-input" id="city" name="city"
                value={form.city} onChange={handleChange}
                placeholder="Bengaluru"
                autoComplete="address-level2"
              />
              {errors.city && <span className="form-error">{errors.city}</span>}
            </div>
            <div className={`form-group ${errors.state ? 'form-group--error' : ''}`}>
              <label className="form-label" htmlFor="state">State</label>
              <input
                className="form-input" id="state" name="state"
                value={form.state} onChange={handleChange}
                placeholder="Karnataka"
                autoComplete="address-level1"
              />
              {errors.state && <span className="form-error">{errors.state}</span>}
            </div>
            <div className={`form-group ${errors.pincode ? 'form-group--error' : ''}`}>
              <label className="form-label" htmlFor="pincode">PIN code</label>
              <input
                className="form-input" id="pincode" name="pincode"
                type="text" inputMode="numeric" maxLength={6}
                value={form.pincode}
                onChange={(e) => setForm({ ...form, pincode: e.target.value.replace(/\D/g, '').slice(0, 6) })}
                placeholder="560001"
                autoComplete="postal-code"
              />
              {errors.pincode && <span className="form-error">{errors.pincode}</span>}
              {shipEstimate && !shipEstimate.cod_available && (
              <span className="form-error" style={{ color: '#92400E' }}>
                Note: COD is not available for this PIN code.
              </span>
            )}
            {shipEstimate?.message && (
              <span className="form-help" style={{ color: '#6B7280', fontSize: 12 }}>
                {shipEstimate.message}
              </span>
            )}
            </div>
          </div>

          <h3 style={{ marginTop: 24 }}>Payment</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginBottom: 12 }}>
            <label style={paymentTileStyle(paymentType === 'immediate')}>
              <input type="radio" name="paymentType" value="immediate"
                     checked={paymentType === 'immediate'}
                     onChange={() => setPaymentType('immediate')}
                     style={{ marginRight: 6 }} />
              <div>
                <strong>Pay Now</strong>
                <div style={{ color: '#16A34A', fontSize: 12, fontWeight: 600 }}>
                  Save extra {EARLY_DISCOUNT_PCT}%
                </div>
                <div style={{ color: '#6B7280', fontSize: 11 }}>UPI / card / net banking</div>
              </div>
            </label>
            <label style={paymentTileStyle(paymentType === 'cod')}>
              <input type="radio" name="paymentType" value="cod"
                     checked={paymentType === 'cod'}
                     onChange={() => setPaymentType('cod')}
                     style={{ marginRight: 6 }}
                     disabled={shipEstimate && !shipEstimate.cod_available} />
              <div>
                <strong>Cash on Delivery</strong>
                <div style={{ color: '#6B7280', fontSize: 12 }}>No extra discount</div>
                {shipEstimate && !shipEstimate.cod_available && (
                   <div style={{ color: '#92400E', fontSize: 11 }}>Not available for this PIN</div>
                )}
              </div>
            </label>

            {user?.role === 'dealer' && (
              <>
                <label style={paymentTileStyle(paymentType === 'credit')}>
                  <input type="radio" name="paymentType" value="credit"
                         checked={paymentType === 'credit'}
                         onChange={() => setPaymentType('credit')}
                         style={{ marginRight: 6 }}
                         disabled={!dealerCredit?.is_active || (parseFloat(dealerCredit?.credit_limit || 0) - parseFloat(dealerCredit?.amount_used || 0)) < grandTotal} />
                  <div>
                    <strong>Dealer Credit</strong>
                    <div style={{ color: '#6B7280', fontSize: 11 }}>
                      Limit: {formatPrice(parseFloat(dealerCredit?.credit_limit || 0) - parseFloat(dealerCredit?.amount_used || 0))}
                    </div>
                    {!dealerCredit?.is_active && <div style={{ color: '#92400E', fontSize: 10 }}>Credit inactive</div>}
                  </div>
                </label>
                <label style={paymentTileStyle(paymentType === 'wallet')}>
                  <input type="radio" name="paymentType" value="wallet"
                         checked={paymentType === 'wallet'}
                         onChange={() => setPaymentType('wallet')}
                         style={{ marginRight: 6 }}
                         disabled={!dealerWallet?.is_active || parseFloat(dealerWallet?.balance || 0) < grandTotal} />
                  <div>
                    <strong>Dealer Wallet</strong>
                    <div style={{ color: '#6B7280', fontSize: 11 }}>
                      Balance: {formatPrice(dealerWallet?.balance || 0)}
                    </div>
                    {!dealerWallet?.is_active && <div style={{ color: '#92400E', fontSize: 10 }}>Wallet inactive</div>}
                  </div>
                </label>
              </>
            )}
          </div>


          <button
            type="submit"
            className="btn-primary pay-btn checkout-pay-btn"
            id="pay-now-btn"
            disabled={submitting}
            aria-busy={submitting}
          >
            <FiLock size={16} />
            {submitting
              ? 'Processing — please wait…'
              : paymentType === 'cod'
                ? `Place COD Order — ${formatPrice(grandTotal)}`
                : paymentType === 'credit'
                  ? `Pay via Credit — ${formatPrice(grandTotal)}`
                  : paymentType === 'wallet'
                    ? `Pay via Wallet — ${formatPrice(grandTotal)}`
                    : DEV_MODE
                      ? `Pay Now (Simulated) — ${formatPrice(grandTotal)}`
                      : `Pay Securely — ${formatPrice(grandTotal)}`}

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

            {/* Coupon */}
            <div style={{ display: 'flex', gap: 6, alignItems: 'stretch', marginTop: 8 }}>
              <input
                type="text"
                placeholder="Coupon code"
                value={couponInput}
                onChange={(e) => setCouponInput(e.target.value.toUpperCase())}
                disabled={!!couponState.code || couponLoading}
                style={{ flex: 1, padding: '8px 10px', border: '1px solid #D1D5DB',
                         borderRadius: 6, textTransform: 'uppercase' }}
              />
              {couponState.code ? (
                <button type="button" onClick={handleClearCoupon}
                        style={{ padding: '0 12px', borderRadius: 6, border: '1px solid #D1D5DB',
                                 background: '#F3F4F6', cursor: 'pointer' }}>
                  Remove
                </button>
              ) : (
                <button type="button" onClick={handleApplyCoupon}
                        disabled={!couponInput.trim() || couponLoading}
                        style={{ padding: '0 12px', borderRadius: 6, border: 0,
                                 background: '#111827', color: '#fff',
                                 cursor: couponLoading ? 'progress' : 'pointer' }}>
                  {couponLoading ? '…' : 'Apply'}
                </button>
              )}
            </div>
            {couponState.code && couponState.discount > 0 && (
              <div className="checkout-summary__row checkout-summary__row--savings">
                <span>Coupon ({couponState.code})</span>
                <span>−{formatPrice(couponState.discount)}</span>
              </div>
            )}
            {earlyPayDiscount > 0 && (
              <div className="checkout-summary__row checkout-summary__row--savings">
                <span>Pay-Now Discount ({EARLY_DISCOUNT_PCT}%)</span>
                <span>−{formatPrice(earlyPayDiscount)}</span>
              </div>
            )}

            <div className="checkout-summary__row">
              <span>GST ({gstPercent}%)</span>
              <span>{formatPrice(gstAmount)}</span>
            </div>
            <div className="checkout-summary__row">
              <span>
                Shipping
                {shipEstimate?.zone_name && (
                  <small style={{ display: 'block', color: '#6B7280', fontSize: 11 }}>
                    {shipEstimate.zone_name}
                    {shipEstimate.etd_days_min &&
                      ` · ${shipEstimate.etd_days_min}-${shipEstimate.etd_days_max} days`}
                  </small>
                )}
                {shipLoading && (
                  <small style={{ display: 'block', color: '#6B7280', fontSize: 11 }}>
                    Checking pincode…
                  </small>
                )}
              </span>
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

const paymentTileStyle = (active) => ({
  display: 'flex', alignItems: 'flex-start', gap: 6,
  padding: 12, borderRadius: 8,
  border: `2px solid ${active ? '#0E766E' : '#E5E7EB'}`,
  background: active ? '#F0FDFA' : '#fff',
  cursor: 'pointer',
});
