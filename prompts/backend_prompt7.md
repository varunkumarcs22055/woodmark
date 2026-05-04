# Backend Prompt 7 — Cart & Orders

## Role
You are a senior backend engineer. Build the session-based cart system and the complete order management backend for FurniShop. Orders support guest checkout (no account required) and authenticated users.

---

## Context
The cart uses Django sessions (database-backed) as a secondary cart store. The frontend's localStorage cart is the primary UX — the session cart is for server-side reference and future mobile app support. Orders are created with stock validation, price snapshotting, and stock decrement. The discount system from Prompt 6 is integrated: if the user has a discount, the `effective_price` is used for order totals.

**Depends on:** Backend Prompts 1, 2, 5 (products), 6 (discounts)
**Required by:** Backend Prompt 8 (payments trigger ERP after order confirmed)

---

## Files to Create

```
backend/cart/
├── models.py          ← No DB models (session-based)
├── views.py
├── urls.py
└── tests/
    ├── __init__.py
    └── test_views.py

backend/orders/
├── models.py
├── serializers.py
├── views.py
├── urls.py
├── admin.py
└── tests/
    ├── __init__.py
    ├── test_models.py
    ├── test_serializers.py
    └── test_views.py
```

---

## Cart — `cart/views.py`

The cart is stored in `request.session` as a dict: `{'7': 2, '12': 1}` (product_id → quantity).

```python
import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from products.models import Product

logger = logging.getLogger(__name__)


def get_cart(request):
    """Return the cart dict from session, initializing if needed."""
    if 'cart' not in request.session:
        request.session['cart'] = {}
    return request.session['cart']


def save_cart(request, cart):
    """Save cart back to session and mark as modified."""
    request.session['cart'] = cart
    request.session.modified = True


class CartView(APIView):
    """GET /api/cart/ — return full cart with product details and total."""
    permission_classes = [AllowAny]

    def get(self, request):
        cart = get_cart(request)
        if not cart:
            return Response({'items': [], 'total': '0.00', 'count': 0})

        product_ids = [int(pid) for pid in cart.keys()]
        products = Product.objects.filter(id__in=product_ids).select_related('category')
        product_map = {str(p.id): p for p in products}

        items = []
        total = 0
        for product_id, quantity in cart.items():
            product = product_map.get(product_id)
            if not product:
                continue
            subtotal = float(product.price) * quantity
            total += subtotal
            items.append({
                'product_id': product.id,
                'name': product.name,
                'slug': product.slug,
                'price': str(product.price),
                'image_url': product.image_url,
                'quantity': quantity,
                'subtotal': f'{subtotal:.2f}',
                'stock': product.stock,
                'in_stock': product.in_stock,
            })

        return Response({
            'items': items,
            'total': f'{total:.2f}',
            'count': sum(cart.values()),
        })


class CartAddView(APIView):
    """POST /api/cart/add/ — add item to session cart."""
    permission_classes = [AllowAny]

    def post(self, request):
        product_id = request.data.get('product_id')
        quantity = int(request.data.get('quantity', 1))

        if not product_id:
            return Response({'error': 'product_id is required.'}, status=status.HTTP_400_BAD_REQUEST)
        if quantity < 1:
            return Response({'error': 'Quantity must be at least 1.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            product = Product.objects.get(pk=product_id)
        except Product.DoesNotExist:
            return Response({'error': 'Product not found.'}, status=status.HTTP_404_NOT_FOUND)

        cart = get_cart(request)
        current_qty = cart.get(str(product_id), 0)
        new_qty = current_qty + quantity

        if new_qty > product.stock:
            return Response({
                'error': f'Only {product.stock} units available. You already have {current_qty} in cart.'
            }, status=status.HTTP_400_BAD_REQUEST)

        cart[str(product_id)] = new_qty
        save_cart(request, cart)

        return Response({
            'message': 'Item added to cart.',
            'product_id': product.id,
            'quantity': new_qty,
            'cart_count': sum(cart.values()),
        })


class CartRemoveView(APIView):
    """POST /api/cart/remove/ — remove item from session cart."""
    permission_classes = [AllowAny]

    def post(self, request):
        product_id = str(request.data.get('product_id', ''))
        if not product_id:
            return Response({'error': 'product_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        cart = get_cart(request)
        cart.pop(product_id, None)
        save_cart(request, cart)

        return Response({
            'message': 'Item removed from cart.',
            'cart_count': sum(cart.values()),
        })


class CartClearView(APIView):
    """POST /api/cart/clear/ — clear entire session cart."""
    permission_classes = [AllowAny]

    def post(self, request):
        save_cart(request, {})
        return Response({'message': 'Cart cleared.', 'cart_count': 0})
```

## Cart URLs — `cart/urls.py`

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.CartView.as_view(), name='cart'),
    path('add/', views.CartAddView.as_view(), name='cart-add'),
    path('remove/', views.CartRemoveView.as_view(), name='cart-remove'),
    path('clear/', views.CartClearView.as_view(), name='cart-clear'),
]
```

---

## Order Models — `orders/models.py`

```python
import uuid
from django.db import models
from django.conf import settings
from products.models import Product


class Order(models.Model):
    PAYMENT_STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
    ]
    ORDER_STATUS_CHOICES = [
        ('CREATED', 'Created'),
        ('CONFIRMED', 'Confirmed'),
        ('SHIPPED', 'Shipped'),
        ('DELIVERED', 'Delivered'),
        ('CANCELLED', 'Cancelled'),
    ]

    order_id = models.CharField(max_length=20, unique=True, editable=False)
    # Guest checkout fields (no account needed)
    user_name = models.CharField(max_length=100)
    user_email = models.EmailField(db_index=True)
    phone = models.CharField(max_length=15)
    address = models.TextField()
    # Optional link to authenticated user (set when user is logged in)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='orders'
    )
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_status = models.CharField(
        max_length=10, choices=PAYMENT_STATUS_CHOICES, default='PENDING', db_index=True
    )
    order_status = models.CharField(
        max_length=12, choices=ORDER_STATUS_CHOICES, default='CREATED', db_index=True
    )
    erp_order_id = models.CharField(max_length=50, blank=True, null=True)
    erp_sync_status = models.CharField(
        max_length=10,
        choices=[('pending', 'Pending'), ('synced', 'Synced'), ('failed', 'Failed')],
        default='pending'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user_email']),
            models.Index(fields=['payment_status', 'order_status']),
        ]

    def save(self, *args, **kwargs):
        if not self.order_id:
            self.order_id = f'ORD-{uuid.uuid4().hex[:8].upper()}'
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.order_id} — {self.user_name}'


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name='order_items')
    quantity = models.PositiveIntegerField()
    price = models.DecimalField(
        max_digits=10, decimal_places=2,
        help_text='Effective price (after discount) at time of order'
    )
    original_price = models.DecimalField(
        max_digits=10, decimal_places=2,
        help_text='Full price at time of order (before discount)'
    )

    class Meta:
        db_table = 'order_items'

    @property
    def subtotal(self):
        return self.price * self.quantity

    def __str__(self):
        return f'{self.product.name} × {self.quantity}'
```

---

## Order Serializers — `orders/serializers.py`

```python
from rest_framework import serializers
from django.db import models as django_models
from .models import Order, OrderItem
from products.models import Product
from discounts.services import get_effective_price, apply_discounts_to_order


class OrderItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_slug = serializers.CharField(source='product.slug', read_only=True)
    product_image = serializers.URLField(source='product.image_url', read_only=True)
    subtotal = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = OrderItem
        fields = [
            'id', 'product', 'product_name', 'product_slug', 'product_image',
            'quantity', 'price', 'original_price', 'subtotal'
        ]


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            'id', 'order_id', 'user_name', 'user_email', 'phone', 'address',
            'total_amount', 'payment_status', 'order_status',
            'erp_order_id', 'erp_sync_status', 'created_at', 'items'
        ]


class OrderItemCreateSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1)


class OrderCreateSerializer(serializers.Serializer):
    user_name = serializers.CharField(max_length=100)
    user_email = serializers.EmailField()
    phone = serializers.CharField(max_length=15)
    address = serializers.CharField()
    items = OrderItemCreateSerializer(many=True)

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError('At least one item is required.')
        for item in value:
            try:
                product = Product.objects.get(pk=item['product_id'])
            except Product.DoesNotExist:
                raise serializers.ValidationError(f"Product ID {item['product_id']} not found.")
            if product.stock < item['quantity']:
                raise serializers.ValidationError(
                    f"Insufficient stock for '{product.name}'. "
                    f"Available: {product.stock}, Requested: {item['quantity']}"
                )
        return value

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        user = self.context.get('request') and self.context['request'].user
        if user and not user.is_authenticated:
            user = None

        # Determine user role for discount pricing
        user_role = getattr(user, 'role', 'user') if user else 'user'

        total_amount = 0
        order_items = []

        for item_data in items_data:
            product = Product.objects.get(pk=item_data['product_id'])
            quantity = item_data['quantity']
            original_price = product.price
            effective_price, _, _ = get_effective_price(product, user_role)

            total_amount += effective_price * quantity
            order_items.append({
                'product': product,
                'quantity': quantity,
                'price': effective_price,
                'original_price': original_price,
            })

        order = Order.objects.create(
            total_amount=total_amount,
            user=user,
            **validated_data
        )

        for item in order_items:
            OrderItem.objects.create(order=order, **item)
            # Decrement stock atomically
            from django.db.models import F
            Product.objects.filter(pk=item['product'].pk).update(
                stock=F('stock') - item['quantity']
            )

        return order


class OrderStatusUpdateSerializer(serializers.ModelSerializer):
    """Used by admin to update order_status."""
    class Meta:
        model = Order
        fields = ['order_status']

    def validate_order_status(self, value):
        valid = [choice[0] for choice in Order.ORDER_STATUS_CHOICES]
        if value not in valid:
            raise serializers.ValidationError(f'Invalid status. Choose from: {valid}')
        return value
```

---

## Order Views — `orders/views.py`

```python
import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from rest_framework.permissions import AllowAny, IsAuthenticated
from users.permissions import IsAdminRole
from .models import Order
from .serializers import OrderCreateSerializer, OrderSerializer, OrderStatusUpdateSerializer

logger = logging.getLogger(__name__)


class OrderCreateView(APIView):
    """POST /api/orders/create/ — create order (guest or authenticated)."""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            order = serializer.save()
            return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderListView(APIView):
    """
    GET /api/orders/
    - Guest: requires ?email= query param → returns orders for that email
    - Authenticated user: returns their own orders (no email param needed)
    """
    permission_classes = [AllowAny]

    def get(self, request):
        if request.user.is_authenticated:
            orders = Order.objects.filter(user=request.user).prefetch_related('items__product')
        else:
            email = request.query_params.get('email')
            if not email:
                return Response({'error': 'Email is required for guest order lookup.'}, status=status.HTTP_400_BAD_REQUEST)
            orders = Order.objects.filter(user_email=email).prefetch_related('items__product')
        return Response(OrderSerializer(orders, many=True).data)


class OrderAdminListView(generics.ListAPIView):
    """GET /api/orders/all/ — admin: paginated list of all orders with filters."""
    serializer_class = OrderSerializer
    permission_classes = [IsAdminRole]
    filterset_fields = ['payment_status', 'order_status']
    search_fields = ['order_id', 'user_email', 'user_name']
    ordering_fields = ['created_at', 'total_amount']
    ordering = ['-created_at']

    def get_queryset(self):
        return Order.objects.prefetch_related('items__product').all()


class OrderStatusUpdateView(APIView):
    """PATCH /api/orders/{id}/status/ — admin: update order status."""
    permission_classes = [IsAdminRole]

    def patch(self, request, pk):
        try:
            order = Order.objects.get(pk=pk)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = OrderStatusUpdateSerializer(order, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            logger.info(f'Order {order.order_id} status updated to {order.order_status} by {request.user.email}')
            return Response(OrderSerializer(order).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
```

---

## Order URLs — `orders/urls.py`

```python
from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.OrderCreateView.as_view(), name='order-create'),
    path('', views.OrderListView.as_view(), name='order-list'),
    path('all/', views.OrderAdminListView.as_view(), name='order-admin-list'),
    path('<int:pk>/status/', views.OrderStatusUpdateView.as_view(), name='order-status-update'),
]
```

---

## Order Admin — `orders/admin.py`

```python
from django.contrib import admin
from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    readonly_fields = ('product', 'quantity', 'price', 'original_price', 'subtotal_display')
    extra = 0

    def subtotal_display(self, obj):
        return f'₹{obj.subtotal:,.2f}'
    subtotal_display.short_description = 'Subtotal'


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = (
        'order_id', 'user_name', 'user_email', 'total_display',
        'payment_status', 'order_status', 'erp_sync_status', 'created_at'
    )
    list_filter = ('payment_status', 'order_status', 'erp_sync_status')
    list_editable = ('order_status',)
    search_fields = ('order_id', 'user_email', 'user_name')
    ordering = ('-created_at',)
    readonly_fields = ('order_id', 'erp_order_id', 'created_at', 'updated_at')
    inlines = [OrderItemInline]

    def total_display(self, obj):
        return f'₹{obj.total_amount:,.2f}'
    total_display.short_description = 'Total'
```

---

## Acceptance Criteria

- [ ] `POST /api/orders/create/` with valid payload creates order, returns `order_id` in `ORD-XXXXXXXX` format
- [ ] Stock is correctly decremented after order creation
- [ ] `POST /api/orders/create/` with `quantity > stock` returns `400` with stock error message
- [ ] Authenticated user's order is linked to their user account (`order.user` field is set)
- [ ] Guest order is created without authentication
- [ ] `GET /api/orders/?email=test@test.com` returns all orders for that email
- [ ] Authenticated user's `GET /api/orders/` returns their orders
- [ ] Admin can `GET /api/orders/all/` and see all orders
- [ ] Admin can `PATCH /api/orders/{id}/status/` to update order status
- [ ] Session cart add/remove/clear works independently of the order flow
- [ ] Cart stock validation prevents adding more than `product.stock` to session cart
- [ ] All tests pass: `python manage.py test orders cart`
