/**
 * HomePage — Livspace-style e-commerce homepage.
 * Features: Hero banner, category strips, featured collections,
 * "Why Us" strip, product grid with filters, promo banners.
 */

import { useState, useEffect, useCallback } from "react";
import { Link, useSearchParams, useNavigate } from "react-router-dom";
import { fetchProducts } from "../api";
import ProductCard from "../components/ProductCard";
import FilterSidebar from "../components/FilterSidebar";
import {
  FiSearch,
  FiSliders,
  FiChevronLeft,
  FiChevronRight,
  FiTruck,
  FiShield,
  FiRefreshCw,
  FiStar,
  FiArrowRight,
} from "react-icons/fi";
import "./HomePage.css";
import { Swiper, SwiperSlide } from "swiper/react";
import { Autoplay, Pagination, EffectFade } from "swiper/modules";
import "swiper/css";
import "swiper/css/pagination";
import "swiper/css/effect-fade";

const CATEGORIES = [
  {
    label: "Bed Linen",
    value: "Beds",
    emoji: "🛏️",
    color: "#FFF8F0",
    border: "#FFD9B3",
  },
  {
    label: "Bath Linen",
    value: "Bath",
    emoji: "🛁",
    color: "#F0FAFF",
    border: "#B3E4FF",
  },
  {
    label: "Sofas",
    value: "Sofas",
    emoji: "🛋️",
    color: "#F0FFF4",
    border: "#B3F0C8",
  },
  {
    label: "Tables",
    value: "Tables",
    emoji: "🪵",
    color: "#FFF5F0",
    border: "#FFCCB3",
  },
  {
    label: "Chairs",
    value: "Chairs",
    emoji: "🪑",
    color: "#F5F0FF",
    border: "#D4B3FF",
  },
  {
    label: "Cushions",
    value: "Cushions",
    emoji: "🎁",
    color: "#FFFAF0",
    border: "#FFE9B3",
  },
];

const WHY_US = [
  {
    icon: <FiTruck size={24} />,
    title: "Free Shipping",
    desc: "On all orders above ₹2,999",
  },
  {
    icon: <FiRefreshCw size={24} />,
    title: "Easy Returns",
    desc: "30-day hassle-free returns",
  },
  {
    icon: <FiShield size={24} />,
    title: "1-Year Warranty",
    desc: "On all furniture products",
  },
  {
    icon: <FiStar size={24} />,
    title: "1 Lakh+ Happy Homes",
    desc: "Trusted by customers across India",
  },
];

const FEATURED_COLLECTIONS = [
  {
    title: "Bedroom Essentials",
    subtitle: "Comfort meets style",
    cta: "Shop Beds",
    category: "Beds",
    image: "/cat_bed.png",
    bg: "#F0FAF9",
    accent: "#00736A",
  },
  {
    title: "Living Room",
    subtitle: "Timeless furniture",
    cta: "Shop Sofas",
    category: "Sofas",
    image: "/cat_furniture.png",
    bg: "#FAF5F0",
    accent: "#8B5E3C",
  },
  {
    title: "Bath Collection",
    subtitle: "Spa-like luxury",
    cta: "Shop Bath",
    category: "Bath",
    image: "/cat_bath.png",
    bg: "#F0F5FA",
    accent: "#1A5276",
  },
];

export default function HomePage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const navigate = useNavigate();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [totalPages, setTotalPages] = useState(1);
  const [currentPage, setCurrentPage] = useState(1);
  const [filterOpen, setFilterOpen] = useState(false);
  const [heroSearch, setHeroSearch] = useState("");

  const [filters, setFilters] = useState({
    category: searchParams.get("category") || "",
    material: searchParams.get("material") || "",
    price_min: searchParams.get("price_min") || "",
    price_max: searchParams.get("price_max") || "",
    search: searchParams.get("search") || "",
  });

  const loadProducts = useCallback(
    async (page = 1) => {
      setLoading(true);
      try {
        const params = { page };
        if (filters.category) params.category = filters.category;
        if (filters.material) params.material = filters.material;
        if (filters.price_min) params.price_min = filters.price_min;
        if (filters.price_max) params.price_max = filters.price_max;
        if (filters.search) params.search = filters.search;

        const data = await fetchProducts(params);
        setProducts(data.results || []);
        setTotalPages(Math.ceil((data.count || 0) / 12));
        setCurrentPage(page);
      } catch (err) {
        console.error("Failed to fetch products:", err);
        setProducts([]);
      } finally {
        setLoading(false);
      }
    },
    [filters],
  );

  useEffect(() => {
    loadProducts(1);
    const params = {};
    Object.entries(filters).forEach(([k, v]) => {
      if (v) params[k] = v;
    });
    setSearchParams(params, { replace: true });
  }, [filters]);

  const handleHeroSearch = (e) => {
    e.preventDefault();
    if (heroSearch.trim()) {
      setFilters((f) => ({ ...f, search: heroSearch.trim() }));
      document
        .getElementById("products-section")
        ?.scrollIntoView({ behavior: "smooth" });
    }
  };

  const handleCategoryClick = (cat) => {
    setFilters((f) => ({ ...f, category: cat, search: "" }));
    document
      .getElementById("products-section")
      ?.scrollIntoView({ behavior: "smooth" });
  };

  const hasActiveFilters =
    filters.category ||
    filters.material ||
    filters.price_min ||
    filters.price_max ||
    filters.search;

  return (
    <div className="home-page">
      {/* ── Hero Carousel ─────────────────────────────────────── */}
      <section className="hero-section" id="hero-section">
        <Swiper
          modules={[Autoplay, Pagination, EffectFade]}
          autoplay={{ delay: 4000, disableOnInteraction: false }}
          pagination={{ clickable: true }}
          effect="fade"
          loop
          className="hero-swiper"
        >
          {[
            {
              img: "/hero_banner.png",
              eyebrow: "Trusted by 1 Lakh+ Happy Homes",
              title: "Beautiful Homes",
              accent: "Start Here",
              desc: "Premium furniture & home essentials — crafted for the Indian home. From bedroom linen to living room statement pieces.",
            },
            {
              img: "/cat_furniture.png",
              eyebrow: "New Arrival",
              title: "Modern Sofas",
              accent: "For Every Home",
              desc: "Discover our latest sofa collection — comfort, style, and durability for your living room.",
            },
            {
              img: "/cat_bath.png",
              eyebrow: "Best Seller",
              title: "Bath Collection",
              accent: "Spa Luxury",
              desc: "Upgrade your bath experience with plush towels and accessories.",
            },
          ].map((slide, idx) => (
            <SwiperSlide key={idx}>
              <div className="hero-bg">
                <img src={slide.img} alt="Banner" className="hero-bg-img" />
                <div className="hero-overlay" />
              </div>
              <div className="hero-content container">
                <div className="hero-text">
                  <span className="hero-eyebrow">{slide.eyebrow}</span>
                  <h1 className="hero-title">
                    {slide.title}
                    <br />
                    <span className="hero-title-accent">{slide.accent}</span>
                  </h1>
                  <p className="hero-desc">{slide.desc}</p>
                  <form
                    className="hero-search-form"
                    onSubmit={handleHeroSearch}
                    id="hero-search-form"
                  >
                    <FiSearch size={18} className="hero-search-icon" />
                    <input
                      type="text"
                      placeholder="Search sofas, beds, cushions, towels..."
                      value={heroSearch}
                      onChange={(e) => setHeroSearch(e.target.value)}
                      className="hero-search-input"
                      id="hero-search-input"
                    />
                    <button type="submit" className="hero-search-btn">
                      Search
                    </button>
                  </form>
                  <div className="hero-tags">
                    {["Sofas", "Bed Sheets", "Bath Towels", "Cushions"].map(
                      (tag) => (
                        <button
                          key={tag}
                          className="hero-tag-chip"
                          onClick={() => {
                            setHeroSearch(tag);
                            setFilters((f) => ({ ...f, search: tag }));
                          }}
                        >
                          {tag}
                        </button>
                      ),
                    )}
                  </div>
                </div>
                <div className="hero-stats">
                  {[
                    { num: "1L+", label: "Happy Customers" },
                    { num: "500+", label: "Products" },
                    { num: "4.8★", label: "Avg Rating" },
                  ].map((s) => (
                    <div className="hero-stat" key={s.label}>
                      <span className="hero-stat-num">{s.num}</span>
                      <span className="hero-stat-label">{s.label}</span>
                    </div>
                  ))}
                </div>
              </div>
            </SwiperSlide>
          ))}
        </Swiper>
      </section>

      {/* ── Why Us Strip ────────────────────────────────────── */}
      <section className="why-us-strip">
        <div className="why-us-inner container">
          {WHY_US.map((item) => (
            <div key={item.title} className="why-us-item">
              <span className="why-us-icon">{item.icon}</span>
              <div>
                <p className="why-us-title">{item.title}</p>
                <p className="why-us-desc">{item.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* ── Category Chips ──────────────────────────────────── */}
      <section className="category-strip-section container" id="category-strip">
        <div className="section-header-row">
          <div>
            <span className="section-tag">Explore</span>
            <h2 className="section-title">Shop by Category</h2>
          </div>
          <button
            className="see-all-btn"
            onClick={() =>
              setFilters((f) => ({ ...f, category: "", search: "" }))
            }
          >
            View All <FiArrowRight size={15} />
          </button>
        </div>
        <div className="category-chips">
          {CATEGORIES.map((cat) => (
            <button
              key={cat.value}
              className={`category-chip ${filters.category === cat.value ? "active" : ""}`}
              style={{ "--chip-bg": cat.color, "--chip-border": cat.border }}
              onClick={() => handleCategoryClick(cat.value)}
              id={`cat-chip-${cat.value.toLowerCase()}`}
            >
              <span className="chip-emoji">{cat.emoji}</span>
              <span className="chip-label">{cat.label}</span>
            </button>
          ))}
        </div>
      </section>

      {/* ── Featured Collections ─────────────────────────────── */}
      <section className="featured-collections container">
        <div className="section-header-row">
          <div>
            <span className="section-tag">Collections</span>
            <h2 className="section-title">Shop Our Collections</h2>
          </div>
        </div>
        <div className="collection-grid">
          {FEATURED_COLLECTIONS.map((col, i) => (
            <button
              key={col.title}
              className={`collection-card ${i === 0 ? "collection-card--large" : ""}`}
              style={{ "--col-bg": col.bg, "--col-accent": col.accent }}
              onClick={() => handleCategoryClick(col.category)}
              id={`collection-${col.category.toLowerCase()}`}
            >
              <div className="collection-img-wrap">
                <img
                  src={col.image}
                  alt={col.title}
                  className="collection-img"
                />
                <div className="collection-img-overlay" />
              </div>
              <div className="collection-info">
                <p className="collection-subtitle">{col.subtitle}</p>
                <h3 className="collection-title">{col.title}</h3>
                <span className="collection-cta">
                  {col.cta} <FiArrowRight size={14} />
                </span>
              </div>
            </button>
          ))}
        </div>
      </section>

      {/* ── Promo Banner ─────────────────────────────────────── */}
      <section className="promo-banner-section container">
        <div className="promo-banner">
          <div className="promo-banner-content">
            <span className="promo-banner-tag">Limited Time</span>
            <h3 className="promo-banner-title">
              Up to 40% off on
              <br />
              Best Sellers
            </h3>
            <p className="promo-banner-desc">
              Shop our most-loved products at unbeatable prices
            </p>
            <button
              className="btn-primary promo-banner-btn"
              onClick={() => handleCategoryClick("")}
            >
              Shop Best Sellers
            </button>
          </div>
          <div className="promo-banner-visual">
            <div className="promo-circle promo-circle-1" />
            <div className="promo-circle promo-circle-2" />
            <span className="promo-percent">40%</span>
            <span className="promo-off">OFF</span>
          </div>
        </div>
      </section>

      {/* ── Products Section ─────────────────────────────────── */}
      <section className="products-section container" id="products-section">
        <div className="products-section-header">
          <div>
            <span className="section-tag">Our Range</span>
            <h2 className="section-title">
              {filters.category
                ? `${filters.category} Collection`
                : filters.search
                  ? `Results for "${filters.search}"`
                  : "All Products"}
            </h2>
          </div>
          <div className="products-section-actions">
            {hasActiveFilters && (
              <button
                className="clear-filters-btn"
                onClick={() =>
                  setFilters({
                    category: "",
                    material: "",
                    price_min: "",
                    price_max: "",
                    search: "",
                  })
                }
              >
                Clear filters ×
              </button>
            )}
            <button
              className="mobile-filter-toggle-btn"
              onClick={() => setFilterOpen(true)}
              id="mobile-filter-btn"
            >
              <FiSliders size={15} /> Filters
            </button>
          </div>
        </div>

        <div className="products-layout">
          {/* Sidebar Filters */}
          <FilterSidebar
            filters={filters}
            onFilterChange={setFilters}
            mobileOpen={filterOpen}
            onClose={() => setFilterOpen(false)}
          />

          {/* Product Grid */}
          <div className="products-main">
            {loading ? (
              <div className="product-grid stagger-children">
                {Array.from({ length: 8 }).map((_, i) => (
                  <div key={i} className="product-skeleton">
                    <div
                      className="skeleton"
                      style={{ aspectRatio: "3/4", borderRadius: 8 }}
                    />
                    <div style={{ padding: "14px 0" }}>
                      <div
                        className="skeleton"
                        style={{ height: 10, width: "40%", marginBottom: 8 }}
                      />
                      <div
                        className="skeleton"
                        style={{ height: 16, width: "85%", marginBottom: 8 }}
                      />
                      <div
                        className="skeleton"
                        style={{ height: 22, width: "35%" }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            ) : products.length > 0 ? (
              <>
                <div
                  className="product-grid stagger-children"
                  id="product-grid"
                >
                  {products.map((product) => (
                    <ProductCard key={product.id} product={product} />
                  ))}
                </div>

                {/* Pagination */}
                {totalPages > 1 && (
                  <div className="pagination" id="pagination">
                    <button
                      className="pagination-btn"
                      disabled={currentPage <= 1}
                      onClick={() => loadProducts(currentPage - 1)}
                    >
                      <FiChevronLeft size={16} /> Prev
                    </button>
                    <div className="pagination-pages">
                      {Array.from({ length: totalPages }, (_, i) => i + 1).map(
                        (page) => (
                          <button
                            key={page}
                            className={`pagination-page ${page === currentPage ? "active" : ""}`}
                            onClick={() => loadProducts(page)}
                          >
                            {page}
                          </button>
                        ),
                      )}
                    </div>
                    <button
                      className="pagination-btn"
                      disabled={currentPage >= totalPages}
                      onClick={() => loadProducts(currentPage + 1)}
                    >
                      Next <FiChevronRight size={16} />
                    </button>
                  </div>
                )}
              </>
            ) : (
              <div className="empty-state">
                <div className="empty-icon">🔍</div>
                <h3>No products found</h3>
                <p>Try adjusting your filters or search terms.</p>
                <button
                  className="btn-primary"
                  onClick={() =>
                    setFilters({
                      category: "",
                      material: "",
                      price_min: "",
                      price_max: "",
                      search: "",
                    })
                  }
                >
                  Clear All Filters
                </button>
              </div>
            )}
          </div>
        </div>
      </section>
    </div>
  );
}
