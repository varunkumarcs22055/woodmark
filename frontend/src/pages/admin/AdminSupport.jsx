/**
 * AdminSupport — Intercom-style inbox layout for every customer / dealer ticket.
 *
 * Layout:
 *   ┌──────────────────────┬─────────────────────────────────────┐
 *   │ Stat strip across top                                       │
 *   ├──────────────────────┼─────────────────────────────────────┤
 *   │ Search + filter rail │ Selected ticket — meta strip        │
 *   │                      ├─────────────────────────────────────┤
 *   │ Ticket list          │ Conversation thread (scroll)        │
 *   │  • avatar            │                                     │
 *   │  • subject + snippet ├─────────────────────────────────────┤
 *   │  • status pill       │ Reply box + status actions          │
 *   └──────────────────────┴─────────────────────────────────────┘
 */
import { useEffect, useMemo, useState } from 'react';
import {
  FiSearch, FiSend, FiLock, FiCheck, FiAlertCircle,
  FiInbox, FiUser, FiPackage,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchTickets, fetchTicketDetail, replyToTicket, updateTicketStatus,
} from '../../api';
import { formatDateTime } from '../../utils/format';
import './AdminSupport.css';

const STATUS_LABEL = {
  open: 'Open',
  awaiting_customer: 'Awaiting Customer',
  awaiting_agent: 'Needs Reply',
  resolved: 'Resolved',
  closed: 'Closed',
};
const STATUS_COLOR = {
  open:              { bg: '#DBEAFE', fg: '#1E40AF', dot: '#3B82F6' },
  awaiting_agent:    { bg: '#FEF3C7', fg: '#92400E', dot: '#F59E0B' },
  awaiting_customer: { bg: '#E0E7FF', fg: '#3730A3', dot: '#6366F1' },
  resolved:          { bg: '#D1FAE5', fg: '#065F46', dot: '#10B981' },
  closed:            { bg: '#F3F4F6', fg: '#4B5563', dot: '#9CA3AF' },
};
const PRIORITY_COLOR = {
  low:    '#9CA3AF',
  normal: '#2D2E5F',
  high:   '#D97706',
  urgent: '#DC2626',
};

const STATUS_FILTERS = [
  { key: 'ALL',                label: 'All',         icon: <FiInbox size={13} /> },
  { key: 'awaiting_agent',     label: 'Needs Reply' },
  { key: 'open',               label: 'Open' },
  { key: 'awaiting_customer',  label: 'Awaiting' },
  { key: 'resolved',           label: 'Resolved' },
  { key: 'closed',             label: 'Closed' },
];

function initials(nameOrEmail = '') {
  const s = (nameOrEmail || '').trim();
  if (!s) return '?';
  const parts = s.split(/[\s@.]+/).filter(Boolean);
  if (parts.length === 0) return '?';
  return (parts[0][0] + (parts[1]?.[0] || '')).toUpperCase();
}

function avatarColor(seed = '') {
  const palette = ['#2D2E5F', '#0891B2', '#7C3AED', '#DB2777', '#EA580C', '#65A30D'];
  let h = 0;
  for (let i = 0; i < seed.length; i++) h = (h * 31 + seed.charCodeAt(i)) | 0;
  return palette[Math.abs(h) % palette.length];
}

function relativeTime(iso) {
  if (!iso) return '';
  const ms = Date.now() - new Date(iso).getTime();
  const m = Math.floor(ms / 60_000);
  if (m < 1)   return 'just now';
  if (m < 60)  return `${m} min ago`;
  const h = Math.floor(m / 60);
  if (h < 24)  return `${h} hr ago`;
  const d = Math.floor(h / 24);
  if (d < 7)   return `${d} day${d === 1 ? '' : 's'} ago`;
  return new Date(iso).toLocaleDateString();
}

export default function AdminSupport() {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [search, setSearch] = useState('');
  const [selectedId, setSelectedId] = useState(null);

  // Detail panel state
  const [detail, setDetail] = useState(null);
  const [detailLoading, setDetailLoading] = useState(false);
  const [reply, setReply] = useState('');
  const [internalNote, setInternalNote] = useState(false);
  const [sending, setSending] = useState(false);
  const [updatingStatus, setUpdatingStatus] = useState(false);

  const loadList = async () => {
    setLoading(true);
    try {
      const params = statusFilter === 'ALL' ? undefined : { status: statusFilter };
      const data = await fetchTickets(params);
      const rows = Array.isArray(data) ? data : data.results || [];
      setTickets(rows);
      // Auto-select the first ticket on initial load so the right panel is never blank.
      if (rows.length > 0 && !selectedId) setSelectedId(rows[0].id);
    } catch {
      toast.error('Failed to load tickets.');
      setTickets([]);
    } finally {
      setLoading(false);
    }
  };

  const loadDetail = async (id) => {
    setDetailLoading(true);
    try {
      const t = await fetchTicketDetail(id);
      setDetail(t);
    } catch {
      setDetail(null);
      toast.error('Could not load ticket.');
    } finally {
      setDetailLoading(false);
    }
  };

  useEffect(() => { loadList(); /* eslint-disable-next-line */ }, [statusFilter]);
  useEffect(() => { if (selectedId) loadDetail(selectedId); }, [selectedId]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return tickets;
    return tickets.filter((t) =>
      (t.ticket_number || '').toLowerCase().includes(q)
      || (t.subject || '').toLowerCase().includes(q)
      || (t.user_email || t.user?.email || '').toLowerCase().includes(q)
      || (t.user_name  || t.user?.full_name || '').toLowerCase().includes(q)
    );
  }, [tickets, search]);

  const counts = useMemo(() => ({
    total: tickets.length,
    needsReply: tickets.filter((t) => ['open', 'awaiting_agent'].includes(t.status)).length,
    urgent: tickets.filter(
      (t) => t.priority === 'urgent' && !['resolved', 'closed'].includes(t.status),
    ).length,
  }), [tickets]);

  const sendReply = async (e) => {
    e?.preventDefault?.();
    const body = reply.trim();
    if (!body || !selectedId) return;
    setSending(true);
    try {
      await replyToTicket(selectedId, body, internalNote);
      setReply('');
      setInternalNote(false);
      await Promise.all([loadDetail(selectedId), loadList()]);
      toast.success(internalNote ? 'Internal note saved.' : 'Reply sent.');
    } catch {
      toast.error('Could not send.');
    } finally {
      setSending(false);
    }
  };

  const changeStatus = async (newStatus) => {
    if (!newStatus || !selectedId || detail?.status === newStatus) return;
    setUpdatingStatus(true);
    try {
      await updateTicketStatus(selectedId, newStatus);
      await Promise.all([loadDetail(selectedId), loadList()]);
      toast.success(`Status → ${STATUS_LABEL[newStatus]}`);
    } catch {
      toast.error('Status update failed.');
    } finally {
      setUpdatingStatus(false);
    }
  };

  return (
    <div className="admin-page support-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Support Inbox</h2>
        <span className="admin-meta-line">
          {counts.total} total · {counts.needsReply} need reply · {counts.urgent} urgent
        </span>
      </div>

      <div className="support-stats">
        <StatCard label="Total Tickets"  value={counts.total}      tone="neutral" />
        <StatCard label="Needs Reply"    value={counts.needsReply} tone="warn" />
        <StatCard label="Urgent Open"    value={counts.urgent}     tone="danger" />
      </div>

      <div className="support-shell">
        {/* ─── LEFT: ticket list ─── */}
        <aside className="support-list">
          <div className="support-list__filters">
            <div className="support-search">
              <FiSearch size={14} />
              <input
                type="search"
                placeholder="Search tickets…"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            <div className="support-chips">
              {STATUS_FILTERS.map((f) => (
                <button
                  key={f.key}
                  onClick={() => setStatusFilter(f.key)}
                  className={`support-chip ${statusFilter === f.key ? 'support-chip--active' : ''}`}
                >
                  {f.icon}{f.label}
                </button>
              ))}
            </div>
          </div>

          <div className="support-list__rows">
            {loading ? (
              Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="support-row support-row--skeleton">
                  <div className="skeleton" style={{ width: 36, height: 36, borderRadius: '50%' }} />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6 }}>
                    <div className="skeleton" style={{ width: '60%', height: 12, borderRadius: 4 }} />
                    <div className="skeleton" style={{ width: '90%', height: 10, borderRadius: 4 }} />
                  </div>
                </div>
              ))
            ) : filtered.length === 0 ? (
              <div className="support-empty">
                <FiInbox size={28} />
                <strong>No tickets here</strong>
                <p>Try a different filter or search term.</p>
              </div>
            ) : (
              filtered.map((t) => {
                const name = t.user_name || t.user?.full_name || t.user_email || '—';
                const email = t.user_email || t.user?.email || '';
                const snippet = (t.last_message || t.subject || '').slice(0, 100);
                const c = STATUS_COLOR[t.status] || STATUS_COLOR.open;
                const isActive = selectedId === t.id;
                return (
                  <button
                    key={t.id}
                    onClick={() => setSelectedId(t.id)}
                    className={`support-row ${isActive ? 'support-row--active' : ''}`}
                  >
                    <div className="support-avatar"
                         style={{ background: avatarColor(email || name) }}>
                      {initials(name || email)}
                      {t.priority === 'urgent' && (
                        <span className="support-avatar__urgent" title="Urgent" />
                      )}
                    </div>
                    <div className="support-row__body">
                      <div className="support-row__topline">
                        <strong className="support-row__name">{name}</strong>
                        <span className="support-row__time">{relativeTime(t.updated_at)}</span>
                      </div>
                      <div className="support-row__subject">{t.subject || '(no subject)'}</div>
                      <div className="support-row__snippet">
                        <code style={{ color: '#9CA3AF', fontSize: 11 }}>{t.ticket_number}</code>
                        <span style={{ margin: '0 6px', color: '#D1D5DB' }}>·</span>
                        <span>{snippet}</span>
                      </div>
                      <div className="support-row__meta">
                        <span className="support-pill"
                              style={{ background: c.bg, color: c.fg }}>
                          <span className="support-pill__dot" style={{ background: c.dot }} />
                          {STATUS_LABEL[t.status] || t.status}
                        </span>
                        <span className="support-priority"
                              style={{ color: PRIORITY_COLOR[t.priority] }}>
                          {t.priority?.toUpperCase()}
                        </span>
                      </div>
                    </div>
                  </button>
                );
              })
            )}
          </div>
        </aside>

        {/* ─── RIGHT: detail / conversation ─── */}
        <main className="support-detail">
          {!selectedId ? (
            <EmptyDetail />
          ) : detailLoading || !detail ? (
            <div className="support-detail__loading">Loading conversation…</div>
          ) : (
            <>
              {/* Meta strip */}
              <header className="support-detail__header">
                <div className="support-detail__title">
                  <code className="support-detail__num">{detail.ticket_number}</code>
                  <h3>{detail.subject}</h3>
                </div>
                <div className="support-detail__meta">
                  <Meta icon={<FiUser size={11} />} label="From">
                    {detail.user_name || detail.user?.full_name || '—'}{' '}
                    <span style={{ color: '#9CA3AF' }}>
                      ({detail.user_email || detail.user?.email})
                    </span>
                  </Meta>
                  <Meta label="Category">
                    <span style={{ textTransform: 'capitalize' }}>{detail.category}</span>
                  </Meta>
                  <Meta label="Priority">
                    <strong style={{ color: PRIORITY_COLOR[detail.priority] }}>
                      {detail.priority?.toUpperCase()}
                    </strong>
                  </Meta>
                  {detail.related_order_id && (
                    <Meta icon={<FiPackage size={11} />} label="Order">
                      <code>{detail.related_order_id_human || detail.related_order_id}</code>
                    </Meta>
                  )}
                </div>
                <div className="support-detail__actions">
                  <StatusButton onClick={() => changeStatus('awaiting_customer')}
                                disabled={updatingStatus || detail.status === 'awaiting_customer'}>
                    Awaiting Customer
                  </StatusButton>
                  <StatusButton onClick={() => changeStatus('resolved')}
                                disabled={updatingStatus || detail.status === 'resolved'}
                                tone="success">
                    <FiCheck size={12} /> Mark Resolved
                  </StatusButton>
                  <StatusButton onClick={() => changeStatus('closed')}
                                disabled={updatingStatus || detail.status === 'closed'}
                                tone="muted">
                    Close
                  </StatusButton>
                </div>
              </header>

              {/* Conversation thread */}
              <div className="support-thread">
                {(detail.messages || []).map((m) => {
                  const isAgent = m.sender_role === 'admin';
                  const senderName = m.sender_name || m.sender_role;
                  return (
                    <div key={m.id}
                         className={`support-bubble ${isAgent ? 'support-bubble--agent' : 'support-bubble--customer'}
                                     ${m.is_internal_note ? 'support-bubble--internal' : ''}`}>
                      <div className="support-bubble__avatar"
                           style={{ background: avatarColor(senderName) }}>
                        {initials(senderName)}
                      </div>
                      <div className="support-bubble__content">
                        <div className="support-bubble__head">
                          <strong>{senderName}</strong>
                          <span>{formatDateTime(m.created_at)}</span>
                          {m.is_internal_note && (
                            <span className="support-bubble__internal-tag">
                              <FiLock size={10} /> INTERNAL
                            </span>
                          )}
                        </div>
                        <div className="support-bubble__body">{m.body}</div>
                      </div>
                    </div>
                  );
                })}
                {(!detail.messages || detail.messages.length === 0) && (
                  <p className="support-thread__empty">No messages yet.</p>
                )}
              </div>

              {/* Reply composer */}
              {detail.status !== 'closed' ? (
                <form className={`support-composer ${internalNote ? 'support-composer--internal' : ''}`}
                      onSubmit={sendReply}>
                  <textarea
                    value={reply}
                    onChange={(e) => setReply(e.target.value)}
                    placeholder={internalNote
                      ? 'Internal note — only visible to admins…'
                      : `Reply to ${detail.user_name || detail.user?.full_name || 'customer'}…`}
                    rows={3}
                    onKeyDown={(e) => {
                      if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') sendReply(e);
                    }}
                  />
                  <div className="support-composer__bar">
                    <label className="support-composer__internal-toggle">
                      <input
                        type="checkbox"
                        checked={internalNote}
                        onChange={(e) => setInternalNote(e.target.checked)}
                      />
                      <FiLock size={12} /> Internal note
                    </label>
                    <span className="support-composer__hint">
                      Ctrl + Enter to send
                    </span>
                    <button type="submit" disabled={sending || !reply.trim()}
                            className="btn-primary support-composer__send">
                      <FiSend size={13} />
                      {sending ? 'Sending…' : (internalNote ? 'Save Note' : 'Send Reply')}
                    </button>
                  </div>
                </form>
              ) : (
                <div className="support-composer support-composer--closed">
                  <FiAlertCircle /> This ticket is closed. Reopen it (set status →
                  <em> Awaiting Customer</em>) to reply.
                </div>
              )}
            </>
          )}
        </main>
      </div>
    </div>
  );
}

// ─── Small subcomponents ─────────────────────────────────────────────────

function StatCard({ label, value, tone = 'neutral' }) {
  return (
    <div className={`support-stat support-stat--${tone}`}>
      <span className="support-stat__value">{value}</span>
      <span className="support-stat__label">{label}</span>
    </div>
  );
}

function Meta({ icon, label, children }) {
  return (
    <div className="support-meta">
      <span className="support-meta__label">
        {icon}{label}
      </span>
      <span className="support-meta__value">{children}</span>
    </div>
  );
}

function StatusButton({ children, onClick, disabled, tone = 'neutral' }) {
  return (
    <button onClick={onClick} disabled={disabled}
            className={`support-status-btn support-status-btn--${tone}`}>
      {children}
    </button>
  );
}

function EmptyDetail() {
  return (
    <div className="support-detail__empty">
      <FiInbox size={48} />
      <h3>Select a ticket</h3>
      <p>Pick a conversation on the left to see the thread and reply.</p>
    </div>
  );
}
