"""
Cloudinary lifecycle hooks for product media.

Three behaviours wired here:

  1. pre_save(ProductMedia)  -> if the .file changed (replacement, not
                                 deletion), destroy the previous asset
                                 BEFORE the row is updated. Without this,
                                 every "swap product photo" leaves the
                                 old image orphaned in the Media Library.
  2. post_delete(ProductMedia) -> destroy the asset behind .file.
  3. post_delete(Product)    -> sweep stragglers under the product
                                 folder and remove the now-empty folder
                                 from the dashboard tree.

All Cloudinary calls route through `services.cloudinary` (retries +
logging + central config). Failures NEVER block the DB transaction.
"""
import logging

from django.db.models.signals import pre_save, post_delete
from django.dispatch import receiver
from django.utils.text import slugify

from services import cloudinary as cdn
from .models import Product, ProductMedia

logger = logging.getLogger(__name__)


def _public_id(field) -> str:
    """`ProductMedia.file` is a CloudinaryField; return its public_id."""
    if not field:
        return ''
    pid = getattr(field, 'public_id', None)
    return pid if pid else str(field)


@receiver(pre_save, sender=ProductMedia)
def _pin_and_swap_on_save(sender, instance, **kwargs):
    if not cdn.is_configured():
        return

    # When an existing row has its .file replaced, destroy the OLD asset
    # so the swap doesn't leave an orphan behind.
    if instance.pk:
        try:
            old = ProductMedia.objects.only('file', 'kind').get(pk=instance.pk)
        except ProductMedia.DoesNotExist:
            old = None
        if old:
            old_pid = _public_id(old.file)
            new_pid = _public_id(instance.file)
            if old_pid and old_pid != new_pid:
                cdn.destroy(old_pid, kind=old.kind)

    # Pin the new asset to the right per-product folder so the dashboard
    # tree always reflects the right hierarchy. Idempotent — safe even
    # if _attach_media already set it during upload.
    new_pid = _public_id(instance.file)
    if new_pid:
        slug = instance.product.slug or slugify(instance.product.name)
        target = f'woodmark/products/{slug}'
        cdn.pin_asset_folder(new_pid, target)


@receiver(post_delete, sender=ProductMedia)
def _destroy_on_delete(sender, instance, **kwargs):
    if not cdn.is_configured():
        return
    pid = _public_id(instance.file)
    if pid:
        cdn.destroy(pid, kind=instance.kind)


@receiver(post_delete, sender=Product)
def _delete_folder_for_product(sender, instance, **kwargs):
    if not cdn.is_configured():
        return
    slug = instance.slug or slugify(instance.name)
    folder = f'woodmark/products/{slug}'
    summary = cdn.destroy_folder(folder)
    logger.info('Product %s deleted; folder %s -> %s',
                instance.pk, folder, summary)
