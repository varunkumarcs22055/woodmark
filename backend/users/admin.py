from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ('email', 'first_name', 'last_name', 'role', 'dealer_status', 'is_active', 'date_joined')
    list_filter = ('role', 'dealer_status', 'is_active', 'is_staff')
    search_fields = ('email', 'first_name', 'last_name', 'dealer_company_name')
    ordering = ('-date_joined',)
    list_editable = ('role', 'dealer_status')

    fieldsets = UserAdmin.fieldsets + (
        ('FurnoTech Fields', {
            'fields': ('role', 'phone', 'dealer_status', 'dealer_company_name', 'dealer_gst_number'),
        }),
    )

    add_fieldsets = UserAdmin.add_fieldsets + (
        ('FurnoTech Fields', {
            'fields': ('email', 'role', 'phone'),
        }),
    )
