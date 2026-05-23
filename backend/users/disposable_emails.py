"""
Disposable / throwaway email-domain blocklist.

Used by RegisterView to reject signups from common temp-email services
(mailinator, tempmail, guerrillamail, 10minutemail, etc.). This is a
defensive measure against:
  - Coupon farming via burner accounts
  - Spam signups inflating the user table
  - Abuse of the welcome-email path

Strategy:
  * Hard-coded list of the most popular disposable providers (curated).
  * Match is case-insensitive on the full domain after `@`.
  * Subdomains of a listed root are also blocked (e.g. anything ending
    in `.mailinator.com`).
  * This list is intentionally short; it covers the providers that
    account for >95% of throwaway traffic. For a more thorough list,
    point to https://github.com/disposable-email-domains/disposable-email-domains
    and import their `disposable_email_blocklist.conf` at deploy time.

Add new domains by editing DISPOSABLE_DOMAINS below.
"""
from __future__ import annotations

# Lowercased, no leading "@". Most popular temp-mail services.
DISPOSABLE_DOMAINS: frozenset[str] = frozenset({
    '10minutemail.com', '10minutemail.net', '20minutemail.com',
    'anonbox.net', 'anonmails.de', 'anonymbox.com',
    'binkmail.com', 'bobmail.info', 'bsnow.net', 'bspamfree.org',
    'bugmenot.com', 'burnermail.io',
    'deadaddress.com', 'despam.it', 'discard.email', 'dispostable.com',
    'dropmail.me', 'dudmail.com',
    'einrot.com', 'emailfake.com', 'emailondeck.com', 'emailtemporanea.net',
    'emltmp.com', 'evopo.com',
    'fakeinbox.com', 'fakemail.net', 'fakemailgenerator.com', 'fast-email.info',
    'forgetmail.com',
    'getairmail.com', 'getnada.com', 'guerrillamail.biz', 'guerrillamail.com',
    'guerrillamail.de', 'guerrillamail.info', 'guerrillamail.net',
    'guerrillamail.org', 'guerrillamailblock.com',
    'harakirimail.com',
    'inboxalias.com', 'inboxbear.com', 'inboxkitten.com', 'incognitomail.org',
    'jetable.org',
    'kasmail.com', 'kurzepost.de',
    'lookugly.com', 'luxusmail.org',
    'mail-temp.com', 'mailbox52.ga', 'mailcatch.com', 'maildrop.cc',
    'maileater.com', 'mailexpire.com', 'mailforspam.com', 'mailfreeonline.com',
    'mailguard.me', 'mailimate.com', 'mailinator.com', 'mailinator.net',
    'mailinator.org', 'mailmoat.com', 'mailnesia.com', 'mailnull.com',
    'mailrock.biz', 'mailsac.com', 'mailshell.com', 'mailtemp.info',
    'mailtothis.com', 'mailtrash.net', 'mintemail.com', 'mohmal.com',
    'moakt.com', 'msgwire.com', 'mt2015.com', 'mvrht.com', 'myemailboxy.com',
    'mytemp.email', 'mytrashmail.com',
    'nada.email', 'no-spam.ws', 'nobulk.com', 'notmailinator.com',
    'objectmail.com', 'one-time.email', 'onewaymail.com', 'opayq.com',
    'pookmail.com', 'proxymail.eu',
    'rcpt.at', 'recursor.net',
    'sharklasers.com', 'shieldedmail.com', 'shieldemail.com', 'sneakemail.com',
    'soodonims.com', 'spam4.me', 'spambog.com', 'spambox.us', 'spamcero.com',
    'spamex.com', 'spamfree24.com', 'spamfree24.de', 'spamfree24.eu',
    'spamfree24.info', 'spamfree24.net', 'spamfree24.org', 'spamgourmet.com',
    'spaminator.de', 'spammotel.com', 'spamspot.com', 'spamthis.co.uk',
    'spamtrail.com', 'superrito.com',
    'tagyourself.com', 'teleworm.com', 'teleworm.us', 'temp-mail.org',
    'temp-mail.ru', 'tempail.com', 'tempemail.co.za', 'tempemail.com',
    'tempemail.net', 'tempinbox.com', 'tempmail.us', 'tempmailaddress.com',
    'tempr.email', 'tempymail.com', 'thankyou2010.com', 'thisisnotmyrealemail.com',
    'throwam.com', 'throwawayemailaddress.com', 'throwaway.email',
    'throwawaymail.com', 'tmail.ws', 'tmailinator.com', 'tonymail.cc',
    'tradermail.info', 'trash-mail.com', 'trash-mail.de', 'trashmail.at',
    'trashmail.com', 'trashmail.de', 'trashmail.me', 'trashmail.net',
    'trashmail.org', 'trashmailer.com', 'trbvm.com', 'trillianpro.com',
    'tyldd.com',
    'uggsrock.com', 'upliftnow.com', 'uplipht.com',
    'wegwerfadresse.de', 'wegwerfemail.com', 'wegwerfemail.de', 'wegwerfmail.de',
    'wegwerfmail.info', 'wegwerfmail.net', 'wegwerfmail.org', 'whatpaas.com',
    'whyspam.me',
    'yopmail.com', 'yopmail.fr', 'yopmail.net',
    'zetmail.com', 'zoemail.org', 'zomg.info',
    # ─── Modern temp-mail services (2023–2026 wave) ──────────────────────
    'mail.tm', 'mailtm.com', 'emailnator.com', 'tempmail.dev',
    'tempmail.email', 'tempmail.io', 'tempmail.plus', 'tempmailo.com',
    'tempmailbeast.com', 'tempmailgen.com', 'temp-mail.io',
    'temporarymail.com', 'crazymailing.com', 'mailpoof.com',
    'moakt.cc', 'moakt.ws', 'mohmal.in.net', 'mohmal.tech',
    'internxt.com', 'fakermail.com', 'inboxes.com', 'flymail.tk',
    'smailpro.com', 'mailcare.io', 'minutemail.com',
    'snapmail.cc', 'tmpmail.org', 'tmpmail.net',
    '1secmail.com', '1secmail.net', '1secmail.org',
    'edu.poltekkesjogja.ac.id',  # known disposable from old leaks
    'duck.com', 'duckduckgo.com',  # DuckDuckGo email aliasing — also disposable
    'simplelogin.io', 'simplelogin.com',  # SimpleLogin aliases
    'anonaddy.com', 'anonaddy.me',  # AnonAddy aliases
    'relay.firefox.com',  # Firefox Relay
    'kuvenu.com', 'fexpost.com', 'fexbox.org',
    'tutuapp.bid', 'discardmail.com', 'discardmail.de',
    'gufum.com', 'mailbox.in.ua', 'mailcuk.com',
    'spamok.com', 'spamok.de', 'spamok.com.ua',
    'rambler.ua',  # commonly used as throwaway
    'inboxmail.world', 'crypto-mining.club',
    'pokemail.net', 'spambox.org', 'spammy.click',
    'wuuvo.com', 'edny.net', 'givmail.com',
})


def is_disposable_email(email: str) -> bool:
    """Return True if email's domain is a known throwaway service."""
    if not email or '@' not in email:
        return False
    domain = email.rsplit('@', 1)[1].strip().lower()
    if domain in DISPOSABLE_DOMAINS:
        return True
    # Subdomain match (e.g. xyz.mailinator.com)
    for d in DISPOSABLE_DOMAINS:
        if domain.endswith('.' + d):
            return True
    return False
