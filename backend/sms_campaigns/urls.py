from django.urls import path
from . import views

urlpatterns = [
    path('contacts/', views.ContactListCreateView.as_view(), name='sms-contacts'),
    path('contacts/bulk/', views.ContactBulkImportView.as_view(), name='sms-contacts-bulk'),
    path('contacts/bulk-delete/', views.ContactBulkDeleteView.as_view(), name='sms-contacts-bulk-delete'),
    path('contacts/<int:pk>/', views.ContactDetailView.as_view(), name='sms-contact-detail'),
    path('campaigns/', views.CampaignListCreateView.as_view(), name='sms-campaigns'),
    path('campaigns/<int:pk>/', views.CampaignDetailView.as_view(), name='sms-campaign-detail'),
    path('campaigns/<int:pk>/queue/', views.CampaignQueueView.as_view(), name='sms-campaign-queue'),
    path('campaigns/<int:pk>/send/', views.CampaignSendView.as_view(), name='sms-campaign-send'),
    path('campaigns/<int:pk>/deliveries/', views.CampaignDeliveryListView.as_view(), name='sms-campaign-deliveries'),
]
