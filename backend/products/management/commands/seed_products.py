from django.core.management.base import BaseCommand
from products.models import Category, Product


class Command(BaseCommand):
    help = 'Seed the database with sample furniture products'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding products...')

        categories_data = [
            {'name': 'Sofas', 'slug': 'sofas', 'description': 'Comfortable sofas and sectionals'},
            {'name': 'Tables', 'slug': 'tables', 'description': 'Dining and coffee tables'},
            {'name': 'Chairs', 'slug': 'chairs', 'description': 'Office and accent chairs'},
            {'name': 'Beds', 'slug': 'beds', 'description': 'Beds and bedroom furniture'},
            {'name': 'Storage', 'slug': 'storage', 'description': 'Shelves, wardrobes, and storage'},
            {'name': 'Desks', 'slug': 'desks', 'description': 'Work-from-home and study desks'},
            {'name': 'Dining Sets', 'slug': 'dining-sets', 'description': 'Complete dining room sets'},
            {'name': 'Outdoor', 'slug': 'outdoor', 'description': 'Outdoor and garden furniture'},
        ]

        categories = {}
        for cat_data in categories_data:
            cat, _ = Category.objects.update_or_create(
                slug=cat_data['slug'],
                defaults={'name': cat_data['name'], 'description': cat_data['description']},
            )
            categories[cat_data['slug']] = cat
            self.stdout.write(f'  Category: {cat.name}')

        products_data = [
            # Sofas
            {
                'name': 'Oslo Velvet Sofa', 'slug': 'oslo-velvet-sofa',
                'description': 'Premium 3-seater velvet sofa with solid oak legs. Mid-century modern design that brings timeless elegance to your living room.',
                'price': '45999.00', 'category_slug': 'sofas', 'material': 'fabric',
                'color': 'Emerald Green', 'dimensions': '220x85x80 cm',
                'image_url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
                'stock': 15, 'is_featured': True,
            },
            {
                'name': 'Nordic L-Shape Sectional', 'slug': 'nordic-l-shape-sectional',
                'description': 'Spacious L-shaped sectional sofa with removable covers. Perfect for large living rooms and open-plan spaces.',
                'price': '78999.00', 'category_slug': 'sofas', 'material': 'fabric',
                'color': 'Charcoal Grey', 'dimensions': '300x200x80 cm',
                'image_url': 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800',
                'stock': 8, 'is_featured': False,
            },
            # Tables
            {
                'name': 'Acacia Wood Coffee Table', 'slug': 'acacia-wood-coffee-table',
                'description': 'Hand-crafted solid acacia wood coffee table with natural grain finish. Each piece is unique.',
                'price': '18999.00', 'category_slug': 'tables', 'material': 'wood',
                'color': 'Natural Brown', 'dimensions': '120x60x45 cm',
                'image_url': 'https://images.unsplash.com/photo-1611269154421-4e27233ac5c7?w=800',
                'stock': 22, 'is_featured': False,
            },
            {
                'name': 'Marble Top Dining Table', 'slug': 'marble-top-dining-table',
                'description': 'Luxurious white marble dining table with powder-coated steel frame. Seats 6 comfortably.',
                'price': '54999.00', 'category_slug': 'tables', 'material': 'marble',
                'color': 'White', 'dimensions': '180x90x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
                'stock': 10, 'is_featured': True,
            },
            # Chairs
            {
                'name': 'Tulip Accent Chair', 'slug': 'tulip-accent-chair',
                'description': 'Mid-century modern accent chair with button tufting and walnut legs. Available in multiple colors.',
                'price': '12999.00', 'category_slug': 'chairs', 'material': 'fabric',
                'color': 'Mustard Yellow', 'dimensions': '75x78x85 cm',
                'image_url': 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=800',
                'stock': 30, 'is_featured': False,
            },
            {
                'name': 'Ergonomic Mesh Office Chair', 'slug': 'ergonomic-mesh-office-chair',
                'description': 'Full lumbar support mesh office chair with adjustable armrests and headrest. 8-hour comfort guarantee.',
                'price': '22999.00', 'category_slug': 'chairs', 'material': 'fabric',
                'color': 'Black', 'dimensions': '65x65x120 cm',
                'image_url': 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800',
                'stock': 50, 'is_featured': True,
            },
            # Beds
            {
                'name': 'King Platform Bed Frame', 'slug': 'king-platform-bed-frame',
                'description': 'Solid walnut king-size platform bed with under-bed storage drawers. No box spring required.',
                'price': '64999.00', 'category_slug': 'beds', 'material': 'wood',
                'color': 'Walnut Brown', 'dimensions': '200x180x40 cm',
                'image_url': 'https://images.unsplash.com/photo-1505693314120-0d443867891c?w=800',
                'stock': 12, 'is_featured': True,
            },
            {
                'name': 'Upholstered Wingback Bed', 'slug': 'upholstered-wingback-bed',
                'description': 'Luxurious upholstered queen bed with tall wingback headboard. Soft velvet finish in rose pink.',
                'price': '48999.00', 'category_slug': 'beds', 'material': 'fabric',
                'color': 'Dusty Rose', 'dimensions': '215x165x140 cm',
                'image_url': 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
                'stock': 7, 'is_featured': False,
            },
            # Storage
            {
                'name': 'Modular Bookshelf Unit', 'slug': 'modular-bookshelf-unit',
                'description': '5-shelf modular bookshelf with adjustable shelves. Mix-and-match modules to create your perfect storage wall.',
                'price': '16999.00', 'category_slug': 'storage', 'material': 'wood',
                'color': 'Oak White', 'dimensions': '90x35x180 cm',
                'image_url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
                'stock': 25, 'is_featured': False,
            },
            {
                'name': '3-Door Wardrobe', 'slug': '3-door-wardrobe',
                'description': 'Sliding door wardrobe with mirror panel, hanging rods, and 4 internal shelves.',
                'price': '34999.00', 'category_slug': 'storage', 'material': 'wood',
                'color': 'Matte White', 'dimensions': '180x60x210 cm',
                'image_url': 'https://images.unsplash.com/photo-1558997519-83ea9252edf8?w=800',
                'stock': 9, 'is_featured': False,
            },
            # Desks
            {
                'name': 'Solid Oak Writing Desk', 'slug': 'solid-oak-writing-desk',
                'description': 'Minimalist solid oak writing desk with integrated cable management and a hidden drawer.',
                'price': '28999.00', 'category_slug': 'desks', 'material': 'wood',
                'color': 'Natural Oak', 'dimensions': '140x70x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800',
                'stock': 18, 'is_featured': False,
            },
            {
                'name': 'Height Adjustable Standing Desk', 'slug': 'height-adjustable-standing-desk',
                'description': 'Electric sit-stand desk with memory presets. Dual motor system, whisper-quiet operation.',
                'price': '42999.00', 'category_slug': 'desks', 'material': 'metal',
                'color': 'White Frame', 'dimensions': '160x80x72-120 cm',
                'image_url': 'https://images.unsplash.com/photo-1593642532454-e138e28a63f4?w=800',
                'stock': 14, 'is_featured': True,
            },
            # Dining Sets
            {
                'name': '6-Seater Teak Dining Set', 'slug': '6-seater-teak-dining-set',
                'description': 'Complete 6-seater dining set in solid teak with padded chairs. Includes table and 6 chairs.',
                'price': '84999.00', 'category_slug': 'dining-sets', 'material': 'wood',
                'color': 'Teak Brown', 'dimensions': 'Table 180x90x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
                'stock': 5, 'is_featured': True,
            },
            {
                'name': 'Compact 4-Seater Dining Set', 'slug': 'compact-4-seater-dining-set',
                'description': 'Space-saving 4-seater dining set perfect for apartments. Fold-away chairs for extra space.',
                'price': '36999.00', 'category_slug': 'dining-sets', 'material': 'wood',
                'color': 'Beech Natural', 'dimensions': 'Table 120x70x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1615529328331-f8917597711f?w=800',
                'stock': 20, 'is_featured': False,
            },
            # Outdoor
            {
                'name': 'Teak Garden Bench', 'slug': 'teak-garden-bench',
                'description': 'Weather-resistant teak garden bench. Treated with teak oil for outdoor durability.',
                'price': '14999.00', 'category_slug': 'outdoor', 'material': 'wood',
                'color': 'Teak', 'dimensions': '150x55x80 cm',
                'image_url': 'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=800',
                'stock': 35, 'is_featured': False,
            },
            {
                'name': 'Rattan Outdoor Lounge Set', 'slug': 'rattan-outdoor-lounge-set',
                'description': '4-piece outdoor rattan lounge set with weather-resistant cushions. Includes 2 chairs, sofa, and table.',
                'price': '52999.00', 'category_slug': 'outdoor', 'material': 'rattan',
                'color': 'Natural Rattan', 'dimensions': 'Sofa 180x80x70 cm',
                'image_url': 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
                'stock': 11, 'is_featured': False,
            },
        ]

        for product_data in products_data:
            category_slug = product_data.pop('category_slug')
            product, created = Product.objects.update_or_create(
                slug=product_data['slug'],
                defaults={**product_data, 'category': categories[category_slug]},
            )
            status_text = 'Created' if created else 'Updated'
            self.stdout.write(f'  {status_text}: {product.name}')

        self.stdout.write(self.style.SUCCESS(f'\nDone! {len(products_data)} products seeded.'))
