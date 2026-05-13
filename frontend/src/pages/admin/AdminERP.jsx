/**
 * AdminERP — ERP sync status with smart-default filter, retry, bulk retry.
 *
 * Default filter: "failed" when there's anything to triage, "all paid" once
 * the system is healthy — so the page is never blank by accident.
 *
 * Backend contract:
 *   GET  /api/orders/all/             every order with erp_order_id + erp_sync_status
 *   POST /api/orders/{pk}/retry-erp/  paid only; returns {erp_order_id} or 400
 */
import { useEffect, useMemo, useState } from 'react';
import {
  FiRefreshCw, FiCheckCircle, FiAlertTriangle, FiClock,
  FiSearch, FiZap, FiActivity,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchAllOrders, retryErpSync } from '../../api';
import { formatDateTime } from '../../utils/format';
import './AdminERP.css';

const FILTERS = [
  { key: 'failed',  label: 'Failed sync', tone: 'danger' },
  { key: 'all',     label: 'All paid',    tone: 'brand' },
  { key: 'synced',  label: 'Synced',      tone: 'success' },
  { key: 'unpaid',  label: 'Not paid yet', tone: 'muted' },
];

export default function AdminERP() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  // `null` = "auto", resolved to "failed" if any exist, else "all".
  const [filter, setFilter] = useState(null);
  const [working, setWorking] = useState(null);
  const [bulkRetrying, setBulkRetrying] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await fetchAllOrders({ page_size: 200 });
      setOrders(Array.isArray(data) ? data : Array.isArray(data?.results) ? data.results : []);
    } catch {
      toast.error('Failed to load orders');
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => { load(); }, []);

  const grouped = useMemo(() => {
    const paid = orders.filter((o) => o.payment_status === 'SUCCESS');
    const missingErp = orders.filter((o) => !o.erp_order_id);
    return {
      all: paid,
      synced: paid.filter((o) => o.erp_order_id),
      failed: missingErp,
      unpaid: orders.filter((o) => o.payment_status !== 'SUCCESS'),
    };
  }, [orders]);

  // Auto-pick the most useful filter the first time data arrives.
  const effectiveFilter = filter || (grouped.failed.length > 0 ? 'failed' : 'all');

  const rows = useMemo(() => {
    let list = grouped[effectiveFilter] || [];
    const q = search.trim().toLowerCase();
    if (q) {
      list = list.filter((o) =>
        (o.order_id || '').toLowerCase().includes(q)
        || (o.user_email || '').toLowerCase().includes(q)
        || (o.erp_order_id || '').toLowerCase().includes(q)
      );
    }
    return list;
  }, [grouped, effectiveFilter, search]);

  const healthy = !loading && orders.length > 0 && grouped.failed.length === 0;

  const handleRetry = async (pk) => {
    setWorking(pk);
    try {
      const r = await retryErpSync(pk);
      toast.success(`Synced — ${r.erp_order_id || 'OK'}`);
      await load();
    } catch (err) {
      const data = err.response?.data;
      const msg = typeof data === 'string' ? data
        : data?.error || data?.detail || 'Sync failed. Check server logs.';
      toast.error(msg);
    } finally {
      setWorking(null);
    }
  };

  const handleBulkRetry = async () => {
    if (grouped.failed.length === 0) return;
    if (!window.confirm(`Retry ERP sync for ${grouped.failed.length} failed order(s)?`)) return;
    setBulkRetrying(true);
    let ok = 0, fail = 0;
    for (const o of grouped.failed) {
      try { await retryErpSync(o.id); ok += 1; }
      catch { fail += 1; }
    }
    setBulkRetrying(false);
    toast[fail ? 'error' : 'success'](`Bulk retry: ${ok} synced, ${fail} still failing.`);
    await load();
  };

  return (
    <div className="admin-page erp-page">
      <div className="erp-header">
        <div>
          <h2 className="admin-page__title" style={{ margin: 0 }}>
            <FiActivity style={{ verticalAlign: 'middle', marginRight: 8 }} />
            ERP Sync Status
          </h2>
          <p className="erp-header__sub">
            {grouped.all.length} paid orders · {grouped.synced.length} synced ·{' '}
            <span style={{ color: grouped.failed.length ? '#DC2626' : '#10B981', fontWeight: 600 }}>
              {grouped.failed.length} failed
            </span>
          </p>
        </div>
        <button onClick={load} className="erp-refresh" title="Reload">
          <FiRefreshCw size={14} /> Refresh
        </button>
      </div>

      {/* Stat tiles */}
      <div className="erp-stats">
        <StatTile tone="success" icon={<FiCheckCircle />}
                  value={grouped.synced.length} label="Synced to ERP" />
        <StatTile tone="danger" icon={<FiAlertTriangle />}
            value={grouped.failed.length}
            label="Failed (missing ERP id)" />
        <StatTile tone="muted" icon={<FiClock />}
                  value={grouped.unpaid.length} label="Awaiting payment" />
        <StatTile tone="brand" icon={<FiActivity />}
                  value={grouped.all.length} label="Total paid orders" />
      </div>

      {healthy && (
        <div className="erp-banner erp-banner--ok">
          <FiCheckCircle /> All paid orders are synced — nothing to retry.
        </div>
      )}

      {/* Controls */}
      <div className="erp-toolbar">
        <div className="erp-search">
          <FiSearch size={14} />
          <input
            type="search"
            placeholder="Search order #, customer email, or ERP id…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <div className="erp-chips">
          {FILTERS.map((f) => {
            const count = grouped[f.key]?.length ?? 0;
            const active = effectiveFilter === f.key;
            return (
              <button key={f.key}
                      onClick={() => setFilter(f.key)}
                      className={`erp-chip erp-chip--${f.tone} ${active ? 'erp-chip--active' : ''}`}>
                {f.label}
                <span className="erp-chip__count">{count}</span>
              </button>
            );
          })}
        </div>
        <button onClick={handleBulkRetry}
                disabled={grouped.failed.length === 0 || bulkRetrying}
                className="erp-bulk-btn"
                title="Retry every failed row">
          <FiZap size={14} />
          {bulkRetrying ? 'Retrying…' : `Bulk Retry (${grouped.failed.length})`}
        </button>
      </div>

      {/* Table */}
      <div className="erp-table-wrap">
        {loading ? (
          <div className="erp-empty">Loading orders…</div>
        ) : rows.length === 0 ? (
          <EmptyState filter={effectiveFilter} />
        ) : (
          <table className="erp-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>ERP Order ID</th>
                <th>Sync Status</th>
                <th>Placed</th>
                <th style={{ textAlign: 'right' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((o) => (
                <tr key={o.order_id}>
                  <td><code className="erp-mono">{o.order_id}</code></td>
                  <td>
                    <div className="erp-customer">
                      <strong>{o.user_name || '—'}</strong>
                      <span>{o.user_email}</span>
                    </div>
                  </td>
                  <td>
                    {o.erp_order_id
                      ? <code className="erp-mono erp-mono--accent">{o.erp_order_id}</code>
                      : <span className="erp-muted">—</span>}
                  </td>
                  <td>{renderStatus(o)}</td>
                  <td className="erp-muted">{formatDateTime(o.created_at)}</td>
                  <td style={{ textAlign: 'right' }}>
                    {o.payment_status !== 'SUCCESS' ? (
                      <span className="erp-muted">awaiting payment</span>
                    ) : o.erp_order_id ? (
                      <button className="erp-action erp-action--ghost"
                              onClick={() => handleRetry(o.id)}
                              disabled={working === o.id}
                              title="Force re-sync to ERP">
                        <FiRefreshCw size={12} />
                        {working === o.id ? 'Re-syncing…' : 'Re-sync'}
                      </button>
                    ) : (
                      <button className="erp-action erp-action--danger"
                              onClick={() => handleRetry(o.id)}
                              disabled={working === o.id}>
                        <FiRefreshCw size={12} />
                        {working === o.id ? 'Retrying…' : 'Retry'}
                      </button>
                    )}
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

function StatTile({ tone, icon, value, label }) {
  return (
    <div className={`erp-tile erp-tile--${tone}`}>
      <div className="erp-tile__icon">{icon}</div>
      <div className="erp-tile__body">
        <span className="erp-tile__value">{value}</span>
        <span className="erp-tile__label">{label}</span>
      </div>
    </div>
  );
}

function renderStatus(o) {
  if (o.payment_status !== 'SUCCESS') {
    return <span className="erp-status erp-status--muted">○ Awaiting payment</span>;
  }
  if (o.erp_order_id) {
    return <span className="erp-status erp-status--ok">✓ Synced</span>;
  }
  return <span className="erp-status erp-status--bad">✗ Failed</span>;
}

function EmptyState({ filter }) {
  const map = {
    failed:  { icon: <FiCheckCircle size={36} />, h: 'No failed syncs',
               p: 'Every paid order has a valid ERP id. You\'re all caught up.' },
    synced:  { icon: <FiActivity size={36} />,    h: 'No synced orders yet',
               p: 'Once a customer pays, the ERP id appears here.' },
    unpaid:  { icon: <FiClock size={36} />,       h: 'No unpaid orders',
               p: 'Everyone has paid — nothing waiting in the wings.' },
    all:     { icon: <FiActivity size={36} />,    h: 'No paid orders yet',
               p: 'When a payment succeeds, the order shows up here.' },
  };
  const m = map[filter] || map.all;
  return (
    <div className="erp-empty">
      <div className="erp-empty__icon">{m.icon}</div>
      <strong>{m.h}</strong>
      <p>{m.p}</p>
    </div>
  );
}
