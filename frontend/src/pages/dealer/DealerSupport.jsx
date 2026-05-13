/**
 * DealerSupport — list + create + view tickets, plus inline reply UI.
 * Same component used by customers — only routing/menu changes.
 */
import { useEffect, useState } from 'react';
import { FiMessageSquare, FiPlus, FiSend } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchTickets, fetchTicketDetail, createTicket, replyToTicket,
} from '../../api';

const STATUS_LABEL = {
  open: 'Open',
  awaiting_customer: 'Awaiting You',
  awaiting_agent: 'Awaiting Agent',
  resolved: 'Resolved',
  closed: 'Closed',
};
const STATUS_COLOR = {
  open: '#0EA5E9',
  awaiting_customer: '#F59E0B',
  awaiting_agent: '#6366F1',
  resolved: '#10B981',
  closed: '#6B7280',
};

export default function DealerSupport() {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null);
  const [composeOpen, setComposeOpen] = useState(false);

  const load = async () => {
    setLoading(true);
    try { setTickets(await fetchTickets()); } catch { setTickets([]); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 16 }}>
        <div>
          <h1>Support</h1>
          <p>Open tickets for order issues, payments, shipping, or account questions.</p>
        </div>
        <button onClick={() => setComposeOpen(true)} className="btn-primary"
                style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
          <FiPlus /> New Ticket
        </button>
      </header>

      {composeOpen && <ComposeModal onClose={() => setComposeOpen(false)} onCreated={() => { setComposeOpen(false); load(); }} />}
      {selected && <TicketModal id={selected} onClose={() => setSelected(null)} onChange={load} />}

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header">
          <h2>My Tickets</h2>
        </div>
        {loading ? (
          <div className="dealer-overview__empty">Loading…</div>
        ) : tickets.length === 0 ? (
          <div className="dealer-overview__empty">
            <FiMessageSquare size={28} style={{ color: '#9CA3AF', marginBottom: 8 }} />
            <p>No tickets yet. Click <strong>New Ticket</strong> to start a conversation.</p>
          </div>
        ) : (
          <table className="admin-table admin-table--compact">
            <thead>
              <tr><th>Ticket</th><th>Subject</th><th>Category</th><th>Status</th><th>Updated</th></tr>
            </thead>
            <tbody>
              {tickets.map((t) => (
                <tr key={t.id} onClick={() => setSelected(t.id)} style={{ cursor: 'pointer' }}>
                  <td><code>{t.ticket_number}</code></td>
                  <td>{t.subject}</td>
                  <td>{t.category}</td>
                  <td>
                    <span style={{ display: 'inline-block', padding: '2px 8px', borderRadius: 12, color: '#fff', fontSize: 11,
                                   background: STATUS_COLOR[t.status] || '#6B7280' }}>
                      {STATUS_LABEL[t.status] || t.status}
                    </span>
                  </td>
                  <td>{new Date(t.updated_at).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}

function ComposeModal({ onClose, onCreated }) {
  const [form, setForm] = useState({ subject: '', category: 'order', priority: 'normal', body: '' });
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.subject.trim() || !form.body.trim()) {
      toast.error('Subject and body are required.');
      return;
    }
    setSubmitting(true);
    try {
      await createTicket(form);
      toast.success('Ticket opened. We\'ll reply soon.');
      onCreated();
    } catch {
      toast.error('Could not open ticket.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <ModalShell title="New ticket" onClose={onClose}>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <input placeholder="Subject" value={form.subject}
               onChange={(e) => setForm({ ...form, subject: e.target.value })}
               style={inputStyle} />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} style={inputStyle}>
            {['order','payment','shipping','product','credit','account','other'].map(c =>
              <option key={c} value={c}>{c}</option>)}
          </select>
          <select value={form.priority} onChange={(e) => setForm({ ...form, priority: e.target.value })} style={inputStyle}>
            {['low','normal','high','urgent'].map(p => <option key={p} value={p}>{p}</option>)}
          </select>
        </div>
        <textarea rows={6} placeholder="Describe the issue…"
                  value={form.body} onChange={(e) => setForm({ ...form, body: e.target.value })}
                  style={inputStyle} />
        <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
          <button type="button" onClick={onClose} style={btnGhost}>Cancel</button>
          <button type="submit" disabled={submitting} className="btn-primary">
            {submitting ? 'Opening…' : 'Open ticket'}
          </button>
        </div>
      </form>
    </ModalShell>
  );
}

function TicketModal({ id, onClose, onChange }) {
  const [ticket, setTicket] = useState(null);
  const [reply, setReply] = useState('');
  const [sending, setSending] = useState(false);

  const load = async () => {
    try { setTicket(await fetchTicketDetail(id)); } catch { setTicket(null); }
  };
  useEffect(() => { load(); }, [id]);

  const handleReply = async (e) => {
    e.preventDefault();
    if (!reply.trim()) return;
    setSending(true);
    try {
      await replyToTicket(id, reply);
      setReply('');
      await load();
      onChange?.();
    } catch {
      toast.error('Could not send reply.');
    } finally {
      setSending(false);
    }
  };

  return (
    <ModalShell title={ticket?.ticket_number || 'Loading…'} onClose={onClose} wide>
      {!ticket ? (
        <p>Loading…</p>
      ) : (
        <>
          <h3 style={{ marginTop: 0 }}>{ticket.subject}</h3>
          <p style={{ color: '#6B7280', fontSize: 13, marginBottom: 16 }}>
            {ticket.category} · {ticket.priority} · status: <strong>{STATUS_LABEL[ticket.status] || ticket.status}</strong>
          </p>

          <div style={{ maxHeight: 360, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: 10, padding: 12, background: '#F9FAFB', borderRadius: 8 }}>
            {ticket.messages.map((m) => (
              <div key={m.id} style={{
                alignSelf: m.sender_role === 'admin' ? 'flex-start' : 'flex-end',
                background: m.sender_role === 'admin' ? '#FFFFFF' : '#111827',
                color: m.sender_role === 'admin' ? '#111827' : '#FAFAF7',
                padding: '8px 12px', borderRadius: 12, maxWidth: '80%',
                border: m.sender_role === 'admin' ? '1px solid #E5E7EB' : 0,
              }}>
                <div style={{ fontSize: 11, marginBottom: 2, opacity: 0.7 }}>
                  {m.sender_name || m.sender_role} · {new Date(m.created_at).toLocaleString()}
                </div>
                <div style={{ whiteSpace: 'pre-wrap' }}>{m.body}</div>
              </div>
            ))}
          </div>

          {ticket.status !== 'closed' && (
            <form onSubmit={handleReply} style={{ display: 'flex', gap: 8, marginTop: 12 }}>
              <input value={reply} onChange={(e) => setReply(e.target.value)}
                     placeholder="Type a reply…" style={{ ...inputStyle, flex: 1 }} />
              <button type="submit" disabled={sending} className="btn-primary"
                      style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                <FiSend /> Send
              </button>
            </form>
          )}
        </>
      )}
    </ModalShell>
  );
}

const inputStyle = { padding: '8px 10px', border: '1px solid #D1D5DB', borderRadius: 6, fontSize: 14 };
const btnGhost = { padding: '8px 14px', borderRadius: 6, border: '1px solid #D1D5DB', background: '#fff', cursor: 'pointer' };

function ModalShell({ title, onClose, wide, children }) {
  return (
    <div onClick={onClose}
         style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
      <div onClick={(e) => e.stopPropagation()}
           style={{ background: '#fff', borderRadius: 12, padding: 20, width: wide ? 720 : 480, maxWidth: '94vw', maxHeight: '88vh', overflow: 'auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <strong>{title}</strong>
          <button onClick={onClose} style={{ ...btnGhost, padding: '4px 10px' }}>✕</button>
        </div>
        {children}
      </div>
    </div>
  );
}
