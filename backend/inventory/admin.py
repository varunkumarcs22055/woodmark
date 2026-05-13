from django.contrib import admin
from .models import Warehouse, StockLevel, StockMovement


@admin.register(Warehouse)
class WarehouseAdmin(admin.ModelAdmin):
    list_display = ('name', 'code', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('name', 'code')


@admin.register(StockLevel)
class StockLevelAdmin(admin.ModelAdmin):
    list_display = ('product', 'variant', 'warehouse', 'quantity', 'low_threshold', 'updated_at')
    list_filter = ('warehouse',)
    search_fields = ('product__name', 'product__sku')


@admin.register(StockMovement)
class StockMovementAdmin(admin.ModelAdmin):
    list_display = ('created_at', 'stock_level', 'delta', 'reason', 'actor')
    list_filter = ('reason',)
    search_fields = ('reference', 'note')
    date_hierarchy = 'created_at'
