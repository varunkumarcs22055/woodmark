"""
SMS provider abstraction.

Currently supports:
  - Msg91 (Indian SMS gateway — cheapest for 16k numbers).
  - Simulated provider (dev mode — just logs).

To activate Msg91, set env vars:
  MSG91_AUTH_KEY=...
  MSG91_SENDER_ID=FURNSH   (6 chars)
  MSG91_ROUTE=4             (transactional=4)
  MSG91_DLT_TE_ID=...       (DLT template entity ID, required for India)

If env vars are missing, the sim provider is used and deliveries are marked
as `sent` with a simulated response payload.
"""
import logging
import os
import time
import uuid

import requests
from django.conf import settings

logger = logging.getLogger(__name__)

# Rate-limit: max N messages per batch, with a delay between batches.
BATCH_SIZE = int(os.getenv('SMS_BATCH_SIZE', '50'))
BATCH_DELAY_SEC = float(os.getenv('SMS_BATCH_DELAY', '1.0'))


class BaseProvider:
    """Interface that all SMS providers must implement."""

    def send(self, phone: str, message: str, name: str = '') -> dict:
        """
        Send one SMS and return a dict with at least:
          { 'status': 'sent'|'failed', 'provider_response': {...} }
        """
        raise NotImplementedError


class SimulatedProvider(BaseProvider):
    """Logs but doesn't send. Used when real credentials are absent."""

    def send(self, phone, message, name=''):
        ref = f'sim_{uuid.uuid4().hex[:12]}'
        logger.info('[SMS-SIM] to=%s name=%s body=%s ref=%s', phone, name, message[:50], ref)
        return {
            'status': 'sent',
            'provider_response': {
                'simulated': True,
                'ref': ref,
                'phone': phone,
            },
        }


class Msg91Provider(BaseProvider):
    """
    Indian SMS gateway. Cheap for bulk. Docs: https://docs.msg91.com/
    Uses the Send SMS API (v5).
    """
    API_URL = 'https://control.msg91.com/api/v5/flow/'

    def __init__(self, auth_key, sender_id, route='4', dlt_te_id=''):
        self.auth_key = auth_key
        self.sender_id = sender_id
        self.route = route
        self.dlt_te_id = dlt_te_id

    def send(self, phone, message, name=''):
        # Msg91 expects phone without leading +
        mobile = phone.lstrip('+')
        payload = {
            'sender': self.sender_id,
            'route': self.route,
            'country': '91',
            'sms': [{
                'message': message,
                'to': [mobile],
            }],
        }
        if self.dlt_te_id:
            payload['DLT_TE_ID'] = self.dlt_te_id
        headers = {'authkey': self.auth_key, 'Content-Type': 'application/json'}
        try:
            resp = requests.post(self.API_URL, json=payload, headers=headers, timeout=10)
            data = resp.json() if resp.headers.get('content-type', '').startswith('application/json') else {'text': resp.text}
            ok = resp.status_code in (200, 201) and data.get('type') != 'error'
            return {
                'status': 'sent' if ok else 'failed',
                'provider_response': data,
            }
        except Exception as exc:
            logger.error('Msg91 send failed for %s: %s', phone, exc)
            return {
                'status': 'failed',
                'provider_response': {'error': str(exc)},
            }


def get_provider() -> BaseProvider:
    """Factory — returns the right provider based on env vars."""
    auth_key = os.getenv('MSG91_AUTH_KEY', '')
    sender_id = os.getenv('MSG91_SENDER_ID', '')
    if auth_key and sender_id:
        return Msg91Provider(
            auth_key=auth_key,
            sender_id=sender_id,
            route=os.getenv('MSG91_ROUTE', '4'),
            dlt_te_id=os.getenv('MSG91_DLT_TE_ID', ''),
        )
    logger.warning('SMS provider env vars missing — using simulated provider.')
    return SimulatedProvider()
