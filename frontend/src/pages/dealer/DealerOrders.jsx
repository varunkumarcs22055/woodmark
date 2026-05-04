/**
 * DealerOrders — dealer's order history with status chips + summary cards.
 */
import { useEffect, useState, useMemo } from 'react';
import { FiSearch } from 'react-icons/fi';
import { fetchOrders } from '../../api';
import OrderCard from '../../components/OrderCard';

const STATUS_OPTIONS = ['ALL', 'CREATED', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

export default function DealerOrders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState('ALL');
  const [search, setSearch] = useState('');

  useEffect(() => {
    let live = true;
    fetchOrders()
      .then((data) => {
        if (!live) return;
        setOrders(Array.isArray(data) ? data : data?.results || []);
      })
      .catch(() => setOrders([]))
      .finally(() => live && setLoading(false));
    return () => { live = false; };
  }, []);

  const filtered = useMemo(() => orders
    .filter((o) => filterStatus === 'ALL' || o.order_status === filterStatus)
    .filter((o) => !search || o.order_id.toLowerCase().includes(search.toLowerCase())),
  [orders, filterStatus, search]);

  const totals = useMemo(() => ({
    total: orders.length,
    paid: orders.filter((o) => o.payment_status === 'PAID' || o.payment_status === 'SUCCESS').length,
    pending: orders.filter((o) => o.order_status === 'CREATED').length,
    delivered: orders.filter((o) => o.order_status === 'DELIVERED').length,
  }), [orders]);

  return (
    <div className="dealer-orders">
      <header className="dealer-orders__header">
        <h1>My Orders</h1>
        <p>Track your B2B orders, payments, and shipments.</p>
      </header>

      <div className="dealer-orders__summary">
        <SummaryItem label="Total" value={totals.total} />
        <SummaryItem label="Paid" value={totals.paid} />
        <SummaryItem label="Awaiting Payment" value={totals.pending} />
        <SummaryItem label="Delivered" value={totals.delivered} />
      </div>

      <div className="dealer-orders__toolbar">
        <div className="dealer-orders__search">
          <FiSearch />
          <input
            type="search"
            placeholder="Search by Order ID…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <div className="dealer-orders__filters">
          {STATUS_OPTIONS.map((s) => (
            <button
              key={s}
              onClick={() => setFilterStatus(s)}
              className={`dealer-orders__chip ${filterStatus === s ? 'dealer-orders__chip--active' : ''}`}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="dealer-orders__empty">Loading…</div>
      ) : filtered.length === 0 ? (
        <div className="dealer-orders__empty">No orders match your filters.</div>
      ) : (
        <div className="dealer-orders__list">
          {filtered.map((o) => (
            <OrderCard key={o.order_id} order={o} />
          ))}
        </div>
      )}
    </div>
  );
}

function SummaryItem({ label, value }) {
  return (
    <div className="dealer-orders__summary-item">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}
