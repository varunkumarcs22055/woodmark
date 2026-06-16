"""
One-off migration: pull every existing product/banner image (currently
external URLs like Unsplash or local /cat_*.png) into your Cloudinary
account so they're visible in the Media Library and served from the CDN
going forward.

Idempotent: skips anything already hosted on res.cloudinary.com.
Meaningful public IDs: products → woodmark/products/<slug>,
banners → woodmark/banners/<slug>, so the Media Library is readable.
"""
import django, os, sys, requests, time

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.core.files.base import ContentFile
from django.conf import settings
import cloudinary
import cloudinary.uploader
from products.models import Product, ProductMedia
from cms.models import Banner

cloudinary.config(
    cloud_name=settings.CLOUDINARY_STORAGE['CLOUD_NAME'],
    api_key=settings.CLOUDINARY_STORAGE['API_KEY'],
    api_secret=settings.CLOUDINARY_STORAGE['API_SECRET'],
)


def _is_already_cloudinary(url):
    return 'res.cloudinary.com' in (url or '')


def _slug(text):
    import re
    s = re.sub(r'[^a-z0-9]+', '-', (text or '').lower()).strip('-')
    return s[:60] or 'item'


def _fetch_bytes(url):
    if not url:
        return None
    # Static files served by Vite (e.g. /cat_furniture.png) — read from disk.
    if url.startswith('/'):
        candidates = [
            os.path.join(settings.BASE_DIR, '..', 'frontend', 'public', url.lstrip('/')),
            os.path.join(settings.BASE_DIR, 'media', url.lstrip('/')),
        ]
        for path in candidates:
            if os.path.exists(path):
                with open(path, 'rb') as f:
                    return f.read()
        return None
    # Remote URL — pull bytes.
    try:
        r = requests.get(url, timeout=20)
        r.raise_for_status()
        return r.content
    except Exception as e:
        print(f'    fetch failed: {e}')
        return None


def upload_to_cloudinary(blob, public_id):
    """Upload bytes, return the secure_url."""
    result = cloudinary.uploader.upload(
        blob,
        public_id=public_id,
        overwrite=False,
        resource_type='image',
    )
    return result.get('secure_url') or result.get('url')


def migrate_products():
    print('\n=== Migrating product images ===')
    count_uploaded, count_skipped, count_failed = 0, 0, 0
    for p in Product.objects.all():
        # Skip if already has Cloudinary-hosted ProductMedia
        if p.media.filter(file__icontains='cloudinary').exists() \
                or _is_already_cloudinary(p.image_url):
            print(f'  [skip] {p.name} (already on Cloudinary)')
            count_skipped += 1
            continue
        if not p.image_url:
            print(f'  [skip] {p.name} (no image_url)')
            count_skipped += 1
            continue

        blob = _fetch_bytes(p.image_url)
        if not blob:
            print(f'  [fail] {p.name} — could not fetch {p.image_url}')
            count_failed += 1
            continue

        public_id = f'woodmark/products/{_slug(p.slug or p.name)}'
        try:
            cdn_url = upload_to_cloudinary(blob, public_id)
        except Exception as e:
            print(f'  [fail] {p.name} — upload error: {e}')
            count_failed += 1
            continue

        # Create the canonical ProductMedia row and update the legacy image_url.
        ProductMedia.objects.create(
            product=p, kind='image',
            file=public_id,           # Cloudinary backend reads this as a public id
            is_primary=True,
            alt_text=p.name[:200],
        )
        Product.objects.filter(pk=p.pk).update(image_url=cdn_url)
        print(f'  [ok]   {p.name} -> {cdn_url}')
        count_uploaded += 1
        time.sleep(0.15)   # be polite to Cloudinary free-tier rate limits

    return count_uploaded, count_skipped, count_failed


def migrate_banners():
    print('\n=== Migrating banner images ===')
    count_uploaded, count_skipped, count_failed = 0, 0, 0
    for b in Banner.objects.all():
        if b.image:                                       # Cloudinary field already set
            print(f'  [skip] Banner #{b.id} "{b.title}" — already has Cloudinary image')
            count_skipped += 1
            continue
        if not b.image_url:
            print(f'  [skip] Banner #{b.id} "{b.title}" — no source url')
            count_skipped += 1
            continue
        if _is_already_cloudinary(b.image_url):
            print(f'  [skip] Banner #{b.id} — image_url already points at Cloudinary')
            count_skipped += 1
            continue

        blob = _fetch_bytes(b.image_url)
        if not blob:
            print(f'  [fail] Banner #{b.id} "{b.title}" — could not fetch {b.image_url}')
            count_failed += 1
            continue

        public_id = f'woodmark/banners/{_slug(b.title)}-{b.id}'
        try:
            cdn_url = upload_to_cloudinary(blob, public_id)
        except Exception as e:
            print(f'  [fail] Banner #{b.id} — upload error: {e}')
            count_failed += 1
            continue

        b.image = public_id                                # CloudinaryField accepts public_id string
        b.image_url = cdn_url                              # keep image_url in sync for legacy reads
        b.save(update_fields=['image', 'image_url', 'updated_at'])
        print(f'  [ok]   Banner #{b.id} "{b.title}" -> {cdn_url}')
        count_uploaded += 1
        time.sleep(0.15)

    return count_uploaded, count_skipped, count_failed


if __name__ == '__main__':
    pu, ps, pf = migrate_products()
    bu, bs, bf = migrate_banners()
    print('\n=== Summary ===')
    print(f'  Products: {pu} uploaded, {ps} skipped, {pf} failed')
    print(f'  Banners:  {bu} uploaded, {bs} skipped, {bf} failed')
    print('\nOpen https://console.cloudinary.com → Media Library → "woodmark"')
    print('folder to see them all.')
