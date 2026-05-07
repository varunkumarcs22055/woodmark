# Frontend Prompt 6 — Admin Dashboard (Full Custom Panel)

## Role
You are a senior frontend engineer. Build the complete custom Admin Dashboard for FurniShop — a React single-page admin panel accessible at `/admin-dashboard`. This replaces reliance on Django Admin for day-to-day operations and provides a beautiful, functional UI for managing products, discounts, orders, dealers, and ERP sync status.

**Use Claude Design for all UI mockups. Build with production-level code.**

---

## Context
This is the most complex frontend prompt. The Admin Dashboard is a nested React application with sidebar navigation and multiple management sections. Admins can: manage products (CRUD), manage discounts (user and dealer tiers), view and update orders, approve/reject dealer applications, and monitor ERP sync status.

**Depends on:** Frontend Prompts 1–5 (auth, CartContext, API layer, design system)
**Requires:** Admin JWT token (role='admin') — all API calls require `Authorization: Bearer <token>`
**Backend endpoints used:**
- `GET/POST /api/products/admin/`
- `PUT/DELETE /api/products/admin/{id}/`
- `GET /api/products/categories/`
- `GET/POST /api/discounts/`
- `PUT/DELETE /api/discounts/{id}/`
- `GET /api/orders/all/`
- `PATCH /api/orders/{id}/status/`
- `POST /api/orders/{id}/retry-erp/`
- `GET /api/auth/users/?role=dealer&dealer_status=pending`
- `PATCH /api/auth/dealers/{id}/approve/`

---

## Files to Create

```
frontend/src/pages/
├── AdminDashboard.jsx         ← Main layout + routing
└── admin/
    ├── AdminOverview.jsx      ← Dashboard overview cards
    ├── AdminProducts.jsx      ← Product management
    ├── AdminDiscounts.jsx     ← Discount management
    ├── AdminOrders.jsx        ← Order management
    ├── AdminDealers.jsx       ← Dealer management
    └── AdminERP.jsx           ← ERP sync status

frontend/src/pages/AdminDashboard.css
frontend/src/pages/admin/AdminPanel.css
```

---

## AdminDashboard — Layout & Routing — `src/pages/AdminDashboard.jsx`

```javascript
import { Routes, Route, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  FiGrid, FiPackage, FiTag, FiShoppingBag,
  FiUsers, FiRefreshCw, FiLogOut, FiMenu, FiX
} from 'react-icons/fi';

const NAV_ITEMS = [
  { path: '', label: 'Overview', icon: <FiGrid /> },
  { path: 'products', label: 'Products', icon: <FiPackage /> },
  { path: 'discounts', label: 'Discounts', icon: <FiTag /> },
  { path: 'orders', label: 'Orders', icon: <FiShoppingBag /> },
  { path: 'dealers', label: 'Dealers', icon: <FiUsers /> },
  { path: 'erp', label: 'ERP Status', icon: <FiRefreshCw /> },
];

export default function AdminDashboard() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <div className="admin-layout">
      {/* Sidebar */}
      <aside className={`admin-sidebar ${sidebarOpen ? 'admin-sidebar--open' : ''}`}>
        <div className="admin-sidebar__header">
          <span className="admin-sidebar__logo">FurniShop Admin</span>
          <button className="admin-sidebar__close" onClick={() => setSidebarOpen(false)}>
            <FiX />
          </button>
        </div>

        <nav className="admin-nav">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === ''}
              className={({ isActive }) =>
                `admin-nav__item ${isActive ? 'admin-nav__item--active' : ''}`
              }
              onClick={() => setSidebarOpen(false)}
            >
              {item.icon}
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>
        <div className="admin-sidebar__footer">
          <div className="admin-user">
            <span className="admin-user__email">{user?.email}</span>
            <span className="admin-user__role">Administrator</span>
          </div>
          <button className="admin-logout" onClick={handleLogout}>
            <FiLogOut /> Logout
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <div className="admin-main">
        <header className="admin-topbar">
          <button className="admin-menu-toggle" onClick={() => setSidebarOpen(true)}>
            <FiMenu />
          </button>
          <h1 className="admin-topbar__title">Admin Dashboard</h1>
        </header>

        <div className="admin-content">
          <Routes>
            <Route index element={<AdminOverview />} />
            <Route path="products" element={<AdminProducts />} />
            <Route path="discounts" element={<AdminDiscounts />} />
            <Route path="orders" element={<AdminOrders />} />
            <Route path="dealers" element={<AdminDealers />} />
            <Route path="erp" element={<AdminERP />} />
          </Routes>
        </div>
      </div>

      {/* Mobile overlay */}
      {sidebarOpen && (
        <div className="admin-overlay" onClick={() => setSidebarOpen(false)} />
      )}
    </div>
  );
}
```

---

## AdminOverview — `src/pages/admin/AdminOverview.jsx`

Stats cards at the top:
```javascript
const [stats, setStats] = useState({
  totalProducts: 0,
  totalOrders: 0,
  pendingOrders: 0,
  failedERPSyncs: 0,
  pendingDealers: 0,
  totalRevenue: 0,
});

useEffect(() => {
  // Load counts from APIs in parallel
  Promise.all([
    fetchAllOrders({ page_size: 1 }),
    fetchAllOrders({ payment_status: 'PENDING', page_size: 1 }),
    fetchAllOrders({ erp_sync_status: 'failed', page_size: 1 }),
    // ...
  ]).then(([orders, pendingOrders, failedERP]) => {
    setStats({
      totalOrders: orders.count,
      pendingOrders: pendingOrders.count,
      failedERPSyncs: failedERP.count,
    });
  });
}, []);
```

Stat cards to render:
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Total Products  │  │ Total Orders    │  │ Pending Orders  │  │ ERP Sync Fails  │
│ 16              │  │ 142             │  │ 3               │  │ 1               │
│ ↑ View          │  │ ↑ View          │  │ Needs action    │  │ Needs retry     │
└─────────────────┘  └─────────────────┘  └─────────────────┘  └─────────────────┘
```

Below stats: "Recent Orders" table (last 10 orders) and "Low Stock Alert" table (products with stock ≤ 5).

---

## AdminProducts — `src/pages/admin/AdminProducts.jsx`

Full product CRUD interface:

### Product Table
```
┌──────────────────────────────────────────────────────────────────────────┐
│ Products                                     [+ Add Product]             │
│ Search: [__________] Category: [All ▼] Material: [All ▼]               │
├──────────┬────────────────────┬──────────┬────────┬────────┬────────────┤
│ Image    │ Name               │ Category │ Price  │ Stock  │ Actions    │
├──────────┼────────────────────┼──────────┼────────┼────────┼────────────┤
│ [img]    │ Oslo Velvet Sofa   │ Sofas    │₹45,999 │ 15     │ [Edit][Del]│
│ [img]    │ Nordic Dining Set  │ Dining   │₹84,999 │  5 ⚠️  │ [Edit][Del]│
└──────────┴────────────────────┴──────────┴────────┴────────┴────────────┘
```

Stock warning: show ⚠️ icon and red color for stock ≤ 5.

### Add/Edit Product Modal
Full-screen overlay modal with all product fields:

```javascript
const [modal, setModal] = useState({ open: false, product: null });

// Form state for add/edit
const [productForm, setProductForm] = useState({
  name: '', description: '', price: '', category: '',
  material: '', color: '', dimensions: '', image_url: '', stock: 0,
  is_featured: false,
});

const handleSave = async () => {
  try {
    if (modal.product) {
      await updateProduct(modal.product.id, productForm);
      toast.success('Product updated.');
    } else {
      await createProduct(productForm);
      toast.success('Product created.');
    }
    setModal({ open: false, product: null });
    loadProducts();
  } catch (err) {
    // Show field errors
    toast.error('Failed to save product.');
  }
};
```

Modal fields:
- **Name:** text input (auto-generates slug preview below)
- **Description:** textarea (min 4 rows)
- **Price:** number input with ₹ prefix
- **Category:** select dropdown (loaded from API)
- **Material:** select dropdown (8 choices)
- **Color:** text input
- **Dimensions:** text input (placeholder: "220x85x80 cm")
- **Image URL:** text input + live preview image on the right
- **Stock:** number input (min 0)
- **Is Featured:** toggle switch

### Delete Confirmation
```javascript
const handleDelete = (product) => {
  if (window.confirm(`Delete "${product.name}"? This cannot be undone.`)) {
    deleteProduct(product.id)
      .then(() => { toast.success('Product deleted.'); loadProducts(); })
      .catch(() => toast.error('Cannot delete — product may have existing orders.'));
  }
};
```

---

## AdminDiscounts — `src/pages/admin/AdminDiscounts.jsx`

The discount management panel. Two tabs: "User Discounts" and "Dealer Discounts".

### Layout
```
┌──────────────────────────────────────────────────────────────────────────┐
│ Discount Manager                                                          │
│ [User Discounts]  [Dealer Discounts]  ← Active tab underlined           │
│ ──────────────────────────────────────────────────────────────────────── │
│  Add New Discount:                                                        │
│  Product: [Search & select product ▼] (live search combobox)             │
│  Mode: (●) Percentage (%) ○ Flat Amount (₹)                              │
│  Value: [15         ]   Count Limit: [100] (blank = unlimited)           │
│  Active From: [2026-05-01]  Until: [2026-12-31] (optional)              │
│                                               [Save Discount]            │
│ ──────────────────────────────────────────────────────────────────────── │
│  Active Discounts:                                                        │
│  Product      │ Mode │ Value │ Limit │ Used │ Left │ Expires │ Actions  │
│  Oslo Sofa    │  %   │  15   │  100  │  23  │  77  │ Dec 31  │ [E] [D] │
│  Nordic Desk  │  ₹   │ 3000  │   50  │  50  │   0  │  —      │ [E] [D] │
└──────────────────────────────────────────────────────────────────────────┘
```

### Product Search Combobox (key feature)
```javascript
const [productSearch, setProductSearch] = useState('');
const [productOptions, setProductOptions] = useState([]);
const [selectedProduct, setSelectedProduct] = useState(null);

// Debounced search
useEffect(() => {
  if (productSearch.length < 2) { setProductOptions([]); return; }
  const timeout = setTimeout(async () => {
    const data = await fetchProducts({ search: productSearch, page_size: 10 });
    setProductOptions(data.results);
  }, 300);
  return () => clearTimeout(timeout);
}, [productSearch]);
```

Render the combobox:
```jsx
<div className="product-combobox">
  <input
    type="text"
    value={selectedProduct ? selectedProduct.name : productSearch}
    onChange={(e) => {
      setProductSearch(e.target.value);
      setSelectedProduct(null);
    }}
    placeholder="Search products by name…"
    className="product-combobox__input"
  />
  {productOptions.length > 0 && !selectedProduct && (
    <div className="product-combobox__dropdown">
      {productOptions.map((p) => (
        <button
          key={p.id}
          className="product-combobox__option"
          onClick={() => {
            setSelectedProduct(p);
            setProductOptions([]);
            setProductSearch('');
          }}
        >
          <img src={p.image_url} alt={p.name} width={32} height={32} />
          <div>
            <span className="product-combobox__name">{p.name}</span>
            <span className="product-combobox__price">{formatPrice(p.price)}</span>
          </div>
        </button>
      ))}
    </div>
  )}
</div>
```

### Discount Table
Show remaining units with color coding:
- 0 remaining: red badge "Exhausted"
- 1–10 remaining: orange badge "X left"
- 11+ remaining: green badge "X left"
- Null (unlimited): "∞ Unlimited" badge

---

## AdminOrders — `src/pages/admin/AdminOrders.jsx`

### Filterable Order Table
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Orders                          Search: [___________]                        │
│ Status: [All ▼]  Payment: [All ▼]  ERP: [All ▼]                           │
├──────────────┬─────────────────┬──────────────┬────────┬──────────┬────────┤
│ Order ID     │ Customer        │ Total        │ Status │ ERP      │ Actions│
├──────────────┼─────────────────┼──────────────┼────────┼──────────┼────────┤
│ ORD-A3F2B91C │ Priya Sharma    │ ₹45,999      │SHIPPED │ Synced   │ [View] │
│ ORD-B7C1D2E3 │ Raj Kumar       │ ₹28,999      │CONFIRM │ Failed⚠️ │[View][↻]│
└──────────────┴─────────────────┴──────────────┴────────┴──────────┴────────┘
```

### Order Detail Drawer (slide-in panel)
Clicking "View" opens a side drawer showing:
- Full order details (customer info, address, items with images)
- Payment info (Razorpay IDs if available)
- ERP sync status + retry button if failed
- Order status dropdown (admin can change status)

```javascript
const handleStatusChange = async (orderId, newStatus) => {
  try {
    await updateOrderStatus(orderId, newStatus);
    toast.success(`Order status updated to ${newStatus}`);
    loadOrders();
  } catch {
    toast.error('Failed to update status.');
  }
};

const handleERPRetry = async (orderId) => {
  try {
    const result = await retryERPSync(orderId);
    toast.success(`ERP synced. ERP ID: ${result.erp_order_id}`);
    loadOrders();
  } catch {
    toast.error('ERP retry failed. Check server logs.');
  }
};
```

---

## AdminDealers — `src/pages/admin/AdminDealers.jsx`

Two sections: "Pending Applications" and "Active Dealers".

### Pending Applications
```
┌─────────────────────────────────────────────────────────────────────┐
│ Pending Dealer Applications (3)                                      │
├──────────────┬──────────────────┬──────────────────────────┬────────┤
│ Name         │ Email            │ Company                  │ Action │
├──────────────┼──────────────────┼──────────────────────────┼────────┤
│ Arjun Mehta  │ arjun@acme.com   │ Acme Furniture Co.       │[✓][✗]  │
│ Riya Patel   │ riya@spaces.com  │ Creative Spaces Pvt Ltd  │[✓][✗]  │
└──────────────┴──────────────────┴──────────────────────────┴────────┘
```

```javascript
const handleApprove = async (userId) => {
  try {
    await approveDealer(userId, 'active');
    toast.success('Dealer approved! They can now access dealer pricing.');
    loadDealers();
  } catch { toast.error('Approval failed.'); }
};

const handleReject = async (userId) => {
  if (!window.confirm('Reject this dealer application?')) return;
  try {
    await approveDealer(userId, 'rejected');
    toast.success('Dealer application rejected.');
    loadDealers();
  } catch { toast.error('Rejection failed.'); }
};
```

---

## AdminERP — `src/pages/admin/AdminERP.jsx`

```
┌────────────────────────────────────────────────────────────────────────┐
│ ERP Sync Status                                                         │
│ Synced: 138  │  Pending: 2  │  Failed: 3                               │
├──────────────┬─────────────────┬──────────────────────┬───────────────┤
│ Order ID     │ Customer Email  │ ERP Order ID         │ Status        │
├──────────────┼─────────────────┼──────────────────────┼───────────────┤
│ ORD-A3F2...  │ priya@test.com  │ ERP-SIM-ORD-A3F2...  │ ✓ Synced      │
│ ORD-B7C1...  │ raj@test.com    │ —                    │ ✗ Failed [↻]  │
└──────────────┴─────────────────┴──────────────────────┴───────────────┘
```

---

## CSS — Key Admin Styles — `src/pages/AdminDashboard.css`

```css
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: #F4F6FA;
}

.admin-sidebar {
  width: 260px; flex-shrink: 0;
  background: #1A1A1A; color: white;
  display: flex; flex-direction: column;
  position: fixed; top: 0; left: 0; bottom: 0;
  z-index: 100;
  transition: transform var(--transition-slow);
}

@media (max-width: 900px) {
  .admin-sidebar { transform: translateX(-100%); }
  .admin-sidebar--open { transform: translateX(0); }
  .admin-overlay {
    position: fixed; inset: 0;
    background: rgba(0,0,0,0.5); z-index: 99;
  }
}

.admin-nav__item {
  display: flex; align-items: center; gap: 0.75rem;
  padding: 0.875rem 1.5rem;
  color: rgba(255,255,255,0.7);
  transition: all var(--transition-base);
  border-left: 3px solid transparent;
}
.admin-nav__item:hover { color: white; background: rgba(255,255,255,0.05); }
.admin-nav__item--active {
  color: white; background: rgba(255,255,255,0.1);
  border-left-color: var(--color-primary);
}

.admin-main { margin-left: 260px; flex: 1; }
@media (max-width: 900px) { .admin-main { margin-left: 0; } }

.admin-content { padding: 1.5rem; }

/* Stats Cards */
.admin-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1.25rem; margin-bottom: 2rem;
}
.admin-stat-card {
  background: white; border-radius: var(--radius-lg);
  padding: 1.5rem; box-shadow: var(--shadow-sm);
}
.admin-stat-card__value { font-size: 2rem; font-weight: 700; color: var(--color-primary); }
.admin-stat-card__label { color: var(--color-text-secondary); font-size: var(--text-sm); }

/* Data Table */
.admin-table-wrapper { background: white; border-radius: var(--radius-lg); box-shadow: var(--shadow-sm); overflow: hidden; }
.admin-table { width: 100%; border-collapse: collapse; }
.admin-table th {
  background: #F8F9FA; padding: 0.875rem 1rem;
  text-align: left; font-size: var(--text-sm);
  font-weight: 600; color: var(--color-text-secondary);
  border-bottom: 1px solid var(--color-border);
}
.admin-table td {
  padding: 0.875rem 1rem;
  border-bottom: 1px solid var(--color-border);
  font-size: var(--text-sm);
}
.admin-table tr:last-child td { border-bottom: none; }
.admin-table tr:hover td { background: #F8F9FA; }

/* Modal */
.admin-modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.5); z-index: 200;
  display: flex; align-items: center; justify-content: center;
  padding: 1rem;
}
.admin-modal {
  background: white; border-radius: var(--radius-lg);
  width: 100%; max-width: 640px; max-height: 90vh;
  overflow-y: auto; box-shadow: var(--shadow-xl);
}
.admin-modal__header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 1.5rem; border-bottom: 1px solid var(--color-border);
  position: sticky; top: 0; background: white; z-index: 1;
}
.admin-modal__body { padding: 1.5rem; }
.admin-modal__footer {
  padding: 1.25rem 1.5rem; border-top: 1px solid var(--color-border);
  display: flex; justify-content: flex-end; gap: 1rem;
  position: sticky; bottom: 0; background: white;
}

/* Status Badges */
.status-badge {
  display: inline-flex; align-items: center; gap: 0.375rem;
  padding: 0.25rem 0.625rem; border-radius: var(--radius-full);
  font-size: var(--text-xs); font-weight: 600;
}
.status-badge--confirmed { background: #E8F5E9; color: #2E7D32; }
.status-badge--shipped { background: #E3F2FD; color: #1565C0; }
.status-badge--delivered { background: #E8F5E9; color: #1B5E20; }
.status-badge--cancelled { background: #FFEBEE; color: #C62828; }
.status-badge--created { background: #F5F5F5; color: #616161; }
.status-badge--synced { background: #E8F5E9; color: #2E7D32; }
.status-badge--failed { background: #FFEBEE; color: #C62828; }
```

---

## Acceptance Criteria

**Layout:**
- [ ] Sidebar renders with all 6 nav items
- [ ] Active route is highlighted in sidebar
- [ ] Mobile: hamburger opens sidebar overlay
- [ ] Logout button works (clears tokens, redirects to home)

**Products:**
- [ ] Product table loads from `/api/products/admin/`
- [ ] Search and category filter work
- [ ] "Add Product" opens modal with empty form
- [ ] Clicking "Edit" opens modal pre-filled with product data
- [ ] Saving calls correct API (`POST` for new, `PUT` for edit)
- [ ] Image URL shows live preview
- [ ] "Delete" shows confirmation then calls DELETE API
- [ ] Low stock products (≤5) show warning indicator

**Discounts:**
- [ ] Two tabs: User Discounts and Dealer Discounts switch the view
- [ ] Product combobox loads search results as user types (debounced)
- [ ] Selecting a product from dropdown shows its current price
- [ ] Save creates discount via `POST /api/discounts/`
- [ ] Discount table shows units remaining with color coding
- [ ] Edit updates via `PUT /api/discounts/{id}/`
- [ ] Delete removes via `DELETE /api/discounts/{id}/`

**Orders:**
- [ ] Order table shows all orders with status filter
- [ ] Order detail drawer opens on "View" click
- [ ] Admin can change order status from the drawer
- [ ] "Retry ERP" button appears for failed syncs and works

**Dealers:**
- [ ] Pending applications table loads
- [ ] "Approve" button calls `PATCH /api/auth/dealers/{id}/approve/` with `{"dealer_status": "active"}`
- [ ] "Reject" shows confirmation then calls same endpoint with `{"dealer_status": "rejected"}`
- [ ] After approval/rejection, the dealer moves to the correct list

**ERP:**
- [ ] ERP status summary (synced/pending/failed counts) shows
- [ ] Failed orders show retry button that triggers ERP retry
