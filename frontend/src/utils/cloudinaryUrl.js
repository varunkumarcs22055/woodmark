/**
 * Frontend Cloudinary URL helpers — mirror of `backend/services/cloudinary.py`.
 *
 * Why this file exists:
 *   * The backend serializes a Cloudinary `secure_url` to the frontend, but
 *     that URL is one fixed size. For card grids we want a 600x800 fill, for
 *     hero banners we want 1600x700, for thumbnails 200x200. Re-deriving
 *     those URLs from the public_id is essentially free (Cloudinary builds
 *     the derivative on first request and caches it forever).
 *   * `<img srcset>` lets the browser pick the right width — saves ~40%
 *     bandwidth on mobile vs. shipping the 1600w hero to every viewport.
 *
 * Usage:
 *   import { presetUrl, srcSet } from '@/utils/cloudinaryUrl';
 *   <img src={presetUrl(publicId, 'card')} srcSet={srcSet(publicId)} />
 */

const CLOUD_NAME =
  import.meta.env.VITE_CLOUDINARY_CLOUD_NAME || 'de5dq6nbu';

const PRESETS = {
  thumb: 'w_200,h_200,c_fill,q_auto,f_auto',
  card: 'w_600,h_800,c_fill,q_auto,f_auto',
  hero: 'w_1600,h_700,c_fill,q_auto,f_auto',
};

/**
 * Extract a public_id from either:
 *   - a bare public_id ('furnishop/products/samir/main')
 *   - a full Cloudinary URL ('https://res.cloudinary.com/.../upload/v123/x/y.jpg')
 *
 * Returns '' if the input doesn't look like a Cloudinary asset.
 */
export function extractPublicId(input) {
  if (!input) return '';
  if (typeof input !== 'string') return '';
  if (!input.includes('://')) return input;          // already a public_id
  const m = input.match(/\/upload\/(?:v\d+\/)?(.+?)(?:\.[a-z0-9]+)?$/i);
  return m ? m[1] : '';
}

/**
 * Build a Cloudinary delivery URL with explicit transformations.
 * `transforms` is a comma-separated string of Cloudinary transform params,
 * e.g. 'w_600,h_800,c_fill,q_auto,f_auto'.
 */
export function transformUrl(input, transforms = 'q_auto,f_auto') {
  const pid = extractPublicId(input);
  if (!pid) return typeof input === 'string' ? input : '';
  return `https://res.cloudinary.com/${CLOUD_NAME}/image/upload/${transforms}/${pid}`;
}

/**
 * Build a URL using one of the named presets (thumb/card/hero).
 * Falls back to the raw URL if the preset name is unknown.
 */
export function presetUrl(input, preset) {
  const spec = PRESETS[preset];
  if (!spec) return typeof input === 'string' ? input : '';
  return transformUrl(input, spec);
}

/**
 * Build a responsive srcset string for `<img srcSet>` — lets the browser
 * pick the smallest-sufficient width for the user's viewport.
 */
export function srcSet(
  input,
  widths = [400, 800, 1200, 1600],
) {
  const pid = extractPublicId(input);
  if (!pid) return '';
  return widths
    .map((w) => `${transformUrl(pid, `w_${w},c_scale,q_auto,f_auto`)} ${w}w`)
    .join(', ');
}
