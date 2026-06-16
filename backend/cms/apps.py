from django.apps import AppConfig


class CmsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'cms'

    def ready(self):
        # Wire the post-save signal that pins Banner uploads into the
        # `woodmark/banners` Cloudinary asset folder (dynamic-mode).
        from . import signals  # noqa: F401
