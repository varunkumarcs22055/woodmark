# Frontend Prompt 2 — Homepage (Hero, Categories, Product Grid, Filters)

## Role
You are a senior frontend engineer. Build the FurniShop homepage — the most visited page. It must be visually stunning (Featherlite/Livspace quality), performant, and fully functional. Every interactive element must work.

**Use Claude Artifacts for design mockups. Use Claude Opus for implementation.**

---

## Context
The homepage is the storefront. It features a hero carousel, trust strip, category chips, featured collections, a promotional banner, and the main product grid with sidebar filters. The filter state lives in the URL (`?category=sofas&price_min=5000`) so filtered pages are shareable.

**Depends on:** Frontend Prompt 1 (design system, API layer, CartContext)
**Backend endpoints used:**
- `GET /api/products/` — paginated, filterable product list
- `GET /api/products/categories/` — category list for filter sidebar

---

## Files to Create

```
frontend/src/pages/
├── HomePage.jsx
└── HomePage.css

frontend/src/components/
├── ProductCard.jsx
├── ProductCard.css
└── FilterSidebar.jsx
└── FilterSidebar.css
```

---

## Design Specification

### Visual Design Requirements (Generate with Claude Design)
Design a Featherlite/Livspace-quality homepage. Reference these design principles:
- **Hero:** Full-width carousel, 70vh height, lifestyle furniture photography, gradient overlay, large serif headline + CTA button
- **Color scheme:** Warm off-white (#FAFAF7) background, teal primary (#00736A), warm gold accents (#C8A97E)
- **Typography:** Serif headings (Georgia), sans-serif body (Inter)
- **Category chips:** Pill-shaped chips with emoji icons and soft colored backgrounds
- **Product cards:** Clean white cards, product photo top (square aspect ratio), product name, category badge, price + effective price, "Add to Cart" button on hover

### Hero Carousel
- 4 slides minimum
- `Swiper` with `Autoplay` (4s), `EffectFade`, `Pagination` (dot indicators)
- Each slide: background image, dark gradient overlay, headline, subheadline, CTA button
- Lazy loading for slide images

```javascript
const HERO_SLIDES = [
  {
    heading: 'Transform Your Space',
    subheading: 'Premium furniture crafted for the modern Indian home',
    cta: 'Shop Now',
    ctaLink: '/',
    image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1600&q=80',
    bg: '#1A1A1A',
  },
  {
    heading: 'Bedroom Essentials',
    subheading: 'Where comfort meets timeless design',
    cta: 'Shop Beds',
    ctaLink: '/?category=beds',
    image: 'https://images.unsplash.com/photo-1505693314120-0d443867891c?w=1600&q=80',
    bg: '#2C3E50',
  },
  {
    heading: 'Work From Home, In Style',
    subheading: 'Desks and chairs built for focus and comfort',
    cta: 'Shop Desks',
    ctaLink: '/?category=desks',
    image: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=1600&q=80',
    bg: '#3D2B1F',
  },
  {
    heading: 'Outdoor Living',
    subheading: 'Bring the indoors out with weather-resistant elegance',
    cta: 'Shop Outdoor',
    ctaLink: '/?category=outdoor',
    image: 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=1600&q=80',
    bg: '#1A3A2A',
  },
];
```

---

## HomePage Component — `src/pages/HomePage.jsx`

### State
```javascript
const [searchParams, setSearchParams] = useSearchParams();
const navigate = useNavigate();

// Filters synced to URL
const [filters, setFilters] = useState({
  category: searchParams.get('category') || '',
  price_min: searchParams.get('price_min') || '',
  price_max: searchParams.get('price_max') || '',
  material: searchParams.get('material') || '',
  search: searchParams.get('search') || '',
  ordering: searchParams.get('ordering') || '-created_at',
  page: parseInt(searchParams.get('page') || '1', 10),
});

const [products, setProducts] = useState([]);
const [totalCount, setTotalCount] = useState(0);
const [loading, setLoading] = useState(false);
const [showFilters, setShowFilters] = useState(false); // Mobile filter toggle
const [categories, setCategories] = useState([]);
```

### URL Sync
```javascript
// Sync filter state → URL when filters change
useEffect(() => {
  const params = {};
  Object.entries(filters).forEach(([key, value]) => {
    if (value !== '' && value !== null && value !== 1) {
      params[key] = value;
    }
  });
  setSearchParams(params, { replace: true });
}, [filters]);

// Load products when filters change
useEffect(() => {
  loadProducts();
}, [filters]);
```

### Product Loading
```javascript
const loadProducts = useCallback(async () => {
  setLoading(true);
  try {
    const params = {};
    if (filters.category) params.category = filters.category;
    if (filters.price_min) params.price_min = filters.price_min;
    if (filters.price_max) params.price_max = filters.price_max;
    if (filters.material) params.material = filters.material;
    if (filters.search) params.search = filters.search;
    if (filters.ordering) params.ordering = filters.ordering;
    params.page = filters.page;

    const data = await fetchProducts(params);
    setProducts(data.results);
    setTotalCount(data.count);
  } catch (err) {
    toast.error('Failed to load products. Please try again.');
  } finally {
    setLoading(false);
  }
}, [filters]);
```

### Category Chips
The `value` field MUST exactly match the DB category slug:
```javascript
const CATEGORIES = [
  { label: 'Sofas', value: 'sofas', emoji: '🛋️', color: '#F0FFF4', border: '#B3F0C8' },
  { label: 'Tables', value: 'tables', emoji: '🪵', color: '#FFF5F0', border: '#FFCCB3' },
  { label: 'Chairs', value: 'chairs', emoji: '🪑', color: '#F5F0FF', border: '#D4B3FF' },
  { label: 'Beds', value: 'beds', emoji: '🛏️', color: '#FFF8F0', border: '#FFD9B3' },
  { label: 'Storage', value: 'storage', emoji: '📦', color: '#F0F8FF', border: '#B3DAFF' },
  { label: 'Desks', value: 'desks', emoji: '💻', color: '#FFFAF0', border: '#FFE9B3' },
  { label: 'Dining Sets', value: 'dining-sets', emoji: '🍽️', color: '#FFF0F5', border: '#FFB3CC' },
  { label: 'Outdoor', value: 'outdoor', emoji: '🌿', color: '#F0FAFF', border: '#B3E4FF' },
];
```

### Featured Collections
3 card banners linking to filtered product views:
```javascript
const FEATURED_COLLECTIONS = [
  {
    title: 'Bedroom Essentials',
    subtitle: 'Comfort meets timeless design',
    cta: 'Shop Beds',
    category: 'beds',
    image: 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=600',
    accent: '#00736A',
  },
  {
    title: 'Living Room',
    subtitle: 'Make it yours',
    cta: 'Shop Sofas',
    category: 'sofas',
    image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600',
    accent: '#8B5E3C',
  },
  {
    title: 'Work From Home',
    subtitle: 'Designed for focus',
    cta: 'Shop Desks',
    category: 'desks',
    image: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600',
    accent: '#2C3E50',
  },
];
```

### Pagination
```javascript
const totalPages = Math.ceil(totalCount / 12);

const handlePageChange = (page) => {
  setFilters((prev) => ({ ...prev, page }));
  window.scrollTo({ top: 0, behavior: 'smooth' });
};
```

### Homepage Layout Structure
```
<div className="homepage">
  {/* 1. Hero Carousel */}
  <section className="hero-section">...</section>

  {/* 2. Why Us Strip */}
  <section className="why-us-strip">...</section>

  {/* 3. Category Chips */}
  <section className="category-chips-section">...</section>

  {/* 4. Featured Collections */}
  <section className="featured-collections">...</section>

  {/* 5. Promo Banner */}
  <section className="promo-banner">...</section>

  {/* 6. Products Section (filter sidebar + grid) */}
  <section className="products-section">
    <div className="products-layout">
      <aside className="filter-sidebar-wrapper">
        <FilterSidebar filters={filters} onChange={setFilters} categories={categories} />
      </aside>
      <div className="products-main">
        <div className="products-toolbar">
          {/* Filter toggle (mobile), Sort dropdown, Result count */}
        </div>
        {loading ? <ProductGridSkeleton /> : (
          <div className="products-grid">
            {products.map((p) => <ProductCard key={p.id} product={p} />)}
          </div>
        )}
        <Pagination current={filters.page} total={totalPages} onChange={handlePageChange} />
      </div>
    </div>
  </section>
</div>
```

---

## ProductCard Component — `src/components/ProductCard.jsx`

```javascript
import { Link } from 'react-router-dom';
import { FiShoppingCart, FiHeart } from 'react-icons/fi';
import { useCart } from '../context/CartContext';
import toast from 'react-hot-toast';
import { formatPrice, calcDiscountPercent } from '../utils/format';

export default function ProductCard({ product }) {
  const { addToCart } = useCart();
  const hasDiscount = product.effective_price &&
    parseFloat(product.effective_price) < parseFloat(product.price);
  const discountPercent = hasDiscount
    ? calcDiscountPercent(product.price, product.effective_price)
    : 0;

  const handleAddToCart = (e) => {
    e.preventDefault();
    if (!product.in_stock) return;
    addToCart(product);
    toast.success(`${product.name} added to cart!`);
  };

  return (
    <Link to={`/product/${product.slug}`} className="product-card">
      <div className="product-card__image-wrapper">
        <img
          src={product.image_url}
          alt={product.name}
          className="product-card__image"
          loading="lazy"
        />
        {!product.in_stock && (
          <div className="product-card__out-of-stock">Out of Stock</div>
        )}
        {discountPercent > 0 && (
          <div className="product-card__discount-badge">{discountPercent}% OFF</div>
        )}
        {product.discount_units_remaining !== null && product.discount_units_remaining !== undefined && (
          <div className="product-card__units-badge">
            {product.discount_units_remaining === 0
              ? 'Offer ended'
              : `${product.discount_units_remaining} left at this price`}
          </div>
        )}
        <button
          className="product-card__wishlist"
          aria-label="Add to wishlist"
          onClick={(e) => e.preventDefault()}
        >
          <FiHeart size={18} />
        </button>
      </div>

      <div className="product-card__body">
        <span className="product-card__category">{product.category_name}</span>
        <h3 className="product-card__name">{product.name}</h3>
        <p className="product-card__material">{product.material} · {product.color}</p>

        <div className="product-card__pricing">
          {hasDiscount ? (
            <>
              <span className="product-card__effective-price">
                {formatPrice(product.effective_price)}
              </span>
              <span className="product-card__original-price">
                {formatPrice(product.price)}
              </span>
            </>
          ) : (
            <span className="product-card__price">{formatPrice(product.price)}</span>
          )}
        </div>

        <button
          className={`product-card__cta ${!product.in_stock ? 'product-card__cta--disabled' : ''}`}
          onClick={handleAddToCart}
          disabled={!product.in_stock}
        >
          <FiShoppingCart size={16} />
          {product.in_stock ? 'Add to Cart' : 'Out of Stock'}
        </button>
      </div>
    </Link>
  );
}
```

---

## FilterSidebar Component — `src/components/FilterSidebar.jsx`

```javascript
// Props:
// filters: { category, price_min, price_max, material, ordering }
// onChange: (updater) => void — call like setFilters
// categories: Category[]

export default function FilterSidebar({ filters, onChange, categories }) {
  const MATERIALS = [
    { value: 'wood', label: 'Wood' },
    { value: 'fabric', label: 'Fabric' },
    { value: 'metal', label: 'Metal' },
    { value: 'leather', label: 'Leather' },
    { value: 'marble', label: 'Marble' },
    { value: 'glass', label: 'Glass' },
    { value: 'rattan', label: 'Rattan' },
    { value: 'plastic', label: 'Plastic' },
  ];

  const resetFilters = () => {
    onChange({ category: '', price_min: '', price_max: '', material: '', ordering: '-created_at', page: 1 });
  };

  return (
    <div className="filter-sidebar">
      <div className="filter-sidebar__header">
        <h3>Filters</h3>
        <button className="filter-sidebar__reset" onClick={resetFilters}>
          Reset All
        </button>
      </div>

      {/* Sort By */}
      <div className="filter-group">
        <label className="filter-group__label">Sort By</label>
        <select
          value={filters.ordering}
          onChange={(e) => onChange((prev) => ({ ...prev, ordering: e.target.value, page: 1 }))}
          className="filter-group__select"
        >
          <option value="-created_at">Newest First</option>
          <option value="price">Price: Low to High</option>
          <option value="-price">Price: High to Low</option>
          <option value="name">Name: A to Z</option>
        </select>
      </div>

      {/* Category */}
      <div className="filter-group">
        <label className="filter-group__label">Category</label>
        {categories.map((cat) => (
          <label key={cat.slug} className="filter-checkbox">
            <input
              type="radio"
              name="category"
              checked={filters.category === cat.slug}
              onChange={() => onChange((prev) => ({ ...prev, category: cat.slug, page: 1 }))}
            />
            <span>{cat.name}</span>
            <span className="filter-checkbox__count">({cat.product_count})</span>
          </label>
        ))}
        {filters.category && (
          <button
            className="filter-group__clear"
            onClick={() => onChange((prev) => ({ ...prev, category: '', page: 1 }))}
          >
            Clear category
          </button>
        )}
      </div>

      {/* Price Range */}
      <div className="filter-group">
        <label className="filter-group__label">Price Range (₹)</label>
        <div className="filter-price-range">
          <input
            type="number"
            placeholder="Min"
            value={filters.price_min}
            onChange={(e) => onChange((prev) => ({ ...prev, price_min: e.target.value, page: 1 }))}
            className="filter-price-input"
            min="0"
          />
          <span className="filter-price-sep">—</span>
          <input
            type="number"
            placeholder="Max"
            value={filters.price_max}
            onChange={(e) => onChange((prev) => ({ ...prev, price_max: e.target.value, page: 1 }))}
            className="filter-price-input"
            min="0"
          />
        </div>
        <div className="filter-price-presets">
          {[['Under ₹10k', '', '10000'], ['₹10k–₹30k', '10000', '30000'], ['₹30k+', '30000', '']].map(([label, min, max]) => (
            <button
              key={label}
              className={`filter-price-preset ${filters.price_min === min && filters.price_max === max ? 'active' : ''}`}
              onClick={() => onChange((prev) => ({ ...prev, price_min: min, price_max: max, page: 1 }))}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {/* Material */}
      <div className="filter-group">
        <label className="filter-group__label">Material</label>
        {MATERIALS.map((mat) => (
          <label key={mat.value} className="filter-checkbox">
            <input
              type="radio"
              name="material"
              checked={filters.material === mat.value}
              onChange={() => onChange((prev) => ({ ...prev, material: mat.value, page: 1 }))}
            />
            <span>{mat.label}</span>
          </label>
        ))}
        {filters.material && (
          <button
            className="filter-group__clear"
            onClick={() => onChange((prev) => ({ ...prev, material: '', page: 1 }))}
          >
            Clear material
          </button>
        )}
      </div>
    </div>
  );
}
```

---

## Why Us Strip Content
```javascript
const WHY_US = [
  { icon: <FiTruck />, title: 'Free Shipping', desc: 'On orders above ₹2,999' },
  { icon: <FiRefreshCw />, title: 'Easy Returns', desc: '30-day hassle-free returns' },
  { icon: <FiShield />, title: '1-Year Warranty', desc: 'On all furniture products' },
  { icon: <FiStar />, title: '1 Lakh+ Happy Homes', desc: 'Trusted across India' },
];
```

---

## CSS Requirements — `src/pages/HomePage.css` & `src/components/ProductCard.css`

Write complete CSS with:
- **Product Grid:** `display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.5rem;`
- **ProductCard:** White card, 4px border-radius (--radius-lg), image aspect ratio 1:1 (padding-top: 100%), hover shadow elevation, "Add to Cart" button slides up on card hover
- **Hero:** Full-width, 70vh min-height, `object-fit: cover` background images, gradient overlay `linear-gradient(to bottom, rgba(0,0,0,0.2) 0%, rgba(0,0,0,0.6) 100%)`
- **Filter sidebar:** 260px width on desktop, `position: sticky; top: 80px;`
- **Mobile:** Filter sidebar hidden below 768px, shown in modal overlay when toggle clicked
- **Skeleton loaders:** Pulse animation for loading state

---

## Acceptance Criteria

- [ ] Hero carousel auto-plays, can be paused on hover, has dot pagination
- [ ] Clicking a category chip filters products to that category (URL changes to `?category=sofas`)
- [ ] Featured collection cards navigate to correct category filter
- [ ] FilterSidebar: selecting category, material, price range all update products
- [ ] Sort dropdown changes product order
- [ ] Pagination renders correctly and loads the right page
- [ ] "Reset All" button clears all filters
- [ ] ProductCard shows discount badge, effective price, and units remaining for logged-in users with discounts
- [ ] "Add to Cart" button fires toast and updates cart badge in Navbar
- [ ] Out-of-stock products show "Out of Stock" badge and disabled button
- [ ] Mobile: filter sidebar shows/hides via toggle button
- [ ] Page URL changes when filters are applied (shareable filter URLs)
- [ ] Page renders 12 products per page
