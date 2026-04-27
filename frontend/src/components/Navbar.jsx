/**
 * Navbar — Featherlite-style catalog mega menu.
 * Multi-column dropdown with product series from catalog.
 */

import { useState, useRef, useEffect } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useCart } from "../context/CartContext";
import {
  FiSearch,
  FiShoppingBag,
  FiUser,
  FiChevronDown,
  FiMenu,
  FiX,
  FiHeart,
  FiPhone,
} from "react-icons/fi";
import "./Navbar.css";

/* ─────────────────────────────────────────────────────────────────────
   Catalog nav structure — extracted from Featherlite catalog images.
   Each top-level item can have `columns` (multi-column mega menu).
   `slug` maps to backend API category slug.
───────────────────────────────────────────────────────────────────── */
// const NAV_ITEMS = [
//   {
//     label: 'Chairs',
//     key: 'chairs',
//     columns: [
//       {
//         heading: 'WFH Chairs',
//         items: [
//           { label: 'High Back Chairs',    slug: 'chairs' },
//           { label: 'Medium Back Chairs',  slug: 'chairs' },
//           { label: 'Mesh Chairs',         slug: 'chairs' },
//           { label: 'Fabric Chairs',       slug: 'chairs' },
//         ],
//       },
//       {
//         heading: 'Director / Executive',
//         items: [
//           { label: 'Chairman Chair Series',  slug: 'chairs' },
//           { label: 'Director Chair Series',  slug: 'chairs' },
//           { label: 'Executive Chair Series', slug: 'chairs' },
//           { label: 'Manager Chair Series',   slug: 'chairs' },
//           { label: 'Mesh Chair Series',      slug: 'chairs' },
//         ],
//       },
//       {
//         heading: 'Living Chairs',
//         items: [
//           { label: 'Lounge Chairs',           slug: 'chairs' },
//           { label: 'Gaming Chairs',           slug: 'chairs' },
//           { label: 'Living Fabric Chair',     slug: 'chairs' },
//           { label: 'Living Leatherette Chair',slug: 'chairs' },
//         ],
//       },
//       {
//         heading: 'Visitor / Specialty',
//         items: [
//           { label: 'Visitor Chair Series',   slug: 'chairs' },
//           { label: 'Classroom Chair Series', slug: 'chairs' },
//           { label: 'Restaurant & Bar Chairs',slug: 'chairs' },
//           { label: 'Auditorium Chairs',      slug: 'chairs' },
//           { label: 'Waiting Chair Series',   slug: 'chairs' },
//         ],
//       },
//     ],
//   },
//   {
//     label: 'Tables',
//     key: 'tables',
//     columns: [
//       {
//         heading: 'WFH Tables',
//         items: [
//           { label: 'Height Adjustable Tables', slug: 'tables' },
//           { label: 'Computer Tables',          slug: 'tables' },
//           { label: 'Study Tables',             slug: 'tables' },
//           { label: 'Executive Tables',         slug: 'tables' },
//           { label: 'Portable Tables',          slug: 'tables' },
//         ],
//       },
//       {
//         heading: 'Office / Conference',
//         items: [
//           { label: 'Conference Table Series',  slug: 'tables' },
//           { label: 'Manager Table',            slug: 'tables' },
//           { label: 'CEO Table',                slug: 'tables' },
//           { label: 'Chairman Suit',            slug: 'tables' },
//           { label: 'Free Standing Director Table', slug: 'desks' },
//         ],
//       },
//       {
//         heading: 'Workstations',
//         items: [
//           { label: 'Modular Workstation',      slug: 'desks' },
//           { label: 'Modular Cabin Table',      slug: 'desks' },
//           { label: 'Modular Computer Table',   slug: 'desks' },
//           { label: 'Prestino Director Table',  slug: 'desks' },
//         ],
//       },
//       {
//         heading: 'Living Tables',
//         items: [
//           { label: 'Coffee Table', slug: 'tables' },
//           { label: 'Side Table',   slug: 'tables' },
//         ],
//       },
//     ],
//   },
//   {
//     label: 'Storage',
//     key: 'storage',
//     columns: [
//       {
//         heading: 'WFH Accessories',
//         items: [
//           { label: 'Open Storage',       slug: 'storage' },
//           { label: 'Pedestal',           slug: 'storage' },
//           { label: 'Laptop Stands',      slug: 'storage' },
//           { label: 'Table Top Storage',  slug: 'storage' },
//         ],
//       },
//       {
//         heading: 'Office Storage',
//         items: [
//           { label: 'Prestino Storage',         slug: 'storage' },
//           { label: 'Prestino Book Shelf',      slug: 'storage' },
//           { label: 'Kid Storage Furniture',    slug: 'storage' },
//           { label: 'Storage Compactor Series', slug: 'storage' },
//         ],
//       },
//       {
//         heading: 'Steel & Partitions',
//         items: [
//           { label: 'Steel Furniture Series',   slug: 'storage' },
//           { label: 'Partition Series',         slug: 'storage' },
//           { label: 'Laboratory Furniture',     slug: 'storage' },
//           { label: 'Hostel Furniture Series',  slug: 'storage' },
//         ],
//       },
//     ],
//   },
//   {
//     label: 'Sofas & Seating',
//     key: 'sofas',
//     columns: [
//       {
//         heading: 'Office Sofas',
//         items: [
//           { label: 'Office Sofa Series',      slug: 'sofas' },
//           { label: 'President / GM Suit',     slug: 'sofas' },
//           { label: 'Prestino Director Suit',  slug: 'sofas' },
//           { label: 'Reception Sofas',         slug: 'sofas' },
//         ],
//       },
//       {
//         heading: 'Dining & Restaurant',
//         items: [
//           { label: 'Dining Sets',                     slug: 'dining-sets' },
//           { label: 'Restaurant & Bar Stool Series',   slug: 'dining-sets' },
//           { label: 'Institutional Restaurant Chairs', slug: 'dining-sets' },
//         ],
//       },
//       {
//         heading: 'Outdoor',
//         items: [
//           { label: 'Outdoor Furniture',  slug: 'outdoor' },
//           { label: 'Garden Seating',     slug: 'outdoor' },
//         ],
//       },
//     ],
//   },
//   {
//     label: 'Beds & Hospital',
//     key: 'beds',
//     columns: [
//       {
//         heading: 'Beds',
//         items: [
//           { label: 'Beds & Bedroom Sets', slug: 'beds' },
//           { label: 'Kid Furniture Series', slug: 'beds' },
//         ],
//       },
//       {
//         heading: 'Hospital Furniture',
//         items: [
//           { label: 'Hospital Bed Series',              slug: 'beds' },
//           { label: 'Patient Transfer Trolley Series',  slug: 'beds' },
//         ],
//       },
//       {
//         heading: 'Accessories',
//         items: [
//           { label: 'Chair Part & Accessories', slug: 'chairs' },
//           { label: 'Lab Furniture',            slug: 'storage' },
//         ],
//       },
//     ],
//   },
//   {
//     label: 'Best Sellers',
//     key: 'best-sellers',
//     slug: '',            // no dropdown — direct link to all products
//     highlight: true,
//   },
// ];

const NAV_ITEMS = [
  {
    label: "Prestino Director Suit Series",
    key: "category-1",
    columns: [
      {
        heading: "Prestino Director Suit Series",
        items: [
          // { label: 'Prestino Director Suit Series', slug: 'category-1' },
          { label: "Prestino Director Table", slug: "category-1" },
          { label: "Prestino Storage", slug: "category-1" },
          { label: "Prestino Book Shelf & Full Height", slug: "category-1" },
          { label: "Free Standing Director Table", slug: "category-1" },
          { label: "Manager Table", slug: "category-1" },
          { label: "CEO Table", slug: "category-1" },
          { label: "Chairman Suit", slug: "category-1" },
          { label: "Modular Computer Table", slug: "category-1" },
          { label: "Conference Table Series", slug: "category-1" },
          { label: "Modular Workstation Series", slug: "category-1" },
          { label: "Modular Cabin Table", slug: "category-1" },
          { label: "Modular Workstation", slug: "category-1" },
        ],
      },
    ],
  },

  {
    label: "Modular Workstation Series",
    key: "category-2",
    columns: [
      {
        heading: "Modular Workstation Series",
        items: [
          // { label: 'Modular Workstation Series', slug: 'category-2' },
          { label: "Modular Cabin Table", slug: "category-2" },
          { label: "Modular Workstation", slug: "category-2" },
        ],
      },
    ],
  },

  {
    label: "Chair Series",
    key: "chairs",
    columns: [
      {
        heading: "Chair Series",
        items: [
          { label: "Chairman Chair Series", slug: "chairs" },
          { label: "Director Chair Series", slug: "chairs" },
          { label: "Executive Chair Series", slug: "chairs" },
          { label: "Manager Chair Series", slug: "chairs" },
          { label: "Director Chair MSH Series", slug: "chairs" },
          { label: "Director MSH Chair Color Series", slug: "chairs" },
          { label: "Visitor Chair Series", slug: "chairs" },
          { label: "Classroom Chair Series", slug: "chairs" },
          { label: "Institutional Restaurant Chair Series", slug: "chairs" },
          { label: "Restaurant & Bar Stool Chair Series", slug: "chairs" },
          { label: "Restaurant & Bar Chair Series", slug: "chairs" },
          { label: "Auditorium Chair Series", slug: "chairs" },
        ],
      },
    ],
  },

  {
    label: "Kid Series",
    key: "kids",
    columns: [
      {
        heading: "Kids Furniture",
        items: [
          { label: "Kid Furniture Series", slug: "kids" },
          { label: "Kid Storage Furniture Series", slug: "kids" },
        ],
      },
    ],
  },

  {
    label: "Hospital Furniture",
    key: "hospital",
    columns: [
      {
        heading: "Hospital",
        items: [
          { label: "Hospital Bed Series", slug: "hospital" },
          { label: "Patient Transfer Trolley Series", slug: "hospital" },
        ],
      },
    ],
  },

  {
    label: "Other Series",
    key: "others",
    columns: [
      {
        heading: "Others",
        items: [
          { label: "Laboratory Furniture Series", slug: "others" },
          { label: "Hostel Furniture Series", slug: "others" },
          { label: "Reception Table Series", slug: "others" },
          { label: "Waiting Chair Series", slug: "others" },
          { label: "Office Sofa Series", slug: "others" },
          { label: "Steel Furniture Series", slug: "others" },
          { label: "Storage Compactor Series", slug: "others" },
          { label: "Partition Series", slug: "others" },
          { label: "Chair Part & Accessories Series", slug: "others" },
        ],
      },
    ],
  },
];
/* ─────────────────────────────────────────────────────────────────────
   Component
───────────────────────────────────────────────────────────────────── */
export default function Navbar() {
  const { cartCount } = useCart();
  const location = useLocation();
  const navigate = useNavigate();

  const [activeMenu, setActiveMenu] = useState(null);
  const [mobileExpanded, setMobileExpanded] = useState(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [scrolled, setScrolled] = useState(false);

  const searchRef = useRef(null);
  const menuTimer = useRef(null);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 2);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    setMobileOpen(false);
    setActiveMenu(null);
  }, [location.pathname]);

  useEffect(() => {
    if (searchOpen && searchRef.current) searchRef.current.focus();
  }, [searchOpen]);

  const openMenu = (key) => {
    clearTimeout(menuTimer.current);
    setActiveMenu(key);
  };
  const closeMenu = () => {
    menuTimer.current = setTimeout(() => setActiveMenu(null), 150);
  };

  const goTo = (slug) => {
    navigate(slug ? `/?category=${encodeURIComponent(slug)}` : "/");
    setActiveMenu(null);
    setMobileOpen(false);
  };

  const handleSearch = (e) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      navigate(`/?search=${encodeURIComponent(searchQuery.trim())}`);
      setSearchOpen(false);
      setSearchQuery("");
    }
  };

  // Helper to split items into columns
  function splitIntoColumns(items, colCount = 3) {
    const columns = Array.from({ length: colCount }, () => []);
    items.forEach((item, idx) => {
      columns[idx % colCount].push(item);
    });
    return columns;
  }

  return (
    <>
      {/* Announcement Bar */}
      <div className="announcement-bar" id="announcement-bar">
        <div className="announcement-inner container">
          <span className="announcement-text">
            🎉 Free shipping on orders above ₹2,999 &nbsp;·&nbsp; Trusted by 1
            Lakh+ happy homes
          </span>
          <div className="announcement-right">
            <FiPhone size={12} />
            <span>1800-123-4567</span>
          </div>
        </div>
      </div>

      {/* Main Navbar */}
      <nav className={`navbar ${scrolled ? "scrolled" : ""}`} id="main-navbar">
        <div className="navbar-inner container">
          {/* Logo */}
          <Link to="/" className="navbar-brand" id="navbar-brand">
            <div className="brand-logo">
              <span className="brand-icon-wrap">
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                  <rect width="28" height="28" rx="6" fill="#00736A" />
                  <path
                    d="M7 20V12L14 7L21 12V20H16V15H12V20H7Z"
                    fill="white"
                  />
                </svg>
              </span>
              <span className="brand-text">FurniShop</span>
            </div>
          </Link>

          {/* Desktop Nav */}
          <div className="navbar-nav">
            {NAV_ITEMS.map((item) => {
              const hasManyProducts =
                item.columns &&
                item.columns.length === 1 &&
                item.columns[0].items.length > 6;
              const colCount = hasManyProducts
                ? 3
                : item.columns
                  ? item.columns.length
                  : 1;
              let columns = item.columns;
              if (hasManyProducts) {
                // Split products into 3 columns for better look
                const splitCols = splitIntoColumns(item.columns[0].items, 3);
                columns = splitCols.map((colItems, idx) => ({
                  heading: idx === 0 ? item.columns[0].heading : "",
                  items: colItems,
                }));
              }
              return (
                <div
                  key={item.key}
                  className="nav-item"
                  onMouseEnter={() => item.columns && openMenu(item.key)}
                  onMouseLeave={closeMenu}
                >
                  {/* Trigger */}
                  {item.columns ? (
                    <button
                      className={`nav-trigger ${activeMenu === item.key ? "active" : ""}`}
                    >
                      {item.label}
                      <FiChevronDown
                        size={13}
                        className={`nav-chevron ${activeMenu === item.key ? "rotated" : ""}`}
                      />
                    </button>
                  ) : (
                    <button
                      className={`nav-trigger ${item.highlight ? "nav-highlight" : ""}`}
                      onClick={() => goTo(item.slug ?? "")}
                    >
                      {item.label}
                    </button>
                  )}

                  {/* Multi-column mega dropdown */}
                  {item.columns && activeMenu === item.key && (
                    <div
                      className="mega-menu"
                      onMouseEnter={() => clearTimeout(menuTimer.current)}
                      onMouseLeave={closeMenu}
                    >
                      <div className="mega-menu-inner mega-menu-cols">
                        {columns.map((col, colIdx) => (
                          <div key={col.heading + colIdx} className="mega-col">
                            {col.heading && (
                              <p className="mega-col-title">{col.heading}</p>
                            )}
                            {col.items.map((child) => (
                              <button
                                key={child.label}
                                className="mega-link"
                                onClick={() => goTo(child.slug)}
                                id={`nav-${item.key}-${child.label.toLowerCase().replace(/\s+/g, "-")}`}
                              >
                                {child.label}
                              </button>
                            ))}
                          </div>
                        ))}
                      </div>
                      {/* Bottom bar */}
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
              id="search-toggle-btn"
              onClick={() => setSearchOpen(!searchOpen)}
              title="Search"
            >
              <FiSearch size={20} />
            </button>
            <button className="nav-action-btn" title="Wishlist">
              <FiHeart size={20} />
            </button>
            <button className="nav-action-btn" title="Account">
              <FiUser size={20} />
            </button>
            <Link
              to="/cart"
              className="nav-cart-btn"
              id="nav-cart-btn"
              title="Cart"
            >
              <FiShoppingBag size={20} />
              {cartCount > 0 && (
                <span className="cart-badge" id="cart-count-badge">
                  {cartCount}
                </span>
              )}
            </Link>
            <button
              className="mobile-toggle"
              id="mobile-menu-toggle"
              onClick={() => setMobileOpen(!mobileOpen)}
              aria-label="Toggle menu"
            >
              {mobileOpen ? <FiX size={22} /> : <FiMenu size={22} />}
            </button>
          </div>
        </div>

        {/* Search overlay */}
        {searchOpen && (
          <div className="search-overlay" id="search-overlay">
            <div className="search-overlay-inner container">
              <form className="search-form" onSubmit={handleSearch}>
                <FiSearch size={20} className="search-form-icon" />
                <input
                  ref={searchRef}
                  type="text"
                  placeholder="Search chairs, tables, sofas, storage..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="search-form-input"
                  id="main-search-input"
                />
                <button type="submit" className="btn-primary search-submit">
                  Search
                </button>
                <button
                  type="button"
                  className="search-close-btn"
                  onClick={() => setSearchOpen(false)}
                >
                  <FiX size={20} />
                </button>
              </form>
              <div className="search-suggestions">
                {[
                  "Mesh Chairs",
                  "Executive Tables",
                  "Office Sofas",
                  "Workstations",
                  "Storage",
                ].map((s) => (
                  <button
                    key={s}
                    className="search-suggestion-chip"
                    onClick={() => {
                      setSearchQuery(s);
                      navigate(`/?search=${s}`);
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
        <div className="mobile-drawer" id="mobile-drawer">
          <div className="mobile-drawer-header">
            <Link
              to="/"
              className="navbar-brand"
              onClick={() => setMobileOpen(false)}
            >
              <span className="brand-text">FurniShop</span>
            </Link>
            <button
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
            >
              <FiX size={22} />
            </button>
          </div>
          <div className="mobile-drawer-body">
            {NAV_ITEMS.map((item) => (
              <div key={item.key} className="mobile-nav-group">
                {item.columns ? (
                  <>
                    {/* Accordion header */}
                    <button
                      className={`mobile-nav-label mobile-accordion ${mobileExpanded === item.key ? "expanded" : ""}`}
                      onClick={() =>
                        setMobileExpanded(
                          mobileExpanded === item.key ? null : item.key,
                        )
                      }
                    >
                      <span>{item.label}</span>
                      <FiChevronDown
                        size={16}
                        className={`mobile-accordion-arrow ${mobileExpanded === item.key ? "rotated" : ""}`}
                      />
                    </button>
                    {/* Accordion content */}
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
                  </>
                ) : (
                  <button
                    className={`mobile-nav-label ${item.highlight ? "highlight" : ""}`}
                    onClick={() => goTo(item.slug ?? "")}
                  >
                    {item.label}
                  </button>
                )}
              </div>
            ))}
            <div className="mobile-drawer-divider" />
            <Link
              to="/orders"
              className="mobile-nav-label"
              onClick={() => setMobileOpen(false)}
            >
              My Orders
            </Link>
            <Link
              to="/cart"
              className="mobile-nav-label"
              onClick={() => setMobileOpen(false)}
            >
              Cart {cartCount > 0 && `(${cartCount})`}
            </Link>
          </div>
        </div>
      )}
      {mobileOpen && (
        <div className="mobile-overlay" onClick={() => setMobileOpen(false)} />
      )}
    </>
  );
}
