from django.conf import settings
from django.db import models


class AuditLog(models.Model):
    """
    Append-only log of admin mutations. Written by AuditedMixin (see mixins.py).
    Sensitive payload fields ('password', 'token', 'secret', 'refresh') are
    redacted before insert.
    """
    ACTION_CHOICES = [
        ('create', 'Create'),
        ('update', 'Update'),
        ('delete', 'Delete'),
        ('login', 'Login'),
        ('logout', 'Logout'),
        ('block', 'Block'),
        ('unblock', 'Unblock'),
        ('approve', 'Approve'),
        ('reject', 'Reject'),
        ('refund', 'Refund'),
        ('cancel', 'Cancel'),
        ('export', 'Export'),
        ('other', 'Other'),
    ]

    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='audit_logs',
    )
    action = models.CharField(max_length=20, choices=ACTION_CHOICES, db_index=True)
    target_type = models.CharField(max_length=80, db_index=True)
    target_id = models.CharField(max_length=80, db_index=True, blank=True)
    payload = models.JSONField(default=dict, blank=True)
    ip = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.CharField(max_length=300, blank=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = 'audit_logs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['target_type', 'target_id']),
            models.Index(fields=['actor', '-created_at']),
        ]

    def __str__(self):
        actor = self.actor.email if self.actor else 'system'
        return f'[{self.created_at:%Y-%m-%d %H:%M}] {actor} {self.action} {self.target_type}#{self.target_id}'
