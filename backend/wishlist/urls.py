from django.urls import path
from . import views

urlpatterns = [
    path('admin/order/<int:order_id>/', views.AdminWishlistByOrderView.as_view(), name='admin-wishlist-by-order'),
    path('admin/all/', views.AdminAllWishlistsView.as_view(), name='admin-wishlist-all'),
    path('admin/high-value/', views.AdminHighValueWishlistView.as_view(), name='admin-wishlist-high-value'),
    path('', views.WishlistListView.as_view(), name='wishlist-list'),
    path('<int:product_id>/', views.WishlistToggleView.as_view(), name='wishlist-toggle'),
]
