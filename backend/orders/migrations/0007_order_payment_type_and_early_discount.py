from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0006_order_coupon_code_order_coupon_discount'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='payment_type',
            field=models.CharField(
                choices=[
                    ('immediate', 'Immediate'),
                    ('credit', 'On Credit'),
                    ('cod', 'COD'),
                ],
                db_index=True,
                default='immediate',
                help_text='Whether the order is paid now, on credit, or COD; drives early-payment discount.',
                max_length=12,
            ),
        ),
        migrations.AddField(
            model_name='order',
            name='early_payment_discount',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=10),
        ),
    ]
