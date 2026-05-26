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
    # One-click unsubscribe (RFC 8058) — signed token, no auth needed.
    # Used by the List-Unsubscribe header on every bulk newsletter so Gmail /
    # Yahoo's Feb 2024 bulk-sender rules don't drop us straight into spam.
    path('unsubscribe/', views.NewsletterUnsubscribeView.as_view(),
         name='newsletter-unsubscribe'),
]
