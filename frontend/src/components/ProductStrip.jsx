/**
 * ProductStrip — a titled horizontal carousel of ProductCards.
 * Reused by "You may also like" (related) and "Recently viewed".
 * Renders nothing when there are no products.
 */
import { useRef } from 'react';
import { FiChevronLeft, FiChevronRight } from 'react-icons/fi';
import ProductCard from './ProductCard';
import './ProductStrip.css';

export default function ProductStrip({ title, eyebrow, products }) {
  const trackRef = useRef(null);
  if (!products || products.length === 0) return null;

  const scrollBy = (dir) => {
    const el = trackRef.current;
    if (el) el.scrollBy({ left: dir * (el.clientWidth * 0.8), behavior: 'smooth' });
  };

  return (
    <section className="product-strip">
      <div className="product-strip__head">
        <div>
          {eyebrow && <span className="section-tag">{eyebrow}</span>}
          <h2 className="product-strip__title">{title}</h2>
        </div>
        {products.length > 3 && (
          <div className="product-strip__nav">
            <button type="button" aria-label="Scroll left" onClick={() => scrollBy(-1)}>
              <FiChevronLeft size={18} />
            </button>
            <button type="button" aria-label="Scroll right" onClick={() => scrollBy(1)}>
              <FiChevronRight size={18} />
            </button>
          </div>
        )}
      </div>
      <div className="product-strip__track" ref={trackRef}>
        {products.map((p) => (
          <div className="product-strip__item" key={p.id}>
            <ProductCard product={p} />
          </div>
        ))}
      </div>
    </section>
  );
}
