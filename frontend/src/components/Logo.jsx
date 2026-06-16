/**
 * Logo — Woodmark brand lockup (icon mark + wordmark).
 *
 * Pure inline SVG + text, so it scales crisply and needs no raster asset.
 *   variant="default"  → navy wordmark (light backgrounds: navbar)
 *   variant="inverse"  → white wordmark (dark backgrounds: footer)
 *   withTagline        → shows "CRAFTED FOR LIVING" under the wordmark
 *
 * The mark is a navy rounded square with three orange "plank/grain" bars,
 * evoking stacked timber — the furniture/wood identity.
 */
import './Logo.css';

export function LogoMark({ size = 34, className = '' }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 64 64"
      fill="none"
      className={className}
      aria-hidden="true"
    >
      <rect width="64" height="64" rx="15" fill="var(--color-brand)" />
      <rect x="15" y="17" width="34" height="5.4" rx="2.7" fill="var(--color-accent)" />
      <rect x="15" y="29.3" width="34" height="5.4" rx="2.7" fill="var(--color-accent)" opacity="0.82" />
      <rect x="15" y="41.6" width="34" height="5.4" rx="2.7" fill="var(--color-accent)" opacity="0.64" />
    </svg>
  );
}

export default function Logo({
  variant = 'default',
  withTagline = false,
  markSize = 34,
  className = '',
}) {
  return (
    <span className={`wm-logo wm-logo--${variant} ${className}`.trim()}>
      <LogoMark size={markSize} className="wm-logo__mark" />
      <span className="wm-logo__lockup">
        <span className="wm-logo__word">
          Wood<span className="wm-logo__accent">mark</span>
        </span>
        {withTagline && <span className="wm-logo__tagline">Crafted for living</span>}
      </span>
    </span>
  );
}
