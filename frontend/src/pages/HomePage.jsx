/**
 * HomePage — Livspace-style e-commerce homepage.
 * Features: Hero banner, category strips, featured collections,
 * "Why Us" strip, product grid with filters, promo banners.
 */

import { useState, useEffect, useCallback, useMemo, memo } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import { fetchProducts, fetchLimitedOffers, fetchBanners, fetchContentBlocks } from "../api";
import ProductCard from "../components/ProductCard";
import FilterSidebar from "../components/FilterSidebar";
import { useSettings } from "../context/SettingsContext";
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

/**
 * Category chips. `value` MUST match the seeded backend category slug
 * (sofas, tables, chairs, beds, storage, desks, dining-sets, outdoor)
 * so the /?category=<slug> URL actually filters correctly.
 */
const CATEGORIES = [
  { label: "Sofas",       value: "sofas",       emoji: "🛋️", color: "#F0FFF4", border: "#B3F0C8" },
  { label: "Tables",      value: "tables",      emoji: "🪵", color: "#FFF5F0", border: "#FFCCB3" },
  { label: "Chairs",      value: "chairs",      emoji: "🪑", color: "#F5F0FF", border: "#D4B3FF" },
  { label: "Beds",        value: "beds",        emoji: "🛏️", color: "#FFF8F0", border: "#FFD9B3" },
  { label: "Storage",     value: "storage",     emoji: "📦", color: "#F0F8FF", border: "#B3DAFF" },
  { label: "Desks",       value: "desks",       emoji: "💻", color: "#FFFAF0", border: "#FFE9B3" },
  { label: "Dining Sets", value: "dining-sets", emoji: "🍽️", color: "#FFF0F5", border: "#FFB3CC" },
  { label: "Outdoor",     value: "outdoor",     emoji: "🌿", color: "#F0FAFF", border: "#B3E4FF" },
];



const FEATURED_COLLECTIONS = [
  {
    title: "Bedroom Essentials",
    subtitle: "Comfort meets timeless design",
    cta: "Shop Beds",
    category: "beds",
    image: "/cat_bed.png",
    bg: "#F0FAF9",
    accent: "#2D2E5F",
  },
  {
    title: "Living Room",
    subtitle: "Make it yours",
    cta: "Shop Sofas",
    category: "sofas",
    image: "/cat_furniture.png",
    bg: "#FAF5F0",
    accent: "#8B5E3C",
  },
  {
    title: "Work From Home",
    subtitle: "Designed for focus",
    cta: "Shop Desks",
    category: "desks",
    image: "/cat_bath.png",
    bg: "#F0F5FA",
    accent: "#2C3E50",
  },
];

// Derive filters from the URL so that any external nav (Navbar mega-menu,
// category chip, browser back/forward) is the single source of truth.
const FILTER_KEYS = ['category', 'material', 'price_min', 'price_max',
                     'search', 'ordering', 'tag', 'page'];
function readFiltersFromUrl(searchParams) {
  const f = {};
  FILTER_KEYS.forEach((k) => { f[k] = searchParams.get(k) || ''; });
  if (!f.ordering) f.ordering = '-created_at';
  if (!f.page) f.page = '1';
  return f;
}
function shallowEqual(a, b) {
  for (const k of FILTER_KEYS) if ((a[k] || '') !== (b[k] || '')) return false;
  return true;
}

export default function HomePage() {
  const { settings } = useSettings();
  const [searchParams, setSearchParams] = useSearchParams();
  const navigate = useNavigate();

  const fallbackWhyUs = useMemo(() => ([
    {
      icon: <FiTruck size={24} />,
      title: "Free Shipping",
      desc: settings.free_shipping_threshold 
        ? `On all orders above ${new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(settings.free_shipping_threshold)}`
        : "On all orders",
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
  ]), [settings.free_shipping_threshold]);

  const [heroSlides, setHeroSlides] = useState(DEFAULT_HERO_SLIDES);
  const [heroCopy, setHeroCopy] = useState(DEFAULT_HERO_COPY);
  const [whyUs, setWhyUs] = useState(fallbackWhyUs);
  const [promo, setPromo] = useState(DEFAULT_PROMO);

  const [products, setProducts] = useState(null);
  const [error, setError] = useState(null);
  // `hasLoadedOnce` distinguishes the first paint (show skeletons) from
  // legitimate empty results (show empty state). Without it, the empty state
  // can flash for one frame before the initial fetch resolves.
  const [hasLoadedOnce, setHasLoadedOnce] = useState(false);
  const [loading, setLoading] = useState(true);
  const [totalPages, setTotalPages] = useState(1);
  const [currentPage, setCurrentPage] = useState(1);
  const [filterOpen, setFilterOpen] = useState(false);
  const [heroSearch, setHeroSearch] = useState(searchParams.get('search') || '');

  // Filters are computed from the URL on every render. Mutations route through
  // setSearchParams() so URL + state stay in lockstep — there's no second
  // source of truth that can drift.
  const filters = useMemo(() => readFiltersFromUrl(searchParams), [searchParams]);

  const setFilters = useCallback((updater) => {
    setSearchParams((prev) => {
      const current = readFiltersFromUrl(prev);
      const next = typeof updater === 'function' ? updater(current) : { ...current, ...updater };
      const out = new URLSearchParams();
      FILTER_KEYS.forEach((k) => {
        if (next[k]) out.set(k, next[k]);
      });
      // Skip the URL write if nothing changed — avoids router re-renders.
      const same = shallowEqual(current, next);
      return same ? prev : out;
    }, { replace: true });
  }, [setSearchParams]);

  useEffect(() => {
    setWhyUs(fallbackWhyUs);
  }, [fallbackWhyUs]);

  useEffect(() => {
    fetchBanners('home_hero')
      .then((rows) => {
        const slides = (rows || []).map((b) => ({
          img: b.image_url_resolved || b.image_url || '',
          eyebrow: b.title || DEFAULT_HERO_COPY.eyebrow,
        })).filter((s) => s.img);
        if (slides.length > 0) setHeroSlides(slides);
      })
      .catch(() => setHeroSlides(DEFAULT_HERO_SLIDES));
  }, []);

  useEffect(() => {
    fetchContentBlocks([
      'home_hero_copy',
      'trust_badges',
      'promo_best_sellers',
    ])
      .then((rows) => {
        const map = {};
        (rows || []).forEach((b) => { map[b.key] = b; });

        const heroData = map.home_hero_copy?.data_json;
        if (heroData && typeof heroData === 'object') {
          setHeroCopy({
            ...DEFAULT_HERO_COPY,
            ...heroData,
            tags: Array.isArray(heroData.tags) ? heroData.tags : DEFAULT_HERO_COPY.tags,
            stats: Array.isArray(heroData.stats) ? heroData.stats : DEFAULT_HERO_COPY.stats,
          });
        } else {
          setHeroCopy(DEFAULT_HERO_COPY);
        }

        const trustData = map.trust_badges?.data_json?.items;
        if (Array.isArray(trustData) && trustData.length > 0) {
          const iconMap = {
            truck: <FiTruck size={24} />,
            returns: <FiRefreshCw size={24} />,
            shield: <FiShield size={24} />,
            star: <FiStar size={24} />,
          };
          setWhyUs(trustData.map((i) => ({
            icon: iconMap[i.icon] || <FiStar size={24} />,
            title: i.title || 'Highlight',
            desc: i.desc || '',
          })));
        } else {
          setWhyUs(fallbackWhyUs);
        }

        const promoData = map.promo_best_sellers?.data_json;
        if (promoData && typeof promoData === 'object') {
          setPromo({
            ...DEFAULT_PROMO,
            ...promoData,
          });
        } else {
          setPromo(DEFAULT_PROMO);
        }
      })
      .catch(() => {
        setHeroCopy(DEFAULT_HERO_COPY);
        setWhyUs(fallbackWhyUs);
        setPromo(DEFAULT_PROMO);
      });
  }, [fallbackWhyUs]);



  // Stable string key so the effect only fires when filter *values* change,
  // not when the filters object reference changes on re-render.
  const filterKey = useMemo(
    () => JSON.stringify(filters),
    [filters],
  );

  useEffect(() => {
    let ignore = false;
    const parsed = JSON.parse(filterKey);

    async function startLoad() {
      setLoading(true);
      setError(null);
      try {
        const params = { page: parsed.page || 1 };
        FILTER_KEYS.forEach((k) => {
          if (k !== 'page' && parsed[k]) params[k] = parsed[k];
        });
        let data;
        for (let attempt = 0; attempt < 2; attempt++) {
          try {
            data = await fetchProducts(params);
            break;
          } catch (err) {
            if (attempt === 1) throw err;
          }
        }
        if (!ignore) {
          const results = Array.isArray(data?.results)
            ? data.results
            : Array.isArray(data)
              ? data
              : [];
          const count = Number.isFinite(data?.count) ? data.count : results.length;
          const nextPage = parseInt(parsed.page || 1, 10);

          if (count > 0 && results.length === 0 && nextPage > 1) {
            setFilters({ page: 1 });
            return;
          }

          setProducts(results);
          setTotalPages(Math.ceil(count / 12));
          setCurrentPage(parseInt(parsed.page || 1, 10));
        }
      } catch (err) {
        console.error("Failed to fetch products:", err);
        if (!ignore) {
          setError('Failed to load products. Please try again.');
          setProducts((prev) => prev ?? []);
        }
      } finally {
        if (!ignore) {
          setLoading(false);
          setHasLoadedOnce(true);
        }
      }
    }

    startLoad();
    return () => { ignore = true; };
  }, [filterKey]);

  // Keep the hero search input synced with URL changes too (e.g. when the
  // user clicks a category chip in the navbar, we want the search box to
  // clear so it doesn't keep showing an old query).
  useEffect(() => {
    setHeroSearch(filters.search || '');
  }, [filters.search]);

  const handleHeroSearch = (e) => {
    e.preventDefault();
    const term = heroSearch.trim();
    setFilters({ search: term });
    document.getElementById("products-section")
      ?.scrollIntoView({ behavior: "smooth" });
  };

  const handleCategoryClick = (cat) => {
    setFilters({ category: cat, search: '' });
    document.getElementById("products-section")
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
      {/* ── Hero (rotating background only — content is stable) ────── */}
      <HeroSection
        heroSearch={heroSearch}
        setHeroSearch={setHeroSearch}
        onSearchSubmit={handleHeroSearch}
        onTagClick={(tag) => {
          setHeroSearch(tag);
          setFilters({ search: tag });
          document.getElementById("products-section")
            ?.scrollIntoView({ behavior: "smooth" });
        }}
        slides={heroSlides}
        copy={heroCopy}
      />

      {/* ── Why Us Strip ────────────────────────────────────── */}
      <section className="why-us-strip">
        <div className="why-us-inner container">
          {whyUs.map((item) => (
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

      {/* ── Limited Time Offers ─────────────────────────────── */}
      <LimitedTimeOffers />

      {/* ── Featured Collections ───────────────────────────────
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
      </section> */}

      {/* ── Promo Banner ─────────────────────────────────────── */}
      <section className="promo-banner-section container">
        <div className="promo-banner">
          <div className="promo-banner-content">
            <span className="promo-banner-tag">{promo.tag}</span>
            <h3 className="promo-banner-title">
              {promo.title}
              <br />
              {promo.title_accent}
            </h3>
            <p className="promo-banner-desc">
              {promo.desc}
            </p>
            <button
              className="btn-primary promo-banner-btn"
              onClick={() => navigate(promo.cta_link || '/best-sellers')}
            >
              {promo.cta_text}
            </button>
          </div>
          {/* Right-side visual removed — the redundant "40% OFF" circle
              was overlapping the gradient and duplicating the title text
              ("Up to 40% off on Best Sellers"). */}
        </div>
      </section>

      {/* ── Products Section ─────────────────────────────────── */}
      <section className="products-section container" id="products-section">
        <div className="products-section-header">
          <div>
            <span className="section-tag">Our Range</span>
            <h2 className="section-title">
              {filters.category
                ? `${(CATEGORIES.find((c) => c.value === filters.category)?.label) || filters.category} Collection`
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
                    category: "", material: "", price_min: "",
                    price_max: "", search: "", tag: "", ordering: "-created_at",
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
            {loading || !hasLoadedOnce || products === null ? (
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
            ) : error && (!products || products.length === 0) ? (
              <div className="empty-state">
                <div className="empty-icon">⚠️</div>
                <h3>{error}</h3>
                <p>Please check your connection or reload the page.</p>
                <button
                  className="btn-primary"
                  onClick={() => setFilters({ page: 1 })}
                >
                  Retry
                </button>
              </div>
            ) : products && products.length > 0 ? (
              <>
                {error && (
                  <div className="empty-state" style={{ marginBottom: 20 }}>
                    <div className="empty-icon">⚠️</div>
                    <h3>{error}</h3>
                    <p>Showing last loaded products. Pull to refresh.</p>
                  </div>
                )}
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
                      onClick={() => setFilters({ page: currentPage - 1 })}
                    >
                      <FiChevronLeft size={16} /> Prev
                    </button>
                    <div className="pagination-pages">
                      {Array.from({ length: totalPages }, (_, i) => i + 1).map(
                        (page) => (
                          <button
                            key={page}
                            className={`pagination-page ${page === currentPage ? "active" : ""}`}
                            onClick={() => setFilters({ page })}
                          >
                            {page}
                          </button>
                        ),
                      )}
                    </div>
                    <button
                      className="pagination-btn"
                      disabled={currentPage >= totalPages}
                      onClick={() => setFilters({ page: currentPage + 1 })}
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
                      category: "", material: "", price_min: "",
                      price_max: "", search: "", tag: "", ordering: "-created_at",
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

/**
 * HeroSection — rotating background image carousel with a stable foreground.
 *
 * The earlier version rendered the entire hero content (title, search bar,
 * tags, stats) inside each <SwiperSlide>. That meant every autoplay tick
 * unmounted the search input and remounted it — keystrokes felt slow and
 * the bar visibly jumped between slides.
 *
 * The new layout puts the search/title/CTA in a SINGLE, stable container
 * outside the Swiper. Only the background image + the eyebrow caption
 * (which is purely decorative) rotate. The Swiper is wrapped in React.memo
 * so it doesn't re-render when the parent re-renders.
 */
const DEFAULT_HERO_SLIDES = [
  { img: "/hero_banner.png",   eyebrow: "Trusted by 1 Lakh+ Happy Homes" },
  { img: "/cat_furniture.png", eyebrow: "New Arrival — Modern Sofas" },
  { img: "/cat_bath.png",      eyebrow: "Best Seller — Bath Collection" },
];
const DEFAULT_HERO_TAGS = ["Sofa", "Dining Table", "Bed", "Office Chair", "Bookshelf"];
const DEFAULT_HERO_STATS = [
  { num: "1L+", label: "Happy Customers" },
  { num: "500+", label: "Products" },
  { num: "4.8★", label: "Avg Rating" },
];
const DEFAULT_HERO_COPY = {
  eyebrow: "New Arrival — Modern Sofas",
  title: "Beautiful Homes",
  accent: "Start Here",
  desc: "Premium furniture & home essentials — crafted for the Indian home. From bedroom linen to living-room statement pieces.",
  tags: DEFAULT_HERO_TAGS,
  stats: DEFAULT_HERO_STATS,
};
const DEFAULT_PROMO = {
  tag: "Limited Time",
  title: "Up to 40% off on",
  title_accent: "Best Sellers",
  desc: "Shop our most-loved products at unbeatable prices",
  cta_text: "Shop Best Sellers",
  cta_link: "/best-sellers",
  percent: "40%",
};

const HeroBackgrounds = (function () {
  const Inner = function HeroBackgrounds({ onCaption, slides }) {
    return (
      <Swiper
        modules={[Autoplay, Pagination, EffectFade]}
        autoplay={{ delay: 5000, disableOnInteraction: false }}
        pagination={{ clickable: true }}
        effect="fade"
        loop
        speed={900}
        className="hero-bg-swiper"
        onSlideChange={(swiper) => {
          // Pass the *real* index even when looped — Swiper's `realIndex`
          // ignores the cloned slides used by loop mode.
          const idx = swiper.realIndex ?? 0;
          onCaption?.(slides[idx]?.eyebrow || "");
        }}
      >
        {slides.map((s, i) => (
          <SwiperSlide key={i}>
            <img src={s.img} alt="" className="hero-bg-img" loading="eager" />
          </SwiperSlide>
        ))}
      </Swiper>
    );
  };
  // Memo on identity — parent re-renders shouldn't restart the autoplay
  // unless the slide set actually changes.
  return memo(Inner, (prev, next) => prev.slides === next.slides);
})()

function HeroSection({ heroSearch, setHeroSearch, onSearchSubmit, onTagClick, slides, copy }) {
  const safeSlides = Array.isArray(slides) && slides.length > 0
    ? slides
    : DEFAULT_HERO_SLIDES;
  const [caption, setCaption] = useState(safeSlides[0]?.eyebrow || DEFAULT_HERO_COPY.eyebrow);

  useEffect(() => {
    setCaption(safeSlides[0]?.eyebrow || DEFAULT_HERO_COPY.eyebrow);
  }, [safeSlides]);

  const heroTags = Array.isArray(copy?.tags) && copy.tags.length > 0
    ? copy.tags
    : DEFAULT_HERO_TAGS;
  const heroStats = Array.isArray(copy?.stats) && copy.stats.length > 0
    ? copy.stats
    : DEFAULT_HERO_STATS;

  return (
    <section className="hero-section" id="hero-section">
      <div className="hero-bg">
        <HeroBackgrounds onCaption={setCaption} slides={safeSlides} />
        <div className="hero-overlay" />
      </div>
      <div className="hero-content container">
        <div className="hero-text">
          <span className="hero-eyebrow">{caption}</span>
          <h1 className="hero-title">
            {copy?.title || DEFAULT_HERO_COPY.title}
            <br />
            <span className="hero-title-accent">{copy?.accent || DEFAULT_HERO_COPY.accent}</span>
          </h1>
          <p className="hero-desc">
            {copy?.desc || DEFAULT_HERO_COPY.desc}
          </p>
          <form
            className="hero-search-form"
            onSubmit={onSearchSubmit}
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
            {heroTags.map((tag) => (
              <button
                key={tag}
                className="hero-tag-chip"
                onClick={() => onTagClick(tag)}
                type="button"
              >
                {tag}
              </button>
            ))}
          </div>
        </div>
        <div className="hero-stats">
          {heroStats.map((s) => (
            <div className="hero-stat" key={s.label}>
              <span className="hero-stat-num">{s.num}</span>
              <span className="hero-stat-label">{s.label}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/**
 * LimitedTimeOffers — strip of products with active time-bound discounts.
 * Hides itself when the response is empty so the homepage doesn't show a
 * blank section. Countdown re-renders every minute via a tick state.
 */
function LimitedTimeOffers() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [, setTick] = useState(0);

  useEffect(() => {
    fetchLimitedOffers({ limit: 8 })
      .then((data) => setItems(Array.isArray(data) ? data : []))
      .catch(() => setItems([]))
      .finally(() => setLoading(false));
  }, []);

  // Re-render every 60s so the countdown updates.
  useEffect(() => {
    if (items.length === 0) return undefined;
    const id = setInterval(() => setTick((n) => n + 1), 60_000);
    return () => clearInterval(id);
  }, [items.length]);

  if (loading || items.length === 0) return null;

  return (
    <section className="lto-section container" id="limited-time-offers">
      <div className="section-header-row">
        <div>
          <span className="section-tag" style={{ color: "#b91c1c" }}>⏱ Hurry</span>
          <h2 className="section-title">Limited Time Offers</h2>
        </div>
      </div>
      <div className="product-grid">
        {items.map((p) => (
          <div key={p.id} className="lto-card-wrap">
            <ProductCard product={p} />
            {p.time_offer?.ends_at && (
              <CountdownPill endsAt={p.time_offer.ends_at} />
            )}
          </div>
        ))}
      </div>
    </section>
  );
}

function CountdownPill({ endsAt }) {
  const ms = new Date(endsAt).getTime() - Date.now();
  if (ms <= 0) return null;

  const days = Math.floor(ms / 86_400_000);
  const hrs = Math.floor((ms % 86_400_000) / 3_600_000);
  const mins = Math.floor((ms % 3_600_000) / 60_000);

  let label;
  if (days >= 1) label = `${days}d ${hrs}h left`;
  else if (hrs >= 1) label = `${hrs}h ${mins}m left`;
  else label = `${mins}m left`;

  const urgent = ms < 6 * 3_600_000;

  return (
    <span className={`lto-countdown ${urgent ? "lto-countdown--urgent" : ""}`}>
      ⏱ {label}
    </span>
  );
}
