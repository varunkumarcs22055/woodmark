from django.contrib import admin
from .models import Review, ReviewVote


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('product', 'user', 'rating', 'status', 'verified_purchase', 'created_at')
    list_filter = ('status', 'rating', 'verified_purchase')
    search_fields = ('product__name', 'user__email', 'title', 'body')
    date_hierarchy = 'created_at'


@admin.register(ReviewVote)
class ReviewVoteAdmin(admin.ModelAdmin):
    list_display = ('review', 'user', 'value', 'created_at')
