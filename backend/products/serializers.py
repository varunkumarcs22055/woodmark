"""
Products app — Serializers.

Converts Product and Category model instances to/from JSON.
"""

from rest_framework import serializers
from .models import Category, Product


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for Category model."""
    product_count = serializers.IntegerField(
        source='products.count',
        read_only=True
    )

    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'product_count']


class ProductListSerializer(serializers.ModelSerializer):
    """
    Serializer for product list view.
    Includes category name for display in product cards.
    """
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'description', 'price',
            'category', 'category_name', 'material', 'color',
            'dimensions', 'image_url', 'stock', 'in_stock',
            'created_at'
        ]


class ProductDetailSerializer(serializers.ModelSerializer):
    """
    Serializer for product detail view.
    Includes full nested category object.
    """
    category = CategorySerializer(read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'description', 'price',
            'category', 'material', 'color', 'dimensions',
            'image_url', 'stock', 'in_stock', 'created_at'
        ]
