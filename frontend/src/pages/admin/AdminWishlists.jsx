/**
 * AdminWishlists — full cross-user wishlist browser.
 *
 *  - Searchable by user email / name OR product name
 *  - Paginated
 *  - Each row shows: product thumb, name, category, price, the user who saved
 *    it, when they saved it
 *  - Three stat cards up top: total wishlists, unique users, unique products
 *
 * Use cases:
 *   • Spot which products are heavily wishlisted (purchase signal).
 *   • See which customers are window-shopping which categories (retargeting).
 *   • Drop into AdminSMS or AdminNewsletter with a targeted offer.
 */
import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { FiHeart, FiSearch, FiUser, FiPackage, FiShoppingBag, FiX } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchAllWishlists } from '../../api';
import Pagination from '../../components/Pagination';

const PAGE_SIZE = 25;

function formatINR(value) {
  if (!value && value !== 0) return '—';
  return `Rs. ${Math.round(value).toLocaleString('en-IN')}`;
}

function formatDate(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleDateString('en-IN', {
    day: '2-digit', month: 'short', year: 'numeric',
  });
}

export default function AdminWishlists() {
  const [items, setItems] = useState([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);

  // Search + price filters split into "input" (typed-but-not-yet-applied)
  // and "applied" (active in the query). Submit copies input -> applied.
  const [searchInput, setSearchInput] = useState('');
  const [minPriceInput, setMinPriceInput] = useState('');
  const [maxPriceInput, setMaxPriceInput] = useState('');
  const [search, setSearch] = useState('');
  const [minPrice, setMinPrice] = useState('');
  const [maxPrice, setMaxPrice] = useState('');

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    const params = { page, page_size: PAGE_SIZE };
    if (search) params.search = search;
    if (minPrice) params.min_price = minPrice;
    if (maxPrice) params.max_price = maxPrice;
    fetchAllWishlists(params)
      .then((data) => {
        if (cancelled) return;
        setItems(data.results || []);
        setCount(data.count || 0);
      })
      .catch(() => toast.error('Failed to load wishlists'))
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [page, search, minPrice, maxPrice]);

  // Stat cards — count unique users + unique products in the current page.
  // (For "all-time totals" we'd need a separate endpoint; this is a snapshot
  // of what's currently visible.)
  const stats = useMemo(() => {
    const userIds = new Set(items.map((i) => i.user.id));
    const productIds = new Set(items.map((i) => i.product.id));
    return {
      total: count,
      uniqueUsers: userIds.size,
      uniqueProducts: productIds.size,
    };
  }, [items, count]);

  const handleSearch = (e) => {
    e.preventDefault();
    setPage(1);
    setSearch(searchInput.trim());
    setMinPrice(minPriceInput.trim());
    setMaxPrice(maxPriceInput.trim());
  };

  const handleClear = () => {
    setSearchInput('');
    setMinPriceInput('');
    setMaxPriceInput('');
    setSearch('');
    setMinPrice('');
    setMaxPrice('');
    setPage(1);
  };

  const hasFilters = !!(search || minPrice || maxPrice);

  return (
    <div className="admin-page">
      <div className="admin-page__title-row">
        <h2 className="admin-page__title" style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <FiHeart size={22} style={{ color: '#e74c3c' }} />
          Wishlists
        </h2>
      </div>

      {/* Stat cards */}
      <div className="admin-stats-grid admin-stats-grid--compact">
        <div className="admin-stat-card">
          <div className="admin-stat-card__label">
            <FiHeart size={14} /> Total wishlist items
          </div>
          <div className="admin-stat-card__value">{stats.total.toLocaleString('en-IN')}</div>
        </div>
        <div className="admin-stat-card">
          <div className="admin-stat-card__label">
            <FiUser size={14} /> Users on this page
          </div>
          <div className="admin-stat-card__value">{stats.uniqueUsers}</div>
        </div>
        <div className="admin-stat-card">
          <div className="admin-stat-card__label">
            <FiPackage size={14} /> Products on this page
          </div>
          <div className="admin-stat-card__value">{stats.uniqueProducts}</div>
        </div>
      </div>

      {/* Search + price-range filters. Pressing Enter on any input submits. */}
      <form onSubmit={handleSearch} style={{ marginBottom: 20 }}>
        <div className="admin-search">
          <FiSearch size={18} className="admin-search__icon" />
          <input
            type="search"
            placeholder="Search by user email, name, or product name…"
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            className="admin-search__input"
          />
          {searchInput && (
            <button
              type="button"
              onClick={() => setSearchInput('')}
              className="admin-search__clear"
              title="Clear text"
              aria-label="Clear text"
            >
              <FiX size={14} />
            </button>
          )}
          <button type="submit" className="admin-search__btn">
            Search
          </button>
        </div>

        {/* Price-range row + quick chips */}
        <div style={{
          marginTop: 12, display: 'flex', flexWrap: 'wrap',
          alignItems: 'center', gap: 10,
        }}>
          <div className="admin-money-range">
            <span className="admin-money-range__currency">Rs.</span>
            <input
              type="number"
              min="0"
              step="500"
              placeholder="Min price"
              value={minPriceInput}
              onChange={(e) => setMinPriceInput(e.target.value)}
              className="admin-money-range__input"
            />
            <span className="admin-money-range__sep">to</span>
            <input
              type="number"
              min="0"
              step="500"
              placeholder="Max price"
              value={maxPriceInput}
              onChange={(e) => setMaxPriceInput(e.target.value)}
              className="admin-money-range__input"
            />
            <button type="submit" className="admin-money-range__apply">
              Apply
            </button>
          </div>

          <span style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>Quick:</span>
          {[
            { label: '≥ 10k', min: 10000 },
            { label: '≥ 25k', min: 25000 },
            { label: '≥ 50k', min: 50000 },
            { label: '≥ 1L',  min: 100000 },
          ].map((q) => (
            <button
              key={q.label}
              type="button"
              onClick={() => {
                setMinPriceInput(String(q.min));
                setMaxPriceInput('');
                setMinPrice(String(q.min));
                setMaxPrice('');
                setPage(1);
              }}
              className={`admin-chip ${String(q.min) === minPrice ? 'admin-chip--active' : ''}`}
            >
              {q.label}
            </button>
          ))}

          {hasFilters && (
            <button
              type="button"
              onClick={handleClear}
              className="admin-chip admin-chip--ghost"
              title="Clear all filters"
            >
              <FiX size={12} /> Clear all
            </button>
          )}
        </div>

        {hasFilters && (
          <p style={{ marginTop: 10, fontSize: 12, color: 'var(--color-text-muted)' }}>
            Filtering by
            {search && <> text "<strong>{search}</strong>"</>}
            {(search && (minPrice || maxPrice)) && ', '}
            {minPrice && <> price ≥ Rs. {Number(minPrice).toLocaleString('en-IN')}</>}
            {minPrice && maxPrice && ' and'}
            {maxPrice && <> price ≤ Rs. {Number(maxPrice).toLocaleString('en-IN')}</>}
            <> · {count} match{count === 1 ? '' : 'es'}</>
          </p>
        )}
      </form>

      {/* Table */}
      <div className="admin-table-wrapper">
        {loading ? (
          <p className="admin-empty">Loading…</p>
        ) : items.length === 0 ? (
          <div className="admin-empty">
            <FiHeart size={32} style={{ opacity: 0.4 }} />
            <p style={{ margin: 0, fontWeight: 600 }}>
              {search ? 'No wishlists match your search.' : 'No wishlists yet.'}
            </p>
            <p style={{ margin: 0, fontSize: 12 }}>
              {search ? 'Try a different keyword.' : 'Customers who tap the heart icon on a product land here.'}
            </p>
          </div>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th style={{ width: 80 }}>Image</th>
                <th>Product</th>
                <th>Category</th>
                <th style={{ textAlign: 'right' }}>Price</th>
                <th>Saved by</th>
                <th>When</th>
                <th style={{ width: 80 }}></th>
              </tr>
            </thead>
            <tbody>
              {items.map((w) => (
                <tr key={w.id}>
                  <td>
                    {w.product.image_url ? (
                      <img
                        src={w.product.image_url}
                        alt=""
                        style={{
                          width: 56, height: 56, objectFit: 'cover',
                          borderRadius: 8, background: '#f4f6f5',
                        }}
                        loading="lazy"
                      />
                    ) : (
                      <div style={{
                        width: 56, height: 56, borderRadius: 8,
                        background: '#f4f6f5',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                      }}>
                        <FiPackage size={20} style={{ color: '#bbb' }} />
                      </div>
                    )}
                  </td>
                  <td>
                    <Link to={`/product/${w.product.slug}`}
                          target="_blank" rel="noreferrer"
                          style={{ color: 'var(--color-text)', fontWeight: 600, textDecoration: 'none' }}>
                      {w.product.name}
                    </Link>
                  </td>
                  <td>
                    <span style={{
                      display: 'inline-block', padding: '3px 10px',
                      background: 'var(--color-brand-pale)', color: 'var(--color-brand)',
                      borderRadius: 999, fontSize: 11, fontWeight: 700, letterSpacing: '0.04em',
                      textTransform: 'uppercase',
                    }}>
                      {w.product.category || '—'}
                    </span>
                  </td>
                  <td style={{ textAlign: 'right', fontWeight: 700 }}>
                    {formatINR(w.product.price)}
                  </td>
                  <td>
                    <div style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.3 }}>
                      <strong style={{ fontSize: 13 }}>{w.user.name || '—'}</strong>
                      <span style={{ fontSize: 12, color: 'var(--color-text-muted)', wordBreak: 'break-all' }}>
                        {w.user.email}
                      </span>
                      {w.user.phone && (
                        <span style={{ fontSize: 11, color: 'var(--color-text-muted)' }}>
                          {w.user.phone}
                        </span>
                      )}
                    </div>
                  </td>
                  <td style={{ fontSize: 12, color: 'var(--color-text-muted)', whiteSpace: 'nowrap' }}>
                    {formatDate(w.added_at)}
                  </td>
                  <td>
                    <Link to={`/admin-dashboard/customers?id=${w.user.id}`}
                          className="btn-outline"
                          style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontSize: 12, padding: '6px 10px' }}
                          title="Open this customer's profile">
                      <FiShoppingBag size={12} /> View
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <Pagination
        page={page}
        pageSize={PAGE_SIZE}
        totalCount={count}
        onChange={setPage}
      />
    </div>
  );
}
