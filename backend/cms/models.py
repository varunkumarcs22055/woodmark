from django.db import models
from cloudinary.models import CloudinaryField

class Banner(models.Model):
    PLACEMENT_CHOICES = [
        ('home_hero', 'Home Hero'),
        ('home_strip', 'Home Strip'),
        ('category_top', 'Category Top'),
    ]
    title = models.CharField(max_length=200)
    image = CloudinaryField('banner', null=True, blank=True)
    image_url = models.URLField(max_length=500, blank=True, help_text="Fallback when not using Cloudinary upload.")
    link_url = models.URLField(blank=True)
    placement = models.CharField(max_length=20, choices=PLACEMENT_CHOICES, db_index=True)
    is_active = models.BooleanField(default=True)
    sort_order = models.PositiveIntegerField(default=0)
    starts_at = models.DateTimeField(null=True, blank=True)
    ends_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'cms_banners'
        ordering = ['placement', 'sort_order', 'id']

    @property
    def resolved_image_url(self):
        if self.image:
            return self.image.url
        return self.image_url

class FAQ(models.Model):
    question = models.CharField(max_length=300)
    answer = models.TextField()
    category = models.CharField(max_length=50, blank=True, db_index=True)
    sort_order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "FAQ"
        verbose_name_plural = "FAQs"
        db_table = 'cms_faqs'
        ordering = ['category', 'sort_order', 'id']

class Page(models.Model):
    slug = models.SlugField(max_length=80, unique=True)
    title = models.CharField(max_length=200)
    body_md = models.TextField(help_text="Markdown source.")
    is_published = models.BooleanField(default=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cms_pages'
        ordering = ['slug']

class NewsletterSubscriber(models.Model):
    email = models.EmailField(unique=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cms_newsletter'

    def __str__(self):
        return self.email


class ContentBlock(models.Model):
    key = models.SlugField(max_length=80, unique=True)
    title = models.CharField(max_length=200, blank=True)
    body_md = models.TextField(blank=True)
    data_json = models.JSONField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cms_content_blocks'
        ordering = ['key']

    def __str__(self):
        return self.key


class NewsletterCampaign(models.Model):
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('queued', 'Queued'),
        ('sent', 'Sent'),
        ('failed', 'Failed'),
    ]
    subject = models.CharField(max_length=200)
    body_md = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='queued')
    sent_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'cms_newsletter_campaigns'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.subject} ({self.status})"
