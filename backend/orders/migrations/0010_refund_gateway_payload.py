from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0009_order_billing_company_name_order_billing_gstin'),
    ]

    operations = [
        migrations.AddField(
            model_name='refund',
            name='gateway_payload',
            field=models.JSONField(blank=True, default=dict),
        ),
    ]
