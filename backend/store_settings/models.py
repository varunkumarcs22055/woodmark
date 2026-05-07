from decimal import Decimal
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


class StoreSettings(models.Model):
    gst_percent = models.DecimalField(
        max_digits=5, decimal_places=2, default=Decimal('18.00'),
        validators=[MinValueValidator(Decimal('0')), MaxValueValidator(Decimal('100'))],
    )
    free_shipping_threshold = models.DecimalField(
        max_digits=10, decimal_places=2, default=Decimal('2999.00'),
    )
    standard_shipping_fee = models.DecimalField(
        max_digits=10, decimal_places=2, default=Decimal('499.00'),
    )
    updated_at = models.DateTimeField(auto_now=True)
    updated_by = models.ForeignKey(
        'users.User', on_delete=models.SET_NULL, null=True, blank=True,
    )

    class Meta:
        db_table = 'store_settings'

    def save(self, *args, **kwargs):
        self.pk = 1
        super().save(*args, **kwargs)

    @classmethod
    def current(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj

    def __str__(self):
        return f'StoreSettings (GST {self.gst_percent}%)'
