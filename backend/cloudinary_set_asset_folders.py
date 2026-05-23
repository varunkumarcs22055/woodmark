"""
Dynamic-folder accounts need the `asset_folder` field set explicitly
(separate from public_id) for the Media Library to render the folder
tree. Walks every furnishop/* asset and writes its asset_folder so the
dashboard shows:

    Home
    └── furnishop
        ├── products
        │   ├── samir
        │   ├── oslo-velvet-sofa
        │   …
        └── banners
"""
import django, os

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.conf import settings
import cloudinary, cloudinary.api

cloudinary.config(
    cloud_name=settings.CLOUDINARY_STORAGE['CLOUD_NAME'],
    api_key=settings.CLOUDINARY_STORAGE['API_KEY'],
    api_secret=settings.CLOUDINARY_STORAGE['API_SECRET'],
)


def desired_folder(public_id):
    """
    public_id `furnishop/products/samir/main` → asset_folder `furnishop/products/samir`
    public_id `furnishop/banners/welcome-1`   → asset_folder `furnishop/banners`
    """
    parts = public_id.rsplit('/', 1)
    return parts[0] if len(parts) == 2 else ''


def main():
    # Page through everything under furnishop/
    next_cursor = None
    moved = 0
    skipped = 0
    while True:
        kwargs = dict(type='upload', prefix='furnishop/', max_results=100)
        if next_cursor:
            kwargs['next_cursor'] = next_cursor
        result = cloudinary.api.resources(**kwargs)
        for r in result.get('resources', []):
            pid = r['public_id']
            target = desired_folder(pid)
            current = r.get('asset_folder') or ''
            if current == target:
                skipped += 1
                continue
            try:
                cloudinary.api.update(pid, asset_folder=target)
                print(f'  [ok] {pid}  ->  folder={target}')
                moved += 1
            except Exception as e:
                print(f'  [fail] {pid}: {repr(e)[:200]}')
        next_cursor = result.get('next_cursor')
        if not next_cursor:
            break
    print(f'\nDone. Moved {moved}, already in place {skipped}.')


if __name__ == '__main__':
    main()
