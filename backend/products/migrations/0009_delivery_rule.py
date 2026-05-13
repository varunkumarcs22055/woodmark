from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0008_product_dealer_only_product_min_order_quantity'),
    ]

    operations = [
        migrations.CreateModel(
            name='DeliveryRule',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('min_qty', models.PositiveIntegerField(default=1)),
                ('max_qty', models.PositiveIntegerField(default=1000000,
                    help_text='Inclusive upper bound. Use a large number for "and above".')),
                ('etd_days_min', models.PositiveSmallIntegerField()),
                ('etd_days_max', models.PositiveSmallIntegerField()),
                ('note', models.CharField(blank=True, max_length=160,
                    help_text='Optional human-readable note shown on the PDP.')),
                ('product', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='delivery_rules', to='products.product')),
            ],
            options={
                'db_table': 'product_delivery_rules',
                'ordering': ['product', 'min_qty'],
                'indexes': [models.Index(fields=['product', 'min_qty'], name='product_dr_product_min_qty_idx')],
            },
        ),
    ]
