from django.contrib import admin
from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    readonly_fields = ('product', 'quantity', 'price', 'original_price', 'subtotal_display')
    extra = 0

    def subtotal_display(self, obj):
        return f'₹{obj.subtotal:,.2f}'
    subtotal_display.short_description = 'Subtotal'


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = (
        'order_id', 'user_name', 'user_email', 'total_display',
        'payment_status', 'order_status', 'erp_sync_status', 'created_at'
    )
    list_filter = ('payment_status', 'order_status', 'erp_sync_status')
    list_editable = ('order_status',)
    search_fields = ('order_id', 'user_email', 'user_name')
    ordering = ('-created_at',)
    readonly_fields = ('order_id', 'erp_order_id', 'created_at', 'updated_at')
    inlines = [OrderItemInline]

    def total_display(self, obj):
        return f'₹{obj.total_amount:,.2f}'
    total_display.short_description = 'Total'
