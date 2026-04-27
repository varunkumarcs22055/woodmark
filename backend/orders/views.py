"""
Orders app — Views.

API views for creating and listing orders.
"""

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Order
from .serializers import OrderSerializer, OrderCreateSerializer


class OrderCreateView(APIView):
    """
    POST /api/orders/create/

    Create a new order with items.
    Validates stock availability, calculates total, and reduces stock.
    """
    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data)
        if serializer.is_valid():
            order = serializer.save()
            return Response(
                OrderSerializer(order).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderListView(APIView):
    """
    GET /api/orders/?email=user@example.com

    List orders for a given email address (guest checkout lookup).
    Returns orders sorted by newest first.
    """
    def get(self, request):
        email = request.query_params.get('email')
        if not email:
            return Response(
                {'error': 'Email parameter is required to look up orders.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        orders = Order.objects.filter(
            user_email=email
        ).prefetch_related('items__product').order_by('-created_at')

        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data)
