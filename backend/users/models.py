"""
Users app — models.

Using Django's built-in User model for now.
This file is a placeholder for future custom user model extensions.
"""

from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    """
    Custom user model extending Django's AbstractUser.
    Allows easy extension later (e.g., phone number, address, etc.)
    """
    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
