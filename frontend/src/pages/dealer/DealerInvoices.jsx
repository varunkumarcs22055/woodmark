/**
 * DealerInvoices — paginated list of the signed-in dealer's invoices.
 *
 * Backend: GET /api/dealer/invoices/?status=open|paid&page=N
 *   Page size = 12. Open invoices appear first (DRF orders by -created_at).
 *
 * Clicks → open the PDF in a new tab (same `fetchInvoicePDFBlob` helper
 * used in OrderDetailPage), or download it directly.
 */
import { useEffect, useMemo, useState } from 'react';
import {
  FiFileText, FiDownload, FiExternalLink, FiSearch, FiAlertCircle,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchDealerInvoices, fetchInvoicePDFBlob } from '../../api';
import { formatPrice, formatDate } from '../../utils/format';
import Pagination from '../../components/Pagination';

const PAGE_SIZE = 12;
const STATUS_FILTERS = [
  { key: 'ALL',  label: 'All' },
  { key: 'open', label: 'Outstanding' },
  { key: 'paid', label: 'Paid' },
];

export default function DealerInvoices() {
  const [rows, setRows] = useState([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState('ALL');
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState(null);

  const load = async () => {
    setLoading(true);
    try {
      const params = { page, page_size: PAGE_SIZE };
      if (filter !== 'ALL') params.status = filter;
      const data = await fetchDealerInvoices(params);
      const list = Array.isArray(data) ? data
        : Array.isArray(data?.results) ? data.results : [];
      setRows(list);
      setCount(typeof data?.count === 'number' ? data.count : list.length);
    } catch {
      setRows([]);
      setCount(0);
      toast.error('Failed to load invoices.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); /* eslint-disable-next-line */ }, [page, filter]);
  // Reset to page 1 when the filter changes
  useEffect(() => { if (page !== 1) setPage(1); /* eslint-disable-next-line */ }, [filter]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return rows;
    return rows.filter((r) =>
      (r.invoice_number || '').toLowerCase().includes(q)
      || (r.order_id_human || '').toLowerCase().includes(q)
    );
  }, [rows, search]);

  const openPDF = async (inv, download = false) => {
    setBusyId(inv.id);
    try {
      const blob = await fetchInvoicePDFBlob(inv.id, { download });
      const url = URL.createObjectURL(blob);
      if (download) {
        const a = document.createElement('a');
        a.href = url;
        a.download = `${inv.invoice_number}.pdf`;
        a.click();
      } else {
        window.open(url, '_blank', 'noopener,noreferrer');
      }
      setTimeout(() => URL.revokeObjectURL(url), 30_000);
    } catch {
      toast.error('Could not load PDF.');
    } finally {
      setBusyId(null);
    }
  };

  const totals = useMemo(() => ({
    outstanding: rows.filter((r) => parseFloat(r.amount_due || 0) > 0)
      .reduce((s, r) => s + parseFloat(r.amount_due || 0), 0),
    paidCount: rows.filter((r) => parseFloat(r.amount_due || 0) === 0).length,
  }), [rows]);

  return (
    <div className="dealer-overview">
      <header className="dealer-overview__header">
        <h1>Invoices</h1>
        <p>
          Tax invoices for every paid order plus open credit invoices.
          Outstanding: <strong>{formatPrice(totals.outstanding)}</strong> · Paid: <strong>{totals.paidCount}</strong>
        </p>
      </header>

      <section className="dealer-overview__section">
        <div className="dealer-overview__section-header" style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          flexWrap: 'wrap', gap: 12,
        }}>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {STATUS_FILTERS.map((f) => (
              <button
                key={f.key}
                onClick={() => setFilter(f.key)}
                className={`dealer-orders__chip ${filter === f.key ? 'dealer-orders__chip--active' : ''}`}
              >
                {f.label}
              </button>
            ))}
          </div>
          <div className="dealer-orders__search" style={{ minWidth: 220 }}>
            <FiSearch />
            <input
              type="search"
              placeholder="Search invoice # or order ID…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>

        {loading ? (
          <div className="dealer-overview__empty">Loading invoices…</div>
        ) : filtered.length === 0 ? (
          <div className="dealer-overview__empty"
               style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
            <FiFileText size={32} style={{ color: '#9CA3AF' }} />
            <strong style={{ color: '#111827' }}>No invoices to show</strong>
            <p style={{ margin: 0, color: '#6B7280' }}>
              {filter === 'open'
                ? 'No outstanding invoices — you\'re all paid up.'
                : count === 0
                  ? 'Invoices appear here once you\'ve completed a paid order or placed a credit order.'
                  : 'No invoices match this filter.'}
            </p>
          </div>
        ) : (
          <>
            <div style={{ overflowX: 'auto' }}>
              <table className="admin-table admin-table--compact" style={{ minWidth: 720 }}>
                <thead>
                  <tr>
                    <th>Invoice #</th>
                    <th>Order</th>
                    <th>Date</th>
                    <th>Total</th>
                    <th>Outstanding</th>
                    <th>Status</th>
                    <th style={{ textAlign: 'right' }}>PDF</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((inv) => {
                    const due = parseFloat(inv.amount_due || 0);
                    const isOpen = due > 0;
                    return (
                      <tr key={inv.id}>
                        <td><strong>{inv.invoice_number}</strong></td>
                        <td><code>{inv.order_id_human || '—'}</code></td>
                        <td>{formatDate(inv.invoice_date || inv.created_at)}</td>
                        <td>{formatPrice(inv.grand_total)}</td>
                        <td style={{ color: isOpen ? '#B91C1C' : '#047857', fontWeight: 600 }}>
                          {isOpen ? formatPrice(due) : '—'}
                        </td>
                        <td>
                          {isOpen
                            ? <span style={pillStyle('#FEE2E2', '#B91C1C')}>
                                <FiAlertCircle size={11} /> Outstanding
                              </span>
                            : <span style={pillStyle('#D1FAE5', '#047857')}>✓ Paid</span>}
                        </td>
                        <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>
                          <button className="admin-icon-btn" onClick={() => openPDF(inv, false)}
                                  disabled={busyId === inv.id} aria-label="View PDF">
                            <FiExternalLink size={13} />
                          </button>
                          <button className="admin-icon-btn" onClick={() => openPDF(inv, true)}
                                  disabled={busyId === inv.id} aria-label="Download PDF">
                            <FiDownload size={13} />
                          </button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
            <Pagination
              page={page}
              count={count}
              pageSize={PAGE_SIZE}
              onChange={setPage}
            />
          </>
        )}
      </section>
    </div>
  );
}

const pillStyle = (bg, fg) => ({
  display: 'inline-flex', alignItems: 'center', gap: 4,
  padding: '2px 8px', borderRadius: 999,
  background: bg, color: fg, fontSize: 11, fontWeight: 700,
});
