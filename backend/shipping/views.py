from rest_framework import generics, status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from users.permissions import IsAdminRole

from .models import ShippingZone
from .serializers import ShippingZoneSerializer, EstimateSerializer
from .services import estimate as estimate_service


class ShippingEstimateView(APIView):
    """
    POST /api/shipping/estimate/  body={pincode, subtotal?, weight_grams?, prefer_cod?}
    Public — used by checkout to display shipping cost + ETD before payment.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        ser = EstimateSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        result = estimate_service(
            ser.validated_data['pincode'],
            subtotal=ser.validated_data.get('subtotal', 0),
            weight_grams=ser.validated_data.get('weight_grams', 0),
            prefer_cod=ser.validated_data.get('prefer_cod', False),
        )
        return Response(result, status=status.HTTP_200_OK)


class ShippingZoneListCreateView(generics.ListCreateAPIView):
    queryset = ShippingZone.objects.all()
    serializer_class = ShippingZoneSerializer
    permission_classes = [IsAdminRole]


class ShippingZoneDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = ShippingZone.objects.all()
    serializer_class = ShippingZoneSerializer
    permission_classes = [IsAdminRole]
