"""
Cart app — Views.

Session-based cart API endpoints.
Cart data is stored in Django session as a dictionary:
{
    "product_id": {"quantity": 2, "product_id": 1},
    ...
}

Note: The primary cart management happens on the frontend via React Context
and localStorage. These backend endpoints serve as a secondary persistence
layer and for future mobile app support.
"""

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from products.models import Product
from products.serializers import ProductListSerializer


class CartView(APIView):
    """
    GET /api/cart/

    Returns the current session cart with full product details.
    """
    def get(self, request):
        cart = request.session.get('cart', {})
        cart_items = []

        for product_id, item_data in cart.items():
            try:
                product = Product.objects.select_related('category').get(
                    pk=int(product_id)
                )
                cart_items.append({
                    'product': ProductListSerializer(product).data,
                    'quantity': item_data['quantity'],
                })
            except Product.DoesNotExist:
                continue  # Skip products that no longer exist

        # Calculate total
        total = sum(
            float(item['product']['price']) * item['quantity']
            for item in cart_items
        )

        return Response({
            'items': cart_items,
            'total': round(total, 2),
            'item_count': len(cart_items),
        })


class CartAddView(APIView):
    """
    POST /api/cart/add/

    Add a product to the session cart.
    Body: { "product_id": 1, "quantity": 1 }
    """
    def post(self, request):
        product_id = str(request.data.get('product_id'))
        quantity = int(request.data.get('quantity', 1))

        if not product_id:
            return Response(
                {'error': 'product_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Verify product exists and has stock
        try:
            product = Product.objects.get(pk=int(product_id))
        except Product.DoesNotExist:
            return Response(
                {'error': 'Product not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        if product.stock < quantity:
            return Response(
                {'error': 'Insufficient stock'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Add to session cart
        cart = request.session.get('cart', {})
        if product_id in cart:
            cart[product_id]['quantity'] += quantity
        else:
            cart[product_id] = {'quantity': quantity, 'product_id': int(product_id)}

        request.session['cart'] = cart
        request.session.modified = True

        return Response({
            'message': f'{product.name} added to cart',
            'cart_count': len(cart)
        })


class CartRemoveView(APIView):
    """
    POST /api/cart/remove/

    Remove a product from the session cart.
    Body: { "product_id": 1 }
    """
    def post(self, request):
        product_id = str(request.data.get('product_id'))

        cart = request.session.get('cart', {})
        if product_id in cart:
            del cart[product_id]
            request.session['cart'] = cart
            request.session.modified = True
            return Response({'message': 'Item removed from cart'})

        return Response(
            {'error': 'Item not in cart'},
            status=status.HTTP_404_NOT_FOUND
        )


class CartClearView(APIView):
    """
    POST /api/cart/clear/

    Clear all items from the session cart.
    """
    def post(self, request):
        request.session['cart'] = {}
        request.session.modified = True
        return Response({'message': 'Cart cleared'})
