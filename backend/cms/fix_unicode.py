"""
One-shot script to fix garbled unicode in existing CMS content blocks.
Run: python manage.py shell < cms/fix_unicode.py
"""
import os, sys, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from cms.models import ContentBlock

fixes = {
    'home_hero_copy': {
        'eyebrow': 'New Arrival - Modern Sofas',
        'title': 'Beautiful Homes',
        'accent': 'Start Here',
        'desc': 'Premium furniture & home essentials - crafted for the Indian home.',
        'tags': ['Sofa', 'Dining Table', 'Bed', 'Office Chair', 'Bookshelf'],
        'stats': [
            {'num': '1L+', 'label': 'Happy Customers'},
            {'num': '500+', 'label': 'Products'},
            {'num': '4.8', 'label': 'Avg Rating'},
        ],
    },
    'trust_badges': {
        'items': [
            {'icon': 'truck', 'title': 'Free Shipping', 'desc': 'On all orders above Rs.299'},
            {'icon': 'returns', 'title': 'Easy Returns', 'desc': '30-day hassle-free returns'},
            {'icon': 'shield', 'title': '1-Year Warranty', 'desc': 'On all furniture products'},
            {'icon': 'star', 'title': '1 Lakh+ Happy Homes', 'desc': 'Trusted by customers across India'},
        ],
    },
    'announcement_bar': {
        'text': 'Free shipping on orders above Rs.299 - Trusted by 1 Lakh+ happy homes',
        'phone': '1800-123-4567',
    },
}

for key, data in fixes.items():
    try:
        obj = ContentBlock.objects.get(key=key)
        obj.data_json = data
        obj.save()
        print(f'Fixed: {key}')
    except ContentBlock.DoesNotExist:
        print(f'Not found: {key}')

print('Done fixing unicode.')
