"""
Orders app — URL configuration.
"""

from django.urls import path
from . import views

urlpatterns = [
    # POST /api/orders/create/ — Create new order
    path('create/', views.OrderCreateView.as_view(), name='order-create'),

    # GET /api/orders/?email=... — List orders by email
    path('', views.OrderListView.as_view(), name='order-list'),
]
