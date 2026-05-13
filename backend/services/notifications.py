"""
Pluggable notification dispatch.

Three channels:
  - inapp:   writes a Notification row (read by /api/notifications/)
  - email:   django.core.mail.send_mail (console backend in dev)
  - sms:     stubbed; logs and returns. Wire Twilio later.

Always call `notify(user, kind, title, body, payload, channels)` — never write
to Notification directly from a view.
"""
from __future__ import annotations

import logging
from typing import Iterable

from django.conf import settings
from django.core.mail import send_mail

logger = logging.getLogger(__name__)

DEFAULT_CHANNELS = ('inapp', 'email')


def _send_inapp(user, kind, title, body, payload):
    # Local import to avoid AppRegistryNotReady at import time
    from notifications.models import Notification
    Notification.objects.create(
        user=user, kind=kind, title=title or kind,
        body=body or '', payload=payload or {},
    )


def _send_email(user, kind, title, body, payload):
    if not getattr(user, 'email', None):
        return
    try:
        send_mail(
            subject=title or kind,
            message=body or '',
            from_email=getattr(settings, 'DEFAULT_FROM_EMAIL', 'no-reply@furnishop.local'),
            recipient_list=[user.email],
            fail_silently=True,
        )
    except Exception:  # pragma: no cover — never let notification crash a request
        logger.exception('email send failed (kind=%s, user=%s)', kind, user.pk)


def _send_sms(user, kind, title, body, payload):
    # Stub: real implementation would use Twilio / MSG91. For now: log only.
    phone = getattr(user, 'phone', None)
    if phone:
        logger.info('SMS stub → %s [%s] %s', phone, kind, title)


_DISPATCH = {
    'inapp': _send_inapp,
    'email': _send_email,
    'sms': _send_sms,
}


def notify(user, *, kind: str, title: str = '', body: str = '',
           payload: dict | None = None, channels: Iterable[str] = DEFAULT_CHANNELS):
    """
    Send a notification to a user via the listed channels.
    Failures in one channel never affect the others — each is wrapped.
    """
    if user is None:
        return
    payload = payload or {}
    for ch in channels:
        sender = _DISPATCH.get(ch)
        if not sender:
            logger.warning('unknown notification channel: %s', ch)
            continue
        try:
            sender(user, kind, title, body, payload)
        except Exception:
            logger.exception('channel %s failed (kind=%s, user=%s)', ch, kind, user.pk)


def notify_admins(*, kind: str, title: str = '', body: str = '',
                  payload: dict | None = None, channels: Iterable[str] = DEFAULT_CHANNELS):
    """Fan-out to every active admin."""
    from users.models import User
    for admin in User.objects.filter(role='admin', is_active=True).iterator():
        notify(admin, kind=kind, title=title, body=body, payload=payload, channels=channels)
