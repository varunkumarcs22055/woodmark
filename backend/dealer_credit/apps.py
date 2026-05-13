from django.apps import AppConfig


class DealerCreditConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'dealer_credit'

    def ready(self):
        # Register signal handlers (post_save on Order/DealerPayment/DealerCredit).
        from . import signals  # noqa: F401
