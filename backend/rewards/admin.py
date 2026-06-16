from django.contrib import admin

from .models import (
    LoyaltyAccount, LoyaltyTransaction, Referral,
    GiftCard, GiftCardTransaction,
)


@admin.register(LoyaltyAccount)
class LoyaltyAccountAdmin(admin.ModelAdmin):
    list_display = ('user', 'points_balance', 'lifetime_earned', 'updated_at')
    search_fields = ('user__email',)


@admin.register(LoyaltyTransaction)
class LoyaltyTransactionAdmin(admin.ModelAdmin):
    list_display = ('account', 'kind', 'points', 'balance_after', 'order', 'created_at')
    list_filter = ('kind',)
    search_fields = ('account__user__email', 'reason')


@admin.register(Referral)
class ReferralAdmin(admin.ModelAdmin):
    list_display = ('code', 'referrer', 'referee', 'rewarded', 'created_at')
    list_filter = ('rewarded',)
    search_fields = ('code', 'referrer__email', 'referee__email')


@admin.register(GiftCard)
class GiftCardAdmin(admin.ModelAdmin):
    list_display = ('code', 'initial_amount', 'balance', 'is_active', 'purchaser', 'created_at')
    list_filter = ('is_active',)
    search_fields = ('code', 'recipient_email', 'purchaser__email')
    readonly_fields = ('code', 'initial_amount', 'created_at')


@admin.register(GiftCardTransaction)
class GiftCardTransactionAdmin(admin.ModelAdmin):
    list_display = ('gift_card', 'amount', 'balance_after', 'order', 'created_at')
    search_fields = ('gift_card__code',)
