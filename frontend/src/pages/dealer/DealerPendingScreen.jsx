/**
 * Shown when user.dealer_status === 'pending'.
 */
import { Link } from 'react-router-dom';
import { FiClock, FiMail } from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';

export default function DealerPendingScreen() {
  const { user, logout } = useAuth();

  return (
    <div className="dealer-status-screen-wrap">
      <div className="dealer-status-screen">
        <div className="dealer-status-screen__icon dealer-status-screen__icon--pending">
          <FiClock size={56} />
        </div>
        <h1>Application Under Review</h1>
        <p className="dealer-status-screen__lead">
          Thanks for applying, <strong>{user?.dealer_company_name || user?.full_name}</strong>.
          Our team is reviewing your dealer application.
        </p>

        <div className="dealer-status-screen__details">
          <div className="dealer-status-screen__detail-row">
            <span>Status</span>
            <strong style={{ color: '#E65100' }}>● Pending Review</strong>
          </div>
          {user?.date_joined && (
            <div className="dealer-status-screen__detail-row">
              <span>Applied On</span>
              <strong>{new Date(user.date_joined).toLocaleDateString('en-IN', {
                day: 'numeric', month: 'long', year: 'numeric',
              })}</strong>
            </div>
          )}
          <div className="dealer-status-screen__detail-row">
            <span>Estimated Review Time</span>
            <strong>1–3 business days</strong>
          </div>
        </div>

        <div className="dealer-status-screen__next">
          <h3>What happens next?</h3>
          <ol>
            <li>Our team verifies your business details and GST number.</li>
            <li>You'll receive an email at <strong>{user?.email}</strong> once approved.</li>
            <li>After approval, you'll see exclusive dealer pricing across the catalog.</li>
          </ol>
        </div>

        <div className="dealer-status-screen__actions">
          <Link to="/" className="btn-primary">Browse as Customer</Link>
          <a href="mailto:dealers@furnishop.com" className="btn-outline">
            <FiMail size={14} /> Contact Support
          </a>
          <button onClick={logout} className="dealer-status-screen__signout">Sign Out</button>
        </div>
      </div>
    </div>
  );
}
