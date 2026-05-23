from decimal import Decimal
from datetime import timedelta
from django.utils import timezone
from rest_framework import serializers
from django.db.models import F
from .models import Order, OrderItem, OrderReturn, Refund
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
            'quantity', 'price', 'original_price', 'subtotal',
            'is_backorder', 'backorder_quantity', 'expected_restock_date',
        ]


class RefundSerializer(serializers.ModelSerializer):
    class Meta:
        model = Refund
        fields = [
            'id', 'amount', 'gateway', 'gateway_refund_id',
            'status', 'note', 'gateway_payload', 'created_at',
        ]


class OrderReturnSerializer(serializers.ModelSerializer):
    order_id = serializers.CharField(source='order.order_id', read_only=True)
    user_name = serializers.CharField(source='order.user_name', read_only=True)
    user_email = serializers.CharField(source='order.user_email', read_only=True)
    order_total = serializers.DecimalField(
        source='order.total_amount', max_digits=10, decimal_places=2, read_only=True,
    )
    refunds = RefundSerializer(many=True, read_only=True)

    class Meta:
        model = OrderReturn
        fields = [
            'id', 'order', 'order_id', 'user_name', 'user_email', 'order_total',
            'reason', 'status', 'refund_amount', 'admin_note',
            'created_at', 'updated_at', 'refunds',
        ]
        read_only_fields = ['created_at', 'updated_at']


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    invoice_id = serializers.SerializerMethodField()
    invoice_number = serializers.SerializerMethodField()
    can_cancel = serializers.SerializerMethodField()
    cancel_expires_at = serializers.SerializerMethodField()
    cancel_minutes_remaining = serializers.SerializerMethodField()
    is_high_value = serializers.SerializerMethodField()
    returns = OrderReturnSerializer(many=True, read_only=True)
    refunds = RefundSerializer(many=True, read_only=True)

    def get_invoice_id(self, obj):
        invoice = getattr(obj, 'invoice', None)
        return invoice.id if invoice else None

    def get_invoice_number(self, obj):
        invoice = getattr(obj, 'invoice', None)
        return invoice.invoice_number if invoice else None

    def _cancel_deadline(self, obj):
        return obj.created_at + timedelta(hours=1)

    def get_cancel_expires_at(self, obj):
        return self._cancel_deadline(obj).isoformat()

    def get_can_cancel(self, obj):
        if obj.order_status not in ('CREATED', 'CONFIRMED'):
            return False
        return timezone.now() <= self._cancel_deadline(obj)

    def get_cancel_minutes_remaining(self, obj):
        remaining = self._cancel_deadline(obj) - timezone.now()
        minutes = int(max(0, remaining.total_seconds() // 60))
        return minutes

    def get_is_high_value(self, obj):
        try:
            return Decimal(str(obj.total_amount)) >= Decimal('50000')
        except Exception:
            return False

    class Meta:
        model = Order
        fields = [
            'id', 'order_id', 'user_name', 'user_email', 'phone', 'address',
            'subtotal_amount', 'gst_percent', 'gst_amount', 'shipping_amount',
            'coupon_code', 'coupon_discount',
            'payment_type', 'early_payment_discount',
            'total_amount', 'payment_status', 'order_status',
            'packing_status', 'shipping_status',
            'tracking_carrier', 'tracking_number',
            'payment_method', 'po_number', 'dealer_note', 'preferred_carrier',
            'erp_order_id', 'erp_sync_status', 'created_at', 'items',
            'invoice_id', 'invoice_number',
            'can_cancel', 'cancel_expires_at', 'cancel_minutes_remaining',
            'is_high_value', 'returns', 'refunds',
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
    # Optional B2B fields — silently ignored for B2C orders.
    payment_method = serializers.ChoiceField(
        choices=[('razorpay', 'razorpay'), ('cod', 'cod'),
                 ('credit', 'credit'), ('wallet', 'wallet')],
        required=False, default='razorpay',
    )
    po_number = serializers.CharField(max_length=80, required=False, allow_blank=True)
    dealer_note = serializers.CharField(required=False, allow_blank=True)
    preferred_carrier = serializers.CharField(max_length=80, required=False, allow_blank=True)
    coupon_code = serializers.CharField(max_length=40, required=False, allow_blank=True)
    pincode = serializers.CharField(max_length=6, required=False, allow_blank=True)
    # When omitted, derived from payment_method: razorpay/wallet→immediate,
    # credit→credit, cod→cod. Front-end can also set explicitly.
    payment_type = serializers.ChoiceField(
        choices=[('immediate', 'immediate'), ('credit', 'credit'), ('cod', 'cod')],
        required=False,
    )

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError('At least one item is required.')

        request = self.context.get('request') if hasattr(self, 'context') else None
        user = request.user if request and request.user.is_authenticated else None
        role = getattr(user, 'role', 'user') if user else 'user'
        is_active_dealer = (role == 'dealer'
                            and getattr(user, 'dealer_status', None) == 'active')

        for item in value:
            try:
                product = Product.objects.get(pk=item['product_id'])
            except Product.DoesNotExist:
                raise serializers.ValidationError(f"Product ID {item['product_id']} not found.")
            # Stock check — active dealers can backorder; everyone else cannot.
            # Backorder details (qty, restock date) are computed in create().
            if product.stock < item['quantity'] and not is_active_dealer:
                raise serializers.ValidationError(
                    f"Insufficient stock for '{product.name}'. "
                    f"Available: {product.stock}, Requested: {item['quantity']}"
                )
            # Dealer-only catalog: refuse to accept the line for non-dealers.
            if getattr(product, 'dealer_only', False) and not is_active_dealer:
                raise serializers.ValidationError(
                    f"'{product.name}' is available to dealers only."
                )
            # MOQ — applies to everyone, but most products have moq=1 so no-op.
            moq = getattr(product, 'min_order_quantity', 1) or 1
            if item['quantity'] < moq:
                raise serializers.ValidationError(
                    f"Minimum order quantity for '{product.name}' is {moq}."
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

        from datetime import date, timedelta
        is_active_dealer = (user_role == 'dealer'
                            and getattr(user, 'dealer_status', None) == 'active')

        for item_data in items_data:
            product = Product.objects.get(pk=item_data['product_id'])
            quantity = item_data['quantity']
            original_price = product.price
            if user_role == 'dealer' and user is not None:
                from dealer_pricing.service import resolve as resolve_dealer
                res = resolve_dealer(product, user, quantity=quantity)
                effective_price = res['effective_price']
            else:
                effective_price, _, _ = get_effective_price(
                    product, user_role, quantity=quantity,
                )

            # Dealer backorder: detect short stock per line.
            shortfall = max(0, quantity - product.stock)
            is_backorder = shortfall > 0 and is_active_dealer
            expected_restock = (
                date.today() + timedelta(days=14) if is_backorder else None
            )

            subtotal += effective_price * quantity
            order_items.append({
                'product': product,
                'quantity': quantity,
                'price': effective_price,
                'original_price': original_price,
                'is_backorder': is_backorder,
                'backorder_quantity': shortfall if is_backorder else 0,
                'expected_restock_date': expected_restock,
                # carry stock-at-time so we can decrement correctly later
                '_decrement_units': min(product.stock, quantity),
            })

        gst_percent = store.gst_percent
        gst_amount = (subtotal * gst_percent / 100).quantize(Decimal('0.01'))

        # Pincode-aware shipping. Falls back to store flat fee if no zone matches.
        pincode = (validated_data.pop('pincode', '') or '').strip()
        if pincode:
            from shipping.services import estimate as shipping_estimate
            ship = shipping_estimate(pincode, subtotal=subtotal)
            shipping_amount = Decimal(ship['fee'])
        else:
            shipping_amount = (
                Decimal('0') if subtotal >= store.free_shipping_threshold
                else store.standard_shipping_fee
            )

        # Coupon evaluation — applies to subtotal, may also free shipping.
        coupon_code_input = (validated_data.get('coupon_code') or '').strip().upper()
        coupon_discount = Decimal('0')
        coupon_obj = None
        if coupon_code_input:
            from coupons.services import evaluate as evaluate_coupon
            res = evaluate_coupon(
                coupon_code_input,
                subtotal=subtotal,
                user=user,
                role=user_role,
            )
            if not res.ok:
                raise serializers.ValidationError({'coupon_code': res.message})
            coupon_obj = res.coupon
            coupon_discount = res.discount
            if res.free_shipping:
                shipping_amount = Decimal('0')

        adjusted_subtotal = max(subtotal - coupon_discount, Decimal('0'))

        # Pay-now incentive — derive payment_type from payment_method when not
        # set explicitly so the buyer doesn't have to pick twice. Razorpay /
        # wallet count as immediate; credit and COD do not earn the discount.
        payment_method = validated_data.get('payment_method', 'razorpay')
        payment_type = validated_data.pop('payment_type', None)
        if payment_type is None:
            if payment_method in ('razorpay', 'wallet'):
                payment_type = 'immediate'
            elif payment_method == 'credit':
                payment_type = 'credit'
            else:
                payment_type = 'cod'

        early_discount_pct = Decimal(str(getattr(store, 'early_payment_discount_pct', 0) or 0))
        if early_discount_pct <= 0:
            early_discount_pct = Decimal('5')  # sensible default if unset
        early_payment_discount = Decimal('0')
        if payment_type == 'immediate':
            early_payment_discount = (adjusted_subtotal * early_discount_pct / 100
                                      ).quantize(Decimal('0.01'))
            adjusted_subtotal = max(adjusted_subtotal - early_payment_discount, Decimal('0'))

        # GST is computed on the discounted subtotal so the buyer's "you save"
        # number stays consistent with the line on the invoice.
        gst_amount = (adjusted_subtotal * gst_percent / 100).quantize(Decimal('0.01'))
        total_amount = adjusted_subtotal + gst_amount + shipping_amount

        # B2B: payment_method='credit' is dealer-only and must fit in the
        # dealer's remaining credit. Reject before creating the Order.
        if payment_method in ('credit', 'wallet'):
            if user_role != 'dealer':
                raise serializers.ValidationError({
                    'payment_method': f'Method {payment_method!r} is dealer-only.',
                })
            if payment_method == 'credit':
                from dealer_credit.models import DealerCredit
                credit, _ = DealerCredit.objects.get_or_create(
                    dealer=user,
                    defaults={'credit_limit': 0, 'amount_used': 0,
                              'terms_days': 30, 'is_active': True},
                )
                if not credit.is_active:
                    raise serializers.ValidationError({
                        'payment_method': 'Your credit account is paused. Contact support.',
                    })
                if Decimal(str(credit.remaining)) < total_amount:
                    raise serializers.ValidationError({
                        'payment_method':
                            f'Credit limit exceeded. Available: '
                            f'{credit.remaining}, order: {total_amount}.',
                    })
            if payment_method == 'wallet':
                from dealer_wallet.models import DealerWallet
                wallet, _ = DealerWallet.objects.get_or_create(dealer=user)
                if not wallet.is_active:
                    raise serializers.ValidationError({
                        'payment_method': 'Your wallet is disabled. Contact support.',
                    })
                if Decimal(str(wallet.balance)) < total_amount:
                    raise serializers.ValidationError({
                        'payment_method':
                            f'Insufficient wallet balance. Available: '
                            f'{wallet.balance}, order: {total_amount}.',
                    })

        # Strip coupon_code from validated_data so we can persist the
        # canonicalized form on the Order (and it isn't passed twice).
        validated_data.pop('coupon_code', None)

        # GST + company-name snapshot — frozen at order time, never re-read
        # from the user profile later. Legal requirement under Indian GST.
        billing_gstin = ''
        billing_company_name = ''
        if user and user_role == 'dealer':
            billing_gstin = getattr(user, 'dealer_gst_number', '') or ''
            billing_company_name = getattr(user, 'dealer_company_name', '') or ''

        order = Order.objects.create(
            subtotal_amount=subtotal,
            gst_percent=gst_percent,
            gst_amount=gst_amount,
            shipping_amount=shipping_amount,
            coupon_code=coupon_obj.code if coupon_obj else '',
            coupon_discount=coupon_discount,
            payment_type=payment_type,
            early_payment_discount=early_payment_discount,
            total_amount=total_amount,
            user=user,
            billing_gstin=billing_gstin,
            billing_company_name=billing_company_name,
            **validated_data
        )

        low_stock_alerts = []
        for item in order_items:
            decrement_units = item.pop('_decrement_units')
            OrderItem.objects.create(order=order, **item)
            # Only decrement what's actually available — the backorder remainder
            # waits in the queue and ships after restock.
            if decrement_units > 0:
                Product.objects.filter(pk=item['product'].pk).update(
                    stock=F('stock') - decrement_units
                )
                # Check post-decrement stock for low-stock alerting.
                fresh = Product.objects.only('id', 'name', 'sku', 'stock').get(
                    pk=item['product'].pk,
                )
                if fresh.stock <= 5:
                    low_stock_alerts.append(fresh)

        # Fire one consolidated low-stock notification per affected admin.
        # In-app only here — email is opt-in via settings and runs in a
        # try/except so it never blocks the order response. Sending email
        # synchronously over SMTP can stall for tens of seconds when the
        # mail server is unreachable, which would time the checkout out
        # *after* the order is already committed and leave the buyer
        # thinking it failed.
        if low_stock_alerts:
            try:
                from django.contrib.auth import get_user_model
                from services.notifications import notify
                User = get_user_model()
                lines = '\n'.join(
                    f'• {p.name} (SKU {p.sku}) — {p.stock} left' for p in low_stock_alerts
                )
                for admin in User.objects.filter(role='admin', is_active=True):
                    notify(
                        user=admin,
                        kind='admin_low_stock',
                        title=f'Low stock on {len(low_stock_alerts)} product(s)',
                        body=(
                            f'After order {order.order_id}, the following products '
                            f'are running low:\n\n{lines}\n\nRestock soon to avoid backorders.'
                        ),
                        payload={'order_id': order.order_id,
                                 'product_ids': [p.id for p in low_stock_alerts]},
                        channels=['inapp'],
                    )
            except Exception:
                import logging
                logging.getLogger(__name__).exception(
                    'low-stock admin notify failed for order %s', order.order_id,
                )

        # Redeem coupon now that the order is fully written.
        if coupon_obj is not None:
            from coupons.services import redeem as redeem_coupon
            try:
                redeem_coupon(
                    coupon_obj, user=user, order=order,
                    discount_amount=coupon_discount,
                )
            except Exception:
                import logging
                logging.getLogger(__name__).exception(
                    'Coupon redeem failed for order %s', order.pk,
                )

        # Wallet-paid orders: debit immediately + mark order as paid since the
        # wallet balance acts like cash. Idempotent because we're inside the
        # serializer.create() so it runs exactly once per order.
        if payment_method == 'wallet':
            from dealer_wallet.models import DealerWallet
            wallet = DealerWallet.objects.get(dealer=user)
            try:
                wallet.debit(
                    total_amount, reason=f'Order {order.order_id}',
                    reference=order.order_id, order=order,
                )
                order.payment_status = 'SUCCESS'
                order.order_status = 'CONFIRMED'
                order.save(update_fields=['payment_status', 'order_status'])
                # Mirror into dealer payments ledger so it shows up on the
                # dealer dashboard's "Recent Payments" panel.
                try:
                    from payments.views import _record_dealer_payment_for_order
                    _record_dealer_payment_for_order(order, method='cash',
                                                     reference=order.order_id)
                except Exception:
                    import logging
                    logging.getLogger(__name__).exception(
                        'Failed to record DealerPayment for wallet order %s', order.order_id,
                    )
            except ValueError as e:
                # Race vs another concurrent debit — surface as 400.
                raise serializers.ValidationError({'payment_method': str(e)})

        # Dealer credit orders: create the invoice now (after line items exist)
        # so the dealer's credit ledger is updated and the invoice shows up
        # in their open list. Idempotent — safe even if re-called later.
        if payment_method == 'credit':
            try:
                from invoices.factory import create_invoice_from_order
                create_invoice_from_order(order)
            except Exception:
                import logging
                logging.getLogger(__name__).exception(
                    'Failed to auto-create invoice for credit order %s', order.pk,
                )

        return order


class OrderStatusUpdateSerializer(serializers.ModelSerializer):
    # Forward-only transition graph. Mirrored on the frontend in AdminOrders.jsx.
    ALLOWED_TRANSITIONS = {
        'CREATED':   {'CONFIRMED', 'CANCELLED'},
        'CONFIRMED': {'SHIPPED', 'CANCELLED'},
        'SHIPPED':   {'DELIVERED'},
        'DELIVERED': set(),
        'CANCELLED': set(),
    }

    class Meta:
        model = Order
        fields = ['order_status']

    def validate_order_status(self, value):
        valid = {choice[0] for choice in Order.ORDER_STATUS_CHOICES}
        if value not in valid:
            raise serializers.ValidationError(
                f'Invalid status. Choose from: {sorted(valid)}'
            )
        current = self.instance.order_status if self.instance else None
        if current is not None and value != current:
            allowed = self.ALLOWED_TRANSITIONS.get(current, set())
            if value not in allowed:
                raise serializers.ValidationError(
                    f"Cannot transition from {current} to {value}. "
                    f"Allowed next states: {sorted(allowed) or 'none (terminal)'}"
                )
        return value
