from django.urls import path
from . import views

urlpatterns = [
    path('', views.ProductListView.as_view(), name='product-list'),
    path('categories/', views.CategoryListView.as_view(), name='category-list'),
    path('limited-offers/', views.LimitedOffersView.as_view(), name='limited-offers'),
    path('best-sellers/', views.BestSellersView.as_view(), name='best-sellers'),
    path('similar/<int:pk>/', views.SimilarProductsView.as_view(), name='similar-products'),
    # Tags (keywords) — public + admin
    path('tags/', views.TagListView.as_view(), name='tag-list'),
    path('nav-tags/', views.NavTagsView.as_view(), name='nav-tags'),
    path('admin/tags/', views.TagAdminListCreateView.as_view(), name='tag-admin-list'),
    path('admin/tags/<int:pk>/', views.TagAdminDetailView.as_view(), name='tag-admin-detail'),
    path('admin/', views.ProductAdminViewSet.as_view(), name='product-admin-list'),
    path('admin/<int:pk>/', views.ProductAdminDetailView.as_view(), name='product-admin-detail'),
    path('media/<int:pk>/', views.ProductMediaDeleteView.as_view(), name='product-media-delete'),
    path('<slug:slug>/eta/', views.ProductDeliveryEtaView.as_view(), name='product-eta'),
    path('<slug:slug>/stock-alert/', views.StockAlertSubscribeView.as_view(),
         name='product-stock-alert'),
    path('<slug:slug>/', views.ProductDetailView.as_view(), name='product-detail'),
]
