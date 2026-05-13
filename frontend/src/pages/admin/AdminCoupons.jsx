/**
 * AdminCoupons — generate, edit, and disable promo codes.
 *
 * Backend:
 *   GET    /api/coupons/admin/
 *   POST   /api/coupons/admin/
 *   PATCH  /api/coupons/admin/{id}/
 *   DELETE /api/coupons/admin/{id}/
 */
import { useEffect, useMemo, useState } from 'react';
import { FiPlus, FiTrash2, FiEdit3, FiCopy, FiRefreshCw, FiX } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchAdminCoupons, createAdminCoupon, updateAdminCoupon, deleteAdminCoupon,
} from '../../api';
import { formatPrice, formatDate } from '../../utils/format';

const TYPE_LABEL = {
  percent: '% off subtotal',
  flat: 'Flat ₹ off',
  shipping: 'Free shipping',
};

const EMPTY_FORM = {
  code: '',
  description: '',
  type: 'percent',
  value: '10',
  min_subtotal: '0',
  max_discount: '0',
  max_uses: '0',
  per_user_limit: '1',
  allowed_role: 'any',
  valid_from: '',
  valid_until: '',
  is_active: true,
};

function randomCode(prefix = 'FURN') {
  const r = Math.random().toString(36).toUpperCase().slice(2, 8);
  return `${prefix}${r}`;
}

export default function AdminCoupons() {
  const [coupons, setCoupons] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await fetchAdminCoupons();
      setCoupons(Array.isArray(data) ? data : data.results || []);
    } catch {
      toast.error('Failed to load coupons.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const totals = useMemo(() => ({
    total: coupons.length,
    active: coupons.filter((c) => c.is_active).length,
    redemptions: coupons.reduce((s, c) => s + (c.used_count || 0), 0),
  }), [coupons]);

  const openCreate = () => {
    setEditing(null);
    setForm({ ...EMPTY_FORM, code: randomCode() });
    setShowForm(true);
  };

  const openEdit = (c) => {
    setEditing(c);
    setForm({
      code: c.code,
      description: c.description || '',
      type: c.type,
      value: String(c.value || '0'),
      min_subtotal: String(c.min_subtotal || '0'),
      max_discount: String(c.max_discount || '0'),
      max_uses: String(c.max_uses || '0'),
      per_user_limit: String(c.per_user_limit || '0'),
      allowed_role: c.allowed_role || 'any',
      valid_from: c.valid_from ? c.valid_from.slice(0, 16) : '',
      valid_until: c.valid_until ? c.valid_until.slice(0, 16) : '',
      is_active: !!c.is_active,
    });
    setShowForm(true);
  };

  const handleField = (k, v) => setForm((f) => ({ ...f, [k]: v }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.code.trim()) {
      toast.error('Code is required.');
      return;
    }
    setSaving(true);
    const payload = {
      ...form,
      code: form.code.trim().toUpperCase(),
      value: form.type === 'shipping' ? 0 : parseFloat(form.value || 0),
      min_subtotal: parseFloat(form.min_subtotal || 0),
      max_discount: parseFloat(form.max_discount || 0),
      max_uses: parseInt(form.max_uses || 0, 10),
      per_user_limit: parseInt(form.per_user_limit || 0, 10),
      valid_from: form.valid_from || null,
      valid_until: form.valid_until || null,
    };
    try {
      if (editing) {
        await updateAdminCoupon(editing.id, payload);
        toast.success(`Coupon ${payload.code} updated.`);
      } else {
        await createAdminCoupon(payload);
        toast.success(`Coupon ${payload.code} created.`);
      }
      setShowForm(false);
      setEditing(null);
      await load();
    } catch (err) {
      const data = err.response?.data;
      const msg = (typeof data === 'string' ? data :
        data?.code?.[0] || data?.detail || 'Could not save coupon.');
      toast.error(msg);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (c) => {
    if (!window.confirm(`Delete coupon ${c.code}? This cannot be undone.`)) return;
    try {
      await deleteAdminCoupon(c.id);
      toast.success(`Deleted ${c.code}.`);
      await load();
    } catch {
      toast.error('Delete failed.');
    }
  };

  const handleToggle = async (c) => {
    try {
      await updateAdminCoupon(c.id, { is_active: !c.is_active });
      toast.success(`${c.code} is now ${!c.is_active ? 'active' : 'disabled'}.`);
      await load();
    } catch {
      toast.error('Toggle failed.');
    }
  };

  const copyCode = (code) => {
    navigator.clipboard?.writeText(code).then(() => toast.success(`${code} copied`));
  };

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Coupons</h2>
        <span className="admin-meta-line">
          {totals.total} total · {totals.active} active · {totals.redemptions} redemptions
        </span>
      </div>

      <div className="admin-stats-grid admin-stats-grid--compact" style={{ marginBottom: 16 }}>
        <div className="admin-stat-card">
          <span className="admin-stat-card__value">{totals.total}</span>
          <span className="admin-stat-card__label">Codes</span>
        </div>
        <div className="admin-stat-card admin-stat-card--success">
          <span className="admin-stat-card__value">{totals.active}</span>
          <span className="admin-stat-card__label">Active</span>
        </div>
        <div className="admin-stat-card">
          <span className="admin-stat-card__value">{totals.redemptions}</span>
          <span className="admin-stat-card__label">Total Redemptions</span>
        </div>
      </div>

      <div className="admin-toolbar" style={{ justifyContent: 'flex-end' }}>
        <button className="btn-primary" onClick={openCreate}>
          <FiPlus /> Generate New Coupon
        </button>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : coupons.length === 0 ? (
          <p className="admin-empty">No coupons yet. Click "Generate New Coupon" to create one.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Code</th>
                <th>Type</th>
                <th>Value</th>
                <th>Min Subtotal</th>
                <th>Audience</th>
                <th>Used</th>
                <th>Valid Until</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {coupons.map((c) => (
                <tr key={c.id}>
                  <td>
                    <code style={{ fontWeight: 700, fontSize: 13 }}>{c.code}</code>
                    <button
                      onClick={() => copyCode(c.code)}
                      className="admin-icon-btn"
                      style={{ marginLeft: 4 }}
                      aria-label="Copy code"
                    >
                      <FiCopy size={12} />
                    </button>
                    {c.description && (
                      <div className="admin-meta-line">{c.description}</div>
                    )}
                  </td>
                  <td>{TYPE_LABEL[c.type] || c.type}</td>
                  <td>
                    {c.type === 'shipping'
                      ? '—'
                      : c.type === 'percent'
                        ? `${c.value}%`
                        : formatPrice(c.value)}
                  </td>
                  <td>{c.min_subtotal > 0 ? formatPrice(c.min_subtotal) : '—'}</td>
                  <td>
                    <span style={{
                      display: 'inline-block', padding: '2px 8px', borderRadius: 999,
                      background: c.allowed_role === 'dealer' ? '#E0F2FE'
                        : c.allowed_role === 'user' ? '#FEF3C7' : '#F3F4F6',
                      color: c.allowed_role === 'dealer' ? '#075985'
                        : c.allowed_role === 'user' ? '#92400E' : '#374151',
                      fontSize: 11, fontWeight: 600, textTransform: 'capitalize',
                    }}>
                      {c.allowed_role === 'any' ? 'All' : c.allowed_role}
                    </span>
                  </td>
                  <td>
                    {c.used_count}
                    {c.max_uses > 0 && <span style={{ color: '#9CA3AF' }}> / {c.max_uses}</span>}
                  </td>
                  <td>{c.valid_until ? formatDate(c.valid_until) : 'No expiry'}</td>
                  <td>
                    <button
                      onClick={() => handleToggle(c)}
                      className={`status-badge ${c.is_active ? 'status-badge--synced' : 'status-badge--failed'}`}
                      style={{ border: 0, cursor: 'pointer' }}
                    >
                      {c.is_active ? '✓ Active' : '○ Disabled'}
                    </button>
                  </td>
                  <td>
                    <button className="admin-icon-btn" onClick={() => openEdit(c)} aria-label="Edit">
                      <FiEdit3 size={14} />
                    </button>
                    <button className="admin-icon-btn admin-icon-btn--danger"
                            onClick={() => handleDelete(c)} aria-label="Delete">
                      <FiTrash2 size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {showForm && (
        <CouponFormModal
          form={form}
          editing={editing}
          saving={saving}
          onField={handleField}
          onClose={() => { setShowForm(false); setEditing(null); }}
          onSubmit={handleSubmit}
          onRandom={() => handleField('code', randomCode())}
        />
      )}
    </div>
  );
}

function CouponFormModal({ form, editing, saving, onField, onClose, onSubmit, onRandom }) {
  return (
    <div className="admin-modal-backdrop" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <header className="admin-modal__header">
          <h3>{editing ? `Edit ${editing.code}` : 'Generate New Coupon'}</h3>
          <button onClick={onClose} className="admin-icon-btn" aria-label="Close">
            <FiX />
          </button>
        </header>

        <form onSubmit={onSubmit} className="admin-form">
          <div className="admin-form-row">
            <label className="admin-form-field">
              <span>Coupon code</span>
              <div style={{ display: 'flex', gap: 6 }}>
                <input
                  type="text"
                  value={form.code}
                  onChange={(e) => onField('code', e.target.value.toUpperCase())}
                  placeholder="e.g. SUMMER15"
                  required
                  disabled={!!editing}
                  style={{ flex: 1, textTransform: 'uppercase', fontWeight: 700 }}
                />
                {!editing && (
                  <button type="button" onClick={onRandom} className="btn-outline"
                          style={{ padding: '6px 10px' }} aria-label="Generate random">
                    <FiRefreshCw size={14} />
                  </button>
                )}
              </div>
            </label>
            <label className="admin-form-field">
              <span>Description (optional)</span>
              <input
                type="text"
                value={form.description}
                onChange={(e) => onField('description', e.target.value)}
                placeholder="Festive sale — 15% off"
              />
            </label>
          </div>

          <div className="admin-form-row">
            <label className="admin-form-field">
              <span>Type</span>
              <select value={form.type} onChange={(e) => onField('type', e.target.value)}>
                <option value="percent">% off subtotal</option>
                <option value="flat">Flat ₹ off subtotal</option>
                <option value="shipping">Free shipping</option>
              </select>
            </label>
            {form.type !== 'shipping' && (
              <label className="admin-form-field">
                <span>{form.type === 'percent' ? 'Percent (0-100)' : 'Amount (₹)'}</span>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  value={form.value}
                  onChange={(e) => onField('value', e.target.value)}
                  required
                />
              </label>
            )}
            <label className="admin-form-field">
              <span>Audience</span>
              <select value={form.allowed_role}
                      onChange={(e) => onField('allowed_role', e.target.value)}>
                <option value="any">All shoppers</option>
                <option value="user">Customers only</option>
                <option value="dealer">Dealers only</option>
              </select>
            </label>
          </div>

          <div className="admin-form-row">
            <label className="admin-form-field">
              <span>Minimum subtotal (₹)</span>
              <input
                type="number" step="0.01" min="0"
                value={form.min_subtotal}
                onChange={(e) => onField('min_subtotal', e.target.value)}
              />
            </label>
            {form.type === 'percent' && (
              <label className="admin-form-field">
                <span>Max discount cap (₹) — 0 = no cap</span>
                <input
                  type="number" step="0.01" min="0"
                  value={form.max_discount}
                  onChange={(e) => onField('max_discount', e.target.value)}
                />
              </label>
            )}
            <label className="admin-form-field">
              <span>Max total uses — 0 = unlimited</span>
              <input
                type="number" min="0"
                value={form.max_uses}
                onChange={(e) => onField('max_uses', e.target.value)}
              />
            </label>
            <label className="admin-form-field">
              <span>Per-user limit — 0 = unlimited</span>
              <input
                type="number" min="0"
                value={form.per_user_limit}
                onChange={(e) => onField('per_user_limit', e.target.value)}
              />
            </label>
          </div>

          <div className="admin-form-row">
            <label className="admin-form-field">
              <span>Valid from (optional)</span>
              <input
                type="datetime-local"
                value={form.valid_from}
                onChange={(e) => onField('valid_from', e.target.value)}
              />
            </label>
            <label className="admin-form-field">
              <span>Valid until (optional)</span>
              <input
                type="datetime-local"
                value={form.valid_until}
                onChange={(e) => onField('valid_until', e.target.value)}
              />
            </label>
            <label className="admin-form-field admin-form-field--checkbox">
              <input
                type="checkbox"
                checked={form.is_active}
                onChange={(e) => onField('is_active', e.target.checked)}
              />
              <span>Active immediately</span>
            </label>
          </div>

          <footer className="admin-modal__footer">
            <button type="button" onClick={onClose} className="btn-outline">Cancel</button>
            <button type="submit" disabled={saving} className="btn-primary">
              {saving ? 'Saving…' : (editing ? 'Save changes' : 'Generate coupon')}
            </button>
          </footer>
        </form>
      </div>
    </div>
  );
}
