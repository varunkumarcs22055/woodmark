import { useState, useEffect, useMemo, useCallback } from 'react';
import { FiSend, FiUsers, FiMail, FiCheckCircle, FiSearch, FiCheckSquare, FiSquare, FiChevronLeft, FiChevronRight } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchNewsletterStats, sendNewsletterCampaign, fetchNewsletterCampaigns, fetchNewsletterRecipients } from '../../api';
import './AdminNewsletter.css';

export default function AdminNewsletter() {
  const [stats, setStats] = useState({ subscribers: 0, customers: 0, dealers: 0 });
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);

  const [form, setForm] = useState({
    subject: '',
    body: '',
    targets: [],
    customEmails: [],
  });

  const [dirGroup, setDirGroup] = useState('subscribers');
  const [dirSearch, setDirSearch] = useState('');
  const [dirPage, setDirPage] = useState(1);
  const [dirData, setDirData] = useState({ results: [], count: 0, total_pages: 1 });
  const [dirLoading, setDirLoading] = useState(false);

  const targetGroups = useMemo(() => ([
    { key: 'subscribers', label: 'Subscribers', count: stats.subscribers },
    { key: 'customers', label: 'Customers', count: stats.customers },
    { key: 'dealers', label: 'Active Dealers', count: stats.dealers },
  ]), [stats]);

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      const [s, c] = await Promise.all([
        fetchNewsletterStats(),
        fetchNewsletterCampaigns(),
      ]);
      setStats(s);
      setCampaigns(c.results || c || []);
    } catch (err) {
      toast.error('Failed to load newsletter data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDirectory = useCallback(async () => {
    setDirLoading(true);
    try {
      const data = await fetchNewsletterRecipients({ group: dirGroup, search: dirSearch, page: dirPage, page_size: 10 });
      setDirData(data);
    } catch (err) {
      toast.error('Failed to load recipients');
    } finally {
      setDirLoading(false);
    }
  }, [dirGroup, dirSearch, dirPage]);

  useEffect(() => {
    loadDirectory();
  }, [loadDirectory]);

  const toggleTargetGroup = (group) => {
    setForm(prev => {
      const targets = prev.targets.includes(group)
        ? prev.targets.filter(t => t !== group)
        : [...prev.targets, group];
      return { ...prev, targets };
    });
  };

  const toggleCustomEmail = (email) => {
    setForm(prev => {
      const customEmails = prev.customEmails.includes(email)
        ? prev.customEmails.filter(e => e !== email)
        : [...prev.customEmails, email];
      return { ...prev, customEmails };
    });
  };

  const handleSend = async (e) => {
    e.preventDefault();
    if (!form.subject.trim() || !form.body.trim()) {
      toast.error('Subject and body are required');
      return;
    }
    if (form.targets.length === 0 && form.customEmails.length === 0) {
      toast.error('Please select at least one recipient group or custom recipient');
      return;
    }

    const payload = {
      subject: form.subject,
      body: form.body,
      targets: form.targets,
      recipient_emails: form.customEmails,
    };

    if (!window.confirm(`Are you sure you want to send this newsletter to the selected recipients?`)) {
      return;
    }

    setSending(true);
    try {
      const res = await sendNewsletterCampaign(payload);
      toast.success(`Newsletter sent successfully to ${res.recipients_count} recipients!`);
      setForm({ subject: '', body: '', targets: [], customEmails: [] });
      loadDashboardData();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Failed to send newsletter');
    } finally {
      setSending(false);
    }
  };

  if (loading) return <div className="admin-empty">Loading newsletter dashboard...</div>;

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Newsletter & Marketing</h2>
      </div>

      <div className="admin-newsletter-container">
        {/* Left: Compose Form & Group Selection */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div className="newsletter-card">
            <h3 className="newsletter-title">
              <FiMail /> Compose Newsletter
            </h3>
            <form onSubmit={handleSend}>
              <div className="newsletter-field">
                <label>Subject Line</label>
                <input 
                  className="newsletter-input"
                  value={form.subject} 
                  onChange={e => setForm({ ...form, subject: e.target.value })}
                  placeholder="e.g. Exciting New Arrivals at FurnoTech!"
                  required
                />
              </div>

              <div className="newsletter-field">
                <label>Message Content (Plain Text / Markdown)</label>
                <textarea 
                  className="newsletter-input newsletter-textarea"
                  value={form.body}
                  onChange={e => setForm({ ...form, body: e.target.value })}
                  placeholder="Write your newsletter content here..."
                  required
                />
              </div>

              <div className="newsletter-field" style={{ marginTop: '32px' }}>
                <label>Bulk Send to Entire Groups</label>
                <div className="newsletter-target-grid">
                  {targetGroups.map((g) => (
                    <TargetCard
                      key={g.key}
                      label={g.label}
                      count={g.count}
                      selected={form.targets.includes(g.key)}
                      onClick={() => toggleTargetGroup(g.key)}
                    />
                  ))}
                </div>
                <div style={{ marginTop: '16px', fontSize: '13px', color: '#6b7280', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <span>
                    Selected Custom Emails: <strong style={{ color: form.customEmails.length > 0 ? '#4f46e5' : 'inherit' }}>{form.customEmails.length}</strong>
                  </span>
                  {form.customEmails.length > 0 && (
                    <button type="button" onClick={() => setForm(p => ({...p, customEmails: []}))} style={{ background: 'none', border: 'none', color: '#ef4444', cursor: 'pointer', fontWeight: 600 }}>
                      Clear Selection
                    </button>
                  )}
                </div>
              </div>

              <div style={{ marginTop: '32px' }}>
                <button 
                  type="submit" 
                  className="newsletter-btn" 
                  disabled={sending || (form.targets.length === 0 && form.customEmails.length === 0)}
                >
                  {sending ? 'Processing...' : <><FiSend /> Send Newsletter Now</>}
                </button>
              </div>
            </form>
          </div>

          <div className="newsletter-card">
            <h3 className="newsletter-title" style={{ fontSize: '18px', marginBottom: '20px' }}>
              Recent Campaigns
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              {campaigns.length === 0 ? (
                <p style={{ color: '#6b7280', fontSize: '14px', textAlign: 'center', padding: '20px' }}>No campaigns sent yet.</p>
              ) : (
                campaigns.slice(0, 5).map(c => (
                  <div key={c.id} className="campaign-item">
                    <div className="campaign-subject">{c.subject}</div>
                    <div className="campaign-meta">
                      <span className="campaign-date">{new Date(c.created_at).toLocaleString()}</span>
                      <span className={`badge ${c.status}`}>{c.status}</span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        {/* Right: Recipient Directory */}
        <div className="newsletter-card" style={{ display: 'flex', flexDirection: 'column', height: '100%', minHeight: '600px', padding: 0, overflow: 'hidden' }}>
          <div style={{ padding: '28px 28px 0 28px' }}>
            <h3 className="newsletter-title" style={{ marginBottom: '12px' }}>
              <FiUsers /> Individual Recipient Selection
            </h3>
            <p style={{ fontSize: '14px', color: '#6b7280', marginBottom: '24px', lineHeight: 1.5 }}>
              Use this directory to find and add specific individuals to your newsletter if you don't want to send it to the entire group.
            </p>

            <div className="newsletter-tabs">
              {['subscribers', 'customers', 'dealers'].map(grp => (
                <button 
                  key={grp}
                  className={`newsletter-tab ${dirGroup === grp ? 'active' : ''}`}
                  onClick={() => { setDirGroup(grp); setDirPage(1); }}
                >
                  {grp}
                </button>
              ))}
            </div>

            <div className="admin-search" style={{ marginBottom: '20px', width: '100%' }}>
              <FiSearch />
              <input 
                type="text" 
                placeholder="Search by name or email..." 
                value={dirSearch}
                onChange={e => { setDirSearch(e.target.value); setDirPage(1); }}
                style={{ width: '100%', padding: '10px 10px 10px 36px', border: '1px solid #e5e7eb', borderRadius: '8px', fontSize: '14px' }}
              />
            </div>
          </div>

          <div className="newsletter-directory-wrapper">
            {dirLoading ? (
              <div style={{ textAlign: 'center', padding: '60px 20px', color: '#9ca3af' }}>Loading recipients...</div>
            ) : dirData.results.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '60px 20px', color: '#9ca3af' }}>No recipients found matching your search.</div>
            ) : (
              <table className="newsletter-table">
                <thead>
                  <tr>
                    <th style={{ width: '50px', textAlign: 'center' }}>Add</th>
                    <th>User / Email</th>
                    <th>Details</th>
                  </tr>
                </thead>
                <tbody>
                  {dirData.results.map(user => {
                    const isSelected = form.customEmails.includes(user.email);
                    const isGroupSelected = form.targets.includes(user.group);
                    return (
                      <tr key={user.email} style={{ opacity: isGroupSelected ? 0.5 : 1, pointerEvents: isGroupSelected ? 'none' : 'auto' }}>
                        <td style={{ textAlign: 'center' }}>
                          <button 
                            type="button" 
                            className={`checkbox-btn ${isSelected || isGroupSelected ? 'selected' : ''}`}
                            onClick={() => !isGroupSelected && toggleCustomEmail(user.email)}
                            disabled={isGroupSelected}
                            title={isGroupSelected ? "Included via bulk group" : "Select for broadcast"}
                          >
                            {isSelected || isGroupSelected ? <FiCheckSquare size={20} /> : <FiSquare size={20} />}
                          </button>
                        </td>
                        <td>
                          <div className="user-name">{user.name || 'N/A'}</div>
                          <div className="user-email">{user.email}</div>
                        </td>
                        <td>
                          {user.company && <div className="detail-text">{user.company}</div>}
                          <div className="detail-text" style={{ fontSize: '12px', color: '#9ca3af' }}>Joined: {new Date(user.created_at).toLocaleDateString()}</div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </div>

          {/* Pagination */}
          {dirData.total_pages > 1 && (
            <div style={{ padding: '16px 28px', borderTop: '1px solid #e5e7eb', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#f9fafb' }}>
              <span style={{ fontSize: '13px', color: '#6b7280', fontWeight: 500 }}>
                Showing page {dirData.page} of {dirData.total_pages}
              </span>
              <div style={{ display: 'flex', gap: '8px' }}>
                <button 
                  type="button"
                  className="btn-outline" 
                  disabled={dirPage === 1} 
                  onClick={() => setDirPage(p => p - 1)}
                  style={{ padding: '6px 12px', display: 'flex', alignItems: 'center', gap: '4px' }}
                >
                  <FiChevronLeft /> Prev
                </button>
                <button 
                  type="button"
                  className="btn-outline" 
                  disabled={dirPage >= dirData.total_pages} 
                  onClick={() => setDirPage(p => p + 1)}
                  style={{ padding: '6px 12px', display: 'flex', alignItems: 'center', gap: '4px' }}
                >
                  Next <FiChevronRight />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function TargetCard({ label, count, selected, onClick }) {
  return (
    <button
      type="button"
      className={`newsletter-target-card ${selected ? 'is-selected' : ''}`}
      onClick={onClick}
    >
      <span className="target-label">{label}</span>
      <span className="target-count">{count}</span>
      <span className="target-check">
        {selected ? <FiCheckCircle size={22} /> : <div style={{ width: '22px', height: '22px', borderRadius: '50%', border: '2px solid #d1d5db' }} />}
      </span>
    </button>
  );
}


