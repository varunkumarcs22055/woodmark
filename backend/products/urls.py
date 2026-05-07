from django.urls import path
from . import views

urlpatterns = [
    path('', views.ProductListView.as_view(), name='product-list'),
    path('categories/', views.CategoryListView.as_view(), name='category-list'),
    path('similar/<int:pk>/', views.SimilarProductsView.as_view(), name='similar-products'),
    path('admin/', views.ProductAdminViewSet.as_view(), name='product-admin-list'),
    path('admin/<int:pk>/', views.ProductAdminDetailView.as_view(), name='product-admin-detail'),
    path('media/<int:pk>/', views.ProductMediaDeleteView.as_view(), name='product-media-delete'),
    path('<slug:slug>/', views.ProductDetailView.as_view(), name='product-detail'),
]
