/**
 * Recently-viewed products — persisted to localStorage, newest first.
 *
 * Stores a slim snapshot (the fields ProductCard renders) so the strip can
 * render instantly without re-fetching. Capped at MAX entries.
 */
import { useEffect, useState } from 'react';

const KEY = 'woodmark_recently_viewed';
const MAX = 12;

const slim = (p) => ({
  id: p.id,
  name: p.name,
  slug: p.slug,
  price: p.price,
  effective_price: p.effective_price ?? null,
  discount_applied: p.discount_applied ?? null,
  discount_units_remaining: p.discount_units_remaining ?? null,
  image_url: p.image_url,
  category_name: p.category_name ?? p.category?.name ?? '',
  material: p.material ?? '',
  color: p.color ?? '',
  brand: p.brand ?? '',
  rating_avg: p.rating_avg ?? 0,
  rating_count: p.rating_count ?? 0,
  in_stock: p.in_stock ?? (p.stock ?? 0) > 0,
});

export function getRecentlyViewed() {
  try {
    const raw = localStorage.getItem(KEY);
    const arr = raw ? JSON.parse(raw) : [];
    return Array.isArray(arr) ? arr.filter((p) => p && p.id && p.slug) : [];
  } catch {
    return [];
  }
}

export function addRecentlyViewed(product) {
  if (!product || !product.id) return;
  try {
    const current = getRecentlyViewed().filter((p) => p.id !== product.id);
    const next = [slim(product), ...current].slice(0, MAX);
    localStorage.setItem(KEY, JSON.stringify(next));
    // Let same-tab listeners (the strip) know it changed.
    window.dispatchEvent(new Event('woodmark:recently-viewed'));
  } catch {
    /* quota / disabled storage — non-fatal */
  }
}

/**
 * Hook returning the current recently-viewed list, optionally excluding one
 * product id (e.g. the product you're currently looking at).
 */
export function useRecentlyViewed(excludeId = null) {
  const [items, setItems] = useState(getRecentlyViewed);

  useEffect(() => {
    const refresh = () => setItems(getRecentlyViewed());
    window.addEventListener('woodmark:recently-viewed', refresh);
    window.addEventListener('storage', refresh);
    return () => {
      window.removeEventListener('woodmark:recently-viewed', refresh);
      window.removeEventListener('storage', refresh);
    };
  }, []);

  return excludeId != null ? items.filter((p) => p.id !== excludeId) : items;
}
