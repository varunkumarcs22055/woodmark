"""Users app — Admin configuration."""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    """Custom user admin with default UserAdmin features."""
    pass
