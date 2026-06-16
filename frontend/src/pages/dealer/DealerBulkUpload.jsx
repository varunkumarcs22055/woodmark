/**
 * DealerBulkUpload — drop-a-CSV bulk-order page.
 *
 * Two-step flow:
 *   1) Upload CSV → POST with dry_run=true → see a preview with prices and
 *      stock status. Backorders for active dealers are clearly flagged so
 *      they know which lines won't ship immediately.
 *   2) Click "Confirm & Place Order" → same form posted with dry_run=false
 *      → backend creates the consolidated order and we redirect.
 *
 * The address defaults to the dealer's profile shipping address (backend
 * pulls UserAddress); they can override it inline if they want this order
 * shipped elsewhere.
 */
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  FiUploadCloud, FiCheckCircle, FiAlertCircle, FiDownload,
  FiClock, FiArrowLeft,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import { dealerBulkUpload } from '../../api';
import { formatPrice } from '../../utils/format';

const SAMPLE = `sku,quantity
BED-29CC80,2
SOF-1A2B3C,5
TBL-XYZ123,1
`;

export default function DealerBulkUpload() {
  const navigate = useNavigate();
  const [file, setFile] = useState(null);
  const [paymentMethod, setPaymentMethod] = useState('razorpay');
  const [poNumber, setPoNumber] = useState('');
  const [address, setAddress] = useState('');
  const [dealerNote, setDealerNote] = useState('');
  const [loading, setLoading] = useState(false);
  const [preview, setPreview] = useState(null);   // { lines, subtotal, address, ... }
  const [result, setResult] = useState(null);     // { order, summary, skipped }
  const [error, setError] = useState('');

  const buildFormData = (dryRun) => {
    const fd = new FormData();
    fd.append('file', file);
    fd.append('payment_method', paymentMethod);
    fd.append('dry_run', dryRun ? 'true' : 'false');
    if (poNumber) fd.append('po_number', poNumber);
    if (address.trim()) fd.append('address', address.trim());
    if (dealerNote.trim()) fd.append('dealer_note', dealerNote.trim());
    return fd;
  };

  const handlePreview = async (e) => {
    e.preventDefault();
    if (!file) {
      setError('Choose a CSV file first.');
      return;
    }
    setLoading(true); setError(''); setResult(null); setPreview(null);
    try {
      const res = await dealerBulkUpload(buildFormData(true));
      setPreview(res);
      if (res.summary?.lines_accepted === 0) {
        toast.error('No valid lines in the CSV. See skipped list below.');
      }
    } catch (err) {
      const data = err.response?.data || {};
      setError(data.error || 'Preview failed.');
      if (data.skipped) setPreview({ skipped: data.skipped });
    } finally {
      setLoading(false);
    }
  };

  const handleConfirm = async () => {
    setLoading(true); setError('');
    try {
      const res = await dealerBulkUpload(buildFormData(false));
      setResult(res);
      setPreview(null);
      if ((res.summary?.lines_accepted ?? 0) > 0) {
        toast.success(
          `Order ${res.order.order_id} created with ${res.summary.lines_accepted} line(s).`,
          { duration: 6000 },
        );
      }
    } catch (err) {
      const data = err.response?.data || {};
      const detail = data.detail
        ? Object.values(data.detail).flat().join(', ')
        : '';
      setError([data.error, detail].filter(Boolean).join(' — ') || 'Order placement failed.');
    } finally {
      setLoading(false);
    }
  };

  const resetAll = () => {
    setPreview(null);
    setResult(null);
    setError('');
  };

  const downloadSample = () => {
    const blob = new Blob([SAMPLE], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = 'woodmark-bulk-template.csv';
    a.click();
    URL.revokeObjectURL(url);
  };

  // ── Final-result screen ───────────────────────────────────────────
  if (result?.order) {
    return (
      <div className="dealer-overview">
        <header className="dealer-overview__header">
          <h1>Order Placed</h1>
        </header>
        <div className="auth-error-banner" style={{ background: '#ECFDF5', color: '#065F46', borderColor: '#A7F3D0', padding: 16 }}>
          <FiCheckCircle style={{ marginRight: 8, verticalAlign: 'middle' }} />
          Order <strong>{result.order.order_id}</strong> created with{' '}
          <strong>{result.summary?.lines_accepted}</strong> line(s) totalling{' '}
          <strong>{formatPrice(result.order.total_amount)}</strong>.{' '}
          <Link to={`/dealer-dashboard/orders/${result.order.order_id}`} style={{ color: '#065F46', fontWeight: 600 }}>
            View order →
          </Link>
        </div>
        {result.skipped?.length > 0 && (
          <section className="dealer-overview__section" style={{ marginTop: 16 }}>
            <div className="dealer-overview__section-header">
              <h2>Skipped rows ({result.skipped.length})</h2>
            </div>
            <SkippedTable rows={result.skipped} />
          </section>
        )}
        <div style={{ marginTop: 20 }}>
          <button className="btn-outline" onClick={() => {
            setFile(null); setResult(null); setPreview(null);
          }}>
            Upload another CSV
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Bulk Order Upload</h1>
        <p>
          Upload a CSV with columns <code>sku,quantity</code> to place a single
          consolidated order. You'll review the preview before anything is
          charged or committed.
        </p>
      </header>

      {/* ── Preview step ──────────────────────────────────────────── */}
      {preview && preview.lines ? (
        <>
          <section className="dealer-overview__section">
            <div className="dealer-overview__section-header" style={{ display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', gap: 8 }}>
              <h2>Preview — please confirm</h2>
              <button type="button" className="btn-outline" onClick={resetAll}
                      style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                <FiArrowLeft size={14} /> Edit upload
              </button>
            </div>
            <p className="admin-meta-line">
              Ship to: <strong>{preview.address}</strong> · Payment:{' '}
              <strong>{preview.payment_method.toUpperCase()}</strong>
            </p>

            <table className="admin-table admin-table--compact" style={{ marginTop: 12 }}>
              <thead>
                <tr>
                  <th>SKU</th><th>Product</th><th>Qty</th>
                  <th>Unit price</th><th>Line total</th><th>Status</th>
                </tr>
              </thead>
              <tbody>
                {preview.lines.map((l) => (
                  <tr key={l.product_id}>
                    <td><code>{l.sku}</code></td>
                    <td>{l.product_name}</td>
                    <td>{l.quantity}</td>
                    <td>{formatPrice(l.unit_price)}</td>
                    <td><strong>{formatPrice(l.line_total)}</strong></td>
                    <td>
                      {l.backorder_qty > 0 ? (
                        <span style={{ color: '#92400E', display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                          <FiClock size={12} /> {l.backorder_qty} on backorder
                        </span>
                      ) : (
                        <span style={{ color: '#065F46' }}>
                          <FiCheckCircle size={12} /> In stock
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            <p style={{ marginTop: 16, fontSize: 15 }}>
              Subtotal (before GST & shipping):{' '}
              <strong>{formatPrice(preview.subtotal)}</strong>
            </p>
            <p className="admin-meta-line">{preview.note}</p>

            {error && (
              <div className="auth-error-banner" style={{ marginTop: 12 }}>
                <FiAlertCircle style={{ marginRight: 6, verticalAlign: 'middle' }} />
                {error}
              </div>
            )}

            <div style={{ display: 'flex', gap: 10, marginTop: 16, flexWrap: 'wrap' }}>
              <button type="button" className="btn-primary"
                      onClick={handleConfirm} disabled={loading}>
                {loading ? 'Placing order…' : 'Confirm & Place Order'}
              </button>
              <button type="button" className="btn-outline" onClick={resetAll} disabled={loading}>
                Cancel
              </button>
            </div>
          </section>

          {preview.skipped?.length > 0 && (
            <section className="dealer-overview__section" style={{ marginTop: 16 }}>
              <div className="dealer-overview__section-header">
                <h2>Skipped rows ({preview.skipped.length})</h2>
              </div>
              <SkippedTable rows={preview.skipped} />
            </section>
          )}
        </>
      ) : (
        // ── Upload step ─────────────────────────────────────────────
        <>
          <section className="dealer-overview__section" style={{ marginBottom: 24 }}>
            <div className="dealer-overview__section-header">
              <h2>Step 1 — Get the template</h2>
            </div>
            <p>
              <button type="button" onClick={downloadSample}
                      style={{ display: 'inline-flex', alignItems: 'center', gap: 6,
                               padding: '8px 12px', borderRadius: 6, border: '1px solid #D1D5DB',
                               background: '#F9FAFB', cursor: 'pointer' }}>
                <FiDownload /> Download CSV template
              </button>
            </p>
          </section>

          <section className="dealer-overview__section">
            <div className="dealer-overview__section-header">
              <h2>Step 2 — Upload & preview</h2>
            </div>

            <form onSubmit={handlePreview} style={{ display: 'flex', flexDirection: 'column', gap: 16, maxWidth: 720 }}>
              <label style={{ display: 'block', padding: 24, border: '2px dashed #D1D5DB', borderRadius: 12, textAlign: 'center', cursor: 'pointer' }}>
                <FiUploadCloud size={32} style={{ marginBottom: 8, color: '#6B7280' }} />
                <div>
                  {file ? (
                    <strong>{file.name}</strong>
                  ) : (
                    <span>Drag a CSV here, or click to choose</span>
                  )}
                </div>
                <input
                  type="file" accept=".csv,text/csv"
                  onChange={(e) => setFile(e.target.files?.[0] || null)}
                  style={{ display: 'none' }}
                />
              </label>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                <label>
                  <span style={{ display: 'block', fontSize: 13, marginBottom: 4 }}>Payment method</span>
                  <select value={paymentMethod} onChange={(e) => setPaymentMethod(e.target.value)}
                          style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #D1D5DB' }}>
                    <option value="razorpay">Razorpay (online)</option>
                    <option value="cod">Cash on Delivery</option>
                    <option value="credit">On Credit (uses credit limit)</option>
                    <option value="wallet">Wallet</option>
                  </select>
                </label>
                <label>
                  <span style={{ display: 'block', fontSize: 13, marginBottom: 4 }}>PO number (optional)</span>
                  <input value={poNumber} onChange={(e) => setPoNumber(e.target.value)}
                         placeholder="PO-2026-001"
                         style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #D1D5DB' }} />
                </label>
              </div>

              <label>
                <span style={{ display: 'block', fontSize: 13, marginBottom: 4 }}>
                  Shipping address (leave blank to use your default from profile)
                </span>
                <textarea
                  rows={3}
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  placeholder="e.g. Warehouse 3, MIDC Phase 2, Pune 411019"
                  style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #D1D5DB', fontFamily: 'inherit' }}
                />
              </label>

              <label>
                <span style={{ display: 'block', fontSize: 13, marginBottom: 4 }}>Order note (optional)</span>
                <input
                  value={dealerNote} onChange={(e) => setDealerNote(e.target.value)}
                  placeholder="Internal reference or special instructions"
                  style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #D1D5DB' }}
                />
              </label>

              {error && (
                <div className="auth-error-banner">
                  <FiAlertCircle style={{ marginRight: 6, verticalAlign: 'middle' }} />
                  {error}
                </div>
              )}

              <button type="submit" disabled={loading || !file} className="btn-primary"
                      style={{ alignSelf: 'flex-start' }}>
                {loading ? 'Previewing…' : 'Preview Order'}
              </button>
            </form>
          </section>

          {/* Skipped rows from a failed preview also shown here */}
          {preview?.skipped?.length > 0 && (
            <section className="dealer-overview__section" style={{ marginTop: 16 }}>
              <div className="dealer-overview__section-header">
                <h2>Skipped rows ({preview.skipped.length})</h2>
              </div>
              <SkippedTable rows={preview.skipped} />
            </section>
          )}
        </>
      )}
    </div>
  );
}

function SkippedTable({ rows }) {
  return (
    <table className="admin-table admin-table--compact">
      <thead><tr><th>Line</th><th>SKU</th><th>Reason</th></tr></thead>
      <tbody>
        {rows.map((s, i) => (
          <tr key={i}>
            <td>{s.line || '—'}</td>
            <td><code>{s.sku || '—'}</code></td>
            <td>{s.reason}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
