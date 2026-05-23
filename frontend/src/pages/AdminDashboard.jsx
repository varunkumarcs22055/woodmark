/**
 * AdminDashboard — sidebar shell with nested routes.
 * Mounted at /admin-dashboard/* and guarded by RoleRoute({ allowedRoles: ['admin'] }).
 */
import { useState } from 'react';
import { Routes, Route, NavLink, useNavigate } from 'react-router-dom';
import {
  FiGrid, FiPackage, FiTag, FiShoppingBag, FiLayers,
  FiUsers, FiUser, FiRefreshCw, FiLogOut, FiMenu, FiX, FiSettings,
  FiArchive, FiFileText, FiFile, FiMessageSquare, FiStar, FiMail, FiActivity, FiTruck,
  FiSmartphone, FiHeart,
} from 'react-icons/fi';
import { useAuth } from '../context/AuthContext';

import AdminOverview from './admin/AdminOverview';
import AdminProducts from './admin/AdminProducts';
import AdminCategories from './admin/AdminCategories';
import AdminInventory from './admin/AdminInventory';
import AdminDiscounts from './admin/AdminDiscounts';
import AdminCoupons from './admin/AdminCoupons';
import AdminOrders from './admin/AdminOrders';
import AdminInvoices from './admin/AdminInvoices';
import AdminCustomers from './admin/AdminCustomers';
import AdminDealers from './admin/AdminDealers';
import AdminCMS from './admin/AdminCMS';
import AdminERP from './admin/AdminERP';
import AdminSupport from './admin/AdminSupport';
import AdminAuditLogs from './admin/AdminAuditLogs';
import AdminSettings from './admin/AdminSettings';
import AdminReviews from './admin/AdminReviews';
import AdminNewsletter from './admin/AdminNewsletter';
import AdminShipping from './admin/AdminShipping';
import AdminSMS from './admin/AdminSMS';
import AdminWishlists from './admin/AdminWishlists';

import './AdminDashboard.css';
import './admin/AdminPanel.css';

const NAV_ITEMS = [
  { path: '',           label: 'Overview',   icon: <FiGrid /> },
  { path: 'products',   label: 'Products',   icon: <FiPackage /> },
  { path: 'categories', label: 'Categories', icon: <FiLayers /> },
  { path: 'inventory',  label: 'Inventory',  icon: <FiArchive /> },
  { path: 'shipping',   label: 'Shipping',   icon: <FiTruck /> },
  { path: 'discounts',  label: 'Discounts',  icon: <FiTag /> },
  { path: 'coupons',    label: 'Coupons',    icon: <FiTag /> },
  { path: 'orders',     label: 'Orders',     icon: <FiShoppingBag /> },
  { path: 'invoices',   label: 'Invoices',   icon: <FiFile /> },
  { path: 'customers',  label: 'Customers',  icon: <FiUser /> },
  { path: 'reviews',    label: 'Reviews',    icon: <FiStar /> },
  { path: 'wishlists',  label: 'Wishlists',  icon: <FiHeart /> },
  { path: 'dealers',    label: 'Dealers',    icon: <FiUsers /> },
  { path: 'cms',        label: 'Content',    icon: <FiFileText /> },
  { path: 'newsletter', label: 'Newsletter', icon: <FiMail /> },
  { path: 'sms',        label: 'SMS Campaigns', icon: <FiSmartphone /> },
  { path: 'support',    label: 'Support',    icon: <FiMessageSquare /> },
  { path: 'audit',      label: 'Audit Logs', icon: <FiActivity /> },
  { path: 'erp',        label: 'ERP Status', icon: <FiRefreshCw /> },
  { path: 'settings',   label: 'Settings',   icon: <FiSettings /> },
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
      <aside className={`admin-sidebar ${sidebarOpen ? 'admin-sidebar--open' : ''}`}>
        <div className="admin-sidebar__header">
          <span className="admin-sidebar__logo">FurniShop Admin</span>
          <button
            className="admin-sidebar__close"
            onClick={() => setSidebarOpen(false)}
            aria-label="Close sidebar"
          >
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

      <div className="admin-main">
        <header className="admin-topbar">
          <button
            className="admin-menu-toggle"
            onClick={() => setSidebarOpen(true)}
            aria-label="Open sidebar"
          >
            <FiMenu />
          </button>
          <h1 className="admin-topbar__title">Admin Dashboard</h1>
        </header>

        <div className="admin-content">
          <Routes>
            <Route index element={<AdminOverview />} />
            <Route path="products" element={<AdminProducts />} />
            <Route path="categories" element={<AdminCategories />} />
            <Route path="inventory" element={<AdminInventory />} />
            <Route path="shipping" element={<AdminShipping />} />
            <Route path="discounts" element={<AdminDiscounts />} />
            <Route path="coupons" element={<AdminCoupons />} />
            <Route path="orders" element={<AdminOrders />} />
            <Route path="invoices" element={<AdminInvoices />} />
            <Route path="customers" element={<AdminCustomers />} />
            <Route path="reviews" element={<AdminReviews />} />
            <Route path="wishlists" element={<AdminWishlists />} />
            <Route path="dealers" element={<AdminDealers />} />
            <Route path="cms" element={<AdminCMS />} />
            <Route path="newsletter" element={<AdminNewsletter />} />
            <Route path="sms" element={<AdminSMS />} />
            <Route path="support" element={<AdminSupport />} />
            <Route path="audit" element={<AdminAuditLogs />} />
            <Route path="erp" element={<AdminERP />} />
            <Route path="settings" element={<AdminSettings />} />
          </Routes>
        </div>
      </div>

      {sidebarOpen && (
        <div className="admin-overlay" onClick={() => setSidebarOpen(false)} />
      )}
    </div>
  );
}
