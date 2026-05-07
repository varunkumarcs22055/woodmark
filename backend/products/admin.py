from django.contrib import admin
from .models import Category, Product, ProductMedia


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'product_count')
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ('name',)

    def product_count(self, obj):
        return obj.products.count()
    product_count.short_description = 'Products'


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'material', 'stock', 'in_stock', 'is_featured', 'created_at')
    list_filter = ('category', 'material', 'is_featured')
    list_editable = ('price', 'stock', 'is_featured')
    search_fields = ('name', 'description', 'color')
    prepopulated_fields = {'slug': ('name',)}
    ordering = ('-created_at',)
    readonly_fields = ('created_at', 'updated_at', 'slug')


@admin.register(ProductMedia)
class ProductMediaAdmin(admin.ModelAdmin):
    list_display = ('product', 'kind', 'is_primary', 'order', 'created_at')
    list_filter = ('kind', 'is_primary')
    search_fields = ('product__name',)
    list_editable = ('is_primary', 'order')
