from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from users.permissions import IsAdminRole
from .models import StoreSettings
from .serializers import StoreSettingsSerializer


class StoreSettingsView(APIView):
    def get_permissions(self):
        if self.request.method == 'GET':
            return [AllowAny()]
        return [IsAdminRole()]

    def get(self, request):
        settings = StoreSettings.current()
        return Response(StoreSettingsSerializer(settings).data)

    def patch(self, request):
        settings = StoreSettings.current()
        serializer = StoreSettingsSerializer(settings, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save(updated_by=request.user)
            return Response(serializer.data)
        return Response(serializer.errors, status=400)
