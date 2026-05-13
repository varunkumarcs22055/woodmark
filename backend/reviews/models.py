from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Review(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    product = models.ForeignKey('products.Product', on_delete=models.CASCADE, related_name='reviews')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='reviews')
    order_item = models.ForeignKey(
        'orders.OrderItem', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='reviews',
        help_text='When set, marks this review as a verified purchase.',
    )

    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
    )
    title = models.CharField(max_length=120, blank=True)
    body = models.TextField()

    verified_purchase = models.BooleanField(default=False, db_index=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending', db_index=True)
    helpful_count = models.PositiveIntegerField(default=0)
    moderator = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='moderated_reviews',
    )
    moderated_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'reviews'
        ordering = ['-created_at']
        constraints = [
            models.UniqueConstraint(fields=['product', 'user'], name='one_review_per_user_per_product'),
        ]
        indexes = [
            models.Index(fields=['product', 'status', '-created_at']),
        ]

    def save(self, *args, **kwargs):
        # Set verified_purchase if the user has an OrderItem for this product.
        if not self.pk and not self.verified_purchase:
            from orders.models import OrderItem
            self.verified_purchase = OrderItem.objects.filter(
                order__user=self.user, product=self.product,
            ).exists()
            if self.verified_purchase and self.order_item_id is None:
                first_item = OrderItem.objects.filter(
                    order__user=self.user, product=self.product,
                ).order_by('-id').first()
                if first_item:
                    self.order_item = first_item
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.user_id} on product {self.product_id}: {self.rating}*'


class ReviewVote(models.Model):
    review = models.ForeignKey(Review, on_delete=models.CASCADE, related_name='votes')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='review_votes')
    value = models.SmallIntegerField(default=1, help_text='+1 helpful, -1 not helpful.')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'review_votes'
        constraints = [
            models.UniqueConstraint(fields=['review', 'user'], name='one_vote_per_user_per_review'),
        ]

    def __str__(self):
        return f'{self.user_id} voted {self.value} on review {self.review_id}'
