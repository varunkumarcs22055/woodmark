/**
 * AdminCustomers — list with filters + drawer with profile, order history, block toggle.
 *
 * Backend endpoints:
 *   GET   /api/admin/customers/?search=&role=&is_blocked=&ordering=
 *   GET   /api/admin/customers/{id}/         (detail with aggregates + recent orders)
 *   PATCH /api/admin/customers/{id}/         (toggle is_blocked, edit phone/name)
 */
import { useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { FiSearch, FiX, FiSlash, FiCheck, FiAlertTriangle } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchCustomers, fetchCustomerDetail, updateCustomer,
} from '../../api';
import { formatPrice, formatDate, formatDateTime } from '../../utils/format';
import Pagination from '../../components/Pagination';

const PAGE_SIZE = 20;

export default function AdminCustomers() {
  const [rows, setRows] = useState([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [role, setRole] = useState('');
  const [blocked, setBlocked] = useState('');
  const [drawer, setDrawer] = useState(null);

  const load = async () => {
    setLoading(true);
    try {
      const params = { page, page_size: PAGE_SIZE };
      if (search) params.search = search;
      if (role) params.role = role;
      if (blocked) params.is_blocked = blocked;
      const data = await fetchCustomers(params);
      const list = Array.isArray(data) ? data : Array.isArray(data?.results) ? data.results : [];
      setRows(list);
      setCount(typeof data?.count === 'number' ? data.count : list.length);
    } catch {
      toast.error('Failed to load customers');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); /* eslint-disable-next-line */ }, [page]);
  useEffect(() => {
    const t = setTimeout(() => { if (page !== 1) setPage(1); else load(); }, 300);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search, role, blocked]);

  const openDrawer = async (id) => {
    try {
      const detail = await fetchCustomerDetail(id);
      setDrawer(detail);
    } catch {
      toast.error('Failed to load customer detail');
    }
  };

  // Deep-link: when navigated here with ?id=<userId> (e.g. from
  // AdminWishlists -> View), auto-open that customer's drawer. We then
  // strip the param so a Back nav doesn't re-trigger.
  const [searchParams, setSearchParams] = useSearchParams();
  useEffect(() => {
    const id = searchParams.get('id');
    if (!id) return;
    openDrawer(id);
    // Remove the param without leaving a history entry
    const next = new URLSearchParams(searchParams);
    next.delete('id');
    setSearchParams(next, { replace: true });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const toggleBlock = async (customer) => {
    const next = !customer.is_blocked;
    const verb = next ? 'Block' : 'Unblock';
    if (!window.confirm(`${verb} ${customer.email}?`)) return;
    try {
      await updateCustomer(customer.id, { is_blocked: next });
      toast.success(`${verb}ed.`);
      setDrawer({ ...customer, is_blocked: next });
      setRows((prev) => prev.map((r) => (r.id === customer.id ? { ...r, is_blocked: next } : r)));
    } catch (err) {
      toast.error(err.response?.data?.detail || `${verb} failed.`);
    }
  };

  const counts = useMemo(() => ({
    total: rows.length,
    blocked: rows.filter((r) => r.is_blocked).length,
    dealers: rows.filter((r) => r.role === 'dealer').length,
  }), [rows]);

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Customers</h2>
        <span className="admin-meta-line">
          {counts.total} total · {counts.dealers} dealers · {counts.blocked} blocked
        </span>
      </div>

      <div className="admin-toolbar">
        <div className="admin-toolbar__search">
          <FiSearch />
          <input
            type="search"
            placeholder="Search by email, name, phone…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select value={role} onChange={(e) => setRole(e.target.value)}>
          <option value="">All roles</option>
          <option value="user">Customer</option>
          <option value="dealer">Dealer</option>
          <option value="admin">Admin</option>
        </select>
        <select value={blocked} onChange={(e) => setBlocked(e.target.value)}>
          <option value="">Blocked + Active</option>
          <option value="false">Active only</option>
          <option value="true">Blocked only</option>
        </select>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : rows.length === 0 ? (
          <p className="admin-empty">No customers match your filters.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Email</th>
                <th>Name</th>
                <th>Role</th>
                <th>Orders</th>
                <th>Lifetime value</th>
                <th>Joined</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((c) => (
                <tr key={c.id}>
                  <td>
                    <strong>{c.email}</strong>
                    {c.phone && <span className="admin-meta-line">{c.phone}</span>}
                  </td>
                  <td>{c.full_name || '—'}</td>
                  <td>
                    <span className={`status-badge status-badge--${c.role}`}>{c.role}</span>
                    {c.dealer_status && (
                      <span className="admin-meta-line">{c.dealer_status}</span>
                    )}
                  </td>
                  <td>{c.order_count ?? 0}</td>
                  <td>{c.lifetime_value ? formatPrice(c.lifetime_value) : '—'}</td>
                  <td>{formatDate(c.date_joined)}</td>
                  <td>
                    {c.is_blocked ? (
                      <span className="status-badge status-badge--cancelled">
                        <FiAlertTriangle size={12} /> Blocked
                      </span>
                    ) : (
                      <span className="status-badge status-badge--confirmed">Active</span>
                    )}
                  </td>
                  <td>
                    <button className="admin-icon-btn" onClick={() => openDrawer(c.id)}>
                      View
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <Pagination page={page} count={count} pageSize={PAGE_SIZE} onChange={setPage} />
      </div>

      {drawer && (
        <CustomerDrawer
          customer={drawer}
          onClose={() => setDrawer(null)}
          onToggleBlock={toggleBlock}
        />
      )}
    </div>
  );
}

function CustomerDrawer({ customer, onClose, onToggleBlock }) {
  const agg = customer.aggregates || {};
  const orders = customer.recent_orders || [];

  return (
    <>
      <div className="admin-drawer-backdrop" onClick={onClose} />
      <aside className="admin-drawer">
        <div className="admin-drawer__header">
          <div>
            <h3>{customer.email}</h3>
            <span className="admin-meta-line">
              {customer.role}
              {customer.dealer_status && ` · ${customer.dealer_status}`}
            </span>
          </div>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>

        <div className="admin-drawer__body">
          <section className="admin-drawer__section">
            <h4>Profile</h4>
            <p><strong>{customer.full_name || '—'}</strong></p>
            <p>{customer.phone || 'No phone on file'}</p>
            {customer.dealer_company_name && (
              <p>Company: {customer.dealer_company_name}</p>
            )}
            {customer.dealer_gst_number && (
              <p>GST: <code>{customer.dealer_gst_number}</code></p>
            )}
          </section>

          <section className="admin-drawer__section">
            <h4>Lifetime</h4>
            <div className="admin-stats-grid admin-stats-grid--compact">
              <div className="admin-stat-card">
                <span className="admin-stat-card__value">{agg.order_count ?? 0}</span>
                <span className="admin-stat-card__label">Orders</span>
              </div>
              <div className="admin-stat-card">
                <span className="admin-stat-card__value">
                  {agg.lifetime_value ? formatPrice(agg.lifetime_value) : '—'}
                </span>
                <span className="admin-stat-card__label">Lifetime value</span>
              </div>
              <div className="admin-stat-card">
                <span className="admin-stat-card__value" style={{ fontSize: 'var(--text-base)' }}>
                  {agg.last_order_at ? formatDate(agg.last_order_at) : '—'}
                </span>
                <span className="admin-stat-card__label">Last order</span>
              </div>
            </div>
          </section>

          <section className="admin-drawer__section">
            <h4>Recent orders</h4>
            {orders.length === 0 ? (
              <p className="admin-empty">No orders.</p>
            ) : (
              <table className="admin-table admin-table--compact">
                <thead>
                  <tr><th>Order</th><th>Total</th><th>Status</th><th>Date</th></tr>
                </thead>
                <tbody>
                  {orders.map((o) => (
                    <tr key={o.id}>
                      <td><code>{o.order_id}</code></td>
                      <td>{formatPrice(o.total_amount)}</td>
                      <td>
                        <span className={`status-badge status-badge--${(o.order_status || '').toLowerCase()}`}>
                          {o.order_status}
                        </span>
                      </td>
                      <td>{formatDateTime(o.created_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </section>

          <section className="admin-drawer__section">
            <h4>Account access</h4>
            {customer.is_blocked ? (
              <button className="btn-primary" onClick={() => onToggleBlock(customer)}>
                <FiCheck size={14} /> Unblock account
              </button>
            ) : (
              <button className="btn-outline admin-icon-btn--danger" onClick={() => onToggleBlock(customer)}>
                <FiSlash size={14} /> Block account
              </button>
            )}
            <p className="admin-meta-line">
              Blocked accounts are rejected at login with code <code>user_blocked</code>.
            </p>
          </section>
        </div>
      </aside>
    </>
  );
}
