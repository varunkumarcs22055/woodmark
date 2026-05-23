import { useEffect, useState } from 'react';
import { FiEdit2, FiTrash2, FiPlus } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchShippingZones, createShippingZone,
  updateShippingZone, deleteShippingZone,
} from '../../api';

const EMPTY = {
  name: '',
  pincode_prefix: '',
  base_fee: 0,
  per_kg_fee: 0,
  free_shipping_threshold: 0,
  etd_days_min: 3,
  etd_days_max: 7,
  cod_available: true,
  is_active: true,
};

export default function AdminShipping() {
  const [zones, setZones] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState(EMPTY);

  const loadZones = async () => {
    setLoading(true);
    try {
      const data = await fetchShippingZones();
      const list = Array.isArray(data) ? data : data?.results || [];
      setZones(list);
    } catch {
      toast.error('Failed to load shipping zones');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadZones();
  }, []);

  const startEdit = (z) => {
    setEditing(z);
    setForm({
      name: z.name || '',
      pincode_prefix: z.pincode_prefix || '',
      base_fee: z.base_fee ?? 0,
      per_kg_fee: z.per_kg_fee ?? 0,
      free_shipping_threshold: z.free_shipping_threshold ?? 0,
      etd_days_min: z.etd_days_min ?? 3,
      etd_days_max: z.etd_days_max ?? 7,
      cod_available: !!z.cod_available,
      is_active: !!z.is_active,
    });
  };

  const resetForm = () => {
    setEditing(null);
    setForm(EMPTY);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editing) {
        await updateShippingZone(editing.id, form);
        toast.success('Zone updated');
      } else {
        await createShippingZone(form);
        toast.success('Zone created');
      }
      resetForm();
      loadZones();
    } catch (err) {
      const msg = err.response?.data?.pincode_prefix?.[0]
        || err.response?.data?.name?.[0]
        || err.response?.data?.detail
        || 'Failed to save zone';
      toast.error(msg);
    }
  };

  const handleDelete = async (z) => {
    if (!window.confirm(`Delete zone ${z.name}?`)) return;
    try {
      await deleteShippingZone(z.id);
      toast.success('Zone deleted');
      loadZones();
    } catch {
      toast.error('Failed to delete zone');
    }
  };

  return (
    <div className="admin-page">
      <h2 className="admin-page__title">Shipping Zones</h2>

      <form className="admin-card" onSubmit={handleSubmit} style={{ marginBottom: 20 }}>
        <h3 style={{ marginTop: 0 }}>{editing ? 'Edit Zone' : 'Add Zone'}</h3>
        <div className="admin-form-grid">
          <label className="admin-label">
            Name
            <input className="admin-input" value={form.name}
                   onChange={(e) => setForm({ ...form, name: e.target.value })} />
          </label>
          <label className="admin-label">
            Pincode prefix
            <input className="admin-input" value={form.pincode_prefix}
                   onChange={(e) => setForm({ ...form, pincode_prefix: e.target.value.replace(/\D/g, '').slice(0, 6) })}
                   placeholder="e.g. 11" />
          </label>
          <label className="admin-label">
            Base fee (INR)
            <input className="admin-input" type="number" step="0.01" value={form.base_fee}
                   onChange={(e) => setForm({ ...form, base_fee: e.target.value })} />
          </label>
          <label className="admin-label">
            Per kg fee (INR)
            <input className="admin-input" type="number" step="0.01" value={form.per_kg_fee}
                   onChange={(e) => setForm({ ...form, per_kg_fee: e.target.value })} />
          </label>
          <label className="admin-label">
            Free shipping threshold
            <input className="admin-input" type="number" step="0.01" value={form.free_shipping_threshold}
                   onChange={(e) => setForm({ ...form, free_shipping_threshold: e.target.value })} />
          </label>
          <label className="admin-label">
            ETD min (days)
            <input className="admin-input" type="number" value={form.etd_days_min}
                   onChange={(e) => setForm({ ...form, etd_days_min: e.target.value })} />
          </label>
          <label className="admin-label">
            ETD max (days)
            <input className="admin-input" type="number" value={form.etd_days_max}
                   onChange={(e) => setForm({ ...form, etd_days_max: e.target.value })} />
          </label>
          <label className="admin-label" style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <input type="checkbox" checked={form.cod_available}
                   onChange={(e) => setForm({ ...form, cod_available: e.target.checked })} />
            COD available
          </label>
          <label className="admin-label" style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <input type="checkbox" checked={form.is_active}
                   onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
            Active
          </label>
        </div>
        <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
          <button type="submit" className="btn-primary" style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
            <FiPlus /> {editing ? 'Save changes' : 'Add zone'}
          </button>
          {editing && (
            <button type="button" className="btn-outline" onClick={resetForm}>
              Cancel
            </button>
          )}
        </div>
      </form>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : zones.length === 0 ? (
          <p className="admin-empty">No shipping zones yet.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Prefix</th>
                <th>Base fee</th>
                <th>Per kg</th>
                <th>Free threshold</th>
                <th>ETD</th>
                <th>COD</th>
                <th>Active</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {zones.map((z) => (
                <tr key={z.id}>
                  <td>{z.name}</td>
                  <td>{z.pincode_prefix}</td>
                  <td>{z.base_fee}</td>
                  <td>{z.per_kg_fee}</td>
                  <td>{z.free_shipping_threshold}</td>
                  <td>{z.etd_days_min}-{z.etd_days_max}</td>
                  <td>{z.cod_available ? 'Yes' : 'No'}</td>
                  <td>{z.is_active ? 'Yes' : 'No'}</td>
                  <td style={{ whiteSpace: 'nowrap' }}>
                    <button className="admin-icon-btn" onClick={() => startEdit(z)}>
                      <FiEdit2 /> Edit
                    </button>
                    <button className="admin-icon-btn" onClick={() => handleDelete(z)}>
                      <FiTrash2 /> Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
