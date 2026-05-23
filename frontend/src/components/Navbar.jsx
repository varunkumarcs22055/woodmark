/**
 * Navbar — premium mega-menu navigation with auth-aware account menu.
 *
 *   - Announcement bar (top strip)
 *   - Main row: logo · mega-menu nav · search · account · cart
 *   - Mega menu: multi-column dropdown per category, slug-based navigation
 *   - Search overlay with quick suggestion chips
 *   - Mobile drawer with accordion nav
 *   - Account button: shows Login link when logged out, dropdown menu when logged in
 *     (Profile, Orders, Admin/Dealer dashboard by role, Sign Out)
 *
 * NAV_ITEMS slugs MUST match seeded Category slugs in the backend
 * (sofas, tables, chairs, beds, storage, desks, dining-sets, outdoor).
 */

import { useState, useRef, useEffect, useMemo } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import {
  FiSearch,
  FiShoppingBag,
  FiUser,
  FiChevronDown,
  FiMenu,
  FiX,
  FiPhone,
  FiLogOut,
  FiPackage,
  FiSettings,
  FiTrendingUp,
  FiUserCheck,
  FiMessageSquare,
} from 'react-icons/fi';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import { fetchContentBlocks } from '../api';
import { useSettings } from '../context/SettingsContext';
import './Navbar.css';

/* ─── Catalog navigation ────────────────────────────────────────────────
 * The labels here preserve the Featherlite-style office-furniture series
 * naming the storefront launched with. They are *not* category names —
 * each item carries:
 *   { label, slug, search }
 * where:
 *   slug   = backend Category slug to filter on (e.g. 'desks', 'chairs')
 *   search = free-text keyword passed to the product list endpoint's
 *            `?search=` (matches name / description / SKU).
 *
 * Combined URL pattern: /?category=<slug>&search=<keyword>
 * Backend ANDs the two filters together, so the dropdown items surface
 * a real subset of products without needing a Tag or child-Category row
 * for every label. As products are added with these series names in their
 * titles, the links automatically pull them in.
 *
 * If a label produces an empty result set, the storefront still falls
 * back to the broader category — never a blank page.
 */
const NAV_ITEMS = [
  {
    label: 'Prestino Director Suit Series',
    key: 'prestino',
    columns: [
      {
        heading: 'Prestino Director Suit Series',
        items: [
          { label: 'Prestino Director Table', slug: 'desks', search: 'director table' },
          { label: 'Prestino Storage', slug: 'storage', search: 'prestino' },
          { label: 'Prestino Book Shelf & Full Height', slug: 'storage', search: 'bookshelf' },
          { label: 'Free Standing Director Table', slug: 'desks', search: 'director' },
          { label: 'Manager Table', slug: 'desks', search: 'manager' },
          { label: 'CEO Table', slug: 'desks', search: 'ceo' },
          { label: 'Chairman Suit', slug: 'sofas', search: 'chairman' },
          { label: 'Modular Computer Table', slug: 'desks', search: 'computer' },
          { label: 'Conference Table Series', slug: 'tables', search: 'conference' },
          { label: 'Modular Workstation Series', slug: 'desks', search: 'workstation' },
          { label: 'Modular Cabin Table', slug: 'desks', search: 'cabin' },
          { label: 'Modular Workstation', slug: 'desks', search: 'workstation' },
        ],
      },
    ],
  },

  {
    label: 'Modular Workstation Series',
    key: 'modular',
    columns: [
      {
        heading: 'Modular Workstation Series',
        items: [
          { label: 'Modular Cabin Table', slug: 'desks', search: 'cabin' },
          { label: 'Modular Workstation', slug: 'desks', search: 'workstation' },
        ],
      },
    ],
  },

  {
    label: 'Chair Series',
    key: 'chairs',
    columns: [
      {
        heading: 'Chair Series',
        items: [
          { label: 'Chairman Chair Series', slug: 'chairs', search: 'chairman' },
          { label: 'Director Chair Series', slug: 'chairs', search: 'director' },
          { label: 'Executive Chair Series', slug: 'chairs', search: 'executive' },
          { label: 'Manager Chair Series', slug: 'chairs', search: 'manager' },
          { label: 'Director Chair MSH Series', slug: 'chairs', search: 'msh' },
          { label: 'Director MSH Chair Color Series', slug: 'chairs', search: 'msh color' },
          { label: 'Visitor Chair Series', slug: 'chairs', search: 'visitor' },
          { label: 'Classroom Chair Series', slug: 'chairs', search: 'classroom' },
          { label: 'Institutional Restaurant Chair Series', slug: 'chairs', search: 'restaurant' },
          { label: 'Restaurant & Bar Stool Chair Series', slug: 'chairs', search: 'bar stool' },
          { label: 'Restaurant & Bar Chair Series', slug: 'chairs', search: 'bar' },
          { label: 'Auditorium Chair Series', slug: 'chairs', search: 'auditorium' },
        ],
      },
    ],
  },

  {
    label: 'Kid Series',
    key: 'kids',
    columns: [
      {
        heading: 'Kids Furniture',
        items: [
          { label: 'Kid Furniture Series', slug: 'beds', search: 'kid' },
          { label: 'Kid Storage Furniture Series', slug: 'storage', search: 'kid' },
        ],
      },
    ],
  },

  {
    label: 'Hospital Furniture',
    key: 'hospital',
    columns: [
      {
        heading: 'Hospital',
        items: [
          { label: 'Hospital Bed Series', slug: 'beds', search: 'hospital' },
          { label: 'Patient Transfer Trolley Series', slug: 'beds', search: 'trolley' },
        ],
      },
    ],
  },

  {
    label: 'Other Series',
    key: 'others',
    columns: [
      {
        heading: 'Others',
        items: [
          { label: 'Laboratory Furniture Series', slug: 'storage', search: 'laboratory' },
          { label: 'Hostel Furniture Series', slug: 'beds', search: 'hostel' },
          { label: 'Reception Table Series', slug: 'tables', search: 'reception' },
          { label: 'Waiting Chair Series', slug: 'chairs', search: 'waiting' },
          { label: 'Office Sofa Series', slug: 'sofas', search: 'office' },
          { label: 'Steel Furniture Series', slug: 'storage', search: 'steel' },
          { label: 'Storage Compactor Series', slug: 'storage', search: 'compactor' },
          { label: 'Partition Series', slug: 'storage', search: 'partition' },
          { label: 'Chair Part & Accessories Series', slug: 'chairs', search: 'accessories' },
          { label: 'Outdoor & Garden Seating', slug: 'outdoor', search: '' },
          { label: 'Dining Sets', slug: 'dining-sets', search: '' },
        ],
      },
    ],
  },
];

const SEARCH_SUGGESTIONS = ['Sofas', 'Dining Tables', 'Beds', 'Office Chairs', 'Bookshelves'];

export default function Navbar() {
  const { cartCount } = useCart();
  const { user, logout } = useAuth();
  const { settings } = useSettings();
  const location = useLocation();
  const navigate = useNavigate();

  const [activeMenu, setActiveMenu] = useState(null);
  const [mobileExpanded, setMobileExpanded] = useState(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [accountOpen, setAccountOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  const freeShippingText = settings.free_shipping_threshold
    ? `Free shipping on orders above ${new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        maximumFractionDigits: 0,
      }).format(settings.free_shipping_threshold)}`
    : 'Free shipping on all orders';
  const [contentBlocks, setContentBlocks] = useState({});

  useEffect(() => {
    fetchContentBlocks(['announcement_bar', 'nav_menu'])
      .then((rows) => {
        const map = {};
        (rows || []).forEach((b) => { map[b.key] = b; });
        setContentBlocks(map);
      })
      .catch(() => setContentBlocks({}));
  }, []);

  const navItems = useMemo(() => {
    // CMS override wins — admin can hand-author the navbar tree.
    const override = contentBlocks.nav_menu?.data_json?.groups;
    if (Array.isArray(override) && override.length > 0) {
      return override.map((g, idx) => {
        const columns = Array.isArray(g.columns) && g.columns.length > 0
          ? g.columns
          : [{ heading: g.heading || g.label || 'Menu', items: g.items || [] }];
        return {
          label: g.label || g.heading || `Menu ${idx + 1}`,
          key: g.key || `cms-${idx}`,
          slug: g.slug || '',
          columns,
        };
      });
    }
    return NAV_ITEMS;
  }, [contentBlocks.nav_menu]);

  const searchRef = useRef(null);
  const menuTimer = useRef(null);
  const accountRef = useRef(null);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 2);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  useEffect(() => {
    setMobileOpen(false);
    setActiveMenu(null);
    setAccountOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    if (searchOpen && searchRef.current) searchRef.current.focus();
  }, [searchOpen]);

  // Close account menu when clicking outside
  useEffect(() => {
    if (!accountOpen) return;
    const onClick = (e) => {
      if (accountRef.current && !accountRef.current.contains(e.target)) {
        setAccountOpen(false);
      }
    };
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, [accountOpen]);

  // ESC closes the mobile drawer + locks page scroll while it's open so the
  // user can't scroll the body behind the drawer.
  useEffect(() => {
    if (!mobileOpen) return undefined;
    const onKey = (e) => { if (e.key === 'Escape') setMobileOpen(false); };
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    document.addEventListener('keydown', onKey);
    return () => {
      document.body.style.overflow = prev;
      document.removeEventListener('keydown', onKey);
    };
  }, [mobileOpen]);

  const openMenu = (key) => {
    clearTimeout(menuTimer.current);
    setActiveMenu(key);
  };

  const closeMenu = () => {
    menuTimer.current = setTimeout(() => setActiveMenu(null), 150);
  };

  // `child` is one mega-menu link: { label, slug, search?, tag? }
  //   label  -> the visible name (used as the search keyword so the URL
  //             reflects exactly what the user clicked)
  //   slug   -> backend Category slug. Used ONLY when there's no search
  //             keyword — otherwise it would AND with the search and drop
  //             products that match the keyword but live in another category.
  //   search -> optional override keyword (defaults to label)
  //   tag    -> optional Tag.slug (CMS overrides may still use it)
  // Bare strings are treated as a category slug for backward compat.
  const buildHref = (child) => {
    if (typeof child === 'string') {
      return child ? `/?category=${encodeURIComponent(child)}` : '/';
    }
    if (!child) return '/';
    const params = new URLSearchParams();
    // Default the search to the clicked label so the URL is self-describing.
    // Explicit empty string (`search: ''`) suppresses it on items that should
    // pull the entire category instead of narrowing.
    const keyword = child.search !== undefined ? child.search : (child.label || '');
    if (keyword) {
      params.set('search', keyword);
    } else if (child.slug) {
      // Only fall back to category when there's no keyword at all.
      params.set('category', child.slug);
    }
    if (child.tag) params.set('tag', child.tag);
    const qs = params.toString();
    return qs ? `/?${qs}` : '/';
  };

  const goTo = (child) => {
    navigate(buildHref(child));
    setActiveMenu(null);
    setMobileOpen(false);
  };

  const handleSearch = (e) => {
    e.preventDefault();
    const q = searchQuery.trim();
    if (q) {
      navigate(`/?search=${encodeURIComponent(q)}`);
      setSearchOpen(false);
      setSearchQuery('');
    }
  };

  const handleLogout = async () => {
    await logout();
    setAccountOpen(false);
    navigate('/');
  };

  // Long single-column item lists look better split into multiple columns
  const splitIntoColumns = (items, colCount = 3) => {
    const columns = Array.from({ length: colCount }, () => []);
    items.forEach((item, idx) => columns[idx % colCount].push(item));
    return columns;
  };

  return (
    <>
      {/* Announcement Bar — swaps to a dealer-rates ribbon when a dealer is logged in */}
      {user?.role === 'dealer' ? (
        <div className="announcement-bar announcement-bar--dealer">
          <div className="announcement-inner container">
            <span className="announcement-text">
              💼 Dealer rates active &nbsp;·&nbsp; Your B2B prices are applied automatically across the site
            </span>
            <div className="announcement-right">
              <Link to="/dealer-dashboard" style={{ color: 'inherit' }}>
                Dealer Portal →
              </Link>
            </div>
          </div>
        </div>
      ) : (
        <div className="announcement-bar">
          <div className="announcement-inner container">
            <span className="announcement-text">
              {contentBlocks.announcement_bar?.data_json?.text
                || contentBlocks.announcement_bar?.body_md?.trim()
                || `🎉 ${freeShippingText} · Trusted by 1 Lakh+ happy homes`}
            </span>
            <div className="announcement-right">
              <FiPhone size={12} />
              <span>{contentBlocks.announcement_bar?.data_json?.phone || '1800-123-4567'}</span>
            </div>
          </div>
        </div>
      )}

      {/* Main Navbar */}
      <nav className={`navbar ${scrolled ? 'scrolled' : ''}`}>
        <div className="navbar-inner container">
          {/* Logo — uses the printed image from /logo.png (the file lives
              in frontend/public/logo.png, dropped in by the brand owner).
              The image renders the full lockup (mark + wordmark + tagline)
              from the official brand asset, so it always matches the
              printed material exactly. */}
          <Link to="/" className="navbar-brand">
            <img
              src="/logo.webp"
              alt="FurnoTech"
              className="brand-logo-img"
              onError={(e) => {
                // If the user hasn't dropped logo.png in /public yet, fall
                // back to the inline SVG wordmark so the navbar is never
                // empty. The image element is hidden and we render the
                // text alongside as a backup.
                e.currentTarget.style.display = 'none';
                e.currentTarget.nextElementSibling.style.display = 'inline-flex';
              }}
            />
            <span className="brand-logo brand-logo--fallback">
              <span className="brand-icon-wrap" aria-hidden="true">
                <svg width="34" height="34" viewBox="0 0 40 40" fill="none">
                  <rect width="40" height="40" rx="8" fill="var(--color-accent)" />
                  <path d="M12 30 V10 H30 V14 H17 V18 H27 V22 H17 V30 Z" fill="#fff" />
                </svg>
              </span>
              <span className="brand-text">
                Furno<span className="brand-text__accent">Tech</span>
              </span>
            </span>
          </Link>

          {/* Desktop Nav */}
          <div className="navbar-nav">
            {navItems.map((item) => {
              // If a column has many items, fan it across 3 sub-columns for layout
              const shouldSplit =
                item.columns.length === 1 && item.columns[0].items.length > 6;
              const renderedColumns = shouldSplit
                ? splitIntoColumns(item.columns[0].items, 3).map((items, idx) => ({
                    heading: idx === 0 ? item.columns[0].heading : '',
                    items,
                  }))
                : item.columns;

              return (
                <div
                  key={item.key}
                  className="nav-item"
                  onMouseEnter={() => openMenu(item.key)}
                  onMouseLeave={closeMenu}
                >
                  <button className={`nav-trigger ${activeMenu === item.key ? 'active' : ''}`}>
                    {item.label}
                    <FiChevronDown
                      size={13}
                      className={`nav-chevron ${activeMenu === item.key ? 'rotated' : ''}`}
                    />
                  </button>

                  {activeMenu === item.key && (
                    <div
                      className="mega-menu"
                      onMouseEnter={() => clearTimeout(menuTimer.current)}
                      onMouseLeave={closeMenu}
                    >
                      <div className="mega-menu-inner mega-menu-cols">
                        {renderedColumns.map((col, colIdx) => (
                          <div key={(col.heading || 'col') + colIdx} className="mega-col">
                            {col.heading && <p className="mega-col-title">{col.heading}</p>}
                            {col.items.map((child) => (
                              <Link
                                key={child.label}
                                to={buildHref(child)}
                                className="mega-link"
                                onClick={() => { setActiveMenu(null); setMobileOpen(false); }}
                              >
                                {child.label}
                              </Link>
                            ))}
                          </div>
                        ))}
                      </div>
                      <div className="mega-footer">
                        <span className="mega-footer-text">
                          Browse all <strong>{item.label}</strong>
                        </span>
                        <Link
                          to={buildHref(item.columns[0]?.items[0])}
                          className="mega-footer-btn"
                          onClick={() => { setActiveMenu(null); setMobileOpen(false); }}
                        >
                          View Full Range →
                        </Link>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {/* Right Actions */}
          <div className="navbar-actions">
            <button
              className="nav-action-btn"
              onClick={() => setSearchOpen(!searchOpen)}
              title="Search"
              aria-label="Search"
            >
              <FiSearch size={20} />
            </button>

            {/* Account dropdown */}
            <div className="account-wrap" ref={accountRef}>
              <button
                className="nav-action-btn"
                onClick={() => setAccountOpen((o) => !o)}
                title="Account"
                aria-label="Account"
              >
                <FiUser size={20} />
              </button>

              {accountOpen && (
                <div className="account-menu">
                  {user ? (
                    <>
                      <div className="account-menu__header">
                        <div className="account-menu__avatar">
                          {user.full_name?.charAt(0).toUpperCase() ||
                            user.email?.charAt(0).toUpperCase() ||
                            'U'}
                        </div>
                        <div className="account-menu__user">
                          <span className="account-menu__name">
                            {user.full_name || user.email}
                          </span>
                          <span className="account-menu__role">{user.role}</span>
                        </div>
                      </div>
                      <Link to="/orders" className="account-menu__link" onClick={() => setAccountOpen(false)}>
                        <FiPackage size={16} /> My Orders
                      </Link>
                      {user.role === 'user' && (
                        <Link to="/account" className="account-menu__link" onClick={() => setAccountOpen(false)}>
                          <FiUserCheck size={16} /> My Account
                        </Link>
                      )}
                      {user.role === 'user' && (
                        <Link to="/account/support" className="account-menu__link" onClick={() => setAccountOpen(false)}>
                          <FiMessageSquare size={16} /> Support Inbox
                        </Link>
                      )}
                      {user.role === 'admin' && (
                        <Link
                          to="/admin-dashboard"
                          className="account-menu__link"
                          onClick={() => setAccountOpen(false)}
                        >
                          <FiSettings size={16} /> Admin Dashboard
                        </Link>
                      )}
                      {user.role === 'dealer' && (
                        <Link
                          to="/dealer-dashboard"
                          className="account-menu__link"
                          onClick={() => setAccountOpen(false)}
                        >
                          <FiTrendingUp size={16} /> Dealer Portal
                        </Link>
                      )}
                      {user.role === 'user' && (
                        <Link
                          to="/dealer-apply"
                          className="account-menu__link"
                          onClick={() => setAccountOpen(false)}
                        >
                          <FiTrendingUp size={16} /> Become a Dealer
                        </Link>
                      )}
                      <div className="account-menu__divider" />
                      <button onClick={handleLogout} className="account-menu__link account-menu__link--danger">
                        <FiLogOut size={16} /> Sign Out
                      </button>
                    </>
                  ) : (
                    <>
                      <p className="account-menu__greet">Welcome to FurnoTech</p>
                      <Link to="/login" className="btn-primary account-menu__cta" onClick={() => setAccountOpen(false)}>
                        Sign In
                      </Link>
                      <p className="account-menu__hint">
                        New here?{' '}
                        <Link to="/signup" onClick={() => setAccountOpen(false)}>
                          Create an account
                        </Link>
                      </p>
                      <div className="account-menu__divider" />
                      <Link to="/orders" className="account-menu__link" onClick={() => setAccountOpen(false)}>
                        <FiPackage size={16} /> Track an Order
                      </Link>
                      <Link to="/dealer-apply" className="account-menu__link" onClick={() => setAccountOpen(false)}>
                        <FiTrendingUp size={16} /> Become a Dealer
                      </Link>
                    </>
                  )}
                </div>
              )}
            </div>

            <Link to="/cart" className="nav-cart-btn" title="Cart" aria-label="Cart">
              <FiShoppingBag size={20} />
              {cartCount > 0 && <span className="cart-badge">{cartCount}</span>}
            </Link>

            <button
              className="mobile-toggle"
              onClick={() => setMobileOpen(!mobileOpen)}
              aria-label="Toggle menu"
            >
              {mobileOpen ? <FiX size={22} /> : <FiMenu size={22} />}
            </button>
          </div>
        </div>

        {/* Search overlay */}
        {searchOpen && (
          <div className="search-overlay">
            <div className="search-overlay-inner container">
              <form className="search-form" onSubmit={handleSearch}>
                <FiSearch size={20} className="search-form-icon" />
                <input
                  ref={searchRef}
                  type="text"
                  placeholder="Search sofas, tables, beds, storage…"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="search-form-input"
                />
                <button type="submit" className="btn-primary search-submit" id="search-btn-desktop">
                  Search
                </button>
                <button
                  type="button"
                  className="search-close-btn"
                  onClick={() => setSearchOpen(false)}
                  aria-label="Close search"
                  id="search-close-btn"
                >
                  <FiX size={20} />
                </button>
              </form>
              <div className="search-suggestions">
                {SEARCH_SUGGESTIONS.map((s) => (
                  <button
                    key={s}
                    className="search-suggestion-chip"
                    onClick={() => {
                      navigate(`/?search=${encodeURIComponent(s)}`);
                      setSearchOpen(false);
                    }}
                  >
                    {s}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}
      </nav>

      {/* Mobile Drawer + backdrop */}
      {mobileOpen && (
        <>
          <div className="mobile-drawer-backdrop"
               onClick={() => setMobileOpen(false)}
               aria-hidden="true" />
          <div className="mobile-drawer" role="dialog" aria-modal="true"
               aria-label="Site navigation">
            <div className="mobile-drawer-header">
              <Link to="/" className="navbar-brand" onClick={() => setMobileOpen(false)}>
                <span className="brand-text">FurnoTech</span>
              </Link>
              <button onClick={() => setMobileOpen(false)} aria-label="Close menu"
                      className="mobile-drawer-close">
                <FiX size={22} />
              </button>
            </div>
            <div className="mobile-drawer-body">
            {navItems.map((item) => (
              <div key={item.key} className="mobile-nav-group">
                <button
                  className={`mobile-nav-label mobile-accordion ${
                    mobileExpanded === item.key ? 'expanded' : ''
                  }`}
                  onClick={() =>
                    setMobileExpanded(mobileExpanded === item.key ? null : item.key)
                  }
                >
                  <span>{item.label}</span>
                  <FiChevronDown
                    size={16}
                    className={`mobile-accordion-arrow ${
                      mobileExpanded === item.key ? 'rotated' : ''
                    }`}
                  />
                </button>
                {mobileExpanded === item.key && (
                  <div className="mobile-accordion-content">
                    {item.columns.map((col) => (
                      <div key={col.heading} className="mobile-sub-group">
                        <p className="mobile-sub-heading">{col.heading}</p>
                        {col.items.map((child) => (
                          <Link
                            key={child.label}
                            to={buildHref(child)}
                            className="mobile-nav-link"
                            onClick={() => setMobileOpen(false)}
                          >
                            {child.label}
                          </Link>
                        ))}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ))}

            <div className="mobile-drawer-divider" />

            {user ? (
              <>
                <div className="mobile-user-card">
                  <div className="account-menu__avatar">
                    {user.full_name?.charAt(0).toUpperCase() || 'U'}
                  </div>
                  <div>
                    <span className="account-menu__name">{user.full_name || user.email}</span>
                    <span className="account-menu__role">{user.role}</span>
                  </div>
                </div>
                <Link to="/orders" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
                  My Orders
                </Link>
                {user.role === 'admin' && (
                  <Link to="/admin-dashboard" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
                    Admin Dashboard
                  </Link>
                )}
                {user.role === 'dealer' && (
                  <Link to="/dealer-dashboard" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
                    Dealer Portal
                  </Link>
                )}
                <button className="mobile-nav-label" onClick={handleLogout}>
                  Sign Out
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
                  Sign In
                </Link>
                <Link to="/signup" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
                  Create Account
                </Link>
                <Link to="/orders" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
                  Track an Order
                </Link>
                <Link to="/dealer-apply" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
                  Become a Dealer
                </Link>
              </>
            )}
            <Link to="/cart" className="mobile-nav-label" onClick={() => setMobileOpen(false)}>
              Cart {cartCount > 0 && `(${cartCount})`}
            </Link>
            </div>
          </div>
        </>
      )}
    </>
  );
}
