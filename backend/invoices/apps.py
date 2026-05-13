from django.apps import AppConfig


class InvoicesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'invoices'

    def ready(self):
        # Wire signals (auto-create invoice on payment success)
        from . import signals  # noqa: F401
