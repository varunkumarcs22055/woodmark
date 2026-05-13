from django.contrib import admin
from .models import Banner, Page, FAQ, ContentBlock, NewsletterSubscriber, NewsletterCampaign


@admin.register(Banner)
class BannerAdmin(admin.ModelAdmin):
    list_display = ('title', 'placement', 'is_active', 'sort_order', 'starts_at', 'ends_at')
    list_filter = ('placement', 'is_active')
    search_fields = ('title',)


@admin.register(Page)
class PageAdmin(admin.ModelAdmin):
    list_display = ('slug', 'title', 'is_published', 'updated_at')
    list_filter = ('is_published',)
    search_fields = ('slug', 'title')


@admin.register(FAQ)
class FAQAdmin(admin.ModelAdmin):
    list_display = ('question', 'category', 'sort_order', 'is_active')
    list_filter = ('category', 'is_active')
    search_fields = ('question', 'answer')


@admin.register(ContentBlock)
class ContentBlockAdmin(admin.ModelAdmin):
    list_display = ('key', 'title', 'is_active', 'updated_at')
    list_filter = ('is_active',)
    search_fields = ('key', 'title')


@admin.register(NewsletterSubscriber)
class NewsletterSubscriberAdmin(admin.ModelAdmin):
    list_display = ('email', 'is_active', 'created_at')
    list_filter = ('is_active',)
    search_fields = ('email',)


@admin.register(NewsletterCampaign)
class NewsletterCampaignAdmin(admin.ModelAdmin):
    list_display = ('subject', 'status', 'created_at', 'sent_at')
    list_filter = ('status',)
    search_fields = ('subject',)
