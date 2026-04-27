"""
Products app — Admin configuration.

Rich admin interface for managing products and categories.
"""

from django.contrib import admin
from .models import Category, Product


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """Admin interface for Category model."""
    list_display = ('name', 'slug', 'product_count')
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ('name',)

    def product_count(self, obj):
        """Display the number of products in this category."""
        return obj.products.count()
    product_count.short_description = 'Products'


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    """Admin interface for Product model with full management capabilities."""
    list_display = (
        'name', 'category', 'price', 'material',
        'color', 'stock', 'in_stock', 'created_at'
    )
    list_filter = ('category', 'material', 'color', 'created_at')
    search_fields = ('name', 'description')
    prepopulated_fields = {'slug': ('name',)}
    list_editable = ('price', 'stock')  # Quick-edit price and stock from list view
    list_per_page = 25
    readonly_fields = ('created_at',)

    fieldsets = (
        ('Basic Info', {
            'fields': ('name', 'slug', 'description', 'category')
        }),
        ('Pricing & Stock', {
            'fields': ('price', 'stock')
        }),
        ('Attributes', {
            'fields': ('material', 'color', 'dimensions')
        }),
        ('Media', {
            'fields': ('image_url',)
        }),
    )
