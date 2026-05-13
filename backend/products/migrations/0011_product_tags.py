from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0010_product_rich_pdp_fields'),
    ]

    operations = [
        migrations.CreateModel(
            name='Tag',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=80, unique=True)),
                ('slug', models.SlugField(blank=True, max_length=100, unique=True)),
                ('description', models.CharField(blank=True, max_length=200)),
                ('is_navigation', models.BooleanField(db_index=True, default=False,
                    help_text='Show this tag in the storefront navbar.')),
                ('nav_label', models.CharField(blank=True, max_length=80,
                    help_text='Optional display name for navbar (defaults to `name`).')),
                ('nav_order', models.PositiveIntegerField(default=0)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('category', models.ForeignKey(blank=True, null=True,
                    on_delete=django.db.models.deletion.SET_NULL,
                    related_name='nav_tags', to='products.category')),
            ],
            options={
                'db_table': 'product_tags',
                'ordering': ['nav_order', 'name'],
                'indexes': [
                    models.Index(fields=['is_navigation', 'nav_order'], name='product_tags_nav_idx'),
                    models.Index(fields=['category', 'is_navigation'], name='product_tags_cat_nav_idx'),
                ],
            },
        ),
        migrations.AddField(
            model_name='product',
            name='tags',
            field=models.ManyToManyField(
                blank=True,
                help_text='Keywords that link this product to navbar entries and similar-product surfaces.',
                related_name='products', to='products.tag'),
        ),
    ]
