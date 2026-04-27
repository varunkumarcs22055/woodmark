"""
Cart app — URL configuration.
"""

from django.urls import path
from . import views

urlpatterns = [
    # GET /api/cart/ — View cart
    path('', views.CartView.as_view(), name='cart-view'),

    # POST /api/cart/add/ — Add item to cart
    path('add/', views.CartAddView.as_view(), name='cart-add'),

    # POST /api/cart/remove/ — Remove item from cart
    path('remove/', views.CartRemoveView.as_view(), name='cart-remove'),

    # POST /api/cart/clear/ — Clear cart
    path('clear/', views.CartClearView.as_view(), name='cart-clear'),
]
