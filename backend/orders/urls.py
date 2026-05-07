from django.urls import path
from . import views
from payments.views import ERPRetryView

urlpatterns = [
    path('create/', views.OrderCreateView.as_view(), name='order-create'),
    path('', views.OrderListView.as_view(), name='order-list'),
    path('all/', views.OrderAdminListView.as_view(), name='order-admin-list'),
    path('<int:pk>/status/', views.OrderStatusUpdateView.as_view(), name='order-status-update'),
    path('<int:pk>/retry-erp/', ERPRetryView.as_view(), name='order-retry-erp'),
]
