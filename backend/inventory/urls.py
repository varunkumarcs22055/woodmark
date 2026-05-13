from django.urls import path
from . import views

urlpatterns = [
    path('warehouses/', views.WarehouseListView.as_view(), name='warehouse-list'),
    path('levels/', views.StockLevelListView.as_view(), name='stock-level-list'),
    path('levels/<int:pk>/movements/', views.StockLevelMovementsView.as_view(), name='stock-level-movements'),
    path('adjust/', views.StockAdjustView.as_view(), name='stock-adjust'),
    path('seed-all/', views.StockLevelBulkSeedView.as_view(), name='stock-seed-all'),
    path('low-stock/', views.LowStockView.as_view(), name='low-stock'),
]
