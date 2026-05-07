from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from users.permissions import IsAdminRole
from .models import Discount
from .serializers import DiscountSerializer, DiscountWriteSerializer


class DiscountListCreateView(APIView):
    """
    GET  /api/discounts/  — Admin: list all discounts
    POST /api/discounts/  — Admin: create discount
    """
    permission_classes = [IsAdminRole]

    def get(self, request):
        discount_type = request.query_params.get('discount_type') or request.query_params.get('type')
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
