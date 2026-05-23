import { useState, useEffect } from 'react';
import { FiSave, FiUserPlus, FiTrash2, FiShield, FiX } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchStoreSettings, updateStoreSettings,
  fetchAdminUsers, createAdminUser, deleteAdminUser,
} from '../../api';
import { useAuth } from '../../context/AuthContext';
import { formatDate } from '../../utils/format';

export default function AdminSettings() {
  const { user: me } = useAuth();
  const [form, setForm] = useState({
    gst_percent: '',
    free_shipping_threshold: '',
    standard_shipping_fee: '',
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // ── Admin user management ─────────────────────────────────────────
  const [admins, setAdmins] = useState([]);
  const [adminsLoading, setAdminsLoading] = useState(true);
  const [showCreate, setShowCreate] = useState(false);
  const [newAdmin, setNewAdmin] = useState({
    email: '', password: '', full_name: '', phone: '',
  });
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    fetchStoreSettings()
      .then((data) => setForm({
        gst_percent: data.gst_percent,
        free_shipping_threshold: data.free_shipping_threshold,
        standard_shipping_fee: data.standard_shipping_fee,
      }))
      .catch(() => toast.error('Failed to load settings'))
      .finally(() => setLoading(false));
  }, []);

  const loadAdmins = () => {
    setAdminsLoading(true);
    fetchAdminUsers()
      .then((rows) => setAdmins(Array.isArray(rows) ? rows : rows?.results || []))
      .catch(() => setAdmins([]))
      .finally(() => setAdminsLoading(false));
  };
  useEffect(() => { loadAdmins(); }, []);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await updateStoreSettings({
        gst_percent: parseFloat(form.gst_percent),
        free_shipping_threshold: parseFloat(form.free_shipping_threshold),
        standard_shipping_fee: parseFloat(form.standard_shipping_fee),
      });
      toast.success('Settings updated. New orders will use the updated GST.');
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to save settings.');
    } finally {
      setSaving(false);
    }
  };

  const handleCreateAdmin = async (e) => {
    e.preventDefault();
    if (newAdmin.password.length < 8) {
      toast.error('Password must be at least 8 characters.');
      return;
    }
    if (!/\S+@\S+\.\S+/.test(newAdmin.email)) {
      toast.error('Enter a valid email.');
      return;
    }
    setCreating(true);
    try {
      const created = await createAdminUser({
        email: newAdmin.email.trim().toLowerCase(),
        password: newAdmin.password,
        full_name: newAdmin.full_name.trim(),
        phone: newAdmin.phone.trim(),
      });
      toast.success(`Admin ${created.email} created. They've been emailed.`);
      setAdmins((prev) => [created, ...prev]);
      setNewAdmin({ email: '', password: '', full_name: '', phone: '' });
      setShowCreate(false);
    } catch (err) {
      const data = err.response?.data || {};
      const msg =
        data.email || data.password || data.full_name || data.detail
        || 'Could not create admin.';
      toast.error(typeof msg === 'string' ? msg : Object.values(data).flat()[0] || 'Failed.');
    } finally {
      setCreating(false);
    }
  };

  const handleDemote = async (admin) => {
    if (admin.id === me?.id) {
      toast.error("You can't remove your own admin role.");
      return;
    }
    if (!window.confirm(`Demote ${admin.email} to a regular user? They will lose admin access.`)) {
      return;
    }
    try {
      await deleteAdminUser(admin.id);
      toast.success(`${admin.email} demoted.`);
      setAdmins((prev) => prev.filter((a) => a.id !== admin.id));
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Could not demote.');
    }
  };

  if (loading) return <p className="admin-empty">Loading…</p>;

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Store Settings</h2>
      </div>

      <form onSubmit={handleSave} style={{ maxWidth: 480 }}>
        <div className="admin-settings-card">
          <h3 className="admin-settings-card__title">Tax &amp; Shipping</h3>

          <div className="admin-field">
            <label>GST Percentage (%)</label>
            <input
              type="number" name="gst_percent" min="0" max="100" step="0.01"
              value={form.gst_percent} onChange={handleChange} required
            />
            <span className="admin-field__hint">Applied to all new orders after discounts.</span>
          </div>

          <div className="admin-field">
            <label>Free Shipping Threshold (₹)</label>
            <input
              type="number" name="free_shipping_threshold" min="0" step="0.01"
              value={form.free_shipping_threshold} onChange={handleChange} required
            />
          </div>

          <div className="admin-field">
            <label>Standard Shipping Fee (₹)</label>
            <input
              type="number" name="standard_shipping_fee" min="0" step="0.01"
              value={form.standard_shipping_fee} onChange={handleChange} required
            />
          </div>

          <button type="submit" className="btn-primary" disabled={saving} style={{ marginTop: 8 }}>
            <FiSave size={15} />
            {saving ? 'Saving…' : 'Save Settings'}
          </button>
        </div>
      </form>

      {/* ── Admin Users ──────────────────────────────────────── */}
      <div className="admin-settings-card" style={{ maxWidth: 880, marginTop: 24 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, flexWrap: 'wrap', marginBottom: 8 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <FiShield size={18} style={{ color: '#2D2E5F' }} />
            <h3 className="admin-settings-card__title" style={{ margin: 0 }}>Admin Users</h3>
          </div>
          {!showCreate && (
            <button type="button" className="btn-primary" onClick={() => setShowCreate(true)}>
              <FiUserPlus size={15} /> Add Admin
            </button>
          )}
        </div>
        <p className="admin-meta-line" style={{ marginTop: -4 }}>
          Anyone listed here can sign into <code>/admin-dashboard</code>. To revoke
          access, demote the admin — their account stays so audit history is preserved.
        </p>

        {showCreate && (
          <form onSubmit={handleCreateAdmin} className="admin-settings-card" style={{ background: '#FAFAF7', marginTop: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <strong>Create new admin</strong>
              <button type="button" className="admin-icon-btn" onClick={() => setShowCreate(false)} aria-label="Cancel">
                <FiX size={14} />
              </button>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 12, marginTop: 12 }}>
              <div className="admin-field">
                <label>Email *</label>
                <input
                  type="email" required value={newAdmin.email}
                  onChange={(e) => setNewAdmin({ ...newAdmin, email: e.target.value })}
                />
              </div>
              <div className="admin-field">
                <label>Temporary password *</label>
                <input
                  type="text" required minLength={8} value={newAdmin.password}
                  onChange={(e) => setNewAdmin({ ...newAdmin, password: e.target.value })}
                />
                <span className="admin-field__hint">8+ chars. Share securely with the new admin.</span>
              </div>
              <div className="admin-field">
                <label>Full name</label>
                <input
                  type="text" value={newAdmin.full_name}
                  onChange={(e) => setNewAdmin({ ...newAdmin, full_name: e.target.value })}
                />
              </div>
              <div className="admin-field">
                <label>Phone</label>
                <input
                  type="tel" value={newAdmin.phone}
                  onChange={(e) => setNewAdmin({ ...newAdmin, phone: e.target.value })}
                />
              </div>
            </div>
            <div style={{ marginTop: 12, display: 'flex', gap: 10 }}>
              <button type="submit" className="btn-primary" disabled={creating}>
                <FiUserPlus size={15} />
                {creating ? 'Creating…' : 'Create Admin'}
              </button>
              <button type="button" className="btn-outline" onClick={() => setShowCreate(false)}>
                Cancel
              </button>
            </div>
          </form>
        )}

        <div className="admin-table-wrapper" style={{ marginTop: 14 }}>
          {adminsLoading ? (
            <p className="admin-empty">Loading…</p>
          ) : admins.length === 0 ? (
            <p className="admin-empty">No admins found. Strange — you should be on this list.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Email</th>
                  <th>Name</th>
                  <th>Phone</th>
                  <th>Status</th>
                  <th>Joined</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {admins.map((a) => {
                  const isMe = a.id === me?.id;
                  return (
                    <tr key={a.id}>
                      <td>
                        <strong>{a.email}</strong>
                        {isMe && <span className="admin-meta-line" style={{ color: '#0EA5E9' }}>You</span>}
                      </td>
                      <td>{a.full_name || '—'}</td>
                      <td>{a.phone || '—'}</td>
                      <td>
                        {a.is_blocked
                          ? <span className="status-badge status-badge--rejected">Blocked</span>
                          : a.is_active
                            ? <span className="status-badge status-badge--approved">Active</span>
                            : <span className="status-badge status-badge--pending">Inactive</span>}
                      </td>
                      <td>{a.date_joined ? formatDate(a.date_joined) : '—'}</td>
                      <td>
                        {!isMe && (
                          <button
                            className="admin-icon-btn admin-icon-btn--danger"
                            onClick={() => handleDemote(a)}
                            title="Demote to regular user"
                          >
                            <FiTrash2 size={14} /> Demote
                          </button>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
