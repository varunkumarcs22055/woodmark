/**
 * CompareBar — floating tray showing products queued for comparison.
 * Renders only when 1+ products are selected. Public storefront only.
 */
import { useNavigate } from 'react-router-dom';
import { FiX, FiBarChart2 } from 'react-icons/fi';
import { useCompare } from '../context/CompareContext';
import './CompareBar.css';

export default function CompareBar() {
  const { compareItems, removeCompare, clearCompare } = useCompare();
  const navigate = useNavigate();
  if (compareItems.length === 0) return null;

  return (
    <div className="compare-bar" role="region" aria-label="Compare products">
      <div className="compare-bar__items">
        {compareItems.map((p) => (
          <div className="compare-bar__chip" key={p.id}>
            <img src={p.image_url} alt="" />
            <span>{p.name}</span>
            <button type="button" onClick={() => removeCompare(p.id)} aria-label={`Remove ${p.name}`}>
              <FiX size={13} />
            </button>
          </div>
        ))}
      </div>
      <div className="compare-bar__actions">
        <button type="button" className="compare-bar__clear" onClick={clearCompare}>
          Clear
        </button>
        <button
          type="button"
          className="btn-primary compare-bar__go"
          onClick={() => navigate('/compare')}
          disabled={compareItems.length < 2}
        >
          <FiBarChart2 size={15} /> Compare ({compareItems.length})
        </button>
      </div>
    </div>
  );
}
