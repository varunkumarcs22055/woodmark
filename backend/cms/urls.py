from django.urls import path
from . import views

urlpatterns = [
    # Public
    path('banners/', views.PublicBannerListView.as_view(), name='cms-public-banners'),
    path('pages/<slug:slug>/', views.PublicPageDetailView.as_view(), name='cms-public-page'),
    path('faqs/', views.PublicFAQListView.as_view(), name='cms-public-faqs'),
    path('content/', views.PublicContentBlockListView.as_view(), name='cms-public-content-list'),
    path('content/<slug:key>/', views.PublicContentBlockDetailView.as_view(), name='cms-public-content-detail'),
    path('newsletter/subscribe/', views.NewsletterSubscriptionView.as_view(), name='cms-newsletter-subscribe'),

    # Admin
    path('admin/banners/', views.AdminBannerListCreateView.as_view(), name='cms-admin-banners'),
    path('admin/banners/<int:pk>/', views.AdminBannerDetailView.as_view(), name='cms-admin-banner-detail'),
    path('admin/pages/', views.AdminPageListCreateView.as_view(), name='cms-admin-pages'),
    path('admin/pages/<int:pk>/', views.AdminPageDetailView.as_view(), name='cms-admin-page-detail'),
    path('admin/faqs/', views.AdminFAQListCreateView.as_view(), name='cms-admin-faqs'),
    path('admin/faqs/<int:pk>/', views.AdminFAQDetailView.as_view(), name='cms-admin-faq-detail'),
    path('admin/content/', views.AdminContentBlockListCreateView.as_view(), name='cms-admin-content'),
    path('admin/content/<int:pk>/', views.AdminContentBlockDetailView.as_view(), name='cms-admin-content-detail'),
    path('admin/newsletter/subscribers/', views.AdminNewsletterSubscriberListView.as_view(), name='cms-admin-newsletter-subscribers'),
    path('admin/newsletter/subscribers/<int:pk>/', views.AdminNewsletterSubscriberDetailView.as_view(), name='cms-admin-newsletter-subscriber-detail'),
    path('admin/newsletter/campaigns/', views.AdminNewsletterCampaignListCreateView.as_view(), name='cms-admin-newsletter-campaigns'),
    path('admin/newsletter/campaigns/<int:pk>/', views.AdminNewsletterCampaignDetailView.as_view(), name='cms-admin-newsletter-campaign-detail'),
    path('admin/newsletter/stats/', views.AdminNewsletterStatsView.as_view(), name='cms-admin-newsletter-stats'),
    path('admin/newsletter/send/', views.AdminNewsletterSendView.as_view(), name='cms-admin-newsletter-send'),
    path('admin/newsletter/recipients/', views.AdminNewsletterRecipientsView.as_view(), name='cms-admin-newsletter-recipients'),
]
