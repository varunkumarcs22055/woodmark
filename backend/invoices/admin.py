from django.contrib import admin
from .models import Invoice, InvoiceItem, InvoiceCounter


class InvoiceItemInline(admin.TabularInline):
    model = InvoiceItem
    extra = 0
    readonly_fields = tuple(f.name for f in InvoiceItem._meta.fields if f.name != 'id')


@admin.register(Invoice)
class InvoiceAdmin(admin.ModelAdmin):
    list_display = ('invoice_number', 'order', 'billing_name',
                    'grand_total', 'payment_status', 'invoice_date')
    list_filter = ('payment_status',)
    search_fields = ('invoice_number', 'billing_name', 'order__order_id', 'customer__email')
    date_hierarchy = 'invoice_date'
    inlines = [InvoiceItemInline]
    readonly_fields = ('invoice_number', 'created_at', 'updated_at')


@admin.register(InvoiceCounter)
class InvoiceCounterAdmin(admin.ModelAdmin):
    list_display = ('year', 'last_seq')
