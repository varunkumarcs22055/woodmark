/**
 * CartItem — single cart row, discount-aware.
 * Subtotal uses effective_price when present so totals match what the backend
 * will actually charge. MRP is shown struck-through when discounted.
 */

import { Link } from 'react-router-dom';
import { FiMinus, FiPlus, FiX, FiBookmark } from 'react-icons/fi';
import { useCart } from '../context/CartContext';
import { formatPrice } from '../utils/format';
import './CartItem.css';

export default function CartItem({ item }) {
  const { updateQuantity, removeFromCart, saveForLater } = useCart();
  const { product, quantity } = item;

  const mrp = parseFloat(product.price);
  const effective = parseFloat(product.effective_price ?? product.price);
  const hasDiscount = effective < mrp;
  const subtotal = effective * quantity;
  const maxQty = Math.min(product.stock || 99, 10);

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
            <Link to={`/product/${product.slug}`} className="cart-item-name">
              {product.name}
            </Link>
            {product.material && (
              <p className="cart-item-meta">
                {product.material}
                {product.color ? ` · ${product.color}` : ''}
              </p>
            )}
            <div className="cart-item-unit-price">
              <span>{formatPrice(effective)}</span>
              {hasDiscount && (
                <span className="cart-item-unit-mrp">{formatPrice(mrp)}</span>
              )}
            </div>
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
              disabled={quantity >= maxQty}
              aria-label="Increase quantity"
            >
              <FiPlus size={13} />
            </button>
          </div>
          <span className="cart-item-price">{formatPrice(subtotal)}</span>
        </div>

        <button
          type="button"
          className="cart-item-save"
          onClick={() => saveForLater(product.id)}
        >
          <FiBookmark size={13} /> Save for later
        </button>
      </div>
    </div>
  );
}
