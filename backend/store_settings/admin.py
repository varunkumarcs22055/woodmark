from django.contrib import admin
from .models import StoreSettings


@admin.register(StoreSettings)
class StoreSettingsAdmin(admin.ModelAdmin):
    list_display = ('gst_percent', 'free_shipping_threshold', 'standard_shipping_fee', 'updated_at')
    readonly_fields = ('updated_at', 'updated_by')

    def has_add_permission(self, request):
        return not StoreSettings.objects.exists()

    def has_delete_permission(self, request, obj=None):
        return False
