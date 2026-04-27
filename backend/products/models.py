"""
Products app — Models.

Defines Category and Product models for the furniture e-commerce platform.
All product data is managed via Django Admin.
"""

from django.db import models
from django.utils.text import slugify


class Category(models.Model):
    """
    Product category (e.g., Sofas, Tables, Chairs, Beds).
    Used for filtering and grouping products.
    """
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True, blank=True)

    class Meta:
        db_table = 'categories'
        verbose_name = 'Category'
        verbose_name_plural = 'Categories'
        ordering = ['name']

    def save(self, *args, **kwargs):
        """Auto-generate slug from name if not provided."""
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class Product(models.Model):
    """
    Product model representing a furniture item.
    All fields are managed via Django Admin panel.
    """

    # Material choices for furniture
    MATERIAL_CHOICES = [
        ('wood', 'Wood'),
        ('metal', 'Metal'),
        ('fabric', 'Fabric'),
        ('leather', 'Leather'),
        ('glass', 'Glass'),
        ('plastic', 'Plastic'),
        ('marble', 'Marble'),
        ('rattan', 'Rattan'),
    ]

    name = models.CharField(max_length=200)
    slug = models.SlugField(max_length=200, unique=True, blank=True)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.ForeignKey(
        Category,
        on_delete=models.CASCADE,
        related_name='products'
    )
    material = models.CharField(max_length=50, choices=MATERIAL_CHOICES)
    color = models.CharField(max_length=50)
    dimensions = models.CharField(
        max_length=100,
        help_text='e.g., 120x60x75 cm'
    )
    image_url = models.URLField(
        max_length=500,
        help_text='External URL for the product image'
    )
    stock = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        """Auto-generate slug from name if not provided."""
        if not self.slug:
            base_slug = slugify(self.name)
            slug = base_slug
            # Ensure uniqueness
            counter = 1
            while Product.objects.filter(slug=slug).exclude(pk=self.pk).exists():
                slug = f'{base_slug}-{counter}'
                counter += 1
            self.slug = slug
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    @property
    def in_stock(self):
        """Check if product is available."""
        return self.stock > 0
