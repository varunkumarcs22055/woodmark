from django.db import migrations


def seed_tiers(apps, schema_editor):
    DealerTier = apps.get_model('dealer_pricing', 'DealerTier')
    rows = [
        ('standard', 'Standard Dealer', 25, 0),
        ('premium', 'Premium Dealer', 31, 1),
        ('platinum', 'Platinum Dealer', 36, 2),
    ]
    for slug, name, pct, order in rows:
        DealerTier.objects.update_or_create(
            slug=slug,
            defaults={
                'name': name,
                'default_discount_pct': pct,
                'sort_order': order,
                'is_active': True,
            },
        )


def reverse(apps, schema_editor):
    DealerTier = apps.get_model('dealer_pricing', 'DealerTier')
    DealerTier.objects.filter(slug__in=['standard', 'premium', 'platinum']).delete()


class Migration(migrations.Migration):
    dependencies = [
        ('dealer_pricing', '0001_initial'),
    ]
    operations = [
        migrations.RunPython(seed_tiers, reverse),
    ]
