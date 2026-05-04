# Backend Prompt 5 — Products & Categories (Catalog Engine)

## Role
You are a senior backend engineer. Build the complete product catalog backend for FurniShop: Category and Product models, serializers, views, filters, admin configuration, and seed data management command.

---

## Context
This is the core catalog engine. The product listing supports pagination (12/page), filtering by category/price/material, full-text search, and ordering. Product detail is retrieved by slug (SEO-friendly). This app is used by all three user roles — the serializers return role-aware pricing after the discount system (Prompt 6) is integrated.

**Depends on:** Backend Prompts 1, 2
**Required by:** Backend Prompt 6 (discounts extend product serializers), Prompt 7 (orders reference products)

---

## Files to Create/Modify

```
backend/products/
├── models.py
├── serializers.py
├── views.py
├── filters.py
├── urls.py
├── admin.py
├── apps.py
├── management/
│   └── commands/
│       └── seed_products.py
└── tests/
    ├── __init__.py
    ├── test_models.py
    ├── test_serializers.py
    ├── test_views.py
    └── test_filters.py
```

---

## Models — `products/models.py`

```python
from django.db import models
from django.utils.text import slugify


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
```

---

## Serializers — `products/serializers.py`

Write three serializers:

### CategorySerializer
```python
class CategorySerializer(serializers.ModelSerializer):
    product_count = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'description', 'product_count']

    def get_product_count(self, obj):
        return obj.products.count()
```

### ProductListSerializer (for grid/listing — minimal fields)
```python
class ProductListSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_slug = serializers.CharField(source='category.slug', read_only=True)
    # Phase 2: effective_price, discount_applied, discount_units_remaining
    # will be added by the discounts app via serializer mixin

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'price', 'category', 'category_name',
            'category_slug', 'material', 'color', 'dimensions',
            'image_url', 'stock', 'in_stock', 'is_featured', 'created_at'
        ]
```

### ProductDetailSerializer (for detail page — full fields + nested category)
```python
class ProductDetailSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'description', 'price', 'category',
            'material', 'color', 'dimensions', 'image_url',
            'stock', 'in_stock', 'is_featured', 'created_at'
        ]
```

### ProductWriteSerializer (for Admin CRUD — writable)
```python
class ProductWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            'name', 'description', 'price', 'category',
            'material', 'color', 'dimensions', 'image_url', 'stock', 'is_featured'
        ]

    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError('Price must be greater than 0.')
        return value

    def validate_stock(self, value):
        if value < 0:
            raise serializers.ValidationError('Stock cannot be negative.')
        return value
```

---

## Filters — `products/filters.py`

```python
import django_filters
from .models import Product


class ProductFilter(django_filters.FilterSet):
    category = django_filters.CharFilter(field_name='category__slug', lookup_expr='exact')
    price_min = django_filters.NumberFilter(field_name='price', lookup_expr='gte')
    price_max = django_filters.NumberFilter(field_name='price', lookup_expr='lte')
    material = django_filters.CharFilter(field_name='material', lookup_expr='exact')
    in_stock = django_filters.BooleanFilter(method='filter_in_stock')

    class Meta:
        model = Product
        fields = ['category', 'price_min', 'price_max', 'material', 'in_stock']

    def filter_in_stock(self, queryset, name, value):
        if value:
            return queryset.filter(stock__gt=0)
        return queryset.filter(stock=0)
```

---

## Views — `products/views.py`

```python
from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from users.permissions import IsAdminRole
from .models import Product, Category
from .serializers import (
    ProductListSerializer, ProductDetailSerializer,
    CategorySerializer, ProductWriteSerializer
)
from .filters import ProductFilter


class ProductListView(generics.ListAPIView):
    """GET /api/products/ — list with filters, search, ordering, pagination."""
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductListSerializer
    filterset_class = ProductFilter
    search_fields = ['name', 'description', 'color']
    ordering_fields = ['price', 'created_at', 'name', 'stock']
    ordering = ['-created_at']
    permission_classes = [AllowAny]


class ProductDetailView(generics.RetrieveAPIView):
    """GET /api/products/{slug}/ — single product detail."""
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductDetailSerializer
    lookup_field = 'slug'
    permission_classes = [AllowAny]


class SimilarProductsView(APIView):
    """GET /api/products/similar/{id}/ — up to 4 same-category products."""
    permission_classes = [AllowAny]

    def get(self, request, pk):
        try:
            product = Product.objects.get(pk=pk)
        except Product.DoesNotExist:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)

        similar = (
            Product.objects
            .filter(category=product.category)
            .exclude(pk=product.pk)
            .select_related('category')[:4]
        )
        return Response(ProductListSerializer(similar, many=True).data)


class CategoryListView(generics.ListAPIView):
    """GET /api/products/categories/ — all categories, no pagination."""
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    pagination_class = None
    permission_classes = [AllowAny]


class ProductAdminViewSet(APIView):
    """
    Admin-only product CRUD.
    GET /api/products/admin/      — list all (no pagination limit for admin)
    POST /api/products/admin/     — create product
    PUT /api/products/admin/{id}/ — update product
    DELETE /api/products/admin/{id}/ — delete product
    """
    permission_classes = [IsAdminRole]

    def get(self, request):
        products = Product.objects.select_related('category').all()
        serializer = ProductListSerializer(products, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = ProductWriteSerializer(data=request.data)
        if serializer.is_valid():
            product = serializer.save()
            return Response(ProductDetailSerializer(product).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProductAdminDetailView(APIView):
    """PUT/DELETE /api/products/admin/{id}/"""
    permission_classes = [IsAdminRole]

    def get_object(self, pk):
        try:
            return Product.objects.get(pk=pk)
        except Product.DoesNotExist:
            return None

    def put(self, request, pk):
        product = self.get_object(pk)
        if not product:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ProductWriteSerializer(product, data=request.data, partial=True)
        if serializer.is_valid():
            product = serializer.save()
            return Response(ProductDetailSerializer(product).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        product = self.get_object(pk)
        if not product:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)
        product.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

---

## URLs — `products/urls.py`

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.ProductListView.as_view(), name='product-list'),
    path('categories/', views.CategoryListView.as_view(), name='category-list'),
    path('similar/<int:pk>/', views.SimilarProductsView.as_view(), name='similar-products'),
    path('admin/', views.ProductAdminViewSet.as_view(), name='product-admin-list'),
    path('admin/<int:pk>/', views.ProductAdminDetailView.as_view(), name='product-admin-detail'),
    path('<slug:slug>/', views.ProductDetailView.as_view(), name='product-detail'),
]
```

---

## Admin — `products/admin.py`

```python
from django.contrib import admin
from .models import Category, Product


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'product_count')
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ('name',)

    def product_count(self, obj):
        return obj.products.count()
    product_count.short_description = 'Products'


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'material', 'stock', 'in_stock', 'is_featured', 'created_at')
    list_filter = ('category', 'material', 'is_featured')
    list_editable = ('price', 'stock', 'is_featured')
    search_fields = ('name', 'description', 'color')
    prepopulated_fields = {'slug': ('name',)}
    ordering = ('-created_at',)
    readonly_fields = ('created_at', 'updated_at', 'slug')
```

---

## Seed Command — `management/commands/seed_products.py`

Create 8 categories and 2 products per category (16 total). Use Indian pricing (₹3,000 – ₹85,000). Use real Unsplash URLs for images.

Categories and their slugs (these MUST match the React frontend's NAV_ITEMS and CATEGORIES slugs):
```
sofas       → slug: sofas
tables      → slug: tables
chairs      → slug: chairs
beds        → slug: beds
storage     → slug: storage
desks       → slug: desks
dining-sets → slug: dining-sets
outdoor     → slug: outdoor
```

The command should be idempotent — running it twice must not create duplicate data:
```python
from django.core.management.base import BaseCommand
from products.models import Category, Product


class Command(BaseCommand):
    help = 'Seed the database with sample furniture products'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding products...')

        categories_data = [
            {'name': 'Sofas', 'slug': 'sofas', 'description': 'Comfortable sofas and sectionals'},
            {'name': 'Tables', 'slug': 'tables', 'description': 'Dining and coffee tables'},
            {'name': 'Chairs', 'slug': 'chairs', 'description': 'Office and accent chairs'},
            {'name': 'Beds', 'slug': 'beds', 'description': 'Beds and bedroom furniture'},
            {'name': 'Storage', 'slug': 'storage', 'description': 'Shelves, wardrobes, and storage'},
            {'name': 'Desks', 'slug': 'desks', 'description': 'Work-from-home and study desks'},
            {'name': 'Dining Sets', 'slug': 'dining-sets', 'description': 'Complete dining room sets'},
            {'name': 'Outdoor', 'slug': 'outdoor', 'description': 'Outdoor and garden furniture'},
        ]

        # Create/update categories
        categories = {}
        for cat_data in categories_data:
            cat, _ = Category.objects.update_or_create(
                slug=cat_data['slug'],
                defaults={'name': cat_data['name'], 'description': cat_data['description']}
            )
            categories[cat_data['slug']] = cat
            self.stdout.write(f'  Category: {cat.name}')

        # Create products (2 per category, 16 total)
        products_data = [
            # Sofas
            {
                'name': 'Oslo Velvet Sofa', 'slug': 'oslo-velvet-sofa',
                'description': 'Premium 3-seater velvet sofa with solid oak legs. Mid-century modern design that brings timeless elegance to your living room.',
                'price': '45999.00', 'category_slug': 'sofas', 'material': 'fabric',
                'color': 'Emerald Green', 'dimensions': '220x85x80 cm',
                'image_url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
                'stock': 15,
            },
            {
                'name': 'Nordic L-Shape Sectional', 'slug': 'nordic-l-shape-sectional',
                'description': 'Spacious L-shaped sectional sofa with removable covers. Perfect for large living rooms and open-plan spaces.',
                'price': '78999.00', 'category_slug': 'sofas', 'material': 'fabric',
                'color': 'Charcoal Grey', 'dimensions': '300x200x80 cm',
                'image_url': 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800',
                'stock': 8,
            },
            # Tables
            {
                'name': 'Acacia Wood Coffee Table', 'slug': 'acacia-wood-coffee-table',
                'description': 'Hand-crafted solid acacia wood coffee table with natural grain finish. Each piece is unique.',
                'price': '18999.00', 'category_slug': 'tables', 'material': 'wood',
                'color': 'Natural Brown', 'dimensions': '120x60x45 cm',
                'image_url': 'https://images.unsplash.com/photo-1611269154421-4e27233ac5c7?w=800',
                'stock': 22,
            },
            {
                'name': 'Marble Top Dining Table', 'slug': 'marble-top-dining-table',
                'description': 'Luxurious white marble dining table with powder-coated steel frame. Seats 6 comfortably.',
                'price': '54999.00', 'category_slug': 'tables', 'material': 'marble',
                'color': 'White', 'dimensions': '180x90x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
                'stock': 10,
            },
            # Chairs
            {
                'name': 'Tulip Accent Chair', 'slug': 'tulip-accent-chair',
                'description': 'Mid-century modern accent chair with button tufting and walnut legs. Available in multiple colors.',
                'price': '12999.00', 'category_slug': 'chairs', 'material': 'fabric',
                'color': 'Mustard Yellow', 'dimensions': '75x78x85 cm',
                'image_url': 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=800',
                'stock': 30,
            },
            {
                'name': 'Ergonomic Mesh Office Chair', 'slug': 'ergonomic-mesh-office-chair',
                'description': 'Full lumbar support mesh office chair with adjustable armrests and headrest. 8-hour comfort guarantee.',
                'price': '22999.00', 'category_slug': 'chairs', 'material': 'fabric',
                'color': 'Black', 'dimensions': '65x65x120 cm',
                'image_url': 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800',
                'stock': 50,
            },
            # Beds
            {
                'name': 'King Platform Bed Frame', 'slug': 'king-platform-bed-frame',
                'description': 'Solid walnut king-size platform bed with under-bed storage drawers. No box spring required.',
                'price': '64999.00', 'category_slug': 'beds', 'material': 'wood',
                'color': 'Walnut Brown', 'dimensions': '200x180x40 cm',
                'image_url': 'https://images.unsplash.com/photo-1505693314120-0d443867891c?w=800',
                'stock': 12,
            },
            {
                'name': 'Upholstered Wingback Bed', 'slug': 'upholstered-wingback-bed',
                'description': 'Luxurious upholstered queen bed with tall wingback headboard. Soft velvet finish in rose pink.',
                'price': '48999.00', 'category_slug': 'beds', 'material': 'fabric',
                'color': 'Dusty Rose', 'dimensions': '215x165x140 cm',
                'image_url': 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
                'stock': 7,
            },
            # Storage
            {
                'name': 'Modular Bookshelf Unit', 'slug': 'modular-bookshelf-unit',
                'description': '5-shelf modular bookshelf with adjustable shelves. Mix-and-match modules to create your perfect storage wall.',
                'price': '16999.00', 'category_slug': 'storage', 'material': 'wood',
                'color': 'Oak White', 'dimensions': '90x35x180 cm',
                'image_url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
                'stock': 25,
            },
            {
                'name': '3-Door Wardrobe', 'slug': '3-door-wardrobe',
                'description': 'Sliding door wardrobe with mirror panel, hanging rods, and 4 internal shelves.',
                'price': '34999.00', 'category_slug': 'storage', 'material': 'wood',
                'color': 'Matte White', 'dimensions': '180x60x210 cm',
                'image_url': 'https://images.unsplash.com/photo-1558997519-83ea9252edf8?w=800',
                'stock': 9,
            },
            # Desks
            {
                'name': 'Solid Oak Writing Desk', 'slug': 'solid-oak-writing-desk',
                'description': 'Minimalist solid oak writing desk with integrated cable management and a hidden drawer.',
                'price': '28999.00', 'category_slug': 'desks', 'material': 'wood',
                'color': 'Natural Oak', 'dimensions': '140x70x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800',
                'stock': 18,
            },
            {
                'name': 'Height Adjustable Standing Desk', 'slug': 'height-adjustable-standing-desk',
                'description': 'Electric sit-stand desk with memory presets. Dual motor system, whisper-quiet operation.',
                'price': '42999.00', 'category_slug': 'desks', 'material': 'metal',
                'color': 'White Frame', 'dimensions': '160x80x72-120 cm',
                'image_url': 'https://images.unsplash.com/photo-1593642532454-e138e28a63f4?w=800',
                'stock': 14,
            },
            # Dining Sets
            {
                'name': '6-Seater Teak Dining Set', 'slug': '6-seater-teak-dining-set',
                'description': 'Complete 6-seater dining set in solid teak with padded chairs. Includes table and 6 chairs.',
                'price': '84999.00', 'category_slug': 'dining-sets', 'material': 'wood',
                'color': 'Teak Brown', 'dimensions': 'Table 180x90x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
                'stock': 5,
            },
            {
                'name': 'Compact 4-Seater Dining Set', 'slug': 'compact-4-seater-dining-set',
                'description': 'Space-saving 4-seater dining set perfect for apartments. Fold-away chairs for extra space.',
                'price': '36999.00', 'category_slug': 'dining-sets', 'material': 'wood',
                'color': 'Beech Natural', 'dimensions': 'Table 120x70x75 cm',
                'image_url': 'https://images.unsplash.com/photo-1615529328331-f8917597711f?w=800',
                'stock': 20,
            },
            # Outdoor
            {
                'name': 'Teak Garden Bench', 'slug': 'teak-garden-bench',
                'description': 'Weather-resistant teak garden bench. Treated with teak oil for outdoor durability.',
                'price': '14999.00', 'category_slug': 'outdoor', 'material': 'wood',
                'color': 'Teak', 'dimensions': '150x55x80 cm',
                'image_url': 'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=800',
                'stock': 35,
            },
            {
                'name': 'Rattan Outdoor Lounge Set', 'slug': 'rattan-outdoor-lounge-set',
                'description': '4-piece outdoor rattan lounge set with weather-resistant cushions. Includes 2 chairs, sofa, and table.',
                'price': '52999.00', 'category_slug': 'outdoor', 'material': 'rattan',
                'color': 'Natural Rattan', 'dimensions': 'Sofa 180x80x70 cm',
                'image_url': 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
                'stock': 11,
            },
        ]

        for product_data in products_data:
            category_slug = product_data.pop('category_slug')
            product, created = Product.objects.update_or_create(
                slug=product_data['slug'],
                defaults={
                    **product_data,
                    'category': categories[category_slug],
                }
            )
            status_text = 'Created' if created else 'Updated'
            self.stdout.write(f'  {status_text}: {product.name}')

        self.stdout.write(self.style.SUCCESS(f'\nDone! {len(products_data)} products seeded.'))
```

---

## Tests — `products/tests/test_views.py`

```python
from django.test import TestCase
from rest_framework.test import APIClient
from products.models import Category, Product


class ProductListViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.cat_sofa = Category.objects.create(name='Sofas', slug='sofas')
        self.cat_chair = Category.objects.create(name='Chairs', slug='chairs')
        for i in range(3):
            Product.objects.create(
                name=f'Sofa {i}', price=10000 + i * 1000,
                category=self.cat_sofa, material='fabric',
                color='Blue', dimensions='200x80x80',
                image_url='https://test.com/img.jpg', stock=5
            )
        Product.objects.create(
            name='Chair 1', price=5000, category=self.cat_chair,
            material='wood', color='Brown', dimensions='70x70x90',
            image_url='https://test.com/img.jpg', stock=3
        )

    def test_list_returns_all_products(self):
        response = self.client.get('/api/products/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 4)

    def test_filter_by_category_slug(self):
        response = self.client.get('/api/products/?category=sofas')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 3)

    def test_filter_by_price_range(self):
        response = self.client.get('/api/products/?price_min=10000&price_max=11000')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 2)

    def test_search_by_name(self):
        response = self.client.get('/api/products/?search=Chair')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 1)

    def test_product_detail_by_slug(self):
        product = Product.objects.get(name='Chair 1')
        response = self.client.get(f'/api/products/{product.slug}/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['name'], 'Chair 1')

    def test_product_detail_404_for_nonexistent_slug(self):
        response = self.client.get('/api/products/nonexistent-slug/')
        self.assertEqual(response.status_code, 404)
```

---

## Acceptance Criteria

- [ ] `python manage.py seed_products` creates 8 categories and 16 products without errors
- [ ] Running seed twice does not create duplicates
- [ ] `GET /api/products/` returns paginated list (12/page)
- [ ] `GET /api/products/?category=sofas` returns only sofa products
- [ ] `GET /api/products/?price_min=5000&price_max=20000` correctly filters by price
- [ ] `GET /api/products/?search=velvet` returns matching products
- [ ] `GET /api/products/?ordering=-price` returns products sorted by price descending
- [ ] `GET /api/products/{slug}/` returns full product with nested category object
- [ ] `GET /api/products/similar/{id}/` returns up to 4 products from same category
- [ ] `GET /api/products/categories/` returns all 8 categories with product counts
- [ ] Admin can `POST /api/products/admin/` to create a product (with valid JWT + admin role)
- [ ] Non-admin gets `403` on `POST /api/products/admin/`
- [ ] All tests pass: `python manage.py test products`
