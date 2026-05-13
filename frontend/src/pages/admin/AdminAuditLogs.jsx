/**
 * AdminAuditLogs — read-only viewer for the system audit trail.
 *
 * Every admin mutation goes through audit.mixins.AuditedMixin which writes
 * an AuditLog row. This page exposes that table at /admin-dashboard/audit
 * with search + action + target_type filters so an admin can answer
 * "who changed dealer X's credit limit at 3am?" in seconds.
 */
import { useEffect, useMemo, useState } from 'react';
import { FiSearch, FiActivity, FiUser, FiRefreshCw } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchAuditLogs } from '../../api';
import { formatDateTime } from '../../utils/format';
import Pagination from '../../components/Pagination';

const PAGE_SIZE = 30;

const ACTION_TONE = {
  create: { bg: '#D1FAE5', fg: '#047857' },
  update: { bg: '#DBEAFE', fg: '#1E40AF' },
  delete: { bg: '#FEE2E2', fg: '#B91C1C' },
  block:  { bg: '#FEE2E2', fg: '#B91C1C' },
  unblock:{ bg: '#D1FAE5', fg: '#047857' },
  approve:{ bg: '#D1FAE5', fg: '#047857' },
  reject: { bg: '#FEE2E2', fg: '#B91C1C' },
  refund: { bg: '#FFEDD5', fg: '#9A3412' },
  cancel: { bg: '#FEE2E2', fg: '#B91C1C' },
  login:  { bg: '#E0E7FF', fg: '#3730A3' },
  logout: { bg: '#E0E7FF', fg: '#3730A3' },
  export: { bg: '#FEF3C7', fg: '#92400E' },
  other:  { bg: '#F3F4F6', fg: '#374151' },
};

const ACTION_FILTERS = ['ALL', 'create', 'update', 'delete', 'block', 'unblock',
                        'approve', 'reject', 'refund', 'cancel', 'login', 'logout',
                        'export', 'other'];

export default function AdminAuditLogs() {
  const [rows, setRows] = useState([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [action, setAction] = useState('ALL');
  const [targetType, setTargetType] = useState('');
  const [search, setSearch] = useState('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');

  const load = async () => {
    setLoading(true);
    try {
      const params = { page, page_size: PAGE_SIZE };
      if (action !== 'ALL') params.action = action;
      if (targetType) params.target_type = targetType;
      if (dateFrom) params.from = dateFrom;
      if (dateTo) params.to = dateTo;
      const data = await fetchAuditLogs(params);
      const list = Array.isArray(data) ? data
        : Array.isArray(data?.results) ? data.results : [];
      setRows(list);
      setCount(typeof data?.count === 'number' ? data.count : list.length);
    } catch {
      toast.error('Failed to load audit logs.');
      setRows([]);
      setCount(0);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); /* eslint-disable-next-line */ }, [page, action, targetType, dateFrom, dateTo]);
  useEffect(() => { if (page !== 1) setPage(1); /* eslint-disable-next-line */ },
            [action, targetType, dateFrom, dateTo]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return rows;
    return rows.filter((r) =>
      (r.target_type || '').toLowerCase().includes(q)
      || (r.target_id || '').toLowerCase().includes(q)
      || (r.actor_email || '').toLowerCase().includes(q)
      || (r.actor_name || '').toLowerCase().includes(q)
      || JSON.stringify(r.payload || {}).toLowerCase().includes(q)
    );
  }, [rows, search]);

  const targetTypes = useMemo(() => {
    return Array.from(new Set(rows.map((r) => r.target_type).filter(Boolean))).sort();
  }, [rows]);

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">
          <FiActivity style={{ verticalAlign: 'middle', marginRight: 6 }} />
          Audit Logs
        </h2>
        <span className="admin-meta-line">
          {filtered.length} of {rows.length} entries
        </span>
      </div>

      <div className="admin-toolbar" style={{ flexWrap: 'wrap' }}>
        <div className="admin-toolbar__search" style={{ flex: '1 1 240px' }}>
          <FiSearch />
          <input
            type="search"
            placeholder="Search actor, target, payload…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select value={action} onChange={(e) => setAction(e.target.value)}>
          {ACTION_FILTERS.map((a) => (
            <option key={a} value={a}>{a === 'ALL' ? 'All actions' : a}</option>
          ))}
        </select>
        <select value={targetType} onChange={(e) => setTargetType(e.target.value)}>
          <option value="">All target types</option>
          {targetTypes.map((t) => (
            <option key={t} value={t}>{t}</option>
          ))}
        </select>
        <input type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)}
               aria-label="From date" />
        <input type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)}
               aria-label="To date" />
        <button onClick={load} className="btn-outline"
                style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
          <FiRefreshCw size={13} /> Refresh
        </button>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading audit trail…</p>
        ) : filtered.length === 0 ? (
          <div className="admin-empty" style={{ padding: '40px 24px' }}>
            <FiActivity size={32} style={{ color: '#9CA3AF', marginBottom: 8 }} />
            <strong style={{ color: '#111827' }}>No matching entries</strong>
            <p style={{ margin: 0, color: '#6B7280' }}>
              Try widening the filters or clearing the search box.
            </p>
          </div>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>When</th>
                <th>Actor</th>
                <th>Action</th>
                <th>Target</th>
                <th>Payload</th>
                <th>IP</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((r) => {
                const tone = ACTION_TONE[r.action] || ACTION_TONE.other;
                return (
                  <tr key={r.id}>
                    <td style={{ whiteSpace: 'nowrap', fontSize: 12.5, color: '#6B7280' }}>
                      {formatDateTime(r.created_at)}
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                        <FiUser size={11} style={{ color: '#9CA3AF' }} />
                        <div style={{ minWidth: 0 }}>
                          <strong style={{ fontSize: 13 }}>{r.actor_name || '—'}</strong>
                          <div className="admin-meta-line">{r.actor_email || 'system'}</div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span style={{
                        display: 'inline-block', padding: '2px 10px', borderRadius: 999,
                        fontSize: 11, fontWeight: 700, textTransform: 'uppercase',
                        letterSpacing: '0.04em',
                        background: tone.bg, color: tone.fg,
                      }}>
                        {r.action}
                      </span>
                    </td>
                    <td>
                      <code style={{ fontSize: 12, background: '#F3F4F6',
                                     padding: '2px 6px', borderRadius: 4 }}>
                        {r.target_type}
                      </code>
                      {r.target_id && (
                        <span style={{ marginLeft: 6, color: '#6B7280', fontSize: 12 }}>
                          #{r.target_id}
                        </span>
                      )}
                    </td>
                    <td>
                      {r.payload && Object.keys(r.payload).length > 0 ? (
                        <details>
                          <summary style={{ cursor: 'pointer', fontSize: 12, color: '#0E766E' }}>
                            View
                          </summary>
                          <pre style={{
                            margin: '6px 0 0', padding: '8px 10px',
                            background: '#F9FAFB', border: '1px solid #E5E7EB',
                            borderRadius: 6, fontSize: 11.5, color: '#374151',
                            overflow: 'auto', maxWidth: 360, maxHeight: 160,
                          }}>
                            {JSON.stringify(r.payload, null, 2)}
                          </pre>
                        </details>
                      ) : (
                        <span className="admin-meta-line">—</span>
                      )}
                    </td>
                    <td style={{ fontFamily: 'ui-monospace, monospace', fontSize: 11.5,
                                 color: '#6B7280' }}>
                      {r.ip || '—'}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
        <Pagination page={page} count={count} pageSize={PAGE_SIZE} onChange={setPage} />
      </div>
    </div>
  );
}
