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
  FiPackage, FiTruck, FiShield, FiTag, FiTool, FiPlayCircle,
  FiAlertTriangle, FiList, FiStar, FiBell,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchProduct, fetchSimilarProducts,
  fetchProductReviews, fetchReviewSummary, createReview,
  fetchProductEta, subscribeStockAlert,
} from '../api';
import { useAuth } from '../context/AuthContext';
import { useCart } from '../context/CartContext';
import { useSettings } from '../context/SettingsContext';
import useAddToCartGuarded from '../utils/useAddToCartGuarded';
import { formatPrice, calcDiscountPercent } from '../utils/format';
import ProductCard from '../components/ProductCard';
import ProductGallery from '../components/ProductGallery';
import StarRating from '../components/StarRating';
import WishlistButton from '../components/WishlistButton';
import './ProductDetailPage.css';

export default function ProductDetailPage() {
  const { slug } = useParams();
  const { user } = useAuth();
  const { cartItems } = useCart();
  const { settings } = useSettings();
  const addToCart = useAddToCartGuarded();
  const [product, setProduct] = useState(null);
  const [similar, setSimilar] = useState([]);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const [added, setAdded] = useState(false);
  const [reviews, setReviews] = useState([]);
  const [reviewSummary, setReviewSummary] = useState(null);
  // Quantity-aware delivery ETA. Refetched (debounced) when qty/pin changes.
  const [eta, setEta] = useState(null);
  const [etaPincode, setEtaPincode] = useState('');

  useEffect(() => {
    setLoading(true);
    setQuantity(1);
    setAdded(false);
    setReviews([]);
    setReviewSummary(null);
    fetchProduct(slug)
      .then((data) => {
        setProduct(data);
        // Fan out — reviews and similar are independent
        Promise.all([
          fetchSimilarProducts(data.id).catch(() => []),
          fetchProductReviews(data.id).catch(() => ({ results: [] })),
          fetchReviewSummary(data.id).catch(() => null),
        ]).then(([sim, revs, summary]) => {
          setSimilar(sim);
          setReviews(revs.results || revs || []);
          setReviewSummary(summary);
        });
      })
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
  }, [slug]);

  // SEO: title + JSON-LD product schema. Mounted on <head>; cleaned up on
  // unmount or when the slug changes so we don't leak stale tags.
  useEffect(() => {
    if (!product) return undefined;
    const prevTitle = document.title;
    document.title = product.meta_title || `${product.name} | FurniShop`;

    let metaDesc = document.querySelector('meta[name="description"]');
    const prevDesc = metaDesc?.getAttribute('content') || null;
    if (!metaDesc) {
      metaDesc = document.createElement('meta');
      metaDesc.setAttribute('name', 'description');
      document.head.appendChild(metaDesc);
    }
    metaDesc.setAttribute(
      'content',
      product.meta_description ||
        (product.description || '').slice(0, 160) ||
        `Shop ${product.name} on FurniShop.`,
    );

    const ldId = 'pd-jsonld';
    const ld = {
      '@context': 'https://schema.org/',
      '@type': 'Product',
      name: product.name,
      description: product.description,
      sku: product.sku,
      brand: product.brand ? { '@type': 'Brand', name: product.brand } : undefined,
      image: product.primary_image || product.image_url || undefined,
      offers: {
        '@type': 'Offer',
        priceCurrency: 'INR',
        price: parseFloat(product.effective_price ?? product.price).toFixed(2),
        availability: product.in_stock
          ? 'https://schema.org/InStock'
          : 'https://schema.org/OutOfStock',
        url: window.location.href,
      },
      aggregateRating:
        (product.rating_count ?? 0) > 0
          ? {
              '@type': 'AggregateRating',
              ratingValue: product.rating_avg,
              reviewCount: product.rating_count,
            }
          : undefined,
    };

    let script = document.getElementById(ldId);
    if (!script) {
      script = document.createElement('script');
      script.type = 'application/ld+json';
      script.id = ldId;
      document.head.appendChild(script);
    }
    script.textContent = JSON.stringify(ld);

    return () => {
      document.title = prevTitle;
      if (metaDesc && prevDesc !== null) metaDesc.setAttribute('content', prevDesc);
      const stale = document.getElementById(ldId);
      if (stale) stale.remove();
    };
  }, [product]);

  // Refetch ETA when quantity or pincode changes (debounced 350ms).
  // MUST be declared before any early `return` below — React requires hooks
  // to run in the same order every render.
  useEffect(() => {
    if (!product) return undefined;
    const handle = setTimeout(() => {
      fetchProductEta(product.slug, {
        qty: quantity,
        pincode: /^\d{6}$/.test(etaPincode) ? etaPincode : undefined,
      })
        .then(setEta)
        .catch(() => setEta(null));
    }, 350);
    return () => clearTimeout(handle);
  }, [product, quantity, etaPincode]);

  const handleSubmitReview = async (payload) => {
    try {
      await createReview({ product: product.id, ...payload });
      toast.success('Review submitted — pending moderation.');
      // Refresh summary; the new review starts as pending so it won't show
      // in the public list until an admin approves it.
      const fresh = await fetchReviewSummary(product.id).catch(() => null);
      setReviewSummary(fresh);
    } catch (err) {
      const msg = err.response?.data?.detail
        || err.response?.data?.non_field_errors?.[0]
        || 'Failed to submit review.';
      toast.error(msg);
    }
  };

  const handleAddToCart = () => {
    if (!product || !product.in_stock) return;
    const ok = addToCart(product, quantity);
    if (!ok) return;
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

  // baselinePrice is the 1-unit price from the backend (accounts for dealer tier/negotiated).
  const baselinePrice = parseFloat(product.effective_price ?? product.price);

  // Quantity discount tiers come from the detail serializer as `discount_tiers`.
  // Default to an empty array so `.filter` / `.sort` below never blow up if the
  // field is missing (e.g. older API versions, network truncation).
  const tiers = Array.isArray(product.discount_tiers) ? product.discount_tiers : [];

  // We only show a "better" tier if it actually beats the baseline or if quantity > 1.
  const activeTier = quantity > 1
    ? (tiers
        .filter((t) => t.min_quantity <= quantity && !t.is_exhausted)
        .sort((a, b) => b.min_quantity - a.min_quantity)[0])
    : null;

  const effective = activeTier
    ? (activeTier.mode === 'percent'
        ? +(mrp * (1 - parseFloat(activeTier.value) / 100)).toFixed(2)
        : Math.max(0, mrp - parseFloat(activeTier.value)))
    : baselinePrice;

  const hasDiscount = effective < mrp;
  const discountPercent = hasDiscount ? Math.round(((mrp - effective) / mrp) * 100) : 0;
  const unitsLeft = activeTier?.units_remaining ?? product.discount_units_remaining;

  // The next-tier hint: smallest tier whose min_quantity > current quantity.
  const nextTier = tiers
    .filter((t) => t.min_quantity > quantity && !t.is_exhausted)
    .sort((a, b) => a.min_quantity - b.min_quantity)[0];

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

          {(product.rating_count ?? 0) > 0 ? (
            <a href="#reviews-section" className="pd-rating-link">
              <StarRating
                value={product.rating_avg}
                count={product.rating_count}
                size={16}
              />
            </a>
          ) : (
            <span className="pd-rating-link" style={{ color: 'var(--color-text-muted)', fontSize: '0.85rem' }}>
              No reviews yet
            </span>
          )}

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

          {nextTier && (
            <p className="pd-units-note">
              <FiTag size={14} />
              Add {nextTier.min_quantity - quantity} more to unlock{' '}
              <strong>
                {nextTier.value}{nextTier.mode === 'percent' ? '%' : '₹'} off
              </strong>{' '}at {nextTier.min_quantity}+ units
            </p>
          )}

          {tiers.length > 1 && (
            <div className="pd-tier-ladder">
              <span className="pd-tier-ladder__label">
                <FiTag size={14} /> Volume pricing
              </span>
              <ul className="pd-tier-ladder__list">
                {[...tiers]
                  .sort((a, b) => a.min_quantity - b.min_quantity)
                  .map((t) => {
                    const active = activeTier && activeTier.id === t.id;
                    const tierPrice = t.mode === 'percent'
                      ? +(mrp * (1 - parseFloat(t.value) / 100)).toFixed(2)
                      : Math.max(0, mrp - parseFloat(t.value));
                    return (
                      <li
                        key={t.id}
                        className={`pd-tier-rung ${active ? 'pd-tier-rung--active' : ''} ${t.is_exhausted ? 'pd-tier-rung--out' : ''}`}
                      >
                        <span className="pd-tier-rung__qty">
                          {t.min_quantity === 1 ? 'Any qty' : `${t.min_quantity}+ units`}
                        </span>
                        <span className="pd-tier-rung__off">
                          {t.value}{t.mode === 'percent' ? '%' : '₹'} off
                        </span>
                        <span className="pd-tier-rung__price">{formatPrice(tierPrice)}</span>
                      </li>
                    );
                  })}
              </ul>
            </div>
          )}

          {product.discount_applied?.type === 'dealer' && (
            <p className="pd-dealer-note">
              <FiTag size={14} /> You're seeing exclusive dealer pricing
            </p>
          )}

          {product.short_description && (
            <p className="pd-short-desc">{product.short_description}</p>
          )}

          {Array.isArray(product.highlights) && product.highlights.length > 0 && (
            <ul className="pd-highlights">
              {product.highlights.map((h, i) => (
                <li key={i}><FiCheck size={14} /> {h}</li>
              ))}
            </ul>
          )}

          {product.installation_required && (
            <div className="pd-diy-notice">
              <FiAlertTriangle />
              <span>
                <strong>DO IT YOURSELF Product</strong> — ships knocked-down with
                instructions and required tools.
              </span>
            </div>
          )}

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
              <WishlistButton productId={product.id} size={20} />
            </div>
          ) : (
            <div className="pd-actions" style={{ flexDirection: 'column', alignItems: 'stretch' }}>
              <button className="btn-primary pd-add-btn" disabled>
                Out of Stock
              </button>
              <StockAlertSignup slug={product.slug} defaultEmail={user?.email} />
            </div>
          )}

          {/* Quantity-aware delivery ETA */}
          {eta && (
            <div style={{
              display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: 10,
              padding: '10px 14px', background: '#F0FDFA', borderRadius: 10,
              border: '1px solid #99F6E4', marginTop: 12,
            }}>
              <FiTruck color="#0E766E" />
              <span style={{ fontSize: 14 }}>
                <strong>Delivery:</strong> {eta.etd_days_min === eta.etd_days_max
                  ? `${eta.etd_days_max} days`
                  : `${eta.etd_days_min}–${eta.etd_days_max} days`} for {eta.qty} unit{eta.qty > 1 ? 's' : ''}
                {eta.zone?.zone_name && <> to <strong>{eta.zone.zone_name}</strong></>}
                {eta.note && <span style={{ display: 'block', color: '#374151', fontSize: 12 }}>{eta.note}</span>}
              </span>
              <input
                type="text" inputMode="numeric" maxLength={6}
                value={etaPincode}
                onChange={(e) => setEtaPincode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="Check pincode"
                style={{ marginLeft: 'auto', width: 130, padding: '5px 8px',
                         border: '1px solid #D1D5DB', borderRadius: 6, fontSize: 13 }}
              />
            </div>
          )}

          {/* Trust badges (data-driven; falls back to safe defaults) */}
          <div className="pd-trust">
            <div className="trust-item">
              <FiTruck size={18} />
              <span>
                {settings.free_shipping_threshold
                  ? `Free shipping over ${new Intl.NumberFormat('en-IN', {
                      style: 'currency',
                      currency: 'INR',
                      maximumFractionDigits: 0,
                    }).format(settings.free_shipping_threshold)}`
                  : 'Free shipping on all orders'}
              </span>
            </div>
            <div className="trust-item">
              <FiShield size={18} /> <span>{product.warranty_years || 1}-year warranty</span>
            </div>
            <div className="trust-item">
              <FiPackage size={18} /> <span>{product.return_policy_days || 30}-day easy returns</span>
            </div>
          </div>
        </div>
      </div>

      {/* ── Perks strip (Quick Install / Warranty / Delivery) ───────── */}
      {Array.isArray(product.perks) && product.perks.length > 0 && (
        <section className="pd-perks container">
          {product.perks.map((p, i) => (
            <div key={i} className="pd-perk">
              <div className="pd-perk__icon">{p.icon || '★'}</div>
              <strong>{p.title}</strong>
              {p.subtitle && <span>{p.subtitle}</span>}
            </div>
          ))}
        </section>
      )}

      {/* ── Description ─────────────────────────────────────────────── */}
      <section className="pd-section container" id="description">
        <div className="pd-section__head">
          <span className="pd-section__pill">Description</span>
        </div>
        <p className="pd-description">{product.description}</p>
      </section>

      {/* ── YouTube assembly / marketing video ──────────────────────── */}
      {product.youtube_embed_url && (
        <section className="pd-section container" id="video">
          <div className="pd-section__head">
            <FiPlayCircle size={18} />
            <h2>{product.installation_required ? 'How to Assemble' : 'See it in Action'}</h2>
          </div>
          <div className="pd-video">
            <iframe
              src={product.youtube_embed_url}
              title={`${product.name} video`}
              loading="lazy"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          </div>
        </section>
      )}

      {/* ── Feature blocks — alternating image + text rows ──────────── */}
      {Array.isArray(product.feature_blocks) && product.feature_blocks.length > 0 && (
        <section className="pd-features container">
          <div className="pd-section__head pd-section__head--center">
            <span className="pd-divider" />
            <h2>Designed to Respond</h2>
            <span className="pd-divider" />
          </div>
          <div className="pd-features__list">
            {product.feature_blocks
              .slice()
              .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
              .map((b, i) => {
                const align = b.image_alignment || (i % 2 === 0 ? 'right' : 'left');
                return (
                  <div key={i}
                       className={`pd-feature-block pd-feature-block--${align}`}
                       style={b.image_url ? { backgroundImage: `url(${b.image_url})` } : undefined}>
                    <div className="pd-feature-block__copy">
                      {b.title && <h3>{b.title}</h3>}
                      {b.body && <p>{b.body}</p>}
                    </div>
                  </div>
                );
              })}
          </div>
        </section>
      )}

      {/* ── Specifications ──────────────────────────────────────────── */}
      {(product.specifications?.length > 0 || product.dimensions || product.weight_grams) && (
        <section className="pd-section container" id="specifications">
          <div className="pd-section__head">
            <FiList size={18} />
            <h2>Specifications</h2>
          </div>
          <table className="pd-spec-table">
            <tbody>
              {product.specifications?.map((s) => (
                <tr key={s.id}><th>{s.label}</th><td>{s.value}</td></tr>
              ))}
              {product.dimensions && (
                <tr><th>Dimensions</th><td>{product.dimensions}</td></tr>
              )}
              {product.weight_grams ? (
                <tr><th>Weight</th><td>{(product.weight_grams / 1000).toFixed(1)} kg</td></tr>
              ) : null}
              {product.material && (
                <tr><th>Material</th><td style={{ textTransform: 'capitalize' }}>{product.material}</td></tr>
              )}
              {product.color && (
                <tr><th>Colour</th><td>{product.color}</td></tr>
              )}
              {product.brand && (
                <tr><th>Brand</th><td>{product.brand}</td></tr>
              )}
            </tbody>
          </table>
        </section>
      )}

      {/* ── Care instructions (optional) ────────────────────────────── */}
      {product.care_instructions && (
        <section className="pd-section container" id="care">
          <div className="pd-section__head">
            <FiTool size={18} /> <h2>Care Instructions</h2>
          </div>
          <p className="pd-description">{product.care_instructions}</p>
        </section>
      )}

      {/* Reviews */}
      <ReviewsSection
        product={product}
        reviews={reviews}
        summary={reviewSummary}
        canWrite={!!user}
        onSubmit={handleSubmitReview}
      />

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

function ReviewsSection({ product, reviews, summary, canWrite, onSubmit }) {
  const [rating, setRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    if (!rating) return;
    setSubmitting(true);
    try {
      await onSubmit({ rating, title: title.trim(), body: body.trim() });
      setSubmitted(true);
      setTitle('');
      setBody('');
      setRating(0);
    } finally {
      setSubmitting(false);
    }
  };

  const totalCount = summary?.count || 0;
  const avgRaw = summary?.avg ?? product.rating_avg ?? 0;
  const avgParsed = Number.parseFloat(avgRaw);
  const avg = Number.isFinite(avgParsed) ? avgParsed : 0;

  const timeAgo = (dateStr) => {
    const diff = Date.now() - new Date(dateStr).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    const days = Math.floor(hrs / 24);
    if (days < 30) return `${days}d ago`;
    const months = Math.floor(days / 30);
    return `${months}mo ago`;
  };

  return (
    <section className="reviews-section container" id="reviews-section">
      {/* ── Header ─────────────────────────────── */}
      <div className="reviews-header">
        <div className="reviews-header__left">
          <h2 className="reviews-title">Customer Reviews</h2>
          <p className="reviews-subtitle">
            {totalCount > 0
              ? `Based on ${totalCount.toLocaleString()} verified review${totalCount === 1 ? '' : 's'}`
              : 'No reviews yet'}
          </p>
        </div>
      </div>

      <div className="reviews-content">
        {/* ── Summary Card ──────────────────────── */}
        <div className="reviews-summary-card">
          <div className="reviews-big-rating">
            <span className="reviews-big-number">{avg.toFixed(1)}</span>
            <div className="reviews-big-stars">
              <StarRating value={avg} size={20} showValue={false} />
              <span className="reviews-count-label">
                {totalCount} review{totalCount === 1 ? '' : 's'}
              </span>
            </div>
          </div>

          {/* Histogram */}
          <div className="reviews-histogram">
            {[5, 4, 3, 2, 1].map((star) => {
              const c = summary?.by_star?.[String(star)] || 0;
              const pct = totalCount > 0 ? (c / totalCount) * 100 : 0;
              return (
                <div key={star} className="histogram-row">
                  <span className="histogram-label">{star}</span>
                  <span className="histogram-star-icon">★</span>
                  <div className="histogram-track">
                    <div className="histogram-fill" style={{ width: `${pct}%` }} />
                  </div>
                  <span className="histogram-count">{c}</span>
                </div>
              );
            })}
          </div>
        </div>

        {/* ── Write Review Form ────────────────── */}
        <div className="reviews-form-card">
          {canWrite ? (
            submitted ? (
              <div className="review-success">
                <div className="review-success-icon">✓</div>
                <h3>Thank you!</h3>
                <p>Your review has been submitted and is pending moderation.</p>
              </div>
            ) : (
              <form onSubmit={submit} className="review-form">
                <h3 className="review-form__title">Share Your Experience</h3>
                <p className="review-form__subtitle">Help other customers make informed decisions</p>

                {/* Star picker */}
                <div className="review-form__rating">
                  <label>Your Rating</label>
                  <div className="review-stars-picker">
                    {[1, 2, 3, 4, 5].map((s) => (
                      <button
                        key={s}
                        type="button"
                        className={`review-star-btn ${s <= (hoverRating || rating) ? 'active' : ''}`}
                        onMouseEnter={() => setHoverRating(s)}
                        onMouseLeave={() => setHoverRating(0)}
                        onClick={() => setRating(s)}
                        aria-label={`${s} star${s > 1 ? 's' : ''}`}
                      >
                        ★
                      </button>
                    ))}
                    {rating > 0 && (
                      <span className="review-rating-text">
                        {['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][rating]}
                      </span>
                    )}
                  </div>
                </div>

                <div className="review-form__field">
                  <label>Title <span className="optional">(optional)</span></label>
                  <input
                    type="text"
                    placeholder="Summarize your experience"
                    value={title}
                    maxLength={120}
                    onChange={(e) => setTitle(e.target.value)}
                  />
                </div>

                <div className="review-form__field">
                  <label>Your Review <span className="required">*</span></label>
                  <textarea
                    placeholder="What did you like or dislike about this product?"
                    rows={4}
                    value={body}
                    required
                    onChange={(e) => setBody(e.target.value)}
                  />
                </div>

                <button className="review-submit-btn" type="submit"
                  disabled={submitting || !rating || !body.trim()}>
                  {submitting ? (
                    <><span className="spinner-small" /> Submitting…</>
                  ) : (
                    'Submit Review'
                  )}
                </button>
              </form>
            )
          ) : (
            <div className="review-login-prompt">
              <FiShield size={32} />
              <h3>Share Your Thoughts</h3>
              <p>Sign in to write a review and help others choose.</p>
              <Link to="/login" className="btn-primary" style={{ textDecoration: 'none' }}>
                Sign In to Review
              </Link>
            </div>
          )}
        </div>
      </div>

      {/* ── Reviews List ─────────────────────── */}
      {reviews.length === 0 ? (
        <div className="reviews-empty">
          <div className="reviews-empty-icon">💬</div>
          <h3>No reviews yet</h3>
          <p>Be the first to share your experience with this product.</p>
        </div>
      ) : (
        <div className="reviews-list">
          {reviews.map((r) => (
            <div key={r.id} className="review-card">
              <div className="review-card__header">
                <div className="review-avatar">
                  {(r.user_name || 'U').charAt(0).toUpperCase()}
                </div>
                <div className="review-card__meta">
                  <div className="review-card__top-row">
                    <span className="review-card__author">{r.user_name}</span>
                    {r.verified_purchase && (
                      <span className="review-card__verified">
                        <FiCheck size={12} /> Verified
                      </span>
                    )}
                  </div>
                  <div className="review-card__rating-row">
                    <StarRating value={r.rating} showValue={false} size={14} />
                    <span className="review-card__date">{timeAgo(r.created_at)}</span>
                  </div>
                </div>
              </div>
              {r.title && <h4 className="review-card__title">{r.title}</h4>}
              <p className="review-card__body">{r.body}</p>
            </div>
          ))}
        </div>
      )}
    </section>
  );
}

/**
 * StockAlertSignup — "Notify me when in stock" inline form rendered next to
 * the disabled Add-to-Cart button on out-of-stock PDPs. Guests can subscribe
 * by typing their email; signed-in users skip the input and just click.
 */
function StockAlertSignup({ slug, defaultEmail }) {
  const [email, setEmail] = useState(defaultEmail || '');
  const [submitted, setSubmitted] = useState(false);
  const [busy, setBusy] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    if (!email || !/\S+@\S+\.\S+/.test(email)) {
      toast.error('Enter a valid email to get notified.');
      return;
    }
    setBusy(true);
    try {
      await subscribeStockAlert(slug, email);
      setSubmitted(true);
      toast.success("We'll email you the moment this is back in stock.");
    } catch {
      toast.error('Could not subscribe. Try again in a moment.');
    } finally {
      setBusy(false);
    }
  };

  if (submitted) {
    return (
      <div style={{
        marginTop: 8, padding: '10px 14px',
        background: '#F0FDFA', border: '1px solid #99E1D6', borderRadius: 10,
        color: '#134e4a', fontSize: 13.5,
        display: 'flex', alignItems: 'center', gap: 8,
      }}>
        <FiCheck /> You're on the list — we'll email <strong>{email}</strong>.
      </div>
    );
  }

  return (
    <form onSubmit={submit} style={{
      marginTop: 8, display: 'flex', flexWrap: 'wrap', gap: 8,
      padding: '12px 14px', background: '#FFFBEB',
      border: '1px solid #FDE68A', borderRadius: 10,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, flex: '1 1 240px',
                    minWidth: 0, fontSize: 13.5, color: '#78350F' }}>
        <FiBell />
        <span style={{ fontWeight: 600 }}>Get a notification when it's back</span>
      </div>
      <input
        type="email" value={email} onChange={(e) => setEmail(e.target.value)}
        placeholder="your@email.com" required
        style={{ flex: '1 1 200px', padding: '8px 12px', borderRadius: 8,
                 border: '1px solid #FDE68A', fontSize: 14, minWidth: 0 }}
      />
      <button type="submit" disabled={busy}
              style={{ padding: '8px 16px', background: '#F97316', color: '#fff',
                       border: 0, borderRadius: 8, fontWeight: 700, fontSize: 13,
                       cursor: busy ? 'progress' : 'pointer' }}>
        {busy ? 'Subscribing…' : 'Notify me'}
      </button>
    </form>
  );
}

