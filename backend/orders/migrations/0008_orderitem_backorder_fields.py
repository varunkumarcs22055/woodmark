from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0007_order_payment_type_and_early_discount'),
    ]

    operations = [
        migrations.AddField(
            model_name='orderitem',
            name='is_backorder',
            field=models.BooleanField(db_index=True, default=False),
        ),
        migrations.AddField(
            model_name='orderitem',
            name='backorder_quantity',
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.AddField(
            model_name='orderitem',
            name='expected_restock_date',
            field=models.DateField(blank=True, null=True),
        ),
    ]
