"""
Products app — Views.

API views for product listing, detail, similar products, and categories.
All data is fetched from the Neon PostgreSQL database.
"""

from rest_framework import generics
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Product, Category
from .serializers import (
    ProductListSerializer,
    ProductDetailSerializer,
    CategorySerializer
)
from .filters import ProductFilter


class ProductListView(generics.ListAPIView):
    """
    GET /api/products/

    List all products with optional filtering.
    Supports: category, price_min, price_max, material
    Supports: search by name/description
    Supports: ordering by price, created_at
    """
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductListSerializer
    filterset_class = ProductFilter
    search_fields = ['name', 'description']
    ordering_fields = ['price', 'created_at', 'name']
    ordering = ['-created_at']  # Default: newest first


class ProductDetailView(generics.RetrieveAPIView):
    """
    GET /api/products/{slug}/

    Retrieve a single product by its slug.
    Returns full product details with nested category.
    """
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductDetailSerializer
    lookup_field = 'slug'


class SimilarProductsView(APIView):
    """
    GET /api/products/similar/{id}/

    Returns up to 4 similar products based on the same category.
    Excludes the product itself from results.
    """
    def get(self, request, pk):
        try:
            product = Product.objects.get(pk=pk)
        except Product.DoesNotExist:
            return Response({'error': 'Product not found'}, status=404)

        # Find products in the same category, excluding the current product
        similar = Product.objects.filter(
            category=product.category
        ).exclude(
            pk=product.pk
        ).select_related('category')[:4]

        serializer = ProductListSerializer(similar, many=True)
        return Response(serializer.data)


class CategoryListView(generics.ListAPIView):
    """
    GET /api/categories/

    List all product categories.
    Used by the frontend filter sidebar.
    """
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    pagination_class = None  # Return all categories without pagination
