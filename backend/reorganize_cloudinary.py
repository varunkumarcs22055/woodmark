"""
One-off: reorganize existing flat `furnishop/products/<slug>` assets into
per-product folders `furnishop/products/<slug>/main`.

Cloudinary's `rename()` API moves an asset to a new public_id; the old
URL stops working but the new one returns the same image. We then update
ProductMedia.file + Product.image_url to point at the new public_id.
"""
import django, os, re

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.conf import settings
import cloudinary, cloudinary.api, cloudinary.uploader
from products.models import Product, ProductMedia

cloudinary.config(
    cloud_name=settings.CLOUDINARY_STORAGE['CLOUD_NAME'],
    api_key=settings.CLOUDINARY_STORAGE['API_KEY'],
    api_secret=settings.CLOUDINARY_STORAGE['API_SECRET'],
)


def _slug(text):
    s = re.sub(r'[^a-z0-9]+', '-', (text or '').lower()).strip('-')
    return s[:60] or 'item'


def reorganize_products():
    moved, skipped, failed = 0, 0, 0
    for p in Product.objects.all():
        slug = _slug(p.slug or p.name)
        old_public_id = f'furnishop/products/{slug}'
        new_public_id = f'furnishop/products/{slug}/main'

        # Skip if no Cloudinary URL configured on this product.
        if not (p.image_url and 'res.cloudinary.com' in p.image_url):
            skipped += 1
            continue
        # Skip if it already lives in a per-product folder.
        if f'/products/{slug}/' in p.image_url:
            print(f'  [skip] {p.name} already in per-product folder')
            skipped += 1
            continue

        try:
            result = cloudinary.uploader.rename(old_public_id, new_public_id,
                                                overwrite=True)
            new_url = result.get('secure_url') or result.get('url')
        except Exception as e:
            print(f'  [fail] {p.name} — {e}')
            failed += 1
            continue

        # Repoint DB rows at the new public_id.
        ProductMedia.objects.filter(product=p, file=old_public_id) \
            .update(file=new_public_id)
        # Some rows might have already been created with `f` (no public id);
        # also update any whose file column already contains the old slug.
        ProductMedia.objects.filter(product=p) \
            .filter(file__icontains=f'/{slug}') \
            .exclude(file__contains=new_public_id) \
            .update(file=new_public_id)
        Product.objects.filter(pk=p.pk).update(image_url=new_url)
        print(f'  [ok]   {p.name} -> {new_url}')
        moved += 1

    return moved, skipped, failed


if __name__ == '__main__':
    print('Reorganizing products into per-product folders...')
    m, s, f = reorganize_products()
    print(f'\nSummary: {m} moved, {s} skipped, {f} failed')
    print('Open Cloudinary Media Library -> furnishop -> products -> '
          '<slug folder> to see each one.')
