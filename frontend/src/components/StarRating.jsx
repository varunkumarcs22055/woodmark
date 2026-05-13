/**
 * StarRating — display + interactive star widget.
 *
 * Display:    <StarRating value={4.2} count={1248} />
 * Interactive: <StarRating value={picked} onChange={setPicked} interactive />
 */
import { useState } from 'react';
import './StarRating.css';

export default function StarRating({
  value = 0,
  count,
  size = 14,
  interactive = false,
  onChange,
  showValue = true,
}) {
  const [hover, setHover] = useState(null);
  const display = hover ?? Number(value) ?? 0;

  return (
    <span className={`star-rating ${interactive ? 'star-rating--interactive' : ''}`}>
      <span className="star-rating__stars" style={{ '--star-size': `${size}px` }}>
        {[1, 2, 3, 4, 5].map((n) => {
          const filled = display >= n;
          const half = !filled && display > n - 1;
          return (
            <button
              key={n}
              type="button"
              className={`star ${filled ? 'star--filled' : half ? 'star--half' : ''}`}
              onMouseEnter={() => interactive && setHover(n)}
              onMouseLeave={() => interactive && setHover(null)}
              onClick={() => interactive && onChange?.(n)}
              tabIndex={interactive ? 0 : -1}
              aria-label={interactive ? `Rate ${n} stars` : null}
              disabled={!interactive}
            >
              ★
            </button>
          );
        })}
      </span>
      {showValue && Number(value) > 0 && (
        <span className="star-rating__value">
          {Number(value).toFixed(1)}
        </span>
      )}
      {typeof count === 'number' && count > 0 && (
        <span className="star-rating__count">
          ({count.toLocaleString()})
        </span>
      )}
    </span>
  );
}
