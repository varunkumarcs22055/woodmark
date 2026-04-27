/**
 * ProductDetailPage — Shows full product details and similar products.
 */
import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { fetchProduct, fetchSimilarProducts } from '../api';
import { useCart } from '../context/CartContext';
import ProductCard from '../components/ProductCard';
import { FiShoppingCart, FiCheck, FiChevronRight, FiPackage, FiTruck, FiShield } from 'react-icons/fi';
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
        return fetchSimilarProducts(data.id);
      })
      .then((simData) => setSimilar(simData))
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
  }, [slug]);

  const handleAddToCart = () => {
    if (product) {
      addToCart({
        id: product.id, name: product.name, slug: product.slug,
        price: product.price, image_url: product.image_url,
        category_name: product.category?.name, material: product.material,
        color: product.color, in_stock: product.in_stock,
      }, quantity);
      setAdded(true);
      setTimeout(() => setAdded(false), 2000);
    }
  };

  const formatPrice = (price) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(price);

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
          <Link to="/" className="btn-primary">Back to Shop</Link>
        </div>
      </div>
    );
  }

  const isInCart = cartItems.some(item => item.product.id === product.id);

  return (
    <div className="product-detail-page">
      {/* Breadcrumb */}
      <div className="breadcrumb container">
        <Link to="/">Shop</Link>
        <FiChevronRight size={14} />
        <span>{product.category?.name}</span>
        <FiChevronRight size={14} />
        <span className="current">{product.name}</span>
      </div>

      <div className="pd-layout container">
        {/* Product Image */}
        <div className="pd-image-wrapper" id="product-image">
          <img src={product.image_url} alt={product.name} className="pd-image" />
        </div>

        {/* Product Info */}
        <div className="pd-info">
          <span className="pd-category">{product.category?.name}</span>
          <h1 className="pd-name">{product.name}</h1>
          <div className="pd-rating">
            <div className="pd-stars">
              {'★★★★☆'.split('').map((s, i) => (
                <span key={i} className="pd-star">{s}</span>
              ))}
            </div>
            <span className="pd-rating-text">4.0 (248 reviews)</span>
          </div>
          <div className="pd-pricing">
            <span className="pd-price">{formatPrice(product.price)}</span>
            <span className="pd-original-price">{formatPrice(Math.round(product.price * 1.2))}</span>
            <span className="pd-discount-badge">20% OFF</span>
          </div>

          <p className="pd-description">{product.description}</p>

          {/* Specs */}
          <div className="pd-specs">
            <div className="pd-spec">
              <span className="spec-label">Material</span>
              <span className="spec-value">{product.material}</span>
            </div>
            <div className="pd-spec">
              <span className="spec-label">Color</span>
              <span className="spec-value">{product.color}</span>
            </div>
            <div className="pd-spec">
              <span className="spec-label">Dimensions</span>
              <span className="spec-value">{product.dimensions}</span>
            </div>
            <div className="pd-spec">
              <span className="spec-label">Availability</span>
              <span className={`spec-value ${product.in_stock ? 'in-stock' : 'out-stock'}`}>
                {product.in_stock ? `In Stock (${product.stock})` : 'Out of Stock'}
              </span>
            </div>
          </div>

          {/* Add to Cart */}
          {product.in_stock && (
            <div className="pd-actions">
              <div className="pd-quantity">
                <button onClick={() => setQuantity(Math.max(1, quantity - 1))}>−</button>
                <span>{quantity}</span>
                <button onClick={() => setQuantity(Math.min(product.stock, quantity + 1))}>+</button>
              </div>
              <button
                className={`btn-primary pd-add-btn ${added ? 'added' : ''}`}
                onClick={handleAddToCart}
                id="add-to-cart-btn"
              >
                {added ? <><FiCheck /> Added to Cart!</> : isInCart ? <><FiShoppingCart /> Update Cart</> : <><FiShoppingCart /> Add to Cart</>}
              </button>
            </div>
          )}

          {/* Trust badges */}
          <div className="pd-trust">
            <div className="trust-item"><FiTruck size={18} /> <span>Free shipping over ₹5,000</span></div>
            <div className="trust-item"><FiShield size={18} /> <span>2-year warranty</span></div>
            <div className="trust-item"><FiPackage size={18} /> <span>Easy returns</span></div>
          </div>
        </div>
      </div>

      {/* Similar Products */}
      {similar.length > 0 && (
        <section className="similar-section container">
          <h2>Similar Products</h2>
          <div className="similar-grid">
            {similar.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
