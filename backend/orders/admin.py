"""
Orders app — Admin configuration.
"""

from django.contrib import admin
from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    """Inline display of order items within Order admin."""
    model = OrderItem
    readonly_fields = ('product', 'quantity', 'price', 'subtotal')
    extra = 0
    can_delete = False


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    """Admin interface for managing orders."""
    list_display = (
        'order_id', 'user_name', 'user_email', 'total_amount',
        'payment_status', 'order_status', 'erp_order_id', 'created_at'
    )
    list_filter = ('payment_status', 'order_status', 'created_at')
    search_fields = ('order_id', 'user_name', 'user_email')
    readonly_fields = ('order_id', 'total_amount', 'created_at')
    list_editable = ('order_status',)  # Quick-update order status from list
    inlines = [OrderItemInline]
    list_per_page = 25

    fieldsets = (
        ('Order Info', {
            'fields': ('order_id', 'total_amount', 'payment_status', 'order_status', 'created_at')
        }),
        ('Customer Info', {
            'fields': ('user_name', 'user_email', 'phone', 'address')
        }),
        ('ERP', {
            'fields': ('erp_order_id',),
            'classes': ('collapse',),
        }),
    )
