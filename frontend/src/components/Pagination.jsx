/**
 * Pagination — reusable Prev / Next / window pager.
 *
 * Designed to work with DRF's PageNumberPagination shape
 * (`{ count, next, previous, results }`). Pass `count`, `pageSize`, and
 * the current `page` (1-indexed) along with an `onChange(page)` callback.
 * The component renders nothing when there's only one page.
 *
 * Why this exists: every admin/dealer list was fetching `page_size=100`
 * (or worse, no page param) so the very first byte cost a full table.
 * With pagination, the initial paint shows 12-20 rows and the user
 * pages forward only when needed → ~5-10× faster on big tables.
 */
import { FiChevronLeft, FiChevronRight } from 'react-icons/fi';
import './Pagination.css';

export default function Pagination({
  page = 1,
  count = 0,
  pageSize = 12,
  onChange,
  windowSize = 5,
  className = '',
}) {
  const totalPages = Math.max(1, Math.ceil(count / pageSize));
  if (totalPages <= 1) return null;

  // Compute a small window of numbered page buttons around the current page.
  const half = Math.floor(windowSize / 2);
  let start = Math.max(1, page - half);
  let end = Math.min(totalPages, start + windowSize - 1);
  if (end - start + 1 < windowSize) start = Math.max(1, end - windowSize + 1);
  const pages = [];
  for (let i = start; i <= end; i++) pages.push(i);

  const go = (p) => {
    const clamped = Math.min(totalPages, Math.max(1, p));
    if (clamped !== page) onChange?.(clamped);
  };

  const firstOnPage = (page - 1) * pageSize + 1;
  const lastOnPage = Math.min(page * pageSize, count);

  return (
    <nav className={`pager ${className}`} aria-label="Pagination">
      <span className="pager__count">
        {firstOnPage}–{lastOnPage} of {count}
      </span>
      <div className="pager__buttons">
        <button
          type="button"
          className="pager__btn"
          onClick={() => go(page - 1)}
          disabled={page <= 1}
          aria-label="Previous page"
        >
          <FiChevronLeft size={14} />
        </button>
        {start > 1 && (
          <>
            <button type="button" className="pager__num" onClick={() => go(1)}>1</button>
            {start > 2 && <span className="pager__ellipsis">…</span>}
          </>
        )}
        {pages.map((p) => (
          <button
            key={p}
            type="button"
            className={`pager__num ${p === page ? 'pager__num--active' : ''}`}
            onClick={() => go(p)}
            aria-current={p === page ? 'page' : undefined}
          >
            {p}
          </button>
        ))}
        {end < totalPages && (
          <>
            {end < totalPages - 1 && <span className="pager__ellipsis">…</span>}
            <button type="button" className="pager__num" onClick={() => go(totalPages)}>
              {totalPages}
            </button>
          </>
        )}
        <button
          type="button"
          className="pager__btn"
          onClick={() => go(page + 1)}
          disabled={page >= totalPages}
          aria-label="Next page"
        >
          <FiChevronRight size={14} />
        </button>
      </div>
    </nav>
  );
}
