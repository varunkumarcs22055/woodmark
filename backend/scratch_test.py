import os
import django
import sys

# Set up Django environment
sys.path.append(r'c:\Users\DELL\OneDrive\Desktop\ecomerse\furnotech_ecommerce\backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from cms.models import Banner, Page, FAQ, ContentBlock
from django.core.serializers.json import DjangoJSONEncoder
import json

def test_cms_models():
    print("--- Testing CMS Models CRUD ---")
    try:
        # Test Banner
        b = Banner.objects.create(title="Test Banner", placement="home_hero")
        print(f"Created Banner: {b.id}")
        b.title = "Updated Banner"
        b.save()
        print(f"Updated Banner: {b.id}")
        b.delete()
        print("Deleted Banner")

        # Test ContentBlock
        cb = ContentBlock.objects.create(key="test_key", title="Test Block", data_json={"foo": "bar"})
        print(f"Created ContentBlock: {cb.id}")
        cb.title = "Updated Block"
        cb.save()
        print(f"Updated ContentBlock: {cb.id}")
        cb.delete()
        print("Deleted ContentBlock")

        print("--- CRUD Successful ---")
    except Exception as e:
        print(f"--- CRUD FAILED: {e} ---")

if __name__ == "__main__":
    test_cms_models()
