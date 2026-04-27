"""
Management command to seed the database with sample furniture products.

Usage:
    python manage.py seed_products

This creates categories and sample products for development/testing.
All data is created via Django ORM, exactly the same as adding via Admin panel.
"""

from django.core.management.base import BaseCommand
from products.models import Category, Product


class Command(BaseCommand):
    help = 'Seed database with sample furniture products and categories'

    def handle(self, *args, **options):
        self.stdout.write('Seeding database...\n')

        # ─── Create Categories ────────────────────────────────────
        categories_data = [
            'Sofas', 'Tables', 'Chairs', 'Beds', 'Storage',
            'Desks', 'Dining Sets', 'Outdoor'
        ]
        categories = {}
        for name in categories_data:
            cat, created = Category.objects.get_or_create(name=name)
            categories[name] = cat
            status = 'Created' if created else 'Exists'
            self.stdout.write(f'  Category: {name} [{status}]')

        # ─── Create Products ─────────────────────────────────────
        products_data = [
            {
                'name': 'Oslo Velvet Sofa',
                'description': 'A luxurious 3-seater velvet sofa with solid oak legs. Features high-density foam cushions and a contemporary Scandinavian design that elevates any living room.',
                'price': 45999.00,
                'category': categories['Sofas'],
                'material': 'fabric',
                'color': 'Emerald Green',
                'dimensions': '220x85x80 cm',
                'image_url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
                'stock': 15,
            },
            {
                'name': 'Manhattan Leather Recliner',
                'description': 'Premium genuine leather recliner with manual recline mechanism. Padded armrests and lumbar support for ultimate comfort. Perfect for reading corners and home theaters.',
                'price': 32999.00,
                'category': categories['Sofas'],
                'material': 'leather',
                'color': 'Dark Brown',
                'dimensions': '95x90x100 cm',
                'image_url': 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=800',
                'stock': 8,
            },
            {
                'name': 'Aria Sectional Sofa',
                'description': 'Modern L-shaped sectional sofa with reversible chaise. Stain-resistant upholstery, perfect for families. Includes 4 throw pillows.',
                'price': 67999.00,
                'category': categories['Sofas'],
                'material': 'fabric',
                'color': 'Slate Gray',
                'dimensions': '280x170x85 cm',
                'image_url': 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800',
                'stock': 5,
            },
            {
                'name': 'Nordic Oak Dining Table',
                'description': 'Solid oak dining table with tapered legs. Seats 6 comfortably. Hand-finished with food-safe natural oil for a warm, organic look.',
                'price': 38999.00,
                'category': categories['Tables'],
                'material': 'wood',
                'color': 'Natural Oak',
                'dimensions': '180x90x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
                'stock': 12,
            },
            {
                'name': 'Marble Coffee Table',
                'description': 'Elegant coffee table with genuine Italian Carrara marble top and brushed brass legs. A statement piece for sophisticated living rooms.',
                'price': 28999.00,
                'category': categories['Tables'],
                'material': 'marble',
                'color': 'White Marble',
                'dimensions': '120x60x45 cm',
                'image_url': 'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?w=800',
                'stock': 10,
            },
            {
                'name': 'Industrial Side Table',
                'description': 'Compact side table with reclaimed wood top and black steel frame. Industrial charm meets modern functionality.',
                'price': 8999.00,
                'category': categories['Tables'],
                'material': 'metal',
                'color': 'Black / Rustic Brown',
                'dimensions': '45x45x55 cm',
                'image_url': 'https://images.unsplash.com/photo-1499933374294-4584851497cc?w=800',
                'stock': 25,
            },
            {
                'name': 'Eames Style Dining Chair',
                'description': 'Mid-century modern dining chair with molded seat and beech wood legs. Ergonomic design for hours of comfortable dining.',
                'price': 6999.00,
                'category': categories['Chairs'],
                'material': 'plastic',
                'color': 'White',
                'dimensions': '47x53x82 cm',
                'image_url': 'https://images.unsplash.com/photo-1503602642458-232111445657?w=800',
                'stock': 30,
            },
            {
                'name': 'Rattan Accent Chair',
                'description': 'Handwoven natural rattan accent chair with cotton cushion. Brings warmth and texture to any room. Lightweight and easy to move.',
                'price': 14999.00,
                'category': categories['Chairs'],
                'material': 'rattan',
                'color': 'Natural',
                'dimensions': '70x65x85 cm',
                'image_url': 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=800',
                'stock': 18,
            },
            {
                'name': 'Executive Office Chair',
                'description': 'High-back mesh office chair with adjustable lumbar support, armrests, and headrest. 360-degree swivel with smooth-rolling casters.',
                'price': 19999.00,
                'category': categories['Chairs'],
                'material': 'metal',
                'color': 'Black',
                'dimensions': '65x65x120 cm',
                'image_url': 'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=800',
                'stock': 20,
            },
            {
                'name': 'Royal Upholstered Bed',
                'description': 'King-size upholstered bed with tufted headboard. Solid wood frame with premium slat support. No box spring needed.',
                'price': 54999.00,
                'category': categories['Beds'],
                'material': 'fabric',
                'color': 'Navy Blue',
                'dimensions': '200x180x120 cm',
                'image_url': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
                'stock': 7,
            },
            {
                'name': 'Minimalist Platform Bed',
                'description': 'Japanese-inspired low platform bed in solid walnut. Clean lines and floating design create a serene bedroom aesthetic.',
                'price': 42999.00,
                'category': categories['Beds'],
                'material': 'wood',
                'color': 'Walnut',
                'dimensions': '200x160x30 cm',
                'image_url': 'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800',
                'stock': 10,
            },
            {
                'name': 'Modular Bookshelf',
                'description': 'Geometric modular bookshelf with 8 open compartments. Wall-mountable or freestanding. Mix and match multiple units for custom configurations.',
                'price': 16999.00,
                'category': categories['Storage'],
                'material': 'wood',
                'color': 'White Oak',
                'dimensions': '120x30x180 cm',
                'image_url': 'https://images.unsplash.com/photo-1594620302200-9a762244a156?w=800',
                'stock': 14,
            },
            {
                'name': 'Glass Display Cabinet',
                'description': 'Elegant glass display cabinet with LED lighting and mirrored back. Tempered glass shelves with soft-close hinges. Perfect for showcasing collectibles.',
                'price': 34999.00,
                'category': categories['Storage'],
                'material': 'glass',
                'color': 'Transparent / Black Frame',
                'dimensions': '80x40x180 cm',
                'image_url': 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=800',
                'stock': 6,
            },
            {
                'name': 'Standing Desk Pro',
                'description': 'Electric height-adjustable standing desk with memory presets. Bamboo tabletop with cable management tray. Dual motor for smooth, quiet operation.',
                'price': 29999.00,
                'category': categories['Desks'],
                'material': 'wood',
                'color': 'Bamboo / Black',
                'dimensions': '140x70x65-125 cm',
                'image_url': 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800',
                'stock': 16,
            },
            {
                'name': 'Classic Writing Desk',
                'description': 'Elegant writing desk with 3 drawers and leather inlay top. Crafted from solid mahogany with brass hardware. A timeless piece for any study.',
                'price': 26999.00,
                'category': categories['Desks'],
                'material': 'wood',
                'color': 'Mahogany',
                'dimensions': '120x60x78 cm',
                'image_url': 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800',
                'stock': 9,
            },
            {
                'name': 'Teak Garden Bench',
                'description': 'Weather-resistant solid teak garden bench. Comfortable contoured seat. Develops a beautiful silver patina over time.',
                'price': 22999.00,
                'category': categories['Outdoor'],
                'material': 'wood',
                'color': 'Teak',
                'dimensions': '150x60x90 cm',
                'image_url': 'https://images.unsplash.com/photo-1521783988139-89397d761dce?w=800',
                'stock': 11,
            },
        ]

        for prod_data in products_data:
            product, created = Product.objects.get_or_create(
                name=prod_data['name'],
                defaults=prod_data
            )
            status = 'Created' if created else 'Exists'
            self.stdout.write(f'  Product: {product.name} [INR {product.price}] [{status}]')

        self.stdout.write(self.style.SUCCESS(
            f'\nDone! {Category.objects.count()} categories, '
            f'{Product.objects.count()} products in database.'
        ))
