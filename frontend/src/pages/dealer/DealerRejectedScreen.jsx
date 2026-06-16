/**
 * Shown when user.dealer_status === 'rejected'.
 */
import { Link } from 'react-router-dom';
import { FiAlertCircle, FiMail } from 'react-icons/fi';
import { useAuth } from '../../context/AuthContext';

export default function DealerRejectedScreen() {
  const { logout } = useAuth();

  return (
    <div className="dealer-status-screen-wrap">
      <div className="dealer-status-screen">
        <div className="dealer-status-screen__icon dealer-status-screen__icon--rejected">
          <FiAlertCircle size={56} />
        </div>
        <h1>Application Not Approved</h1>
        <p className="dealer-status-screen__lead">
          Unfortunately, we were unable to approve your dealer application at this time.
        </p>

        <div className="dealer-status-screen__details">
          <p>
            This may be because of incomplete business information, an unverifiable GST number,
            or insufficient business history. We'd encourage you to review your application and
            reach out to our team for clarification.
          </p>
        </div>

        <div className="dealer-status-screen__next">
          <h3>What you can do</h3>
          <ul>
            <li>Continue shopping as a regular customer with our standard catalog.</li>
            <li>Contact our dealer team to understand why and reapply with updated info.</li>
            <li>If your business is newly established, consider reapplying after 6 months.</li>
          </ul>
        </div>

        <div className="dealer-status-screen__actions">
          <Link to="/" className="btn-primary">Continue as Customer</Link>
          <a href="mailto:dealers@woodmark.in" className="btn-outline">
            <FiMail size={14} /> Contact Dealer Team
          </a>
          <button onClick={logout} className="dealer-status-screen__signout">Sign Out</button>
        </div>
      </div>
    </div>
  );
}
