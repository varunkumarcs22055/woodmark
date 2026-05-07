import { useState, useEffect, useCallback } from 'react';
import { FiX, FiChevronLeft, FiChevronRight } from 'react-icons/fi';
import './MediaLightbox.css';

export default function MediaLightbox({ items, initialIndex = 0, onClose }) {
  const [idx, setIdx] = useState(initialIndex);

  const prev = useCallback(() => setIdx((i) => (i - 1 + items.length) % items.length), [items.length]);
  const next = useCallback(() => setIdx((i) => (i + 1) % items.length), [items.length]);

  useEffect(() => {
    const onKey = (e) => {
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowLeft') prev();
      if (e.key === 'ArrowRight') next();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose, prev, next]);

  const active = items[idx];

  return (
    <div className="mlb-overlay" onClick={onClose} role="dialog" aria-modal="true">
      <div className="mlb-content" onClick={(e) => e.stopPropagation()}>
        <button className="mlb-close" onClick={onClose} aria-label="Close">
          <FiX size={24} />
        </button>

        {items.length > 1 && (
          <button className="mlb-nav mlb-nav--prev" onClick={prev} aria-label="Previous">
            <FiChevronLeft size={28} />
          </button>
        )}

        <div className="mlb-media">
          {active.kind === 'video' ? (
            <video src={active.url} controls className="mlb-media__el" />
          ) : (
            <img src={active.url} alt={active.alt_text || ''} className="mlb-media__el" />
          )}
        </div>

        {items.length > 1 && (
          <button className="mlb-nav mlb-nav--next" onClick={next} aria-label="Next">
            <FiChevronRight size={28} />
          </button>
        )}

        {items.length > 1 && (
          <div className="mlb-counter">{idx + 1} / {items.length}</div>
        )}
      </div>
    </div>
  );
}
