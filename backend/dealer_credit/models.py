from django.conf import settings
from django.db import models


class DealerCredit(models.Model):
    """
    Singleton-per-dealer credit ledger.

    `amount_used` is the running total of unpaid `Invoice.amount_due` for
    orders the dealer placed with `payment_method='credit'`. It is the
    single source of truth for "how much of my limit is used".

    Mutated transactionally inside the invoice signal and the admin
    payment-recording endpoint — never set this directly from a view.
    """
    dealer = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='credit',
    )
    credit_limit = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    amount_used = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    terms_days = models.PositiveIntegerField(default=30)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'dealer_credit'

    @property
    def remaining(self):
        return max(0, (self.credit_limit or 0) - (self.amount_used or 0))

    def __str__(self):
        return f'{self.dealer_id} — limit {self.credit_limit}, used {self.amount_used}'


class DealerPayment(models.Model):
    METHOD_CHOICES = [
        ('bank_transfer', 'Bank Transfer'),
        ('cheque', 'Cheque'),
        ('upi', 'UPI'),
        ('cash', 'Cash'),
        ('razorpay', 'Razorpay'),
    ]

    dealer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='dealer_payments',
    )
    invoice = models.ForeignKey(
        'invoices.Invoice', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='dealer_payments',
        help_text='Optional — NULL means an on-account / advance payment.',
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    method = models.CharField(max_length=20, choices=METHOD_CHOICES)
    reference = models.CharField(
        max_length=80, blank=True,
        help_text='UTR / cheque # / transaction ID.',
    )
    recorded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='recorded_dealer_payments',
    )
    note = models.TextField(blank=True)
    received_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'dealer_payments'
        ordering = ['-received_at']
        indexes = [
            models.Index(fields=['dealer', '-received_at']),
        ]

    def __str__(self):
        return f'{self.dealer_id} paid {self.amount} via {self.method}'
