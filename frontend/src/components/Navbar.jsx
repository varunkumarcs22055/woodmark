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

import { useState, useRef, useEffect } from 'react';
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
} from 'react-icons/fi';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import './Navbar.css';

/* ─── Catalog navigation
 * Labels keep the original Featherlite-style office-furniture series naming.
 * `slug` MUST be one of the seeded backend categories so /?category=<slug>
 * actually returns products: sofas, tables, chairs, beds, storage, desks,
 * dining-sets, outdoor.
 */
const NAV_ITEMS = [
  {
    label: 'Prestino Director Suit Series',
    key: 'prestino',
    columns: [
      {
        heading: 'Prestino Director Suit Series',
        items: [
          { label: 'Prestino Director Table', slug: 'desks' },
          { label: 'Prestino Storage', slug: 'storage' },
          { label: 'Prestino Book Shelf & Full Height', slug: 'storage' },
          { label: 'Free Standing Director Table', slug: 'desks' },
          { label: 'Manager Table', slug: 'desks' },
          { label: 'CEO Table', slug: 'desks' },
          { label: 'Chairman Suit', slug: 'sofas' },
          { label: 'Modular Computer Table', slug: 'desks' },
          { label: 'Conference Table Series', slug: 'tables' },
          { label: 'Modular Workstation Series', slug: 'desks' },
          { label: 'Modular Cabin Table', slug: 'desks' },
          { label: 'Modular Workstation', slug: 'desks' },
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
          { label: 'Modular Cabin Table', slug: 'desks' },
          { label: 'Modular Workstation', slug: 'desks' },
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
          { label: 'Chairman Chair Series', slug: 'chairs' },
          { label: 'Director Chair Series', slug: 'chairs' },
          { label: 'Executive Chair Series', slug: 'chairs' },
          { label: 'Manager Chair Series', slug: 'chairs' },
          { label: 'Director Chair MSH Series', slug: 'chairs' },
          { label: 'Director MSH Chair Color Series', slug: 'chairs' },
          { label: 'Visitor Chair Series', slug: 'chairs' },
          { label: 'Classroom Chair Series', slug: 'chairs' },
          { label: 'Institutional Restaurant Chair Series', slug: 'chairs' },
          { label: 'Restaurant & Bar Stool Chair Series', slug: 'chairs' },
          { label: 'Restaurant & Bar Chair Series', slug: 'chairs' },
          { label: 'Auditorium Chair Series', slug: 'chairs' },
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
          { label: 'Kid Furniture Series', slug: 'beds' },
          { label: 'Kid Storage Furniture Series', slug: 'storage' },
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
          { label: 'Hospital Bed Series', slug: 'beds' },
          { label: 'Patient Transfer Trolley Series', slug: 'beds' },
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
          { label: 'Laboratory Furniture Series', slug: 'storage' },
          { label: 'Hostel Furniture Series', slug: 'beds' },
          { label: 'Reception Table Series', slug: 'tables' },
          { label: 'Waiting Chair Series', slug: 'chairs' },
          { label: 'Office Sofa Series', slug: 'sofas' },
          { label: 'Steel Furniture Series', slug: 'storage' },
          { label: 'Storage Compactor Series', slug: 'storage' },
          { label: 'Partition Series', slug: 'storage' },
          { label: 'Chair Part & Accessories Series', slug: 'chairs' },
          { label: 'Outdoor & Garden Seating', slug: 'outdoor' },
          { label: 'Dining Sets', slug: 'dining-sets' },
        ],
      },
    ],
  },
];

const SEARCH_SUGGESTIONS = ['Sofas', 'Dining Tables', 'Beds', 'Office Chairs', 'Bookshelves'];

export default function Navbar() {
  const { cartCount } = useCart();
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  const [activeMenu, setActiveMenu] = useState(null);
  const [mobileExpanded, setMobileExpanded] = useState(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [accountOpen, setAccountOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

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

  const openMenu = (key) => {
    clearTimeout(menuTimer.current);
    setActiveMenu(key);
  };

  const closeMenu = () => {
    menuTimer.current = setTimeout(() => setActiveMenu(null), 150);
  };

  const goTo = (slug) => {
    navigate(slug ? `/?category=${encodeURIComponent(slug)}` : '/');
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
              🎉 Free shipping on orders above ₹2,999 &nbsp;·&nbsp; Trusted by 1 Lakh+ happy homes
            </span>
            <div className="announcement-right">
              <FiPhone size={12} />
              <span>1800-123-4567</span>
            </div>
          </div>
        </div>
      )}

      {/* Main Navbar */}
      <nav className={`navbar ${scrolled ? 'scrolled' : ''}`}>
        <div className="navbar-inner container">
          {/* Logo */}
          <Link to="/" className="navbar-brand">
            <div className="brand-logo">
              <span className="brand-icon-wrap">
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                  <rect width="28" height="28" rx="6" fill="#00736A" />
                  <path d="M7 20V12L14 7L21 12V20H16V15H12V20H7Z" fill="white" />
                </svg>
              </span>
              <span className="brand-text">FurniShop</span>
            </div>
          </Link>

          {/* Desktop Nav */}
          <div className="navbar-nav">
            {NAV_ITEMS.map((item) => {
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
                              <button
                                key={child.label}
                                className="mega-link"
                                onClick={() => goTo(child.slug)}
                              >
                                {child.label}
                              </button>
                            ))}
                          </div>
                        ))}
                      </div>
                      <div className="mega-footer">
                        <span className="mega-footer-text">
                          Browse all <strong>{item.label}</strong>
                        </span>
                        <button
                          className="mega-footer-btn"
                          onClick={() => goTo(item.columns[0].items[0].slug)}
                        >
                          View Full Range →
                        </button>
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
                      <p className="account-menu__greet">Welcome to FurniShop</p>
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
                <button type="submit" className="btn-primary search-submit">
                  Search
                </button>
                <button
                  type="button"
                  className="search-close-btn"
                  onClick={() => setSearchOpen(false)}
                  aria-label="Close search"
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

      {/* Mobile Drawer */}
      {mobileOpen && (
        <div className="mobile-drawer">
          <div className="mobile-drawer-header">
            <Link to="/" className="navbar-brand" onClick={() => setMobileOpen(false)}>
              <span className="brand-text">FurniShop</span>
            </Link>
            <button onClick={() => setMobileOpen(false)} aria-label="Close menu">
              <FiX size={22} />
            </button>
          </div>
          <div className="mobile-drawer-body">
            {NAV_ITEMS.map((item) => (
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
                          <button
                            key={child.label}
                            className="mobile-nav-link"
                            onClick={() => goTo(child.slug)}
                          >
                            {child.label}
                          </button>
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
      )}
      {mobileOpen && <div className="mobile-overlay" onClick={() => setMobileOpen(false)} />}
    </>
  );
}
