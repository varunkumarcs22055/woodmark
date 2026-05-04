# Frontend Prompt 5 — Checkout Page & Razorpay Payment Integration

## Role
You are a senior frontend engineer. Build the complete checkout experience for FurniShop: the checkout form page, real Razorpay payment integration (frontend modal), payment success/failure handling, and the order confirmation screen.

---

## Context
Checkout is the most critical flow — any bug here costs revenue. The checkout page collects shipping details, creates an order via the API, then triggers Razorpay's payment modal. After payment, the signature is verified server-side. A development-only "Pay Now (Simulated)" button is also shown when `VITE_DEV_MODE=true`.

**Depends on:** Frontend Prompts 1, 3 (CartContext, CartPage), Backend Prompts 7, 8 (order creation, Razorpay)
**Backend endpoints used:**
- `POST /api/orders/create/`
- `POST /api/payment/create-razorpay-order/`
- `POST /api/payment/verify/`
- `POST /api/payment/success/` (dev simulation only)

---

## Files to Create

```
frontend/src/pages/
├── CheckoutPage.jsx
└── CheckoutPage.css
```

---

## Razorpay Script Loading

Load the Razorpay checkout script dynamically. Do NOT use npm package — load from CDN:

```javascript
const loadRazorpayScript = () => {
  return new Promise((resolve) => {
    if (window.Razorpay) { resolve(true); return; }
    const script = document.createElement('script');
    script.src = 'https://checkout.razorpay.com/v1/checkout.js';
    script.onload = () => resolve(true);
    script.onerror = () => resolve(false);
    document.body.appendChild(script);
  });
};
```

Call this in a `useEffect` on component mount:
```javascript
useEffect(() => {
  loadRazorpayScript();
}, []);
```

---

## CheckoutPage — `src/pages/CheckoutPage.jsx`

### State
```javascript
const { cartItems, cartTotal, cartCount, clearCart } = useCart();
const { user } = useAuth();
const navigate = useNavigate();

// Pre-fill form with logged-in user's info
const [form, setForm] = useState({
  user_name: user?.full_name || '',
  user_email: user?.email || '',
  phone: user?.phone || '',
  address: '',
});
const [errors, setErrors] = useState({});

// Flow state
const [step, setStep] = useState('form'); // 'form' | 'processing' | 'success' | 'error'
const [createdOrder, setCreatedOrder] = useState(null);

const DEV_MODE = import.meta.env.VITE_DEV_MODE === 'true';
```

### Guard: Redirect if cart is empty
```javascript
useEffect(() => {
  if (cartCount === 0 && step === 'form') {
    navigate('/cart');
  }
}, [cartCount]);
```

### Form Validation
```javascript
const validate = () => {
  const errs = {};
  if (!form.user_name.trim()) errs.user_name = 'Full name is required';
  if (!form.user_email) errs.user_email = 'Email is required';
  else if (!/\S+@\S+\.\S+/.test(form.user_email)) errs.user_email = 'Invalid email address';
  if (!form.phone) errs.phone = 'Phone number is required';
  else if (!/^\d{10}$/.test(form.phone)) errs.phone = 'Enter a valid 10-digit mobile number';
  if (!form.address.trim()) errs.address = 'Delivery address is required';
  else if (form.address.trim().length < 20) errs.address = 'Please enter a complete address (minimum 20 characters)';
  return errs;
};
```

### Full Checkout Flow

```javascript
const handleCheckout = async (e) => {
  e.preventDefault();
  const errs = validate();
  if (Object.keys(errs).length > 0) { setErrors(errs); return; }
  setErrors({});

  // Step 1: Create Order
  setStep('processing');
  let order;
  try {
    const items = cartItems.map((item) => ({
      product_id: item.product.id,
      quantity: item.quantity,
    }));
    order = await createOrder({ ...form, items });
    setCreatedOrder(order);
  } catch (err) {
    const msg = err.response?.data?.items?.[0] || err.response?.data?.detail || 'Failed to create order. Please try again.';
    toast.error(msg);
    setStep('form');
    return;
  }

  // Step 2A: DEV — use simulated payment
  if (DEV_MODE) {
    try {
      const result = await simulatePayment(order.order_id);
      clearCart();
      setCreatedOrder({ ...order, erp_order_id: result.erp_order_id });
      setStep('success');
    } catch (err) {
      toast.error('Payment simulation failed.');
      setStep('form');
    }
    return;
  }

  // Step 2B: PRODUCTION — real Razorpay
  const razorpayLoaded = await loadRazorpayScript();
  if (!razorpayLoaded) {
    toast.error('Payment gateway failed to load. Please refresh and try again.');
    setStep('form');
    return;
  }

  let razorpayOrderData;
  try {
    razorpayOrderData = await createRazorpayOrder(order.order_id);
  } catch (err) {
    toast.error('Failed to initialize payment. Please try again.');
    setStep('form');
    return;
  }

  // Step 3: Open Razorpay modal
  const options = {
    key: razorpayOrderData.key_id,
    amount: razorpayOrderData.amount,
    currency: razorpayOrderData.currency,
    name: 'FurniShop',
    description: `Order ${order.order_id}`,
    image: '/logo.png',
    order_id: razorpayOrderData.razorpay_order_id,
    prefill: razorpayOrderData.prefill,
    notes: { furnishop_order_id: order.order_id },
    theme: { color: '#00736A' },
    modal: {
      ondismiss: () => {
        toast.error('Payment cancelled. Your order is saved — you can pay later.');
        setStep('form');
      },
    },
    handler: async (response) => {
      // Step 4: Verify signature
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
        toast.error('Payment verification failed. Please contact support with your order ID.');
        setStep('error');
      }
    },
  };

  const rzp = new window.Razorpay(options);
  rzp.on('payment.failed', (response) => {
    toast.error(`Payment failed: ${response.error.description}`);
    setStep('form');
  });
  rzp.open();
};
```

---

## Page Layout

### Step: Form

```
┌──────────────────────────────────────┬────────────────────────┐
│  Delivery Details                    │  Order Summary         │
│  ──────────────────────────────────  │  ───────────────────   │
│  Full Name    [________________]     │  3 items               │
│  Email        [________________]     │  [img] Oslo Sofa  1×   │
│  Phone        [________________]     │  [img] Chair      2×   │
│  Delivery     [________________]     │                        │
│  Address      [________________]     │  Subtotal: ₹XX,XXX     │
│               [________________]     │  Discount: -₹X,XXX     │
│               [________________]     │  Shipping: FREE        │
│                                      │  ─────────────────     │
│  [Pay Securely with Razorpay]        │  Total: ₹XX,XXX        │
│  [Powered by Razorpay 🔒]            │                        │
│                                      │  🔒 Secure checkout    │
└──────────────────────────────────────┴────────────────────────┘
```

### Step: Processing
```jsx
<div className="checkout-processing">
  <div className="checkout-processing__spinner" />
  <h3>Creating your order…</h3>
  <p>Please do not close this page.</p>
</div>
```

### Step: Success
```jsx
<div className="checkout-success" data-testid="checkout-success">
  <div className="checkout-success__icon">
    <FiCheckCircle size={64} color="var(--color-success)" />
  </div>
  <h2>Order Placed Successfully!</h2>
  <p>Thank you for shopping with FurniShop.</p>

  <div className="checkout-success__details">
    <div className="checkout-success__detail-row">
      <span>Order ID</span>
      <strong data-testid="success-order-id">{createdOrder?.order_id}</strong>
    </div>
    {createdOrder?.erp_order_id && (
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
      <strong>{formatPrice(createdOrder?.total_amount)}</strong>
    </div>
  </div>

  <div className="checkout-success__actions">
    <Link to="/orders" className="btn-primary">
      View My Orders
    </Link>
    <Link to="/" className="btn-outline">
      Continue Shopping
    </Link>
  </div>

  <p className="checkout-success__note">
    A confirmation will be sent to {form.user_email}.
    Your order will be confirmed shortly.
  </p>
</div>
```

### Step: Error
```jsx
<div className="checkout-error">
  <FiAlertCircle size={64} color="var(--color-error)" />
  <h2>Payment Verification Failed</h2>
  <p>Your payment may have been processed but we couldn't verify it.</p>
  <p>
    Please contact support with your Order ID: <strong>{createdOrder?.order_id}</strong>
  </p>
  <div className="checkout-error__actions">
    <Link to="/orders" className="btn-primary">Check Order Status</Link>
    <a href="mailto:support@furnishop.com" className="btn-outline">Contact Support</a>
  </div>
</div>
```

---

## Order Summary Sidebar

```javascript
const subtotal = cartTotal; // Uses effective_price
const shipping = subtotal >= 2999 ? 0 : 499;
const grandTotal = subtotal + shipping;
const originalTotal = cartItems.reduce(
  (sum, item) => sum + parseFloat(item.product.price) * item.quantity, 0
);
const totalSavings = originalTotal - subtotal;
```

```jsx
<div className="checkout-summary">
  <h3>Order Summary</h3>
  <div className="checkout-summary__items">
    {cartItems.map((item) => (
      <div key={item.product.id} className="checkout-summary__item">
        <img src={item.product.image_url} alt={item.product.name} />
        <div className="checkout-summary__item-info">
          <span className="checkout-summary__item-name">{item.product.name}</span>
          <span className="checkout-summary__item-qty">× {item.quantity}</span>
        </div>
        <span className="checkout-summary__item-price">
          {formatPrice(parseFloat(item.product.effective_price ?? item.product.price) * item.quantity)}
        </span>
      </div>
    ))}
  </div>

  <div className="checkout-summary__totals">
    <div className="checkout-summary__row">
      <span>Subtotal</span>
      <span>{formatPrice(subtotal)}</span>
    </div>
    {totalSavings > 0 && (
      <div className="checkout-summary__row checkout-summary__row--savings">
        <span>You Save</span>
        <span>-{formatPrice(totalSavings)}</span>
      </div>
    )}
    <div className="checkout-summary__row">
      <span>Shipping</span>
      <span>{shipping === 0 ? 'FREE' : formatPrice(shipping)}</span>
    </div>
    <div className="checkout-summary__row checkout-summary__row--total">
      <span>Total</span>
      <strong>{formatPrice(grandTotal)}</strong>
    </div>
  </div>

  <div className="checkout-summary__security">
    <FiLock size={14} />
    <span>Secured by Razorpay · 256-bit SSL encryption</span>
  </div>
</div>
```

---

## CSS — Key Styles `src/pages/CheckoutPage.css`

```css
.checkout-page {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1.5rem;
  display: grid;
  grid-template-columns: 1fr 380px;
  gap: 2rem;
  align-items: start;
}

@media (max-width: 900px) {
  .checkout-page { grid-template-columns: 1fr; }
  .checkout-summary { order: -1; } /* Summary on top on mobile */
}

.checkout-form-section {
  background: white;
  border-radius: var(--radius-lg);
  padding: 2rem;
  box-shadow: var(--shadow-md);
}

.checkout-pay-btn {
  width: 100%; padding: 1rem;
  background: var(--color-primary);
  color: white; font-size: 1.0625rem; font-weight: 600;
  border-radius: var(--radius-md);
  display: flex; align-items: center; justify-content: center; gap: 0.75rem;
  transition: background var(--transition-base);
  margin-top: 1.5rem;
}
.checkout-pay-btn:hover:not(:disabled) { background: var(--color-primary-dark); }
.checkout-pay-btn:disabled { opacity: 0.7; cursor: not-allowed; }

.checkout-razorpay-badge {
  display: flex; align-items: center; justify-content: center; gap: 0.5rem;
  color: var(--color-text-muted); font-size: var(--text-xs);
  margin-top: 0.75rem;
}

.checkout-success {
  text-align: center; padding: 3rem 2rem;
  background: white; border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  max-width: 600px; margin: 2rem auto;
}
.checkout-success__icon { margin-bottom: 1.5rem; }
.checkout-success__details {
  background: var(--color-bg); border-radius: var(--radius-md);
  padding: 1.25rem; margin: 1.5rem 0; text-align: left;
}
.checkout-success__detail-row {
  display: flex; justify-content: space-between;
  padding: 0.5rem 0; border-bottom: 1px solid var(--color-border);
}
.checkout-success__detail-row:last-child { border-bottom: none; }
.checkout-success__actions { display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; margin: 1.5rem 0; }
```

---

## Acceptance Criteria

- [ ] Checkout page redirects to `/cart` if cart is empty
- [ ] Form pre-fills with logged-in user's name, email, phone
- [ ] All form fields validate before submission
- [ ] Order is created via `POST /api/orders/create/` on form submit
- [ ] In `VITE_DEV_MODE=true`: "Pay Now (Simulated)" triggers `POST /api/payment/success/`
- [ ] In production: Razorpay modal opens after order creation
- [ ] Razorpay `handler` callback calls `POST /api/payment/verify/` with all three Razorpay IDs
- [ ] Successful verification: cart cleared, success screen shown with order ID and ERP reference
- [ ] Razorpay modal dismissed (cancelled): toast shown, user stays on form with order preserved
- [ ] Payment failure: error screen shown with order ID for customer support
- [ ] Order summary shows correct subtotal, savings, shipping, grand total
- [ ] "View My Orders" link on success screen works
- [ ] "Continue Shopping" link on success screen works
- [ ] Processing spinner prevents duplicate form submissions
