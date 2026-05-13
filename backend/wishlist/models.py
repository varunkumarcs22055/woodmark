from django.conf import settings
from django.db import models


class WishlistItem(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='wishlist_items')
    product = models.ForeignKey('products.Product', on_delete=models.CASCADE, related_name='wishlisted_by')
    variant = models.ForeignKey(
        'products.ProductVariant', null=True, blank=True,
        on_delete=models.CASCADE, related_name='wishlisted_by',
    )
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'wishlist_items'
        ordering = ['-added_at']
        constraints = [
            models.UniqueConstraint(
                fields=['user', 'product', 'variant'],
                name='one_wishlist_row_per_user_product_variant',
            ),
        ]

    def __str__(self):
        return f'{self.user_id} ❤ {self.product_id}'
