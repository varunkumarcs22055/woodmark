/**
 * DealerBulkUpload — drop-a-CSV bulk-order page.
 * Server collapses all valid rows into ONE order so freight is paid once.
 */
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { FiUploadCloud, FiCheckCircle, FiAlertCircle, FiDownload } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { dealerBulkUpload } from '../../api';

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
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!file) {
      setError('Choose a CSV file first.');
      return;
    }
    setLoading(true); setError(''); setResult(null);
    try {
      const fd = new FormData();
      fd.append('file', file);
      fd.append('payment_method', paymentMethod);
      if (poNumber) fd.append('po_number', poNumber);
      const res = await dealerBulkUpload(fd);
      setResult(res);
      if ((res.summary?.lines_accepted ?? 0) > 0) {
        toast.success(`Order ${res.order.order_id} created with ${res.summary.lines_accepted} line(s).`);
      }
    } catch (err) {
      const msg = err.response?.data?.error || 'Upload failed.';
      setError(msg);
      if (err.response?.data?.skipped) setResult({ skipped: err.response.data.skipped });
    } finally {
      setLoading(false);
    }
  };

  const downloadSample = () => {
    const blob = new Blob([SAMPLE], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = 'furnishop-bulk-template.csv';
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Bulk Order Upload</h1>
        <p>
          Upload a CSV with columns <code>sku,quantity</code> to place a single
          consolidated order. Out-of-stock or unknown SKUs are skipped — you'll
          see a per-row breakdown after upload.
        </p>
      </header>

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
          <h2>Step 2 — Upload</h2>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 16, maxWidth: 600 }}>
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

          {error && (
            <div className="auth-error-banner">
              <FiAlertCircle style={{ marginRight: 6, verticalAlign: 'middle' }} />
              {error}
            </div>
          )}

          <button type="submit" disabled={loading || !file} className="btn-primary"
                  style={{ alignSelf: 'flex-start' }}>
            {loading ? 'Uploading…' : 'Submit Bulk Order'}
          </button>
        </form>
      </section>

      {result && (
        <section className="dealer-overview__section" style={{ marginTop: 24 }}>
          <div className="dealer-overview__section-header"><h2>Result</h2></div>
          {result.order && (
            <div className="auth-error-banner" style={{ background: '#ECFDF5', color: '#065F46', borderColor: '#A7F3D0' }}>
              <FiCheckCircle style={{ marginRight: 6, verticalAlign: 'middle' }} />
              Order <strong>{result.order.order_id}</strong> created with {' '}
              <strong>{result.summary?.lines_accepted}</strong> line(s) for {' '}
              <strong>₹{result.order.total_amount}</strong>. {' '}
              <Link to={`/dealer-dashboard/orders/${result.order.order_id}`}>View →</Link>
            </div>
          )}
          {result.skipped?.length > 0 && (
            <>
              <h3 style={{ marginTop: 16 }}>Skipped rows ({result.skipped.length})</h3>
              <table className="admin-table admin-table--compact">
                <thead><tr><th>Line</th><th>SKU</th><th>Reason</th></tr></thead>
                <tbody>
                  {result.skipped.map((s, i) => (
                    <tr key={i}>
                      <td>{s.line || '—'}</td>
                      <td><code>{s.sku || '—'}</code></td>
                      <td>{s.reason}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </>
          )}
        </section>
      )}
    </div>
  );
}
