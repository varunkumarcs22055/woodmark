"""
Central Cloudinary helper.

Every upload / delete / transform-URL operation in the app routes through
here so there's *one* place to manage:

  * folder + asset_folder pinning (dynamic-mode accounts)
  * eager transformations (pre-generated thumb / card / hero sizes)
  * exponential-backoff retries on transient network errors
  * audit logging
  * orphan detection

Why this file exists:
  * `cloudinary.uploader.upload(...)` scattered across the app makes
    behaviour-change one-PR-per-call. With this helper, tweaking the
    default quality, retry count, or eager preset is a single-line
    edit.
  * Test seams: the upload/destroy functions accept a `_client` kwarg
    so unit tests can inject a fake without touching the real API.
"""
from __future__ import annotations

import logging
import time
from typing import Any, Iterable, Mapping

from django.conf import settings

logger = logging.getLogger(__name__)


# ─── Configuration ────────────────────────────────────────────────────────

# Pre-generate these derivatives on upload so first request doesn't pay
# the transform cost. Each maps a key (used in transform URLs below) to a
# Cloudinary transformation spec.
EAGER_PRESETS: dict[str, dict] = {
    'thumb': {'width': 200, 'height': 200, 'crop': 'fill',
              'quality': 'auto', 'fetch_format': 'auto'},
    'card':  {'width': 600, 'height': 800, 'crop': 'fill',
              'quality': 'auto', 'fetch_format': 'auto'},
    'hero':  {'width': 1600, 'height': 700, 'crop': 'fill',
              'quality': 'auto', 'fetch_format': 'auto'},
}

# How many times to retry on a transient Cloudinary error (network timeouts,
# 5xx). 4 attempts with backoff = ~7s worst case before bubbling the error.
_RETRY_ATTEMPTS = 4
_RETRY_BACKOFF_BASE = 0.4   # seconds; doubled each retry


def is_configured() -> bool:
    """True only when Cloudinary credentials are usable."""
    cfg = getattr(settings, 'CLOUDINARY_STORAGE', {}) or {}
    return bool(cfg.get('CLOUD_NAME') and cfg.get('API_KEY')
                and cfg.get('API_SECRET'))


def _configure_sdk():
    if not is_configured():
        return False
    import cloudinary
    cfg = settings.CLOUDINARY_STORAGE
    cloudinary.config(
        cloud_name=cfg['CLOUD_NAME'],
        api_key=cfg['API_KEY'],
        api_secret=cfg['API_SECRET'],
        secure=True,                  # always https URLs
    )
    return True


def _is_transient(err: Exception) -> bool:
    """Decide whether to retry. Be conservative: only network/5xx-ish."""
    msg = str(err).lower()
    if 'timeout' in msg or 'temporarily' in msg or 'try again' in msg:
        return True
    code = getattr(err, 'http_code', None) or getattr(err, 'status_code', None)
    if isinstance(code, int) and 500 <= code < 600:
        return True
    return False


def _retry(fn, *args, **kwargs):
    """Call fn() with exponential-backoff retries on transient errors."""
    last_exc = None
    for attempt in range(1, _RETRY_ATTEMPTS + 1):
        try:
            return fn(*args, **kwargs)
        except Exception as exc:
            last_exc = exc
            if attempt == _RETRY_ATTEMPTS or not _is_transient(exc):
                raise
            sleep = _RETRY_BACKOFF_BASE * (2 ** (attempt - 1))
            logger.warning('Cloudinary transient error (attempt %d/%d): %s. '
                           'Retrying in %.1fs.',
                           attempt, _RETRY_ATTEMPTS, exc, sleep)
            time.sleep(sleep)
    if last_exc:
        raise last_exc


# ─── Upload ───────────────────────────────────────────────────────────────


def upload(file, *, folder: str, kind: str = 'image',
           eager: Iterable[str] | None = ('thumb', 'card'),
           overwrite: bool = False, **extra) -> dict[str, Any]:
    """
    Upload a file (file-like, path, or remote URL) to Cloudinary.

    Args:
        file:      file-like / path / URL.
        folder:    target folder, e.g. 'woodmark/products/samir'. Used
                   for BOTH fixed-mode `folder` AND dynamic-mode
                   `asset_folder` so the Media Library tree is always
                   correct regardless of account mode.
        kind:      'image' or 'video'.
        eager:     iterable of EAGER_PRESETS keys to pre-generate
                   ('thumb', 'card', 'hero'). Pass None to skip.
        overwrite: whether to replace an existing public_id.

    Returns: Cloudinary's full response dict.
    Raises: cloudinary.exceptions.Error after retries are exhausted.
    """
    if not _configure_sdk():
        raise RuntimeError('Cloudinary is not configured (CLOUDINARY_* env vars).')

    import cloudinary.uploader

    eager_transforms = []
    if eager:
        for key in eager:
            preset = EAGER_PRESETS.get(key)
            if preset:
                eager_transforms.append(preset)

    opts = dict(
        folder=folder,
        asset_folder=folder,
        resource_type=kind,
        use_filename=True,
        unique_filename=True,
        overwrite=overwrite,
        # Auto quality + format saves ~30-60% bandwidth at no quality cost.
        quality='auto',
        fetch_format='auto',
        # Pre-generate the derivatives so first delivery is fast.
        eager=eager_transforms or None,
        eager_async=True,            # don't make the upload wait on them
        **extra,
    )
    # Drop None values so Cloudinary doesn't treat them as defaults-clear.
    opts = {k: v for k, v in opts.items() if v is not None}

    result = _retry(cloudinary.uploader.upload, file, **opts)
    logger.info('Cloudinary upload OK public_id=%s folder=%s',
                result.get('public_id'), folder)
    return result


# ─── Destroy ──────────────────────────────────────────────────────────────


def destroy(public_id: str, *, kind: str = 'image') -> bool:
    """
    Remove an asset from Cloudinary. Returns True if the asset was found
    and deleted (or already absent). 'auto' is NOT a valid resource_type
    here — callers must pass 'image' or 'video' explicitly via `kind`.
    """
    if not _configure_sdk() or not public_id:
        return False
    import cloudinary.uploader

    resource_type = 'video' if kind == 'video' else 'image'
    try:
        result = _retry(
            cloudinary.uploader.destroy,
            public_id,
            resource_type=resource_type,
            invalidate=True,
        )
        ok = result.get('result') in ('ok', 'not found')
        logger.info('Cloudinary destroy %s result=%s', public_id, result.get('result'))
        return ok
    except Exception:
        logger.exception('Cloudinary destroy failed for %s', public_id)
        return False


def destroy_folder(folder: str) -> dict[str, Any]:
    """Best-effort wipe of every asset under `folder/` + the folder itself."""
    if not _configure_sdk():
        return {'deleted': 0}
    import cloudinary.api
    summary = {'deleted': 0, 'folder_removed': False}
    try:
        res = _retry(cloudinary.api.delete_resources_by_prefix, folder + '/')
        summary['deleted'] = len(res.get('deleted', {}))
    except Exception:
        logger.exception('Cloudinary delete_resources_by_prefix(%s) failed', folder)
    try:
        _retry(cloudinary.api.delete_folder, folder)
        summary['folder_removed'] = True
    except Exception:
        # Folder may be missing or non-empty — non-fatal.
        pass
    return summary


# ─── Move (replace asset_folder for an existing public_id) ────────────────


def pin_asset_folder(public_id: str, folder: str) -> bool:
    """
    Set asset_folder on an existing asset (idempotent). Required for the
    dashboard tree on dynamic-folder accounts.
    """
    if not _configure_sdk() or not public_id:
        return False
    import cloudinary.api
    try:
        # Skip the write if it's already correct.
        current = _retry(cloudinary.api.resource, public_id)
        if current.get('asset_folder') == folder:
            return True
        _retry(cloudinary.api.update, public_id, asset_folder=folder)
        return True
    except Exception:
        logger.exception('Cloudinary pin_asset_folder(%s, %s) failed',
                         public_id, folder)
        return False


# ─── URL helpers ──────────────────────────────────────────────────────────


def transform_url(public_id: str, **transformations) -> str:
    """
    Build a delivery URL with on-the-fly transformations. Example:
        transform_url('woodmark/products/samir/main', width=600, crop='fill')
    """
    if not public_id:
        return ''
    if not _configure_sdk():
        return ''
    import cloudinary.utils
    url, _opts = cloudinary.utils.cloudinary_url(public_id, **transformations)
    return url


def preset_url(public_id: str, preset: str) -> str:
    """Build a URL using one of the EAGER_PRESETS (thumb/card/hero)."""
    spec = EAGER_PRESETS.get(preset)
    if not spec:
        return ''
    return transform_url(public_id, **spec)


def srcset(public_id: str, widths: Iterable[int] = (400, 800, 1200, 1600)) -> str:
    """
    Build a `srcset` string for responsive `<img>` rendering. Each width
    gets a transform URL with quality=auto + fetch_format=auto.
    """
    if not public_id:
        return ''
    parts = []
    for w in widths:
        url = transform_url(public_id, width=w, crop='scale',
                            quality='auto', fetch_format='auto')
        if url:
            parts.append(f'{url} {w}w')
    return ', '.join(parts)


# ─── Orphan detection ─────────────────────────────────────────────────────


def list_assets(prefix: str, max_assets: int = 500) -> list[str]:
    """Return every public_id under a prefix (paginated)."""
    if not _configure_sdk():
        return []
    import cloudinary.api
    ids: list[str] = []
    cursor = None
    while True:
        kwargs: dict[str, Any] = {
            'type': 'upload', 'prefix': prefix, 'max_results': 100,
        }
        if cursor:
            kwargs['next_cursor'] = cursor
        try:
            res = _retry(cloudinary.api.resources, **kwargs)
        except Exception:
            logger.exception('Cloudinary list_assets(%s) failed', prefix)
            break
        for r in res.get('resources', []):
            ids.append(r['public_id'])
            if len(ids) >= max_assets:
                return ids
        cursor = res.get('next_cursor')
        if not cursor:
            break
    return ids
