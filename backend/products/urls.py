"""
Products app — URL configuration.

Maps product API endpoints to views.
"""

from django.urls import path
from . import views

urlpatterns = [
    # GET /api/products/ — List products with filters
    path('', views.ProductListView.as_view(), name='product-list'),

    # GET /api/categories/ — List all categories
    path('categories/', views.CategoryListView.as_view(), name='category-list'),

    # GET /api/products/similar/<id>/ — Similar products
    path('similar/<int:pk>/', views.SimilarProductsView.as_view(), name='similar-products'),

    # GET /api/products/<slug>/ — Product detail (must be last to avoid slug conflicts)
    path('<slug:slug>/', views.ProductDetailView.as_view(), name='product-detail'),
]
