/**
 * ProductDetailPage — full product view with role-aware pricing.
 *
 * Reads the same backend pricing fields as ProductCard:
 *   product.effective_price, product.discount_applied,
 *   product.discount_units_remaining
 *
 * Backend may return category as nested object OR flat `category_name` —
 * we handle both shapes.
 */
import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import {
  FiShoppingCart, FiCheck, FiChevronRight,
  FiPackage, FiTruck, FiShield, FiTag,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchProduct, fetchSimilarProducts } from '../api';
import { useCart } from '../context/CartContext';
import { formatPrice, calcDiscountPercent } from '../utils/format';
import ProductCard from '../components/ProductCard';
import ProductGallery from '../components/ProductGallery';
import './ProductDetailPage.css';

export default function ProductDetailPage() {
  const { slug } = useParams();
  const { addToCart, cartItems } = useCart();
  const [product, setProduct] = useState(null);
  const [similar, setSimilar] = useState([]);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const [added, setAdded] = useState(false);

  useEffect(() => {
    setLoading(true);
    setQuantity(1);
    setAdded(false);
    fetchProduct(slug)
      .then((data) => {
        setProduct(data);
        return fetchSimilarProducts(data.id).catch(() => []);
      })
      .then((simData) => setSimilar(simData))
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
  }, [slug]);

  const handleAddToCart = () => {
    if (!product || !product.in_stock) return;
    addToCart(product, quantity);
    setAdded(true);
    toast.success(`${quantity}× ${product.name} added to cart!`);
    setTimeout(() => setAdded(false), 2000);
  };

  if (loading) {
    return (
      <div className="product-detail-page container">
        <div className="pd-layout">
          <div className="skeleton" style={{ aspectRatio: '4/3', borderRadius: 16 }} />
          <div style={{ flex: 1 }}>
            <div className="skeleton" style={{ height: 20, width: '30%', marginBottom: 12 }} />
            <div className="skeleton" style={{ height: 36, width: '70%', marginBottom: 16 }} />
            <div className="skeleton" style={{ height: 32, width: '25%', marginBottom: 24 }} />
            <div className="skeleton" style={{ height: 100, width: '100%' }} />
          </div>
        </div>
      </div>
    );
  }

  if (!product) {
    return (
      <div className="product-detail-page container">
        <div className="empty-state">
          <h3>Product not found</h3>
          <p>The product you're looking for doesn't exist or has been removed.</p>
          <Link to="/" className="btn-primary">Back to Shop</Link>
        </div>
      </div>
    );
  }

  const isInCart = cartItems.some((item) => item.product.id === product.id);
  const categoryName = product.category_name || product.category?.name || '';

  // Real pricing — read directly from backend response
  const mrp = parseFloat(product.price);
  const effective = parseFloat(product.effective_price ?? product.price);
  const hasDiscount = effective < mrp;
  const discountPercent = hasDiscount ? calcDiscountPercent(mrp, effective) : 0;
  const unitsLeft = product.discount_units_remaining;

  // Stock status
  const stockBucket =
    product.stock === 0 ? 'oos' : product.stock <= 5 ? 'low' : 'ok';
  const stockMessage =
    stockBucket === 'oos' ? 'Out of Stock'
      : stockBucket === 'low' ? `Only ${product.stock} left in stock!`
      : `In Stock (${product.stock} available)`;

  const maxQty = Math.min(product.stock || 1, 10);
  const decrementQty = () => setQuantity((q) => Math.max(1, q - 1));
  const incrementQty = () => setQuantity((q) => Math.min(maxQty, q + 1));

  return (
    <div className="product-detail-page">
      {/* Breadcrumb */}
      <div className="breadcrumb container">
        <Link to="/">Shop</Link>
        <FiChevronRight size={14} />
        {categoryName && (
          <>
            <Link to={`/?category=${encodeURIComponent(categoryName.toLowerCase().replace(/\s+/g, '-'))}`}>
              {categoryName}
            </Link>
            <FiChevronRight size={14} />
          </>
        )}
        <span className="current">{product.name}</span>
      </div>

      <div className="pd-layout container">
        {/* Product Gallery */}
        <div className="pd-image-wrapper" id="product-image">
          <ProductGallery
            media={product.media || []}
            fallbackUrl={product.primary_image || product.image_url}
          />
          {discountPercent > 0 && (
            <span className="pd-image-badge">{discountPercent}% OFF</span>
          )}
        </div>

        {/* Product Info */}
        <div className="pd-info">
          {categoryName && <span className="pd-category">{categoryName}</span>}
          <h1 className="pd-name">{product.name}</h1>

          <div className="pd-rating">
            <div className="pd-stars">
              {'★★★★☆'.split('').map((s, i) => (
                <span key={i} className="pd-star">{s}</span>
              ))}
            </div>
            <span className="pd-rating-text">4.0 (248 reviews)</span>
          </div>

          {/* Pricing */}
          <div className="pd-pricing">
            <span className="pd-price">{formatPrice(effective)}</span>
            {hasDiscount && (
              <>
                <span className="pd-original-price">{formatPrice(mrp)}</span>
                <span className="pd-discount-badge">{discountPercent}% OFF</span>
              </>
            )}
          </div>

          {/* Discount-units note */}
          {unitsLeft !== null && unitsLeft !== undefined && (
            <p className={`pd-units-note ${unitsLeft === 0 ? 'pd-units-note--ended' : ''}`}>
              <FiTag size={14} />
              {unitsLeft === 0
                ? 'Offer has ended — showing regular price'
                : `Only ${unitsLeft} units left at this discounted price`}
            </p>
          )}

          {product.discount_applied === 'dealer' && (
            <p className="pd-dealer-note">
              <FiTag size={14} /> You're seeing exclusive dealer pricing
            </p>
          )}

          <p className="pd-description">{product.description}</p>

          {/* Specs */}
          <div className="pd-specs">
            <div className="pd-spec">
              <span className="spec-label">Material</span>
              <span className="spec-value">{product.material || '—'}</span>
            </div>
            <div className="pd-spec">
              <span className="spec-label">Color</span>
              <span className="spec-value">{product.color || '—'}</span>
            </div>
            <div className="pd-spec">
              <span className="spec-label">Dimensions</span>
              <span className="spec-value">{product.dimensions || '—'}</span>
            </div>
            <div className="pd-spec">
              <span className="spec-label">Availability</span>
              <span
                className={`spec-value ${
                  stockBucket === 'oos' ? 'out-stock'
                    : stockBucket === 'low' ? 'low-stock' : 'in-stock'
                }`}
              >
                {stockMessage}
              </span>
            </div>
          </div>

          {/* Add to Cart */}
          {product.in_stock ? (
            <div className="pd-actions">
              <div className="pd-quantity">
                <button onClick={decrementQty} disabled={quantity <= 1} aria-label="Decrease quantity">−</button>
                <span>{quantity}</span>
                <button onClick={incrementQty} disabled={quantity >= maxQty} aria-label="Increase quantity">+</button>
              </div>
              <button
                className={`btn-primary pd-add-btn ${added ? 'added' : ''}`}
                onClick={handleAddToCart}
                id="add-to-cart-btn"
              >
                {added ? (
                  <><FiCheck /> Added to Cart!</>
                ) : isInCart ? (
                  <><FiShoppingCart /> Add Again</>
                ) : (
                  <><FiShoppingCart /> Add to Cart</>
                )}
              </button>
            </div>
          ) : (
            <div className="pd-actions">
              <button className="btn-primary pd-add-btn" disabled>
                Out of Stock
              </button>
            </div>
          )}

          {/* Trust badges */}
          <div className="pd-trust">
            <div className="trust-item">
              <FiTruck size={18} /> <span>Free shipping over ₹2,999</span>
            </div>
            <div className="trust-item">
              <FiShield size={18} /> <span>1-year warranty</span>
            </div>
            <div className="trust-item">
              <FiPackage size={18} /> <span>30-day easy returns</span>
            </div>
          </div>
        </div>
      </div>

      {/* Similar Products */}
      {similar.length > 0 && (
        <section className="similar-section container">
          <h2>You May Also Like</h2>
          <div className="similar-grid">
            {similar.slice(0, 4).map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
