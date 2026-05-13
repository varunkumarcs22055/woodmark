from django.urls import path
from . import views

urlpatterns = [
    path('', views.NotificationListView.as_view(), name='notifications-list'),
    path('preferences/', views.NotificationPreferenceView.as_view(), name='notifications-preferences'),
    path('unread-count/', views.UnreadCountView.as_view(), name='notifications-unread-count'),
    path('<int:pk>/read/', views.MarkReadView.as_view(), name='notifications-mark-read'),
    path('read-all/', views.MarkAllReadView.as_view(), name='notifications-read-all'),
    path('newsletters/targets/', views.NewsletterTargetGroupView.as_view(), name='newsletter-targets'),
    path('newsletters/send/', views.NewsletterSendView.as_view(), name='newsletter-send'),
    path('subscribers/', views.SubscriberCreateView.as_view(), name='subscriber-create'),
]
