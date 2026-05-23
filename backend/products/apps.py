"""Products app configuration."""

from django.apps import AppConfig


class ProductsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'products'

    def ready(self):
        # Cloudinary lifecycle hooks (delete asset when ProductMedia /
        # Product is deleted; pin asset_folder on new uploads).
        from . import signals  # noqa: F401
