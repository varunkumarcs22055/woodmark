/**
 * ProductCard — Livspace-style product display card.
 *
 * Renders backend-provided pricing fields:
 *   product.price             — MRP
 *   product.effective_price   — discounted price for the current viewer
 *                               (set when product.discount_applied is truthy)
 *   product.discount_applied  — 'user' | 'dealer' | null
 *   product.discount_units_remaining — count_limit - units_sold (or null)
 */

import { Link } from 'react-router-dom';
import { useState } from 'react';
import { FiShoppingBag, FiCheck, FiHeart } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { useCart } from '../context/CartContext';
import { formatPrice, calcDiscountPercent } from '../utils/format';
import './ProductCard.css';

export default function ProductCard({ product }) {
  const { addToCart, cartItems } = useCart();
  const [added, setAdded] = useState(false);
  const [wishListed, setWishListed] = useState(false);

  const isInCart = cartItems.some((item) => item.product.id === product.id);

  const mrp = parseFloat(product.price);
  const effective = parseFloat(product.effective_price ?? product.price);
  const hasDiscount = effective < mrp;
  const discountPercent = hasDiscount ? calcDiscountPercent(mrp, effective) : 0;
  const unitsLeft = product.discount_units_remaining;

  const handleAddToCart = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (!product.in_stock) return;
    addToCart(product, 1);
    setAdded(true);
    toast.success(`${product.name} added to cart!`);
    setTimeout(() => setAdded(false), 1800);
  };

  const handleWishlist = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setWishListed((w) => !w);
  };

  return (
    <Link
      to={`/product/${product.slug}`}
      className="product-card fade-up"
      id={`product-card-${product.id}`}
    >
      {/* Image */}
      <div className="product-card-image">
        <img
          src={product.image_url}
          alt={product.name}
          loading="lazy"
          className="product-card-img"
        />

        {/* Hover overlay — Add to Cart */}
        <div className="product-card-overlay">
          {product.in_stock && (
            <button
              className={`pc-add-btn ${added || isInCart ? 'added' : ''}`}
              onClick={handleAddToCart}
              id={`add-to-cart-${product.id}`}
              aria-label={`Add ${product.name} to cart`}
            >
              {added || isInCart ? (
                <>
                  <FiCheck size={15} /> {added ? 'Added!' : 'In Cart'}
                </>
              ) : (
                <>
                  <FiShoppingBag size={15} /> Add to Cart
                </>
              )}
            </button>
          )}
        </div>

        {/* Top-left badges */}
        <div className="product-card-badges">
          {!product.in_stock && (
            <span className="pc-badge pc-badge-oos">Out of Stock</span>
          )}
          {product.in_stock && discountPercent > 0 && (
            <span className="pc-badge pc-badge-discount">{discountPercent}% OFF</span>
          )}
          {product.discount_applied === 'dealer' && (
            <span className="pc-badge pc-badge-dealer">Dealer Price</span>
          )}
        </div>

        {/* Wishlist */}
        <button
          className={`pc-wishlist-btn ${wishListed ? 'wishlisted' : ''}`}
          onClick={handleWishlist}
          aria-label="Add to wishlist"
        >
          <FiHeart size={16} />
        </button>
      </div>

      {/* Body */}
      <div className="product-card-body">
        <span className="product-card-category">{product.category_name}</span>
        <h3 className="product-card-name">{product.name}</h3>
        <div className="product-card-meta">
          {product.material && (
            <span className="product-card-material">{product.material}</span>
          )}
          {product.color && (
            <span className="product-card-material">· {product.color}</span>
          )}
        </div>

        <div className="product-card-pricing">
          <span className="product-card-price">{formatPrice(effective)}</span>
          {hasDiscount && (
            <span className="product-card-original">{formatPrice(mrp)}</span>
          )}
        </div>

        {/* Discount-units badge — only when backend reports a count limit */}
        {unitsLeft !== null && unitsLeft !== undefined && (
          <p
            className={`product-card-units ${
              unitsLeft === 0
                ? 'product-card-units--ended'
                : unitsLeft <= 10
                  ? 'product-card-units--low'
                  : ''
            }`}
          >
            {unitsLeft === 0
              ? 'Offer ended'
              : `Only ${unitsLeft} left at this price`}
          </p>
        )}

        {/* Static rating row — replaced when reviews ship */}
        <div className="product-card-rating">
          {'★★★★☆'.split('').map((s, i) => (
            <span key={i} className={`star ${i < 4 ? 'filled' : ''}`}>
              {s}
            </span>
          ))}
          <span className="rating-count">(128)</span>
        </div>
      </div>
    </Link>
  );
}
