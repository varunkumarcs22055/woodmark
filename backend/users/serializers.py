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

    class Meta:
        model = User
        fields = [
            'id', 'email', 'full_name', 'phone', 'role',
            'dealer_status', 'dealer_company_name', 'dealer_gst_number', 'date_joined',
        ]
        read_only_fields = ['id', 'email', 'role', 'dealer_status', 'date_joined']

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
        fields = ['dealer_status']

    def validate_dealer_status(self, value):
        if value not in ('active', 'rejected'):
            raise serializers.ValidationError("dealer_status must be 'active' or 'rejected'.")
        return value
