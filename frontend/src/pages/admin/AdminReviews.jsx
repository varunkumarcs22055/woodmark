/**
 * AdminReviews — list + moderation for product reviews.
 */
import { useEffect, useMemo, useState } from 'react';
import { FiSearch, FiCheck, FiX, FiTrash2 } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchAdminReviews, moderateReview, deleteAdminReview,
} from '../../api';
import { formatDateTime, truncate } from '../../utils/format';

const STATUS_OPTIONS = [
  { value: 'ALL', label: 'All statuses' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
];

export default function AdminReviews() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [search, setSearch] = useState('');

  const load = async () => {
    setLoading(true);
    try {
      const params = statusFilter === 'ALL' ? {} : { status: statusFilter };
      const data = await fetchAdminReviews(params);
      setRows(Array.isArray(data) ? data : Array.isArray(data?.results) ? data.results : []);
    } catch {
      toast.error('Failed to load reviews');
      setRows([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [statusFilter]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return rows;
    return rows.filter((r) => {
      const hay = [
        r.product_name,
        r.product_slug,
        String(r.product || ''),
        r.user_name,
        r.user_email,
        r.title,
        r.body,
      ].filter(Boolean).join(' ').toLowerCase();
      return hay.includes(q);
    });
  }, [rows, search]);

  const counts = useMemo(() => ({
    total: rows.length,
    pending: rows.filter((r) => r.status === 'pending').length,
    approved: rows.filter((r) => r.status === 'approved').length,
    rejected: rows.filter((r) => r.status === 'rejected').length,
  }), [rows]);

  const handleModerate = async (review, status) => {
    if (review.status === status) return;
    try {
      const updated = await moderateReview(review.id, status);
      toast.success(`Review ${status}.`);
      setRows((prev) => {
        if (statusFilter !== 'ALL' && statusFilter !== status) {
          return prev.filter((r) => r.id !== review.id);
        }
        return prev.map((r) => (r.id === review.id ? { ...r, ...updated } : r));
      });
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Update failed.');
    }
  };

  const handleDelete = async (review) => {
    const label = review.product_name || `Product #${review.product}`;
    if (!window.confirm(`Delete review by ${review.user_name} on ${label}?`)) return;
    try {
      await deleteAdminReview(review.id);
      toast.success('Review deleted.');
      setRows((prev) => prev.filter((r) => r.id !== review.id));
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Delete failed.');
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Reviews</h2>
        <span className="admin-meta-line">
          {counts.total} total · {counts.pending} pending · {counts.approved} approved · {counts.rejected} rejected
        </span>
      </div>

      <div className="admin-toolbar">
        <div className="admin-toolbar__search">
          <FiSearch />
          <input
            type="search"
            placeholder="Search product, user, title…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
          {STATUS_OPTIONS.map((o) => (
            <option key={o.value} value={o.value}>{o.label}</option>
          ))}
        </select>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : filtered.length === 0 ? (
          <p className="admin-empty">No reviews match your filters.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Product</th>
                <th>Customer</th>
                <th>Rating</th>
                <th>Status</th>
                <th>Verified</th>
                <th>Date</th>
                <th>Review</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((r) => {
                const productLabel = r.product_name || `Product #${r.product}`;
                const productSub = r.product_slug ? `/${r.product_slug}` : null;
                return (
                  <tr key={r.id}>
                    <td>
                      <strong>{productLabel}</strong>
                      {productSub && <span className="admin-meta-line">{productSub}</span>}
                    </td>
                    <td>
                      {r.user_name}
                      {r.user_email && <span className="admin-meta-line">{r.user_email}</span>}
                    </td>
                    <td>{r.rating}★</td>
                    <td>
                      <span className={`status-badge status-badge--${r.status}`}>
                        {r.status}
                      </span>
                    </td>
                    <td>{r.verified_purchase ? 'Yes' : 'No'}</td>
                    <td>{formatDateTime(r.created_at)}</td>
                    <td>
                      <strong>{truncate(r.title || '—', 40)}</strong>
                      {r.body && <span className="admin-meta-line">{truncate(r.body, 120)}</span>}
                    </td>
                    <td>
                      <div className="admin-action-group">
                        {r.status !== 'approved' && (
                          <button
                            className="admin-icon-btn admin-icon-btn--success"
                            onClick={() => handleModerate(r, 'approved')}
                          >
                            <FiCheck /> Approve
                          </button>
                        )}
                        {r.status !== 'rejected' && (
                          <button
                            className="admin-icon-btn"
                            onClick={() => handleModerate(r, 'rejected')}
                          >
                            <FiX /> Reject
                          </button>
                        )}
                        <button
                          className="admin-icon-btn admin-icon-btn--danger"
                          onClick={() => handleDelete(r)}
                        >
                          <FiTrash2 /> Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
