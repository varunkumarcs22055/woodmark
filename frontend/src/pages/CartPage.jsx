import { Link } from 'react-router-dom';
import { FiArrowRight, FiChevronLeft, FiShoppingBag, FiTrash2 } from 'react-icons/fi';
import { useCart } from '../context/CartContext';
import { useSettings } from '../context/SettingsContext';
import { formatPrice } from '../utils/format';
import CartItem from '../components/CartItem';
import './CartPage.css';

function SavedForLater() {
  const { savedItems, moveToCart, removeSaved } = useCart();
  if (!savedItems || savedItems.length === 0) return null;
  return (
    <section className="saved-section">
      <h2 className="saved-section-title">
        Saved for later ({savedItems.length})
      </h2>
      <div className="saved-grid">
        {savedItems.map((p) => (
          <div className="saved-card" key={p.id}>
            <Link to={`/product/${p.slug}`} className="saved-card-img">
              <img src={p.image_url} alt={p.name} loading="lazy" />
            </Link>
            <div className="saved-card-body">
              <Link to={`/product/${p.slug}`} className="saved-card-name">{p.name}</Link>
              <span className="saved-card-price">
                {formatPrice(p.effective_price ?? p.price)}
              </span>
              <div className="saved-card-actions">
                <button type="button" className="btn-secondary saved-move" onClick={() => moveToCart(p.id)}>
                  <FiShoppingBag size={13} /> Move to cart
                </button>
                <button type="button" className="saved-remove" onClick={() => removeSaved(p.id)} aria-label="Remove">
                  <FiTrash2 size={14} />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

export default function CartPage() {
  const { cartItems, cartTotal, cartCount, clearCart } = useCart();
  const { settings } = useSettings();
  const { gst_percent, free_shipping_threshold, standard_shipping_fee } = settings;


  const subtotal = cartTotal;
  const originalTotal = cartItems.reduce(
    (sum, item) => sum + parseFloat(item.product.price) * item.quantity,
    0
  );
  const savings = originalTotal - subtotal;
  const gstPercent = parseFloat(gst_percent);
  const gstAmount = Math.round(subtotal * gstPercent) / 100;
  const freeThreshold = parseFloat(free_shipping_threshold);
  const shippingFee = parseFloat(standard_shipping_fee);
  const shipping = subtotal >= freeThreshold ? 0 : shippingFee;
  const finalTotal = subtotal + gstAmount + shipping;

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
        <SavedForLater />
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

            <div className="cart-summary-row">
              <span>GST ({gstPercent}%)</span>
              <span>{formatPrice(gstAmount)}</span>
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
                Add {formatPrice(freeThreshold - subtotal)} more for Free Shipping! 🎁
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

      <SavedForLater />
    </div>
  );
}
