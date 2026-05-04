/**
 * Display helpers — kept tiny and pure so they're safe to call from any component.
 */

export const formatPrice = (value) => {
  if (value === null || value === undefined || value === '') return '—';
  const num = typeof value === 'string' ? parseFloat(value) : value;
  if (Number.isNaN(num)) return '—';
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(num);
};

export const formatDate = (isoString) => {
  if (!isoString) return '—';
  return new Date(isoString).toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
};

export const formatDateTime = (isoString) => {
  if (!isoString) return '—';
  return new Date(isoString).toLocaleString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const truncate = (str, n = 80) =>
  str && str.length > n ? `${str.slice(0, n)}…` : str;

export const calcDiscountPercent = (original, effective) => {
  const o = parseFloat(original);
  const e = parseFloat(effective);
  if (!o || Number.isNaN(o) || Number.isNaN(e)) return 0;
  return Math.round((1 - e / o) * 100);
};
