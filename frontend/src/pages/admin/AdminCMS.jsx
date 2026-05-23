/**
 * AdminCMS — Banners · Pages · FAQs
 *
 * Endpoints under /api/cms/admin/{banners,pages,faqs}/
 */
import { useEffect, useState } from 'react';
import { FiPlus, FiEdit2, FiTrash2, FiX, FiUploadCloud, FiImage } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchAdminBanners, createBanner, updateBanner, deleteBanner,
  fetchAdminPages, createPage, updatePage, deletePage,
  fetchAdminFAQs, createFAQ, updateFAQ, deleteFAQ,
  fetchAdminContentBlocks, createContentBlock, updateContentBlock, deleteContentBlock,
  fetchNewsletterSubscribers, updateNewsletterSubscriber,
  fetchNewsletterCampaigns, createNewsletterCampaign,
} from '../../api';

const TABS = [
  { key: 'banners', label: 'Banners' },
  { key: 'pages',   label: 'Pages'   },
  { key: 'faqs',    label: 'FAQs'    },
  { key: 'content', label: 'Site Content' },
  { key: 'newsletter', label: 'Newsletter' },
];

export default function AdminCMS() {
  const [tab, setTab] = useState('banners');
  return (
    <div className="admin-page">
      <h2 className="admin-page__title">Content</h2>
      <div className="admin-toolbar">
        {TABS.map((t) => (
          <button
            key={t.key}
            className={`btn-outline ${tab === t.key ? 'is-active' : ''}`}
            onClick={() => setTab(t.key)}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'banners' && <BannersTab />}
      {tab === 'pages'   && <PagesTab />}
      {tab === 'faqs'    && <FAQsTab />}
      {tab === 'content' && <ContentBlocksTab />}
      {tab === 'newsletter' && <NewsletterTab />}
    </div>
  );
}

// ─── Banners ────────────────────────────────────────────────────────

const PLACEMENTS = [
  { value: 'home_hero',    label: 'Home Hero' },
  { value: 'home_strip',   label: 'Home Strip' },
  { value: 'category_top', label: 'Category Top' },
];
const EMPTY_BANNER = {
  title: '', image_url: '', link_url: '',
  placement: 'home_hero', is_active: true, sort_order: 0,
  starts_at: '', ends_at: '',
};

function BannersTab() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState({ open: false, editing: null });
  const [form, setForm] = useState(EMPTY_BANNER);
  // File staged for upload to Cloudinary — separate from form so the URL
  // field stays editable for the "paste a remote URL" workflow.
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState('');
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await fetchAdminBanners();
      setRows(Array.isArray(data) ? data
        : Array.isArray(data?.results) ? data.results : []);
    } catch { toast.error('Failed to load banners'); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const openAdd = () => {
    setModal({ open: true, editing: null });
    setForm(EMPTY_BANNER);
    setImageFile(null); setImagePreview('');
  };
  const openEdit = (b) => {
    setModal({ open: true, editing: b });
    setForm({
      title: b.title, image_url: b.image_url || '',
      link_url: b.link_url || '', placement: b.placement,
      is_active: b.is_active, sort_order: b.sort_order ?? 0,
      starts_at: b.starts_at?.slice(0, 16) || '',
      ends_at: b.ends_at?.slice(0, 16) || '',
    });
    setImageFile(null);
    // Show whatever the saved CDN URL is, so the admin sees the current
    // banner while editing without having to click around.
    setImagePreview(b.image_url_resolved || b.image_url || '');
  };
  const close = () => {
    setModal({ open: false, editing: null });
    setImageFile(null); setImagePreview('');
  };

  const onPickFile = (e) => {
    const f = e.target.files?.[0];
    if (!f) return;
    if (!f.type.startsWith('image/')) {
      toast.error('Please pick an image file.');
      return;
    }
    if (f.size > 10 * 1024 * 1024) {
      toast.error('Image is over 10 MB — please pick a smaller file.');
      return;
    }
    setImageFile(f);
    setImagePreview(URL.createObjectURL(f));
    e.target.value = '';
  };

  const save = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        ...form,
        sort_order: Number.parseInt(form.sort_order, 10) || 0,
        starts_at: form.starts_at ? new Date(form.starts_at).toISOString() : null,
        ends_at: form.ends_at ? new Date(form.ends_at).toISOString() : null,
      };
      // Attach the staged file so the api helper switches to multipart and
      // the backend Cloudinary field captures it.
      if (imageFile) payload.image = imageFile;
      if (modal.editing) await updateBanner(modal.editing.id, payload);
      else await createBanner(payload);
      toast.success(modal.editing ? 'Banner updated.' : 'Banner created.');
      close();
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Save failed.');
    } finally { setSaving(false); }
  };

  const remove = async (b) => {
    if (!window.confirm(`Delete "${b.title}"?`)) return;
    try { await deleteBanner(b.id); toast.success('Deleted.'); await load(); }
    catch { toast.error('Delete failed.'); }
  };

  return (
    <>
      <div className="admin-toolbar">
        <button className="btn-primary" onClick={openAdd}><FiPlus size={16} /> Add Banner</button>
      </div>
      <div className="admin-table-wrapper">
        {loading ? <p className="admin-empty">Loading…</p>
          : rows.length === 0 ? <p className="admin-empty">No banners.</p>
          : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Image</th><th>Title</th><th>Placement</th>
                  <th>Active</th><th>Sort</th><th>Window</th><th></th>
                </tr>
              </thead>
              <tbody>
                {rows.map((b) => (
                  <tr key={b.id}>
                    <td>
                      {b.image_url_resolved
                        ? <img src={b.image_url_resolved} alt="" className="admin-thumb" />
                        : '—'}
                    </td>
                    <td><strong>{b.title}</strong></td>
                    <td>{b.placement}</td>
                    <td>
                      <span className={`status-badge status-badge--${b.is_active ? 'confirmed' : 'cancelled'}`}>
                        {b.is_active ? 'Yes' : 'No'}
                      </span>
                    </td>
                    <td>{b.sort_order}</td>
                    <td>
                      <span className="admin-meta-line">
                        {b.starts_at || '—'} → {b.ends_at || '∞'}
                      </span>
                    </td>
                    <td>
                      <button className="admin-icon-btn" onClick={() => openEdit(b)}><FiEdit2 size={14} /></button>
                      <button className="admin-icon-btn admin-icon-btn--danger" onClick={() => remove(b)}>
                        <FiTrash2 size={14} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
      </div>

      {modal.open && (
        <div className="admin-modal-overlay" onClick={close}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
            <div className="admin-modal__header">
              <h3>{modal.editing ? 'Edit Banner' : 'Add Banner'}</h3>
              <button className="admin-modal__close" onClick={close}><FiX /></button>
            </div>
            <form onSubmit={save}>
              <div className="admin-modal__body">
                <div className="admin-form-grid">
                  <div className="admin-field">
                    <label>Title</label>
                    <input value={form.title}
                      onChange={(e) => setForm({ ...form, title: e.target.value })} required />
                  </div>
                  <div className="admin-field">
                    <label>Placement</label>
                    <select value={form.placement}
                      onChange={(e) => setForm({ ...form, placement: e.target.value })}>
                      {PLACEMENTS.map((p) => (
                        <option key={p.value} value={p.value}>{p.label}</option>
                      ))}
                    </select>
                  </div>
                  <div className="admin-field">
                    <label>Sort order</label>
                    <input type="number" min="0" value={form.sort_order}
                      onChange={(e) => setForm({ ...form, sort_order: e.target.value })} />
                  </div>
                  <div className="admin-field">
                    <label>Active</label>
                    <label className="admin-toggle">
                      <input type="checkbox" checked={form.is_active}
                        onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
                      <span>Visible on storefront within the date window</span>
                    </label>
                  </div>
                  <div className="admin-field">
                    <label>Starts at</label>
                    <input type="datetime-local" value={form.starts_at}
                      onChange={(e) => setForm({ ...form, starts_at: e.target.value })} />
                  </div>
                  <div className="admin-field">
                    <label>Ends at</label>
                    <input type="datetime-local" value={form.ends_at}
                      onChange={(e) => setForm({ ...form, ends_at: e.target.value })} />
                  </div>
                </div>
                <div className="admin-field">
                  <label>Banner image</label>
                  <div style={{
                    display: 'flex', gap: 14, alignItems: 'flex-start', flexWrap: 'wrap',
                  }}>
                    <div style={{
                      width: 200, height: 110, borderRadius: 10,
                      border: '1px dashed #D1D5DB', background: '#F9FAFB',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      overflow: 'hidden',
                    }}>
                      {imagePreview ? (
                        <img src={imagePreview} alt="preview"
                          style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                      ) : (
                        <FiImage size={26} style={{ color: '#9CA3AF' }} />
                      )}
                    </div>
                    <div style={{ flex: 1, minWidth: 240, display: 'flex',
                                  flexDirection: 'column', gap: 8 }}>
                      <label className="btn-outline" style={{
                        display: 'inline-flex', alignItems: 'center', gap: 6,
                        cursor: 'pointer', alignSelf: 'flex-start',
                      }}>
                        <FiUploadCloud size={14} />
                        {imageFile ? imageFile.name : 'Upload to Cloudinary'}
                        <input type="file" accept="image/*"
                          style={{ display: 'none' }} onChange={onPickFile} />
                      </label>
                      <small style={{ color: '#6B7280', fontSize: 12 }}>
                        Recommended size: 1600 × 700 px. Max 10 MB.<br />
                        Or paste an external image URL below.
                      </small>
                      <input value={form.image_url}
                        onChange={(e) => setForm({ ...form, image_url: e.target.value })}
                        placeholder="https://… (used only when no file is uploaded)" />
                    </div>
                  </div>
                </div>
                <div className="admin-field">
                  <label>Link URL (optional)</label>
                  <input value={form.link_url}
                    onChange={(e) => setForm({ ...form, link_url: e.target.value })}
                    placeholder="https://…" />
                </div>
              </div>
              <div className="admin-modal__footer">
                <button type="button" className="btn-outline" onClick={close}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving}>
                  {saving ? 'Saving…' : modal.editing ? 'Save Changes' : 'Create Banner'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}

// ─── Pages ───────────────────────────────────────────────────────────

const EMPTY_PAGE = { slug: '', title: '', body_md: '', is_published: true };
const POLICY_PAGES = [
  {
    slug: 'shipping-policy',
    title: 'Shipping Policy',
    body_md: '## Overview\nAdd shipping policy details here.\n\n## Delivery timelines\n- Standard shipping timelines.\n\n## Charges\n- Free shipping threshold and fees.\n',
  },
  {
    slug: 'return-policy',
    title: 'Return Policy',
    body_md: '## Overview\nAdd return policy details here.\n\n## Return window\n- Specify the return window.\n\n## Refunds\n- Refund timelines and conditions.\n',
  },
  {
    slug: 'privacy-policy',
    title: 'Privacy Policy',
    body_md: '## Overview\nAdd privacy policy details here.\n\n## Data collected\n- List data types collected.\n\n## Usage\n- Explain how data is used.\n',
  },
  {
    slug: 'contact-us',
    title: 'Contact Us',
    body_md: '## Overview\nAdd contact information here.\n\n## Support\n- Support hours and channels.\n',
  },
  {
    slug: 'support',
    title: 'Support',
    body_md: '## Overview\nAdd support page details here.\n\n## Tickets\n- How customers can open tickets.\n',
  },
];

function PagesTab() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState({ open: false, editing: null });
  const [form, setForm] = useState(EMPTY_PAGE);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    try { setRows((await fetchAdminPages()).results || []); }
    catch { toast.error('Failed to load pages'); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const openAdd = () => { setModal({ open: true, editing: null }); setForm(EMPTY_PAGE); };
  const openEdit = (p) => { setModal({ open: true, editing: p }); setForm({ ...p }); };
  const openPolicy = (p) => { setModal({ open: true, editing: null }); setForm({ ...EMPTY_PAGE, ...p }); };
  const close = () => setModal({ open: false, editing: null });

  const save = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (modal.editing) await updatePage(modal.editing.id, form);
      else await createPage(form);
      toast.success(modal.editing ? 'Page updated.' : 'Page created.');
      close();
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Save failed.');
    } finally { setSaving(false); }
  };

  const remove = async (p) => {
    if (!window.confirm(`Delete page "${p.slug}"?`)) return;
    try { await deletePage(p.id); toast.success('Deleted.'); await load(); }
    catch { toast.error('Delete failed.'); }
  };

  return (
    <>
      <div className="admin-toolbar">
        <button className="btn-primary" onClick={openAdd}><FiPlus size={16} /> Add Page</button>
      </div>
      <div className="admin-card admin-card--tight">
        <div className="admin-card__header">
          <h3>Policy shortcuts</h3>
          <span className="admin-meta-line">Create or edit the policy pages used in footer links.</span>
        </div>
        <div className="admin-action-group">
          {POLICY_PAGES.map((p) => {
            const existing = rows.find((row) => row.slug === p.slug);
            return (
              <button
                key={p.slug}
                className="btn-outline"
                onClick={() => (existing ? openEdit(existing) : openPolicy(p))}
              >
                {existing ? `Edit ${p.title}` : `Create ${p.title}`}
              </button>
            );
          })}
        </div>
      </div>
      <div className="admin-table-wrapper">
        {loading ? <p className="admin-empty">Loading…</p>
          : rows.length === 0 ? <p className="admin-empty">No pages.</p>
          : (
            <table className="admin-table">
              <thead>
                <tr><th>Slug</th><th>Title</th><th>Published</th><th>Updated</th><th></th></tr>
              </thead>
              <tbody>
                {rows.map((p) => (
                  <tr key={p.id}>
                    <td><code>/{p.slug}</code></td>
                    <td>{p.title}</td>
                    <td>
                      <span className={`status-badge status-badge--${p.is_published ? 'confirmed' : 'cancelled'}`}>
                        {p.is_published ? 'Yes' : 'No'}
                      </span>
                    </td>
                    <td>{p.updated_at?.slice(0, 16).replace('T', ' ')}</td>
                    <td>
                      <button className="admin-icon-btn" onClick={() => openEdit(p)}><FiEdit2 size={14} /></button>
                      <button className="admin-icon-btn admin-icon-btn--danger" onClick={() => remove(p)}>
                        <FiTrash2 size={14} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
      </div>

      {modal.open && (
        <div className="admin-modal-overlay" onClick={close}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()} style={{ maxWidth: 800 }}>
            <div className="admin-modal__header">
              <h3>{modal.editing ? 'Edit Page' : 'Add Page'}</h3>
              <button className="admin-modal__close" onClick={close}><FiX /></button>
            </div>
            <form onSubmit={save}>
              <div className="admin-modal__body">
                <div className="admin-form-grid">
                  <div className="admin-field">
                    <label>Slug (URL: /pages/&lt;slug&gt;)</label>
                    <input value={form.slug}
                      onChange={(e) => setForm({ ...form, slug: e.target.value })}
                      placeholder="terms" required pattern="[a-z0-9-]+" />
                  </div>
                  <div className="admin-field">
                    <label>Title</label>
                    <input value={form.title}
                      onChange={(e) => setForm({ ...form, title: e.target.value })} required />
                  </div>
                </div>
                <div className="admin-field">
                  <label>Published</label>
                  <label className="admin-toggle">
                    <input type="checkbox" checked={form.is_published}
                      onChange={(e) => setForm({ ...form, is_published: e.target.checked })} />
                    <span>Visible on storefront</span>
                  </label>
                </div>
                <div className="admin-field">
                  <label>Body (Markdown)</label>
                  <textarea rows={12} value={form.body_md}
                    onChange={(e) => setForm({ ...form, body_md: e.target.value })}
                    style={{ fontFamily: 'ui-monospace, monospace' }} />
                </div>
              </div>
              <div className="admin-modal__footer">
                <button type="button" className="btn-outline" onClick={close}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving}>
                  {saving ? 'Saving…' : modal.editing ? 'Save Changes' : 'Create Page'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}

// ─── FAQs ────────────────────────────────────────────────────────────

const EMPTY_FAQ = { question: '', answer: '', category: '', sort_order: 0, is_active: true };

function FAQsTab() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState({ open: false, editing: null });
  const [form, setForm] = useState(EMPTY_FAQ);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    try { setRows((await fetchAdminFAQs()).results || []); }
    catch { toast.error('Failed to load FAQs'); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const openAdd = () => { setModal({ open: true, editing: null }); setForm(EMPTY_FAQ); };
  const openEdit = (f) => { setModal({ open: true, editing: f }); setForm({ ...f }); };
  const close = () => setModal({ open: false, editing: null });

  const save = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = { ...form, sort_order: Number.parseInt(form.sort_order, 10) || 0 };
      if (modal.editing) await updateFAQ(modal.editing.id, payload);
      else await createFAQ(payload);
      toast.success(modal.editing ? 'FAQ updated.' : 'FAQ created.');
      close();
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Save failed.');
    } finally { setSaving(false); }
  };

  const remove = async (f) => {
    if (!window.confirm('Delete this FAQ?')) return;
    try { await deleteFAQ(f.id); toast.success('Deleted.'); await load(); }
    catch { toast.error('Delete failed.'); }
  };

  return (
    <>
      <div className="admin-toolbar">
        <button className="btn-primary" onClick={openAdd}><FiPlus size={16} /> Add FAQ</button>
      </div>
      <div className="admin-table-wrapper">
        {loading ? <p className="admin-empty">Loading…</p>
          : rows.length === 0 ? <p className="admin-empty">No FAQs.</p>
          : (
            <table className="admin-table">
              <thead>
                <tr><th>Q</th><th>Category</th><th>Active</th><th>Sort</th><th></th></tr>
              </thead>
              <tbody>
                {rows.map((f) => (
                  <tr key={f.id}>
                    <td><strong>{f.question}</strong>
                      <span className="admin-meta-line" style={{ whiteSpace: 'pre-wrap' }}>
                        {f.answer.length > 120 ? f.answer.slice(0, 120) + '…' : f.answer}
                      </span>
                    </td>
                    <td>{f.category || '—'}</td>
                    <td>
                      <span className={`status-badge status-badge--${f.is_active ? 'confirmed' : 'cancelled'}`}>
                        {f.is_active ? 'Yes' : 'No'}
                      </span>
                    </td>
                    <td>{f.sort_order}</td>
                    <td>
                      <button className="admin-icon-btn" onClick={() => openEdit(f)}><FiEdit2 size={14} /></button>
                      <button className="admin-icon-btn admin-icon-btn--danger" onClick={() => remove(f)}>
                        <FiTrash2 size={14} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
      </div>

      {modal.open && (
        <div className="admin-modal-overlay" onClick={close}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
            <div className="admin-modal__header">
              <h3>{modal.editing ? 'Edit FAQ' : 'Add FAQ'}</h3>
              <button className="admin-modal__close" onClick={close}><FiX /></button>
            </div>
            <form onSubmit={save}>
              <div className="admin-modal__body">
                <div className="admin-form-grid">
                  <div className="admin-field">
                    <label>Question</label>
                    <input value={form.question}
                      onChange={(e) => setForm({ ...form, question: e.target.value })} required />
                  </div>
                  <div className="admin-field">
                    <label>Category (optional)</label>
                    <input value={form.category}
                      onChange={(e) => setForm({ ...form, category: e.target.value })}
                      placeholder="Shipping, Returns…" />
                  </div>
                  <div className="admin-field">
                    <label>Sort order</label>
                    <input type="number" min="0" value={form.sort_order}
                      onChange={(e) => setForm({ ...form, sort_order: e.target.value })} />
                  </div>
                  <div className="admin-field">
                    <label>Active</label>
                    <label className="admin-toggle">
                      <input type="checkbox" checked={form.is_active}
                        onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
                      <span>Show on storefront</span>
                    </label>
                  </div>
                </div>
                <div className="admin-field">
                  <label>Answer</label>
                  <textarea rows={6} value={form.answer}
                    onChange={(e) => setForm({ ...form, answer: e.target.value })} required />
                </div>
              </div>
              <div className="admin-modal__footer">
                <button type="button" className="btn-outline" onClick={close}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving}>
                  {saving ? 'Saving…' : modal.editing ? 'Save Changes' : 'Create FAQ'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}

// ─── Site Content Blocks ───────────────────────────────────────────

const EMPTY_BLOCK = {
  key: '',
  title: '',
  body_md: '',
  data_json: '',
  is_active: true,
};
const CONTENT_BLOCK_TEMPLATES = [
  {
    key: 'home_hero_copy',
    title: 'Homepage Hero Copy',
    data_json: {
      eyebrow: 'New Arrival — Modern Sofas',
      title: 'Beautiful Homes',
      accent: 'Start Here',
      desc: 'Premium furniture & home essentials — crafted for the Indian home.',
      tags: ['Sofa', 'Dining Table', 'Bed', 'Office Chair', 'Bookshelf'],
      stats: [
        { num: '1L+', label: 'Happy Customers' },
        { num: '500+', label: 'Products' },
        { num: '4.8★', label: 'Avg Rating' },
      ],
    },
  },
  {
    key: 'trust_badges',
    title: 'Trust Badges Row',
    data_json: {
      items: [
        { icon: 'truck', title: 'Free Shipping', desc: 'On all orders above ₹299' },
        { icon: 'returns', title: 'Easy Returns', desc: '30-day hassle-free returns' },
        { icon: 'shield', title: '1-Year Warranty', desc: 'On all furniture products' },
        { icon: 'star', title: '1 Lakh+ Happy Homes', desc: 'Trusted by customers across India' },
      ],
    },
  },
  {
    key: 'promo_best_sellers',
    title: 'Best Sellers Promo',
    data_json: {
      tag: 'Limited Time',
      title: 'Up to 40% off on',
      title_accent: 'Best Sellers',
      desc: 'Shop our most-loved products at unbeatable prices',
      cta_text: 'Shop Best Sellers',
      cta_link: '/best-sellers',
      percent: '40%',
    },
  },
  {
    key: 'announcement_bar',
    title: 'Announcement Bar',
    data_json: {
      text: '🎉 Free shipping on orders above ₹299 · Trusted by 1 Lakh+ happy homes',
      phone: '1800-123-4567',
    },
  },
  {
    key: 'newsletter_footer',
    title: 'Footer Newsletter',
    data_json: {
      heading: 'Newsletter',
      desc: 'Get exclusive offers, style tips, and new arrivals directly in your inbox.',
      note: 'No spam. Unsubscribe anytime.',
    },
  },
  {
    key: 'nav_menu',
    title: 'Navbar Menu Override',
    data_json: {
      groups: [
        {
          label: 'Living Room',
          items: [
            { label: 'Sofas', slug: 'sofas' },
            { label: 'Tables', slug: 'tables' },
          ],
        },
      ],
    },
  },
];

function ContentBlocksTab() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState({ open: false, editing: null });
  const [form, setForm] = useState(EMPTY_BLOCK);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    try { setRows((await fetchAdminContentBlocks()).results || []); }
    catch { toast.error('Failed to load content blocks'); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const openAdd = () => { setModal({ open: true, editing: null }); setForm(EMPTY_BLOCK); };
  const openTemplate = (t) => {
    setModal({ open: true, editing: null });
    setForm({
      key: t.key,
      title: t.title,
      body_md: '',
      data_json: JSON.stringify(t.data_json, null, 2),
      is_active: true,
    });
  };
  const openEdit = (b) => {
    setModal({ open: true, editing: b });
    setForm({
      key: b.key,
      title: b.title || '',
      body_md: b.body_md || '',
      data_json: b.data_json ? JSON.stringify(b.data_json, null, 2) : '',
      is_active: b.is_active,
    });
  };
  const close = () => setModal({ open: false, editing: null });

  const save = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        key: form.key,
        title: form.title,
        body_md: form.body_md,
        is_active: form.is_active,
      };
      if (form.data_json?.trim()) {
        payload.data_json = JSON.parse(form.data_json);
      } else {
        payload.data_json = null;
      }
      if (modal.editing) await updateContentBlock(modal.editing.id, payload);
      else await createContentBlock(payload);
      toast.success(modal.editing ? 'Content updated.' : 'Content created.');
      close();
      await load();
    } catch (err) {
      const msg = err instanceof SyntaxError
        ? 'Invalid JSON. Please fix and try again.'
        : (err.response?.data?.detail || 'Save failed.');
      toast.error(msg);
    } finally { setSaving(false); }
  };

  const remove = async (b) => {
    if (!window.confirm(`Delete content block "${b.key}"?`)) return;
    try { await deleteContentBlock(b.id); toast.success('Deleted.'); await load(); }
    catch { toast.error('Delete failed.'); }
  };

  return (
    <>
      <div className="admin-toolbar">
        <button className="btn-primary" onClick={openAdd}><FiPlus size={16} /> Add Content</button>
      </div>
      <div className="admin-card admin-card--tight">
        <div className="admin-card__header">
          <h3>Quick templates</h3>
          <span className="admin-meta-line">Generate common homepage/content blocks.</span>
        </div>
        <div className="admin-action-group">
          {CONTENT_BLOCK_TEMPLATES.map((t) => (
            <button key={t.key} className="btn-outline" onClick={() => openTemplate(t)}>
              Create {t.title}
            </button>
          ))}
        </div>
      </div>
      <div className="admin-table-wrapper">
        {loading ? <p className="admin-empty">Loading…</p>
          : rows.length === 0 ? <p className="admin-empty">No content blocks.</p>
          : (
            <table className="admin-table admin-table--compact">
              <thead>
                <tr><th>Key</th><th>Title</th><th>Active</th><th>Updated</th><th></th></tr>
              </thead>
              <tbody>
                {rows.map((b) => (
                  <tr key={b.id}>
                    <td><code>{b.key}</code></td>
                    <td>{b.title || '—'}</td>
                    <td>
                      <span className={`status-badge status-badge--${b.is_active ? 'confirmed' : 'cancelled'}`}>
                        {b.is_active ? 'Yes' : 'No'}
                      </span>
                    </td>
                    <td>{b.updated_at?.slice(0, 16).replace('T', ' ')}</td>
                    <td>
                      <button className="admin-icon-btn" onClick={() => openEdit(b)}><FiEdit2 size={14} /></button>
                      <button className="admin-icon-btn admin-icon-btn--danger" onClick={() => remove(b)}>
                        <FiTrash2 size={14} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
      </div>

      {modal.open && (
        <div className="admin-modal-overlay" onClick={close}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()} style={{ maxWidth: 900 }}>
            <div className="admin-modal__header">
              <h3>{modal.editing ? 'Edit Content Block' : 'Add Content Block'}</h3>
              <button className="admin-modal__close" onClick={close}><FiX /></button>
            </div>
            <form onSubmit={save}>
              <div className="admin-modal__body">
                <div className="admin-form-grid">
                  <div className="admin-field">
                    <label>Key (slug)</label>
                    <input value={form.key}
                      onChange={(e) => setForm({ ...form, key: e.target.value })}
                      placeholder="home_hero_copy" required pattern="[a-z0-9-_]+" />
                  </div>
                  <div className="admin-field">
                    <label>Title</label>
                    <input value={form.title}
                      onChange={(e) => setForm({ ...form, title: e.target.value })} />
                  </div>
                </div>
                <div className="admin-field">
                  <label>Active</label>
                  <label className="admin-toggle">
                    <input type="checkbox" checked={form.is_active}
                      onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
                    <span>Visible on storefront</span>
                  </label>
                </div>
                <div className="admin-field">
                  <label>Body (Markdown)</label>
                  <textarea rows={8} value={form.body_md}
                    onChange={(e) => setForm({ ...form, body_md: e.target.value })}
                    style={{ fontFamily: 'ui-monospace, monospace' }} />
                </div>
                <div className="admin-field">
                  <label>Data (JSON)</label>
                  <textarea rows={10} value={form.data_json}
                    onChange={(e) => setForm({ ...form, data_json: e.target.value })}
                    placeholder='{"title":"...","items":[]}'
                    style={{ fontFamily: 'ui-monospace, monospace' }} />
                </div>
              </div>
              <div className="admin-modal__footer">
                <button type="button" className="btn-outline" onClick={close}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving}>
                  {saving ? 'Saving…' : modal.editing ? 'Save Changes' : 'Create Content'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}

// ─── Newsletter ───────────────────────────────────────────────────

function NewsletterTab() {
  const [subs, setSubs] = useState([]);
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [form, setForm] = useState({ subject: '', body_md: '' });

  const load = async () => {
    setLoading(true);
    try {
      const [s, c] = await Promise.all([
        fetchNewsletterSubscribers(),
        fetchNewsletterCampaigns(),
      ]);
      setSubs(s.results || s || []);
      setCampaigns(c.results || c || []);
    } catch {
      toast.error('Failed to load newsletter data');
    } finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const send = async (e) => {
    e.preventDefault();
    if (!form.subject.trim() || !form.body_md.trim()) {
      toast.error('Add subject and message.');
      return;
    }
    setSending(true);
    try {
      await createNewsletterCampaign({ subject: form.subject, body_md: form.body_md, status: 'queued' });
      toast.success('Campaign queued (sending will be enabled after email provider setup).');
      setForm({ subject: '', body_md: '' });
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to queue campaign.');
    } finally { setSending(false); }
  };

  const toggleSubscriber = async (s) => {
    try {
      await updateNewsletterSubscriber(s.id, { is_active: !s.is_active });
      await load();
    } catch {
      toast.error('Update failed.');
    }
  };

  return (
    <div className="admin-grid-2">
      <div className="admin-card">
        <div className="admin-card__header">
          <h3>Subscribers</h3>
          <span className="admin-meta-line">Total: {subs.length}</span>
        </div>
        <div className="admin-table-wrapper">
          {loading ? <p className="admin-empty">Loading…</p>
            : subs.length === 0 ? <p className="admin-empty">No subscribers yet.</p>
            : (
              <table className="admin-table admin-table--compact">
                <thead>
                  <tr><th>Email</th><th>Active</th><th></th></tr>
                </thead>
                <tbody>
                  {subs.map((s) => (
                    <tr key={s.id}>
                      <td>{s.email}</td>
                      <td>
                        <span className={`status-badge status-badge--${s.is_active ? 'confirmed' : 'cancelled'}`}>
                          {s.is_active ? 'Yes' : 'No'}
                        </span>
                      </td>
                      <td>
                        <button className="admin-icon-btn" onClick={() => toggleSubscriber(s)}>
                          {s.is_active ? 'Deactivate' : 'Activate'}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card__header">
          <h3>Broadcast</h3>
          <span className="admin-meta-line">Queued until email provider is connected.</span>
        </div>
        <form onSubmit={send}>
          <div className="admin-field">
            <label>Subject</label>
            <input value={form.subject}
                   onChange={(e) => setForm({ ...form, subject: e.target.value })}
                   placeholder="New arrivals this week" />
          </div>
          <div className="admin-field">
            <label>Message (Markdown)</label>
            <textarea rows={6} value={form.body_md}
                      onChange={(e) => setForm({ ...form, body_md: e.target.value })}
                      placeholder="Add your newsletter content..." />
          </div>
          <button type="submit" className="btn-primary" disabled={sending}>
            {sending ? 'Queueing…' : 'Queue Broadcast'}
          </button>
        </form>

        <div style={{ marginTop: 18 }}>
          <h4 style={{ margin: '0 0 8px' }}>Recent campaigns</h4>
          {loading ? <p className="admin-empty">Loading…</p>
            : campaigns.length === 0 ? <p className="admin-empty">No campaigns yet.</p>
            : (
              <table className="admin-table admin-table--compact">
                <thead>
                  <tr><th>Subject</th><th>Status</th><th>Created</th></tr>
                </thead>
                <tbody>
                  {campaigns.map((c) => (
                    <tr key={c.id}>
                      <td>{c.subject}</td>
                      <td>
                        <span className={`status-badge status-badge--${
                          c.status === 'sent'
                            ? 'confirmed'
                            : c.status === 'draft'
                              ? 'created'
                              : c.status === 'queued'
                                ? 'pending'
                                : 'failed'
                        }`}>
                          {c.status}
                        </span>
                      </td>
                      <td>{c.created_at?.slice(0, 16).replace('T', ' ')}</td>
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
