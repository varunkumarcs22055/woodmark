import DealerSupport from './dealer/DealerSupport';
import './dealer/DealerDashboard.css';
import './admin/AdminPanel.css';

export default function SupportInbox() {
  return (
    <div className="dealer-main__content">
      <DealerSupport />
    </div>
  );
}
