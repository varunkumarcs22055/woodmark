from django.urls import path
from . import views

urlpatterns = [
    path('estimate/', views.ShippingEstimateView.as_view(), name='shipping-estimate'),
    path('zones/admin/', views.ShippingZoneListCreateView.as_view(), name='zone-admin-list'),
    path('zones/admin/<int:pk>/', views.ShippingZoneDetailView.as_view(), name='zone-admin-detail'),
]
