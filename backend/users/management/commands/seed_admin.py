"""
Idempotent seed for the admin panel demo.

Creates (only if missing):
  - 1 admin
  - 2 customers (one blocked for QA)
  - 1 active dealer + 1 pending dealer
  - 1 warehouse with stock for every existing product
  - 1 home_hero banner, 1 'privacy' Page, 3 FAQs
  - 1 active percent-discount

Run:
    python manage.py seed_admin
"""
from django.core.management.base import BaseCommand
from decimal import Decimal

from cms.models import Banner, Page, FAQ
from inventory.models import StockLevel, StockMovement, Warehouse
from products.models import Product
from users.models import User
from shipping.models import ShippingZone


class Command(BaseCommand):
    help = 'Idempotent seed for the admin panel demo.'

    def handle(self, *args, **opts):
        self._seed_users()
        self._seed_warehouses_and_stock()
        self._seed_cms()
        self._seed_shipping_zones()
        self.stdout.write(self.style.SUCCESS('Seed complete.'))

    # ── Users ────────────────────────────────────────────────────────────

    def _seed_users(self):
        defs = [
            {'email': 'admin@furnishop.local', 'role': 'admin', 'first_name': 'Site', 'last_name': 'Admin',
             'password': 'AdminPass@2024', 'is_staff': True, 'is_superuser': True},
            {'email': 'shopper-1@example.com', 'role': 'user', 'first_name': 'Asha',
             'last_name': 'Kumar', 'password': 'UserPass@2024'},
            {'email': 'shopper-blocked@example.com', 'role': 'user', 'first_name': 'Blocked',
             'last_name': 'Shopper', 'password': 'UserPass@2024', 'is_blocked': True},
            {'email': 'dealer-active@example.com', 'role': 'dealer', 'first_name': 'Active',
             'last_name': 'Dealer', 'password': 'DealerPass@2024',
             'dealer_status': 'active', 'dealer_company_name': 'Active Dealer LLP',
             'dealer_gst_number': '27ABCDE1234F1Z5'},
            {'email': 'dealer-pending@example.com', 'role': 'dealer', 'first_name': 'Pending',
             'last_name': 'Dealer', 'password': 'DealerPass@2024',
             'dealer_status': 'pending', 'dealer_company_name': 'Pending Dealer Co.'},
        ]
        for d in defs:
            password = d.pop('password')
            obj, created = User.objects.get_or_create(
                email=d['email'],
                defaults={'username': d['email'], **d},
            )
            if created:
                obj.set_password(password)
                obj.save()
                self.stdout.write(f'  + created user {obj.email} ({obj.role})')
            else:
                # Reapply role/dealer flags so the script is idempotent yet refreshes test state.
                changed = False
                for k, v in d.items():
                    if getattr(obj, k, None) != v and k not in {'username'}:
                        setattr(obj, k, v)
                        changed = True
                if changed:
                    obj.save()
                    self.stdout.write(f'  ~ updated user {obj.email}')

    # ── Warehouses + stock ───────────────────────────────────────────────

    def _seed_warehouses_and_stock(self):
        wh, _ = Warehouse.objects.get_or_create(
            code='MAIN',
            defaults={'name': 'Main Warehouse', 'address': 'Bengaluru, IN', 'is_active': True},
        )
        for product in Product.objects.iterator():
            level, created = StockLevel.objects.get_or_create(
                product=product, variant=None, warehouse=wh,
                defaults={'quantity': 0, 'low_threshold': 5},
            )
            if created and product.stock > 0:
                # Mirror the Product.stock onto the warehouse via a real movement.
                StockMovement.objects.create(
                    stock_level=level, delta=product.stock, reason='inbound',
                    note='Seeded from existing Product.stock',
                )

    # ── CMS ──────────────────────────────────────────────────────────────

    def _seed_cms(self):
        Banner.objects.get_or_create(
            title='Welcome to FurnoTech',
            defaults={
                'image_url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1600',
                'link_url': '/',
                'placement': 'home_hero',
                'is_active': True, 'sort_order': 0,
            },
        )
        Page.objects.get_or_create(
            slug='privacy',
            defaults={
                'title': 'Privacy Policy',
                'body_md': '# Privacy Policy\n\nWe respect your privacy. (Edit this page in admin.)',
                'is_published': True,
            },
        )
        Page.objects.get_or_create(
            slug='terms',
            defaults={
                'title': 'Terms & Conditions',
                'body_md': '# Terms & Conditions\n\nDefault terms. Please customize.',
                'is_published': True,
            },
        )
        faq_seed = [
            ('How long does shipping take?',
             'Standard shipping arrives in 5–7 business days. Premium 2–3 days.', 'Shipping', 0),
            ('What is your return policy?',
             'You can return any product within 14 days for a full refund.', 'Returns', 0),
            ('Do you offer dealer pricing?',
             'Yes. Apply via the Dealer Apply form; approval typically takes 1–2 days.', 'Dealers', 0),
        ]
        for q, a, cat, order in faq_seed:
            FAQ.objects.get_or_create(
                question=q,
                defaults={'answer': a, 'category': cat, 'sort_order': order, 'is_active': True},
            )

    # ── Shipping zones ──────────────────────────────────────────────────

    def _seed_shipping_zones(self):
        zones = [
            {
                'name': 'Delhi NCR',
                'pincode_prefix': '11',
                'base_fee': Decimal('149'),
                'per_kg_fee': Decimal('25'),
                'free_shipping_threshold': Decimal('5000'),
                'etd_days_min': 2,
                'etd_days_max': 4,
                'cod_available': True,
                'is_active': True,
            },
            {
                'name': 'Mumbai',
                'pincode_prefix': '40',
                'base_fee': Decimal('199'),
                'per_kg_fee': Decimal('30'),
                'free_shipping_threshold': Decimal('6000'),
                'etd_days_min': 3,
                'etd_days_max': 5,
                'cod_available': True,
                'is_active': True,
            },
            {
                'name': 'Bengaluru',
                'pincode_prefix': '56',
                'base_fee': Decimal('189'),
                'per_kg_fee': Decimal('28'),
                'free_shipping_threshold': Decimal('5500'),
                'etd_days_min': 3,
                'etd_days_max': 6,
                'cod_available': True,
                'is_active': True,
            },
            {
                'name': 'Chennai',
                'pincode_prefix': '60',
                'base_fee': Decimal('189'),
                'per_kg_fee': Decimal('28'),
                'free_shipping_threshold': Decimal('5500'),
                'etd_days_min': 3,
                'etd_days_max': 6,
                'cod_available': True,
                'is_active': True,
            },
            {
                'name': 'Hyderabad',
                'pincode_prefix': '50',
                'base_fee': Decimal('189'),
                'per_kg_fee': Decimal('28'),
                'free_shipping_threshold': Decimal('5500'),
                'etd_days_min': 3,
                'etd_days_max': 6,
                'cod_available': True,
                'is_active': True,
            },
            {
                'name': 'Kolkata',
                'pincode_prefix': '70',
                'base_fee': Decimal('209'),
                'per_kg_fee': Decimal('32'),
                'free_shipping_threshold': Decimal('6500'),
                'etd_days_min': 4,
                'etd_days_max': 7,
                'cod_available': True,
                'is_active': True,
            },
        ]

        for z in zones:
            zone, created = ShippingZone.objects.get_or_create(
                pincode_prefix=z['pincode_prefix'],
                defaults=z,
            )
            if created:
                self.stdout.write(f'  + shipping zone {zone.name} ({zone.pincode_prefix}*)')
            else:
                # Update defaults on existing rows to keep local data fresh.
                changed = False
                for k, v in z.items():
                    if getattr(zone, k) != v:
                        setattr(zone, k, v)
                        changed = True
                if changed:
                    zone.save()
