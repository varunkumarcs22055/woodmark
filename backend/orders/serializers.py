"""
Orders app — Serializers.

Handles serialization for order creation and listing.
"""

from rest_framework import serializers
from .models import Order, OrderItem
from products.models import Product


class OrderItemSerializer(serializers.ModelSerializer):
    """Serializer for order items (read)."""
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_slug = serializers.CharField(source='product.slug', read_only=True)
    product_image = serializers.URLField(source='product.image_url', read_only=True)
    subtotal = serializers.DecimalField(
        max_digits=10, decimal_places=2, read_only=True
    )

    class Meta:
        model = OrderItem
        fields = [
            'id', 'product', 'product_name', 'product_slug',
            'product_image', 'quantity', 'price', 'subtotal'
        ]


class OrderSerializer(serializers.ModelSerializer):
    """Serializer for order listing (read)."""
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            'id', 'order_id', 'user_name', 'user_email', 'phone',
            'address', 'total_amount', 'payment_status', 'order_status',
            'erp_order_id', 'created_at', 'items'
        ]


class OrderItemCreateSerializer(serializers.Serializer):
    """Serializer for validating items in order creation request."""
    product_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1)


class OrderCreateSerializer(serializers.Serializer):
    """
    Serializer for creating a new order.

    Expected payload:
    {
        "user_name": "John Doe",
        "user_email": "john@example.com",
        "phone": "9876543210",
        "address": "123 Main St, City, State, PIN",
        "items": [
            {"product_id": 1, "quantity": 2},
            {"product_id": 3, "quantity": 1}
        ]
    }
    """
    user_name = serializers.CharField(max_length=100)
    user_email = serializers.EmailField()
    phone = serializers.CharField(max_length=15)
    address = serializers.CharField()
    items = OrderItemCreateSerializer(many=True)

    def validate_items(self, value):
        """Validate that items list is not empty and products exist with sufficient stock."""
        if not value:
            raise serializers.ValidationError('At least one item is required.')

        for item in value:
            try:
                product = Product.objects.get(pk=item['product_id'])
            except Product.DoesNotExist:
                raise serializers.ValidationError(
                    f"Product with ID {item['product_id']} not found."
                )
            if product.stock < item['quantity']:
                raise serializers.ValidationError(
                    f"Insufficient stock for '{product.name}'. "
                    f"Available: {product.stock}, Requested: {item['quantity']}"
                )
        return value

    def create(self, validated_data):
        """
        Create order and order items.
        Calculates total from current product prices and reduces stock.
        """
        items_data = validated_data.pop('items')
        total_amount = 0
        order_items = []

        # Calculate total and prepare order items
        for item_data in items_data:
            product = Product.objects.get(pk=item_data['product_id'])
            price = product.price
            quantity = item_data['quantity']
            total_amount += price * quantity
            order_items.append({
                'product': product,
                'quantity': quantity,
                'price': price,
            })

        # Create the order
        order = Order.objects.create(
            total_amount=total_amount,
            **validated_data
        )

        # Create order items and reduce stock
        for item in order_items:
            OrderItem.objects.create(order=order, **item)
            # Reduce product stock
            product = item['product']
            product.stock -= item['quantity']
            product.save()

        return order
