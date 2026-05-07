import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from products.models import Product

logger = logging.getLogger(__name__)


def get_cart(request):
    if 'cart' not in request.session:
        request.session['cart'] = {}
    return request.session['cart']


def save_cart(request, cart):
    request.session['cart'] = cart
    request.session.modified = True


class CartView(APIView):
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
    permission_classes = [AllowAny]

    def post(self, request):
        save_cart(request, {})
        return Response({'message': 'Cart cleared.', 'cart_count': 0})
