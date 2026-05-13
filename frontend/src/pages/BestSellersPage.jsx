/**
 * BestSellersPage — dedicated /best-sellers route.
 *
 * Backend ranks by SUM(OrderItem.quantity) across paid orders in the trailing
 * `days` window (default 30). Cold-start fallback to top-rated products if
 * no orders match (so a fresh deployment isn't empty).
 */
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { FiTrendingUp, FiAward, FiArrowLeft } from 'react-icons/fi';
import { fetchBestSellers } from '../api';
import ProductCard from '../components/ProductCard';
import './BestSellersPage.css';

const WINDOWS = [
  { days: 7,  label: 'Last 7 days' },
  { days: 30, label: 'Last 30 days' },
  { days: 90, label: 'Last 90 days' },
];

export default function BestSellersPage() {
  const [windowDays, setWindowDays] = useState(30);
  const [data, setData] = useState({ results: [], count: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let live = true;
    setLoading(true);
    fetchBestSellers({ days: windowDays, limit: 24 })
      .then((d) => { if (live) setData(d); })
      .catch(() => { if (live) setData({ results: [], count: 0 }); })
      .finally(() => { if (live) setLoading(false); });
    return () => { live = false; };
  }, [windowDays]);

  const items = data.results || [];
  const top = items[0];

  return (
    <div className="bestsellers-page">
      <header className="bs-hero">
        <div className="bs-hero__inner container">
          <Link to="/" className="bs-back">
            <FiArrowLeft size={14} /> Back to shop
          </Link>
          <span className="bs-eyebrow">
            <FiTrendingUp size={14} /> Top Picks
          </span>
          <h1 className="bs-title">Best Sellers</h1>
          <p className="bs-sub">
            Ranked live by units actually shipped. No editorial picks, no
            promoted slots — just what the most FurniShop customers bought.
          </p>

          <div className="bs-windows">
            {WINDOWS.map((w) => (
              <button
                key={w.days}
                onClick={() => setWindowDays(w.days)}
                className={`bs-window ${windowDays === w.days ? 'bs-window--active' : ''}`}
              >
                {w.label}
              </button>
            ))}
          </div>
        </div>
      </header>

      <section className="bs-body container">
        {loading ? (
          <div className="bs-grid">
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="skeleton" style={{ height: 360, borderRadius: 16 }} />
            ))}
          </div>
        ) : items.length === 0 ? (
          <div className="bs-empty">
            <FiAward size={42} />
            <h3>No sales yet in this window</h3>
            <p>Try a longer time range, or browse the full catalogue.</p>
            <Link to="/" className="btn-primary">Shop the catalogue</Link>
          </div>
        ) : (
          <>
            {/* Hero card for #1 */}
            {top && (
              <div className="bs-champion">
                <div className="bs-champion__crown">
                  <FiAward size={18} /> Bestselling product
                </div>
                <Link to={`/product/${top.slug}`} className="bs-champion__card">
                  <img src={top.image_url} alt={top.name} />
                  <div className="bs-champion__copy">
                    <span className="bs-rank-pill bs-rank-pill--gold">#1</span>
                    <h2>{top.name}</h2>
                    {top.brand && <span className="bs-brand">{top.brand}</span>}
                    <p className="bs-units">
                      {top.units_sold_in_window > 0
                        ? `${top.units_sold_in_window.toLocaleString()} units sold in the last ${windowDays} days`
                        : 'Top-rated by FurniShop customers'}
                    </p>
                    <span className="bs-cta">View product →</span>
                  </div>
                </Link>
              </div>
            )}

            {/* Rest of the chart */}
            <div className="bs-grid">
              {items.slice(1).map((p, i) => (
                <div key={p.id} className="bs-tile">
                  <span className={`bs-rank-pill ${i + 2 <= 3 ? 'bs-rank-pill--silver' : ''}`}>
                    #{i + 2}
                  </span>
                  <ProductCard product={p} />
                  {p.units_sold_in_window > 0 && (
                    <span className="bs-units-chip">
                      {p.units_sold_in_window.toLocaleString()} sold
                    </span>
                  )}
                </div>
              ))}
            </div>
          </>
        )}
      </section>
    </div>
  );
}
