from rest_framework.permissions import BasePermission


class IsAdminRole(BasePermission):
    message = 'Admin access required.'

    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            (request.user.role == 'admin' or request.user.is_superuser)
        )


class IsDealer(BasePermission):
    message = 'Active dealer account required.'

    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            request.user.role == 'dealer' and
            request.user.dealer_status == 'active'
        )


class IsActiveDealer(BasePermission):
    """
    Stricter version: also rejects blocked dealers. Use on every B2B endpoint.
    """
    message = 'Active dealer account required.'

    def has_permission(self, request, view):
        u = request.user
        return bool(
            u and u.is_authenticated and
            u.role == 'dealer' and
            u.dealer_status == 'active' and
            not getattr(u, 'is_blocked', False)
        )


class IsAdminOrDealer(BasePermission):
    message = 'Admin or active dealer account required.'

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        if request.user.role == 'admin' or request.user.is_superuser:
            return True
        return request.user.role == 'dealer' and request.user.dealer_status == 'active'


class IsOwnerOrAdmin(BasePermission):
    message = 'You do not have permission to access this resource.'

    def has_object_permission(self, request, view, obj):
        if request.user.role == 'admin' or request.user.is_superuser:
            return True
        if hasattr(obj, 'user'):
            return obj.user == request.user
        if hasattr(obj, 'user_email'):
            return obj.user_email == request.user.email
        return False
