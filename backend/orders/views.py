import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from rest_framework.permissions import AllowAny
from users.permissions import IsAdminRole
from .models import Order
from .serializers import OrderCreateSerializer, OrderSerializer, OrderStatusUpdateSerializer

logger = logging.getLogger(__name__)


class OrderCreateView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            order = serializer.save()
            return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        if request.user.is_authenticated:
            orders = Order.objects.filter(user=request.user).prefetch_related('items__product')
        else:
            email = request.query_params.get('email')
            if not email:
                return Response(
                    {'error': 'Email is required for guest order lookup.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            orders = Order.objects.filter(user_email=email).prefetch_related('items__product')
        return Response(OrderSerializer(orders, many=True).data)


class OrderAdminListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAdminRole]
    filterset_fields = ['payment_status', 'order_status']
    search_fields = ['order_id', 'user_email', 'user_name']
    ordering_fields = ['created_at', 'total_amount']
    ordering = ['-created_at']

    def get_queryset(self):
        return Order.objects.prefetch_related('items__product').all()


class OrderStatusUpdateView(APIView):
    permission_classes = [IsAdminRole]

    def patch(self, request, pk):
        try:
            order = Order.objects.get(pk=pk)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = OrderStatusUpdateSerializer(order, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            logger.info(f'Order {order.order_id} status → {order.order_status} by {request.user.email}')
            return Response(OrderSerializer(order).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
