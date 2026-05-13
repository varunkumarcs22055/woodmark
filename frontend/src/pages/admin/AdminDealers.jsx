/**
 * AdminDealers — pending applications, active dealers, and inline credit /
 * wallet / status management.
 *
 * Backend endpoints used:
 *   GET   /api/auth/users/?role=dealer&dealer_status=…
 *   PATCH /api/auth/dealers/{id}/approve/   (approve / reject)
 *   GET   /api/admin/dealers/{id}/credit/   (current credit summary)
 *   PATCH /api/admin/dealers/{id}/credit/   (set limit / terms / active)
 *   POST  /api/admin/dealers/{id}/payments/ (record credit payment received)
 *   POST  /api/admin/dealers/{id}/wallet/topup/   (top up dealer wallet)
 */
import { useEffect, useMemo, useState } from 'react';
import {
  FiCheck, FiX, FiDollarSign, FiCreditCard, FiPower, FiPlusCircle, FiSearch,
  FiTag, FiTrash2, FiPercent,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchUsers, approveDealer,
  fetchAdminDealerCredit, updateAdminDealerCredit, recordAdminDealerPayment,
  adminWalletTopup, fetchDealerTiers,
  createDealerTier, updateDealerTier, deleteDealerTier,
  fetchNegotiatedPrices, upsertNegotiatedPrice, deleteNegotiatedPrice,
  fetchProducts,
} from '../../api';
import { formatDate, formatPrice } from '../../utils/format';

export default function AdminDealers() {
  const [pending, setPending] = useState([]);
  const [active, setActive] = useState([]);
  const [tiers, setTiers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [creditModalFor, setCreditModalFor] = useState(null); // dealer obj
  const [walletModalFor, setWalletModalFor] = useState(null);
  const [showTierManager, setShowTierManager] = useState(false);
  const [negotiatedFor, setNegotiatedFor] = useState(null);

  const load = async () => {
    setLoading(true);
    try {
      const [p, a, t] = await Promise.allSettled([
        fetchUsers({ role: 'dealer', dealer_status: 'pending' }),
        fetchUsers({ role: 'dealer', dealer_status: 'active' }),
        fetchDealerTiers(),
      ]);
      // Both list endpoints can return a plain array OR a paginated
      // {count, results} dict. Normalize to an array so .map / .filter
      // never blow up downstream (crash root-cause of the ErrorBoundary
      // when opening this page in prod).
      const toArr = (v) => (Array.isArray(v) ? v : Array.isArray(v?.results) ? v.results : []);
      setPending(toArr(p.status === 'fulfilled' ? p.value : []));
      setActive(toArr(a.status === 'fulfilled' ? a.value : []));
      setTiers(toArr(t.status === 'fulfilled' ? t.value : []));
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => { load(); }, []);

  const filteredActive = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return active;
    return active.filter((d) =>
      (d.full_name || '').toLowerCase().includes(q)
      || (d.email || '').toLowerCase().includes(q)
      || (d.dealer_company_name || '').toLowerCase().includes(q)
      || (d.dealer_gst_number || '').toLowerCase().includes(q)
    );
  }, [active, search]);

  const handleApprove = async (id, name) => {
    try {
      await approveDealer(id, 'active');
      toast.success(`${name} approved as dealer.`);
      await load();
    } catch {
      toast.error('Approval failed.');
    }
  };

  const handleReject = async (id, name) => {
    if (!window.confirm(`Reject ${name}'s dealer application?`)) return;
    try {
      await approveDealer(id, 'rejected');
      toast.success('Application rejected.');
      await load();
    } catch {
      toast.error('Rejection failed.');
    }
  };

  const handleSuspend = async (d) => {
    const next = d.dealer_status === 'active' ? 'rejected' : 'active';
    const verb = next === 'active' ? 'reactivate' : 'suspend';
    if (!window.confirm(`Are you sure you want to ${verb} ${d.full_name}?`)) return;
    try {
      await approveDealer(d.id, next);
      toast.success(`${d.full_name} ${verb}d.`);
      await load();
    } catch {
      toast.error('Status change failed.');
    }
  };

  const handleSetTier = async (dealerId, tierId) => {
    try {
      await approveDealer(dealerId, 'active', { dealer_tier: tierId || null });
      toast.success('Dealer tier updated.');
      await load();
    } catch {
      toast.error('Failed to update dealer tier.');
    }
  };

  return (
    <div className="admin-page">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <h2 className="admin-page__title" style={{ margin: 0 }}>Dealer Management</h2>
        <button className="btn-outline" onClick={() => setShowTierManager(true)}
                style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <FiPercent size={14} /> Manage Pricing Tiers
        </button>
      </div>

      {/* ─── Pending applications ─────────────────────────────────── */}
      <section className="admin-card">
        <div className="admin-card__header">
          <h3>
            Pending Applications
            {pending.length > 0 && <span className="admin-pill">{pending.length}</span>}
          </h3>
        </div>
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : pending.length === 0 ? (
          <p className="admin-empty">No pending applications.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Name</th><th>Email</th><th>Phone</th>
                <th>Company</th><th>GST</th><th>Applied</th>
                <th style={{ width: 140 }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {pending.map((d) => (
                <tr key={d.id}>
                  <td><strong>{d.full_name}</strong></td>
                  <td>{d.email}</td>
                  <td>{d.phone || '—'}</td>
                  <td>{d.dealer_company_name || '—'}</td>
                  <td><code>{d.dealer_gst_number || '—'}</code></td>
                  <td>{formatDate(d.date_joined)}</td>
                  <td style={{ display: 'flex', gap: 6 }}>
                    <button className="admin-icon-btn admin-icon-btn--success"
                            onClick={() => handleApprove(d.id, d.full_name)}>
                      <FiCheck size={14} /> Approve
                    </button>
                    <button className="admin-icon-btn admin-icon-btn--danger"
                            onClick={() => handleReject(d.id, d.full_name)}>
                      <FiX size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      {/* ─── Active dealers ───────────────────────────────────────── */}
      <section className="admin-card" style={{ marginTop: 24 }}>
        <div className="admin-card__header" style={{ flexWrap: 'wrap', gap: 12 }}>
          <h3>Active Dealers ({active.length})</h3>
          <div className="admin-toolbar__search" style={{ minWidth: 240 }}>
            <FiSearch />
            <input
              type="search"
              placeholder="Search by name, email, GST…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>

        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : filteredActive.length === 0 ? (
          <p className="admin-empty">
            {search ? 'No dealers match this search.' : 'No active dealers yet.'}
          </p>
        ) : (
        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Dealer</th>
                <th>Company / GST</th>
                <th>Pricing Tier</th>
                <th>Joined</th>
                <th style={{ width: 280, textAlign: 'right' }}>Admin actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredActive.map((d) => (
                <tr key={d.id}>
                  <td>
                    <strong>{d.full_name}</strong>
                    <div className="admin-meta-line">{d.email}</div>
                    {d.phone && <div className="admin-meta-line">{d.phone}</div>}
                  </td>
                  <td>
                    {d.dealer_company_name || '—'}
                    <div className="admin-meta-line">
                      <code>{d.dealer_gst_number || 'no GST'}</code>
                    </div>
                  </td>
                  <td>
                    <select 
                      value={d.dealer_tier || ''} 
                      onChange={(e) => handleSetTier(d.id, e.target.value)}
                      style={{ padding: '6px 10px', borderRadius: '6px', border: '1px solid #d1d5db', fontSize: '13px', background: '#f9fafb' }}
                    >
                      <option value="">No Tier (Standard Pricing)</option>
                      {tiers.map(t => (
                        <option key={t.id} value={t.id}>{t.name} ({t.default_discount_pct}% off)</option>
                      ))}
                    </select>
                  </td>
                  <td>{formatDate(d.date_joined)}</td>
                  <td style={{ display: 'flex', gap: 6, flexWrap: 'wrap',
                               justifyContent: 'flex-end' }}>
                    <button className="admin-icon-btn"
                            onClick={() => setCreditModalFor(d)}
                            title="Set credit limit / record payment">
                      <FiCreditCard size={13} /> Credit
                    </button>
                    <button className="admin-icon-btn"
                            onClick={() => setWalletModalFor(d)}
                            title="Top up wallet">
                      <FiDollarSign size={13} /> Wallet
                    </button>
                    <button className="admin-icon-btn"
                            onClick={() => setNegotiatedFor(d)}
                            title="Per-product negotiated price overrides">
                      <FiTag size={13} /> Pricing
                    </button>
                    <button className="admin-icon-btn admin-icon-btn--danger"
                            onClick={() => handleSuspend(d)}
                            title="Suspend / reactivate">
                      <FiPower size={13} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        )}
      </section>

      {creditModalFor && (
        <CreditModal
          dealer={creditModalFor}
          onClose={() => setCreditModalFor(null)}
          onSaved={() => { setCreditModalFor(null); }}
        />
      )}
      {walletModalFor && (
        <WalletModal
          dealer={walletModalFor}
          onClose={() => setWalletModalFor(null)}
          onSaved={() => { setWalletModalFor(null); }}
        />
      )}
      {negotiatedFor && (
        <NegotiatedPricesModal
          dealer={negotiatedFor}
          onClose={() => setNegotiatedFor(null)}
        />
      )}
      {showTierManager && (
        <TierManagementModal
          onClose={() => {
            setShowTierManager(false);
            load();
          }}
        />
      )}
    </div>
  );
}

// ─── Tier management modal ───────────────────────────────────────────────

function TierManagementModal({ onClose }) {
  const [tiers, setTiers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(null); // id or 'new'
  const [form, setForm] = useState({ name: '', default_discount_pct: '0', slug: '' });
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await fetchDealerTiers();
      setTiers(Array.isArray(data) ? data : Array.isArray(data?.results) ? data.results : []);
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => { load(); }, []);

  const startEdit = (t) => {
    setEditing(t.id);
    setForm({
      name: t.name,
      slug: t.slug || t.name.toLowerCase().replace(/\s+/g, '-'),
      default_discount_pct: String(t.default_discount_pct),
    });
  };

  const startNew = () => {
    setEditing('new');
    setForm({ name: '', slug: '', default_discount_pct: '0' });
  };

  const save = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        ...form,
        slug: form.slug || form.name.toLowerCase().replace(/\s+/g, '-'),
        default_discount_pct: parseFloat(form.default_discount_pct) || 0,
      };
      if (editing === 'new') await createDealerTier(payload);
      else await updateDealerTier(editing, payload);
      
      toast.success('Tier saved');
      setEditing(null);
      await load();
    } catch (err) {
      toast.error('Failed to save tier');
    } finally {
      setSaving(false);
    }
  };

  const remove = async (id) => {
    if (!window.confirm('Delete this tier? Dealers assigned to it will revert to standard pricing.')) return;
    try {
      await deleteDealerTier(id);
      toast.success('Tier deleted');
      await load();
    } catch {
      toast.error('Delete failed');
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()} style={{ maxWidth: 640 }}>
        <div className="admin-modal__header">
          <h3>B2B Pricing Tiers</h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>
        <div className="admin-modal__body">
          <p className="admin-meta-line" style={{ marginBottom: 20 }}>
            Tiers apply a global percentage discount to a dealer's account.
            You can also set per-product exceptions via the "Pricing" button on individual dealers.
          </p>

          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Tier Name</th>
                  <th>Global Discount</th>
                  <th style={{ width: 100, textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr><td colSpan="3" className="admin-empty">Loading tiers…</td></tr>
                ) : tiers.length === 0 ? (
                  <tr><td colSpan="3" className="admin-empty">No tiers created yet.</td></tr>
                ) : (
                  tiers.map(t => (
                    <tr key={t.id}>
                      <td><strong>{t.name}</strong> <code style={{ fontSize: 10, opacity: 0.6 }}>({t.slug})</code></td>
                      <td><span className="admin-pill" style={{ background: '#ECFDF5', color: '#047857' }}>{t.default_discount_pct}% OFF</span></td>
                      <td style={{ display: 'flex', gap: 6, justifyContent: 'flex-end' }}>
                        <button className="admin-icon-btn" onClick={() => startEdit(t)}>Edit</button>
                        <button className="admin-icon-btn admin-icon-btn--danger" onClick={() => remove(t.id)}>
                          <FiTrash2 size={12} />
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {editing ? (
            <form onSubmit={save} className="admin-card" style={{ marginTop: 24, padding: 16, background: '#F9FAFB' }}>
              <h4 style={{ marginBottom: 12 }}>{editing === 'new' ? 'Create New Tier' : 'Edit Tier'}</h4>
              <div className="admin-form-row">
                <label className="admin-form-field">
                  <span>Display Name</span>
                  <input value={form.name} required
                         onChange={e => setForm({ ...form, name: e.target.value })}
                         placeholder="e.g. Gold Partner" />
                </label>
                <label className="admin-form-field">
                  <span>Slug (unique ID)</span>
                  <input value={form.slug} required
                         onChange={e => setForm({ ...form, slug: e.target.value })}
                         placeholder="e.g. gold-partner" />
                </label>
                <label className="admin-form-field">
                  <span>Default Discount (%)</span>
                  <input type="number" step="0.1" min="0" max="100" value={form.default_discount_pct}
                         onChange={e => setForm({ ...form, default_discount_pct: e.target.value })} />
                </label>
              </div>
              <div style={{ marginTop: 16, display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
                <button type="button" className="btn-outline" onClick={() => setEditing(null)}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving}>
                  {saving ? 'Saving…' : editing === 'new' ? 'Create Tier' : 'Update Tier'}
                </button>
              </div>
            </form>
          ) : (
            <button className="btn-primary" style={{ marginTop: 20, width: '100%' }} onClick={startNew}>
              <FiPlusCircle size={14} /> Add New Pricing Tier
            </button>
          )}
        </div>
        <div className="admin-modal__footer">
          <button className="btn-outline" onClick={onClose}>Close</button>
        </div>
      </div>
    </div>
  );
}

// ─── Credit management modal ─────────────────────────────────────────────

function CreditModal({ dealer, onClose, onSaved }) {
  const [credit, setCredit] = useState(null);
  const [loading, setLoading] = useState(true);
  const [form, setForm] = useState({ credit_limit: '0', terms_days: '30', is_active: true });
  const [saving, setSaving] = useState(false);

  // Payment-recording state
  const [payAmount, setPayAmount] = useState('');
  const [payMethod, setPayMethod] = useState('bank_transfer');
  const [payReference, setPayReference] = useState('');
  const [payNote, setPayNote] = useState('');
  const [recording, setRecording] = useState(false);

  const reload = async () => {
    setLoading(true);
    try {
      const c = await fetchAdminDealerCredit(dealer.id);
      setCredit(c);
      setForm({
        credit_limit: String(c.credit_limit || '0'),
        terms_days: String(c.terms_days || '30'),
        is_active: !!c.is_active,
      });
    } catch {
      toast.error('Could not load credit info.');
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => { reload(); /* eslint-disable-next-line */ }, [dealer.id]);

  const saveLimit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await updateAdminDealerCredit(dealer.id, {
        credit_limit: parseFloat(form.credit_limit) || 0,
        terms_days: parseInt(form.terms_days, 10) || 0,
        is_active: !!form.is_active,
      });
      toast.success(`Credit settings saved for ${dealer.full_name}.`);
      await reload();
      onSaved?.();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Save failed.');
    } finally {
      setSaving(false);
    }
  };

  const recordPayment = async (e) => {
    e.preventDefault();
    const amt = parseFloat(payAmount);
    if (!Number.isFinite(amt) || amt <= 0) {
      toast.error('Enter a positive amount.');
      return;
    }
    setRecording(true);
    try {
      await recordAdminDealerPayment(dealer.id, {
        amount: amt,
        method: payMethod,
        reference: payReference.trim(),
        note: payNote.trim(),
      });
      toast.success('Payment recorded.');
      setPayAmount(''); setPayReference(''); setPayNote('');
      await reload();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Could not record payment.');
    } finally {
      setRecording(false);
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}
           style={{ maxWidth: 720 }}>
        <div className="admin-modal__header">
          <h3>
            Credit · {dealer.full_name}
            <span className="admin-meta-line" style={{ display: 'block', fontWeight: 400 }}>
              {dealer.email}
            </span>
          </h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>

        <div className="admin-modal__body" style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
          {/* Live snapshot */}
          {loading ? (
            <p className="admin-empty">Loading credit info…</p>
          ) : credit && (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12 }}>
              <Snapshot label="Credit Limit" value={formatPrice(credit.credit_limit)} />
              <Snapshot label="Currently Used" value={formatPrice(credit.amount_used)} tone="warn" />
              <Snapshot label="Available" value={formatPrice(credit.remaining)} tone="success" />
            </div>
          )}

          {/* Limit form */}
          <form onSubmit={saveLimit} style={{ borderTop: '1px solid #E5E7EB', paddingTop: 14 }}>
            <h4 style={{ margin: '0 0 10px', fontSize: 13, color: '#374151',
                         textTransform: 'uppercase', letterSpacing: '0.04em' }}>
              Credit settings
            </h4>
            <div className="admin-form-row">
              <label className="admin-form-field">
                <span>Credit limit (₹)</span>
                <input type="number" min="0" step="0.01"
                       value={form.credit_limit}
                       onChange={(e) => setForm({ ...form, credit_limit: e.target.value })} />
              </label>
              <label className="admin-form-field">
                <span>Payment terms (days)</span>
                <input type="number" min="0" step="1"
                       value={form.terms_days}
                       onChange={(e) => setForm({ ...form, terms_days: e.target.value })} />
              </label>
              <label className="admin-form-field admin-form-field--checkbox">
                <input type="checkbox" checked={form.is_active}
                       onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
                <span>Credit account active</span>
              </label>
            </div>
            <div style={{ marginTop: 10, display: 'flex', justifyContent: 'flex-end' }}>
              <button type="submit" disabled={saving} className="btn-primary">
                {saving ? 'Saving…' : 'Save credit settings'}
              </button>
            </div>
          </form>

          {/* Record payment */}
          <form onSubmit={recordPayment} style={{ borderTop: '1px solid #E5E7EB', paddingTop: 14 }}>
            <h4 style={{ margin: '0 0 10px', fontSize: 13, color: '#374151',
                         textTransform: 'uppercase', letterSpacing: '0.04em' }}>
              Record a payment received
            </h4>
            <div className="admin-form-row">
              <label className="admin-form-field">
                <span>Amount (₹)</span>
                <input type="number" min="0.01" step="0.01"
                       value={payAmount} onChange={(e) => setPayAmount(e.target.value)}
                       placeholder="e.g. 25000" required />
              </label>
              <label className="admin-form-field">
                <span>Method</span>
                <select value={payMethod} onChange={(e) => setPayMethod(e.target.value)}>
                  <option value="bank_transfer">Bank Transfer</option>
                  <option value="cheque">Cheque</option>
                  <option value="upi">UPI</option>
                  <option value="cash">Cash</option>
                  <option value="razorpay">Razorpay</option>
                </select>
              </label>
              <label className="admin-form-field">
                <span>Reference (UTR / cheque #)</span>
                <input value={payReference}
                       onChange={(e) => setPayReference(e.target.value)}
                       placeholder="optional" />
              </label>
            </div>
            <label className="admin-form-field" style={{ marginTop: 8 }}>
              <span>Note</span>
              <input value={payNote} onChange={(e) => setPayNote(e.target.value)}
                     placeholder="optional comment shown in ledger" />
            </label>
            <div style={{ marginTop: 10, display: 'flex', justifyContent: 'flex-end' }}>
              <button type="submit" disabled={recording} className="btn-primary"
                      style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                <FiPlusCircle size={14} />
                {recording ? 'Recording…' : 'Record payment'}
              </button>
            </div>
          </form>
        </div>
        <div className="admin-modal__footer">
          <button type="button" className="btn-outline" onClick={onClose}>Close</button>
        </div>
      </div>
    </div>
  );
}

// ─── Wallet topup modal ──────────────────────────────────────────────────

function WalletModal({ dealer, onClose, onSaved }) {
  const [amount, setAmount] = useState('');
  const [note, setNote] = useState('');
  const [saving, setSaving] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    const amt = parseFloat(amount);
    if (!Number.isFinite(amt) || amt <= 0) {
      toast.error('Enter a positive amount.');
      return;
    }
    setSaving(true);
    try {
      await adminWalletTopup(dealer.id, { amount: amt, note: note.trim() });
      toast.success(`Topped up ${formatPrice(amt)} to ${dealer.full_name}'s wallet.`);
      onSaved?.();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Top-up failed.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}
           style={{ maxWidth: 480 }}>
        <div className="admin-modal__header">
          <h3>
            Wallet Top-up · {dealer.full_name}
            <span className="admin-meta-line" style={{ display: 'block', fontWeight: 400 }}>
              {dealer.email}
            </span>
          </h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>
        <form onSubmit={submit}>
          <div className="admin-modal__body">
            <p className="admin-meta-line" style={{ marginBottom: 12 }}>
              Adds funds to the dealer's wallet. The dealer can spend this
              balance on orders by selecting "Wallet" as payment method.
            </p>
            <div className="admin-form-row">
              <label className="admin-form-field">
                <span>Amount (₹)</span>
                <input type="number" min="0.01" step="0.01" required autoFocus
                       value={amount}
                       onChange={(e) => setAmount(e.target.value)}
                       placeholder="e.g. 10000" />
              </label>
              <label className="admin-form-field">
                <span>Note (optional)</span>
                <input value={note} onChange={(e) => setNote(e.target.value)}
                       placeholder="e.g. Q3 incentive payout" />
              </label>
            </div>
          </div>
          <div className="admin-modal__footer">
            <button type="button" className="btn-outline" onClick={onClose}>Cancel</button>
            <button type="submit" disabled={saving} className="btn-primary">
              {saving ? 'Crediting…' : 'Top-up wallet'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ─── Negotiated prices modal ──────────────────────────────────────────────

function NegotiatedPricesModal({ dealer, onClose }) {
  const [rows, setRows] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [productId, setProductId] = useState('');
  const [price, setPrice] = useState('');
  const [validUntil, setValidUntil] = useState('');
  const [note, setNote] = useState('');
  const [saving, setSaving] = useState(false);
  const [search, setSearch] = useState('');

  const load = async () => {
    setLoading(true);
    try {
      const [list, prods] = await Promise.all([
        fetchNegotiatedPrices(dealer.id),
        fetchProducts({ page_size: 200 }),
      ]);
      setRows(Array.isArray(list) ? list : list.results || []);
      setProducts(prods.results || prods || []);
    } catch {
      toast.error('Could not load negotiated prices.');
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => { load(); /* eslint-disable-next-line */ }, [dealer.id]);

  const filteredProducts = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return products.slice(0, 50);
    return products.filter((p) => p.name.toLowerCase().includes(q)).slice(0, 50);
  }, [products, search]);

  const submit = async (e) => {
    e.preventDefault();
    const p = parseFloat(price);
    if (!productId || !Number.isFinite(p) || p <= 0) {
      toast.error('Pick a product and enter a valid price.');
      return;
    }
    setSaving(true);
    try {
      await upsertNegotiatedPrice(dealer.id, {
        product: parseInt(productId, 10),
        agreed_price: p,
        valid_until: validUntil || null,
        note: note.trim(),
      });
      toast.success('Override saved.');
      setProductId(''); setPrice(''); setValidUntil(''); setNote('');
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Save failed.');
    } finally {
      setSaving(false);
    }
  };

  const remove = async (row) => {
    if (!window.confirm(`Remove override for "${row.product_name}"? Dealer will revert to tier pricing.`)) return;
    try {
      await deleteNegotiatedPrice(dealer.id, row.id);
      toast.success('Override removed.');
      await load();
    } catch {
      toast.error('Delete failed.');
    }
  };

  return (
    <div className="admin-modal-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}
           style={{ maxWidth: 820 }}>
        <div className="admin-modal__header">
          <h3>
            Negotiated Prices · {dealer.full_name}
            <span className="admin-meta-line" style={{ display: 'block', fontWeight: 400 }}>
              Per-product overrides win over tier + quantity ladders
            </span>
          </h3>
          <button className="admin-modal__close" onClick={onClose}><FiX /></button>
        </div>

        <div className="admin-modal__body" style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
          {/* Add / upsert form */}
          <form onSubmit={submit} style={{ borderBottom: '1px solid #E5E7EB',
                                           paddingBottom: 14 }}>
            <h4 style={{ margin: '0 0 10px', fontSize: 13, color: '#374151',
                         textTransform: 'uppercase', letterSpacing: '0.04em' }}>
              Add / update override
            </h4>
            <div className="admin-form-row">
              <label className="admin-form-field">
                <span>Search products</span>
                <input type="search" placeholder="Type to filter…"
                       value={search} onChange={(e) => setSearch(e.target.value)} />
              </label>
              <label className="admin-form-field">
                <span>Product</span>
                <select value={productId} onChange={(e) => setProductId(e.target.value)} required>
                  <option value="">Select a product…</option>
                  {filteredProducts.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} — MRP {formatPrice(p.price)}
                    </option>
                  ))}
                </select>
              </label>
              <label className="admin-form-field">
                <span>Agreed price (₹)</span>
                <input type="number" min="0.01" step="0.01" required
                       value={price} onChange={(e) => setPrice(e.target.value)} />
              </label>
              <label className="admin-form-field">
                <span>Valid until (optional)</span>
                <input type="date" value={validUntil}
                       onChange={(e) => setValidUntil(e.target.value)} />
              </label>
            </div>
            <label className="admin-form-field" style={{ marginTop: 8 }}>
              <span>Note</span>
              <input value={note} onChange={(e) => setNote(e.target.value)}
                     placeholder="e.g. Q3 contract, project X" />
            </label>
            <div style={{ marginTop: 10, display: 'flex', justifyContent: 'flex-end' }}>
              <button type="submit" disabled={saving} className="btn-primary"
                      style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                <FiPlusCircle size={14} />
                {saving ? 'Saving…' : 'Save override'}
              </button>
            </div>
          </form>

          {/* Existing overrides */}
          <div>
            <h4 style={{ margin: '0 0 10px', fontSize: 13, color: '#374151',
                         textTransform: 'uppercase', letterSpacing: '0.04em' }}>
              Active overrides
              {!loading && <span style={{ color: '#9CA3AF', fontWeight: 500,
                                          textTransform: 'none', letterSpacing: 0,
                                          marginLeft: 6 }}>({rows.length})</span>}
            </h4>
            {loading ? (
              <p className="admin-empty">Loading…</p>
            ) : rows.length === 0 ? (
              <p className="admin-empty">No overrides — dealer pays standard tier price.</p>
            ) : (
              <table className="admin-table admin-table--compact">
                <thead>
                  <tr>
                    <th>Product</th><th>MRP</th><th>Agreed</th><th>Save</th>
                    <th>Valid until</th><th>Note</th><th></th>
                  </tr>
                </thead>
                <tbody>
                  {rows.map((r) => {
                    const mrp = parseFloat(r.product_mrp || 0);
                    const agreed = parseFloat(r.agreed_price || 0);
                    const saveAmt = Math.max(0, mrp - agreed);
                    const pct = mrp > 0 ? Math.round((saveAmt / mrp) * 100) : 0;
                    return (
                      <tr key={r.id}>
                        <td>
                          <strong>{r.product_name}</strong>
                          {r.product_sku && (
                            <div className="admin-meta-line"><code>{r.product_sku}</code></div>
                          )}
                        </td>
                        <td>{formatPrice(mrp)}</td>
                        <td><strong style={{ color: '#0E766E' }}>{formatPrice(agreed)}</strong></td>
                        <td>
                          {saveAmt > 0 ? (
                            <span style={{ color: '#047857', fontWeight: 600 }}>
                              {formatPrice(saveAmt)} <small>({pct}%)</small>
                            </span>
                          ) : (
                            <span className="admin-meta-line">—</span>
                          )}
                        </td>
                        <td className="admin-meta-line">
                          {r.valid_until ? formatDate(r.valid_until) : 'No expiry'}
                        </td>
                        <td className="admin-meta-line">{r.note || '—'}</td>
                        <td>
                          <button className="admin-icon-btn admin-icon-btn--danger"
                                  onClick={() => remove(r)} aria-label="Remove override">
                            <FiTrash2 size={13} />
                          </button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </div>
        </div>
        <div className="admin-modal__footer">
          <button type="button" className="btn-outline" onClick={onClose}>Close</button>
        </div>
      </div>
    </div>
  );
}

function Snapshot({ label, value, tone = 'neutral' }) {
  const colors = {
    neutral: { bg: '#F9FAFB', fg: '#111827' },
    success: { bg: '#ECFDF5', fg: '#047857' },
    warn:    { bg: '#FFFBEB', fg: '#92400E' },
  }[tone];
  return (
    <div style={{
      padding: 14, borderRadius: 10,
      background: colors.bg, color: colors.fg,
      display: 'flex', flexDirection: 'column', gap: 4,
    }}>
      <span style={{ fontSize: 11, fontWeight: 700, textTransform: 'uppercase',
                     letterSpacing: '0.06em', opacity: 0.75 }}>{label}</span>
      <strong style={{ fontSize: 18, fontWeight: 700 }}>
        {value}
      </strong>
    </div>
  );
}
