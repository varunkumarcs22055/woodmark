import { FiAlertTriangle, FiX } from 'react-icons/fi';
import './ConfirmModal.css';

export default function ConfirmModal({ 
  open, 
  title = 'Are you sure?', 
  message = 'This action cannot be undone.', 
  confirmLabel = 'Delete', 
  cancelLabel = 'Cancel', 
  onConfirm, 
  onCancel,
  loading = false,
  tone = 'danger' // 'danger' | 'warn' | 'neutral'
}) {
  if (!open) return null;

  return (
    <div className="confirm-modal-overlay" onClick={onCancel}>
      <div className="confirm-modal" onClick={(e) => e.stopPropagation()}>
        <div className="confirm-modal__header">
          <div className={`confirm-modal__icon confirm-modal__icon--${tone}`}>
            <FiAlertTriangle size={20} />
          </div>
          <button className="confirm-modal__close" onClick={onCancel}>
            <FiX size={18} />
          </button>
        </div>
        <div className="confirm-modal__body">
          <h3>{title}</h3>
          <p>{message}</p>
        </div>
        <div className="confirm-modal__footer">
          <button 
            type="button" 
            className="btn-outline" 
            onClick={onCancel} 
            disabled={loading}
          >
            {cancelLabel}
          </button>
          <button 
            type="button" 
            className={`btn-${tone === 'danger' ? 'danger' : 'primary'}`} 
            onClick={onConfirm} 
            disabled={loading}
          >
            {loading ? 'Processing…' : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
