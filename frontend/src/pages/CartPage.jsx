/**
 * CartPage — discount-aware shopping cart.
 *
 * Pricing rules:
 *   subtotal      = sum of effective_price × qty   (this is `cartTotal` from CartContext)
 *   originalTotal = sum of price × qty             (computed locally)
 *   savings       = originalTotal - subtotal       (only shown when > 0)
 *   shipping      = FREE if subtotal >= ₹2,999 else ₹499
 */
import { Link } from 'react-router-dom';
import { FiArrowRight, FiChevronLeft } from 'react-icons/fi';
import { useCart } from '../context/CartContext';
import { formatPrice } from '../utils/format';
import CartItem from '../components/CartItem';
import './CartPage.css';

export default function CartPage() {
  const { cartItems, cartTotal, cartCount, clearCart } = useCart();

  const subtotal = cartTotal; // already discount-aware
  const originalTotal = cartItems.reduce(
    (sum, item) => sum + parseFloat(item.product.price) * item.quantity,
    0
  );
  const savings = originalTotal - subtotal;
  const shipping = subtotal >= 2999 ? 0 : 499;
  const finalTotal = subtotal + shipping;

  if (cartItems.length === 0) {
    return (
      <div className="cart-page container">
        <div className="cart-empty fade-up">
          <div className="cart-empty-icon">🛍️</div>
          <h3>Your cart is empty</h3>
          <p>Looks like you haven't added anything yet. Start shopping!</p>
          <Link to="/" className="btn-primary">
            Browse Products <FiArrowRight />
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="cart-page container">
      <div className="cart-page-title-row">
        <h1 className="cart-page-title">Shopping Cart</h1>
        <Link to="/" className="cart-back-link">
          <FiChevronLeft size={16} /> Continue Shopping
        </Link>
      </div>

      <div className="cart-layout">
        {/* Cart Items Panel */}
        <div className="cart-items-panel">
          <div className="cart-items-header">
            <span className="cart-items-count">
              {cartCount} Item{cartCount !== 1 ? 's' : ''}
            </span>
            <button className="cart-clear-btn" onClick={clearCart}>
              Remove All
            </button>
          </div>
          {cartItems.map((item) => (
            <CartItem key={item.product.id} item={item} />
          ))}
        </div>

        {/* Order Summary Panel */}
        <aside className="cart-summary-panel">
          <h3 className="cart-summary-title">Order Summary</h3>
          <div className="cart-summary-rows">
            <div className="cart-summary-row">
              <span>Subtotal ({cartCount} items)</span>
              <span style={{ fontWeight: 700, color: 'var(--color-text)' }}>
                {formatPrice(originalTotal)}
              </span>
            </div>

            {savings > 0 && (
              <div className="cart-summary-row discount">
                <span>You Save</span>
                <span>−{formatPrice(savings)}</span>
              </div>
            )}

            <div className="cart-summary-row">
              <span>Shipping</span>
              <span
                style={{
                  color:
                    shipping === 0 ? 'var(--color-success)' : 'var(--color-text)',
                  fontWeight: 600,
                }}
              >
                {shipping === 0 ? 'FREE' : formatPrice(shipping)}
              </span>
            </div>

            {shipping > 0 && (
              <p
                style={{
                  fontSize: 'var(--text-xs)',
                  color: 'var(--color-brand)',
                  fontWeight: 600,
                  background: 'var(--color-brand-pale)',
                  padding: '8px 12px',
                  borderRadius: 'var(--radius-sm)',
                }}
              >
                Add {formatPrice(2999 - subtotal)} more for Free Shipping! 🎁
              </p>
            )}
          </div>

          <div className="cart-summary-total">
            <span>Total</span>
            <span>{formatPrice(finalTotal)}</span>
          </div>

          <Link
            to="/checkout"
            className="btn-primary cart-checkout-btn"
            id="checkout-btn"
          >
            Proceed to Checkout <FiArrowRight size={16} />
          </Link>
          <Link to="/" className="cart-continue-link">
            ← Continue Shopping
          </Link>
        </aside>
      </div>
    </div>
  );
}
