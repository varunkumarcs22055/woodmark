/**
 * AdminDashboard — sidebar shell with nested routes.
 * Mounted at /admin-dashboard/* and guarded by RoleRoute({ allowedRoles: ['admin'] }).
 */
import { useState } from 'react';
import { Routes, Route, NavLink, useNavigate } from 'react-router-dom';
import {
  FiGrid, FiPackage, FiTag, FiShoppingBag,
  FiUsers, FiRefreshCw, FiLogOut, FiMenu, FiX,
} from 'react-icons/fi';
import { useAuth } from '../context/AuthContext';

import AdminOverview from './admin/AdminOverview';
import AdminProducts from './admin/AdminProducts';
import AdminDiscounts from './admin/AdminDiscounts';
import AdminOrders from './admin/AdminOrders';
import AdminDealers from './admin/AdminDealers';
import AdminERP from './admin/AdminERP';

import './AdminDashboard.css';
import './admin/AdminPanel.css';

const NAV_ITEMS = [
  { path: '',          label: 'Overview',  icon: <FiGrid /> },
  { path: 'products',  label: 'Products',  icon: <FiPackage /> },
  { path: 'discounts', label: 'Discounts', icon: <FiTag /> },
  { path: 'orders',    label: 'Orders',    icon: <FiShoppingBag /> },
  { path: 'dealers',   label: 'Dealers',   icon: <FiUsers /> },
  { path: 'erp',       label: 'ERP Status',icon: <FiRefreshCw /> },
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
            <Route path="discounts" element={<AdminDiscounts />} />
            <Route path="orders" element={<AdminOrders />} />
            <Route path="dealers" element={<AdminDealers />} />
            <Route path="erp" element={<AdminERP />} />
          </Routes>
        </div>
      </div>

      {sidebarOpen && (
        <div className="admin-overlay" onClick={() => setSidebarOpen(false)} />
      )}
    </div>
  );
}
