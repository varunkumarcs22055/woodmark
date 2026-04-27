/**
 * CartItem — Livspace-style cart item row.
 */

import { useCart } from '../context/CartContext';
import { FiMinus, FiPlus, FiX } from 'react-icons/fi';
import { Link } from 'react-router-dom';
import './CartItem.css';

export default function CartItem({ item }) {
  const { updateQuantity, removeFromCart } = useCart();
  const { product, quantity } = item;

  const formatPrice = (price) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(price);

  const subtotal = parseFloat(product.price) * quantity;

  return (
    <div className="cart-item fade-in" id={`cart-item-${product.id}`}>
      {/* Image */}
      <Link to={`/product/${product.slug}`} className="cart-item-image">
        <img src={product.image_url} alt={product.name} />
      </Link>

      {/* Details */}
      <div className="cart-item-body">
        <div className="cart-item-header">
          <div style={{ flex: 1, minWidth: 0 }}>
            <p className="cart-item-category">{product.category_name}</p>
            <Link to={`/product/${product.slug}`} className="cart-item-name">{product.name}</Link>
            {product.material && (
              <p className="cart-item-meta">{product.material}{product.color ? ` · ${product.color}` : ''}</p>
            )}
          </div>
          <button
            className="cart-item-remove"
            onClick={() => removeFromCart(product.id)}
            aria-label={`Remove ${product.name}`}
          >
            <FiX size={15} />
          </button>
        </div>

        <div className="cart-item-footer">
          <div className="cart-item-quantity">
            <button
              onClick={() => updateQuantity(product.id, quantity - 1)}
              disabled={quantity <= 1}
              aria-label="Decrease quantity"
            >
              <FiMinus size={13} />
            </button>
            <span>{quantity}</span>
            <button
              onClick={() => updateQuantity(product.id, quantity + 1)}
              aria-label="Increase quantity"
            >
              <FiPlus size={13} />
            </button>
          </div>
          <span className="cart-item-price">{formatPrice(subtotal)}</span>
        </div>
      </div>
    </div>
  );
}
