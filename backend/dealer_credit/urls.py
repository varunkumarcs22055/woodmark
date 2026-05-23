from django.urls import path
from . import views
from .bulk_upload import DealerBulkUploadView

urlpatterns = [
    # Dealer-side
    path('credit/', views.DealerCreditView.as_view(), name='dealer-credit'),
    path('credit/pay/init/', views.DealerCreditPayInitView.as_view(),
         name='dealer-credit-pay-init'),
    path('credit/pay/verify/', views.DealerCreditPayVerifyView.as_view(),
         name='dealer-credit-pay-verify'),
    path('payments/', views.DealerPaymentListView.as_view(), name='dealer-payments'),
    path('invoices/', views.DealerInvoiceListView.as_view(), name='dealer-invoices'),
    path('ledger/', views.DealerLedgerView.as_view(), name='dealer-ledger'),
    path('dashboard/', views.DealerDashboardView.as_view(), name='dealer-dashboard'),
    path('orders/bulk-upload/', DealerBulkUploadView.as_view(), name='dealer-bulk-upload'),
]
