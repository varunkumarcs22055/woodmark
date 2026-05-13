from django.utils import timezone
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from users.permissions import IsAdminRole

from .models import SupportTicket, TicketMessage
from .serializers import (
    SupportTicketSerializer, SupportTicketCreateSerializer,
    TicketMessageSerializer, TicketStatusSerializer,
)


def _is_admin(user):
    return getattr(user, 'role', '') == 'admin' or getattr(user, 'is_superuser', False)


class TicketListCreateView(APIView):
    """
    GET  /api/support/tickets/   — caller's tickets (or all if admin)
    POST /api/support/tickets/   — open a new ticket + first message
    """
    permission_classes = [AllowAny]

    def get(self, request):
        qs = SupportTicket.objects.select_related('user', 'related_order').prefetch_related('messages')
        if not request.user.is_authenticated:
            return Response([])
        if not _is_admin(request.user):
            qs = qs.filter(user=request.user)
        status_filter = request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)
        return Response(SupportTicketSerializer(qs, many=True).data)

    def post(self, request):
        ser = SupportTicketCreateSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data

        if not request.user.is_authenticated:
            if not data.get('guest_email'):
                return Response({'guest_email': ['Required for guest tickets.']}, status=status.HTTP_400_BAD_REQUEST)
        
        ticket = SupportTicket.objects.create(
            user=request.user if request.user.is_authenticated else None,
            guest_email=data.get('guest_email'),
            guest_name=data.get('guest_name'),
            subject=data['subject'],
            category=data['category'],
            priority=data['priority'],
            related_order=data.get('related_order'),
        )
        TicketMessage.objects.create(
            ticket=ticket, 
            sender=request.user if request.user.is_authenticated else None, 
            body=data['body'],
        )

        # Notify admins so a human picks it up
        try:
            from services.notifications import notify_admins
            notify_admins(
                kind='support_ticket_opened',
                title=f'New ticket {ticket.ticket_number}: {ticket.subject}',
                body=f'{request.user.email} opened a {ticket.priority} {ticket.category} ticket.',
                payload={'ticket_id': ticket.id, 'priority': ticket.priority},
                channels=['inapp', 'email'],
            )
        except Exception:
            pass

        return Response(SupportTicketSerializer(ticket).data, status=status.HTTP_201_CREATED)


class TicketDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def _get(self, pk, user):
        try:
            ticket = (SupportTicket.objects
                      .select_related('user', 'related_order', 'assigned_to')
                      .prefetch_related('messages__sender').get(pk=pk))
        except SupportTicket.DoesNotExist:
            return None, Response({'error': 'Ticket not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not (_is_admin(user) or ticket.user_id == user.id):
            return None, Response({'error': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)
        return ticket, None

    def get(self, request, pk):
        ticket, err = self._get(pk, request.user)
        if err:
            return err
        # Hide internal notes from non-admins
        data = SupportTicketSerializer(ticket).data
        if not _is_admin(request.user):
            data['messages'] = [m for m in data['messages'] if not m['is_internal_note']]
        return Response(data)


class TicketMessageView(APIView):
    """POST /api/support/tickets/<pk>/messages/  body={body, is_internal_note?}"""
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            ticket = SupportTicket.objects.get(pk=pk)
        except SupportTicket.DoesNotExist:
            return Response({'error': 'Ticket not found.'}, status=status.HTTP_404_NOT_FOUND)

        is_admin = _is_admin(request.user)
        if not (is_admin or ticket.user_id == request.user.id):
            return Response({'error': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        body = (request.data.get('body') or '').strip()
        if not body:
            return Response({'body': ['This field is required.']}, status=status.HTTP_400_BAD_REQUEST)

        is_internal = bool(request.data.get('is_internal_note')) and is_admin
        msg = TicketMessage.objects.create(
            ticket=ticket, sender=request.user, body=body,
            is_internal_note=is_internal,
            attachment_url=(request.data.get('attachment_url') or '').strip(),
        )

        # Auto-flip status: customer reply → awaiting_agent, agent reply → awaiting_customer
        if not is_internal:
            new_status = 'awaiting_customer' if is_admin else 'awaiting_agent'
            if ticket.status not in ('resolved', 'closed') and ticket.status != new_status:
                ticket.status = new_status
                ticket.save(update_fields=['status'])

            # Notify the other side
            try:
                from services.notifications import notify, notify_admins
                if is_admin:
                    notify(
                        user=ticket.user,
                        kind='support_reply',
                        title=f'Reply on ticket {ticket.ticket_number}',
                        body=body[:300],
                        payload={'ticket_id': ticket.id},
                        channels=['inapp', 'email'],
                    )
                else:
                    notify_admins(
                        kind='support_customer_reply',
                        title=f'Customer replied on {ticket.ticket_number}',
                        body=body[:300],
                        payload={'ticket_id': ticket.id},
                        channels=['inapp'],
                    )
            except Exception:
                pass

        return Response(TicketMessageSerializer(msg).data, status=status.HTTP_201_CREATED)


class AdminTicketStatusView(APIView):
    """PATCH /api/support/admin/tickets/<pk>/status/  body={status}"""
    permission_classes = [IsAdminRole]

    def patch(self, request, pk):
        try:
            ticket = SupportTicket.objects.get(pk=pk)
        except SupportTicket.DoesNotExist:
            return Response({'error': 'Ticket not found.'}, status=status.HTTP_404_NOT_FOUND)

        ser = TicketStatusSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        new_status = ser.validated_data['status']
        ticket.status = new_status
        if new_status == 'resolved':
            ticket.resolved_at = timezone.now()
        elif new_status == 'closed':
            ticket.closed_at = timezone.now()
        ticket.assigned_to = request.user
        ticket.save(update_fields=['status', 'resolved_at', 'closed_at', 'assigned_to'])

        try:
            from services.notifications import notify
            notify(
                user=ticket.user,
                kind='support_status_changed',
                title=f'Ticket {ticket.ticket_number} → {ticket.get_status_display()}',
                body=f'Your ticket status was updated to {ticket.get_status_display()}.',
                channels=['inapp', 'email'],
            )
        except Exception:
            pass

        return Response(SupportTicketSerializer(ticket).data)
