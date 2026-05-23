"""
List (and optionally delete) Cloudinary assets that are no longer
referenced by any ProductMedia row or Banner row.

Why this exists:
  Even with pre_save + post_delete signals, orphans can sneak in via:
    * race conditions (upload succeeds, DB save fails)
    * direct dashboard uploads
    * historical data from before signals were wired
  This sweep is the safety net.

Usage:
  python manage.py cloudinary_orphans                  # dry-run, list only
  python manage.py cloudinary_orphans --delete         # actually destroy
  python manage.py cloudinary_orphans --prefix banners # narrow the scan
"""
from django.core.management.base import BaseCommand

from services import cloudinary as cdn
from products.models import ProductMedia
from cms.models import Banner


def _live_public_ids() -> set[str]:
    """Every public_id currently referenced by a DB row."""
    ids: set[str] = set()
    for m in ProductMedia.objects.all().only('file'):
        pid = getattr(m.file, 'public_id', None) or (str(m.file) if m.file else '')
        if pid:
            ids.add(pid)
    for b in Banner.objects.all().only('image'):
        pid = getattr(b.image, 'public_id', None) or (str(b.image) if b.image else '')
        if pid:
            ids.add(pid)
    return ids


class Command(BaseCommand):
    help = 'Find Cloudinary assets not referenced by any DB row.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--prefix', default='furnishop/',
            help='Cloudinary prefix to scan (default: furnishop/).',
        )
        parser.add_argument(
            '--delete', action='store_true',
            help='Actually destroy orphans (default: dry-run).',
        )
        parser.add_argument(
            '--max', type=int, default=2000,
            help='Cap on assets scanned (default: 2000).',
        )

    def handle(self, *args, **opts):
        if not cdn.is_configured():
            self.stdout.write(self.style.ERROR(
                'Cloudinary is not configured. Set CLOUDINARY_* env vars.'))
            return

        prefix = opts['prefix']
        do_delete = opts['delete']
        max_assets = opts['max']

        self.stdout.write(f'Scanning Cloudinary prefix "{prefix}" '
                          f'(max {max_assets})...')
        cloud_ids = set(cdn.list_assets(prefix, max_assets=max_assets))
        self.stdout.write(f'  found {len(cloud_ids)} assets on Cloudinary')

        live_ids = _live_public_ids()
        self.stdout.write(f'  found {len(live_ids)} referenced in DB')

        orphans = sorted(cloud_ids - live_ids)
        self.stdout.write(self.style.WARNING(
            f'  -> {len(orphans)} orphans'))

        if not orphans:
            return

        for pid in orphans:
            self.stdout.write(f'    {pid}')

        if not do_delete:
            self.stdout.write(self.style.NOTICE(
                'Dry-run. Re-run with --delete to remove.'))
            return

        destroyed = 0
        for pid in orphans:
            if cdn.destroy(pid, kind='image'):
                destroyed += 1
        self.stdout.write(self.style.SUCCESS(
            f'Destroyed {destroyed}/{len(orphans)} orphans.'))
