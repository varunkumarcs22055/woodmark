/**
 * Dealer status pill — Active / Pending / Rejected.
 */
import './DealerStatusBadge.css';

const STATUS_CONFIG = {
  active:   { label: 'Active',   color: '#2E7D32', bg: 'rgba(46, 125, 50, 0.1)' },
  pending:  { label: 'Pending',  color: '#E65100', bg: 'rgba(245, 124, 0, 0.1)' },
  rejected: { label: 'Rejected', color: '#C62828', bg: 'rgba(198, 40, 40, 0.1)' },
};

export default function DealerStatusBadge({ status }) {
  const config = STATUS_CONFIG[status] || STATUS_CONFIG.pending;
  return (
    <span
      className="dealer-status-badge"
      style={{ color: config.color, background: config.bg }}
    >
      ● {config.label}
    </span>
  );
}
