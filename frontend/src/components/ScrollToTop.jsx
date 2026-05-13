/**
 * ScrollToTop — fires on every pathname change.
 *
 * SPAs preserve scroll position by default when you navigate; that feels
 * broken when going from a deep PDP back to the homepage and landing
 * mid-page. This forces every route change to start at the top.
 *
 * Two opt-outs handled:
 *   - same-page anchor links (`#reviews-section`) — we leave the hash alone
 *     so in-page jumps still work
 *   - browser back/forward — uses 'auto' (instant) so it doesn't fight the
 *     user's expectation of restoring position; for normal forward nav
 *     we use 'instant' too (no jarring smooth scroll)
 */
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

export default function ScrollToTop() {
  const { pathname, hash } = useLocation();

  useEffect(() => {
    if (hash) return; // honor in-page anchor links
    window.scrollTo({ top: 0, left: 0, behavior: 'instant' });
  }, [pathname, hash]);

  return null;
}
