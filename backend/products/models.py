from django.db import models
from django.utils.text import slugify
from cloudinary.models import CloudinaryField


class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True, blank=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'categories'
        verbose_name_plural = 'Categories'
        ordering = ['name']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class Product(models.Model):
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
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='products')
    material = models.CharField(max_length=50, choices=MATERIAL_CHOICES)
    color = models.CharField(max_length=50)
    dimensions = models.CharField(max_length=100, help_text='e.g., 120x60x75 cm')
    image_url = models.URLField(max_length=500)
    stock = models.PositiveIntegerField(default=0)
    is_featured = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['category']),
            models.Index(fields=['material']),
            models.Index(fields=['price']),
        ]

    def save(self, *args, **kwargs):
        if not self.slug:
            base_slug = slugify(self.name)
            slug = base_slug
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
        return self.stock > 0


class ProductMedia(models.Model):
    MEDIA_KIND = [('image', 'Image'), ('video', 'Video')]
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='media')
    kind = models.CharField(max_length=8, choices=MEDIA_KIND, default='image')
    file = CloudinaryField('media', resource_type='auto', blank=True, null=True)
    is_primary = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)
    alt_text = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'product_media'
        ordering = ['order', 'id']
        indexes = [models.Index(fields=['product', 'is_primary'])]

    @property
    def url(self):
        if self.file:
            try:
                return self.file.url
            except Exception:
                return str(self.file)
        return None

    def __str__(self):
        return f'{self.product.name} — {self.kind} ({self.id})'
