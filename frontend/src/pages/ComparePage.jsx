/**
 * ComparePage — side-by-side comparison of the products in CompareContext.
 */
import { Link } from 'react-router-dom';
import { FiX, FiShoppingBag, FiArrowLeft } from 'react-icons/fi';
import { useCompare } from '../context/CompareContext';
import { useCart } from '../context/CartContext';
import { formatPrice } from '../utils/format';
import StarRating from '../components/StarRating';
import toast from 'react-hot-toast';
import './ComparePage.css';

const ROWS = [
  { key: 'price', label: 'Price', render: (p) => formatPrice(p.effective_price ?? p.price) },
  { key: 'category_name', label: 'Category', render: (p) => p.category_name || '—' },
  { key: 'brand', label: 'Brand', render: (p) => p.brand || '—' },
  { key: 'material', label: 'Material', render: (p) => p.material || '—' },
  { key: 'color', label: 'Colour', render: (p) => p.color || '—' },
  { key: 'dimensions', label: 'Dimensions', render: (p) => p.dimensions || '—' },
  { key: 'warranty', label: 'Warranty', render: (p) => p.warranty || '—' },
  {
    key: 'rating',
    label: 'Rating',
    render: (p) =>
      (p.rating_count ?? 0) > 0
        ? <StarRating value={p.rating_avg} count={p.rating_count} size={13} />
        : 'No reviews',
  },
  {
    key: 'in_stock',
    label: 'Availability',
    render: (p) =>
      p.in_stock
        ? <span className="cmp-instock">In stock</span>
        : <span className="cmp-oos">Out of stock</span>,
  },
];

export default function ComparePage() {
  const { compareItems, removeCompare, clearCompare } = useCompare();
  const { addToCart } = useCart();

  if (compareItems.length === 0) {
    return (
      <div className="compare-page container">
        <div className="empty-state">
          <div className="empty-icon">⚖️</div>
          <h3>Nothing to compare yet</h3>
          <p>Add products to compare using the “Compare” button on any product.</p>
          <Link to="/" className="btn-primary">Browse products</Link>
        </div>
      </div>
    );
  }

  const add = (p) => {
    addToCart(p, 1);
    toast.success(`${p.name} added to cart`);
  };

  return (
    <div className="compare-page container">
      <div className="compare-head">
        <Link to="/" className="compare-back"><FiArrowLeft size={15} /> Back to shop</Link>
        <h1>Compare products</h1>
        <button type="button" className="compare-clear" onClick={clearCompare}>Clear all</button>
      </div>

      <div className="compare-scroll">
        <table className="compare-table" style={{ '--cols': compareItems.length }}>
          <thead>
            <tr>
              <th className="cmp-rowhead" />
              {compareItems.map((p) => (
                <th key={p.id} className="cmp-prodhead">
                  <button type="button" className="cmp-remove" onClick={() => removeCompare(p.id)} aria-label="Remove">
                    <FiX size={14} />
                  </button>
                  <Link to={`/product/${p.slug}`}>
                    <img src={p.image_url} alt={p.name} className="cmp-img" />
                    <span className="cmp-name">{p.name}</span>
                  </Link>
                  <button type="button" className="btn-primary cmp-add" onClick={() => add(p)} disabled={!p.in_stock}>
                    <FiShoppingBag size={13} /> {p.in_stock ? 'Add to cart' : 'Out of stock'}
                  </button>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {ROWS.map((row) => (
              <tr key={row.key}>
                <td className="cmp-rowhead">{row.label}</td>
                {compareItems.map((p) => (
                  <td key={p.id} className="cmp-cell">{row.render(p)}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
