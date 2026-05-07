from decimal import Decimal
from rest_framework import serializers
from django.db.models import F
from .models import Order, OrderItem
from products.models import Product
from discounts.services import get_effective_price


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
            'subtotal_amount', 'gst_percent', 'gst_amount', 'shipping_amount',
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
        from store_settings.models import StoreSettings

        items_data = validated_data.pop('items')
        request = self.context.get('request')
        user = request.user if request else None
        if user and not user.is_authenticated:
            user = None

        user_role = getattr(user, 'role', 'user') if user else 'user'
        store = StoreSettings.current()

        subtotal = Decimal('0')
        order_items = []

        for item_data in items_data:
            product = Product.objects.get(pk=item_data['product_id'])
            quantity = item_data['quantity']
            original_price = product.price
            effective_price, _, _ = get_effective_price(product, user_role)

            subtotal += effective_price * quantity
            order_items.append({
                'product': product,
                'quantity': quantity,
                'price': effective_price,
                'original_price': original_price,
            })

        gst_percent = store.gst_percent
        gst_amount = (subtotal * gst_percent / 100).quantize(Decimal('0.01'))
        shipping_amount = (
            Decimal('0') if subtotal >= store.free_shipping_threshold
            else store.standard_shipping_fee
        )
        total_amount = subtotal + gst_amount + shipping_amount

        order = Order.objects.create(
            subtotal_amount=subtotal,
            gst_percent=gst_percent,
            gst_amount=gst_amount,
            shipping_amount=shipping_amount,
            total_amount=total_amount,
            user=user,
            **validated_data
        )

        for item in order_items:
            OrderItem.objects.create(order=order, **item)
            Product.objects.filter(pk=item['product'].pk).update(
                stock=F('stock') - item['quantity']
            )

        return order


class OrderStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['order_status']

    def validate_order_status(self, value):
        valid = [choice[0] for choice in Order.ORDER_STATUS_CHOICES]
        if value not in valid:
            raise serializers.ValidationError(f'Invalid status. Choose from: {valid}')
        return value
