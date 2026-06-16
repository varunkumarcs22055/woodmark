from decimal import Decimal

from django.conf import settings as dj_settings
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import (
    LoyaltyAccount, Referral, GiftCard, REFERRAL_BONUS,
)
from .serializers import LoyaltyAccountSerializer, GiftCardSerializer


class LoyaltyView(APIView):
    """GET /api/rewards/loyalty/ — current user's points balance + history."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        acc = LoyaltyAccount.for_user(request.user)
        return Response(LoyaltyAccountSerializer(acc).data)


class ReferralView(APIView):
    """GET /api/rewards/referral/ — share code, link, and payout stats."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        code = Referral.code_for(request.user)
        site = (getattr(dj_settings, 'FRONTEND_URL', '') or '').rstrip('/') \
            or (getattr(dj_settings, 'SITE_URL', '') or '').rstrip('/') \
            or 'https://woodmark.in'
        # Referees are rows with this referrer and a non-null referee.
        referrals = Referral.objects.filter(referrer=request.user, referee__isnull=False)
        return Response({
            'code': code,
            'share_url': f'{site}/signup?ref={code}',
            'bonus_points': REFERRAL_BONUS,
            'referred_count': referrals.count(),
            'rewarded_count': referrals.filter(rewarded=True).count(),
        })


class GiftCardCheckView(APIView):
    """POST /api/rewards/giftcards/check/ {code} — balance lookup."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        code = (request.data.get('code') or '').strip().upper()
        if not code:
            return Response({'detail': 'Gift card code is required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        try:
            card = GiftCard.objects.get(code=code, is_active=True)
        except GiftCard.DoesNotExist:
            return Response({'detail': 'Invalid or inactive gift card.'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response(GiftCardSerializer(card).data)


class GiftCardBuyView(APIView):
    """POST /api/rewards/giftcards/buy/ {amount, recipient_email, message}

    Issues a gift card to the buyer. NOTE: this demo issues immediately on
    request; production should gate issuance behind a successful payment.
    """
    permission_classes = [IsAuthenticated]
    ALLOWED = [Decimal('500'), Decimal('1000'), Decimal('2000'),
               Decimal('5000'), Decimal('10000')]

    def post(self, request):
        try:
            amount = Decimal(str(request.data.get('amount')))
        except Exception:
            return Response({'detail': 'Invalid amount.'}, status=status.HTTP_400_BAD_REQUEST)
        if amount not in self.ALLOWED:
            return Response(
                {'detail': f'Amount must be one of {[str(a) for a in self.ALLOWED]}.'},
                status=status.HTTP_400_BAD_REQUEST)
        card = GiftCard.issue(
            amount,
            purchaser=request.user,
            recipient_email=(request.data.get('recipient_email') or '').strip(),
            message=(request.data.get('message') or '').strip()[:240],
        )
        return Response(GiftCardSerializer(card).data, status=status.HTTP_201_CREATED)
