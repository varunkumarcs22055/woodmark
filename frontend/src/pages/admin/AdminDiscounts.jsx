/**
 * AdminDiscounts — two tabs (User / Dealer), product combobox + table.
 *
 * Backend (Backend Prompt 6):
 *   GET    /api/discounts/?discount_type=user|dealer
 *   POST   /api/discounts/
 *   PUT    /api/discounts/{id}/
 *   DELETE /api/discounts/{id}/
 */
import { useEffect, useState } from 'react';
import { FiTrash2, FiTag, FiSearch } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchProducts, fetchDiscounts, createDiscount, deleteDiscount,
} from '../../api';
import { formatPrice } from '../../utils/format';

export default function AdminDiscounts() {
  const [tab, setTab] = useState('user'); // 'user' | 'dealer'
  const [discounts, setDiscounts] = useState([]);
  const [loading, setLoading] = useState(true);

  // Form state
  const [productSearch, setProductSearch] = useState('');
  const [productOptions, setProductOptions] = useState([]);
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [mode, setMode] = useState('percent'); // percent | flat
  const [value, setValue] = useState('');
  const [countLimit, setCountLimit] = useState('');
  const [saving, setSaving] = useState(false);

  const loadDiscounts = async () => {
    setLoading(true);
    try {
      const data = await fetchDiscounts({ discount_type: tab });
      setDiscounts(data.results || data || []);
    } catch {
      setDiscounts([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadDiscounts(); }, [tab]);

  // Debounced product search
  useEffect(() => {
    if (productSearch.trim().length < 2) {
      setProductOptions([]);
      return;
    }
    const t = setTimeout(async () => {
      try {
        const data = await fetchProducts({ search: productSearch, page_size: 8 });
        setProductOptions(data.results || data || []);
      } catch {
        setProductOptions([]);
      }
    }, 300);
    return () => clearTimeout(t);
  }, [productSearch]);

  const resetForm = () => {
    setSelectedProduct(null);
    setProductSearch('');
    setProductOptions([]);
    setValue('');
    setCountLimit('');
    setMode('percent');
  };

  const handleSave = async (e) => {
    e.preventDefault();
    if (!selectedProduct) {
      toast.error('Please select a product');
      return;
    }
    if (!value || parseFloat(value) <= 0) {
      toast.error('Enter a valid discount value');
      return;
    }
    setSaving(true);
    try {
      await createDiscount({
        product: selectedProduct.id,
        discount_type: tab,
        mode,
        value: parseFloat(value),
        count_limit: countLimit ? parseInt(countLimit, 10) : null,
        is_active: true,
      });
      toast.success('Discount created!');
      resetForm();
      await loadDiscounts();
    } catch (err) {
      const msg = err.response?.data?.detail
        || err.response?.data?.product?.[0]
        || 'Failed to create discount';
      toast.error(msg);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id, productName) => {
    if (!window.confirm(`Delete discount on "${productName}"?`)) return;
    try {
      await deleteDiscount(id);
      toast.success('Discount removed');
      await loadDiscounts();
    } catch {
      toast.error('Failed to delete');
    }
  };

  const renderUnitsBadge = (limit, sold) => {
    if (limit === null || limit === undefined) {
      return <span className="status-badge status-badge--shipped">∞ Unlimited</span>;
    }
    const left = limit - (sold || 0);
    if (left <= 0) return <span className="status-badge status-badge--cancelled">Exhausted</span>;
    if (left <= 10) return <span className="status-badge status-badge--shipped">{left} left</span>;
    return <span className="status-badge status-badge--confirmed">{left} left</span>;
  };

  return (
    <div className="admin-page">
      <h2 className="admin-page__title">Discount Manager</h2>

      <div className="admin-tabs">
        <button
          className={`admin-tab ${tab === 'user' ? 'admin-tab--active' : ''}`}
          onClick={() => setTab('user')}
        >
          User Discounts
        </button>
        <button
          className={`admin-tab ${tab === 'dealer' ? 'admin-tab--active' : ''}`}
          onClick={() => setTab('dealer')}
        >
          Dealer Discounts
        </button>
      </div>

      {/* New discount form */}
      <section className="admin-card">
        <div className="admin-card__header">
          <h3>New {tab === 'user' ? 'User' : 'Dealer'} Discount</h3>
        </div>

        <form onSubmit={handleSave} className="admin-discount-form">
          <div className="admin-field">
            <label>Product</label>
            <div className="product-combobox">
              <div className="product-combobox__input-wrap">
                <FiSearch />
                <input
                  type="text"
                  value={selectedProduct ? selectedProduct.name : productSearch}
                  onChange={(e) => {
                    setSelectedProduct(null);
                    setProductSearch(e.target.value);
                  }}
                  placeholder="Search products by name (min 2 chars)…"
                />
              </div>
              {productOptions.length > 0 && !selectedProduct && (
                <div className="product-combobox__dropdown">
                  {productOptions.map((p) => (
                    <button
                      key={p.id}
                      type="button"
                      className="product-combobox__option"
                      onClick={() => {
                        setSelectedProduct(p);
                        setProductSearch('');
                        setProductOptions([]);
                      }}
                    >
                      <img src={p.image_url} alt="" />
                      <div>
                        <span className="product-combobox__name">{p.name}</span>
                        <span className="product-combobox__meta">
                          {p.category_name} · {formatPrice(p.price)}
                        </span>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          <div className="admin-form-grid">
            <div className="admin-field">
              <label>Mode</label>
              <div className="admin-radio-group">
                <label>
                  <input type="radio" name="mode" checked={mode === 'percent'}
                    onChange={() => setMode('percent')} /> Percentage (%)
                </label>
                <label>
                  <input type="radio" name="mode" checked={mode === 'flat'}
                    onChange={() => setMode('flat')} /> Flat (₹)
                </label>
              </div>
            </div>

            <div className="admin-field">
              <label>Value {mode === 'percent' ? '(%)' : '(₹)'}</label>
              <input type="number" min="0" step="0.01" value={value}
                onChange={(e) => setValue(e.target.value)}
                placeholder={mode === 'percent' ? 'e.g. 15' : 'e.g. 3000'} required />
            </div>

            <div className="admin-field">
              <label>Count Limit</label>
              <input type="number" min="0" value={countLimit}
                onChange={(e) => setCountLimit(e.target.value)}
                placeholder="Blank = unlimited" />
            </div>
          </div>

          <button type="submit" className="btn-primary" disabled={saving}>
            <FiTag size={14} /> {saving ? 'Saving…' : 'Save Discount'}
          </button>
        </form>
      </section>

      {/* Existing discounts */}
      <section className="admin-card" style={{ marginTop: 24 }}>
        <div className="admin-card__header">
          <h3>Active {tab === 'user' ? 'User' : 'Dealer'} Discounts</h3>
        </div>
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : discounts.length === 0 ? (
          <p className="admin-empty">No discounts yet. Create one above.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Product</th>
                <th>Mode</th>
                <th>Value</th>
                <th>Limit</th>
                <th>Sold</th>
                <th>Remaining</th>
                <th style={{ width: 60 }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {discounts.map((d) => (
                <tr key={d.id}>
                  <td><strong>{d.product_name || `#${d.product}`}</strong></td>
                  <td>{d.mode === 'percent' ? '%' : '₹'}</td>
                  <td>{d.mode === 'percent' ? `${d.value}%` : formatPrice(d.value)}</td>
                  <td>{d.count_limit ?? '∞'}</td>
                  <td>{d.units_sold || 0}</td>
                  <td>{renderUnitsBadge(d.count_limit, d.units_sold)}</td>
                  <td>
                    <button className="admin-icon-btn admin-icon-btn--danger"
                      onClick={() => handleDelete(d.id, d.product_name)} aria-label="Delete">
                      <FiTrash2 size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
