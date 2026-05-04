/**
 * AdminDealers — pending applications + active dealers, approve/reject.
 */
import { useEffect, useState } from 'react';
import { FiCheck, FiX } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchUsers, approveDealer } from '../../api';
import { formatDate } from '../../utils/format';

export default function AdminDealers() {
  const [pending, setPending] = useState([]);
  const [active, setActive] = useState([]);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    setLoading(true);
    try {
      const [pendingRes, activeRes] = await Promise.allSettled([
        fetchUsers({ role: 'dealer', dealer_status: 'pending' }),
        fetchUsers({ role: 'dealer', dealer_status: 'active' }),
      ]);
      setPending(pendingRes.status === 'fulfilled'
        ? (pendingRes.value.results || pendingRes.value || []) : []);
      setActive(activeRes.status === 'fulfilled'
        ? (activeRes.value.results || activeRes.value || []) : []);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const handleApprove = async (userId, name) => {
    try {
      await approveDealer(userId, 'active');
      toast.success(`${name} approved as dealer.`);
      await load();
    } catch {
      toast.error('Approval failed.');
    }
  };

  const handleReject = async (userId, name) => {
    if (!window.confirm(`Reject ${name}'s dealer application?`)) return;
    try {
      await approveDealer(userId, 'rejected');
      toast.success('Application rejected.');
      await load();
    } catch {
      toast.error('Rejection failed.');
    }
  };

  return (
    <div className="admin-page">
      <h2 className="admin-page__title">Dealer Management</h2>

      <section className="admin-card">
        <div className="admin-card__header">
          <h3>Pending Applications {pending.length > 0 && <span className="admin-pill">{pending.length}</span>}</h3>
        </div>
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : pending.length === 0 ? (
          <p className="admin-empty">No pending applications.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr><th>Name</th><th>Email</th><th>Phone</th><th>Company</th><th>GST</th><th>Applied</th><th style={{ width: 130 }}>Actions</th></tr>
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
                  <td>
                    <button className="admin-icon-btn admin-icon-btn--success"
                      onClick={() => handleApprove(d.id, d.full_name)} aria-label="Approve">
                      <FiCheck size={14} />
                    </button>
                    <button className="admin-icon-btn admin-icon-btn--danger"
                      onClick={() => handleReject(d.id, d.full_name)} aria-label="Reject">
                      <FiX size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <section className="admin-card" style={{ marginTop: 24 }}>
        <div className="admin-card__header">
          <h3>Active Dealers ({active.length})</h3>
        </div>
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : active.length === 0 ? (
          <p className="admin-empty">No active dealers yet.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr><th>Name</th><th>Email</th><th>Company</th><th>GST</th><th>Joined</th></tr>
            </thead>
            <tbody>
              {active.map((d) => (
                <tr key={d.id}>
                  <td><strong>{d.full_name}</strong></td>
                  <td>{d.email}</td>
                  <td>{d.dealer_company_name || '—'}</td>
                  <td><code>{d.dealer_gst_number || '—'}</code></td>
                  <td>{formatDate(d.date_joined)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
