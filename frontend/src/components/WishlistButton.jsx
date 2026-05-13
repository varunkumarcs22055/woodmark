/**
 * WishlistButton — heart icon with optimistic toggle.
 *
 * Renders a stub when the user isn't logged in; clicking it nudges them to
 * sign in via toast (rather than failing silently).
 */
import { useState, useEffect } from 'react';
import { FiHeart } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { fetchWishlist, toggleWishlist } from '../api';
import { useAuth } from '../context/AuthContext';
import './WishlistButton.css';

// Small in-memory cache so multiple buttons on the same page don't all
// hit /api/wishlist/ — keyed by user.id, populated on first call.
const _cache = { userId: null, ids: new Set() };

async function loadIntoCache(userId) {
  if (_cache.userId === userId) return _cache.ids;
  try {
    const data = await fetchWishlist();
    const items = Array.isArray(data) ? data : (data.results || []);
    _cache.ids = new Set(items.map((it) => it.product_detail?.id ?? it.product));
    _cache.userId = userId;
  } catch {
    _cache.ids = new Set();
  }
  return _cache.ids;
}

export default function WishlistButton({ productId, size = 18 }) {
  const { user } = useAuth();
  const [on, setOn] = useState(false);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!user) {
      setOn(false);
      return;
    }
    loadIntoCache(user.id).then((ids) => setOn(ids.has(productId)));
  }, [user, productId]);

  const click = async (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (!user) {
      toast.error('Sign in to save items.');
      return;
    }
    if (busy) return;
    setBusy(true);
    const next = !on;
    setOn(next); // optimistic
    try {
      await toggleWishlist(productId, next);
      if (next) _cache.ids.add(productId);
      else _cache.ids.delete(productId);
      toast.success(next ? 'Added to wishlist.' : 'Removed.');
    } catch {
      setOn(!next); // rollback
      toast.error('Wishlist update failed.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <button
      type="button"
      className={`wishlist-btn ${on ? 'wishlist-btn--on' : ''}`}
      onClick={click}
      aria-label={on ? 'Remove from wishlist' : 'Save to wishlist'}
      disabled={busy}
    >
      <FiHeart size={size} fill={on ? 'currentColor' : 'none'} />
    </button>
  );
}
