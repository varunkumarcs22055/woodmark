/**
 * useScrollReveal — reveal an element when it scrolls into view.
 *
 * Returns a ref to attach to the target. The element starts in its hidden
 * state (`.reveal`, styled in index.css) and gains `.is-visible` the first
 * time it intersects the viewport. It's a one-shot: once revealed we stop
 * observing so the animation never replays on scroll-up.
 *
 * Honors prefers-reduced-motion — when the user has reduced motion enabled
 * the element is revealed immediately with no transition (the CSS guard in
 * index.css also flattens the transition itself).
 */
import { useEffect, useRef } from 'react';

const prefersReducedMotion = () =>
  typeof window !== 'undefined' &&
  window.matchMedia &&
  window.matchMedia('(prefers-reduced-motion: reduce)').matches;

export default function useScrollReveal({ threshold = 0.15, rootMargin = '0px 0px -10% 0px' } = {}) {
  const ref = useRef(null);

  useEffect(() => {
    const node = ref.current;
    if (!node) return undefined;

    // Reduced motion or no IntersectionObserver support → show immediately.
    if (prefersReducedMotion() || typeof IntersectionObserver === 'undefined') {
      node.classList.add('is-visible');
      return undefined;
    }

    const observer = new IntersectionObserver(
      (entries, obs) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible');
            obs.unobserve(entry.target);
          }
        });
      },
      { threshold, rootMargin },
    );

    observer.observe(node);
    return () => observer.disconnect();
  }, [threshold, rootMargin]);

  return ref;
}
