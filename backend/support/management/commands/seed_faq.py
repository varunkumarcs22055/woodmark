"""
Seed the support bot with starter Q&A entries.

Idempotent: looks up each entry by (topic, question) and updates the answer
+ triggers in place rather than creating duplicates. Safe to re-run after
adjusting the catalogue below.

Usage:
  python manage.py seed_faq
"""
from django.core.management.base import BaseCommand
from support.models import FaqEntry


SEED = [
    # ── Package & delivery ───────────────────────────────────────────────
    {
        'topic': 'Package & delivery',
        'question': 'My package hasn\'t arrived yet',
        'answer': (
            "Sorry about that. Could you share:\n"
            "  1. Your order ID (looks like ORD-XXXXXXXX)\n"
            "  2. Your registered phone or email\n"
            "  3. When you placed the order\n\n"
            "You can check live status under My Orders -> Track. Most orders "
            "deliver within 3-7 business days. If it's been longer, I'll "
            "escalate this to our team."
        ),
        'triggers': ['package', 'parcel', "didn't arrive", 'not arrived',
                     'not received', 'where is my order', 'tracking', 'delayed'],
        'follow_up_prompts': ['Track my order', 'Order delivered to wrong address', 'Contact support'],
        'sort_order': 10,
    },
    {
        'topic': 'Package & delivery',
        'question': 'Track my order',
        'answer': (
            "Open My Orders -> click the order -> the tracking number and "
            "carrier appear at the top of the page. If tracking shows no "
            "movement for 48 hours, reply here with your order ID and I'll "
            "raise a ticket."
        ),
        'triggers': ['track', 'tracking number', 'where is', 'carrier'],
        'follow_up_prompts': ['My package hasn\'t arrived yet', 'Contact support'],
        'sort_order': 11,
    },
    {
        'topic': 'Package & delivery',
        'question': 'Order delivered to wrong address',
        'answer': (
            "Please raise a ticket with the correct address and your order ID. "
            "Our team will arrange pickup + redelivery within 24-48 hours. "
            "Refunds available if the wrong-address delivery was our fault."
        ),
        'triggers': ['wrong address', 'wrong location', 'address change'],
        'follow_up_prompts': ['Contact support'],
        'sort_order': 12,
    },

    # ── Payment & refund ─────────────────────────────────────────────────
    {
        'topic': 'Payment & refund',
        'question': 'Payment failed but money was deducted',
        'answer': (
            "Failed payments auto-refund within 5-7 business days. The bank "
            "may show it as 'pending' until then. If 7 days have passed and "
            "the amount hasn't returned, share your order ID + transaction "
            "reference and I'll escalate."
        ),
        'triggers': ['payment failed', 'money deducted', 'payment not received',
                     'amount debited', 'paid but'],
        'follow_up_prompts': ['Refund status', 'Contact support'],
        'sort_order': 20,
    },
    {
        'topic': 'Payment & refund',
        'question': 'Refund status',
        'answer': (
            "Refunds for cancelled / returned orders process within 3-5 "
            "business days after we receive the item back. UPI / wallet "
            "refunds are usually instant; card / netbanking can take up to "
            "7 days. Reply with your order ID for the current status."
        ),
        'triggers': ['refund', 'money back', 'reverse payment'],
        'follow_up_prompts': ['Cancel my order', 'Contact support'],
        'sort_order': 21,
    },

    # ── Returns ─────────────────────────────────────────────────────────
    {
        'topic': 'Returns & cancellations',
        'question': 'Return an item',
        'answer': (
            "You have 30 days from delivery to return unused items. "
            "Open My Orders -> select the order -> click 'Return' -> pick "
            "the reason -> we'll arrange free pickup within 2 business days."
        ),
        'triggers': ['return', 'send back', 'change my mind', 'not happy'],
        'follow_up_prompts': ['Refund status', 'Cancel my order'],
        'sort_order': 30,
    },
    {
        'topic': 'Returns & cancellations',
        'question': 'Cancel my order',
        'answer': (
            "Orders can be cancelled free of charge as long as they haven't "
            "shipped yet (usually a 60-minute window after placing). Open My "
            "Orders -> click the order -> Cancel. After shipping, please use "
            "the Return option once it arrives."
        ),
        'triggers': ['cancel', 'cancellation'],
        'follow_up_prompts': ['Return an item', 'Refund status'],
        'sort_order': 31,
    },

    # ── Account ──────────────────────────────────────────────────────────
    {
        'topic': 'Account',
        'question': 'I can\'t log in / forgot password',
        'answer': (
            "Click 'Forgot password?' on the login screen, enter your email, "
            "and we'll send a reset link instantly. Check your spam folder if "
            "you don't see it in 2 minutes."
        ),
        'triggers': ['login', 'log in', 'sign in', 'password',
                     'forgot', "can't access", 'locked out'],
        'follow_up_prompts': ['Update my email', 'Contact support'],
        'sort_order': 40,
    },
    {
        'topic': 'Account',
        'question': 'Update my email or phone',
        'answer': (
            "Go to My Account -> Profile -> Edit. Email changes require "
            "re-verification (we'll email a 6-digit code). For phone, just "
            "update and save."
        ),
        'triggers': ['change email', 'update email', 'change phone',
                     'update phone', 'edit profile'],
        'follow_up_prompts': [],
        'sort_order': 41,
    },

    # ── Product / warranty ──────────────────────────────────────────────
    {
        'topic': 'Product & warranty',
        'question': 'Warranty claim',
        'answer': (
            "All FurniShop products come with a 1-year manufacturer warranty "
            "against defects. Raise a ticket with: order ID, item, photo of "
            "the defect, and a short description. Our team responds in 24h."
        ),
        'triggers': ['warranty', 'defect', 'broken', 'damaged',
                     'not working', 'manufacturing'],
        'follow_up_prompts': ['Contact support'],
        'sort_order': 50,
    },
]


class Command(BaseCommand):
    help = 'Seed / refresh starter FAQ entries for the support chatbot.'

    def handle(self, *args, **opts):
        created = updated = 0
        for row in SEED:
            obj, was_created = FaqEntry.objects.update_or_create(
                topic=row['topic'],
                question=row['question'],
                defaults={
                    'answer': row['answer'],
                    'triggers': row['triggers'],
                    'follow_up_prompts': row.get('follow_up_prompts', []),
                    'sort_order': row.get('sort_order', 100),
                    'is_active': True,
                },
            )
            if was_created:
                created += 1
            else:
                updated += 1
        self.stdout.write(self.style.SUCCESS(
            f'FAQ seed done — {created} created, {updated} updated, '
            f'{FaqEntry.objects.count()} total.'
        ))
