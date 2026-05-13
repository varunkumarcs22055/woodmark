/**
 * AdminCategories — list + add/edit modal + delete (soft if products exist).
 *
 * Endpoints:
 *   GET    /api/categories/admin/
 *   POST   /api/categories/admin/
 *   PATCH  /api/categories/admin/{id}/
 *   DELETE /api/categories/admin/{id}/
 *   GET    /api/categories/tree/    (used by storefront — not directly here)
 */
import { useEffect, useState } from 'react';
import { FiPlus, FiEdit2, FiTrash2, FiX } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchAdminCategories,
  createCategory, updateCategory, deleteCategory,
} from '../../api';

const EMPTY = { name: '', description: '', parent: '', is_active: true, sort_order: 0 };

export default function AdminCategories() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState({ open: false, editing: null });
  const [form, setForm] = useState(EMPTY);
  const [saving, setSaving] = useState(false);
  const [errors, setErrors] = useState({});

  const load = async () => {
    setLoading(true);
    try {
      const data = await fetchAdminCategories();
      setRows(data.results || data || []);
    } catch {
      toast.error('Failed to load categories');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const openAdd = () => {
    setModal({ open: true, editing: null });
    setForm(EMPTY);
    setErrors({});
  };
  const openEdit = (cat) => {
    setModal({ open: true, editing: cat });
    setForm({
      name: cat.name,
      description: cat.description || '',
      parent: cat.parent || '',
      is_active: cat.is_active,
      sort_order: cat.sort_order ?? 0,
    });
    setErrors({});
  };
  const close = () => setModal({ open: false, editing: null });

  const save = async (e) => {
    e.preventDefault();
    setSaving(true);
    setErrors({});
    try {
      const payload = {
        name: form.name.trim(),
        description: form.description.trim(),
        is_active: !!form.is_active,
        sort_order: Number.parseInt(form.sort_order, 10) || 0,
      };
      if (form.parent) payload.parent = form.parent;
      else payload.parent = null;

      if (modal.editing) {
        await updateCategory(modal.editing.id, payload);
        toast.success('Category updated.');
      } else {
        await createCategory(payload);
        toast.success('Category created.');
      }
      close();
      await load();
    } catch (err) {
      const data = err.response?.data || {};
      setErrors(data);
      toast.error(
        data.detail ||
        Object.values(data).flat()[0] ||
        'Save failed.'
      );
    } finally {
      setSaving(false);
    }
  };

  const remove = async (cat) => {
    if (!window.confirm(
      `Delete "${cat.name}"? If products are attached, it will be deactivated instead.`
    )) return;
    try {
      const r = await deleteCategory(cat.id);
      toast.success(r?.soft_deleted ? 'Deactivated (had products).' : 'Deleted.');
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Delete failed.');
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Categories</h2>
        <button className="btn-primary" onClick={openAdd}>
          <FiPlus size={16} /> Add Category
        </button>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : rows.length === 0 ? (
          <p className="admin-empty">No categories yet.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Slug</th>
                <th>Parent</th>
                <th>Products</th>
                <th>Children</th>
                <th>Sort</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((c) => {
                const parent = rows.find((r) => r.id === c.parent);
                return (
                  <tr key={c.id}>
                    <td><strong>{c.name}</strong></td>
                    <td><code>{c.slug}</code></td>
                    <td>{parent?.name || '—'}</td>
                    <td>{c.product_count ?? 0}</td>
                    <td>{c.child_count ?? 0}</td>
                    <td>{c.sort_order ?? 0}</td>
                    <td>
                      <span className={`status-badge status-badge--${c.is_active ? 'confirmed' : 'cancelled'}`}>
                        {c.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td>
                      <button className="admin-icon-btn" onClick={() => openEdit(c)} aria-label="Edit">
                        <FiEdit2 size={14} />
                      </button>
                      <button
                        className="admin-icon-btn admin-icon-btn--danger"
                        onClick={() => remove(c)}
                        aria-label="Delete"
                      >
                        <FiTrash2 size={14} />
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {modal.open && (
        <div className="admin-modal-overlay" onClick={close}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
            <div className="admin-modal__header">
              <h3>{modal.editing ? 'Edit Category' : 'Add Category'}</h3>
              <button className="admin-modal__close" onClick={close}><FiX /></button>
            </div>
            <form onSubmit={save}>
              <div className="admin-modal__body">
                <div className="admin-form-grid">
                  <Field label="Name" error={errors.name}>
                    <input value={form.name}
                      onChange={(e) => setForm({ ...form, name: e.target.value })} required />
                  </Field>
                  <Field label="Sort order" error={errors.sort_order}>
                    <input type="number" min="0" value={form.sort_order}
                      onChange={(e) => setForm({ ...form, sort_order: e.target.value })} />
                  </Field>
                  <Field label="Parent" error={errors.parent}>
                    <select value={form.parent}
                      onChange={(e) => setForm({ ...form, parent: e.target.value })}>
                      <option value="">— Top level —</option>
                      {rows
                        .filter((r) => !modal.editing || r.id !== modal.editing.id)
                        .map((c) => (
                          <option key={c.id} value={c.id}>{c.name}</option>
                        ))}
                    </select>
                  </Field>
                  <Field label="Active?">
                    <label className="admin-toggle">
                      <input type="checkbox" checked={form.is_active}
                        onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
                      <span>Visible on storefront</span>
                    </label>
                  </Field>
                </div>
                <Field label="Description" error={errors.description}>
                  <textarea rows={3} value={form.description}
                    onChange={(e) => setForm({ ...form, description: e.target.value })} />
                </Field>
              </div>
              <div className="admin-modal__footer">
                <button type="button" className="btn-outline" onClick={close}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving}>
                  {saving ? 'Saving…' : modal.editing ? 'Save Changes' : 'Create Category'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

function Field({ label, error, children }) {
  return (
    <div className={`admin-field ${error ? 'admin-field--error' : ''}`}>
      <label>{label}</label>
      {children}
      {error && <span className="admin-field__error">{Array.isArray(error) ? error[0] : String(error)}</span>}
    </div>
  );
}
