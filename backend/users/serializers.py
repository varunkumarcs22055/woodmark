from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User, UserAddress


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

        return User.objects.create_user(
            email=validated_data['email'],
            username=validated_data['email'],
            password=validated_data['password'],
            phone=validated_data.get('phone', ''),
            first_name=first_name,
            last_name=last_name,
            role='user',
        )


class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class UserProfileSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(required=False, allow_blank=True)
    dealer_tier_name = serializers.CharField(source='dealer_tier.name', read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'email', 'full_name', 'phone', 'role',
            'dealer_status', 'dealer_company_name', 'dealer_gst_number', 'date_joined',
            'dealer_tier', 'dealer_tier_name',
        ]
        read_only_fields = ['id', 'email', 'role', 'dealer_status', 'date_joined', 'dealer_tier_name']

    def to_representation(self, obj):
        rep = super().to_representation(obj)
        rep['full_name'] = obj.full_name
        return rep

    def update(self, instance, validated_data):
        full_name = validated_data.pop('full_name', None)
        if full_name is not None:
            parts = full_name.split(' ', 1)
            instance.first_name = parts[0]
            instance.last_name = parts[1] if len(parts) > 1 else ''
        return super().update(instance, validated_data)


class UserAddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserAddress
        fields = [
            'id', 'full_name', 'phone', 'line1', 'line2', 'landmark',
            'city', 'state', 'postal_code', 'country', 'address_type',
            'is_default_shipping', 'is_default_billing',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class DealerApplicationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)
    full_name = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = User
        fields = [
            'email', 'password', 'confirm_password', 'full_name', 'phone',
            'dealer_company_name', 'dealer_gst_number',
        ]

    # 15-char Indian GSTIN: 2-digit state + 10-char PAN + 1-digit entity
    # + 1-char Z (default) + 1-char checksum.
    GSTIN_REGEX = r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$'

    def validate_dealer_gst_number(self, value):
        import re
        if not value:
            return value  # blank allowed at registration; admin can require later
        normalized = value.strip().upper()
        if not re.match(self.GSTIN_REGEX, normalized):
            raise serializers.ValidationError(
                'Invalid GSTIN format. Expected 15 chars like 22AAAAA0000A1Z5.'
            )
        return normalized

    def validate(self, data):
        if data['password'] != data.pop('confirm_password'):
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        if not data.get('dealer_company_name'):
            raise serializers.ValidationError({'dealer_company_name': 'Company name is required for dealer accounts.'})
        return data

    def create(self, validated_data):
        full_name = validated_data.pop('full_name', '')
        parts = full_name.split(' ', 1)
        return User.objects.create_user(
            email=validated_data['email'],
            username=validated_data['email'],
            password=validated_data['password'],
            first_name=parts[0] if parts else '',
            last_name=parts[1] if len(parts) > 1 else '',
            phone=validated_data.get('phone', ''),
            dealer_company_name=validated_data.get('dealer_company_name', ''),
            dealer_gst_number=validated_data.get('dealer_gst_number', ''),
            role='dealer',
            dealer_status='pending',
        )


class AdminDealerApprovalSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['dealer_status', 'dealer_tier']

    def validate_dealer_status(self, value):
        if value and value not in ('active', 'rejected'):
            raise serializers.ValidationError("dealer_status must be 'active' or 'rejected'.")
        return value


class EmailOTPRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()


class EmailOTPVerifySerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(min_length=6, max_length=6)


class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()


class PasswordResetConfirmSerializer(serializers.Serializer):
    token = serializers.CharField()
    new_password = serializers.CharField(validators=[validate_password])
    confirm_password = serializers.CharField()

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return data


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField()
    new_password = serializers.CharField(validators=[validate_password])
    confirm_password = serializers.CharField()

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return data
