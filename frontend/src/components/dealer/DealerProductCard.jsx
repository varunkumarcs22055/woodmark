/**
 * DealerProductCard — emphasizes dealer-specific pricing.
 * Backend returns `effective_price` based on JWT role; we just render what we get.
 */
import { Link } from 'react-router-dom';
import { FiShoppingCart, FiTag } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { useCart } from '../../context/CartContext';
import { formatPrice, calcDiscountPercent } from '../../utils/format';
import './DealerProductCard.css';

export default function DealerProductCard({ product }) {
  const { addToCart } = useCart();

  const mrp = parseFloat(product.price);
  const yourPrice = parseFloat(product.effective_price ?? product.price);
  const hasDealerDiscount = product.discount_applied === 'dealer';
  const savingsPercent = calcDiscountPercent(mrp, yourPrice);
  const unitsLeft = product.discount_units_remaining;

  const handleAddToCart = (e) => {
    e.preventDefault();
    if (!product.in_stock) return;
    addToCart(product, 1);
    toast.success(`${product.name} added at dealer price.`);
  };

  return (
    <Link to={`/product/${product.slug}`} className="dealer-card">
      {hasDealerDiscount && (
        <span className="dealer-card__badge">
          <FiTag size={12} /> Dealer Price
        </span>
      )}

      <div className="dealer-card__image-wrap">
        <img
          src={product.image_url}
          alt={product.name}
          loading="lazy"
          className="dealer-card__image"
        />
        {!product.in_stock && (
          <div className="dealer-card__out-of-stock">Out of Stock</div>
        )}
      </div>

      <div className="dealer-card__body">
        <span className="dealer-card__category">{product.category_name}</span>
        <h3 className="dealer-card__name">{product.name}</h3>
        <span className="dealer-card__meta">
          {product.material} · {product.color}
        </span>

        <div className="dealer-card__pricing">
          <div className="dealer-card__price-block">
            <span className="dealer-card__your-price-label">Your Price</span>
            <span className="dealer-card__your-price">{formatPrice(yourPrice)}</span>
          </div>
          {hasDealerDiscount && (
            <div className="dealer-card__mrp-block">
              <span className="dealer-card__mrp-label">MRP</span>
              <span className="dealer-card__mrp">{formatPrice(mrp)}</span>
              <span className="dealer-card__savings">Save {savingsPercent}%</span>
            </div>
          )}
        </div>

        {unitsLeft !== null && unitsLeft !== undefined && (
          <div
            className={`dealer-card__units ${
              unitsLeft === 0
                ? 'dealer-card__units--ended'
                : unitsLeft <= 10
                  ? 'dealer-card__units--low'
                  : ''
            }`}
          >
            {unitsLeft === 0
              ? 'Dealer offer ended — showing MRP'
              : `Only ${unitsLeft} units at dealer price`}
          </div>
        )}

        <button
          onClick={handleAddToCart}
          disabled={!product.in_stock}
          className="dealer-card__cta"
        >
          <FiShoppingCart size={16} />
          {product.in_stock ? 'Add to Cart' : 'Out of Stock'}
        </button>
      </div>
    </Link>
  );
}
