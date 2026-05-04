/**
 * DealerCatalog — product browsing with FilterSidebar, sort, pagination,
 * and DealerProductCard rendering. Backend's /api/products/ returns
 * dealer-priced effective_price automatically when JWT role is 'dealer'.
 */
import { useEffect, useState, useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import { FiSearch, FiX } from 'react-icons/fi';
import { fetchProducts, fetchCategories } from '../../api';
import DealerProductCard from '../../components/dealer/DealerProductCard';
import FilterSidebar from '../../components/FilterSidebar';

export default function DealerCatalog() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [pagination, setPagination] = useState({ count: 0, next: null, previous: null });
  const [filterOpen, setFilterOpen] = useState(false);

  const filters = useMemo(() => ({
    category: searchParams.get('category') || '',
    price_min: searchParams.get('price_min') || '',
    price_max: searchParams.get('price_max') || '',
    material: searchParams.get('material') || '',
    search: searchParams.get('search') || '',
    ordering: searchParams.get('ordering') || '-created_at',
    page: parseInt(searchParams.get('page') || '1', 10),
  }), [searchParams]);

  useEffect(() => {
    fetchCategories()
      .then((d) => setCategories(d.results || d || []))
      .catch(() => {});
  }, []);

  useEffect(() => {
    let live = true;
    setLoading(true);
    const params = {};
    Object.entries(filters).forEach(([k, v]) => {
      if (v) params[k] = v;
    });
    fetchProducts(params)
      .then((data) => {
        if (!live) return;
        setProducts(data.results || data || []);
        setPagination({
          count: data.count ?? (data.length || 0),
          next: data.next,
          previous: data.previous,
        });
      })
      .catch(() => setProducts([]))
      .finally(() => live && setLoading(false));
    return () => { live = false; };
  }, [filters]);

  const updateFilter = (next) => {
    const sp = new URLSearchParams();
    Object.entries(next).forEach(([k, v]) => {
      if (v && v !== 1) sp.set(k, v);
    });
    setSearchParams(sp, { replace: true });
  };

  const handleFilterChange = (newFilters) => {
    updateFilter({ ...newFilters, page: 1 });
  };

  return (
    <div className="dealer-catalog">
      <header className="dealer-catalog__header">
        <h1>Dealer Catalog</h1>
        <p>All prices shown reflect your exclusive B2B rates.</p>
      </header>

      <div className="dealer-catalog__layout">
        <aside className="dealer-catalog__sidebar">
          <FilterSidebar
            filters={filters}
            onFilterChange={handleFilterChange}
            mobileOpen={filterOpen}
            onClose={() => setFilterOpen(false)}
          />
        </aside>

        <section className="dealer-catalog__results">
          <div className="dealer-catalog__toolbar">
            <div className="dealer-catalog__search">
              <FiSearch />
              <input
                type="search"
                placeholder="Search products…"
                value={filters.search}
                onChange={(e) => updateFilter({ ...filters, search: e.target.value, page: 1 })}
              />
              {filters.search && (
                <button onClick={() => updateFilter({ ...filters, search: '', page: 1 })}>
                  <FiX />
                </button>
              )}
            </div>
          </div>

          <div className="dealer-catalog__count">
            Showing {products.length} of {pagination.count} products
          </div>

          {loading ? (
            <div className="dealer-catalog__empty">Loading…</div>
          ) : products.length === 0 ? (
            <div className="dealer-catalog__empty">
              <p>No products match your filters.</p>
              <button onClick={() => setSearchParams({})} className="btn-outline">
                Clear Filters
              </button>
            </div>
          ) : (
            <div className="dealer-catalog__grid">
              {products.map((p) => (
                <DealerProductCard key={p.id} product={p} />
              ))}
            </div>
          )}

          {(pagination.next || pagination.previous) && (
            <div className="dealer-catalog__pagination">
              <button
                disabled={!pagination.previous}
                onClick={() => updateFilter({ ...filters, page: filters.page - 1 })}
                className="btn-outline"
              >
                ← Previous
              </button>
              <span>Page {filters.page}</span>
              <button
                disabled={!pagination.next}
                onClick={() => updateFilter({ ...filters, page: filters.page + 1 })}
                className="btn-outline"
              >
                Next →
              </button>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
