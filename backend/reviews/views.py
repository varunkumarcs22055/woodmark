"""
  GET   /api/reviews/?product_id=&ordering=
  GET   /api/reviews/summary/?product_id=
  POST  /api/reviews/                  auth required
  POST  /api/reviews/{id}/helpful/     toggle vote
  GET   /api/admin/reviews/?status=
  PATCH /api/admin/reviews/{id}/       admin moderation
"""
from django.db.models import Count
from django.utils import timezone
from rest_framework import generics, serializers, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from audit.mixins import AuditedMixin
from core.permissions import IsAdminUser

from .models import Review, ReviewVote


class ReviewSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()

    class Meta:
        model = Review
        fields = [
            'id', 'product', 'user', 'user_name',
            'rating', 'title', 'body',
            'verified_purchase', 'status', 'helpful_count',
            'created_at',
        ]
        read_only_fields = [
            'user', 'verified_purchase', 'helpful_count', 'status', 'created_at',
        ]

    def get_user_name(self, obj):
        return obj.user.full_name or obj.user.email.split('@')[0]


class AdminReviewSerializer(ReviewSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_slug = serializers.CharField(source='product.slug', read_only=True)
    user_email = serializers.EmailField(source='user.email', read_only=True)

    class Meta(ReviewSerializer.Meta):
        fields = ReviewSerializer.Meta.fields + [
            'product_name', 'product_slug', 'user_email',
        ]


class PublicReviewListView(generics.ListAPIView):
    """Approved-only feed for the storefront PDP."""
    permission_classes = [AllowAny]
    serializer_class = ReviewSerializer
    ordering_fields = ['created_at', 'rating', 'helpful_count']
    ordering = ['-helpful_count', '-created_at']

    def get_queryset(self):
        product_id = self.request.query_params.get('product_id')
        qs = Review.objects.filter(status='approved').select_related('user')
        if product_id:
            qs = qs.filter(product_id=product_id)
        return qs


class ReviewSummaryView(APIView):
    """Aggregate {avg, count, by_star} for a product — for the histogram block."""
    permission_classes = [AllowAny]

    def get(self, request):
        product_id = request.query_params.get('product_id')
        if not product_id:
            return Response({'detail': 'product_id is required.'}, status=status.HTTP_400_BAD_REQUEST)
        qs = Review.objects.filter(product_id=product_id, status='approved')
        rows = qs.values('rating').annotate(c=Count('id'))
        by_star = {str(i): 0 for i in range(1, 6)}
        for row in rows:
            by_star[str(row['rating'])] = row['c']
        from django.db.models import Avg
        avg = qs.aggregate(a=Avg('rating'))['a'] or 0
        return Response({
            'avg': round(float(avg), 2),
            'count': sum(by_star.values()),
            'by_star': by_star,
        })


class ReviewCreateView(generics.CreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ReviewSerializer

    def perform_create(self, serializer):
        # Defensively reject if a review already exists.
        if Review.objects.filter(
            product=serializer.validated_data['product'],
            user=self.request.user,
        ).exists():
            from rest_framework.exceptions import ValidationError
            raise ValidationError({'detail': 'You have already reviewed this product.'})
        # `verified_purchase` is set inside Review.save() via the OrderItem lookup.
        serializer.save(user=self.request.user)


class ReviewHelpfulView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            review = Review.objects.get(pk=pk, status='approved')
        except Review.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        # Toggle: if a vote row exists, delete and decrement; else create + increment.
        existing = ReviewVote.objects.filter(review=review, user=request.user).first()
        if existing is not None:
            existing.delete()
            Review.objects.filter(pk=review.pk).update(helpful_count=max(0, review.helpful_count - 1))
            return Response({'helpful': False})
        ReviewVote.objects.create(review=review, user=request.user, value=1)
        Review.objects.filter(pk=review.pk).update(helpful_count=review.helpful_count + 1)
        return Response({'helpful': True})


# ─── Admin moderation ────────────────────────────────────────────────────────

class AdminReviewListView(generics.ListAPIView):
    permission_classes = [IsAdminUser]
    serializer_class = AdminReviewSerializer
    ordering_fields = ['created_at', 'rating']
    ordering = ['-created_at']

    def get_queryset(self):
        qs = Review.objects.select_related('user', 'product')
        s = self.request.query_params.get('status')
        if s:
            qs = qs.filter(status=s)
        return qs


class AdminReviewModerateView(AuditedMixin, APIView):
    permission_classes = [IsAdminUser]
    audit_target_type = 'review'

    def patch(self, request, pk):
        try:
            review = Review.objects.get(pk=pk)
        except Review.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        new_status = request.data.get('status')
        if new_status not in ('pending', 'approved', 'rejected'):
            return Response(
                {'detail': "status must be one of: pending, approved, rejected."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        review.status = new_status
        review.moderator = request.user
        review.moderated_at = timezone.now()
        review.save(update_fields=['status', 'moderator', 'moderated_at', 'updated_at'])
        self.audit_write(request, action='approve' if new_status == 'approved' else 'reject',
                         target_id=review.id, payload={'status': new_status})
        return Response(AdminReviewSerializer(review).data)

    def delete(self, request, pk):
        try:
            review = Review.objects.get(pk=pk)
        except Review.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        payload = {
            'product_id': review.product_id,
            'user_id': review.user_id,
            'status': review.status,
        }
        review.delete()
        self.audit_write(request, action='delete', target_id=pk, payload=payload)
        return Response(status=status.HTTP_204_NO_CONTENT)
