from rest_framework import generics, status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from users.permissions import IsAdminRole

from .models import Coupon
from .serializers import CouponSerializer, CouponValidateSerializer
from .services import evaluate


class CouponValidateView(APIView):
    """
    POST /api/coupons/validate/  body={code, subtotal}
    Returns {ok, discount, free_shipping, code, message}.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = CouponValidateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = request.user if request.user.is_authenticated else None
        role = getattr(user, 'role', 'user') if user else 'user'

        result = evaluate(
            serializer.validated_data['code'],
            subtotal=serializer.validated_data['subtotal'],
            user=user, role=role,
        )

        http_status = status.HTTP_200_OK if result.ok else status.HTTP_400_BAD_REQUEST
        return Response({
            'ok': result.ok,
            'code': result.coupon.code if result.coupon else None,
            'discount': str(result.discount),
            'free_shipping': result.free_shipping,
            'message': result.message,
        }, status=http_status)


class CouponAdminListCreateView(generics.ListCreateAPIView):
    queryset = Coupon.objects.all()
    serializer_class = CouponSerializer
    permission_classes = [IsAdminRole]


class CouponAdminDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Coupon.objects.all()
    serializer_class = CouponSerializer
    permission_classes = [IsAdminRole]
