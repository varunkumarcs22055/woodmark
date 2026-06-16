/**
 * DealerProfile — view + edit personal info; business info is read-only.
 */
import { useState } from 'react';
import { FiEdit2, FiSave, FiX, FiCheckCircle } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { useAuth } from '../../context/AuthContext';
import { updateProfile } from '../../api';
import DealerStatusBadge from '../../components/dealer/DealerStatusBadge';
import { formatDate } from '../../utils/format';

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
        <div className="dealer-profile__card">
          <div className="dealer-profile__card-header">
            <h2>Dealer Status</h2>
            <DealerStatusBadge status={user?.dealer_status} />
          </div>
          <div className="dealer-profile__status-row">
            <FiCheckCircle color="var(--color-success)" size={28} />
            <div>
              <strong>Active Dealer Account</strong>
              <p>You have access to dealer pricing and discounts on all eligible products.</p>
            </div>
          </div>
          {user?.date_joined && (
            <div className="dealer-profile__meta">
              Member since: <strong>{formatDate(user.date_joined)}</strong>
            </div>
          )}
        </div>

        <div className="dealer-profile__card">
          <div className="dealer-profile__card-header">
            <h2>Personal Information</h2>
            {!editing && (
              <button onClick={() => setEditing(true)} className="dealer-profile__edit-btn">
                <FiEdit2 size={14} /> Edit
              </button>
            )}
          </div>

          {editing ? (
            <form onSubmit={handleSave} className="dealer-profile__form">
              <div className="dealer-profile__field">
                <label>Full Name</label>
                <input
                  type="text"
                  value={form.full_name}
                  onChange={(e) => setForm({ ...form, full_name: e.target.value })}
                  required
                />
              </div>
              <div className="dealer-profile__field">
                <label>Phone Number</label>
                <input
                  type="tel"
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                  pattern="\d{10}"
                  required
                />
              </div>
              <div className="dealer-profile__field">
                <label>Email (read-only)</label>
                <input type="email" value={user?.email || ''} disabled />
              </div>
              <div className="dealer-profile__form-actions">
                <button type="submit" className="btn-primary" disabled={saving}>
                  <FiSave size={14} /> {saving ? 'Saving…' : 'Save Changes'}
                </button>
                <button type="button" onClick={handleCancel} className="btn-outline">
                  <FiX size={14} /> Cancel
                </button>
              </div>
            </form>
          ) : (
            <dl className="dealer-profile__list">
              <div><dt>Full Name</dt><dd>{user?.full_name || '—'}</dd></div>
              <div><dt>Email</dt><dd>{user?.email}</dd></div>
              <div><dt>Phone</dt><dd>{user?.phone || '—'}</dd></div>
            </dl>
          )}
        </div>

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
            To update business details (company name, GST), please contact{' '}
            <a href="mailto:dealers@woodmark.in">dealers@woodmark.in</a>.
            Changes require re-verification.
          </p>
        </div>
      </div>
    </div>
  );
}
