/**
 * AdminProducts — list + add/edit modal + delete.
 *
 * Backend endpoints (from Backend Prompt 5 — admin-only):
 *   GET    /api/products/admin/         (list with filters)
 *   POST   /api/products/admin/         (create)
 *   PUT    /api/products/admin/{id}/    (update)
 *   DELETE /api/products/admin/{id}/    (delete)
 *
 * Falls back to the public /api/products/ list if the admin endpoint
 * isn't implemented yet, so this page renders even before Backend Prompt 5.
 */
import { useEffect, useState, useMemo } from 'react';
import { FiPlus, FiEdit2, FiTrash2, FiX, FiSearch, FiAlertTriangle, FiUploadCloud, FiImage } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchProducts, fetchCategories, fetchProduct,
  adminCreateProduct, adminUpdateProduct, adminDeleteProduct, adminDeleteProductMedia,
  fetchTags,
} from '../../api';
import { formatPrice } from '../../utils/format';
import ConfirmModal from '../../components/ConfirmModal';

const MATERIALS = ['wood', 'metal', 'fabric', 'leather', 'glass', 'plastic', 'marble', 'rattan'];

const EMPTY_FORM = {
  // Basics
  name: '', brand: '', description: '', short_description: '',
  price: '', category: '', material: 'wood', color: '', dimensions: '',
  weight_grams: '', hsn_code: '',
  image_url: '', stock: 0, sku: '',
  is_featured: false, dealer_only: false, min_order_quantity: 1,
  delivery_estimate_days: 7,
  warranty_years: 1, return_policy_days: 7,
  installation_required: false, care_instructions: '',
  youtube_url: '',
  // Repeatable rich content
  highlights: [],          // string[]
  perks: [],               // [{icon,title,subtitle}]
  specifications: [],      // [{label,value}]
  feature_blocks: [],      // [{title,body,image_url,image_alignment}]
  tags: [],                // string[] — names; backend get-or-creates
};

const PRODUCT_TABS = [
  { key: 'basics',   label: 'Basics' },
  { key: 'pricing',  label: 'Pricing & Stock' },
  { key: 'media',    label: 'Media' },
  { key: 'highlights', label: 'Highlights' },
  { key: 'specs',    label: 'Specifications' },
  { key: 'features', label: 'Feature Blocks' },
  { key: 'keywords', label: 'Keywords' },
  { key: 'extras',   label: 'Video & Care' },
];

export default function AdminProducts() {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterCategory, setFilterCategory] = useState('');

  const [modal, setModal] = useState({ open: false, editing: null });
  const [form, setForm] = useState(EMPTY_FORM);
  const [activeTab, setActiveTab] = useState('basics');
  const [saving, setSaving] = useState(false);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [errors, setErrors] = useState({});
  // Files staged in the picker but not yet uploaded; cleared after save.
  const [mediaFiles, setMediaFiles] = useState([]);
  // Existing ProductMedia rows (with Cloudinary URLs) on the product being edited.
  const [existingMedia, setExistingMedia] = useState([]);

  // Custom confirmation state
  const [deleteConfirm, setDeleteConfirm] = useState({ open: false, product: null });

  const loadProducts = async () => {
    setLoading(true);
    try {
      const data = await fetchProducts({ page_size: 100 });
      setProducts(data.results || data || []);
    } catch {
      toast.error('Failed to load products');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProducts();
    fetchCategories().then((d) => setCategories(d.results || d || [])).catch(() => {});
  }, []);

  const filtered = useMemo(() => {
    return products.filter((p) => {
      if (filterCategory && p.category_name !== filterCategory) return false;
      if (search && !p.name.toLowerCase().includes(search.toLowerCase())) return false;
      return true;
    });
  }, [products, search, filterCategory]);

  const openAdd = () => {
    setModal({ open: true, editing: null });
    setForm({ ...EMPTY_FORM, category: categories[0]?.id || '' });
    setActiveTab('basics');
    setMediaFiles([]);
    setExistingMedia([]);
    setErrors({});
    setLoadingDetail(false);
  };

  const openEdit = async (product) => {
    setModal({ open: true, editing: product });
    // Seed with whatever the list row has — refine with product detail next.
    setForm({
      ...EMPTY_FORM,
      name: product.name,
      brand: product.brand || '',
      description: product.description || '',
      short_description: product.short_description || '',
      price: product.price,
      category: product.category?.id ?? product.category,
      material: product.material,
      color: product.color || '',
      dimensions: product.dimensions || '',
      weight_grams: product.weight_grams || '',
      hsn_code: product.hsn_code || '',
      image_url: product.image_url || '',
      stock: product.stock,
      is_featured: !!product.is_featured,
      dealer_only: !!product.dealer_only,
      min_order_quantity: product.min_order_quantity ?? 1,
      delivery_estimate_days: product.delivery_estimate_days ?? 7,
    });
    setActiveTab('basics');
    setMediaFiles([]);
    setExistingMedia([]);
    setErrors({});
    
    setLoadingDetail(true);
    try {
      const detail = await fetchProduct(product.slug);
      setExistingMedia(detail?.media || []);
      setForm((f) => ({
        ...f,
        description: detail?.description || '',
        short_description: detail?.short_description || '',
        weight_grams: detail?.weight_grams ?? '',
        hsn_code: detail?.hsn_code || '',
        dimensions: detail?.dimensions || '',
        color: detail?.color || '',
        brand: detail?.brand || '',
        highlights: Array.isArray(detail?.highlights) ? detail.highlights : [],
        perks: Array.isArray(detail?.perks) ? detail.perks : [],
        specifications: Array.isArray(detail?.specifications)
          ? detail.specifications.map((s) => ({ label: s.label, value: s.value }))
          : [],
        feature_blocks: Array.isArray(detail?.feature_blocks) ? detail.feature_blocks : [],
        tags: Array.isArray(detail?.tags) ? detail.tags.map((t) => t.name) : [],
        warranty_years: detail?.warranty_years ?? 1,
        return_policy_days: detail?.return_policy_days ?? 7,
        installation_required: !!detail?.installation_required,
        care_instructions: detail?.care_instructions || '',
        youtube_url: detail?.youtube_url || '',
        min_order_quantity: detail?.min_order_quantity ?? 1,
        delivery_estimate_days: detail?.delivery_estimate_days ?? 7,
      }));
    } catch (err) {
      console.error('Failed to fetch product detail:', err);
      toast.error('Could not load full product details. Some fields may be missing.');
    } finally {
      setLoadingDetail(false);
    }
  };

  const closeModal = () => {
    setModal({ open: false, editing: null });
    setMediaFiles([]);
    setExistingMedia([]);
  };

  const onPickFiles = (e) => {
    const incoming = Array.from(e.target.files || []);
    // Cap each upload at 8 files to avoid accidental drag-of-folder.
    const capped = incoming.slice(0, 8);
    setMediaFiles((prev) => [...prev, ...capped].slice(0, 8));
    e.target.value = '';
  };

  const removeStagedFile = (idx) => {
    setMediaFiles((prev) => prev.filter((_, i) => i !== idx));
  };

  const deleteExistingMedia = async (id) => {
    if (!window.confirm('Remove this image from the product?')) return;
    try {
      await adminDeleteProductMedia(id);
      setExistingMedia((prev) => prev.filter((m) => m.id !== id));
      toast.success('Image removed.');
    } catch {
      toast.error('Could not remove image.');
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    if (loadingDetail) {
      toast.error('Please wait for product details to load.');
      return;
    }

    // Frontend Validation
    const newErrors = {};
    if (!form.name?.trim()) newErrors.name = 'Name is required';
    if (!form.price || parseFloat(form.price) <= 0) newErrors.price = 'Valid price is required';
    if (!form.description.trim()) {
      newErrors.description = 'Description is required';
      setActiveTab('basics');
    }
    if (!form.hsn_code?.trim()) {
      newErrors.hsn_code = 'HSN Code is required';
      setActiveTab('basics');
    }
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error('Please fix the errors in the form.');
      return;
    }

    setSaving(true);
    setErrors({});
    try {
      const price = Number.parseFloat(form.price);
      const stock = Number.parseInt(form.stock, 10);
      if (!Number.isFinite(price) || price < 0) {
        setErrors({ price: 'Enter a valid non-negative price.' });
        setSaving(false);
        return;
      }
      if (!Number.isFinite(stock) || stock < 0) {
        setErrors({ stock: 'Enter a valid non-negative stock.' });
        setSaving(false);
        return;
      }
      const moq = Math.max(1, parseInt(form.min_order_quantity, 10) || 1);
      const cleanHighlights = (form.highlights || [])
        .map((h) => (typeof h === 'string' ? h : '').trim())
        .filter(Boolean);
      const cleanSpecs = (form.specifications || [])
        .map((s) => ({ label: (s.label || '').trim(), value: (s.value || '').trim() }))
        .filter((s) => s.label && s.value);
      const cleanPerks = (form.perks || [])
        .map((p) => ({
          icon: (p.icon || '').trim(),
          title: (p.title || '').trim(),
          subtitle: (p.subtitle || '').trim(),
        }))
        .filter((p) => p.title);
      const cleanTags = (form.tags || [])
        .map((t) => (typeof t === 'string' ? t : '').trim())
        .filter(Boolean);
      const cleanBlocks = (form.feature_blocks || [])
        .map((b, i) => ({
          title: (b.title || '').trim(),
          body: (b.body || '').trim(),
          image_url: (b.image_url || '').trim(),
          image_alignment: b.image_alignment || (i % 2 === 0 ? 'right' : 'left'),
          order: parseInt(b.order, 10) || i,
        }))
        .filter((b) => b.title || b.body);

      // When sending multipart (mediaFiles present), JSON values must be
      // serialized first so FormData sends them as strings — backend coerces
      // them back to JSON in ProductWriteSerializer.validate().
      const wantsMultipart = mediaFiles.length > 0;
      const json = (v) => (wantsMultipart ? JSON.stringify(v) : v);
      const payload = {
        name: form.name.trim(),
        brand: form.brand.trim(),
        description: form.description.trim(),
        short_description: form.short_description.trim(),
        category: form.category,
        material: form.material,
        color: form.color.trim(),
        dimensions: form.dimensions.trim(),
        weight_grams: form.weight_grams !== '' ? parseInt(form.weight_grams, 10) : 0,
        hsn_code: form.hsn_code.trim(),
        image_url: form.image_url.trim(),
        is_featured: !!form.is_featured,
        dealer_only: !!form.dealer_only,
        min_order_quantity: moq,
        delivery_estimate_days: parseInt(form.delivery_estimate_days, 10) || 7,
        warranty_years: parseInt(form.warranty_years, 10) || 1,
        return_policy_days: parseInt(form.return_policy_days, 10) || 7,
        installation_required: !!form.installation_required,
        care_instructions: form.care_instructions.trim(),
        youtube_url: form.youtube_url.trim(),
        highlights: json(cleanHighlights),
        perks: json(cleanPerks),
        feature_blocks: json(cleanBlocks),
        specifications: json(cleanSpecs),
        tags: json(cleanTags),
        price,
        stock,
      };
      if (modal.editing) {
        await adminUpdateProduct(modal.editing.id, payload, { mediaFiles });
        toast.success(mediaFiles.length
          ? `Product updated with ${mediaFiles.length} new image(s).`
          : 'Product updated.');
      } else {
        await adminCreateProduct(payload, { mediaFiles });
        toast.success(mediaFiles.length
          ? `Product created with ${mediaFiles.length} image(s) uploaded.`
          : 'Product created.');
      }
      closeModal();
      await loadProducts();
    } catch (err) {
      if (!err.response) {
        toast.error('Network error — backend unreachable.');
      } else if (err.response.status === 401 || err.response.status === 403) {
        toast.error('Not authorized. Re-login as admin.');
      } else {
        const data = err.response.data || {};
        setErrors(data);
        const firstMsg =
          data.detail ||
          data.non_field_errors?.[0] ||
          (typeof data === 'object' && Object.values(data).flat()[0]) ||
          'Save failed. Check the form.';
        toast.error(typeof firstMsg === 'string' ? firstMsg : 'Save failed. Check the form.');
      }
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = (product) => {
    setDeleteConfirm({ open: true, product });
  };

  const confirmDelete = async () => {
    const product = deleteConfirm.product;
    if (!product) return;
    setSaving(true);
    try {
      await adminDeleteProduct(product.id);
      toast.success('Product deleted.');
      setDeleteConfirm({ open: false, product: null });
      await loadProducts();
    } catch {
      toast.error('Cannot delete — product may have existing orders.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Products</h2>
        <button className="btn-primary" onClick={openAdd}>
          <FiPlus size={16} /> Add Product
        </button>
      </div>

      <div className="admin-toolbar">
        <div className="admin-toolbar__search">
          <FiSearch />
          <input
            type="search"
            placeholder="Search by name…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select value={filterCategory} onChange={(e) => setFilterCategory(e.target.value)}>
          <option value="">All categories</option>
          {categories.map((c) => (
            <option key={c.id} value={c.name}>{c.name}</option>
          ))}
        </select>
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : filtered.length === 0 ? (
          <p className="admin-empty">No products match your filters.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th style={{ width: 64 }}>Image</th>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th style={{ width: 110 }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((p) => (
                <tr key={p.id}>
                  <td>
                    <img src={p.image_url} alt="" className="admin-thumb" />
                  </td>
                  <td>
                    <strong>{p.name}</strong>
                    <span className="admin-meta-line">{p.material} · {p.color}</span>
                  </td>
                  <td>{p.category_name}</td>
                  <td>{formatPrice(p.price)}</td>
                  <td>
                    <span className={p.stock <= 5 ? 'admin-stock-warn' : ''}>
                      {p.stock <= 5 && <FiAlertTriangle size={12} />} {p.stock}
                    </span>
                  </td>
                  <td>
                    <button className="admin-icon-btn" onClick={() => openEdit(p)} aria-label="Edit">
                      <FiEdit2 size={14} />
                    </button>
                    <button 
                      className="admin-icon-btn admin-icon-btn--danger" 
                      onClick={(e) => {
                        e.stopPropagation();
                        handleDelete(p);
                      }} 
                      aria-label="Delete"
                    >
                      <FiTrash2 size={16} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Modal */}
      {modal.open && (
        <div className="admin-modal-overlay" onClick={closeModal}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
            <div className="admin-modal__header">
              <h3>{modal.editing ? 'Edit Product' : 'Add Product'}</h3>
              <button className="admin-modal__close" onClick={closeModal}>
                <FiX />
              </button>
            </div>
            <form onSubmit={handleSave}>
              {/* Tab strip */}
              <div style={{
                display: 'flex', gap: 4, padding: '0 20px',
                borderBottom: '1px solid #E5E7EB', overflowX: 'auto',
              }}>
                {PRODUCT_TABS.map((t) => (
                  <button
                    key={t.key}
                    type="button"
                    onClick={() => setActiveTab(t.key)}
                    style={{
                      padding: '10px 14px', border: 0, background: 'transparent',
                      cursor: 'pointer', fontSize: 13, fontWeight: 500,
                      color: activeTab === t.key ? '#0E766E' : '#6B7280',
                      borderBottom: activeTab === t.key ? '2px solid #0E766E' : '2px solid transparent',
                      whiteSpace: 'nowrap',
                    }}
                  >{t.label}</button>
                ))}
              </div>

              <div className="admin-modal__body">
                {activeTab === 'basics' && (
                  <BasicsTab form={form} setForm={setForm} categories={categories} errors={errors} />
                )}
                {activeTab === 'pricing' && (
                  <PricingTab form={form} setForm={setForm} errors={errors} />
                )}
                {activeTab === 'media' && (
                  <MediaTab
                    form={form} setForm={setForm} errors={errors}
                    mediaFiles={mediaFiles} existingMedia={existingMedia}
                    onPickFiles={onPickFiles} removeStagedFile={removeStagedFile}
                    deleteExistingMedia={deleteExistingMedia}
                  />
                )}
                {activeTab === 'highlights' && (
                  <HighlightsTab form={form} setForm={setForm} />
                )}
                {activeTab === 'specs' && (
                  <SpecsTab form={form} setForm={setForm} />
                )}
                {activeTab === 'features' && (
                  <FeatureBlocksTab form={form} setForm={setForm} />
                )}
                {activeTab === 'keywords' && (
                  <KeywordsTab form={form} setForm={setForm} />
                )}
                {activeTab === 'extras' && (
                  <ExtrasTab form={form} setForm={setForm} />
                )}
              </div>
              <div className="admin-modal__footer">
                <button type="button" className="btn-outline" onClick={closeModal}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saving || loadingDetail}>
                  {saving ? 'Saving…' : loadingDetail ? 'Loading Details…' : modal.editing ? 'Save Changes' : 'Create Product'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmModal
        open={deleteConfirm.open}
        title={`Delete "${deleteConfirm.product?.name}"?`}
        message="This will hide the product from the shop and admin panel. This action is irreversible for future orders."
        onConfirm={confirmDelete}
        onCancel={() => setDeleteConfirm({ open: false, product: null })}
        loading={saving}
      />
    </div>
  );
}

function Field({ label, error, children }) {
  return (
    <div className={`admin-field ${error ? 'admin-field--error' : ''}`}>
      <label>{label}</label>
      {children}
      {error && <span className="admin-field__error">{Array.isArray(error) ? error[0] : error}</span>}
    </div>
  );
}

// ─── Tab components ──────────────────────────────────────────────────

function BasicsTab({ form, setForm, categories, errors }) {
  return (
    <>
      <div className="admin-form-grid">
        <Field label="Name" error={errors.name}>
          <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
        </Field>
        <Field label="Brand" error={errors.brand}>
          <input value={form.brand} onChange={(e) => setForm({ ...form, brand: e.target.value })}
                 placeholder="e.g. Featherlite" />
        </Field>
        <Field label="Category" error={errors.category}>
          <select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} required>
            <option value="">Select…</option>
            {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </Field>
        <Field label="Material" error={errors.material}>
          <select value={form.material} onChange={(e) => setForm({ ...form, material: e.target.value })}>
            {MATERIALS.map((m) => <option key={m} value={m}>{m}</option>)}
          </select>
        </Field>
        <Field label="Colour" error={errors.color}>
          <input value={form.color} onChange={(e) => setForm({ ...form, color: e.target.value })}
                 placeholder="e.g. Walnut" />
        </Field>
        <Field label="Dimensions" error={errors.dimensions}>
          <input value={form.dimensions} onChange={(e) => setForm({ ...form, dimensions: e.target.value })}
                 placeholder="220x85x80 cm" />
        </Field>
        <Field label="Weight (g)" error={errors.weight_grams}>
          <input type="number" min="0" value={form.weight_grams}
                 onChange={(e) => setForm({ ...form, weight_grams: e.target.value })} />
        </Field>
        <Field label="HSN code (GST)" error={errors.hsn_code}>
          <input value={form.hsn_code} onChange={(e) => setForm({ ...form, hsn_code: e.target.value })}
                 placeholder="e.g. 9403" />
        </Field>
      </div>

      <Field label="Short description (one-liner above bullet points)" error={errors.short_description}>
        <input value={form.short_description}
               onChange={(e) => setForm({ ...form, short_description: e.target.value })}
               maxLength={240}
               placeholder="High-back mesh chair with dual-frame flexibility…" />
      </Field>
      <Field label="Description" error={errors.description}>
        <textarea rows={5} value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })} required />
      </Field>
    </>
  );
}

function PricingTab({ form, setForm, errors }) {
  return (
    <div className="admin-form-grid">
      <Field label="Price (₹)" error={errors.price}>
        <input type="number" min="0" step="0.01" value={form.price}
               onChange={(e) => setForm({ ...form, price: e.target.value })} required />
      </Field>
      <Field label="Stock" error={errors.stock}>
        <input type="number" min="0" value={form.stock}
               onChange={(e) => setForm({ ...form, stock: e.target.value })} required />
      </Field>
      <Field label="Min order qty (MOQ)" error={errors.min_order_quantity}>
        <input type="number" min="1" value={form.min_order_quantity}
               onChange={(e) => setForm({ ...form, min_order_quantity: e.target.value })} />
      </Field>
      <Field label="Default delivery (days)" error={errors.delivery_estimate_days}>
        <input type="number" min="1" value={form.delivery_estimate_days}
               onChange={(e) => setForm({ ...form, delivery_estimate_days: e.target.value })} />
      </Field>
      <Field label="Warranty (years)">
        <input type="number" min="0" value={form.warranty_years}
               onChange={(e) => setForm({ ...form, warranty_years: e.target.value })} />
      </Field>
      <Field label="Return window (days)">
        <input type="number" min="0" value={form.return_policy_days}
               onChange={(e) => setForm({ ...form, return_policy_days: e.target.value })} />
      </Field>
      <Field label="Featured?">
        <label className="admin-toggle">
          <input type="checkbox" checked={form.is_featured}
                 onChange={(e) => setForm({ ...form, is_featured: e.target.checked })} />
          <span>Show on homepage</span>
        </label>
      </Field>
      <Field label="Dealer-only?">
        <label className="admin-toggle">
          <input type="checkbox" checked={form.dealer_only}
                 onChange={(e) => setForm({ ...form, dealer_only: e.target.checked })} />
          <span>Hide from public storefront</span>
        </label>
      </Field>
      <Field label="Requires assembly?">
        <label className="admin-toggle">
          <input type="checkbox" checked={form.installation_required}
                 onChange={(e) => setForm({ ...form, installation_required: e.target.checked })} />
          <span>Show DIY notice on PDP</span>
        </label>
      </Field>
    </div>
  );
}

function MediaTab({ form, setForm, errors, mediaFiles, existingMedia, onPickFiles, removeStagedFile, deleteExistingMedia }) {
  return (
    <>
      <div className="admin-field">
        <label>Product images (Cloudinary)</label>
        <label
          style={{
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            gap: 8, padding: 18, border: '2px dashed #D1D5DB', borderRadius: 10,
            cursor: 'pointer', background: '#FAFAF7',
          }}
        >
          <FiUploadCloud size={22} style={{ color: '#6B7280' }} />
          <span>Click to select images (multi-select supported, up to 8)</span>
          <input type="file" multiple accept="image/*,video/*"
                 style={{ display: 'none' }} onChange={onPickFiles} />
        </label>
        <span className="admin-meta-line">
          Files upload to Cloudinary on save; URLs are stored on the product.
          The first image becomes the listing thumbnail.
        </span>

        {(mediaFiles.length > 0 || existingMedia.length > 0) && (
          <div style={{
            display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(110px, 1fr))',
            gap: 8, marginTop: 10,
          }}>
            {existingMedia.map((m) => (
              <div key={`ex-${m.id}`} style={{ position: 'relative' }}>
                {m.kind === 'video' ? (
                  <video src={m.url} style={tileStyle} muted onMouseOver={e => e.target.play()} onMouseOut={e => e.target.pause()} />
                ) : (
                  <img src={m.url} alt={m.alt_text || ''} style={tileStyle} />
                )}
                {m.is_primary && <span style={primaryBadgeStyle}>Primary</span>}
                <button type="button" onClick={() => deleteExistingMedia(m.id)}
                        style={tileDeleteBtnStyle} aria-label="Remove image">
                  <FiX size={12} />
                </button>
              </div>
            ))}
            {mediaFiles.map((f, idx) => {
              const url = URL.createObjectURL(f);
              const isVideo = f.type.startsWith('video');
              return (
                <div key={`new-${idx}`} style={{ position: 'relative' }}>
                  {isVideo ? (
                    <video src={url} style={tileStyle} muted />
                  ) : (
                    <img src={url} alt="" style={tileStyle} onLoad={() => URL.revokeObjectURL(url)} />
                  )}
                  <span style={stagedBadgeStyle}>New</span>
                  <button type="button" onClick={() => removeStagedFile(idx)}
                          style={tileDeleteBtnStyle} aria-label="Remove staged image">
                    <FiX size={12} />
                  </button>
                </div>
              );
            })}
          </div>
        )}
      </div>

      <Field label="Fallback image URL (used when no Cloudinary media uploaded)" error={errors.image_url}>
        <input value={form.image_url} onChange={(e) => setForm({ ...form, image_url: e.target.value })}
               placeholder="https://…" />
      </Field>
      {form.image_url && existingMedia.length === 0 && mediaFiles.length === 0 && (
        <img src={form.image_url} alt="" className="admin-image-preview" />
      )}
    </>
  );
}

function HighlightsTab({ form, setForm }) {
  const update = (next) => setForm({ ...form, highlights: next });
  return (
    <>
      <p className="admin-meta-line" style={{ marginBottom: 12 }}>
        Bullet points shown next to the product image (e.g. "Multilock Mechanism",
        "1-Year Warranty"). 4–8 items work best.
      </p>
      {(form.highlights || []).map((h, i) => (
        <div key={i} style={{ display: 'flex', gap: 6, marginBottom: 8 }}>
          <input value={h}
                 onChange={(e) => {
                   const next = [...form.highlights];
                   next[i] = e.target.value;
                   update(next);
                 }}
                 placeholder="Highlight bullet"
                 style={{ flex: 1, padding: '8px 10px', border: '1px solid #D1D5DB', borderRadius: 6 }} />
          <button type="button" onClick={() => update(form.highlights.filter((_, j) => j !== i))}
                  style={ghostBtnStyle}>Remove</button>
        </div>
      ))}
      <button type="button" onClick={() => update([...(form.highlights || []), ''])}
              className="btn-outline" style={{ marginTop: 4 }}>
        + Add highlight
      </button>
    </>
  );
}

function SpecsTab({ form, setForm }) {
  const update = (next) => setForm({ ...form, specifications: next });
  return (
    <>
      <p className="admin-meta-line" style={{ marginBottom: 12 }}>
        Spec table rows shown at the bottom of the PDP. Use any labels —
        e.g. "Seat Height", "Recline Tilt", "Frame Material", "Warranty".
      </p>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr>
            <th style={specHeadStyle}>Label</th>
            <th style={specHeadStyle}>Value</th>
            <th style={{ width: 80 }} />
          </tr>
        </thead>
        <tbody>
          {(form.specifications || []).map((s, i) => (
            <tr key={i}>
              <td style={{ padding: '4px 0' }}>
                <input value={s.label}
                       onChange={(e) => {
                         const next = [...form.specifications];
                         next[i] = { ...next[i], label: e.target.value };
                         update(next);
                       }}
                       placeholder="e.g. Seat Width"
                       style={specInputStyle} />
              </td>
              <td style={{ padding: '4px 4px' }}>
                <input value={s.value}
                       onChange={(e) => {
                         const next = [...form.specifications];
                         next[i] = { ...next[i], value: e.target.value };
                         update(next);
                       }}
                       placeholder="e.g. 510mm"
                       style={specInputStyle} />
              </td>
              <td style={{ padding: '4px 0' }}>
                <button type="button" onClick={() => update(form.specifications.filter((_, j) => j !== i))}
                        style={ghostBtnStyle}>Remove</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <button type="button"
              onClick={() => update([...(form.specifications || []), { label: '', value: '' }])}
              className="btn-outline" style={{ marginTop: 8 }}>
        + Add spec row
      </button>
    </>
  );
}

function FeatureBlocksTab({ form, setForm }) {
  const update = (next) => setForm({ ...form, feature_blocks: next });
  return (
    <>
      <p className="admin-meta-line" style={{ marginBottom: 12 }}>
        "Designed to Respond"-style banner blocks. Each row is one full-width
        marketing block with a background image and a title + body.
      </p>
      {(form.feature_blocks || []).map((b, i) => (
        <div key={i} style={{
          border: '1px solid #E5E7EB', borderRadius: 10, padding: 12, marginBottom: 12,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <strong>Block {i + 1}</strong>
            <button type="button" onClick={() => update(form.feature_blocks.filter((_, j) => j !== i))}
                    style={ghostBtnStyle}>Remove</button>
          </div>
          <div className="admin-form-grid">
            <Field label="Title">
              <input value={b.title || ''}
                     onChange={(e) => {
                       const next = [...form.feature_blocks];
                       next[i] = { ...next[i], title: e.target.value };
                       update(next);
                     }}
                     placeholder="e.g. Dynaflex Back Support" />
            </Field>
            <Field label="Image alignment">
              <select value={b.image_alignment || 'right'}
                      onChange={(e) => {
                        const next = [...form.feature_blocks];
                        next[i] = { ...next[i], image_alignment: e.target.value };
                        update(next);
                      }}>
                <option value="right">Image left, text right</option>
                <option value="left">Image right, text left</option>
                <option value="full">Centered (no float)</option>
              </select>
            </Field>
          </div>
          <Field label="Body copy">
            <textarea rows={3} value={b.body || ''}
                      onChange={(e) => {
                        const next = [...form.feature_blocks];
                        next[i] = { ...next[i], body: e.target.value };
                        update(next);
                      }} />
          </Field>
          <Field label="Background image URL">
            <input value={b.image_url || ''}
                   onChange={(e) => {
                     const next = [...form.feature_blocks];
                     next[i] = { ...next[i], image_url: e.target.value };
                     update(next);
                   }}
                   placeholder="https://… (paste a Cloudinary or CDN URL)" />
          </Field>
          {b.image_url && (
            <img src={b.image_url} alt="" style={{
              width: '100%', maxHeight: 140, objectFit: 'cover',
              borderRadius: 6, border: '1px solid #E5E7EB',
            }} />
          )}
        </div>
      ))}
      <button type="button"
              onClick={() => update([...(form.feature_blocks || []),
                { title: '', body: '', image_url: '', image_alignment: 'right' }])}
              className="btn-outline">
        + Add feature block
      </button>
    </>
  );
}

function KeywordsTab({ form, setForm }) {
  const [allTags, setAllTags] = useState([]);
  const [input, setInput] = useState('');

  useEffect(() => {
    fetchTags().then((t) => setAllTags(Array.isArray(t) ? t : t?.results || []))
      .catch(() => setAllTags([]));
  }, []);

  const selected = form.tags || [];
  const norm = (s) => (s || '').trim().toLowerCase();
  const isSelected = (name) => selected.some((t) => norm(t) === norm(name));

  const addTag = (name) => {
    const trimmed = (name || '').trim();
    if (!trimmed) return;
    if (isSelected(trimmed)) return;
    setForm({ ...form, tags: [...selected, trimmed] });
    setInput('');
  };

  const removeTag = (name) => {
    setForm({ ...form, tags: selected.filter((t) => norm(t) !== norm(name)) });
  };

  const onKeyDown = (e) => {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault();
      addTag(input);
    } else if (e.key === 'Backspace' && !input && selected.length) {
      removeTag(selected[selected.length - 1]);
    }
  };

  const suggestions = (input.length > 0
    ? allTags.filter((t) =>
        t.name.toLowerCase().includes(input.toLowerCase()) && !isSelected(t.name))
    : allTags.filter((t) => !isSelected(t.name))
  ).slice(0, 12);

  return (
    <>
      <p className="admin-meta-line" style={{ marginBottom: 12 }}>
        Keywords link this product to navbar entries and the "You may also like"
        carousel. Type a word and press <kbd>Enter</kbd> or <kbd>,</kbd> to add.
        New keywords are created automatically on save.
      </p>

      {/* Selected chips + input */}
      <div style={{
        display: 'flex', flexWrap: 'wrap', gap: 6, padding: 8,
        border: '1px solid #D1D5DB', borderRadius: 8, background: '#fff',
        minHeight: 44, marginBottom: 10,
      }}>
        {selected.map((t) => (
          <span key={t} style={chipStyle}>
            {t}
            <button type="button" onClick={() => removeTag(t)}
                    style={chipCloseStyle} aria-label={`Remove ${t}`}>
              <FiX size={12} />
            </button>
          </span>
        ))}
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={onKeyDown}
          placeholder={selected.length ? '' : 'office, executive, ergonomic…'}
          style={{ flex: 1, minWidth: 140, border: 0, outline: 'none', fontSize: 14 }}
        />
      </div>

      {/* Suggestions row */}
      {suggestions.length > 0 && (
        <>
          <span className="admin-meta-line">
            {input ? `Matches for "${input}"` : 'Existing keywords'} — click to add
          </span>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 6 }}>
            {suggestions.map((t) => (
              <button
                key={t.id}
                type="button"
                onClick={() => addTag(t.name)}
                style={suggestionChipStyle}
                title={t.is_navigation ? 'In navbar' : ''}
              >
                {t.is_navigation ? '★ ' : ''}{t.name}
                {typeof t.product_count === 'number' && (
                  <small style={{ color: '#6B7280', marginLeft: 4 }}>
                    ({t.product_count})
                  </small>
                )}
              </button>
            ))}
          </div>
        </>
      )}

      <p className="admin-meta-line" style={{ marginTop: 14 }}>
        Tip: To make a keyword appear in the navbar, open it in the global
        Tags page (admin) and toggle "Show in navbar". Star (★) indicates
        keywords already surfaced in the storefront menu.
      </p>
    </>
  );
}

function ExtrasTab({ form, setForm }) {
  return (
    <>
      <Field label="YouTube video URL (assembly / marketing)">
        <input value={form.youtube_url}
               onChange={(e) => setForm({ ...form, youtube_url: e.target.value })}
               placeholder="https://www.youtube.com/watch?v=…" />
      </Field>
      {form.youtube_url && (
        <span className="admin-meta-line">
          Backend converts watch / shorts / youtu.be links to a clean embed URL.
        </span>
      )}
      <Field label="Care instructions (cleaning, maintenance)">
        <textarea rows={4} value={form.care_instructions}
                  onChange={(e) => setForm({ ...form, care_instructions: e.target.value })}
                  placeholder="Wipe with a damp cloth; avoid direct sunlight…" />
      </Field>
    </>
  );
}

const chipStyle = {
  display: 'inline-flex', alignItems: 'center', gap: 4,
  padding: '4px 8px', borderRadius: 14,
  background: '#0E766E', color: '#fff', fontSize: 12, fontWeight: 500,
};
const chipCloseStyle = {
  border: 0, background: 'transparent', color: '#fff',
  cursor: 'pointer', display: 'inline-flex', alignItems: 'center',
  padding: 0, marginLeft: 2,
};
const suggestionChipStyle = {
  padding: '4px 10px', borderRadius: 14,
  border: '1px solid #D1D5DB', background: '#fff',
  cursor: 'pointer', fontSize: 12, color: '#374151',
};
const ghostBtnStyle = {
  padding: '6px 10px', border: '1px solid #D1D5DB',
  borderRadius: 6, background: '#fff', cursor: 'pointer', fontSize: 12,
};
const specHeadStyle = {
  textAlign: 'left', padding: '4px 0',
  fontSize: 12, color: '#6B7280', fontWeight: 500,
};
const specInputStyle = {
  width: '100%', padding: '6px 8px',
  border: '1px solid #D1D5DB', borderRadius: 6, fontSize: 13,
};

const tileStyle = {
  width: '100%', aspectRatio: '1 / 1', objectFit: 'cover',
  borderRadius: 8, border: '1px solid #E5E7EB', background: '#F3F4F6',
};
const tileDeleteBtnStyle = {
  position: 'absolute', top: 4, right: 4, width: 22, height: 22,
  borderRadius: '50%', border: 0, background: 'rgba(17,24,39,0.78)',
  color: '#fff', cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
};
const primaryBadgeStyle = {
  position: 'absolute', bottom: 4, left: 4,
  background: '#16A34A', color: '#fff', fontSize: 10,
  padding: '2px 6px', borderRadius: 8,
};
const stagedBadgeStyle = {
  ...primaryBadgeStyle, background: '#0EA5E9',
};
