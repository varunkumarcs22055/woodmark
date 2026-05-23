"""
SMS Campaign sender.

When a campaign is queued, materialise the audience into Delivery rows, then
iterate through them in batches, calling the provider for each.
"""
import csv
import io
import logging
import time
from decimal import Decimal

from django.db import transaction
from django.utils import timezone

from .models import Contact, Campaign, Delivery, normalize_phone
from .providers import get_provider, BATCH_SIZE, BATCH_DELAY_SEC

logger = logging.getLogger(__name__)


def _resolve_audience(campaign):
    """
    Return a list of (phone, name) tuples for the campaign's audience.
    """
    aud = campaign.audience

    if aud == 'all':
        return list(
            Contact.objects.filter(is_active=True)
            .values_list('phone', 'name')
        )

    if aud == 'tag' and campaign.audience_tag:
        return list(
            Contact.objects.filter(is_active=True, tag=campaign.audience_tag)
            .values_list('phone', 'name')
        )

    if aud == 'customers':
        from django.contrib.auth import get_user_model
        User = get_user_model()
        users = User.objects.filter(role='user', is_active=True).exclude(phone='')
        return [(normalize_phone(u.phone), u.full_name or u.email) for u in users if u.phone]

    if aud == 'dealers':
        from django.contrib.auth import get_user_model
        User = get_user_model()
        users = User.objects.filter(role='dealer', is_active=True).exclude(phone='')
        return [(normalize_phone(u.phone), u.full_name or u.email) for u in users if u.phone]

    if aud == 'wishlist':
        from wishlist.models import WishlistItem
        emails = (
            WishlistItem.objects
            .values_list('user__phone', 'user__first_name')
            .distinct()
        )
        return [
            (normalize_phone(p), n or '') for p, n in emails
            if p
        ]

    if aud == 'high_value':
        from orders.models import Order
        phones = (
            Order.objects.filter(total_amount__gte=Decimal('50000'))
            .exclude(phone='')
            .values_list('phone', 'user_name')
            .distinct()
        )
        return [(normalize_phone(p), n or '') for p, n in phones if p]

    if aud == 'manual':
        # Already populated via delivery rows created at queue time.
        return list(
            campaign.deliveries.values_list('phone', 'name')
        )

    return []


def queue_campaign(campaign, manual_phones=None):
    """
    Materialise audience → Delivery rows; set status=queued.
    `manual_phones` is an optional list of (phone, name) tuples for audience=manual.
    """
    if campaign.status not in ('draft',):
        raise ValueError(f'Campaign {campaign.id} is already {campaign.status}.')

    if campaign.audience == 'manual' and manual_phones:
        # Create deliveries from the supplied list.
        deliveries = []
        seen = set()
        for phone, name in manual_phones:
            normed = normalize_phone(phone)
            if normed in seen:
                continue
            seen.add(normed)
            deliveries.append(Delivery(campaign=campaign, phone=normed, name=name or ''))
        Delivery.objects.bulk_create(deliveries, batch_size=500)
    else:
        pairs = _resolve_audience(campaign)
        deliveries = []
        seen = set()
        for phone, name in pairs:
            if phone in seen:
                continue
            seen.add(phone)
            deliveries.append(Delivery(campaign=campaign, phone=phone, name=name or ''))
        Delivery.objects.bulk_create(deliveries, batch_size=500)

    campaign.total_count = campaign.deliveries.count()
    campaign.status = 'queued'
    campaign.save(update_fields=['total_count', 'status'])
    return campaign


def send_campaign(campaign):
    """
    Process a queued campaign: iterate pending deliveries in batches and
    call the SMS provider for each.
    """
    if campaign.status not in ('queued', 'sending'):
        raise ValueError(f'Campaign {campaign.id} cannot be sent (status={campaign.status}).')

    campaign.status = 'sending'
    campaign.save(update_fields=['status'])

    provider = get_provider()
    pending = campaign.deliveries.filter(status='pending').order_by('id')
    sent = 0
    failed = 0
    errors = []
    batch_count = 0

    for delivery in pending.iterator():
        msg = campaign.message.replace('{name}', delivery.name or 'Customer')
        result = provider.send(delivery.phone, msg, name=delivery.name)
        delivery.status = result['status']
        delivery.provider_response = result.get('provider_response', {})
        delivery.sent_at = timezone.now()
        delivery.save(update_fields=['status', 'provider_response', 'sent_at'])

        if result['status'] == 'sent':
            sent += 1
        else:
            failed += 1
            errors.append(f'{delivery.phone}: {result.get("provider_response", {})}')

        batch_count += 1
        if batch_count >= BATCH_SIZE:
            batch_count = 0
            # Update counts periodically so admin UI shows live progress.
            campaign.sent_count = sent
            campaign.failed_count = failed
            campaign.save(update_fields=['sent_count', 'failed_count'])
            time.sleep(BATCH_DELAY_SEC)

    campaign.sent_count = sent
    campaign.failed_count = failed
    campaign.status = 'sent' if failed == 0 else ('failed' if sent == 0 else 'sent')
    campaign.sent_at = timezone.now()
    if errors:
        campaign.error_log = '\n'.join(errors[:200])  # cap at 200 lines
    campaign.save(update_fields=['sent_count', 'failed_count', 'status', 'sent_at', 'error_log'])
    return campaign


# ─── Transactional one-off SMS (used by orders / invoices / OTP) ──────────


def send_transactional_sms(phone: str, message: str, *, name: str = '') -> dict:
    """
    Fire a single SMS through the configured provider. Used for order
    confirmation, OTP, invoice notification — anything that's NOT a campaign.

    Returns the provider's result dict ({'status': 'sent'|'failed',
    'provider_response': {...}}) so the caller can decide whether to retry
    or persist any record. Failures NEVER raise — they return status='failed'.
    """
    if not phone:
        return {'status': 'failed', 'provider_response': {'error': 'no phone'}}
    try:
        provider = get_provider()
        return provider.send(normalize_phone(phone), message, name=name)
    except Exception as exc:  # pragma: no cover
        return {'status': 'failed', 'provider_response': {'error': str(exc)}}
