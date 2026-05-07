from django.urls import path
from . import views

urlpatterns = [
    path('', views.DiscountListCreateView.as_view(), name='discount-list'),
    path('<int:pk>/', views.DiscountDetailView.as_view(), name='discount-detail'),
]
