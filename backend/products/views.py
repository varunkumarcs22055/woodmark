from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from users.permissions import IsAdminRole
from .models import Product, Category, ProductMedia
from .serializers import (
    ProductListSerializer, ProductDetailSerializer,
    CategorySerializer, ProductWriteSerializer,
)
from .filters import ProductFilter


class ProductListView(generics.ListAPIView):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductListSerializer
    filterset_class = ProductFilter
    search_fields = ['name', 'description', 'color']
    ordering_fields = ['price', 'created_at', 'name', 'stock']
    ordering = ['-created_at']
    permission_classes = [AllowAny]


class ProductDetailView(generics.RetrieveAPIView):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductDetailSerializer
    lookup_field = 'slug'
    permission_classes = [AllowAny]


class SimilarProductsView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, pk):
        try:
            product = Product.objects.get(pk=pk)
        except Product.DoesNotExist:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)

        similar = (
            Product.objects
            .filter(category=product.category)
            .exclude(pk=product.pk)
            .select_related('category')[:4]
        )
        return Response(ProductListSerializer(similar, many=True).data)


class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    pagination_class = None
    permission_classes = [AllowAny]


class ProductAdminViewSet(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        products = Product.objects.select_related('category').all()
        serializer = ProductListSerializer(products, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = ProductWriteSerializer(data=request.data)
        if serializer.is_valid():
            product = serializer.save()
            self._attach_media(request, product)
            return Response(ProductDetailSerializer(product).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def _attach_media(self, request, product):
        files = request.FILES.getlist('media')
        for i, f in enumerate(files):
            ProductMedia.objects.create(
                product=product,
                kind='video' if f.content_type.startswith('video') else 'image',
                file=f,
                is_primary=(i == 0 and not product.media.exists()),
                order=i,
            )


class ProductMediaDeleteView(APIView):
    permission_classes = [IsAdminRole]

    def delete(self, request, pk):
        try:
            media = ProductMedia.objects.get(pk=pk)
        except ProductMedia.DoesNotExist:
            return Response({'error': 'Media not found.'}, status=status.HTTP_404_NOT_FOUND)
        media.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ProductAdminDetailView(APIView):
    permission_classes = [IsAdminRole]

    def get_object(self, pk):
        try:
            return Product.objects.get(pk=pk)
        except Product.DoesNotExist:
            return None

    def put(self, request, pk):
        product = self.get_object(pk)
        if not product:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ProductWriteSerializer(product, data=request.data, partial=True)
        if serializer.is_valid():
            product = serializer.save()
            ProductAdminViewSet._attach_media(self, request, product)
            return Response(ProductDetailSerializer(product).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        product = self.get_object(pk)
        if not product:
            return Response({'error': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)
        product.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
