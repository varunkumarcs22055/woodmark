/**
 * AdminInventory — stock levels grid + adjust modal + per-row movement history.
 *
 * Endpoints:
 *   GET  /api/inventory/warehouses/
 *   POST /api/inventory/warehouses/
 *   GET  /api/inventory/levels/?warehouse=&low=true
 *   GET  /api/inventory/levels/{id}/movements/
 *   POST /api/inventory/adjust/
 */
import { useEffect, useMemo, useState } from 'react';
import { FiAlertTriangle, FiPlus, FiX, FiList, FiPackage, FiZap } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchWarehouses, createWarehouse,
  fetchStockLevels, fetchStockMovements, adjustStock,
  createStockLevel, seedStockForAllProducts,
  fetchProducts,
} from '../../api';
import { formatDateTime } from '../../utils/format';

const REASONS = [
  { value: 'adjustment', label: 'Manual adjustment' },
  { value: 'inbound', label: 'Inbound (receive stock)' },
  { value: 'return', label: 'Return restock' },
];

export default function AdminInventory() {
  const [tab, setTab] = useState('levels');
  const [warehouses, setWarehouses] = useState([]);
  const [levels, setLevels] = useState([]);
  const [filterWh, setFilterWh] = useState('');
  const [showLowOnly, setShowLowOnly] = useState(false);
  const [loading, setLoading] = useState(true);

  const [adjust, setAdjust] = useState(null);     // selected stock level for adjust modal
  const [movements, setMovements] = useState(null); // { level, rows }
  const [whModal, setWhModal] = useState(false);
  const [seedModal, setSeedModal] = useState(false);
  const [bulkSeedModal, setBulkSeedModal] = useState(false);

  const loadAll = async () => {
    setLoading(true);
    try {
      const [w, l] = await Promise.all([
        fetchWarehouses(),
        fetchStockLevels({
          ...(filterWh && { warehouse: filterWh }),
          ...(showLowOnly && { low: 'true' }),
        }),
      ]);
      setWarehouses(w.results || w || []);
      setLevels(l.results || l || []);
    } catch {
      toast.error('Failed to load inventory');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadAll(); /* eslint-disable-next-line */ }, [filterWh, showLowOnly]);

  const counts = useMemo(() => ({
    total: levels.length,
    low: levels.filter((l) => l.is_low).length,
  }), [levels]);

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Inventory</h2>
        <span className="admin-meta-line">
          {warehouses.length} warehouses · {counts.total} stock rows · {counts.low} low
        </span>
      </div>

      <div className="admin-toolbar">
        <button
          className={`btn-outline ${tab === 'levels' ? 'is-active' : ''}`}
          onClick={() => setTab('levels')}
        >
          Stock levels
        </button>
        <button
          className={`btn-outline ${tab === 'warehouses' ? 'is-active' : ''}`}
          onClick={() => setTab('warehouses')}
        >
          Warehouses
        </button>
      </div>

      {tab === 'levels' && (
        <>
          <div className="admin-toolbar">
            <select value={filterWh} onChange={(e) => setFilterWh(e.target.value)}>
              <option value="">All warehouses</option>
              {warehouses.map((w) => (
                <option key={w.id} value={w.id}>{w.name} [{w.code}]</option>
              ))}
            </select>
            <label className="admin-toggle">
              <input
                type="checkbox"
                checked={showLowOnly}
                onChange={(e) => setShowLowOnly(e.target.checked)}
              />
              <span>Low stock only</span>
            </label>
            <div style={{ marginLeft: 'auto', display: 'flex', gap: 8 }}>
              <button
                className="btn-outline"
                onClick={() => setSeedModal(true)}
                disabled={warehouses.length === 0}
                title={warehouses.length === 0 ? 'Create a warehouse first.' : 'Seed stock for one product'}
              >
                <FiPackage size={14} /> Seed Stock
              </button>
              <button
                className="btn-primary"
                onClick={() => setBulkSeedModal(true)}
                disabled={warehouses.length === 0}
                title={warehouses.length === 0 ? 'Create a warehouse first.' : 'Bulk-seed every product into a warehouse'}
              >
                <FiZap size={14} /> Seed All Products
              </button>
            </div>
          </div>

          <div className="admin-table-wrapper">
            {loading ? (
              <p className="admin-empty">Loading…</p>
            ) : levels.length === 0 ? (
              <div className="admin-empty" style={{ display: 'flex', flexDirection: 'column',
                                                    gap: 10, padding: '40px 24px' }}>
                <FiPackage size={32} style={{ color: '#9CA3AF' }} />
                <strong style={{ color: '#111827' }}>No stock levels yet</strong>
                <p style={{ margin: 0, color: '#6B7280', maxWidth: 420, textAlign: 'center' }}>
                  {warehouses.length === 0
                    ? 'Create at least one warehouse first, then seed stock for your products.'
                    : 'Use "Seed All Products" to one-click create stock rows for every product in a warehouse, or "Seed Stock" to add a single row.'}
                </p>
                <div style={{ display: 'flex', gap: 10, marginTop: 6 }}>
                  {warehouses.length === 0 ? (
                    <button className="btn-primary" onClick={() => { setTab('warehouses'); setWhModal(true); }}>
                      Add Warehouse
                    </button>
                  ) : (
                    <>
                      <button className="btn-outline" onClick={() => setSeedModal(true)}>
                        Seed Stock
                      </button>
                      <button className="btn-primary" onClick={() => setBulkSeedModal(true)}>
                        Seed All Products
                      </button>
                    </>
                  )}
                </div>
              </div>
            ) : (
              <table className="admin-table">
                <thead>
                  <tr>
                    <th>Product</th>
                    <th>SKU</th>
                    <th>Variant</th>
                    <th>Warehouse</th>
                    <th>Quantity</th>
                    <th>Threshold</th>
                    <th>Updated</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  {levels.map((l) => (
                    <tr key={l.id}>
                      <td><strong>{l.product_name}</strong></td>
                      <td><code>{l.product_sku || '—'}</code></td>
                      <td>{l.variant_label || '—'}</td>
                      <td>{l.warehouse_name} <span className="admin-meta-line">[{l.warehouse_code}]</span></td>
                      <td>
                        <span className={l.is_low ? 'admin-stock-warn' : ''}>
                          {l.is_low && <FiAlertTriangle size={12} />} {l.quantity}
                        </span>
                      </td>
                      <td>{l.low_threshold}</td>
                      <td>{formatDateTime(l.updated_at)}</td>
                      <td>
                        <button className="admin-icon-btn" onClick={() => setAdjust(l)}>
                          Adjust
                        </button>
                        <button
                          className="admin-icon-btn"
                          onClick={async () => {
                            try {
                              const m = await fetchStockMovements(l.id);
                              setMovements({ level: l, rows: m.results || m || [] });
                            } catch { toast.error('Failed to load movements'); }
                          }}
                        >
                          <FiList size={14} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}

      {tab === 'warehouses' && (
        <>
          <div className="admin-toolbar">
            <button className="btn-primary" onClick={() => setWhModal(true)}>
              <FiPlus size={16} /> Add Warehouse
            </button>
          </div>
          <div className="admin-table-wrapper">
            {warehouses.length === 0 ? (
              <p className="admin-empty">No warehouses yet.</p>
            ) : (
              <table className="admin-table">
                <thead>
                  <tr><th>Name</th><th>Code</th><th>Address</th><th>Active</th></tr>
                </thead>
                <tbody>
                  {warehouses.map((w) => (
                    <tr key={w.id}>
                      <td><strong>{w.name}</strong></td>
                      <td><code>{w.code}</code></td>
                      <td>{w.address || '—'}</td>
                      <td>
                        <span className={`status-badge status-badge--${w.is_active ? 'confirmed' : 'cancelled'}`}>
                          {w.is_active ? 'Yes' : 'No'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}

      {adjust && (
        <AdjustModal
          level={adjust}
          onClose={() => setAdjust(null)}
          onSaved={async () => {
            setAdjust(null);
            await loadAll();
          }}
        />
      )}

      {movements && (
        <MovementsModal
          level={movements.level}
          rows={movements.rows}
          onClose={() => setMovements(null)}
        />
      )}

      {whModal && (
        <WarehouseModal
          onClose={() => setWhModal(false)}
          onSaved={async () => {
            setWhModal(false);
            await loadAll();
          }}
        />
      )}

      {seedModal && (
        <SeedStockModal
          warehouses={warehouses}
          onClose={() => setSeedModal(false)}
          onSaved={async () => {
            setSeedModal(false);
            await loadAll();
          }}
        />
      )}

      {bulkSeedModal && (
        <BulkSeedModal
          warehouses={warehouses}
          onClose={() => setBulkSeedModal(false)}
          onSaved={async () => {
            setBulkSeedModal(false);
            await loadAll();
          }}
        />
      )}
    </div>
  );
}

function AdjustModal({ level, onClose, onSaved }) {
  const [delta, setDelta] = useState('');
  const [reason, setReason] = useState('adjustment');
  const [note, setNote] = useState('');
  const [saving, setSaving] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    const n = Number.parseInt(delta, 10);
    if (!Number.isFinite(n) || n === 0) {
      toast.error('Delta must be a non-zero integer.');
      return;
    }
    setSaving(true);
    try {
      await adjustStock({ stock_level: level.id, delta: n, reason, note });
      toast.success('Stock adjusted.');
      onSaved();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Adjust failed.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <div className="admin-modal__header">
          <h3>Adjust Stock</h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>
        <form onSubmit={submit}>
          <div className="admin-modal__body">
            <p className="admin-meta-line">
              {level.product_name} ({level.warehouse_code}) · current: <strong>{level.quantity}</strong>
            </p>
            <div className="admin-form-grid">
              <div className="admin-field">
                <label>Delta (positive = inbound, negative = outbound)</label>
                <input
                  type="number" step="1" required
                  value={delta} onChange={(e) => setDelta(e.target.value)}
                  placeholder="e.g. 25 or -3"
                />
              </div>
              <div className="admin-field">
                <label>Reason</label>
                <select value={reason} onChange={(e) => setReason(e.target.value)}>
                  {REASONS.map((r) => <option key={r.value} value={r.value}>{r.label}</option>)}
                </select>
              </div>
            </div>
            <div className="admin-field">
              <label>Note</label>
              <textarea rows={3} value={note} onChange={(e) => setNote(e.target.value)} />
            </div>
          </div>
          <div className="admin-modal__footer">
            <button type="button" className="btn-outline" onClick={onClose}>Cancel</button>
            <button type="submit" className="btn-primary" disabled={saving}>
              {saving ? 'Saving…' : 'Apply Adjustment'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function MovementsModal({ level, rows, onClose }) {
  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <div className="admin-modal__header">
          <h3>Movements — {level.product_name} @ {level.warehouse_code}</h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>
        <div className="admin-modal__body">
          {rows.length === 0 ? (
            <p className="admin-empty">No movements yet.</p>
          ) : (
            <table className="admin-table admin-table--compact">
              <thead>
                <tr><th>When</th><th>Δ</th><th>Reason</th><th>By</th><th>Note</th></tr>
              </thead>
              <tbody>
                {rows.map((m) => (
                  <tr key={m.id}>
                    <td>{formatDateTime(m.created_at)}</td>
                    <td>
                      <strong style={{ color: m.delta >= 0 ? '#0a7e3f' : '#b91c1c' }}>
                        {m.delta >= 0 ? '+' : ''}{m.delta}
                      </strong>
                    </td>
                    <td>{m.reason}</td>
                    <td>{m.actor_email || 'system'}</td>
                    <td>{m.note || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}

function SeedStockModal({ warehouses, onClose, onSaved }) {
  const [products, setProducts] = useState([]);
  const [productId, setProductId] = useState('');
  const [warehouseId, setWarehouseId] = useState(warehouses[0]?.id || '');
  const [quantity, setQuantity] = useState('100');
  const [threshold, setThreshold] = useState('5');
  const [saving, setSaving] = useState(false);
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchProducts({ page_size: 200 })
      .then((d) => setProducts(d.results || d || []))
      .catch(() => setProducts([]));
  }, []);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return products.slice(0, 50);
    return products.filter((p) => p.name.toLowerCase().includes(q)).slice(0, 50);
  }, [products, search]);

  const submit = async (e) => {
    e.preventDefault();
    if (!productId || !warehouseId) {
      toast.error('Pick a product and a warehouse.');
      return;
    }
    setSaving(true);
    try {
      await createStockLevel({
        product: productId,
        warehouse: warehouseId,
        quantity: parseInt(quantity, 10) || 0,
        low_threshold: parseInt(threshold, 10) || 0,
      });
      toast.success('Stock row created.');
      onSaved();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Could not create stock row.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <div className="admin-modal__header">
          <h3>Seed Stock</h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>
        <form onSubmit={submit}>
          <div className="admin-modal__body">
            <div className="admin-form-grid">
              <div className="admin-field">
                <label>Search products</label>
                <input
                  type="search"
                  placeholder="Type to filter…"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
              </div>
              <div className="admin-field">
                <label>Product</label>
                <select value={productId} onChange={(e) => setProductId(e.target.value)} required>
                  <option value="">Select a product…</option>
                  {filtered.map((p) => (
                    <option key={p.id} value={p.id}>{p.name}</option>
                  ))}
                </select>
              </div>
              <div className="admin-field">
                <label>Warehouse</label>
                <select value={warehouseId} onChange={(e) => setWarehouseId(e.target.value)} required>
                  {warehouses.map((w) => (
                    <option key={w.id} value={w.id}>{w.name} [{w.code}]</option>
                  ))}
                </select>
              </div>
              <div className="admin-field">
                <label>Initial quantity</label>
                <input
                  type="number" min="0" step="1"
                  value={quantity} onChange={(e) => setQuantity(e.target.value)}
                />
              </div>
              <div className="admin-field">
                <label>Low-stock threshold</label>
                <input
                  type="number" min="0" step="1"
                  value={threshold} onChange={(e) => setThreshold(e.target.value)}
                />
              </div>
            </div>
            <p className="admin-meta-line" style={{ marginTop: 8 }}>
              Tip: if a row already exists for this (product, warehouse), its quantity will be
              updated instead of duplicated.
            </p>
          </div>
          <div className="admin-modal__footer">
            <button type="button" className="btn-outline" onClick={onClose}>Cancel</button>
            <button type="submit" className="btn-primary" disabled={saving}>
              {saving ? 'Saving…' : 'Save Stock Row'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function BulkSeedModal({ warehouses, onClose, onSaved }) {
  const [warehouseId, setWarehouseId] = useState(warehouses[0]?.id || '');
  const [quantity, setQuantity] = useState('0');
  const [threshold, setThreshold] = useState('5');
  const [onlyMissing, setOnlyMissing] = useState(true);
  const [saving, setSaving] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    if (!warehouseId) return toast.error('Pick a warehouse.');
    setSaving(true);
    try {
      const r = await seedStockForAllProducts({
        warehouse: warehouseId,
        quantity: parseInt(quantity, 10) || 0,
        low_threshold: parseInt(threshold, 10) || 0,
        only_missing: onlyMissing,
      });
      toast.success(
        `Done — ${r.created} created, ${r.updated} updated, ${r.skipped} skipped.`
      );
      onSaved();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Bulk seed failed.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <div className="admin-modal__header">
          <h3>Bulk-Seed All Products</h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>
        <form onSubmit={submit}>
          <div className="admin-modal__body">
            <p className="admin-meta-line">
              Creates one stock row for every active product in the selected warehouse.
              Existing rows are left alone (unless you uncheck "Only missing").
            </p>
            <div className="admin-form-grid">
              <div className="admin-field">
                <label>Warehouse</label>
                <select value={warehouseId} onChange={(e) => setWarehouseId(e.target.value)} required>
                  {warehouses.map((w) => (
                    <option key={w.id} value={w.id}>{w.name} [{w.code}]</option>
                  ))}
                </select>
              </div>
              <div className="admin-field">
                <label>Initial quantity (per product)</label>
                <input
                  type="number" min="0" step="1"
                  value={quantity} onChange={(e) => setQuantity(e.target.value)}
                />
              </div>
              <div className="admin-field">
                <label>Low-stock threshold</label>
                <input
                  type="number" min="0" step="1"
                  value={threshold} onChange={(e) => setThreshold(e.target.value)}
                />
              </div>
              <div className="admin-field">
                <label className="admin-toggle">
                  <input
                    type="checkbox"
                    checked={onlyMissing}
                    onChange={(e) => setOnlyMissing(e.target.checked)}
                  />
                  <span>Only create rows for products that don't have one yet</span>
                </label>
              </div>
            </div>
          </div>
          <div className="admin-modal__footer">
            <button type="button" className="btn-outline" onClick={onClose}>Cancel</button>
            <button type="submit" className="btn-primary" disabled={saving}>
              {saving ? 'Seeding…' : 'Run bulk seed'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function WarehouseModal({ onClose, onSaved }) {
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [address, setAddress] = useState('');
  const [saving, setSaving] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await createWarehouse({ name: name.trim(), code: code.trim().toUpperCase(), address });
      toast.success('Warehouse created.');
      onSaved();
    } catch (err) {
      const data = err.response?.data || {};
      toast.error(data.detail || Object.values(data).flat()[0] || 'Create failed.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <div className="admin-modal__header">
          <h3>Add Warehouse</h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>
        <form onSubmit={submit}>
          <div className="admin-modal__body">
            <div className="admin-form-grid">
              <div className="admin-field">
                <label>Name</label>
                <input value={name} onChange={(e) => setName(e.target.value)} required />
              </div>
              <div className="admin-field">
                <label>Code (short, unique)</label>
                <input value={code} onChange={(e) => setCode(e.target.value)} required maxLength={10} />
              </div>
            </div>
            <div className="admin-field">
              <label>Address</label>
              <textarea rows={3} value={address} onChange={(e) => setAddress(e.target.value)} />
            </div>
          </div>
          <div className="admin-modal__footer">
            <button type="button" className="btn-outline" onClick={onClose}>Cancel</button>
            <button type="submit" className="btn-primary" disabled={saving}>
              {saving ? 'Saving…' : 'Create Warehouse'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
