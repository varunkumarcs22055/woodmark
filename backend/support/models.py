"""
SupportTicket — customer/dealer-initiated help thread.

Lifecycle: OPEN → AWAITING_CUSTOMER ↔ AWAITING_AGENT → RESOLVED → CLOSED.
Both customers and dealers use the same model; `category` distinguishes.
"""
from django.conf import settings
from django.db import models, transaction


class SupportTicket(models.Model):
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('awaiting_customer', 'Awaiting Customer'),
        ('awaiting_agent', 'Awaiting Agent'),
        ('resolved', 'Resolved'),
        ('closed', 'Closed'),
    ]
    PRIORITY_CHOICES = [
        ('low', 'Low'),
        ('normal', 'Normal'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    ]
    CATEGORY_CHOICES = [
        ('order', 'Order issue'),
        ('payment', 'Payment / refund'),
        ('shipping', 'Shipping / delivery'),
        ('product', 'Product question'),
        ('credit', 'Credit / billing'),
        ('account', 'Account / login'),
        ('other', 'Other'),
    ]

    ticket_number = models.CharField(max_length=20, unique=True, editable=False, db_index=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                             related_name='support_tickets', null=True, blank=True)
    guest_email = models.EmailField(max_length=255, null=True, blank=True)
    guest_name = models.CharField(max_length=255, null=True, blank=True)
    subject = models.CharField(max_length=200)
    category = models.CharField(max_length=12, choices=CATEGORY_CHOICES, default='other')
    priority = models.CharField(max_length=8, choices=PRIORITY_CHOICES, default='normal', db_index=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open', db_index=True)
    related_order = models.ForeignKey(
        'orders.Order', null=True, blank=True, on_delete=models.SET_NULL,
        related_name='support_tickets',
    )
    assigned_to = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL,
        related_name='assigned_tickets',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    closed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'support_tickets'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'status']),
            models.Index(fields=['priority', 'status']),
        ]

    def save(self, *args, **kwargs):
        if not self.ticket_number:
            self.ticket_number = self._generate_number()
        super().save(*args, **kwargs)

    @transaction.atomic
    def _generate_number(self):
        from django.utils import timezone
        year = timezone.now().year
        # Atomic increment via a counter row would be cleaner, but for our
        # volume a count-based suffix is fine and the unique=True on
        # ticket_number guarantees correctness even under races.
        last = (SupportTicket.objects
                .select_for_update()
                .filter(ticket_number__startswith=f'TKT-{year}-')
                .order_by('-ticket_number')
                .first())
        next_seq = 1
        if last:
            try:
                next_seq = int(last.ticket_number.split('-')[-1]) + 1
            except (ValueError, IndexError):
                next_seq = SupportTicket.objects.count() + 1
        return f'TKT-{year}-{next_seq:05d}'

    def __str__(self):
        return f'{self.ticket_number} — {self.subject}'


class FaqEntry(models.Model):
    """
    Admin-curated Q&A used by the support chatbot.

    Matching strategy:
      - `triggers` is a JSON list of lowercased keywords / short phrases.
        When a user message contains any of them (substring match), this
        entry is a candidate.
      - The candidate with the most trigger matches wins. Tie -> lowest
        `sort_order` -> newest.

    `topic` is a free-form grouping label ("Package & delivery",
    "Payment & refund", ...). Useful for rendering the quick-pick
    buttons at the start of a chat.

    `follow_up_prompts` is an optional list of strings shown as quick-reply
    chips under the bot's answer ("Track my order", "Cancel order", ...).
    Each prompt re-enters the bot loop with that text as the user message.
    """
    topic = models.CharField(max_length=80, db_index=True,
                             help_text='Group label, e.g. "Package & delivery".')
    question = models.CharField(max_length=240,
                                help_text='What this Q&A answers, shown as a quick chip.')
    answer = models.TextField(help_text='Bot reply (plain text or simple markdown).')
    triggers = models.JSONField(
        default=list, blank=True,
        help_text='Lowercased keywords/phrases the bot matches against.',
    )
    follow_up_prompts = models.JSONField(
        default=list, blank=True,
        help_text='Suggested next questions to chip-render after this answer.',
    )
    sort_order = models.PositiveIntegerField(default=100, db_index=True)
    is_active = models.BooleanField(default=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'support_faq_entries'
        ordering = ['sort_order', '-updated_at']

    def __str__(self):
        return f'{self.topic} — {self.question[:60]}'


class TicketMessage(models.Model):
    ticket = models.ForeignKey(SupportTicket, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                               related_name='ticket_messages', null=True, blank=True)
    body = models.TextField()
    is_internal_note = models.BooleanField(
        default=False,
        help_text='Internal notes visible only to admins/agents.',
    )
    attachment_url = models.URLField(max_length=500, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'support_ticket_messages'
        ordering = ['created_at']
