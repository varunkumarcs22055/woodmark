"""
Cloudinary lifecycle hooks for Banner.

Three behaviours, mirroring the products app:

  1. pre_save(Banner)  -> if .image was replaced (not deleted), destroy the
                          previous asset BEFORE the row is updated, so the
                          swap doesn't leave an orphan in the Media Library.
  2. post_save(Banner) -> pin the new asset's `asset_folder` to
                          `woodmark/banners` so the dashboard tree is
                          correct on dynamic-folder accounts.
  3. post_delete(Banner) -> destroy the asset behind .image.

All Cloudinary calls route through `services.cloudinary`. Failures NEVER
block the DB transaction.
"""
import logging

from django.db.models.signals import pre_save, post_save, post_delete
from django.dispatch import receiver

from services import cloudinary as cdn
from .models import Banner

logger = logging.getLogger(__name__)
TARGET_FOLDER = 'woodmark/banners'


def _public_id(field) -> str:
    if not field:
        return ''
    pid = getattr(field, 'public_id', None)
    return pid if pid else str(field)


@receiver(pre_save, sender=Banner)
def _destroy_replaced_image(sender, instance, **kwargs):
    if not cdn.is_configured() or not instance.pk:
        return
    try:
        old = Banner.objects.only('image').get(pk=instance.pk)
    except Banner.DoesNotExist:
        return
    old_pid = _public_id(old.image)
    new_pid = _public_id(instance.image)
    if old_pid and old_pid != new_pid:
        cdn.destroy(old_pid, kind='image')


@receiver(post_save, sender=Banner)
def _pin_folder(sender, instance, created, **kwargs):
    if not cdn.is_configured():
        return
    pid = _public_id(instance.image)
    if pid:
        cdn.pin_asset_folder(pid, TARGET_FOLDER)


@receiver(post_delete, sender=Banner)
def _destroy_on_delete(sender, instance, **kwargs):
    if not cdn.is_configured():
        return
    pid = _public_id(instance.image)
    if pid:
        cdn.destroy(pid, kind='image')
