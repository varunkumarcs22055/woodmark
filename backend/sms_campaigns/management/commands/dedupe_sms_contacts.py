"""
One-off cleanup for SMS contacts that share the same phone after
normalisation (e.g. one row at '9876543210' and another at
'+919876543210' — both normalise to '+919876543210').

Usage:
  python manage.py dedupe_sms_contacts          # dry-run, prints what would merge
  python manage.py dedupe_sms_contacts --apply  # actually delete dup rows

Strategy:
  - Re-normalise every Contact.phone in memory.
  - Group rows by normalised phone.
  - For each group with >1 row: keep the OLDEST (lowest id), merge the
    name/tag from later rows into it, delete the others.
"""
from collections import defaultdict
from django.core.management.base import BaseCommand
from sms_campaigns.models import Contact, normalize_phone


class Command(BaseCommand):
    help = 'Find and merge SMS contacts that share the same normalised phone.'

    def add_arguments(self, parser):
        parser.add_argument('--apply', action='store_true',
                            help='Actually delete duplicate rows (default: dry-run).')

    def handle(self, *args, **opts):
        apply = opts['apply']
        groups = defaultdict(list)
        for c in Contact.objects.all().order_by('id'):
            groups[normalize_phone(c.phone)].append(c)

        dup_groups = [g for g in groups.values() if len(g) > 1]
        if not dup_groups:
            self.stdout.write(self.style.SUCCESS('No duplicates found.'))
            return

        self.stdout.write(self.style.WARNING(
            f'Found {len(dup_groups)} duplicate group(s):'))
        merged = 0
        for group in dup_groups:
            keeper = group[0]
            extras = group[1:]
            self.stdout.write(
                f'  {keeper.phone}: keep id={keeper.pk}, '
                f'drop {[c.pk for c in extras]}'
            )
            if apply:
                # Merge any non-empty name/tag from extras into keeper
                # so we don't lose data.
                changed = False
                for c in extras:
                    if not keeper.name and c.name:
                        keeper.name = c.name; changed = True
                    if not keeper.tag and c.tag:
                        keeper.tag = c.tag; changed = True
                # Make sure keeper's phone is the canonical normalised form.
                norm = normalize_phone(keeper.phone)
                if keeper.phone != norm:
                    keeper.phone = norm; changed = True
                if changed:
                    keeper.save(update_fields=['name', 'tag', 'phone'])
                Contact.objects.filter(pk__in=[c.pk for c in extras]).delete()
                merged += len(extras)

        if apply:
            self.stdout.write(self.style.SUCCESS(
                f'Deleted {merged} duplicate row(s).'))
        else:
            self.stdout.write(self.style.NOTICE(
                'Dry run — re-run with --apply to actually delete.'))
