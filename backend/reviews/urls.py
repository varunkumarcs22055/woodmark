from django.urls import path
from . import views

urlpatterns = [
    # Public
    path('', views.PublicReviewListView.as_view(), name='reviews-list'),
    path('summary/', views.ReviewSummaryView.as_view(), name='reviews-summary'),
    path('create/', views.ReviewCreateView.as_view(), name='reviews-create'),
    path('<int:pk>/helpful/', views.ReviewHelpfulView.as_view(), name='reviews-helpful'),

    # Admin
    path('admin/', views.AdminReviewListView.as_view(), name='reviews-admin'),
    path('admin/<int:pk>/', views.AdminReviewModerateView.as_view(), name='reviews-admin-moderate'),
]
