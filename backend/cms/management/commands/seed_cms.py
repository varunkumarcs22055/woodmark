"""
Management command: seed_cms

Creates CMS tables (via migrate) and inserts default content blocks, banners,
FAQs, and pages so the storefront never shows empty sections.

Usage:
    python manage.py seed_cms
"""
import json
from django.core.management.base import BaseCommand
from cms.models import ContentBlock, Banner, FAQ, Page


# ── Default Content Blocks ────────────────────────────────────────────────────
DEFAULT_CONTENT_BLOCKS = [
    {
        'key': 'home_hero_copy',
        'title': 'Homepage Hero Copy',
        'data_json': {
            'eyebrow': 'New Arrival - Modern Sofas',
            'title': 'Beautiful Homes',
            'accent': 'Start Here',
            'desc': 'Premium furniture & home essentials - crafted for the Indian home.',
            'tags': ['Sofa', 'Dining Table', 'Bed', 'Office Chair', 'Bookshelf'],
            'stats': [
                {'num': '1L+', 'label': 'Happy Customers'},
                {'num': '500+', 'label': 'Products'},
                {'num': '4.8*', 'label': 'Avg Rating'},
            ],
        },
    },
    {
        'key': 'trust_badges',
        'title': 'Trust Badges Row',
        'data_json': {
            'items': [
                {'icon': 'truck', 'title': 'Free Shipping', 'desc': 'On all orders above Rs.299'},
                {'icon': 'returns', 'title': 'Easy Returns', 'desc': '30-day hassle-free returns'},
                {'icon': 'shield', 'title': '1-Year Warranty', 'desc': 'On all furniture products'},
                {'icon': 'star', 'title': '1 Lakh+ Happy Homes', 'desc': 'Trusted by customers across India'},
            ],
        },
    },
    {
        'key': 'promo_best_sellers',
        'title': 'Best Sellers Promo',
        'data_json': {
            'tag': 'Limited Time',
            'title': 'Up to 40% off on',
            'title_accent': 'Best Sellers',
            'desc': 'Shop our most-loved products at unbeatable prices',
            'cta_text': 'Shop Best Sellers',
            'cta_link': '/best-sellers',
            'percent': '40%',
        },
    },
    {
        'key': 'announcement_bar',
        'title': 'Announcement Bar',
        'data_json': {
            'text': 'Free shipping on orders above Rs.299 - Trusted by 1 Lakh+ happy homes',
            'phone': '1800-123-4567',
        },
    },
    {
        'key': 'newsletter_footer',
        'title': 'Footer Newsletter',
        'data_json': {
            'heading': 'Newsletter',
            'desc': 'Get exclusive offers, style tips, and new arrivals directly in your inbox.',
            'note': 'No spam. Unsubscribe anytime.',
        },
    },
    {
        'key': 'nav_menu',
        'title': 'Navbar Menu Override',
        'data_json': {
            'groups': [
                {
                    'label': 'Living Room',
                    'items': [
                        {'label': 'Sofas', 'slug': 'sofas'},
                        {'label': 'Tables', 'slug': 'tables'},
                    ],
                },
            ],
        },
    },
]

# ── Default Banners ───────────────────────────────────────────────────────────
DEFAULT_BANNERS = [
    {
        'title': 'Trusted by 1 Lakh+ Happy Homes',
        'image_url': '/hero_banner.png',
        'placement': 'home_hero',
        'is_active': True,
        'sort_order': 0,
    },
    {
        'title': 'New Arrival - Modern Sofas',
        'image_url': '/cat_furniture.png',
        'placement': 'home_hero',
        'is_active': True,
        'sort_order': 1,
    },
    {
        'title': 'Best Seller - Bath Collection',
        'image_url': '/cat_bath.png',
        'placement': 'home_hero',
        'is_active': True,
        'sort_order': 2,
    },
]

# ── Default FAQs ─────────────────────────────────────────────────────────────
DEFAULT_FAQS = [
    {
        'question': 'What is your return policy?',
        'answer': 'We offer a 30-day hassle-free return policy on all products. If you are not satisfied with your purchase, you can return it within 30 days for a full refund.',
        'category': 'Returns',
        'sort_order': 0,
    },
    {
        'question': 'How long does shipping take?',
        'answer': 'Standard shipping takes 5-7 business days. Express shipping is available for select products and delivers within 2-3 business days.',
        'category': 'Shipping',
        'sort_order': 1,
    },
    {
        'question': 'Do you offer assembly services?',
        'answer': 'Yes! We offer free assembly on all furniture orders above Rs.5,000. Our trained professionals will set up your furniture at a time convenient for you.',
        'category': 'Services',
        'sort_order': 2,
    },
    {
        'question': 'What payment methods do you accept?',
        'answer': 'We accept all major credit/debit cards, UPI, net banking, and cash on delivery. EMI options are available on select products.',
        'category': 'Payments',
        'sort_order': 3,
    },
    {
        'question': 'Is there a warranty on your products?',
        'answer': 'All our furniture products come with a 1-year warranty covering manufacturing defects. Extended warranty options are available at checkout.',
        'category': 'Warranty',
        'sort_order': 4,
    },
]

# ── Default Pages ─────────────────────────────────────────────────────────────
DEFAULT_PAGES = [
    {
        'slug': 'shipping-policy',
        'title': 'Shipping Policy',
        'body_md': (
            '## Overview\n'
            'We offer reliable shipping across India with multiple delivery options.\n\n'
            '## Delivery Timelines\n'
            '- **Standard Shipping:** 5-7 business days\n'
            '- **Express Shipping:** 2-3 business days (select products)\n'
            '- **Same-Day Delivery:** Available in select cities\n\n'
            '## Charges\n'
            '- Free shipping on orders above Rs.299\n'
            '- Flat Rs.49 shipping fee for orders under Rs.299\n'
        ),
        'is_published': True,
    },
    {
        'slug': 'return-policy',
        'title': 'Return Policy',
        'body_md': (
            '## Overview\n'
            'We want you to be completely satisfied with your purchase.\n\n'
            '## Return Window\n'
            '- 30-day return window from the date of delivery\n'
            '- Items must be in original condition with tags attached\n\n'
            '## Refunds\n'
            '- Refunds are processed within 5-7 business days\n'
            '- Original payment method will be refunded\n'
        ),
        'is_published': True,
    },
    {
        'slug': 'privacy-policy',
        'title': 'Privacy Policy',
        'body_md': (
            '## Overview\n'
            'Your privacy is important to us. This policy explains how we handle your data.\n\n'
            '## Data Collected\n'
            '- Name, email, phone number for order processing\n'
            '- Payment information (processed securely via Razorpay)\n'
            '- Browsing data for improving your experience\n\n'
            '## Usage\n'
            '- We never sell your personal data to third parties\n'
            '- Data is used only for order fulfillment and communication\n'
        ),
        'is_published': True,
    },
    {
        'slug': 'contact-us',
        'title': 'Contact Us',
        'body_md': (
            '## Get in Touch\n'
            'We\'d love to hear from you!\n\n'
            '## Support\n'
            '- **Email:** support@woodmark.in\n'
            '- **Phone:** 1800-123-4567 (Mon-Sat, 9 AM - 6 PM)\n'
            '- **WhatsApp:** +91 98765 43210\n\n'
            '## Address\n'
            'Woodmark HQ, Sector 62, Noida, UP - 201301\n'
        ),
        'is_published': True,
    },
    {
        'slug': 'support',
        'title': 'Support',
        'body_md': (
            '## How Can We Help?\n'
            'Our support team is here to assist you.\n\n'
            '## Support Channels\n'
            '- **Live Chat:** Available on the website (Mon-Sat, 9 AM - 6 PM)\n'
            '- **Email Ticket:** Raise a ticket from your account dashboard\n'
            '- **Phone:** 1800-123-4567\n\n'
            '## Response Time\n'
            '- Chat: Instant\n'
            '- Email: Within 24 hours\n'
            '- Phone: Immediate during business hours\n'
        ),
        'is_published': True,
    },
]


class Command(BaseCommand):
    help = 'Seed CMS tables with default content blocks, banners, FAQs, and pages.'

    def handle(self, *args, **options):
        self.stdout.write('Seeding CMS content...\n')

        # ── Content Blocks ────────────────────────────────────────────
        created_blocks = 0
        for block_data in DEFAULT_CONTENT_BLOCKS:
            obj, created = ContentBlock.objects.get_or_create(
                key=block_data['key'],
                defaults={
                    'title': block_data['title'],
                    'data_json': block_data['data_json'],
                    'is_active': True,
                },
            )
            if created:
                created_blocks += 1
                self.stdout.write(f'  [+] Created content block: {obj.key}')
            else:
                self.stdout.write(f'  [-] Content block already exists: {obj.key}')
        self.stdout.write(f'\nContent blocks: {created_blocks} created, '
                          f'{len(DEFAULT_CONTENT_BLOCKS) - created_blocks} already existed.\n')

        # ── Banners ───────────────────────────────────────────────────
        created_banners = 0
        for banner_data in DEFAULT_BANNERS:
            obj, created = Banner.objects.get_or_create(
                title=banner_data['title'],
                placement=banner_data['placement'],
                defaults={
                    'image_url': banner_data['image_url'],
                    'is_active': banner_data['is_active'],
                    'sort_order': banner_data['sort_order'],
                },
            )
            if created:
                created_banners += 1
                self.stdout.write(f'  [+] Created banner: {obj.title}')
            else:
                self.stdout.write(f'  [-] Banner already exists: {obj.title}')
        self.stdout.write(f'\nBanners: {created_banners} created, '
                          f'{len(DEFAULT_BANNERS) - created_banners} already existed.\n')

        # ── FAQs ──────────────────────────────────────────────────────
        created_faqs = 0
        for faq_data in DEFAULT_FAQS:
            obj, created = FAQ.objects.get_or_create(
                question=faq_data['question'],
                defaults={
                    'answer': faq_data['answer'],
                    'category': faq_data['category'],
                    'sort_order': faq_data['sort_order'],
                    'is_active': True,
                },
            )
            if created:
                created_faqs += 1
                self.stdout.write(f'  [+] Created FAQ: {obj.question[:50]}')
            else:
                self.stdout.write(f'  [-] FAQ already exists: {obj.question[:50]}')
        self.stdout.write(f'\nFAQs: {created_faqs} created, '
                          f'{len(DEFAULT_FAQS) - created_faqs} already existed.\n')

        # ── Pages ─────────────────────────────────────────────────────
        created_pages = 0
        for page_data in DEFAULT_PAGES:
            obj, created = Page.objects.get_or_create(
                slug=page_data['slug'],
                defaults={
                    'title': page_data['title'],
                    'body_md': page_data['body_md'],
                    'is_published': page_data['is_published'],
                },
            )
            if created:
                created_pages += 1
                self.stdout.write(f'  [+] Created page: {obj.slug}')
            else:
                self.stdout.write(f'  [-] Page already exists: {obj.slug}')
        self.stdout.write(f'\nPages: {created_pages} created, '
                          f'{len(DEFAULT_PAGES) - created_pages} already existed.\n')

        self.stdout.write(self.style.SUCCESS(
            '\nDONE - CMS seeding complete!'
        ))
