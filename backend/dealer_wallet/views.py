from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from users.permissions import IsAdminRole
from core.permissions import IsActiveDealer
from users.models import User

from .models import DealerWallet
from .serializers import DealerWalletSerializer, WalletTopupSerializer


class DealerWalletView(APIView):
    """GET /api/dealer/wallet/  — current dealer's wallet + last 50 transactions."""
    permission_classes = [IsAuthenticated, IsActiveDealer]

    def get(self, request):
        wallet, _ = DealerWallet.objects.get_or_create(dealer=request.user)
        return Response(DealerWalletSerializer(wallet).data)


class AdminWalletTopupView(APIView):
    """POST /api/admin/dealers/<pk>/wallet/topup/  body={amount, reason?, reference?}"""
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        try:
            dealer = User.objects.get(pk=pk, role='dealer')
        except User.DoesNotExist:
            return Response({'error': 'Dealer not found.'}, status=status.HTTP_404_NOT_FOUND)

        ser = WalletTopupSerializer(data=request.data)
        ser.is_valid(raise_exception=True)

        wallet, _ = DealerWallet.objects.get_or_create(dealer=dealer)
        try:
            txn = wallet.credit(
                ser.validated_data['amount'],
                reason=ser.validated_data.get('reason', '') or 'Admin top-up',
                reference=ser.validated_data.get('reference', ''),
                actor=request.user,
            )
        except ValueError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        # Notify dealer
        try:
            from services.notifications import notify
            notify(
                user=dealer,
                kind='wallet_topup',
                title=f'Wallet credited: ₹{txn.amount}',
                body=f'Your wallet was topped up by ₹{txn.amount}. New balance: ₹{wallet.balance}.',
                channels=['inapp', 'email'],
            )
        except Exception:
            pass

        return Response(DealerWalletSerializer(wallet).data, status=status.HTTP_200_OK)
