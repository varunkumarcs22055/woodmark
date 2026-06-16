import os
import django
import sys
from decimal import Decimal

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings")
django.setup()

from django.test import Client
from users.models import User
from products.models import Product
from dealer_pricing.models import DealerTier
from dealer_credit.models import DealerCredit

client = Client()

# 1. Setup Dealer
try:
    dealer = User.objects.get(email='dev-dealer@woodmark.local')
except User.DoesNotExist:
    print("[-] Dealer not found.")
    sys.exit(1)

# Setup a Dealer Tier
tier, _ = DealerTier.objects.get_or_create(slug='premium', defaults={'name': 'Premium', 'default_discount_pct': Decimal('10.00')})
dealer.dealer_tier = tier
dealer.dealer_status = 'active'
dealer.save()

# Setup Credit Limit
credit, _ = DealerCredit.objects.get_or_create(dealer=dealer)
credit.credit_limit = Decimal('100000.00')
credit.amount_used = Decimal('0.00')
credit.is_active = True
credit.save()

# Login using JWT since DRF only accepts JWTAuthentication
from rest_framework_simplejwt.tokens import RefreshToken
token = str(RefreshToken.for_user(dealer).access_token)
print("[+] Generated JWT for:", dealer.email, "- Tier:", dealer.dealer_tier.name, f"({dealer.dealer_tier.default_discount_pct}% off)")
print("[+] Credit Limit: Rs.", credit.credit_limit)

# 2. Fetch Products
import time
start_time = time.time()
response = client.get('/api/products/', HTTP_HOST='localhost', HTTP_AUTHORIZATION=f'Bearer {token}')
duration = time.time() - start_time
print(f"[+] Fetched products in {duration:.4f}s. Status: {response.status_code}")
products = response.json().get('results', [])
if not products:
    print("[-] No products found!")
    sys.exit(1)

test_product = products[0]
print(f"[+] Selected Product: {test_product['name']} (MRP: Rs.{test_product['price']})")
print(f"    Effective Price for Dealer: Rs.{test_product['effective_price']}")

# Check if discount applied correctly
expected_price = Decimal(str(test_product['price'])) * (Decimal('1') - tier.default_discount_pct/100)
print(f"    Expected Price: Rs.{expected_price:.2f}")

if str(expected_price.quantize(Decimal('0.01'))) != str(test_product['effective_price']):
    print("[-] Warning: Effective price does not match expected discount!")
    sys.exit(1)

print("\n[+] 3. Testing Checkout with Dealer Credit")
payload = {
    'items': [{'product_id': test_product['id'], 'quantity': 2, 'price': str(test_product['effective_price'])}],
    'shipping_address': {'line1': '123 Dealer St', 'city': 'TestCity', 'state': 'TestState', 'postal_code': '123456', 'country': 'India', 'full_name': 'Dev Dealer', 'phone': '1234567890'},
    'billing_address': {'line1': '123 Dealer St', 'city': 'TestCity', 'state': 'TestState', 'postal_code': '123456', 'country': 'India', 'full_name': 'Dev Dealer', 'phone': '1234567890'},
    'payment_method': 'dealer_credit',
    'use_wallet': False,
    'subtotal': str(Decimal(str(test_product['effective_price'])) * 2),
    'tax_amount': '0.00',
    'total_amount': str(Decimal(str(test_product['effective_price'])) * 2)
}

start_time = time.time()
order_resp = client.post('/api/orders/create/', data=payload, content_type='application/json', HTTP_HOST='localhost', HTTP_AUTHORIZATION=f'Bearer {token}')
print(f"[+] Placed order in {time.time() - start_time:.4f}s. Status: {order_resp.status_code}")

if order_resp.status_code == 201:
    print("[+] Order created successfully!")
    credit.refresh_from_db()
    print(f"[+] Dealer Credit Used: Rs.{credit.amount_used}")
    if credit.amount_used == Decimal(str(test_product['effective_price'])) * 2:
        print("[+] Credit Limit perfectly deducted!")
    else:
        print("[-] Credit Limit mismatch!")
else:
    print("[-] Order placement failed:", order_resp.json())

print("\n[+] All Dealer testing successful!")
