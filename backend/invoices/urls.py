from django.urls import path
from . import views

urlpatterns = [
    path('', views.InvoiceListView.as_view(), name='invoice-list'),
    path('<int:pk>/', views.InvoiceDetailView.as_view(), name='invoice-detail'),
    path('<int:pk>/pdf/', views.InvoicePDFView.as_view(), name='invoice-pdf'),
    path('<int:pk>/email/', views.InvoiceEmailView.as_view(), name='invoice-email'),
    path('regenerate/<int:order_id>/', views.InvoiceRegenerateView.as_view(), name='invoice-regenerate'),
]
