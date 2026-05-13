from django.urls import path
from . import views

urlpatterns = [
    path('', views.WishlistListView.as_view(), name='wishlist-list'),
    path('<int:product_id>/', views.WishlistToggleView.as_view(), name='wishlist-toggle'),
]
