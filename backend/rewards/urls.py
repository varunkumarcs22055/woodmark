from django.urls import path

from . import views

urlpatterns = [
    path('loyalty/', views.LoyaltyView.as_view(), name='rewards-loyalty'),
    path('referral/', views.ReferralView.as_view(), name='rewards-referral'),
    path('giftcards/check/', views.GiftCardCheckView.as_view(), name='rewards-giftcard-check'),
    path('giftcards/buy/', views.GiftCardBuyView.as_view(), name='rewards-giftcard-buy'),
]
