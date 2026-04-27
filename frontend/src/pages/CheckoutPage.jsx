/**
 * CheckoutPage — Address form + order summary + payment simulation.
 */
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import { createOrder, simulatePayment } from '../api';
import { FiLock, FiCheck } from 'react-icons/fi';
import './CheckoutPage.css';

export default function CheckoutPage() {
  const { cartItems, cartTotal, clearCart } = useCart();
  const navigate = useNavigate();
  const [step, setStep] = useState('form'); // form | processing | success
  const [orderResult, setOrderResult] = useState(null);
  const [error, setError] = useState('');

  const [form, setForm] = useState({
    user_name: '', user_email: '', phone: '', address: '',
  });

  const formatPrice = (price) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(price);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.user_name || !form.user_email || !form.phone || !form.address) {
      setError('Please fill in all fields.');
      return;
    }
    if (cartItems.length === 0) {
      setError('Your cart is empty.');
      return;
    }

    setStep('processing');
    setError('');

    try {
      // Step 1: Create order
      const orderData = {
        ...form,
        items: cartItems.map(item => ({
          product_id: item.product.id,
          quantity: item.quantity,
        })),
      };
      const order = await createOrder(orderData);

      // Step 2: Simulate payment
      const payment = await simulatePayment(order.order_id);

      setOrderResult({ ...order, ...payment });
      setStep('success');
      clearCart();
    } catch (err) {
      console.error('Checkout failed:', err);
      setError(err.response?.data?.error || err.response?.data?.items?.[0] || 'Something went wrong. Please try again.');
      setStep('form');
    }
  };

  // Success screen
  if (step === 'success' && orderResult) {
    return (
      <div className="checkout-page container">
        <div className="checkout-success fade-in">
          <div className="success-icon"><FiCheck size={40} /></div>
          <h2>Order Placed Successfully!</h2>
          <p className="success-order-id">Order ID: <strong>{orderResult.order_id}</strong></p>
          {orderResult.erp_order_id && (
            <p className="success-erp">ERP Reference: {orderResult.erp_order_id}</p>
          )}
          <p className="success-msg">We've received your order and payment. You'll receive a confirmation email shortly.</p>
          <div className="success-actions">
            <button className="btn-primary" onClick={() => navigate('/orders')}>View My Orders</button>
            <button className="btn-secondary" onClick={() => navigate('/')}>Continue Shopping</button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="checkout-page container">
      <h1>Checkout</h1>

      <div className="checkout-layout">
        {/* Address Form */}
        <form className="checkout-form" onSubmit={handleSubmit} id="checkout-form">
          <h3>Shipping Details</h3>

          <div className="form-group">
            <label className="form-label" htmlFor="user_name">Full Name</label>
            <input className="form-input" id="user_name" name="user_name" value={form.user_name} onChange={handleChange} placeholder="John Doe" required />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label" htmlFor="user_email">Email</label>
              <input className="form-input" id="user_email" name="user_email" type="email" value={form.user_email} onChange={handleChange} placeholder="john@example.com" required />
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="phone">Phone</label>
              <input className="form-input" id="phone" name="phone" value={form.phone} onChange={handleChange} placeholder="+91 98765 43210" required />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="address">Shipping Address</label>
            <textarea className="form-input" id="address" name="address" value={form.address} onChange={handleChange} placeholder="123 Main Street, City, State, PIN Code" rows={3} required />
          </div>

          {error && <p className="checkout-error">{error}</p>}

          <button type="submit" className="btn-primary pay-btn" id="pay-now-btn" disabled={step === 'processing'}>
            {step === 'processing' ? (
              <><span className="spinner" /> Processing...</>
            ) : (
              <><FiLock /> Pay Now — {formatPrice(cartTotal)}</>
            )}
          </button>

          <p className="payment-note">
            <FiLock size={12} /> Payment is simulated. No real charges will be made.
          </p>
        </form>

        {/* Order Summary */}
        <aside className="checkout-summary">
          <h3>Order Summary</h3>
          <div className="checkout-items">
            {cartItems.map((item) => (
              <div key={item.product.id} className="checkout-item">
                <img src={item.product.image_url} alt={item.product.name} />
                <div className="checkout-item-info">
                  <span className="checkout-item-name">{item.product.name}</span>
                  <span className="checkout-item-qty">Qty: {item.quantity}</span>
                </div>
                <span className="checkout-item-price">{formatPrice(item.product.price * item.quantity)}</span>
              </div>
            ))}
          </div>
          <div className="checkout-total">
            <span>Total</span>
            <span>{formatPrice(cartTotal)}</span>
          </div>
        </aside>
      </div>
    </div>
  );
}
