"""
Audit log read-only API — admin / superadmin only.

Exposes:
  GET /api/audit/?action=&target_type=&actor=&search=&from=&to=
      Returns paginated, filterable audit entries newest-first.

Writing is owned by `audit.mixins.AuditedMixin` — never via this view.
"""
from rest_framework import generics, serializers
from users.permissions import IsAdminRole

from .models import AuditLog


class AuditLogSerializer(serializers.ModelSerializer):
    actor_email = serializers.CharField(source='actor.email', read_only=True, default=None)
    actor_name = serializers.SerializerMethodField()

    class Meta:
        model = AuditLog
        fields = [
            'id', 'created_at', 'action', 'target_type', 'target_id',
            'payload', 'ip', 'user_agent',
            'actor', 'actor_email', 'actor_name',
        ]
        read_only_fields = fields

    def get_actor_name(self, obj):
        if not obj.actor:
            return None
        return obj.actor.get_full_name() or obj.actor.email


class AuditLogListView(generics.ListAPIView):
    permission_classes = [IsAdminRole]
    serializer_class = AuditLogSerializer
    search_fields = ['target_type', 'target_id', 'actor__email']
    ordering_fields = ['created_at']
    ordering = ['-created_at']

    def get_queryset(self):
        qs = AuditLog.objects.select_related('actor').all()
        params = self.request.query_params
        action = params.get('action')
        if action:
            qs = qs.filter(action=action)
        ttype = params.get('target_type')
        if ttype:
            qs = qs.filter(target_type=ttype)
        actor = params.get('actor')
        if actor:
            qs = qs.filter(actor_id=actor)
        date_from = params.get('from')
        date_to = params.get('to')
        if date_from:
            qs = qs.filter(created_at__gte=date_from)
        if date_to:
            qs = qs.filter(created_at__lte=date_to)
        return qs
