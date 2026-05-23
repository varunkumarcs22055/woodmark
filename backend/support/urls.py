from django.urls import path
from . import views

urlpatterns = [
    path('tickets/', views.TicketListCreateView.as_view(), name='ticket-list-create'),
    path('tickets/<int:pk>/', views.TicketDetailView.as_view(), name='ticket-detail'),
    path('tickets/<int:pk>/messages/', views.TicketMessageView.as_view(), name='ticket-message'),
    path('admin/tickets/<int:pk>/status/', views.AdminTicketStatusView.as_view(), name='admin-ticket-status'),

    # Chatbot (public)
    path('bot/', views.SupportBotView.as_view(), name='support-bot'),

    # Admin FAQ CRUD
    path('admin/faq/', views.AdminFaqListCreateView.as_view(), name='admin-faq-list'),
    path('admin/faq/<int:pk>/', views.AdminFaqDetailView.as_view(), name='admin-faq-detail'),
]
