"""
Recompute Product.rating_avg / rating_count whenever an approved review
changes. Cheap aggregate over a product's approved reviews — fine at this
scale; for very high write volume, switch to incremental updates.
"""
from decimal import Decimal

from django.db.models import Avg, Count
from django.db.models.signals import post_delete, post_save
from django.dispatch import receiver

from products.models import Product

from .models import Review


def _recompute(product_id):
    qs = Review.objects.filter(product_id=product_id, status='approved')
    agg = qs.aggregate(avg=Avg('rating'), count=Count('id'))
    Product.objects.filter(pk=product_id).update(
        rating_avg=Decimal(str(agg['avg'] or 0)).quantize(Decimal('0.01')),
        rating_count=agg['count'] or 0,
    )


@receiver(post_save, sender=Review)
def recompute_on_save(sender, instance, **kwargs):
    _recompute(instance.product_id)


@receiver(post_delete, sender=Review)
def recompute_on_delete(sender, instance, **kwargs):
    _recompute(instance.product_id)
