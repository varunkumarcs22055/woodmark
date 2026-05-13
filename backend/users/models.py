import secrets
from datetime import timedelta

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


class User(AbstractUser):
    ROLE_CHOICES = [
        ('user', 'Customer'),
        ('dealer', 'Dealer'),
        ('admin', 'Admin'),
    ]
    DEALER_STATUS_CHOICES = [
        ('pending', 'Pending Approval'),
        ('active', 'Active'),
        ('rejected', 'Rejected'),
    ]

    email = models.EmailField(unique=True)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='user')
    phone = models.CharField(max_length=15, blank=True, null=True)
    dealer_status = models.CharField(
        max_length=10,
        choices=DEALER_STATUS_CHOICES,
        blank=True,
        null=True,
        help_text='Only relevant when role=dealer',
    )
    dealer_company_name = models.CharField(max_length=200, blank=True, null=True)
    dealer_gst_number = models.CharField(max_length=15, blank=True, null=True)
    dealer_tier = models.ForeignKey(
        'dealer_pricing.DealerTier', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='dealers',
        help_text='Pricing tier (standard/premium/platinum). NULL = no tier discount.',
    )
    dealer_territory = models.CharField(max_length=80, blank=True, null=True,
                                        help_text='Free-text region label, e.g. "South Karnataka".')
    is_blocked = models.BooleanField(
        default=False,
        help_text='Blocked users are rejected at login with code=user_blocked.',
    )

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'

    def __str__(self):
        return f'{self.email} ({self.role})'

    @property
    def is_admin_role(self):
        return self.role == 'admin' or self.is_superuser

    @property
    def is_dealer(self):
        return self.role == 'dealer' and self.dealer_status == 'active'

    @property
    def full_name(self):
        return f'{self.first_name} {self.last_name}'.strip() or self.email


class UserAddress(models.Model):
    TYPE_CHOICES = [
        ('home', 'Home'),
        ('office', 'Office'),
        ('other', 'Other'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='addresses')
    full_name = models.CharField(max_length=120)
    phone = models.CharField(max_length=20, blank=True)
    line1 = models.CharField(max_length=200)
    line2 = models.CharField(max_length=200, blank=True)
    landmark = models.CharField(max_length=120, blank=True)
    city = models.CharField(max_length=120)
    state = models.CharField(max_length=120)
    postal_code = models.CharField(max_length=20)
    country = models.CharField(max_length=80, default='India')
    address_type = models.CharField(max_length=12, choices=TYPE_CHOICES, default='home')
    is_default_shipping = models.BooleanField(default=False, db_index=True)
    is_default_billing = models.BooleanField(default=False, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'user_addresses'
        ordering = ['-is_default_shipping', '-created_at']
        indexes = [
            models.Index(fields=['user', 'is_default_shipping']),
            models.Index(fields=['user', 'is_default_billing']),
        ]

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        if self.is_default_shipping:
            (UserAddress.objects
             .filter(user=self.user, is_default_shipping=True)
             .exclude(pk=self.pk)
             .update(is_default_shipping=False))
        if self.is_default_billing:
            (UserAddress.objects
             .filter(user=self.user, is_default_billing=True)
             .exclude(pk=self.pk)
             .update(is_default_billing=False))

    def __str__(self):
        return f'{self.user_id} · {self.line1}, {self.city}'


class EmailOTP(models.Model):
    """
    Six-digit numeric OTP for passwordless email login.

    A user can have multiple OTP rows, but only the most recent unconsumed
    one within the TTL window is honored. We rate-limit issuance at the view
    layer (cooldown_seconds), not here.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='email_otps')
    code = models.CharField(max_length=6, db_index=True)
    purpose = models.CharField(
        max_length=20, default='login',
        help_text="login | signup | sensitive — useful when reusing the model later.",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    used_at = models.DateTimeField(null=True, blank=True)
    attempts = models.PositiveSmallIntegerField(default=0)

    class Meta:
        db_table = 'email_otps'
        ordering = ['-created_at']

    @classmethod
    def issue(cls, user, *, purpose='login', ttl_minutes=10):
        return cls.objects.create(
            user=user,
            code=f'{secrets.randbelow(1_000_000):06d}',
            purpose=purpose,
            expires_at=timezone.now() + timedelta(minutes=ttl_minutes),
        )

    @property
    def is_valid(self):
        return self.used_at is None and timezone.now() < self.expires_at and self.attempts < 5

    def consume(self):
        self.used_at = timezone.now()
        self.save(update_fields=['used_at'])


class PasswordResetToken(models.Model):
    """
    Single-use token issued by /api/auth/password-reset/request/ and consumed
    by /api/auth/password-reset/confirm/. We store the raw token because reset
    flows expect to look it up by value; the lifetime is short (1 hour) and
    tokens are 32-byte URL-safe random.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='password_reset_tokens')
    token = models.CharField(max_length=64, unique=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    used_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'password_reset_tokens'
        ordering = ['-created_at']

    @classmethod
    def issue(cls, user, ttl_minutes=60):
        return cls.objects.create(
            user=user,
            token=secrets.token_urlsafe(32),
            expires_at=timezone.now() + timedelta(minutes=ttl_minutes),
        )

    @property
    def is_valid(self):
        return self.used_at is None and timezone.now() < self.expires_at

    def consume(self):
        self.used_at = timezone.now()
        self.save(update_fields=['used_at'])
