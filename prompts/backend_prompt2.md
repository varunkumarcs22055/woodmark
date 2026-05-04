# Backend Prompt 2 — Custom User Model, Roles & Permissions

## Role
You are a senior backend engineer. Build the custom User model and role-based permission system for FurniShop. This is the authentication foundation that every protected endpoint depends on.

---

## Context
FurniShop has three user roles: `admin`, `dealer`, `user`. This prompt creates the `users` app with the custom `AbstractUser` extension, role fields, dealer approval workflow, and reusable DRF permission classes.

**Depends on:** Backend Prompt 1 (project foundation)
**Required by:** Backend Prompts 3, 4, 6, 7, 8 (all auth-protected features)

---

## Files to Create/Modify

```
backend/users/
├── models.py           ← Custom User model
├── admin.py            ← Django admin registration
├── apps.py
├── permissions.py      ← Reusable DRF permission classes
├── pipeline.py         ← social-auth pipeline step
├── serializers.py      ← User serializers
├── urls.py             ← (stub — populated in Prompt 3)
├── views.py            ← (stub — populated in Prompt 3)
└── migrations/
    └── 0001_initial.py
```

---

## User Model — `users/models.py`

```python
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
    # Dealer-specific fields
    dealer_status = models.CharField(
        max_length=10,
        choices=DEALER_STATUS_CHOICES,
        blank=True,
        null=True,
        help_text='Only relevant when role=dealer'
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
```

**Critical:** `AUTH_USER_MODEL = 'users.User'` must be set in `settings.py` (done in Prompt 1). Run `makemigrations users` then `migrate` after creating this model.

---

## Admin Registration — `users/admin.py`

```python
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ('email', 'first_name', 'last_name', 'role', 'dealer_status', 'is_active', 'date_joined')
    list_filter = ('role', 'dealer_status', 'is_active', 'is_staff')
    search_fields = ('email', 'first_name', 'last_name', 'dealer_company_name')
    ordering = ('-date_joined',)
    list_editable = ('role', 'dealer_status')

    fieldsets = UserAdmin.fieldsets + (
        ('FurniShop Fields', {
            'fields': ('role', 'phone', 'dealer_status', 'dealer_company_name', 'dealer_gst_number')
        }),
    )

    add_fieldsets = UserAdmin.add_fieldsets + (
        ('FurniShop Fields', {
            'fields': ('email', 'role', 'phone')
        }),
    )
```

---

## Permission Classes — `users/permissions.py`

Write these four permission classes. Import them in any view that needs role-based access:

```python
from rest_framework.permissions import BasePermission


class IsAdminRole(BasePermission):
    """Allow access only to users with role='admin' or is_superuser."""
    message = 'Admin access required.'

    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            (request.user.role == 'admin' or request.user.is_superuser)
        )


class IsDealer(BasePermission):
    """Allow access only to active dealers."""
    message = 'Active dealer account required.'

    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            request.user.role == 'dealer' and
            request.user.dealer_status == 'active'
        )


class IsAdminOrDealer(BasePermission):
    """Allow access to admins and active dealers."""
    message = 'Admin or active dealer account required.'

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        if request.user.role == 'admin' or request.user.is_superuser:
            return True
        return request.user.role == 'dealer' and request.user.dealer_status == 'active'


class IsOwnerOrAdmin(BasePermission):
    """Object-level permission: allow access to object owner or admin."""
    message = 'You do not have permission to access this resource.'

    def has_object_permission(self, request, view, obj):
        if request.user.role == 'admin' or request.user.is_superuser:
            return True
        # Object must have a user or user_email field
        if hasattr(obj, 'user'):
            return obj.user == request.user
        if hasattr(obj, 'user_email'):
            return obj.user_email == request.user.email
        return False
```

---

## Social Auth Pipeline — `users/pipeline.py`

This step runs after Google OAuth creates a user. It ensures the user gets `role='user'` (default), never `admin` or `dealer` via OAuth:

```python
def save_user_role(backend, user, response, *args, **kwargs):
    """
    Assign default role to OAuth users.
    Dealers and admins must be assigned via the admin panel, never via OAuth.
    """
    if not user.role:
        user.role = 'user'
        user.save(update_fields=['role'])
```

---

## User Serializers — `users/serializers.py`

```python
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)
    full_name = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ['email', 'password', 'confirm_password', 'full_name', 'phone']

    def validate(self, data):
        if data['password'] != data.pop('confirm_password'):
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return data

    def create(self, validated_data):
        full_name = validated_data.pop('full_name', '')
        parts = full_name.split(' ', 1)
        first_name = parts[0] if parts else ''
        last_name = parts[1] if len(parts) > 1 else ''

        user = User.objects.create_user(
            email=validated_data['email'],
            username=validated_data['email'],  # Use email as username
            password=validated_data['password'],
            phone=validated_data.get('phone', ''),
            first_name=first_name,
            last_name=last_name,
            role='user',
        )
        return user


class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class UserProfileSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'phone', 'role', 'dealer_status', 'date_joined']
        read_only_fields = ['id', 'email', 'role', 'dealer_status', 'date_joined']

    def get_full_name(self, obj):
        return obj.full_name


class DealerApplicationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = [
            'email', 'password', 'confirm_password',
            'first_name', 'last_name', 'phone',
            'dealer_company_name', 'dealer_gst_number'
        ]

    def validate(self, data):
        if data['password'] != data.pop('confirm_password'):
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        if not data.get('dealer_company_name'):
            raise serializers.ValidationError({'dealer_company_name': 'Company name is required for dealer accounts.'})
        return data

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            username=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            phone=validated_data.get('phone', ''),
            dealer_company_name=validated_data.get('dealer_company_name', ''),
            dealer_gst_number=validated_data.get('dealer_gst_number', ''),
            role='dealer',
            dealer_status='pending',
        )
        return user


class AdminDealerApprovalSerializer(serializers.ModelSerializer):
    """Used by Admin to approve/reject dealer applications."""
    class Meta:
        model = User
        fields = ['dealer_status']

    def validate_dealer_status(self, value):
        if value not in ('active', 'rejected'):
            raise serializers.ValidationError("dealer_status must be 'active' or 'rejected'.")
        return value
```

---

## Migration

After writing `models.py`, run:
```bash
python manage.py makemigrations users
python manage.py migrate
```

Verify the `users` table has columns: `email`, `role`, `phone`, `dealer_status`, `dealer_company_name`, `dealer_gst_number`.

---

## Acceptance Criteria

- [ ] `python manage.py migrate` runs cleanly — no errors
- [ ] `python manage.py createsuperuser` works (uses email as identifier)
- [ ] Django admin shows the User list with `email`, `role`, `dealer_status` columns
- [ ] `User.objects.create_user(email='test@test.com', username='test@test.com', password='pass')` works in the Django shell
- [ ] A user with `role='admin'` passes `IsAdminRole.has_permission()`
- [ ] A user with `role='dealer'` and `dealer_status='pending'` does NOT pass `IsDealer.has_permission()`
- [ ] A user with `role='dealer'` and `dealer_status='active'` passes `IsDealer.has_permission()`
