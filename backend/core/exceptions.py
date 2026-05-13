"""
Custom DRF exception handler — emits a consistent error envelope:

    {"error": {"code": "snake_case", "message": "...", "details": {...}}}

Wire this in REST_FRAMEWORK['EXCEPTION_HANDLER'].
"""
from rest_framework.views import exception_handler as drf_default_handler
from rest_framework.exceptions import (
    APIException, NotAuthenticated, AuthenticationFailed,
    PermissionDenied, NotFound, ValidationError, MethodNotAllowed,
    Throttled,
)


def _code_for(exc):
    if isinstance(exc, ValidationError):
        return 'validation_error'
    if isinstance(exc, (NotAuthenticated, AuthenticationFailed)):
        return 'not_authenticated'
    if isinstance(exc, PermissionDenied):
        return 'permission_denied'
    if isinstance(exc, NotFound):
        return 'not_found'
    if isinstance(exc, MethodNotAllowed):
        return 'method_not_allowed'
    if isinstance(exc, Throttled):
        return 'throttled'
    if isinstance(exc, APIException):
        return getattr(exc, 'default_code', 'error') or 'error'
    return 'server_error'


def _flatten_message(detail):
    """Pick the first human-readable message out of a DRF detail blob."""
    if isinstance(detail, str):
        return detail
    if isinstance(detail, list) and detail:
        return _flatten_message(detail[0])
    if isinstance(detail, dict):
        for v in detail.values():
            msg = _flatten_message(v)
            if msg:
                return msg
    return 'Request failed.'


def custom_exception_handler(exc, context):
    response = drf_default_handler(exc, context)
    if response is None:
        return None

    detail = response.data
    envelope = {
        'error': {
            'code': _code_for(exc),
            'message': _flatten_message(detail),
            'details': detail if isinstance(detail, (dict, list)) else {'detail': detail},
        }
    }
    response.data = envelope
    return response
