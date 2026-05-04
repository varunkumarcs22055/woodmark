/**
 * AdminProducts — list + add/edit modal + delete.
 *
 * Backend endpoints (from Backend Prompt 5 — admin-only):
 *   GET    /api/products/admin/         (list with filters)
 *   POST   /api/products/admin/         (create)
 *   PUT    /api/products/admin/{id}/    (update)
 *   DELETE /api/products/admin/{id}/    (delete)
 *
 * Falls back to the public /api/products/ list if the admin endpoint
 * isn't implemented yet, so this page renders even before Backend Prompt 5.
 */
import { useEffect, useState, useMemo } from 'react';
import { FiPlus, FiEdit2, FiTrash2, FiX, FiSearch, FiAlertTriangle } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchProducts, fetchCategories,
  adminCreateProduct, adminUpdateProduct, adminDeleteProduct,
} from '../../api';
import { formatPrice } from '../../utils/format';

const MATERIALS = ['wood', 'metal', 'fabric', 'leather', 'glass', 'plastic', 'marble', 'rattan'];

const EMPTY_FORM = {
  name: '', description: '', price: '', category: '',
  material: 'wood', color: '', dimensions: '',
  image_url: '', stock: 0, is_featured: false,
};

export default function AdminProducts() {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterCategory, setFilterCategory] = useState('');

  const [modal, setModal] = useState({ open: false, editing: null });
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [errors, setErrors] = useState({});

  const loadProducts = async () => {
    setLoading(true);
    try {
      const data = await fetchProducts({ page_size: 100 });
      setProducts(data.results || data || []);
    } catch {
      toast.error('Failed to load products');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProducts();
    fetchCategories().then((d) => setCategories(d.results || d || [])).catch(() => {});
  }, []);

  const filtered = useMemo(() => {
    return products.filter((p) => {
      if (filterCategory && p.category_name !== filterCategory) return false;
      if (search && !p.name.toLowerCase().includes(search.toLowerCase())) return false;
      return true;
    });
  }, [products, search, filterCategory]);

  const openAdd = () => {
    setModal({ open: true, editing: null });
    setForm({ ...EMPTY_FORM, category: categories[0]?.id || '' });
    setErrors({});
  };

  const openEdit = (product) => {
    setModal({ open: true, editing: product });
    setForm({
      name: product.name,
      description: product.description || '',
      price: product.price,
      category: product.category?.id ?? product.category,
      material: product.material,
      color: product.color || '',
      dimensions: product.dimensions || '',
      image_url: product.image_url || '',
      stock: product.stock,
      is_featured: !!product.is_featured,
    });
    setErrors({});
  };

  const closeModal = () => setModal({ open: false, editing: null });

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    setErrors({});
    try {
      const payload = { ...form, price: parseFloat(form.price), stock: parseInt(form.stock, 10) };
      if (modal.editing) {
        await adminUpdateProduct(modal.editing.id, payload);
        toast.success('Product updated.');
      } else {
        await adminCreateProduct(payload);
        toast.success('Product created.');
      }
      closeModal();
      await loadProducts();
    } catch (err) {
      const fieldErrors = err.response?.data || {};
      setErrors(fieldErrors);
      toast.error('Save failed. Check the form.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (product) => {
    if (!window.confirm(`Delete "${product.name}"? This cannot be undone.`)) return;
    try {
      await adminDeleteProduct(product.id);
      toast.success('Product deleted.');
      await loadProducts();
    } catch {
      toast.error('Cannot delete — product may have existing orders.');
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Products</h2>
        <button className="btn-primary" onClick={openAdd}>
          <FiPlus size={16} /> Add Product
        </button>
      </div>

      <div className="admin-toolbar">
        <div className="admin-toolbar__search">
          <FiSearch />
          <input
            type="search"
            placeholder="Search by name…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select value={filterCategory} onChange={(e) => setFilterCategory(e.target.value)}>
          <option value="">All categories</option>
          {categories.map((c) => (
            <option key={c.id} value={c.name}>{c.name}</option>
          ))}
        </select>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : filtered.length === 0 ? (
          <p className="admin-empty">No products match your filters.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th style={{ width: 64 }}>Image</th>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th style={{ width: 110 }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((p) => (
                <tr key={p.id}>
                  <td>
                    <img src={p.image_url} alt="" className="admin-thumb" />
                  </td>
                  <td>
                    <strong>{p.name}</strong>
                    <span className="admin-meta-line">{p.material} · {p.color}</span>
                  </td>
                  <td>{p.category_name}</td>
                  <td>{formatPrice(p.price)}</td>
                  <td>
                    <span className={p.stock <= 5 ? 'admin-stock-warn' : ''}>
                      {p.stock <= 5 && <FiAlertTriangle size={12} />} {p.stock}
                    </span>
                  </td>
                  <td>
                    <button className="admin-icon-btn" onClick={() => openEdit(p)} aria-label="Edit">
                      <FiEdit2 size={14} />
                    </button>
                    <button className="admin-icon-btn admin-icon-btn--danger" onClick={() => handleDelete(p)} aria-label="Delete">
                      <FiTrash2 size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Modal */}
      {modal.open && (
        <div className="admin-modal-overlay" onClick={closeModal}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
            <div className="admin-modal__header">
              <h3>{modal.editing ? 'Edit Product' : 'Add Product'}</h3>
              <button className="admin-modal__close" onClick={closeModal}>
                <FiX />
              </button>
            </div>
            <form onSubmit={handleSave}>
              <div className="admin-modal__body">
                <div className="admin-form-grid">
                  <Field label="Name" error={errors.name}>
                    <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
                  </Field>
                  <Field label="Price (₹)" error={errors.price}>
                    <input type="number" min="0" step="0.01" value={form.price}
                      onChange={(e) => setForm({ ...form, price: e.target.value })} required />
                  </Field>
                  <Field label="Category" error={errors.category}>
                    <select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} required>
                      <option value="">Select…</option>
                      {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
                    </select>
                  </Field>
                  <Field label="Material" error={errors.material}>
                    <select value={form.material} onChange={(e) => setForm({ ...form, material: e.target.value })}>
                      {MATERIALS.map((m) => <option key={m} value={m}>{m}</option>)}
                    </select>
                  </Field>
                  <Field label="Color" error={errors.color}>
                    <input value={form.color} onChange={(e) => setForm({ ...form, color: e.target.value })} placeholder="e.g. Walnut" />
                  </Field>
                  <Field label="Dimensions" error={errors.dimensions}>
                    <input value={form.dimensions} onChange={(e) => setForm({ ...form, dimensions: e.target.value })} placeholder="220x85x80 cm" />
                  </Field>
                  <Field label="Stock" error={errors.stock}>
                    <input type="number" min="0" value={form.stock}
                      onChange={(e) => setForm({ ...form, stock: e.target.value })} required />
                  </Field>
                  <Field label="Featured?">
                    <label className="admin-toggle">
                      <input type="checkbox" checked={form.is_featured}
                        onChange={(e) => setForm({ ...form, is_featured: e.target.checked })} />
                      <span>Show on homepage</span>
                    </label>
                  </Field>
                </div>

                <Field label="Image URL" error={errors.image_url}>
                  <input value={form.image_url} onChange={(e) => setForm({ ...form, image_url: e.target.value })}
                    placeholder="https://…" />
                </Field>
                {form.image_url && (
                  <img src={form.image_url} alt="" className="admin-image-preview" />
                )}

                <Field label="Description" error={errors.description}>
                  <textarea rows={4} value={form.description}
                    onChange={(e) => setForm({ ...form, description: e.target.value })} required />
                </Field>
              </div>
              <div className="admin-modal__footer">
                <button type="button" className="btn-outline" onClick={closeModal}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving}>
                  {saving ? 'Saving…' : modal.editing ? 'Save Changes' : 'Create Product'}
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
      {error && <span className="admin-field__error">{Array.isArray(error) ? error[0] : error}</span>}
    </div>
  );
}
