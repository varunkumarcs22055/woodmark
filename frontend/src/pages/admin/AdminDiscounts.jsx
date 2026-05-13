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
  const [minQty, setMinQty] = useState('1');
  const [countLimit, setCountLimit] = useState('');
  const [startsAt, setStartsAt] = useState('');     // datetime-local "" = no start gate
  const [endsAt, setEndsAt] = useState('');         // datetime-local "" = never expires
  const [saving, setSaving] = useState(false);

  const loadDiscounts = async () => {
    setLoading(true);
    try {
      const data = await fetchDiscounts({ discount_type: tab });
      setDiscounts(Array.isArray(data) ? data : Array.isArray(data?.results) ? data.results : []);
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
        setProductOptions(Array.isArray(data) ? data : Array.isArray(data?.results) ? data.results : []);
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
    setMinQty('1');
    setCountLimit('');
    setStartsAt('');
    setEndsAt('');
    setMode('percent');
  };

  // Format a Date as the local datetime-local input wants ("YYYY-MM-DDTHH:mm")
  // — `toISOString` gives UTC and breaks the displayed value.
  const toLocalInput = (date) => {
    const pad = (n) => String(n).padStart(2, '0');
    return (
      `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
      `T${pad(date.getHours())}:${pad(date.getMinutes())}`
    );
  };

  // Quick-pick presets so admins don't have to do mental date math.
  const quickPickEnds = (label) => {
    const now = new Date();
    if (label === 'never') { setEndsAt(''); return; }
    const map = { '1h': 1, '6h': 6, '12h': 12, '24h': 24, '3d': 72, '7d': 168, '30d': 720 };
    const hours = map[label] ?? 0;
    if (hours > 0) {
      const ends = new Date(now.getTime() + hours * 3600 * 1000);
      setEndsAt(toLocalInput(ends));
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    if (!selectedProduct) {
      toast.error('Please select a product');
      return;
    }
    const numericValue = Number.parseFloat(value);
    if (!Number.isFinite(numericValue) || numericValue <= 0) {
      toast.error('Enter a valid discount value');
      return;
    }
    const numericMinQty = Number.parseInt(minQty, 10);
    if (!Number.isFinite(numericMinQty) || numericMinQty < 1) {
      toast.error('Min quantity must be at least 1');
      return;
    }
    if (startsAt && endsAt && new Date(endsAt) <= new Date(startsAt)) {
      toast.error('End time must be after start time.');
      return;
    }
    if (endsAt && new Date(endsAt) <= new Date()) {
      toast.error('End time is in the past — pick a future moment.');
      return;
    }
    setSaving(true);
    try {
      await createDiscount({
        product: selectedProduct.id,
        discount_type: tab,
        mode,
        value: numericValue,
        min_quantity: numericMinQty,
        count_limit: countLimit ? Number.parseInt(countLimit, 10) : null,
        // datetime-local has no timezone — convert to ISO so the backend
        // stores it as UTC. Empty strings stay null (= no gate).
        starts_at: startsAt ? new Date(startsAt).toISOString() : null,
        ends_at: endsAt ? new Date(endsAt).toISOString() : null,
        active: true,
      });
      toast.success(
        numericMinQty > 1
          ? `Tier added: ${numericValue}${mode === 'percent' ? '%' : '₹'} off on ${numericMinQty}+ units`
          : 'Discount created.'
      );
      resetForm();
      await loadDiscounts();
    } catch (err) {
      const data = err.response?.data || {};
      const msg =
        data.detail ||
        data.non_field_errors?.[0] ||
        Object.values(data).flat()[0] ||
        'Failed to create discount';
      toast.error(typeof msg === 'string' ? msg : 'Failed to create discount');
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

  const renderWindowBadge = (startsAtISO, endsAtISO) => {
    const now = Date.now();
    const start = startsAtISO ? new Date(startsAtISO).getTime() : null;
    const end = endsAtISO ? new Date(endsAtISO).getTime() : null;

    if (start && now < start) {
      const hrs = Math.ceil((start - now) / 3_600_000);
      return <span className="status-badge status-badge--shipped">starts in {hrs}h</span>;
    }
    if (end && now > end) {
      return <span className="status-badge status-badge--cancelled">expired</span>;
    }
    if (end) {
      const ms = end - now;
      const days = Math.floor(ms / 86_400_000);
      const hrs = Math.floor((ms % 86_400_000) / 3_600_000);
      const mins = Math.floor((ms % 3_600_000) / 60_000);
      const label = days >= 1 ? `${days}d ${hrs}h left`
                  : hrs >= 1   ? `${hrs}h ${mins}m left`
                                : `${mins}m left`;
      const cls = days < 1 ? 'status-badge--cancelled'
                : days < 3 ? 'status-badge--shipped'
                            : 'status-badge--confirmed';
      return <span className={`status-badge ${cls}`}>⏱ {label}</span>;
    }
    return <span className="status-badge status-badge--shipped">No expiry</span>;
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
              <label>Min Quantity (tier)</label>
              <input type="number" min="1" step="1" value={minQty}
                onChange={(e) => setMinQty(e.target.value)}
                placeholder="1 = always · 5 = on 5+ units" required />
            </div>

            <div className="admin-field">
              <label>Count Limit</label>
              <input type="number" min="0" value={countLimit}
                onChange={(e) => setCountLimit(e.target.value)}
                placeholder="Blank = unlimited" />
            </div>

            <div className="admin-field">
              <label>Starts at (optional)</label>
              <input
                type="datetime-local"
                value={startsAt}
                onChange={(e) => setStartsAt(e.target.value)}
              />
            </div>

            <div className="admin-field">
              <label>Ends at (optional)</label>
              <input
                type="datetime-local"
                value={endsAt}
                onChange={(e) => setEndsAt(e.target.value)}
              />
              <div className="admin-quickpicks">
                {[
                  ['1h', '1 hr'],
                  ['6h', '6 hrs'],
                  ['12h', '12 hrs'],
                  ['24h', '24 hrs'],
                  ['3d', '3 days'],
                  ['7d', '7 days'],
                  ['30d', '30 days'],
                  ['never', 'No expiry'],
                ].map(([key, label]) => (
                  <button
                    key={key}
                    type="button"
                    className="admin-quickpick"
                    onClick={() => quickPickEnds(key)}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <p className="admin-meta-line" style={{ marginTop: 8 }}>
            Add multiple rows for the same product with increasing min-quantity values to build a
            volume ladder (e.g. <code>2 → 20%</code>, <code>5 → 30%</code>, <code>10 → 40%</code>).
            The cart picks the highest tier the buyer qualifies for. Set <strong>Ends at</strong> to
            make a limited-time offer that surfaces on the storefront's Limited Time Offers strip.
          </p>

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
                <th>Min Qty</th>
                <th>Mode</th>
                <th>Value</th>
                <th>Limit</th>
                <th>Sold</th>
                <th>Window</th>
                <th>Remaining</th>
                <th style={{ width: 60 }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {[...discounts]
                .sort((a, b) => {
                  const an = (a.product_name || '').localeCompare(b.product_name || '');
                  return an !== 0 ? an : (a.min_quantity || 1) - (b.min_quantity || 1);
                })
                .map((d) => (
                  <tr key={d.id}>
                    <td><strong>{d.product_name || `#${d.product}`}</strong></td>
                    <td>
                      {(d.min_quantity || 1) === 1
                        ? <span className="admin-meta-line">any</span>
                        : <strong>{d.min_quantity}+</strong>}
                    </td>
                    <td>{d.mode === 'percent' ? '%' : '₹'}</td>
                    <td>{d.mode === 'percent' ? `${d.value}%` : formatPrice(d.value)}</td>
                    <td>{d.count_limit ?? '∞'}</td>
                    <td>{d.units_sold || 0}</td>
                    <td>{renderWindowBadge(d.starts_at, d.ends_at)}</td>
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
