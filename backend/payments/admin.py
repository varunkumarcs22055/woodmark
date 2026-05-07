from django.contrib import admin
from .models import Payment


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ('order', 'status', 'amount_display', 'razorpay_payment_id', 'created_at')
    list_filter = ('status',)
    search_fields = ('order__order_id', 'razorpay_payment_id', 'order__user_email')
    readonly_fields = (
        'order', 'razorpay_order_id', 'razorpay_payment_id',
        'razorpay_signature', 'created_at', 'updated_at'
    )

    def amount_display(self, obj):
        return f'₹{obj.amount:,.2f}'
    amount_display.short_description = 'Amount'
