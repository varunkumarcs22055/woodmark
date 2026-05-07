import { useState, useCallback } from 'react';
import { FiPlay } from 'react-icons/fi';
import MediaLightbox from './MediaLightbox';
import './ProductGallery.css';

export default function ProductGallery({ media = [], fallbackUrl = '' }) {
  const items = media.length > 0 ? media : (fallbackUrl ? [{ id: 0, kind: 'image', url: fallbackUrl, alt_text: '' }] : []);
  const [activeIdx, setActiveIdx] = useState(0);
  const [lightboxOpen, setLightboxOpen] = useState(false);

  const active = items[activeIdx];

  const openLightbox = useCallback(() => {
    if (items.length > 0) setLightboxOpen(true);
  }, [items.length]);

  if (items.length === 0) return null;

  return (
    <div className="product-gallery">
      {/* Hero */}
      <div className="pg-hero" onClick={openLightbox} role="button" tabIndex={0}
        onKeyDown={(e) => e.key === 'Enter' && openLightbox()}
        aria-label="Open image viewer"
      >
        {active.kind === 'video' ? (
          <video
            src={active.url}
            className="pg-hero__media"
            controls
            onClick={(e) => e.stopPropagation()}
          />
        ) : (
          <img src={active.url} alt={active.alt_text || ''} className="pg-hero__media" />
        )}
        {active.kind === 'video' && (
          <div className="pg-hero__play-overlay">
            <FiPlay size={40} />
          </div>
        )}
        {items.length > 1 && (
          <span className="pg-hero__hint">Click to enlarge</span>
        )}
      </div>

      {/* Thumbnails */}
      {items.length > 1 && (
        <div className="pg-thumbs">
          {items.map((item, i) => (
            <button
              key={item.id ?? i}
              className={`pg-thumb ${i === activeIdx ? 'pg-thumb--active' : ''}`}
              onClick={() => setActiveIdx(i)}
              aria-label={`View media ${i + 1}`}
            >
              {item.kind === 'video' ? (
                <div className="pg-thumb__video-placeholder">
                  <FiPlay size={18} />
                </div>
              ) : (
                <img src={item.url} alt={item.alt_text || ''} />
              )}
            </button>
          ))}
        </div>
      )}

      {lightboxOpen && (
        <MediaLightbox
          items={items}
          initialIndex={activeIdx}
          onClose={() => setLightboxOpen(false)}
        />
      )}
    </div>
  );
}
