/**
 * AdminFAQ — manage the chatbot's Q&A knowledge base.
 *
 * Layout: two columns
 *   - Left: list of entries grouped by topic, click to edit
 *   - Right: edit form (or "Create new") with topic / question / answer /
 *     triggers (comma-separated) / follow-up prompts / sort_order / active
 *
 * Each entry maps to one FaqEntry row. Saving / deleting hits the admin
 * FAQ CRUD endpoints. The chatbot uses these entries via /api/support/bot/.
 */
import { useEffect, useMemo, useState } from 'react';
import {
  FiMessageCircle, FiPlus, FiTrash2, FiSave, FiX, FiToggleRight, FiToggleLeft,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchFaqEntries, createFaqEntry, updateFaqEntry, deleteFaqEntry,
} from '../../api';

const BLANK = {
  topic: '', question: '', answer: '',
  triggers: '', follow_up_prompts: '',
  sort_order: 100, is_active: true,
};

function toFormState(row) {
  // Backend stores JSON arrays; the form uses comma-separated strings.
  return {
    ...row,
    triggers: Array.isArray(row.triggers) ? row.triggers.join(', ') : '',
    follow_up_prompts: Array.isArray(row.follow_up_prompts)
      ? row.follow_up_prompts.join(' | ')
      : '',
  };
}

function toApiPayload(form) {
  const parseCsv = (s, sep = ',') =>
    (s || '').split(sep).map((x) => x.trim()).filter(Boolean);
  return {
    topic: form.topic.trim(),
    question: form.question.trim(),
    answer: form.answer.trim(),
    triggers: parseCsv(form.triggers),
    follow_up_prompts: parseCsv(form.follow_up_prompts, '|'),
    sort_order: parseInt(form.sort_order || 100, 10),
    is_active: !!form.is_active,
  };
}

export default function AdminFAQ() {
  const [entries, setEntries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(BLANK);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await fetchFaqEntries();
      const rows = Array.isArray(data) ? data : data?.results || [];
      setEntries(rows);
    } catch {
      toast.error('Failed to load FAQ entries');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const grouped = useMemo(() => {
    const m = {};
    entries.forEach((e) => {
      (m[e.topic || 'Uncategorised'] ||= []).push(e);
    });
    return m;
  }, [entries]);

  const openCreate = () => {
    setEditingId('new');
    setForm(BLANK);
  };

  const openEdit = (row) => {
    setEditingId(row.id);
    setForm(toFormState(row));
  };

  const cancelEdit = () => {
    setEditingId(null);
    setForm(BLANK);
  };

  const handleSave = async () => {
    if (!form.topic.trim() || !form.question.trim() || !form.answer.trim()) {
      toast.error('Topic, question, and answer are required.');
      return;
    }
    setSaving(true);
    try {
      const payload = toApiPayload(form);
      if (editingId === 'new') {
        await createFaqEntry(payload);
        toast.success('FAQ entry created');
      } else {
        await updateFaqEntry(editingId, payload);
        toast.success('FAQ entry updated');
      }
      cancelEdit();
      load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Save failed');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (row) => {
    if (!window.confirm(`Delete "${row.question}"?`)) return;
    try {
      await deleteFaqEntry(row.id);
      toast.success('Deleted');
      if (editingId === row.id) cancelEdit();
      load();
    } catch {
      toast.error('Delete failed');
    }
  };

  const handleToggle = async (row) => {
    try {
      await updateFaqEntry(row.id, { is_active: !row.is_active });
      load();
    } catch {
      toast.error('Toggle failed');
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title" style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <FiMessageCircle size={22} style={{ color: 'var(--color-brand)' }} />
          Support Chatbot — FAQ
        </h2>
        <button className="btn-primary" onClick={openCreate}
                style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
          <FiPlus /> New entry
        </button>
      </div>

      <p className="admin-meta-line" style={{ marginTop: -4, marginBottom: 18, maxWidth: 720 }}>
        Each row teaches the chatbot one Q&amp;A. The <strong>Triggers</strong> field
        is a comma-separated list of keywords the bot matches against the user&apos;s
        message. <strong>Follow-up prompts</strong> are pipe-separated chips shown
        after the answer for the user to click.
      </p>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.3fr', gap: 18 }}>
        {/* ── Left: list ─────────────────────────────────────────── */}
        <div>
          {loading ? (
            <div className="admin-empty">Loading…</div>
          ) : entries.length === 0 ? (
            <div className="admin-empty">
              <FiMessageCircle size={28} style={{ opacity: 0.4 }} />
              <p style={{ margin: 0, fontWeight: 600 }}>No FAQ entries yet</p>
              <p style={{ margin: 0, fontSize: 12 }}>
                Click "New entry" to teach the bot its first answer.
              </p>
            </div>
          ) : (
            Object.entries(grouped).map(([topic, rows]) => (
              <div key={topic} style={{ marginBottom: 18 }}>
                <h4 style={{
                  fontSize: 12, fontWeight: 700, textTransform: 'uppercase',
                  letterSpacing: '0.06em', color: 'var(--color-text-muted)',
                  margin: '0 0 8px',
                }}>
                  {topic}
                </h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {rows.map((row) => (
                    <div
                      key={row.id}
                      className="admin-card"
                      style={{
                        padding: '10px 14px',
                        cursor: 'pointer',
                        border: editingId === row.id
                          ? '2px solid var(--color-brand)'
                          : '1px solid #eef0ee',
                        background: row.is_active ? '#fff' : '#fafaf7',
                      }}
                      onClick={() => openEdit(row)}
                    >
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <strong style={{
                          flex: 1, fontSize: 14,
                          opacity: row.is_active ? 1 : 0.5,
                        }}>
                          {row.question}
                        </strong>
                        <button type="button"
                                onClick={(e) => { e.stopPropagation(); handleToggle(row); }}
                                title={row.is_active ? 'Disable' : 'Enable'}
                                style={{ background: 'none', border: 'none', cursor: 'pointer',
                                         color: row.is_active ? 'var(--color-brand)' : '#9ca3af' }}>
                          {row.is_active
                            ? <FiToggleRight size={20} />
                            : <FiToggleLeft size={20} />}
                        </button>
                        <button type="button"
                                onClick={(e) => { e.stopPropagation(); handleDelete(row); }}
                                title="Delete"
                                style={{ background: 'none', border: 'none', cursor: 'pointer',
                                         color: '#e74c3c' }}>
                          <FiTrash2 size={15} />
                        </button>
                      </div>
                      {row.triggers?.length > 0 && (
                        <div style={{ fontSize: 11, color: 'var(--color-text-muted)',
                                      marginTop: 4, opacity: row.is_active ? 1 : 0.5 }}>
                          Triggers: {row.triggers.join(', ')}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            ))
          )}
        </div>

        {/* ── Right: editor ──────────────────────────────────────── */}
        <div>
          {editingId === null ? (
            <div className="admin-empty">
              <FiMessageCircle size={28} style={{ opacity: 0.4 }} />
              <p style={{ margin: 0, fontWeight: 600 }}>Pick an entry or create a new one</p>
              <p style={{ margin: 0, fontSize: 12 }}>
                Edit the chatbot's answers from here.
              </p>
            </div>
          ) : (
            <div className="admin-card" style={{ position: 'sticky', top: 16 }}>
              <div className="section-header">
                <span className="section-header__icon">
                  {editingId === 'new' ? <FiPlus size={20} /> : <FiMessageCircle size={20} />}
                </span>
                <div className="section-header__text">
                  <h3 className="section-header__title">
                    {editingId === 'new' ? 'Create new entry' : 'Edit entry'}
                  </h3>
                  <p className="section-header__subtitle">
                    The chatbot replies with this answer whenever any of the
                    trigger keywords appear in a user message.
                  </p>
                </div>
              </div>

              <div className="admin-form-grid" style={{ gap: 14 }}>
                <label className="admin-label">
                  <span>Topic</span>
                  <input type="text" className="admin-input"
                         placeholder="Package & delivery"
                         value={form.topic}
                         onChange={(e) => setForm({ ...form, topic: e.target.value })} />
                </label>
                <label className="admin-label">
                  <span>Sort order</span>
                  <input type="number" min="0" className="admin-input"
                         value={form.sort_order}
                         onChange={(e) => setForm({ ...form, sort_order: e.target.value })} />
                </label>
              </div>

              <label className="admin-label" style={{ marginTop: 12 }}>
                <span>Question (shown as chip)</span>
                <input type="text" className="admin-input"
                       placeholder="My package hasn't arrived yet"
                       value={form.question}
                       onChange={(e) => setForm({ ...form, question: e.target.value })} />
              </label>

              <label className="admin-label" style={{ marginTop: 12 }}>
                <span>Answer</span>
                <textarea className="admin-input" rows={6}
                          placeholder="Reply text the bot sends back to the customer"
                          value={form.answer}
                          onChange={(e) => setForm({ ...form, answer: e.target.value })} />
              </label>

              <label className="admin-label" style={{ marginTop: 12 }}>
                <span>Triggers (comma-separated keywords)</span>
                <input type="text" className="admin-input"
                       placeholder="package, didn't arrive, tracking, delayed"
                       value={form.triggers}
                       onChange={(e) => setForm({ ...form, triggers: e.target.value })} />
              </label>

              <label className="admin-label" style={{ marginTop: 12 }}>
                <span>Follow-up prompts (pipe-separated)</span>
                <input type="text" className="admin-input"
                       placeholder="Track my order | Refund status | Contact support"
                       value={form.follow_up_prompts}
                       onChange={(e) => setForm({ ...form, follow_up_prompts: e.target.value })} />
              </label>

              <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 14, cursor: 'pointer' }}>
                <input type="checkbox" checked={form.is_active}
                       onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
                <span style={{ fontSize: 13, fontWeight: 600 }}>Active</span>
                <span style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>
                  — uncheck to hide from the bot without deleting
                </span>
              </label>

              <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
                <button className="btn-primary" onClick={handleSave} disabled={saving}
                        style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                  <FiSave size={14} /> {saving ? 'Saving…' : 'Save'}
                </button>
                <button className="btn-outline" onClick={cancelEdit} disabled={saving}
                        style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                  <FiX size={14} /> Cancel
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
