from django.urls import path
from . import views

urlpatterns = [
    path('validate/', views.CouponValidateView.as_view(), name='coupon-validate'),
    path('admin/', views.CouponAdminListCreateView.as_view(), name='coupon-admin-list'),
    path('admin/<int:pk>/', views.CouponAdminDetailView.as_view(), name='coupon-admin-detail'),
]
