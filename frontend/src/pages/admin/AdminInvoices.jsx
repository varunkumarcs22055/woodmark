/**
 * AdminInvoices — list + filter + view PDF + email + regenerate.
 *
 * Endpoints:
 *   GET  /api/invoices/?search=&payment_status=&from=&to=
 *   GET  /api/invoices/{id}/pdf/?download=1
 *   POST /api/invoices/{id}/email/
 *   POST /api/invoices/regenerate/{order_pk}/
 */
import { useEffect, useMemo, useState } from 'react';
import { FiSearch, FiDownload, FiMail, FiRefreshCw, FiEye } from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchInvoices, fetchInvoicePDFBlob, emailInvoice, regenerateInvoice,
} from '../../api';
import { formatPrice, formatDate } from '../../utils/format';

const STATUSES = ['', 'PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'];

export default function AdminInvoices() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [working, setWorking] = useState(null); // id currently being acted on

  const load = async () => {
    setLoading(true);
    try {
      const params = {};
      if (search) params.search = search;
      if (status) params.payment_status = status;
      if (from) params.from = from;
      if (to) params.to = to;
      const data = await fetchInvoices(params);
      setRows(Array.isArray(data) ? data : Array.isArray(data?.results) ? data.results : []);
    } catch {
      toast.error('Failed to load invoices');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const t = setTimeout(load, 300);
    return () => clearTimeout(t);
    // eslint-disable-next-line
  }, [search, status, from, to]);

  const totals = useMemo(() => ({
    count: rows.length,
    revenue: rows
      .filter((r) => r.payment_status === 'SUCCESS')
      .reduce((s, r) => s + parseFloat(r.grand_total || 0), 0),
  }), [rows]);

  const openPDF = async (invoice) => {
    setWorking(invoice.id);
    try {
      const blob = await fetchInvoicePDFBlob(invoice.id);
      const url = URL.createObjectURL(blob);
      window.open(url, '_blank', 'noopener,noreferrer');
      // Revoke after a short delay so the new tab has time to read it.
      setTimeout(() => URL.revokeObjectURL(url), 60_000);
    } catch {
      toast.error('Failed to open PDF');
    } finally {
      setWorking(null);
    }
  };

  const downloadPDF = async (invoice) => {
    setWorking(invoice.id);
    try {
      const blob = await fetchInvoicePDFBlob(invoice.id, { download: true });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${invoice.invoice_number}.pdf`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch {
      toast.error('Download failed');
    } finally {
      setWorking(null);
    }
  };

  const emailIt = async (invoice) => {
    const recipient = window.prompt(
      `Email invoice ${invoice.invoice_number} to:`,
      invoice.customer_email || ''
    );
    if (!recipient) return;
    setWorking(invoice.id);
    try {
      const r = await emailInvoice(invoice.id, recipient);
      toast.success(`Sent to ${r.emailed_to}`);
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Email failed');
    } finally {
      setWorking(null);
    }
  };

  const regenerate = async (invoice) => {
    if (!window.confirm(
      `Regenerate ${invoice.invoice_number}? The current invoice is deleted and rebuilt from the order.`
    )) return;
    setWorking(invoice.id);
    try {
      await regenerateInvoice(invoice.order);
      toast.success('Regenerated.');
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Regenerate failed');
    } finally {
      setWorking(null);
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title">Invoices</h2>
        <span className="admin-meta-line">
          {totals.count} invoices · {formatPrice(totals.revenue)} captured
        </span>
      </div>

      <div className="admin-toolbar">
        <div className="admin-toolbar__search">
          <FiSearch />
          <input
            type="search"
            placeholder="Search by invoice #, order ID, customer name…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select value={status} onChange={(e) => setStatus(e.target.value)}>
          {STATUSES.map((s) => (
            <option key={s} value={s}>{s || 'All statuses'}</option>
          ))}
        </select>
        <input
          type="date" value={from} onChange={(e) => setFrom(e.target.value)}
          aria-label="From date"
        />
        <input
          type="date" value={to} onChange={(e) => setTo(e.target.value)}
          aria-label="To date"
        />
      </div>

      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : rows.length === 0 ? (
          <p className="admin-empty">No invoices match.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Invoice #</th>
                <th>Order</th>
                <th>Customer</th>
                <th>Total</th>
                <th>GST split</th>
                <th>Status</th>
                <th>Date</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((inv) => (
                <tr key={inv.id}>
                  <td><strong>{inv.invoice_number}</strong></td>
                  <td><code>{inv.order_id_human}</code></td>
                  <td>
                    {inv.billing_name}
                    <span className="admin-meta-line">{inv.customer_email}</span>
                  </td>
                  <td>{formatPrice(inv.grand_total)}</td>
                  <td>
                    <span className="admin-meta-line">
                      {parseFloat(inv.igst_total) > 0
                        ? `IGST ${formatPrice(inv.igst_total)}`
                        : `CGST ${formatPrice(inv.cgst_total)} · SGST ${formatPrice(inv.sgst_total)}`}
                    </span>
                  </td>
                  <td>
                    <span className={`status-badge status-badge--${inv.payment_status === 'SUCCESS' ? 'confirmed' : inv.payment_status === 'FAILED' ? 'cancelled' : 'created'}`}>
                      {inv.payment_status}
                    </span>
                  </td>
                  <td>{formatDate(inv.invoice_date)}</td>
                  <td>
                    <button className="admin-icon-btn" onClick={() => openPDF(inv)}
                      disabled={working === inv.id} aria-label="View PDF">
                      <FiEye size={14} />
                    </button>
                    <button className="admin-icon-btn" onClick={() => downloadPDF(inv)}
                      disabled={working === inv.id} aria-label="Download PDF">
                      <FiDownload size={14} />
                    </button>
                    <button className="admin-icon-btn" onClick={() => emailIt(inv)}
                      disabled={working === inv.id} aria-label="Email invoice">
                      <FiMail size={14} />
                    </button>
                    <button className="admin-icon-btn" onClick={() => regenerate(inv)}
                      disabled={working === inv.id} aria-label="Regenerate">
                      <FiRefreshCw size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
