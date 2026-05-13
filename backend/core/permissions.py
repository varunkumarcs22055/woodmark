"""
Project-wide permission classes.

`IsAdminUser` is the canonical name used by every admin-only endpoint built in
the admin-panel implementation. It re-exports `users.permissions.IsAdminRole`
to avoid a duplicate definition.
"""
from users.permissions import IsAdminRole as IsAdminUser  # noqa: F401
from users.permissions import IsDealer, IsActiveDealer, IsAdminOrDealer, IsOwnerOrAdmin  # noqa: F401

__all__ = [
    'IsAdminUser', 'IsDealer', 'IsActiveDealer',
    'IsAdminOrDealer', 'IsOwnerOrAdmin',
]
