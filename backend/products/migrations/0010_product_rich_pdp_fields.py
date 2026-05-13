from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0009_delivery_rule'),
    ]

    operations = [
        migrations.AddField(
            model_name='product',
            name='short_description',
            field=models.CharField(blank=True, max_length=240,
                help_text='One-line summary shown above the bullet highlights on the PDP.'),
        ),
        migrations.AddField(
            model_name='product',
            name='feature_blocks',
            field=models.JSONField(blank=True, default=list,
                help_text='Alternating image + text marketing blocks rendered below the buy box.'),
        ),
        migrations.AddField(
            model_name='product',
            name='perks',
            field=models.JSONField(blank=True, default=list,
                help_text='Trust strip; each item: {icon, title, subtitle}. Optional.'),
        ),
        migrations.AddField(
            model_name='product',
            name='youtube_url',
            field=models.URLField(blank=True, max_length=500),
        ),
        migrations.AddField(
            model_name='product',
            name='warranty_years',
            field=models.PositiveSmallIntegerField(default=1),
        ),
        migrations.AddField(
            model_name='product',
            name='installation_required',
            field=models.BooleanField(default=False,
                help_text='Show DIY assembly notice and surface assembly video.'),
        ),
        migrations.AddField(
            model_name='product',
            name='care_instructions',
            field=models.TextField(blank=True,
                help_text='Optional cleaning / maintenance instructions.'),
        ),
        migrations.AddField(
            model_name='product',
            name='return_policy_days',
            field=models.PositiveSmallIntegerField(default=7),
        ),
    ]
