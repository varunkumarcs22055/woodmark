from django.contrib import admin
from .models import Discount


@admin.register(Discount)
class DiscountAdmin(admin.ModelAdmin):
    list_display = (
        'product', 'discount_type', 'mode', 'value',
        'count_limit', 'units_sold', 'units_remaining_display',
        'active', 'ends_at'
    )
    list_filter = ('discount_type', 'mode', 'active')
    list_editable = ('active',)
    search_fields = ('product__name',)
    readonly_fields = ('units_sold', 'created_at', 'updated_at')

    def units_remaining_display(self, obj):
        if obj.count_limit is None:
            return '∞'
        return obj.units_remaining
    units_remaining_display.short_description = 'Remaining'
