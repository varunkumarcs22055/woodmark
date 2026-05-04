# Backend Prompt 6 — Discount System (Per-Product, Per-Role, Count-Limited)

## Role
You are a senior backend engineer. Build the complete discount engine for FurniShop: the `discounts` Django app with model, service functions, CRUD API, and integration into product serializers.

---

## Context
FurniShop has two discount tiers: `user` (regular customer) and `dealer` (B2B buyer). Each discount is tied to a specific product, has a mode (% or flat ₹), and an optional unit count limit (how many units can be purchased at the discounted price across all buyers in that tier).

The discount must be computed and returned in the product API so the frontend can display effective prices without any client-side calculation.

**Depends on:** Backend Prompts 1, 2, 5 (products exist, User model has role field)
**Required by:** Backend Prompt 7 (order creation must use effective prices and increment units_sold)

---

## Files to Create

```
backend/discounts/
├── models.py
├── serializers.py
├── services.py          ← Pure computation functions (no Django views)
├── views.py
├── urls.py
├── admin.py
├── apps.py
└── tests/
    ├── __init__.py
    ├── test_models.py
    ├── test_services.py
    └── test_views.py
```

**Modify:**
```
backend/products/serializers.py   ← Add effective_price fields
```

---

## Model — `discounts/models.py`

```python
from django.db import models
from django.conf import settings


class Discount(models.Model):
    DISCOUNT_TYPE_CHOICES = [
        ('user', 'User Discount'),
        ('dealer', 'Dealer Discount'),
    ]
    MODE_CHOICES = [
        ('percent', 'Percentage'),
        ('flat', 'Flat Amount (₹)'),
    ]

    product = models.ForeignKey(
        'products.Product',
        on_delete=models.CASCADE,
        related_name='discounts'
    )
    discount_type = models.CharField(max_length=10, choices=DISCOUNT_TYPE_CHOICES)
    mode = models.CharField(max_length=10, choices=MODE_CHOICES)
    value = models.DecimalField(
        max_digits=10, decimal_places=2,
        help_text='15 for 15%, or 2000 for ₹2000 off'
    )
    count_limit = models.PositiveIntegerField(
        null=True, blank=True,
        help_text='Maximum units at discounted price. NULL = unlimited.'
    )
    units_sold = models.PositiveIntegerField(
        default=0,
        help_text='Auto-incremented when a discounted unit is ordered.'
    )
    active = models.BooleanField(default=True)
    starts_at = models.DateTimeField(null=True, blank=True)
    ends_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='created_discounts'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'discounts'
        unique_together = [('product', 'discount_type')]
        indexes = [
            models.Index(fields=['product', 'discount_type']),
            models.Index(fields=['active']),
        ]

    def __str__(self):
        return f'{self.get_discount_type_display()} on {self.product.name} — {self.value}{"%" if self.mode == "percent" else "₹"}'

    @property
    def units_remaining(self):
        if self.count_limit is None:
            return None
        return max(0, self.count_limit - self.units_sold)

    @property
    def is_exhausted(self):
        if self.count_limit is None:
            return False
        return self.units_sold >= self.count_limit
```

---

## Service Functions — `discounts/services.py`

This file contains pure computation functions. No HTTP request objects — just Python.

```python
from decimal import Decimal
from django.utils import timezone
from django.db import models, transaction
from django.db.models import F


def get_active_discount(product, discount_type):
    """
    Retrieve the active, non-expired, non-exhausted discount for a product and type.
    Returns Discount instance or None.
    """
    from .models import Discount
    now = timezone.now()
    discount = Discount.objects.filter(
        product=product,
        discount_type=discount_type,
        active=True,
    ).filter(
        models.Q(starts_at__isnull=True) | models.Q(starts_at__lte=now)
    ).filter(
        models.Q(ends_at__isnull=True) | models.Q(ends_at__gte=now)
    ).first()

    if discount is None:
        return None
    if discount.is_exhausted:
        return None
    return discount


def get_effective_price(product, user_role):
    """
    Compute the effective (after-discount) price for a product given a user role.

    Args:
        product: Product model instance
        user_role: 'user', 'dealer', or 'admin' (admins pay full price)

    Returns:
        tuple: (effective_price: Decimal, discount: Discount|None, units_remaining: int|None)
        - If no discount: (product.price, None, None)
        - If discount exhausted: (product.price, None, 0)
        - If discount active: (discounted_price, discount, units_remaining_or_None)
    """
    if user_role not in ('user', 'dealer'):
        return product.price, None, None

    discount = get_active_discount(product, user_role)

    if discount is None:
        # Check if there was a discount but it's exhausted
        from .models import Discount
        now = timezone.now()
        exhausted = Discount.objects.filter(
            product=product,
            discount_type=user_role,
            active=True,
        ).filter(
            models.Q(starts_at__isnull=True) | models.Q(starts_at__lte=now)
        ).filter(
            models.Q(ends_at__isnull=True) | models.Q(ends_at__gte=now)
        ).filter(
            count_limit__isnull=False,
            units_sold__gte=models.F('count_limit')
        ).first()
        if exhausted:
            return product.price, None, 0
        return product.price, None, None

    # Calculate discounted price
    if discount.mode == 'percent':
        multiplier = Decimal('1') - (discount.value / Decimal('100'))
        effective = product.price * multiplier
    else:  # flat
        effective = product.price - discount.value
        effective = max(Decimal('0'), effective)

    effective = effective.quantize(Decimal('0.01'))
    return effective, discount, discount.units_remaining


def apply_discounts_to_order(order, user_role):
    """
    Atomically increment units_sold for each discounted product in an order.
    Must be called inside a database transaction after order is confirmed (payment success).

    Uses select_for_update() to prevent race conditions when count_limit is set.
    """
    from .models import Discount

    for item in order.items.select_related('product').all():
        discount = get_active_discount(item.product, user_role)
        if discount is None:
            continue

        with transaction.atomic():
            # Re-acquire with lock to prevent race condition
            locked_discount = Discount.objects.select_for_update().get(pk=discount.pk)

            if locked_discount.count_limit is not None:
                remaining = locked_discount.count_limit - locked_discount.units_sold
                units_to_credit = min(item.quantity, remaining)
            else:
                units_to_credit = item.quantity

            if units_to_credit > 0:
                Discount.objects.filter(pk=locked_discount.pk).update(
                    units_sold=F('units_sold') + units_to_credit
                )


def validate_discount_availability(product, user_role, quantity):
    """
    Validate that a discount is available for the given quantity.
    Called during order creation validation.

    Returns:
        tuple: (is_valid: bool, error_message: str|None)
    """
    discount = get_active_discount(product, user_role)
    if discount is None:
        return True, None  # No discount — full price, always valid

    if discount.count_limit is not None:
        remaining = discount.units_remaining
        if remaining == 0:
            return True, None  # Discount exhausted — full price, still valid
        # Note: V2 policy — if quantity > remaining, apply full price (not an error)
        # V3 will split: first X at discount, rest at full price
    return True, None
```

---

## Serializers — `discounts/serializers.py`

```python
from rest_framework import serializers
from .models import Discount


class DiscountSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    units_remaining = serializers.SerializerMethodField()
    created_by_email = serializers.CharField(source='created_by.email', read_only=True)

    class Meta:
        model = Discount
        fields = [
            'id', 'product', 'product_name', 'discount_type', 'mode', 'value',
            'count_limit', 'units_sold', 'units_remaining', 'active',
            'starts_at', 'ends_at', 'created_by_email', 'created_at'
        ]
        read_only_fields = ['id', 'units_sold', 'created_at', 'product_name', 'units_remaining']

    def get_units_remaining(self, obj):
        return obj.units_remaining

    def validate(self, data):
        if data.get('mode') == 'percent':
            if not (0 < data.get('value', 0) <= 100):
                raise serializers.ValidationError({'value': 'Percentage must be between 1 and 100.'})
        if data.get('mode') == 'flat':
            if data.get('value', 0) <= 0:
                raise serializers.ValidationError({'value': 'Flat discount amount must be greater than 0.'})
        return data


class DiscountWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Discount
        fields = ['product', 'discount_type', 'mode', 'value', 'count_limit', 'active', 'starts_at', 'ends_at']

    def validate(self, data):
        # Check for existing discount of same type for same product (unique_together)
        product = data.get('product')
        discount_type = data.get('discount_type')
        if product and discount_type:
            qs = Discount.objects.filter(product=product, discount_type=discount_type)
            if self.instance:
                qs = qs.exclude(pk=self.instance.pk)
            if qs.exists():
                raise serializers.ValidationError(
                    f'A {discount_type} discount already exists for this product. Deactivate it first.'
                )
        return data
```

---

## Update Product Serializers — `products/serializers.py`

Add these fields to both `ProductListSerializer` and `ProductDetailSerializer`:

```python
# Add to top of products/serializers.py
from discounts.services import get_effective_price


class DiscountInfoMixin:
    """
    Mixin that adds discount-aware pricing to product serializers.
    Reads the request user's role from the serializer context.
    """

    def _get_pricing(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return obj.price, None, None
        role = getattr(request.user, 'role', 'user')
        return get_effective_price(obj, role)

    def get_effective_price(self, obj):
        price, _, _ = self._get_pricing(obj)
        return str(price)

    def get_discount_applied(self, obj):
        _, discount, _ = self._get_pricing(obj)
        if discount is None:
            return None
        return {
            'mode': discount.mode,
            'value': str(discount.value),
            'type': discount.discount_type,
            'display': f'{discount.value}{"%" if discount.mode == "percent" else "₹"} off'
        }

    def get_discount_units_remaining(self, obj):
        _, _, remaining = self._get_pricing(obj)
        return remaining


# Update ProductListSerializer:
class ProductListSerializer(DiscountInfoMixin, serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_slug = serializers.CharField(source='category.slug', read_only=True)
    effective_price = serializers.SerializerMethodField()
    discount_applied = serializers.SerializerMethodField()
    discount_units_remaining = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'price', 'effective_price',
            'discount_applied', 'discount_units_remaining',
            'category', 'category_name', 'category_slug',
            'material', 'color', 'dimensions', 'image_url',
            'stock', 'in_stock', 'is_featured', 'created_at'
        ]
```

**Important:** The `context={'request': request}` must be passed when instantiating the serializer in views. Generic views do this automatically. For manual serialization, pass `ProductListSerializer(qs, many=True, context={'request': request})`.

---

## Views — `discounts/views.py`

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from users.permissions import IsAdminRole
from .models import Discount
from .serializers import DiscountSerializer, DiscountWriteSerializer


class DiscountListCreateView(APIView):
    """
    GET  /api/discounts/           — Admin: list all discounts
    POST /api/discounts/           — Admin: create discount
    """
    permission_classes = [IsAdminRole]

    def get(self, request):
        discount_type = request.query_params.get('type')  # 'user' or 'dealer'
        product_id = request.query_params.get('product')
        qs = Discount.objects.select_related('product', 'created_by').all()
        if discount_type:
            qs = qs.filter(discount_type=discount_type)
        if product_id:
            qs = qs.filter(product_id=product_id)
        return Response(DiscountSerializer(qs, many=True).data)

    def post(self, request):
        serializer = DiscountWriteSerializer(data=request.data)
        if serializer.is_valid():
            discount = serializer.save(created_by=request.user)
            return Response(DiscountSerializer(discount).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DiscountDetailView(APIView):
    """
    GET    /api/discounts/{id}/  — Admin: get discount detail
    PUT    /api/discounts/{id}/  — Admin: update discount
    DELETE /api/discounts/{id}/  — Admin: delete discount
    """
    permission_classes = [IsAdminRole]

    def get_object(self, pk):
        try:
            return Discount.objects.select_related('product').get(pk=pk)
        except Discount.DoesNotExist:
            return None

    def get(self, request, pk):
        discount = self.get_object(pk)
        if not discount:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        return Response(DiscountSerializer(discount).data)

    def put(self, request, pk):
        discount = self.get_object(pk)
        if not discount:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = DiscountWriteSerializer(discount, data=request.data, partial=True)
        if serializer.is_valid():
            discount = serializer.save()
            return Response(DiscountSerializer(discount).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        discount = self.get_object(pk)
        if not discount:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        discount.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

---

## URLs — `discounts/urls.py`

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.DiscountListCreateView.as_view(), name='discount-list'),
    path('<int:pk>/', views.DiscountDetailView.as_view(), name='discount-detail'),
]
```

---

## Admin — `discounts/admin.py`

```python
from django.contrib import admin
from .models import Discount


@admin.register(Discount)
class DiscountAdmin(admin.ModelAdmin):
    list_display = (
        'product', 'discount_type', 'mode', 'value',
        'count_limit', 'units_sold', 'units_remaining_display',
        'active', 'ends_at'
    )
    list_filter = ('discount_type', 'mode', 'active')
    list_editable = ('active',)
    search_fields = ('product__name',)
    readonly_fields = ('units_sold', 'created_at', 'updated_at')

    def units_remaining_display(self, obj):
        if obj.count_limit is None:
            return '∞'
        return obj.units_remaining
    units_remaining_display.short_description = 'Remaining'
```

---

## Tests — `discounts/tests/test_services.py`

```python
from decimal import Decimal
from django.test import TestCase
from products.models import Category, Product
from discounts.models import Discount
from discounts.services import get_effective_price, apply_discounts_to_order


class GetEffectivePriceTest(TestCase):
    def setUp(self):
        cat = Category.objects.create(name='Sofas', slug='sofas')
        self.product = Product.objects.create(
            name='Test Sofa', price='10000.00',
            category=cat, material='fabric',
            color='Blue', dimensions='200x80', image_url='https://test.com/img.jpg', stock=50
        )

    def test_no_discount_returns_full_price(self):
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertIsNone(discount)
        self.assertIsNone(remaining)

    def test_percent_discount_applied_correctly(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('20'), active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('8000.00'))
        self.assertIsNotNone(discount)
        self.assertIsNone(remaining)  # No count limit

    def test_flat_discount_applied_correctly(self):
        Discount.objects.create(
            product=self.product, discount_type='dealer',
            mode='flat', value=Decimal('2500'), active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'dealer')
        self.assertEqual(price, Decimal('7500.00'))

    def test_exhausted_count_limit_returns_full_price(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'),
            count_limit=50, units_sold=50, active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertEqual(remaining, 0)

    def test_partial_count_limit_returns_remaining(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('10'),
            count_limit=100, units_sold=30, active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'user')
        self.assertNotEqual(price, self.product.price)
        self.assertEqual(remaining, 70)

    def test_admin_role_always_gets_full_price(self):
        Discount.objects.create(
            product=self.product, discount_type='user',
            mode='percent', value=Decimal('30'), active=True
        )
        price, discount, remaining = get_effective_price(self.product, 'admin')
        self.assertEqual(price, Decimal('10000.00'))
        self.assertIsNone(discount)
```

---

## Acceptance Criteria

- [ ] `python manage.py migrate` creates `discounts` table cleanly
- [ ] `POST /api/discounts/` with admin JWT creates a discount
- [ ] `GET /api/products/?` for a logged-in user with `role='user'` returns `effective_price`, `discount_applied`, `discount_units_remaining` fields
- [ ] Guest (unauthenticated) gets `effective_price` equal to `product.price` (no discount)
- [ ] Dealer gets their tier's discount (not user discount)
- [ ] User gets their tier's discount (not dealer discount)
- [ ] `count_limit=50, units_sold=50` → discount exhausted → `effective_price = price`
- [ ] Creating a second discount for the same `(product, discount_type)` returns `400`
- [ ] Non-admin cannot access `POST /api/discounts/`
- [ ] All tests pass: `python manage.py test discounts`
