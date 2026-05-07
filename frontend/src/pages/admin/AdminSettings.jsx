import { useState, useEffect } from 'react';
import { FiSave } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchStoreSettings, updateStoreSettings } from '../../api';

export default function AdminSettings() {
  const [form, setForm] = useState({
    gst_percent: '',
    free_shipping_threshold: '',
    standard_shipping_fee: '',
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

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
    </div>
  );
}
