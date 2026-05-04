# Frontend Prompt 7 — Dealer Dashboard

## Role
You are a senior frontend engineer. Build the complete Dealer Dashboard for FurniShop — the B2B portal where approved dealers see dealer-specific pricing, their order history, account status, and the discount-allotted unit counts available to them.

---

## Context
Dealers are approved B2B partners (furniture retailers, interior designers, contractors). They:
- See dealer-specific pricing on every product (lower than retail, controlled by `discount_type='dealer'`)
- Get a count-limited dealer discount per product (e.g., "first 50 units at ₹X")
- Place bulk orders that flow through the same checkout as users but with dealer pricing
- Cannot manage products or other users — that's admin-only

The dealer experience must feel premium and B2B-grade: clean, data-dense, fast, and trustworthy. It should make the dealer feel like a valued partner, not just another customer.

**Depends on:** Frontend Prompts 1, 2, 3, 4, 5, 6 (auth, products, cart, checkout, admin patterns)
**Backend endpoints used:**
- `GET /api/products/` (JWT-authenticated → returns `effective_price` with dealer discount applied)
- `GET /api/products/{slug}/` (dealer pricing)
- `GET /api/orders/` (authenticated → returns this dealer's orders)
- `GET /api/auth/profile/` (dealer profile + dealer_status + company_name + gst_number)
- `PATCH /api/auth/profile/` (update profile)

**Permission Model:**
- Route guarded by `<RoleRoute allowedRoles={['dealer']}>`
- Only `dealer_status === 'active'` dealers see full dashboard
- `dealer_status === 'pending'` → show pending approval screen
- `dealer_status === 'rejected'` → show rejection screen with support contact

---

## Files to Create

```
frontend/src/pages/dealer/
├── DealerDashboard.jsx          # Layout shell with sidebar + nested routes
├── DealerDashboard.css
├── DealerOverview.jsx           # Stats + recent orders + featured products
├── DealerCatalog.jsx            # Product browsing with dealer pricing
├── DealerOrders.jsx             # Dealer's order history
├── DealerProfile.jsx            # Account/company details + edit
├── DealerPendingScreen.jsx      # Shown when dealer_status='pending'
└── DealerRejectedScreen.jsx     # Shown when dealer_status='rejected'

frontend/src/components/dealer/
├── DealerProductCard.jsx        # Product card with dealer pricing emphasis
├── DealerProductCard.css
├── DealerStatusBadge.jsx        # Status pill (Active / Pending / Rejected)
└── DealerStatusBadge.css
```

**Routes to add to App.jsx:**
```jsx
<Route path="/dealer" element={
  <RoleRoute allowedRoles={['dealer']}>
    <DealerDashboard />
  </RoleRoute>
}>
  <Route index element={<DealerOverview />} />
  <Route path="catalog" element={<DealerCatalog />} />
  <Route path="orders" element={<DealerOrders />} />
  <Route path="profile" element={<DealerProfile />} />
</Route>
```

---

## DealerDashboard — `src/pages/dealer/DealerDashboard.jsx`

### Layout Shell

The dashboard uses a sidebar layout similar to AdminDashboard but with a **dealer-specific accent**: a teal/gold banner at the top to visually distinguish the B2B portal.

```jsx
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { FiHome, FiBox, FiShoppingBag, FiUser, FiLogOut, FiTrendingUp } from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';
import DealerStatusBadge from '../../components/dealer/DealerStatusBadge';
import DealerPendingScreen from './DealerPendingScreen';
import DealerRejectedScreen from './DealerRejectedScreen';
import './DealerDashboard.css';

export default function DealerDashboard() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  if (user?.dealer_status === 'pending') return <DealerPendingScreen />;
  if (user?.dealer_status === 'rejected') return <DealerRejectedScreen />;

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <div className="dealer-dashboard">
      <aside className="dealer-sidebar">
        <div className="dealer-sidebar__brand">
          <h2>FurniShop</h2>
          <span className="dealer-sidebar__brand-tag">B2B Portal</span>
        </div>

        <div className="dealer-sidebar__profile">
          <div className="dealer-sidebar__avatar">
            {user?.full_name?.charAt(0).toUpperCase() || 'D'}
          </div>
          <div className="dealer-sidebar__profile-info">
            <span className="dealer-sidebar__name">{user?.full_name}</span>
            <span className="dealer-sidebar__company">{user?.dealer_company_name}</span>
            <DealerStatusBadge status={user?.dealer_status} />
          </div>
        </div>

        <nav className="dealer-sidebar__nav">
          <NavLink to="/dealer" end className="dealer-sidebar__link">
            <FiHome /> Overview
          </NavLink>
          <NavLink to="/dealer/catalog" className="dealer-sidebar__link">
            <FiBox /> Browse Catalog
          </NavLink>
          <NavLink to="/dealer/orders" className="dealer-sidebar__link">
            <FiShoppingBag /> My Orders
          </NavLink>
          <NavLink to="/dealer/profile" className="dealer-sidebar__link">
            <FiUser /> Account
          </NavLink>
        </nav>

        <div className="dealer-sidebar__footer">
          <button onClick={handleLogout} className="dealer-sidebar__logout">
            <FiLogOut /> Sign Out
          </button>
        </div>
      </aside>

      <main className="dealer-main">
        <div className="dealer-main__banner">
          <FiTrendingUp />
          <span>You're shopping at <strong>dealer prices</strong> — exclusive B2B rates apply.</span>
        </div>
        <div className="dealer-main__content">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
```

---

## DealerOverview — `src/pages/dealer/DealerOverview.jsx`

Landing page when dealer logs in. Shows stats, recent orders, and featured products with dealer pricing.

### Layout

```
┌──────────────────────────────────────────────────────────┐
│ Welcome back, {dealer_company_name}                       │
│ Your dealer account is active. Browse the catalog at      │
│ exclusive prices.                                          │
├──────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────┐ │
│ │ Total Orders│ │ Total Spent │ │ Active Disc.│ │ ...  │ │
│ │     24      │ │  ₹3.2L      │ │     12      │ │      │ │
│ └─────────────┘ └─────────────┘ └─────────────┘ └──────┘ │
├──────────────────────────────────────────────────────────┤
│ Recent Orders                          [View All →]       │
│ [Order Card] [Order Card] [Order Card]                    │
├──────────────────────────────────────────────────────────┤
│ Featured at Dealer Prices              [Browse Catalog →] │
│ [DealerProductCard] [DealerProductCard] [DealerProductCard]│
└──────────────────────────────────────────────────────────┘
```

### Implementation

```javascript
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { FiShoppingBag, FiDollarSign, FiTag, FiPackage } from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';
import { fetchOrders, fetchProducts } from '../../api';
import { formatPrice } from '../../utils/format';
import OrderCard from '../../components/OrderCard';
import DealerProductCard from '../../components/dealer/DealerProductCard';

export default function DealerOverview() {
  const { user } = useAuth();
  const [orders, setOrders] = useState([]);
  const [featured, setFeatured] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const [ordersData, productsData] = await Promise.all([
          fetchOrders(),
          fetchProducts({ ordering: '-created_at', page_size: 6 }),
        ]);
        setOrders(ordersData);
        setFeatured(productsData.results || productsData);
      } catch (err) {
        console.error('Failed to load dealer overview', err);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const totalSpent = orders
    .filter((o) => o.payment_status === 'PAID')
    .reduce((sum, o) => sum + parseFloat(o.total_amount), 0);

  const activeDiscountedProducts = featured.filter(
    (p) => p.discount_applied && p.discount_units_remaining !== 0
  ).length;

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Welcome back, {user?.dealer_company_name || user?.full_name}</h1>
        <p>Your dealer account is active. Browse the catalog at exclusive B2B prices.</p>
      </header>

      <section className="dealer-stats">
        <StatCard
          icon={<FiShoppingBag />}
          label="Total Orders"
          value={orders.length}
        />
        <StatCard
          icon={<FiDollarSign />}
          label="Total Spent"
          value={formatPrice(totalSpent)}
        />
        <StatCard
          icon={<FiTag />}
          label="Active Dealer Discounts"
          value={activeDiscountedProducts}
        />
        <StatCard
          icon={<FiPackage />}
          label="Pending Shipments"
          value={orders.filter((o) => o.order_status === 'CONFIRMED').length}
        />
      </section>

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header">
          <h2>Recent Orders</h2>
          <Link to="/dealer/orders" className="dealer-overview__link">
            View All →
          </Link>
        </div>
        {orders.length === 0 ? (
          <div className="dealer-overview__empty">
            <p>No orders yet. <Link to="/dealer/catalog">Browse the catalog →</Link></p>
          </div>
        ) : (
          <div className="dealer-overview__orders">
            {orders.slice(0, 3).map((order) => (
              <OrderCard key={order.order_id} order={order} />
            ))}
          </div>
        )}
      </section>

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header">
          <h2>Featured at Dealer Prices</h2>
          <Link to="/dealer/catalog" className="dealer-overview__link">
            Browse Full Catalog →
          </Link>
        </div>
        <div className="dealer-overview__products">
          {featured.slice(0, 4).map((product) => (
            <DealerProductCard key={product.id} product={product} />
          ))}
        </div>
      </section>
    </div>
  );
}

function StatCard({ icon, label, value }) {
  return (
    <div className="dealer-stat-card">
      <div className="dealer-stat-card__icon">{icon}</div>
      <div className="dealer-stat-card__body">
        <span className="dealer-stat-card__label">{label}</span>
        <span className="dealer-stat-card__value">{value}</span>
      </div>
    </div>
  );
}
```

---

## DealerCatalog — `src/pages/dealer/DealerCatalog.jsx`

Same product browsing experience as the public homepage but uses `DealerProductCard` instead of standard `ProductCard`. Backend automatically returns `effective_price` based on dealer JWT role, so no special API call is needed — `fetchProducts()` already returns dealer pricing for authenticated dealers.

### Layout

```
┌──────────────────────────────────────────────────────────┐
│ Dealer Catalog                                            │
│ All prices shown are exclusive B2B rates.                 │
├─────────────┬────────────────────────────────────────────┤
│  Filters    │  [Search bar................] [Sort: ▼]    │
│             │                                             │
│  Category   │  Showing 24 products                       │
│  ◯ All      │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │
│  ◯ Sofas    │  │ Card │ │ Card │ │ Card │ │ Card │      │
│  ◯ Tables   │  └──────┘ └──────┘ └──────┘ └──────┘      │
│             │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │
│  Price      │  │ Card │ │ Card │ │ Card │ │ Card │      │
│  [____]–[__]│  └──────┘ └──────┘ └──────┘ └──────┘      │
│             │                                             │
│  Material   │  [← Prev]   Page 1 of 3   [Next →]         │
│             │                                             │
│  [Reset]    │                                             │
└─────────────┴────────────────────────────────────────────┘
```

### Implementation

```javascript
import { useEffect, useState, useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import { FiSearch, FiX } from 'react-icons/fi';
import { fetchProducts, fetchCategories } from '../../api';
import DealerProductCard from '../../components/dealer/DealerProductCard';
import FilterSidebar from '../../components/FilterSidebar';

export default function DealerCatalog() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [pagination, setPagination] = useState({ count: 0, next: null, previous: null });

  const filters = useMemo(() => ({
    category: searchParams.get('category') || '',
    price_min: searchParams.get('price_min') || '',
    price_max: searchParams.get('price_max') || '',
    material: searchParams.get('material') || '',
    search: searchParams.get('search') || '',
    ordering: searchParams.get('ordering') || '-created_at',
    page: parseInt(searchParams.get('page') || '1', 10),
  }), [searchParams]);

  useEffect(() => {
    fetchCategories().then(setCategories).catch(console.error);
  }, []);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const data = await fetchProducts(filters);
        setProducts(data.results || data);
        setPagination({
          count: data.count || data.length,
          next: data.next,
          previous: data.previous,
        });
      } catch (err) {
        console.error('Failed to load catalog', err);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [filters]);

  const updateFilter = (key, value) => {
    const next = new URLSearchParams(searchParams);
    if (value) next.set(key, value);
    else next.delete(key);
    if (key !== 'page') next.delete('page');
    setSearchParams(next);
  };

  const resetFilters = () => setSearchParams({});

  return (
    <div className="dealer-catalog">
      <header className="dealer-catalog__header">
        <h1>Dealer Catalog</h1>
        <p>All prices shown reflect your exclusive B2B rates.</p>
      </header>

      <div className="dealer-catalog__layout">
        <aside className="dealer-catalog__sidebar">
          <FilterSidebar
            categories={categories}
            filters={filters}
            onChange={updateFilter}
            onReset={resetFilters}
          />
        </aside>

        <section className="dealer-catalog__results">
          <div className="dealer-catalog__toolbar">
            <div className="dealer-catalog__search">
              <FiSearch />
              <input
                type="search"
                placeholder="Search products..."
                value={filters.search}
                onChange={(e) => updateFilter('search', e.target.value)}
              />
              {filters.search && (
                <button onClick={() => updateFilter('search', '')}>
                  <FiX />
                </button>
              )}
            </div>

            <select
              value={filters.ordering}
              onChange={(e) => updateFilter('ordering', e.target.value)}
              className="dealer-catalog__sort"
            >
              <option value="-created_at">Newest First</option>
              <option value="price">Price: Low to High</option>
              <option value="-price">Price: High to Low</option>
              <option value="name">Name: A–Z</option>
            </select>
          </div>

          <div className="dealer-catalog__count">
            Showing {products.length} of {pagination.count} products
          </div>

          {loading ? (
            <div className="dealer-catalog__loading">Loading...</div>
          ) : products.length === 0 ? (
            <div className="dealer-catalog__empty">
              <p>No products match your filters.</p>
              <button onClick={resetFilters} className="btn-outline">Clear Filters</button>
            </div>
          ) : (
            <div className="dealer-catalog__grid">
              {products.map((product) => (
                <DealerProductCard key={product.id} product={product} />
              ))}
            </div>
          )}

          {(pagination.next || pagination.previous) && (
            <div className="dealer-catalog__pagination">
              <button
                disabled={!pagination.previous}
                onClick={() => updateFilter('page', String(filters.page - 1))}
                className="btn-outline"
              >
                ← Previous
              </button>
              <span>Page {filters.page}</span>
              <button
                disabled={!pagination.next}
                onClick={() => updateFilter('page', String(filters.page + 1))}
                className="btn-outline"
              >
                Next →
              </button>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
```

---

## DealerProductCard — `src/components/dealer/DealerProductCard.jsx`

A product card optimized for dealer experience. Emphasizes:
- **MRP** struck through, **Your Price** (effective_price) prominent
- **Savings** chip showing percent off MRP
- **Units remaining at dealer price** badge (when count_limit set)
- "View Details" → standard product page (`/product/:slug`)
- "Add to Cart" — same cart as users, but stored at dealer price

```javascript
import { Link } from 'react-router-dom';
import { FiShoppingCart, FiTag } from 'react-icons/fi';
import { useCart } from '../../context/CartContext';
import { formatPrice, calcDiscountPercent } from '../../utils/format';
import toast from 'react-hot-toast';
import './DealerProductCard.css';

export default function DealerProductCard({ product }) {
  const { addToCart } = useCart();

  const mrp = parseFloat(product.price);
  const yourPrice = parseFloat(product.effective_price ?? product.price);
  const hasDealerDiscount = product.discount_applied === 'dealer';
  const savings = mrp - yourPrice;
  const savingsPercent = calcDiscountPercent(mrp, yourPrice);

  const handleAddToCart = (e) => {
    e.preventDefault();
    if (!product.in_stock) return;
    addToCart(product, 1);
    toast.success(`${product.name} added to cart at dealer price.`);
  };

  return (
    <Link to={`/product/${product.slug}`} className="dealer-card">
      {hasDealerDiscount && (
        <span className="dealer-card__badge dealer-card__badge--exclusive">
          <FiTag size={12} /> Dealer Price
        </span>
      )}

      <div className="dealer-card__image-wrap">
        <img
          src={product.image_url}
          alt={product.name}
          loading="lazy"
          className="dealer-card__image"
        />
        {!product.in_stock && (
          <div className="dealer-card__out-of-stock">Out of Stock</div>
        )}
      </div>

      <div className="dealer-card__body">
        <span className="dealer-card__category">{product.category_name}</span>
        <h3 className="dealer-card__name">{product.name}</h3>
        <span className="dealer-card__meta">
          {product.material} · {product.color}
        </span>

        <div className="dealer-card__pricing">
          <div className="dealer-card__price-block">
            <span className="dealer-card__your-price-label">Your Price</span>
            <span className="dealer-card__your-price">{formatPrice(yourPrice)}</span>
          </div>
          {hasDealerDiscount && (
            <div className="dealer-card__mrp-block">
              <span className="dealer-card__mrp-label">MRP</span>
              <span className="dealer-card__mrp">{formatPrice(mrp)}</span>
              <span className="dealer-card__savings">Save {savingsPercent}%</span>
            </div>
          )}
        </div>

        {product.discount_units_remaining !== null && product.discount_units_remaining !== undefined && (
          <div className={`dealer-card__units ${
            product.discount_units_remaining === 0
              ? 'dealer-card__units--ended'
              : product.discount_units_remaining <= 10
              ? 'dealer-card__units--low'
              : ''
          }`}>
            {product.discount_units_remaining === 0
              ? 'Dealer offer ended — showing MRP'
              : `Only ${product.discount_units_remaining} units at dealer price`}
          </div>
        )}

        <button
          onClick={handleAddToCart}
          disabled={!product.in_stock}
          className="dealer-card__cta"
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

## DealerOrders — `src/pages/dealer/DealerOrders.jsx`

Order history for the dealer. Filterable by status, sortable by date. Reuses `OrderCard` component.

```javascript
import { useEffect, useState, useMemo } from 'react';
import { fetchOrders } from '../../api';
import OrderCard from '../../components/OrderCard';
import { FiSearch } from 'react-icons/fi';

const STATUS_OPTIONS = ['ALL', 'CREATED', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

export default function DealerOrders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState('ALL');
  const [search, setSearch] = useState('');

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const data = await fetchOrders();
        setOrders(data);
      } catch (err) {
        console.error('Failed to load orders', err);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const filteredOrders = useMemo(() => {
    return orders
      .filter((o) => filterStatus === 'ALL' || o.order_status === filterStatus)
      .filter((o) => !search || o.order_id.toLowerCase().includes(search.toLowerCase()));
  }, [orders, filterStatus, search]);

  const totals = useMemo(() => ({
    total: orders.length,
    paid: orders.filter((o) => o.payment_status === 'PAID').length,
    pending: orders.filter((o) => o.order_status === 'CREATED').length,
    delivered: orders.filter((o) => o.order_status === 'DELIVERED').length,
  }), [orders]);

  return (
    <div className="dealer-orders">
      <header className="dealer-orders__header">
        <h1>My Orders</h1>
        <p>Track your B2B orders, payments, and shipments.</p>
      </header>

      <div className="dealer-orders__summary">
        <div className="dealer-orders__summary-item">
          <span>Total</span><strong>{totals.total}</strong>
        </div>
        <div className="dealer-orders__summary-item">
          <span>Paid</span><strong>{totals.paid}</strong>
        </div>
        <div className="dealer-orders__summary-item">
          <span>Awaiting Payment</span><strong>{totals.pending}</strong>
        </div>
        <div className="dealer-orders__summary-item">
          <span>Delivered</span><strong>{totals.delivered}</strong>
        </div>
      </div>

      <div className="dealer-orders__toolbar">
        <div className="dealer-orders__search">
          <FiSearch />
          <input
            type="search"
            placeholder="Search by Order ID..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <div className="dealer-orders__filters">
          {STATUS_OPTIONS.map((s) => (
            <button
              key={s}
              onClick={() => setFilterStatus(s)}
              className={`dealer-orders__chip ${filterStatus === s ? 'dealer-orders__chip--active' : ''}`}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="dealer-orders__loading">Loading orders...</div>
      ) : filteredOrders.length === 0 ? (
        <div className="dealer-orders__empty">
          <p>No orders match your filters.</p>
        </div>
      ) : (
        <div className="dealer-orders__list">
          {filteredOrders.map((order) => (
            <OrderCard key={order.order_id} order={order} />
          ))}
        </div>
      )}
    </div>
  );
}
```

---

## DealerProfile — `src/pages/dealer/DealerProfile.jsx`

View and update dealer account information. GST and company name are display-only after approval (changes require admin re-approval).

```javascript
import { useState } from 'react';
import { FiEdit2, FiSave, FiX, FiCheckCircle } from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';
import { updateProfile } from '../../api';
import DealerStatusBadge from '../../components/dealer/DealerStatusBadge';
import { formatDate } from '../../utils/format';
import toast from 'react-hot-toast';

export default function DealerProfile() {
  const { user, refreshProfile } = useAuth();
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({
    full_name: user?.full_name || '',
    phone: user?.phone || '',
  });

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await updateProfile(form);
      await refreshProfile();
      toast.success('Profile updated successfully');
      setEditing(false);
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    setForm({
      full_name: user?.full_name || '',
      phone: user?.phone || '',
    });
    setEditing(false);
  };

  return (
    <div className="dealer-profile">
      <header className="dealer-profile__header">
        <h1>Account Details</h1>
        <p>Manage your dealer account and business information.</p>
      </header>

      <div className="dealer-profile__grid">
        {/* Account Status Card */}
        <div className="dealer-profile__card">
          <div className="dealer-profile__card-header">
            <h2>Dealer Status</h2>
            <DealerStatusBadge status={user?.dealer_status} />
          </div>
          <div className="dealer-profile__status-row">
            <FiCheckCircle color="var(--color-success)" />
            <div>
              <strong>Active Dealer Account</strong>
              <p>You have access to dealer pricing and discounts on all eligible products.</p>
            </div>
          </div>
          <div className="dealer-profile__meta">
            Member since: <strong>{formatDate(user?.date_joined)}</strong>
          </div>
        </div>

        {/* Personal Information Card */}
        <div className="dealer-profile__card">
          <div className="dealer-profile__card-header">
            <h2>Personal Information</h2>
            {!editing && (
              <button onClick={() => setEditing(true)} className="btn-icon">
                <FiEdit2 size={16} /> Edit
              </button>
            )}
          </div>

          {editing ? (
            <form onSubmit={handleSave} className="dealer-profile__form">
              <div className="form-field">
                <label>Full Name</label>
                <input
                  type="text"
                  value={form.full_name}
                  onChange={(e) => setForm({ ...form, full_name: e.target.value })}
                  required
                />
              </div>
              <div className="form-field">
                <label>Phone Number</label>
                <input
                  type="tel"
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                  pattern="\d{10}"
                  required
                />
              </div>
              <div className="form-field">
                <label>Email (read-only)</label>
                <input type="email" value={user?.email} disabled />
              </div>
              <div className="dealer-profile__form-actions">
                <button type="submit" className="btn-primary" disabled={saving}>
                  <FiSave size={16} /> {saving ? 'Saving...' : 'Save Changes'}
                </button>
                <button type="button" onClick={handleCancel} className="btn-outline">
                  <FiX size={16} /> Cancel
                </button>
              </div>
            </form>
          ) : (
            <dl className="dealer-profile__list">
              <div><dt>Full Name</dt><dd>{user?.full_name}</dd></div>
              <div><dt>Email</dt><dd>{user?.email}</dd></div>
              <div><dt>Phone</dt><dd>{user?.phone || '—'}</dd></div>
            </dl>
          )}
        </div>

        {/* Business Information Card */}
        <div className="dealer-profile__card dealer-profile__card--span">
          <div className="dealer-profile__card-header">
            <h2>Business Information</h2>
            <span className="dealer-profile__readonly-tag">
              Locked — contact support to update
            </span>
          </div>
          <dl className="dealer-profile__list">
            <div>
              <dt>Company Name</dt>
              <dd>{user?.dealer_company_name || '—'}</dd>
            </div>
            <div>
              <dt>GST Number</dt>
              <dd className="dealer-profile__gst">{user?.dealer_gst_number || '—'}</dd>
            </div>
          </dl>
          <p className="dealer-profile__note">
            To update your business details (company name, GST number), please contact{' '}
            <a href="mailto:dealers@furnishop.com">dealers@furnishop.com</a>.
            Changes require re-verification by our team.
          </p>
        </div>
      </div>
    </div>
  );
}
```

---

## DealerPendingScreen — `src/pages/dealer/DealerPendingScreen.jsx`

Shown when `user.dealer_status === 'pending'`. Friendly waiting screen with what to expect next.

```javascript
import { Link } from 'react-router-dom';
import { FiClock, FiMail } from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';

export default function DealerPendingScreen() {
  const { user, logout } = useAuth();

  return (
    <div className="dealer-status-screen">
      <div className="dealer-status-screen__icon dealer-status-screen__icon--pending">
        <FiClock size={64} />
      </div>
      <h1>Application Under Review</h1>
      <p className="dealer-status-screen__lead">
        Thanks for applying, <strong>{user?.dealer_company_name || user?.full_name}</strong>.
        Our team is reviewing your dealer application.
      </p>

      <div className="dealer-status-screen__details">
        <div className="dealer-status-screen__detail-row">
          <span>Status</span>
          <strong style={{ color: 'var(--color-warning)' }}>● Pending Review</strong>
        </div>
        <div className="dealer-status-screen__detail-row">
          <span>Applied On</span>
          <strong>{new Date(user?.date_joined).toLocaleDateString('en-IN', {
            day: 'numeric', month: 'long', year: 'numeric'
          })}</strong>
        </div>
        <div className="dealer-status-screen__detail-row">
          <span>Estimated Review Time</span>
          <strong>1–3 business days</strong>
        </div>
      </div>

      <div className="dealer-status-screen__next">
        <h3>What happens next?</h3>
        <ol>
          <li>Our team verifies your business details and GST number.</li>
          <li>You'll receive an email at <strong>{user?.email}</strong> once approved.</li>
          <li>After approval, you'll see exclusive dealer pricing across the catalog.</li>
        </ol>
      </div>

      <div className="dealer-status-screen__actions">
        <Link to="/" className="btn-primary">Browse as Customer</Link>
        <a href="mailto:dealers@furnishop.com" className="btn-outline">
          <FiMail size={16} /> Contact Support
        </a>
        <button onClick={logout} className="btn-text">Sign Out</button>
      </div>
    </div>
  );
}
```

---

## DealerRejectedScreen — `src/pages/dealer/DealerRejectedScreen.jsx`

Shown when `user.dealer_status === 'rejected'`. Respectful tone, clear next steps.

```javascript
import { Link } from 'react-router-dom';
import { FiAlertCircle, FiMail } from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';

export default function DealerRejectedScreen() {
  const { user, logout } = useAuth();

  return (
    <div className="dealer-status-screen">
      <div className="dealer-status-screen__icon dealer-status-screen__icon--rejected">
        <FiAlertCircle size={64} />
      </div>
      <h1>Application Not Approved</h1>
      <p className="dealer-status-screen__lead">
        Unfortunately, we were unable to approve your dealer application at this time.
      </p>

      <div className="dealer-status-screen__details">
        <p>
          This may be because of incomplete business information, an unverifiable GST number,
          or insufficient business history. We'd encourage you to review your application
          and reach out to our team for clarification.
        </p>
      </div>

      <div className="dealer-status-screen__next">
        <h3>What you can do</h3>
        <ul>
          <li>Continue shopping as a regular customer with our standard catalog.</li>
          <li>Contact our dealer team to understand why and reapply with updated information.</li>
          <li>If your business is newly established, consider reapplying after 6 months.</li>
        </ul>
      </div>

      <div className="dealer-status-screen__actions">
        <Link to="/" className="btn-primary">Continue as Customer</Link>
        <a href="mailto:dealers@furnishop.com" className="btn-outline">
          <FiMail size={16} /> Contact Dealer Team
        </a>
        <button onClick={logout} className="btn-text">Sign Out</button>
      </div>
    </div>
  );
}
```

---

## DealerStatusBadge — `src/components/dealer/DealerStatusBadge.jsx`

Reusable status pill, used in sidebar and profile.

```javascript
import './DealerStatusBadge.css';

const STATUS_CONFIG = {
  active:   { label: 'Active',   color: 'var(--color-success)', bg: 'rgba(46, 125, 50, 0.1)' },
  pending:  { label: 'Pending',  color: 'var(--color-warning)', bg: 'rgba(245, 124, 0, 0.1)' },
  rejected: { label: 'Rejected', color: 'var(--color-error)',   bg: 'rgba(198, 40, 40, 0.1)' },
};

export default function DealerStatusBadge({ status }) {
  const config = STATUS_CONFIG[status] || STATUS_CONFIG.pending;
  return (
    <span
      className="dealer-status-badge"
      style={{ color: config.color, background: config.bg }}
    >
      ● {config.label}
    </span>
  );
}
```

---

## CSS — `src/pages/dealer/DealerDashboard.css`

```css
/* ============ Layout ============ */
.dealer-dashboard {
  display: grid;
  grid-template-columns: 280px 1fr;
  min-height: 100vh;
  background: var(--color-bg);
}

@media (max-width: 900px) {
  .dealer-dashboard { grid-template-columns: 1fr; }
}

/* ============ Sidebar ============ */
.dealer-sidebar {
  background: linear-gradient(180deg, #00736A 0%, #005A52 100%);
  color: white;
  padding: 1.5rem 1rem;
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 0;
  height: 100vh;
}

.dealer-sidebar__brand {
  padding: 0 0.5rem 1.5rem;
  border-bottom: 1px solid rgba(255,255,255,0.15);
}
.dealer-sidebar__brand h2 {
  font-family: var(--font-heading);
  margin: 0;
  font-size: 1.5rem;
}
.dealer-sidebar__brand-tag {
  font-size: 0.6875rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.7);
  font-weight: 600;
}

.dealer-sidebar__profile {
  display: flex; gap: 0.75rem; align-items: center;
  padding: 1.25rem 0.5rem;
  border-bottom: 1px solid rgba(255,255,255,0.15);
}
.dealer-sidebar__avatar {
  width: 44px; height: 44px;
  border-radius: 50%;
  background: rgba(255,255,255,0.2);
  display: flex; align-items: center; justify-content: center;
  font-weight: 700; font-size: 1.125rem;
  flex-shrink: 0;
}
.dealer-sidebar__profile-info { display: flex; flex-direction: column; gap: 0.125rem; min-width: 0; }
.dealer-sidebar__name {
  font-weight: 600; font-size: 0.9375rem;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.dealer-sidebar__company {
  font-size: 0.75rem; color: rgba(255,255,255,0.7);
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}

.dealer-sidebar__nav {
  display: flex; flex-direction: column; gap: 0.25rem;
  padding: 1rem 0;
  flex: 1;
}
.dealer-sidebar__link {
  display: flex; align-items: center; gap: 0.75rem;
  padding: 0.75rem 1rem;
  border-radius: var(--radius-md);
  color: rgba(255,255,255,0.85);
  text-decoration: none;
  font-size: 0.9375rem;
  transition: background var(--transition-fast);
}
.dealer-sidebar__link:hover { background: rgba(255,255,255,0.1); color: white; }
.dealer-sidebar__link.active {
  background: rgba(255,255,255,0.15);
  color: white;
  font-weight: 600;
}

.dealer-sidebar__footer { padding-top: 1rem; border-top: 1px solid rgba(255,255,255,0.15); }
.dealer-sidebar__logout {
  display: flex; align-items: center; gap: 0.75rem;
  width: 100%; padding: 0.75rem 1rem;
  background: transparent; color: rgba(255,255,255,0.85);
  border: 1px solid rgba(255,255,255,0.2);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--transition-fast);
}
.dealer-sidebar__logout:hover { background: rgba(255,255,255,0.1); color: white; }

/* ============ Main ============ */
.dealer-main { display: flex; flex-direction: column; min-width: 0; }
.dealer-main__banner {
  display: flex; align-items: center; gap: 0.5rem;
  padding: 0.625rem 2rem;
  background: linear-gradient(90deg, #FFF8E1 0%, #FFF3CC 100%);
  border-bottom: 1px solid #F0DC8A;
  font-size: 0.875rem;
  color: #6B5400;
}
.dealer-main__banner svg { color: #B58900; flex-shrink: 0; }
.dealer-main__content { padding: 2rem; flex: 1; max-width: 1280px; width: 100%; }

/* ============ Overview ============ */
.dealer-overview__header { margin-bottom: 2rem; }
.dealer-overview__header h1 { font-family: var(--font-heading); font-size: 2rem; margin: 0 0 0.5rem; }
.dealer-overview__header p { color: var(--color-text-muted); margin: 0; }

.dealer-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
  margin-bottom: 2.5rem;
}
.dealer-stat-card {
  display: flex; gap: 1rem; align-items: center;
  background: white;
  padding: 1.25rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
}
.dealer-stat-card__icon {
  width: 48px; height: 48px;
  background: rgba(0, 115, 106, 0.1);
  border-radius: var(--radius-md);
  display: flex; align-items: center; justify-content: center;
  color: var(--color-primary);
}
.dealer-stat-card__body { display: flex; flex-direction: column; }
.dealer-stat-card__label { font-size: 0.8125rem; color: var(--color-text-muted); }
.dealer-stat-card__value { font-size: 1.5rem; font-weight: 700; color: var(--color-text); }

.dealer-overview__section { margin-bottom: 2.5rem; }
.dealer-overview__section-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 1rem;
}
.dealer-overview__section-header h2 { font-family: var(--font-heading); margin: 0; font-size: 1.375rem; }
.dealer-overview__link { color: var(--color-primary); font-weight: 600; text-decoration: none; }
.dealer-overview__orders { display: flex; flex-direction: column; gap: 1rem; }
.dealer-overview__products {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1.25rem;
}
.dealer-overview__empty {
  background: white;
  padding: 2rem;
  border-radius: var(--radius-lg);
  text-align: center;
  color: var(--color-text-muted);
}

/* ============ Catalog ============ */
.dealer-catalog__header { margin-bottom: 2rem; }
.dealer-catalog__header h1 { font-family: var(--font-heading); font-size: 2rem; margin: 0 0 0.5rem; }
.dealer-catalog__header p { color: var(--color-text-muted); margin: 0; }

.dealer-catalog__layout {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: 2rem;
}
@media (max-width: 900px) {
  .dealer-catalog__layout { grid-template-columns: 1fr; }
}

.dealer-catalog__toolbar {
  display: flex; gap: 1rem; align-items: center;
  margin-bottom: 1rem;
}
.dealer-catalog__search {
  flex: 1;
  display: flex; align-items: center; gap: 0.5rem;
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 0.625rem 0.875rem;
}
.dealer-catalog__search input {
  flex: 1; border: none; background: transparent; outline: none;
  font-size: 0.9375rem;
}
.dealer-catalog__sort {
  padding: 0.625rem 0.875rem;
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: 0.875rem;
}

.dealer-catalog__count { color: var(--color-text-muted); font-size: 0.875rem; margin-bottom: 1rem; }
.dealer-catalog__grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1.25rem;
}
.dealer-catalog__pagination {
  display: flex; gap: 1rem; justify-content: center; align-items: center;
  margin-top: 2rem;
}
.dealer-catalog__empty, .dealer-catalog__loading {
  background: white; padding: 3rem; border-radius: var(--radius-lg);
  text-align: center; color: var(--color-text-muted);
}

/* ============ Orders ============ */
.dealer-orders__header { margin-bottom: 2rem; }
.dealer-orders__header h1 { font-family: var(--font-heading); font-size: 2rem; margin: 0 0 0.5rem; }
.dealer-orders__header p { color: var(--color-text-muted); margin: 0; }

.dealer-orders__summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}
.dealer-orders__summary-item {
  background: white;
  padding: 1rem 1.25rem;
  border-radius: var(--radius-md);
  display: flex; flex-direction: column; gap: 0.25rem;
}
.dealer-orders__summary-item span { font-size: 0.8125rem; color: var(--color-text-muted); }
.dealer-orders__summary-item strong { font-size: 1.5rem; color: var(--color-text); }

.dealer-orders__toolbar {
  display: flex; gap: 1rem; flex-wrap: wrap;
  margin-bottom: 1.5rem;
}
.dealer-orders__search {
  flex: 1; min-width: 240px;
  display: flex; align-items: center; gap: 0.5rem;
  background: white; border: 1px solid var(--color-border);
  border-radius: var(--radius-md); padding: 0.625rem 0.875rem;
}
.dealer-orders__search input { flex: 1; border: none; background: transparent; outline: none; }

.dealer-orders__filters { display: flex; gap: 0.5rem; flex-wrap: wrap; }
.dealer-orders__chip {
  padding: 0.5rem 0.875rem;
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-pill);
  font-size: 0.8125rem; font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);
}
.dealer-orders__chip:hover { border-color: var(--color-primary); }
.dealer-orders__chip--active {
  background: var(--color-primary); color: white; border-color: var(--color-primary);
}

.dealer-orders__list { display: flex; flex-direction: column; gap: 1rem; }
.dealer-orders__empty, .dealer-orders__loading {
  background: white; padding: 3rem; border-radius: var(--radius-lg);
  text-align: center; color: var(--color-text-muted);
}

/* ============ Profile ============ */
.dealer-profile__header { margin-bottom: 2rem; }
.dealer-profile__header h1 { font-family: var(--font-heading); font-size: 2rem; margin: 0 0 0.5rem; }
.dealer-profile__header p { color: var(--color-text-muted); margin: 0; }

.dealer-profile__grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
}
@media (max-width: 900px) { .dealer-profile__grid { grid-template-columns: 1fr; } }

.dealer-profile__card {
  background: white;
  padding: 1.5rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
}
.dealer-profile__card--span { grid-column: 1 / -1; }
.dealer-profile__card-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 1.25rem;
}
.dealer-profile__card-header h2 { font-family: var(--font-heading); font-size: 1.25rem; margin: 0; }

.dealer-profile__status-row {
  display: flex; gap: 1rem; align-items: flex-start;
  padding: 1rem;
  background: rgba(46, 125, 50, 0.05);
  border-radius: var(--radius-md);
  margin-bottom: 1rem;
}
.dealer-profile__status-row strong { display: block; margin-bottom: 0.25rem; }
.dealer-profile__status-row p { margin: 0; color: var(--color-text-muted); font-size: 0.875rem; }
.dealer-profile__meta { font-size: 0.8125rem; color: var(--color-text-muted); }

.dealer-profile__list { margin: 0; padding: 0; }
.dealer-profile__list > div {
  display: flex; justify-content: space-between;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--color-border);
}
.dealer-profile__list > div:last-child { border-bottom: none; }
.dealer-profile__list dt { color: var(--color-text-muted); font-size: 0.875rem; }
.dealer-profile__list dd { margin: 0; font-weight: 500; }
.dealer-profile__gst { font-family: monospace; }

.dealer-profile__readonly-tag {
  font-size: 0.75rem;
  background: var(--color-bg);
  padding: 0.25rem 0.625rem;
  border-radius: var(--radius-pill);
  color: var(--color-text-muted);
}
.dealer-profile__note {
  margin-top: 1rem; font-size: 0.8125rem; color: var(--color-text-muted);
}

.dealer-profile__form { display: flex; flex-direction: column; gap: 1rem; }
.dealer-profile__form-actions {
  display: flex; gap: 0.75rem; margin-top: 0.5rem;
}

/* ============ Status Screens (Pending / Rejected) ============ */
.dealer-status-screen {
  max-width: 600px;
  margin: 4rem auto;
  padding: 2.5rem;
  background: white;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  text-align: center;
}
.dealer-status-screen__icon {
  width: 100px; height: 100px;
  margin: 0 auto 1.5rem;
  display: flex; align-items: center; justify-content: center;
  border-radius: 50%;
}
.dealer-status-screen__icon--pending { background: rgba(245, 124, 0, 0.1); color: var(--color-warning); }
.dealer-status-screen__icon--rejected { background: rgba(198, 40, 40, 0.1); color: var(--color-error); }

.dealer-status-screen h1 { font-family: var(--font-heading); margin: 0 0 1rem; }
.dealer-status-screen__lead { color: var(--color-text-muted); margin-bottom: 2rem; }

.dealer-status-screen__details {
  background: var(--color-bg);
  padding: 1.25rem;
  border-radius: var(--radius-md);
  margin-bottom: 1.5rem;
  text-align: left;
}
.dealer-status-screen__detail-row {
  display: flex; justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border);
}
.dealer-status-screen__detail-row:last-child { border-bottom: none; }

.dealer-status-screen__next { text-align: left; margin-bottom: 2rem; }
.dealer-status-screen__next h3 { font-family: var(--font-heading); margin: 0 0 0.75rem; }
.dealer-status-screen__next ol,
.dealer-status-screen__next ul { padding-left: 1.25rem; color: var(--color-text-muted); line-height: 1.7; }

.dealer-status-screen__actions {
  display: flex; gap: 0.75rem; justify-content: center; flex-wrap: wrap;
}

/* ============ Status Badge ============ */
.dealer-status-badge {
  display: inline-flex; align-items: center; gap: 0.25rem;
  padding: 0.25rem 0.625rem;
  border-radius: var(--radius-pill);
  font-size: 0.6875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  width: fit-content;
}
```

---

## CSS — `src/components/dealer/DealerProductCard.css`

```css
.dealer-card {
  position: relative;
  display: flex;
  flex-direction: column;
  background: white;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  transition: transform var(--transition-base), box-shadow var(--transition-base);
  text-decoration: none;
  color: inherit;
}
.dealer-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.dealer-card__badge {
  position: absolute;
  top: 0.75rem;
  left: 0.75rem;
  z-index: 2;
  display: flex; align-items: center; gap: 0.25rem;
  padding: 0.25rem 0.625rem;
  border-radius: var(--radius-pill);
  font-size: 0.6875rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.dealer-card__badge--exclusive {
  background: linear-gradient(90deg, #B58900 0%, #D4A017 100%);
  color: white;
}

.dealer-card__image-wrap {
  position: relative;
  aspect-ratio: 1 / 1;
  background: var(--color-bg);
  overflow: hidden;
}
.dealer-card__image {
  width: 100%; height: 100%;
  object-fit: cover;
  transition: transform var(--transition-base);
}
.dealer-card:hover .dealer-card__image { transform: scale(1.05); }

.dealer-card__out-of-stock {
  position: absolute; inset: 0;
  background: rgba(0,0,0,0.5);
  color: white;
  display: flex; align-items: center; justify-content: center;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.dealer-card__body { padding: 1rem; display: flex; flex-direction: column; gap: 0.5rem; }
.dealer-card__category {
  font-size: 0.6875rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--color-text-muted);
  font-weight: 600;
}
.dealer-card__name {
  font-family: var(--font-heading);
  font-size: 1rem;
  margin: 0;
  font-weight: 600;
  line-height: 1.3;
}
.dealer-card__meta {
  font-size: 0.8125rem;
  color: var(--color-text-muted);
}

.dealer-card__pricing {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding: 0.5rem 0;
  border-top: 1px solid var(--color-border);
}
.dealer-card__price-block { display: flex; flex-direction: column; }
.dealer-card__your-price-label {
  font-size: 0.6875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-primary);
  font-weight: 700;
}
.dealer-card__your-price {
  font-size: 1.375rem;
  font-weight: 700;
  color: var(--color-text);
}
.dealer-card__mrp-block {
  display: flex; gap: 0.5rem; align-items: center;
  font-size: 0.8125rem;
}
.dealer-card__mrp-label { color: var(--color-text-muted); }
.dealer-card__mrp { text-decoration: line-through; color: var(--color-text-muted); }
.dealer-card__savings {
  background: rgba(46, 125, 50, 0.1);
  color: var(--color-success);
  font-weight: 700;
  padding: 0.125rem 0.5rem;
  border-radius: var(--radius-pill);
  font-size: 0.75rem;
}

.dealer-card__units {
  font-size: 0.75rem;
  padding: 0.375rem 0.625rem;
  border-radius: var(--radius-sm);
  background: rgba(0, 115, 106, 0.08);
  color: var(--color-primary);
  font-weight: 500;
}
.dealer-card__units--low {
  background: rgba(245, 124, 0, 0.1);
  color: var(--color-warning);
}
.dealer-card__units--ended {
  background: var(--color-bg);
  color: var(--color-text-muted);
}

.dealer-card__cta {
  display: flex; align-items: center; justify-content: center; gap: 0.5rem;
  width: 100%;
  padding: 0.625rem;
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: background var(--transition-fast);
  margin-top: 0.5rem;
}
.dealer-card__cta:hover:not(:disabled) { background: var(--color-primary-dark); }
.dealer-card__cta:disabled { opacity: 0.5; cursor: not-allowed; }
```

---

## API additions — `src/api/index.js`

Add the `updateProfile` function used by `DealerProfile.jsx`:

```javascript
export const updateProfile = async (data) => {
  const res = await api.patch('/auth/profile/', data);
  return res.data;
};
```

`AuthContext` should expose a `refreshProfile()` method that calls `GET /api/auth/profile/` and updates the `user` state. If not present, add it:

```javascript
// In AuthContext.jsx
const refreshProfile = async () => {
  try {
    const profile = await fetchProfile();
    setUser(profile);
    return profile;
  } catch (err) {
    console.error('Failed to refresh profile', err);
  }
};

// Expose in context value:
value={{ user, login, logout, loginFromTokens, refreshProfile, loading }}
```

---

## Navbar Update for Dealers

In the existing `Navbar.jsx`, add a "Dealer Portal" link in the user menu when `user.role === 'dealer'`:

```jsx
{user?.role === 'dealer' && (
  <Link to="/dealer" className="navbar__menu-item">
    <FiTrendingUp /> Dealer Portal
  </Link>
)}
{user?.role === 'admin' && (
  <Link to="/admin" className="navbar__menu-item">
    <FiSettings /> Admin Dashboard
  </Link>
)}
```

---

## Acceptance Criteria

**Routing & Access Control:**
- [ ] `/dealer` is only accessible to authenticated users with `role === 'dealer'`
- [ ] Non-dealers redirected to `/` with toast error
- [ ] `dealer_status === 'pending'` shows DealerPendingScreen, not main dashboard
- [ ] `dealer_status === 'rejected'` shows DealerRejectedScreen
- [ ] All sub-routes (`/dealer/catalog`, `/dealer/orders`, `/dealer/profile`) work

**Dashboard Layout:**
- [ ] Sidebar shows brand, profile (avatar, name, company, status), nav links, sign-out
- [ ] B2B portal banner visible at the top of every dealer page
- [ ] Active nav link is highlighted
- [ ] Layout responsive: sidebar collapses on mobile

**Overview Page:**
- [ ] Welcome message shows dealer's company name
- [ ] Four stat cards show real data (total orders, total spent, active discounts, pending shipments)
- [ ] "Recent Orders" shows last 3 with OrderCard components
- [ ] "Featured at Dealer Prices" shows 4 DealerProductCards
- [ ] Empty states handled (no orders, no products)

**Catalog Page:**
- [ ] Products fetched with JWT — backend returns `effective_price` with dealer discount
- [ ] FilterSidebar (category, price range, material, sort) works with URL sync
- [ ] Search bar filters by name/description
- [ ] Pagination Previous/Next works
- [ ] DealerProductCard shows: Your Price (prominent), MRP (struck through), Save X%, units remaining badge
- [ ] "Add to Cart" works — item stored at dealer price (via backend's effective_price)

**Orders Page:**
- [ ] Auto-loads dealer's orders from `GET /api/orders/`
- [ ] 4 summary cards (total, paid, pending, delivered) computed correctly
- [ ] Status filter chips (ALL, CREATED, CONFIRMED, SHIPPED, DELIVERED, CANCELLED) filter the list
- [ ] Search by Order ID works
- [ ] Empty state when no orders match filters

**Profile Page:**
- [ ] Three cards: Dealer Status, Personal Info (editable), Business Info (read-only)
- [ ] "Edit" toggles personal info form
- [ ] Save calls `PATCH /api/auth/profile/`, refreshes user, shows toast
- [ ] Cancel discards form changes
- [ ] Email field is disabled (cannot be changed)
- [ ] GST + company name shown read-only with note about contacting support

**Pending/Rejected Screens:**
- [ ] Pending screen shows dealer's name/company, application date, est review time, next steps
- [ ] Rejected screen explains possible reasons and next actions
- [ ] Both have clear actions: Continue browsing, Contact support, Sign out

**Visual & Branding:**
- [ ] Sidebar uses teal gradient (var(--color-primary) based)
- [ ] B2B Portal tag and gold "Dealer Price" badge visually distinguish from public site
- [ ] DealerProductCard emphasizes pricing differently from regular ProductCard ("Your Price" label, savings chip)
- [ ] All pages match the premium, clean aesthetic of the rest of the site

**Edge Cases:**
- [ ] Token expiration during dealer session triggers refresh, no logout
- [ ] If dealer's status changes mid-session (e.g., admin rejects), next API call returns updated profile, status screen shown on reload
- [ ] Cart works with mixed pricing (if dealer adds product, then logs out, prices update on cart re-fetch)
- [ ] Out-of-stock products in catalog are visibly disabled

---

## Notes for Implementation

- **Reuse patterns from AdminDashboard** (Frontend Prompt 6): same sidebar shell pattern, same `Outlet` nested routing approach, similar CSS class naming conventions.
- **Reuse OrderCard, FilterSidebar** from earlier prompts — no need to recreate.
- The dealer's "Your Price" is the same field (`product.effective_price`) used everywhere — backend determines pricing based on JWT role. Frontend just renders what it gets.
- The `discount_units_remaining` field reflects this dealer's pricing tier — when it hits 0, the dealer sees `effective_price === price` (MRP) and the badge shows "Dealer offer ended".
- All product images, names, and metadata are shared across user/dealer/admin views — only pricing differs.

This completes the 15-prompt series. The full website can now be built in sequence: backend prompts 1–8 followed by frontend prompts 1–7.
