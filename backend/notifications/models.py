from django.conf import settings
from django.db import models


class Notification(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='notifications',
    )
    kind = models.CharField(
        max_length=40, db_index=True,
        help_text="e.g. 'order.created', 'order.shipped', 'low_stock', 'dealer.approved'.",
    )
    title = models.CharField(max_length=200)
    body = models.TextField(blank=True)
    payload = models.JSONField(default=dict, blank=True)
    is_read = models.BooleanField(default=False, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'is_read', '-created_at']),
        ]

    def __str__(self):
        return f'{self.kind}: {self.title[:60]}'


class NotificationPreference(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notification_preferences',
    )
    email_order_updates = models.BooleanField(default=True)
    email_marketing = models.BooleanField(default=False)
    sms_order_updates = models.BooleanField(default=True)
    sms_marketing = models.BooleanField(default=False)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'notification_preferences'

    def __str__(self):
        return f'Preferences for {self.user_id}'


class Subscriber(models.Model):
    email = models.EmailField(unique=True)
    is_active = models.BooleanField(default=True)
    welcomed_at = models.DateTimeField(null=True, blank=True,
                                       help_text='Set when the welcome email succeeds.')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'subscribers'
        ordering = ['-created_at']

    def __str__(self):
        return self.email


class Newsletter(models.Model):
    TARGET_GROUPS = [
        ('all', 'All'),
        ('subscribers', 'Subscribers Only'),
        ('customers', 'Customers Only'),
        ('dealers', 'Active Dealers Only'),
        ('custom', 'Custom Selection'),
    ]
    subject = models.CharField(max_length=255)
    content = models.TextField()
    target_group = models.CharField(max_length=20, choices=TARGET_GROUPS)
    sent_to_emails = models.JSONField(default=list, help_text="List of emails this was sent to")
    sent_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'newsletters'
        ordering = ['-sent_at']

    def __str__(self):
        return self.subject
