from django.conf import settings
from django.db import models


class MediaAsset(models.Model):
    KIND_CHOICES = [
        ('image', 'Image'),
        ('video', 'Video'),
        ('raw', 'Raw'),
    ]

    public_id = models.CharField(max_length=200, unique=True, db_index=True)
    secure_url = models.URLField(max_length=500)
    kind = models.CharField(max_length=8, choices=KIND_CHOICES, default='image')
    bytes = models.PositiveIntegerField(default=0)
    width = models.PositiveIntegerField(null=True, blank=True)
    height = models.PositiveIntegerField(null=True, blank=True)
    folder = models.CharField(max_length=120, blank=True, db_index=True)
    tags = models.JSONField(default=list, blank=True)
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='media_uploads',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'media_assets'
        ordering = ['-created_at']

    def __str__(self):
        return self.public_id
