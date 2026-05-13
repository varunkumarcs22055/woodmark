"""
DRF mixins / helpers for writing AuditLog rows.

Usage on a viewset / view:

    class ProductAdminDetailView(AuditedMixin, APIView):
        audit_target_type = 'product'

        def put(self, request, pk):
            ...
            self.audit_write(request, action='update', target_id=pk, payload=request.data)
"""
from .models import AuditLog

REDACT_KEYS = {'password', 'new_password', 'old_password', 'token',
               'access', 'refresh', 'secret', 'api_key', 'client_secret'}


def _redact(payload):
    if isinstance(payload, dict):
        return {k: ('***' if k in REDACT_KEYS else _redact(v)) for k, v in payload.items()}
    if isinstance(payload, list):
        return [_redact(x) for x in payload]
    return payload


def _client_ip(request):
    xff = request.META.get('HTTP_X_FORWARDED_FOR', '')
    if xff:
        return xff.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR')


def write_audit(request, *, action, target_type, target_id='', payload=None):
    AuditLog.objects.create(
        actor=request.user if getattr(request.user, 'is_authenticated', False) else None,
        action=action,
        target_type=target_type,
        target_id=str(target_id or ''),
        payload=_redact(payload or {}),
        ip=_client_ip(request),
        user_agent=request.META.get('HTTP_USER_AGENT', '')[:300],
    )


class AuditedMixin:
    """Mix into APIView/ViewSet to gain `self.audit_write(...)`."""
    audit_target_type = None

    def audit_write(self, request, *, action, target_id='', payload=None, target_type=None):
        write_audit(
            request,
            action=action,
            target_type=target_type or self.audit_target_type or self.__class__.__name__,
            target_id=target_id,
            payload=payload,
        )
