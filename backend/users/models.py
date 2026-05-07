from django.contrib.auth.models import AbstractUser
from django.db import models


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
