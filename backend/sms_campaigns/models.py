"""
SMS Campaigns — data model layer.

Three tables:
  Contact     — normalised phone number (E.164), optional name and tags.
  Campaign    — message template, audience selection, status + counts.
  Delivery    — per-recipient send status and provider response.

Design notes:
  - Contacts are de-duped by phone number (unique constraint).
  - Campaign.audience is a JSON blob storing the chosen filter criteria so the
    send worker can materialise the recipient list at dispatch time.
  - Delivery rows are created in bulk when a campaign is queued, and updated
    one-by-one (or in small batches) as the provider responds.
"""
import re
import uuid

from django.conf import settings
from django.db import models


def normalize_phone(raw):
    """
    Accept 10-digit Indian number, +91XXXXXXXXXX, or 91XXXXXXXXXX.
    Returns E.164: +91XXXXXXXXXX, or the original value if it can't be parsed.
    """
    digits = re.sub(r'\D', '', (raw or '').strip())
    if len(digits) == 10:
        return f'+91{digits}'
    if len(digits) == 12 and digits.startswith('91'):
        return f'+{digits}'
    if len(digits) == 13 and digits.startswith('91'):
        return f'+{digits}'  # already E.164 with +
    # Return cleaned if nothing fits — let the UI show a warning.
    if raw and raw.startswith('+'):
        return raw.strip()
    return f'+{digits}' if digits else raw


class Contact(models.Model):
    """A phone-book entry for SMS outreach."""
    phone = models.CharField(max_length=20, unique=True, db_index=True)
    name = models.CharField(max_length=120, blank=True)
    tag = models.CharField(max_length=80, blank=True, db_index=True,
                           help_text='Free-form tag for segmentation, e.g. "diwali", "dealer".')
    source = models.CharField(max_length=30, default='manual',
                              help_text='How this number was added: manual, csv, customer, dealer.')
    is_active = models.BooleanField(default=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'sms_contacts'
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        self.phone = normalize_phone(self.phone)
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.phone} ({self.name})' if self.name else self.phone


class Campaign(models.Model):
    AUDIENCE_CHOICES = [
        ('all', 'All contacts'),
        ('customers', 'Registered customers'),
        ('dealers', 'Dealers'),
        ('manual', 'Manual list / CSV import'),
        ('wishlist', 'Wishlist owners'),
        ('high_value', 'High-value order customers (>50k)'),
        ('tag', 'By tag'),
    ]
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('queued', 'Queued'),
        ('sending', 'Sending'),
        ('sent', 'Sent'),
        ('failed', 'Failed'),
    ]

    uid = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    name = models.CharField(max_length=200)
    message = models.TextField(max_length=1000,
                               help_text='Message body (max 1000 chars). Variables: {name}.')
    audience = models.CharField(max_length=20, choices=AUDIENCE_CHOICES, default='all')
    audience_tag = models.CharField(max_length=80, blank=True,
                                    help_text='Limit to contacts with this tag (when audience=tag).')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='draft', db_index=True)
    total_count = models.PositiveIntegerField(default=0)
    sent_count = models.PositiveIntegerField(default=0)
    failed_count = models.PositiveIntegerField(default=0)
    error_log = models.TextField(blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='sms_campaigns',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    sent_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'sms_campaigns'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.name} ({self.status})'


class Delivery(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('sent', 'Sent'),
        ('failed', 'Failed'),
    ]
    campaign = models.ForeignKey(Campaign, on_delete=models.CASCADE, related_name='deliveries')
    phone = models.CharField(max_length=20, db_index=True)
    name = models.CharField(max_length=120, blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending', db_index=True)
    provider_response = models.JSONField(default=dict, blank=True)
    sent_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'sms_deliveries'
        ordering = ['-id']
        indexes = [
            models.Index(fields=['campaign', 'status']),
        ]

    def __str__(self):
        return f'{self.phone} – {self.status}'
