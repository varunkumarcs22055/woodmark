/**
 * CompareContext — up to 4 products held for side-by-side comparison.
 * Persisted to localStorage so the selection survives navigation/refresh.
 */
import { createContext, useContext, useState } from 'react';

const CompareContext = createContext();
const KEY = 'woodmark_compare';
const MAX = 4;

const slim = (p) => ({
  id: p.id,
  name: p.name,
  slug: p.slug,
  price: p.price,
  effective_price: p.effective_price ?? null,
  image_url: p.image_url,
  category_name: p.category_name ?? p.category?.name ?? '',
  material: p.material ?? '',
  color: p.color ?? '',
  brand: p.brand ?? '',
  rating_avg: p.rating_avg ?? 0,
  rating_count: p.rating_count ?? 0,
  in_stock: p.in_stock ?? (p.stock ?? 0) > 0,
  warranty: p.warranty ?? '',
  dimensions: p.dimensions ?? '',
});

const load = () => {
  try {
    const raw = localStorage.getItem(KEY);
    const arr = raw ? JSON.parse(raw) : [];
    return Array.isArray(arr) ? arr.filter((p) => p && p.id) : [];
  } catch {
    return [];
  }
};

export function CompareProvider({ children }) {
  const [items, setItems] = useState(load);

  const persist = (next) => {
    setItems(next);
    try { localStorage.setItem(KEY, JSON.stringify(next)); } catch { /* ignore */ }
    return next;
  };

  const isComparing = (id) => items.some((p) => p.id === id);

  // Returns false if the list is already full (caller can toast).
  const toggleCompare = (product) => {
    if (isComparing(product.id)) {
      persist(items.filter((p) => p.id !== product.id));
      return true;
    }
    if (items.length >= MAX) return false;
    persist([...items, slim(product)]);
    return true;
  };

  const removeCompare = (id) => persist(items.filter((p) => p.id !== id));
  const clearCompare = () => persist([]);

  return (
    <CompareContext.Provider
      value={{ compareItems: items, compareCount: items.length, max: MAX,
               isComparing, toggleCompare, removeCompare, clearCompare }}
    >
      {children}
    </CompareContext.Provider>
  );
}

export function useCompare() {
  const ctx = useContext(CompareContext);
  if (!ctx) throw new Error('useCompare must be used within a CompareProvider');
  return ctx;
}
