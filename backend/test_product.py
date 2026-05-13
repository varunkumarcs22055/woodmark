import os
import django
import sys

# Set up Django environment
sys.path.append(r'c:\Users\DELL\OneDrive\Desktop\ecomerse\furnotech_ecommerce\backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from products.models import Product, Category

def test_create_product():
    print("--- Testing Product Creation ---")
    try:
        cat = Category.objects.first()
        if not cat:
            cat = Category.objects.create(name="Default", slug="default")
        
        p = Product.objects.create(
            name="Test Shell Product",
            price=1000,
            category=cat,
            sku="TEST-SKU-123"
        )
        print(f"Created Product: {p.id}")
        p.delete()
        print("Deleted Product")
        print("--- Test Successful ---")
    except Exception as e:
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_create_product()
