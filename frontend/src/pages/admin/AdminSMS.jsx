/**
 * AdminSMS — Full SMS campaign management page.
 *
 * Three tabs:
 *   1. Contacts — import bulk (textarea / CSV), add single, view list.
 *   2. Campaigns — create, queue, send, view progress.
 *   3. Deliveries — per-campaign delivery log with status.
 */
import { useEffect, useState } from 'react';
import { FiUpload, FiPlus, FiSend, FiUsers, FiMessageSquare, FiList, FiHeart, FiTrash2 } from 'react-icons/fi';
import toast from 'react-hot-toast';
import api, {
  fetchSmsContacts, createSmsContact, bulkImportSmsContacts,
  fetchSmsCampaigns, createSmsCampaign, queueSmsCampaign,
  sendSmsCampaign, fetchSmsCampaignDeliveries,
  fetchHighValueWishlistUsers,
  deleteSmsContact, bulkDeleteSmsContacts,
} from '../../api';
import Pagination from '../../components/Pagination';

const PAGE_SIZE = 20;
const TABS = ['Contacts', 'Campaigns', 'Deliveries'];

export default function AdminSMS() {
  const [tab, setTab] = useState('Contacts');

  return (
    <div className="admin-page">
      <h2 className="admin-page__title">SMS Campaigns</h2>

      <div className="admin-tabs">
        {TABS.map((t) => (
          <button
            key={t}
            className={`admin-tab ${tab === t ? 'admin-tab--active' : ''}`}
            onClick={() => setTab(t)}
          >
            {t === 'Contacts' && <FiUsers size={15} />}
            {t === 'Campaigns' && <FiMessageSquare size={15} />}
            {t === 'Deliveries' && <FiList size={15} />}
            <span>{t}</span>
          </button>
        ))}
      </div>

      {tab === 'Contacts' && <ContactsTab />}
      {tab === 'Campaigns' && <CampaignsTab />}
      {tab === 'Deliveries' && <DeliveriesTab />}
    </div>
  );
}


/* ═══════════════════════════════════════════════════════════════════════════
   CONTACTS TAB
   ═══════════════════════════════════════════════════════════════════════════ */
function ContactsTab() {
  const [contacts, setContacts] = useState([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);

  // Bulk import state
  const [bulkText, setBulkText] = useState('');
  const [bulkTag, setBulkTag] = useState('');
  const [csvFile, setCsvFile] = useState(null);
  const [importing, setImporting] = useState(false);

  // Single add state
  const [singlePhone, setSinglePhone] = useState('');
  const [singleName, setSingleName] = useState('');
  const [singleTag, setSingleTag] = useState('');

  // Contact-row selection for batch delete.
  const [selectedIds, setSelectedIds] = useState(() => new Set());

  const toggleSelected = (id) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const toggleSelectAll = () => {
    setSelectedIds((prev) =>
      prev.size === contacts.length
        ? new Set()
        : new Set(contacts.map((c) => c.id))
    );
  };

  const deleteOne = async (id, phone) => {
    if (!window.confirm(`Delete ${phone}?`)) return;
    try {
      await deleteSmsContact(id);
      toast.success('Deleted');
      setSelectedIds((prev) => {
        const next = new Set(prev); next.delete(id); return next;
      });
      loadContacts();
    } catch {
      toast.error('Failed to delete contact');
    }
  };

  const deleteSelected = async () => {
    if (selectedIds.size === 0) return;
    if (!window.confirm(`Delete ${selectedIds.size} contact(s)?`)) return;
    try {
      const res = await bulkDeleteSmsContacts({ ids: [...selectedIds] });
      toast.success(`Deleted ${res.deleted} contact(s)`);
      setSelectedIds(new Set());
      loadContacts();
    } catch {
      toast.error('Bulk delete failed');
    }
  };

  const deleteAllContacts = async () => {
    if (!window.confirm(
      `Delete ALL ${count} contacts? This cannot be undone.`
    )) return;
    if (!window.confirm('Are you absolutely sure?')) return;
    try {
      const res = await bulkDeleteSmsContacts({ all: true });
      toast.success(`Deleted ${res.deleted} contact(s)`);
      setSelectedIds(new Set());
      loadContacts();
    } catch {
      toast.error('Delete all failed');
    }
  };

  // High-value wishlist targeting state. The threshold is fully editable —
  // 50,000 is just a sensible default ("premium buyers"). Importing pulls
  // these users' phones into the bulk-import textarea so admin can review
  // before sending.
  const [hvThreshold, setHvThreshold] = useState(50000);
  const [hvUsers, setHvUsers] = useState([]);
  const [hvCount, setHvCount] = useState(null);
  const [hvLoading, setHvLoading] = useState(false);
  const [hvImporting, setHvImporting] = useState(false);
  // userIds selected for import; empty Set = none selected yet.
  const [hvSelected, setHvSelected] = useState(() => new Set());

  const loadContacts = async () => {
    setLoading(true);
    try {
      const data = await fetchSmsContacts({ page, page_size: PAGE_SIZE });
      const list = Array.isArray(data) ? data : data?.results || [];
      setContacts(list);
      setCount(typeof data?.count === 'number' ? data.count : list.length);
    } catch {
      toast.error('Failed to load contacts');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadContacts(); }, [page]);

  const handleBulkImport = async () => {
    if (!bulkText.trim() && !csvFile) {
      toast.error('Paste numbers or upload a CSV file.');
      return;
    }
    setImporting(true);
    try {
      let result;
      if (csvFile) {
        const fd = new FormData();
        fd.append('csv_file', csvFile);
        if (bulkTag) fd.append('tag', bulkTag);
        if (bulkText) fd.append('numbers', bulkText);
        result = await bulkImportSmsContacts(fd);
      } else {
        result = await bulkImportSmsContacts({ numbers: bulkText, tag: bulkTag });
      }
      toast.success(`Imported ${result.created} contacts (${result.skipped} duplicates skipped)`);
      if (result.errors?.length) {
        toast.error(`${result.errors.length} invalid numbers skipped`);
      }
      setBulkText('');
      setCsvFile(null);
      loadContacts();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Import failed');
    } finally {
      setImporting(false);
    }
  };

  // Fetch qualifying users + show them in a selectable table. Admin can then
  // tick the rows they want before pushing into Bulk Import.
  const handleWishlistPreview = async () => {
    setHvLoading(true);
    try {
      const res = await fetchHighValueWishlistUsers(hvThreshold);
      setHvUsers(res.results || []);
      setHvCount(res.count);
      // Pre-select everyone that actually has a phone — admin can untick.
      const eligible = (res.results || [])
        .filter((u) => u.phone && u.phone.trim().length >= 10)
        .map((u) => u.user_id);
      setHvSelected(new Set(eligible));
      if (res.count === 0) {
        toast(`No users with wishlist >= Rs. ${hvThreshold.toLocaleString('en-IN')}`);
      }
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to load wishlist users');
    } finally {
      setHvLoading(false);
    }
  };

  const toggleHvUser = (userId) => {
    setHvSelected((prev) => {
      const next = new Set(prev);
      if (next.has(userId)) next.delete(userId);
      else next.add(userId);
      return next;
    });
  };

  const toggleHvAll = () => {
    if (hvSelected.size === hvUsers.filter((u) => u.phone).length) {
      setHvSelected(new Set());
    } else {
      setHvSelected(new Set(
        hvUsers.filter((u) => u.phone && u.phone.trim().length >= 10)
          .map((u) => u.user_id)
      ));
    }
  };

  // Directly import selected wishlist users as SMS contacts, preserving
  // each user's NAME (the textarea path loses it because it only carries
  // phone numbers). Uses the bulk endpoint's structured `contacts` field
  // which accepts a list of {phone, name} objects. Auto-tags everyone
  // `wishlist_<threshold>` for future re-targeting.
  const handleWishlistImport = async () => {
    if (!hvUsers.length) {
      toast.error('Click "Preview count" first to load qualifying users.');
      return;
    }
    if (hvSelected.size === 0) {
      toast.error('Tick at least one user to import.');
      return;
    }
    const rows = hvUsers
      .filter((u) => hvSelected.has(u.user_id))
      .filter((u) => u.phone && u.phone.trim().length >= 10)
      .map((u) => ({ phone: u.phone, name: u.name || '' }));
    if (rows.length === 0) {
      toast.error('Selected users have no valid phone numbers.');
      return;
    }
    setHvImporting(true);
    try {
      const tag = `wishlist_${hvThreshold}`;
      const result = await bulkImportSmsContacts({
        contacts: JSON.stringify(rows),
        tag,
      });
      const created = result.created || 0;
      const skipped = result.skipped || 0;
      toast.success(
        `Imported ${created} new contact${created === 1 ? '' : 's'}`
        + (skipped ? ` (${skipped} were already on file)` : '')
      );
      // Refresh the contacts table so the new rows show up immediately.
      loadContacts();
      // Also seed the bulk tag so the admin can keep adding more under
      // the same tag if they want.
      setBulkTag(tag);
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Import failed');
    } finally {
      setHvImporting(false);
    }
  };

  const handleSingleAdd = async () => {
    if (!singlePhone.trim()) return;
    try {
      const res = await api.post('/sms/contacts/', {
        phone: singlePhone, name: singleName, tag: singleTag,
      });
      // Backend returns header 'X-Woodmark-Duplicate: 1' when the phone
      // already existed; we still get 200 with the existing row so the
      // admin gets a friendly "already on file" message instead of an error.
      if (res.headers && res.headers['x-woodmark-duplicate']) {
        toast(`${res.data.phone} is already on file.`);
      } else {
        toast.success('Contact added');
      }
      setSinglePhone('');
      setSingleName('');
      setSingleTag('');
      loadContacts();
    } catch (err) {
      toast.error(err.response?.data?.phone?.[0] || 'Failed to add contact');
    }
  };

  return (
    <>
      {/* Bulk import card */}
      <div className="admin-card" style={{ marginBottom: 20 }}>
        <div className="section-header">
          <span className="section-header__icon">
            <FiUpload size={20} />
          </span>
          <div className="section-header__text">
            <h3 className="section-header__title">Bulk Import Contacts</h3>
            <p className="section-header__subtitle">
              Paste phone numbers (one per line or comma-separated) or upload
              a CSV. Numbers like <code>9876543210</code> auto-normalise to
              <code> +919876543210</code>. CSV columns:&nbsp;
              <strong>phone</strong> (required), <strong>name</strong>, <strong>tag</strong>.
            </p>
          </div>
        </div>

        <textarea
          className="admin-input"
          rows={6}
          placeholder={
`+919876543210
+919876543211
9876543212
or paste comma-separated: 9876543210, 9876543211`
          }
          value={bulkText}
          onChange={(e) => setBulkText(e.target.value)}
          style={{ width: '100%', fontFamily: 'monospace', fontSize: 13 }}
        />

        <div className="admin-form-grid" style={{ marginTop: 14 }}>
          <label className="admin-label">
            Tag (optional)
            <input className="admin-input" value={bulkTag}
                   onChange={(e) => setBulkTag(e.target.value)}
                   placeholder="e.g. diwali_offer" />
          </label>
          <label className="admin-label">
            CSV file (optional)
            <input type="file" accept=".csv"
                   onChange={(e) => setCsvFile(e.target.files?.[0] || null)}
                   className="admin-input" style={{ padding: 8 }} />
          </label>
        </div>

        <div style={{ marginTop: 16, display: 'flex', alignItems: 'center', gap: 12 }}>
          <button className="btn-primary"
                  onClick={handleBulkImport}
                  disabled={importing}
                  style={{ display: 'inline-flex', gap: 8, alignItems: 'center' }}>
            <FiUpload size={16} /> {importing ? 'Importing…' : 'Import contacts'}
          </button>
          {(bulkText || csvFile) && !importing && (
            <span style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>
              {csvFile ? `1 CSV ready · ` : ''}
              {bulkText ? `${bulkText.split(/[,;\n]/).filter(s => s.trim()).length} number(s) ready` : ''}
            </span>
          )}
        </div>
      </div>

      {/* High-value wishlist targeting card */}
      <div className="admin-card" style={{ marginBottom: 20 }}>
        <div className="section-header">
          <span className="section-header__icon section-header__icon--red">
            <FiHeart size={20} />
          </span>
          <div className="section-header__text">
            <h3 className="section-header__title">Target High-Value Wishlist Customers</h3>
            <p className="section-header__subtitle">
              Find users whose wishlisted products total at least the threshold
              you set — your highest-intent buyers. Tick the rows you want,
              then click <em>Import as contacts</em> — name + phone go straight
              into the contacts table, tagged <code>wishlist_&lt;amount&gt;</code>.
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, alignItems: 'flex-end' }}>
          <label className="admin-label" style={{ flex: '1 1 220px' }}>
            Wishlist value threshold (Rs.)
            <input
              type="number"
              min="0"
              step="1000"
              className="admin-input"
              value={hvThreshold}
              onChange={(e) => setHvThreshold(parseInt(e.target.value || '0', 10))}
            />
          </label>
          <button
            className="btn-outline"
            onClick={handleWishlistPreview}
            disabled={hvLoading || hvImporting}
            style={{ height: 40 }}
          >
            {hvLoading ? 'Counting…' : 'Preview count'}
          </button>
          <button
            className="btn-primary"
            onClick={handleWishlistImport}
            disabled={hvLoading || hvImporting || hvSelected.size === 0}
            style={{ height: 40, display: 'inline-flex', gap: 6, alignItems: 'center' }}
          >
            <FiUpload size={14} />
            {hvImporting
              ? 'Importing…'
              : `Import ${hvSelected.size || ''} as contacts`}
          </button>
        </div>

        {hvCount !== null && hvUsers.length > 0 && (
          <>
            <p style={{ marginTop: 14, marginBottom: 8, fontSize: 13, color: 'var(--color-text-muted)' }}>
              <strong>{hvCount}</strong> user{hvCount === 1 ? '' : 's'} with wishlist
              ≥ Rs. {hvThreshold.toLocaleString('en-IN')}.
              Tick the rows you want, then click <em>Load into Bulk Import</em>.
            </p>
            <div className="admin-table-wrapper" style={{ marginTop: 8 }}>
              <table className="admin-table admin-table--compact">
                <thead>
                  <tr>
                    <th style={{ width: 32 }}>
                      <input
                        type="checkbox"
                        checked={
                          hvUsers.filter((u) => u.phone && u.phone.trim().length >= 10).length > 0 &&
                          hvSelected.size === hvUsers.filter((u) => u.phone && u.phone.trim().length >= 10).length
                        }
                        onChange={toggleHvAll}
                        title="Select / deselect all"
                      />
                    </th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th style={{ textAlign: 'right' }}>Wishlist value</th>
                    <th style={{ textAlign: 'right' }}>Items</th>
                  </tr>
                </thead>
                <tbody>
                  {hvUsers.map((u) => {
                    const hasPhone = u.phone && u.phone.trim().length >= 10;
                    return (
                      <tr key={u.user_id}
                          style={!hasPhone ? { opacity: 0.55 } : undefined}>
                        <td>
                          <input
                            type="checkbox"
                            checked={hvSelected.has(u.user_id)}
                            onChange={() => toggleHvUser(u.user_id)}
                            disabled={!hasPhone}
                            title={hasPhone ? '' : 'No phone on file'}
                          />
                        </td>
                        <td>{u.name || <span style={{ color: 'var(--color-text-muted)' }}>—</span>}</td>
                        <td style={{ wordBreak: 'break-all' }}>{u.email}</td>
                        <td>{u.phone || <span style={{ color: '#e74c3c' }}>no phone</span>}</td>
                        <td style={{ textAlign: 'right', fontWeight: 600 }}>
                          Rs. {Math.round(u.wishlist_value).toLocaleString('en-IN')}
                        </td>
                        <td style={{ textAlign: 'right' }}>{u.item_count}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </>
        )}
        {hvCount === 0 && (
          <p style={{ marginTop: 12, fontSize: 13, color: 'var(--color-text-muted)' }}>
            No users qualify at this threshold. Try lowering the value.
          </p>
        )}
      </div>

      {/* Single add card */}
      <div className="admin-card" style={{ marginBottom: 20 }}>
        <div className="section-header">
          <span className="section-header__icon section-header__icon--blue">
            <FiPlus size={20} />
          </span>
          <div className="section-header__text">
            <h3 className="section-header__title">Add a single contact</h3>
            <p className="section-header__subtitle">
              Add one number manually with an optional name and tag.
              Useful for adding VIPs or fixing an import gap.
            </p>
          </div>
        </div>
        <div className="admin-form-grid">
          <label className="admin-label">
            Phone *
            <input className="admin-input" value={singlePhone}
                   onChange={(e) => setSinglePhone(e.target.value)}
                   placeholder="+91XXXXXXXXXX" />
          </label>
          <label className="admin-label">
            Name
            <input className="admin-input" value={singleName}
                   onChange={(e) => setSingleName(e.target.value)} />
          </label>
          <label className="admin-label">
            Tag
            <input className="admin-input" value={singleTag}
                   onChange={(e) => setSingleTag(e.target.value)} />
          </label>
        </div>
        <button className="btn-primary" onClick={handleSingleAdd}
                style={{ marginTop: 10, display: 'inline-flex', gap: 6, alignItems: 'center' }}>
          <FiPlus /> Add
        </button>
      </div>

      {/* Toolbar — selection counter + Delete selected + Delete all */}
      {contacts.length > 0 && (
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '12px 14px', background: '#fff', border: '1px solid #eef0ee',
          borderRadius: 12, marginBottom: 10, gap: 12, flexWrap: 'wrap',
        }}>
          <div style={{ fontSize: 13, color: 'var(--color-text-muted)' }}>
            {selectedIds.size > 0
              ? <strong style={{ color: 'var(--color-text)' }}>{selectedIds.size} selected</strong>
              : <>Showing {contacts.length} of {count} contact{count === 1 ? '' : 's'}</>}
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            {selectedIds.size > 0 && (
              <button
                type="button"
                onClick={deleteSelected}
                className="admin-chip"
                style={{ borderColor: '#e74c3c', color: '#e74c3c', height: 34 }}
              >
                <FiTrash2 size={13} /> Delete selected
              </button>
            )}
            <button
              type="button"
              onClick={deleteAllContacts}
              className="admin-chip admin-chip--ghost"
              style={{ height: 34 }}
              disabled={count === 0}
            >
              <FiTrash2 size={13} /> Delete all
            </button>
          </div>
        </div>
      )}

      {/* Contact list */}
      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : contacts.length === 0 ? (
          <div className="admin-empty">
            <FiUsers size={28} style={{ opacity: 0.4 }} />
            <p style={{ margin: 0, fontWeight: 600 }}>No contacts yet</p>
            <p style={{ margin: 0, fontSize: 12 }}>Import numbers above or add one manually.</p>
          </div>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th style={{ width: 32 }}>
                  <input
                    type="checkbox"
                    checked={contacts.length > 0 && selectedIds.size === contacts.length}
                    onChange={toggleSelectAll}
                    title="Select / deselect all on this page"
                  />
                </th>
                <th>Phone</th>
                <th>Name</th>
                <th>Tag</th>
                <th>Source</th>
                <th>Active</th>
                <th style={{ width: 60 }}></th>
              </tr>
            </thead>
            <tbody>
              {contacts.map((c) => (
                <tr key={c.id}
                    style={selectedIds.has(c.id)
                      ? { background: 'var(--color-brand-pale)' } : undefined}>
                  <td>
                    <input
                      type="checkbox"
                      checked={selectedIds.has(c.id)}
                      onChange={() => toggleSelected(c.id)}
                    />
                  </td>
                  <td><code>{c.phone}</code></td>
                  <td>{c.name || <span style={{ color: 'var(--color-text-muted)' }}>—</span>}</td>
                  <td>
                    {c.tag ? (
                      <span style={{
                        display: 'inline-block', padding: '2px 8px',
                        background: 'var(--color-brand-pale)', color: 'var(--color-brand)',
                        borderRadius: 999, fontSize: 11, fontWeight: 700,
                      }}>{c.tag}</span>
                    ) : (
                      <span style={{ color: 'var(--color-text-muted)' }}>—</span>
                    )}
                  </td>
                  <td style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>{c.source}</td>
                  <td>{c.is_active ? '✓' : '✗'}</td>
                  <td>
                    <button
                      type="button"
                      onClick={() => deleteOne(c.id, c.phone)}
                      title="Delete contact"
                      style={{
                        background: 'transparent', border: 'none',
                        color: '#e74c3c', cursor: 'pointer', padding: 4,
                        borderRadius: 6,
                      }}
                    >
                      <FiTrash2 size={15} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <Pagination page={page} count={count} pageSize={PAGE_SIZE} onChange={setPage} />
      </div>
    </>
  );
}


/* ═══════════════════════════════════════════════════════════════════════════
   CAMPAIGNS TAB
   ═══════════════════════════════════════════════════════════════════════════ */
function CampaignsTab() {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState({
    name: '', message: '', audience: 'all', audience_tag: '',
  });

  const loadCampaigns = async () => {
    setLoading(true);
    try {
      const data = await fetchSmsCampaigns();
      const list = Array.isArray(data) ? data : data?.results || [];
      setCampaigns(list);
    } catch {
      toast.error('Failed to load campaigns');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadCampaigns(); }, []);

  const handleCreate = async () => {
    if (!form.name.trim() || !form.message.trim()) {
      toast.error('Name and message are required.');
      return;
    }
    setCreating(true);
    try {
      await createSmsCampaign(form);
      toast.success('Campaign created');
      setForm({ name: '', message: '', audience: 'all', audience_tag: '' });
      loadCampaigns();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to create campaign');
    } finally {
      setCreating(false);
    }
  };

  const handleQueue = async (c) => {
    try {
      await queueSmsCampaign(c.id);
      toast.success('Campaign queued — recipients materialised');
      loadCampaigns();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Queue failed');
    }
  };

  const handleSend = async (c) => {
    if (!window.confirm(`Send "${c.name}" to ${c.total_count} recipients? This cannot be undone.`)) return;
    try {
      toast('Sending… this may take a moment for large audiences.');
      await sendSmsCampaign(c.id);
      toast.success('Campaign sent!');
      loadCampaigns();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Send failed');
      loadCampaigns(); // refresh to see partial progress
    }
  };

  return (
    <>
      <div className="admin-card" style={{ marginBottom: 20 }}>
        <h3 style={{ marginTop: 0 }}>Create campaign</h3>
        <div className="admin-form-grid">
          <label className="admin-label">
            Campaign name *
            <input className="admin-input" value={form.name}
                   onChange={(e) => setForm({ ...form, name: e.target.value })} />
          </label>
          <label className="admin-label">
            Audience
            <select className="admin-input" value={form.audience}
                    onChange={(e) => setForm({ ...form, audience: e.target.value })}>
              <option value="all">All contacts</option>
              <option value="customers">Registered customers</option>
              <option value="dealers">Dealers</option>
              <option value="manual">Manual list</option>
              <option value="wishlist">Wishlist owners</option>
              <option value="high_value">High-value orders (&gt;50k)</option>
              <option value="tag">By tag</option>
            </select>
          </label>
          {form.audience === 'tag' && (
            <label className="admin-label">
              Tag filter
              <input className="admin-input" value={form.audience_tag}
                     onChange={(e) => setForm({ ...form, audience_tag: e.target.value })}
                     placeholder="e.g. diwali_offer" />
            </label>
          )}
        </div>
        <label className="admin-label" style={{ marginTop: 10 }}>
          Message body *
          <textarea className="admin-input" rows={4} value={form.message}
                    onChange={(e) => setForm({ ...form, message: e.target.value })}
                    placeholder="Hi {name}, great offers at Woodmark! Visit now."
                    style={{ width: '100%' }} />
          <span className="admin-meta-line">Use {'{name}'} for personalisation. Max 1000 chars.</span>
        </label>
        <button className="btn-primary" onClick={handleCreate} disabled={creating}
                style={{ marginTop: 10, display: 'inline-flex', gap: 6, alignItems: 'center' }}>
          <FiPlus /> {creating ? 'Creating…' : 'Create campaign'}
        </button>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : campaigns.length === 0 ? (
          <p className="admin-empty">No campaigns yet.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Audience</th>
                <th>Status</th>
                <th>Total</th>
                <th>Sent</th>
                <th>Failed</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {campaigns.map((c) => (
                <tr key={c.id}>
                  <td><strong>{c.name}</strong></td>
                  <td>{c.audience}{c.audience_tag ? ` (${c.audience_tag})` : ''}</td>
                  <td>
                    <span className={`status-badge status-badge--${c.status}`}>{c.status}</span>
                  </td>
                  <td>{c.total_count}</td>
                  <td>{c.sent_count}</td>
                  <td>{c.failed_count}</td>
                  <td style={{ whiteSpace: 'nowrap' }}>
                    {c.status === 'draft' && (
                      <button className="btn-outline" onClick={() => handleQueue(c)}>
                        Queue
                      </button>
                    )}
                    {c.status === 'queued' && (
                      <button className="btn-outline" onClick={() => handleSend(c)}
                              style={{ display: 'inline-flex', gap: 4, alignItems: 'center' }}>
                        <FiSend /> Send now
                      </button>
                    )}
                    {(c.status === 'sending' || c.status === 'sent') && (
                      <span className="admin-meta-line">
                        {c.sent_count}/{c.total_count} sent
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}


/* ═══════════════════════════════════════════════════════════════════════════
   DELIVERIES TAB
   ═══════════════════════════════════════════════════════════════════════════ */
function DeliveriesTab() {
  const [campaigns, setCampaigns] = useState([]);
  const [selectedCampaign, setSelectedCampaign] = useState(null);
  const [deliveries, setDeliveries] = useState([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [count, setCount] = useState(0);

  useEffect(() => {
    fetchSmsCampaigns().then((data) => {
      const list = Array.isArray(data) ? data : data?.results || [];
      setCampaigns(list);
    }).catch(() => {});
  }, []);

  useEffect(() => {
    if (!selectedCampaign) return;
    setLoading(true);
    fetchSmsCampaignDeliveries(selectedCampaign, { page, page_size: PAGE_SIZE })
      .then((data) => {
        const list = Array.isArray(data) ? data : data?.results || [];
        setDeliveries(list);
        setCount(typeof data?.count === 'number' ? data.count : list.length);
      })
      .catch(() => toast.error('Failed to load deliveries'))
      .finally(() => setLoading(false));
  }, [selectedCampaign, page]);

  return (
    <>
      <div className="admin-form-grid" style={{ marginBottom: 16 }}>
        <label className="admin-label">
          Select campaign
          <select className="admin-input" value={selectedCampaign || ''}
                  onChange={(e) => { setSelectedCampaign(e.target.value || null); setPage(1); }}>
            <option value="">— Choose —</option>
            {campaigns.map((c) => (
              <option key={c.id} value={c.id}>{c.name} ({c.status})</option>
            ))}
          </select>
        </label>
      </div>

      {selectedCampaign && (
        <div className="admin-table-wrapper">
          {loading ? (
            <p className="admin-empty">Loading…</p>
          ) : deliveries.length === 0 ? (
            <p className="admin-empty">No deliveries for this campaign.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr><th>Phone</th><th>Name</th><th>Status</th><th>Sent at</th></tr>
              </thead>
              <tbody>
                {deliveries.map((d) => (
                  <tr key={d.id}>
                    <td><code>{d.phone}</code></td>
                    <td>{d.name || '—'}</td>
                    <td>
                      <span className={`status-badge status-badge--${d.status}`}>{d.status}</span>
                    </td>
                    <td>{d.sent_at ? new Date(d.sent_at).toLocaleString() : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
          <Pagination page={page} count={count} pageSize={PAGE_SIZE} onChange={setPage} />
        </div>
      )}
    </>
  );
}
