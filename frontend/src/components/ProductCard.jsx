/**
 * ProductCard — Livspace-style product display card.
 */

import { Link } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import { FiShoppingBag, FiCheck, FiHeart } from 'react-icons/fi';
import { useState } from 'react';
import './ProductCard.css';

export default function ProductCard({ product }) {
  const { addToCart, cartItems } = useCart();
  const [added, setAdded] = useState(false);
  const [wishListed, setWishListed] = useState(false);

  const isInCart = cartItems.some(item => item.product.id === product.id);

  const handleAddToCart = (e) => {
    e.preventDefault();
    e.stopPropagation();
    addToCart(product, 1);
    setAdded(true);
    setTimeout(() => setAdded(false), 1800);
  };

  const handleWishlist = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setWishListed(w => !w);
  };

  const formatPrice = (price) =>
    new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(price);

  // Simulate a "original price" for display (20% higher)
  const originalPrice = Math.round(product.price * 1.2);
  const discount = Math.round(((originalPrice - product.price) / originalPrice) * 100);

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

        {/* Overlay actions */}
        <div className="product-card-overlay">
          {product.in_stock && (
            <button
              className={`pc-add-btn ${added || isInCart ? 'added' : ''}`}
              onClick={handleAddToCart}
              id={`add-to-cart-${product.id}`}
              aria-label={`Add ${product.name} to cart`}
            >
              {added || isInCart ? (
                <><FiCheck size={15} /> {added ? 'Added!' : 'In Cart'}</>
              ) : (
                <><FiShoppingBag size={15} /> Add to Cart</>
              )}
            </button>
          )}
        </div>

        {/* Badges */}
        <div className="product-card-badges">
          {!product.in_stock && (
            <span className="pc-badge pc-badge-oos">Out of Stock</span>
          )}
          {product.in_stock && discount > 0 && (
            <span className="pc-badge pc-badge-discount">{discount}% OFF</span>
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
        </div>
        <div className="product-card-pricing">
          <span className="product-card-price">{formatPrice(product.price)}</span>
          {product.in_stock && (
            <span className="product-card-original">{formatPrice(originalPrice)}</span>
          )}
        </div>

        {/* Rating stars - static for UI */}
        <div className="product-card-rating">
          {'★★★★☆'.split('').map((s, i) => (
            <span key={i} className={`star ${i < 4 ? 'filled' : ''}`}>{s}</span>
          ))}
          <span className="rating-count">(128)</span>
        </div>
      </div>
    </Link>
  );
}
