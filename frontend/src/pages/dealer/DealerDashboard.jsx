/**
 * DealerDashboard — sidebar shell for B2B portal.
 * Mounted at /dealer-dashboard/* (RoleRoute allowedRoles=['dealer']).
 *
 * Status routing:
 *   dealer_status === 'pending'  → DealerPendingScreen
 *   dealer_status === 'rejected' → DealerRejectedScreen
 *   dealer_status === 'active'   → full dashboard
 */
import { useState } from 'react';
import { Routes, Route, NavLink, useNavigate } from 'react-router-dom';
import {
  FiHome, FiShoppingBag, FiUser, FiLogOut, FiTrendingUp, FiMenu, FiX,
  FiExternalLink,
} from 'react-icons/fi';
import { Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import DealerStatusBadge from '../../components/dealer/DealerStatusBadge';
import DealerOverview from './DealerOverview';
import DealerOrders from './DealerOrders';
import DealerProfile from './DealerProfile';
import DealerPendingScreen from './DealerPendingScreen';
import DealerRejectedScreen from './DealerRejectedScreen';
import './DealerDashboard.css';

const NAV_ITEMS = [
  { path: '',        label: 'Overview',  icon: <FiHome /> },
  { path: 'orders',  label: 'My Orders', icon: <FiShoppingBag /> },
  { path: 'profile', label: 'Account',   icon: <FiUser /> },
];

export default function DealerDashboard() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  // Status gate
  if (user?.dealer_status === 'pending') return <DealerPendingScreen />;
  if (user?.dealer_status === 'rejected') return <DealerRejectedScreen />;

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <div className="dealer-dashboard">
      <aside className={`dealer-sidebar ${sidebarOpen ? 'dealer-sidebar--open' : ''}`}>
        <div className="dealer-sidebar__brand">
          <div>
            <h2>FurniShop</h2>
            <span className="dealer-sidebar__brand-tag">B2B Portal</span>
          </div>
          <button
            className="dealer-sidebar__close"
            onClick={() => setSidebarOpen(false)}
            aria-label="Close sidebar"
          >
            <FiX />
          </button>
        </div>

        <div className="dealer-sidebar__profile">
          <div className="dealer-sidebar__avatar">
            {user?.full_name?.charAt(0).toUpperCase() || 'D'}
          </div>
          <div className="dealer-sidebar__profile-info">
            <span className="dealer-sidebar__name">{user?.full_name || user?.email}</span>
            {user?.dealer_company_name && (
              <span className="dealer-sidebar__company">{user.dealer_company_name}</span>
            )}
            <DealerStatusBadge status={user?.dealer_status} />
          </div>
        </div>

        <nav className="dealer-sidebar__nav">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === ''}
              className={({ isActive }) =>
                `dealer-sidebar__link ${isActive ? 'dealer-sidebar__link--active' : ''}`
              }
              onClick={() => setSidebarOpen(false)}
            >
              {item.icon} {item.label}
            </NavLink>
          ))}

          {/* Shop on the public site — same UI as users, but dealer prices */}
          <Link
            to="/"
            className="dealer-sidebar__link dealer-sidebar__link--external"
            onClick={() => setSidebarOpen(false)}
          >
            <FiExternalLink /> Shop the Catalog
          </Link>
        </nav>

        <div className="dealer-sidebar__footer">
          <button onClick={handleLogout} className="dealer-sidebar__logout">
            <FiLogOut /> Sign Out
          </button>
        </div>
      </aside>

      <main className="dealer-main">
        <header className="dealer-topbar">
          <button
            className="dealer-menu-toggle"
            onClick={() => setSidebarOpen(true)}
            aria-label="Open sidebar"
          >
            <FiMenu />
          </button>
          <div className="dealer-main__banner">
            <FiTrendingUp />
            <span>You're shopping at <strong>dealer prices</strong> — exclusive B2B rates apply.</span>
          </div>
        </header>

        <div className="dealer-main__content">
          <Routes>
            <Route index element={<DealerOverview />} />
            <Route path="orders" element={<DealerOrders />} />
            <Route path="profile" element={<DealerProfile />} />
          </Routes>
        </div>
      </main>

      {sidebarOpen && (
        <div className="dealer-overlay" onClick={() => setSidebarOpen(false)} />
      )}
    </div>
  );
}
