# Frontend Prompt 3 — Product Detail Page, Cart Page & Order History

## Role
You are a senior frontend engineer. Build three pages: Product Detail (the product page that converts visitors to buyers), Cart Page (with discount-aware pricing), and Order History (guest and authenticated lookup).

---

## Context
These are the core conversion pages. Product Detail must show role-aware pricing, discount availability, stock, and similar products. Cart must accurately calculate totals with discounts. Order history supports both guest (email lookup) and authenticated user flows.

**Depends on:** Frontend Prompts 1 & 2 (design system, CartContext, ProductCard)
**Backend endpoints used:**
- `GET /api/products/{slug}/`
- `GET /api/products/similar/{id}/`
- `GET /api/orders/?email=<email>` (guest)
- `GET /api/orders/` (authenticated)

---

## Files to Create

```
frontend/src/pages/
├── ProductDetailPage.jsx
├── ProductDetailPage.css
├── CartPage.jsx
├── CartPage.css
├── OrdersPage.jsx
└── OrdersPage.css

frontend/src/components/
├── CartItem.jsx
├── CartItem.css
├── OrderCard.jsx
└── OrderCard.css
```

---

## ProductDetailPage — `src/pages/ProductDetailPage.jsx`

### Data Loading
```javascript
const { slug } = useParams();
const [product, setProduct] = useState(null);
const [similarProducts, setSimilarProducts] = useState([]);
const [quantity, setQuantity] = useState(1);
const [loading, setLoading] = useState(true);

useEffect(() => {
  const load = async () => {
    setLoading(true);
    try {
      const [prod, similar] = await Promise.all([
        fetchProduct(slug),
        fetchProduct(slug).then(p => fetchSimilarProducts(p.id)).catch(() => [])
      ]);
      setProduct(prod);
      setSimilarProducts(similar);
    } catch (err) {
      if (err.response?.status === 404) navigate('/404');
    } finally {
      setLoading(false);
    }
  };
  load();
}, [slug]);
```

### Page Layout Specification

```
┌──────────────────────────────────────────────────┐
│ Breadcrumb: Home > Sofas > Oslo Velvet Sofa       │
├─────────────────────┬────────────────────────────┤
│                     │  Name                       │
│  Product Image      │  Category badge | Rating    │
│  (large, square)    │  ─────────────────────────  │
│                     │  Effective Price (big)       │
│                     │  Original Price (striked)    │
│                     │  Discount badge: 15% OFF    │
│                     │  ─────────────────────────  │
│                     │  Units remaining: 77 left   │
│                     │  at this price              │
│                     │  ─────────────────────────  │
│                     │  Material | Color            │
│                     │  Dimensions                  │
│                     │  ─────────────────────────  │
│                     │  Stock: In Stock / Low Stock │
│                     │  ─────────────────────────  │
│                     │  Qty: [–] [2] [+]           │
│                     │  [Add to Cart]              │
│                     │  ─────────────────────────  │
│                     │  Trust badges               │
│                     │  (Shipping|Warranty|Return)  │
├─────────────────────┴────────────────────────────┤
│ Product Description                               │
├──────────────────────────────────────────────────┤
│ Similar Products                                  │
│ [Card] [Card] [Card] [Card]                       │
└──────────────────────────────────────────────────┘
```

### Key Logic

**Pricing display:**
```javascript
const hasDiscount = product.effective_price &&
  parseFloat(product.effective_price) < parseFloat(product.price);
const discountPercent = hasDiscount
  ? calcDiscountPercent(product.price, product.effective_price)
  : 0;
const displayPrice = hasDiscount ? product.effective_price : product.price;
```

**Stock status:**
```javascript
const getStockStatus = (stock) => {
  if (stock === 0) return { label: 'Out of Stock', class: 'status--error' };
  if (stock <= 5) return { label: `Only ${stock} left in stock!`, class: 'status--warning' };
  return { label: 'In Stock', class: 'status--success' };
};
```

**Quantity controls:**
```javascript
const maxQty = Math.min(product.stock, 10);
const decrementQty = () => setQuantity((q) => Math.max(1, q - 1));
const incrementQty = () => setQuantity((q) => Math.min(maxQty, q + 1));
```

**Add to Cart:**
```javascript
const handleAddToCart = () => {
  if (!product.in_stock) return;
  addToCart(product, quantity);
  toast.success(`${quantity}× ${product.name} added to cart!`);
};
```

**Discount units remaining note:**
```javascript
{product.discount_units_remaining !== null && (
  <div className="discount-units-note">
    {product.discount_units_remaining === 0
      ? 'Offer has ended — showing regular price'
      : `Only ${product.discount_units_remaining} units left at this discounted price`}
  </div>
)}
```

### Trust Badges (below Add to Cart button)
```javascript
const TRUST_BADGES = [
  { icon: <FiTruck />, label: 'Free Delivery', sub: 'On orders above ₹2,999' },
  { icon: <FiShield />, label: '1-Year Warranty', sub: 'On all products' },
  { icon: <FiRefreshCw />, label: '30-Day Returns', sub: 'Hassle-free returns' },
];
```

### CSS Requirements
- Two-column layout: image left (55%), info right (45%) on desktop
- Single column on mobile (image top, info below)
- Quantity selector: custom increment/decrement buttons
- Sticky Add-to-Cart button on mobile (fixed bottom bar on small screens)
- Breadcrumb styled with `>` separators
- Similar products in horizontal scroll on mobile, 4-column grid on desktop

---

## CartPage — `src/pages/CartPage.jsx`

### Layout
```
┌─────────────────────────────┬─────────────────────┐
│  Your Cart (N items)        │  Order Summary       │
│  ─────────────────────────  │  ───────────────     │
│  [CartItem]                 │  Subtotal: ₹XX,XXX   │
│  [CartItem]                 │  Discount: -₹X,XXX   │
│  [CartItem]                 │  Shipping: ₹499      │
│                             │  (FREE above ₹2,999) │
│  [← Continue Shopping]      │  ─────────────────   │
│                             │  Total: ₹XX,XXX      │
│                             │  [Proceed to         │
│                             │   Checkout →]        │
└─────────────────────────────┴─────────────────────┘
```

### Order Summary Calculation
```javascript
const subtotal = cartTotal; // Already uses effective_price
const shipping = subtotal >= 2999 ? 0 : 499;
const grandTotal = subtotal + shipping;

// Show "You saved" if any item has a discount
const originalTotal = cartItems.reduce(
  (sum, item) => sum + parseFloat(item.product.price) * item.quantity,
  0
);
const savedAmount = originalTotal - subtotal;
```

### Empty Cart State
```javascript
if (cartItems.length === 0) {
  return (
    <div className="cart-empty">
      <div className="cart-empty__icon"><FiShoppingBag size={64} /></div>
      <h2>Your cart is empty</h2>
      <p>Add some furniture to get started!</p>
      <Link to="/" className="btn-primary">Browse Products</Link>
    </div>
  );
}
```

---

## CartItem — `src/components/CartItem.jsx`

```javascript
export default function CartItem({ item }) {
  const { updateQuantity, removeFromCart } = useCart();
  const { product, quantity } = item;
  const effectivePrice = parseFloat(product.effective_price ?? product.price);
  const subtotal = effectivePrice * quantity;

  return (
    <div className="cart-item">
      <img src={product.image_url} alt={product.name} className="cart-item__image" />
      <div className="cart-item__info">
        <Link to={`/product/${product.slug}`} className="cart-item__name">
          {product.name}
        </Link>
        <span className="cart-item__meta">{product.material} · {product.color}</span>
        <div className="cart-item__pricing">
          <span className="cart-item__price">{formatPrice(effectivePrice)}</span>
          {product.effective_price && parseFloat(product.effective_price) < parseFloat(product.price) && (
            <span className="cart-item__original-price">{formatPrice(product.price)}</span>
          )}
        </div>
      </div>
      <div className="cart-item__controls">
        <div className="qty-control">
          <button onClick={() => updateQuantity(product.id, quantity - 1)} disabled={quantity <= 1}>–</button>
          <span>{quantity}</span>
          <button onClick={() => updateQuantity(product.id, quantity + 1)} disabled={quantity >= product.stock}>+</button>
        </div>
        <span className="cart-item__subtotal">{formatPrice(subtotal)}</span>
        <button className="cart-item__remove" onClick={() => removeFromCart(product.id)}>
          <FiTrash2 size={16} />
        </button>
      </div>
    </div>
  );
}
```

---

## OrdersPage — `src/pages/OrdersPage.jsx`

Supports both guest (email lookup) and authenticated user (auto-loads their orders):

```javascript
const { user } = useAuth();
const [email, setEmail] = useState('');
const [orders, setOrders] = useState([]);
const [loading, setLoading] = useState(false);
const [searched, setSearched] = useState(false);

// Auto-load for authenticated users
useEffect(() => {
  if (user) {
    loadOrders();
  }
}, [user]);

const loadOrders = async () => {
  setLoading(true);
  try {
    const data = await fetchOrders(user ? null : email);
    setOrders(data);
    setSearched(true);
  } catch (err) {
    toast.error('Failed to fetch orders.');
  } finally {
    setLoading(false);
  }
};

const handleEmailSearch = (e) => {
  e.preventDefault();
  if (!email.trim()) return;
  loadOrders();
};
```

### Page Layout:
- If authenticated: show "Your Orders" heading and auto-loaded list
- If guest: show email search form first, then results
- Empty state: "No orders found for this email"

---

## OrderCard — `src/components/OrderCard.jsx`

```javascript
export default function OrderCard({ order }) {
  const statusColors = {
    CREATED: '#8A8A8A',
    CONFIRMED: '#00736A',
    SHIPPED: '#1565C0',
    DELIVERED: '#2E7D32',
    CANCELLED: '#C62828',
  };

  return (
    <div className="order-card">
      <div className="order-card__header">
        <div>
          <span className="order-card__id">{order.order_id}</span>
          <span className="order-card__date">{formatDate(order.created_at)}</span>
        </div>
        <div className="order-card__statuses">
          <span
            className="order-card__status"
            style={{ color: statusColors[order.order_status] }}
          >
            ● {order.order_status}
          </span>
          {order.erp_order_id && (
            <span className="order-card__erp">ERP: {order.erp_order_id}</span>
          )}
        </div>
      </div>

      <div className="order-card__items">
        {order.items.map((item) => (
          <div key={item.id} className="order-card__item">
            <img src={item.product_image} alt={item.product_name} />
            <div>
              <span className="order-card__item-name">{item.product_name}</span>
              <span className="order-card__item-meta">
                Qty: {item.quantity} × {formatPrice(item.price)}
              </span>
            </div>
            <span className="order-card__item-subtotal">{formatPrice(item.subtotal)}</span>
          </div>
        ))}
      </div>

      <div className="order-card__footer">
        <span className="order-card__total">Total: {formatPrice(order.total_amount)}</span>
        <span className="order-card__payment">
          Payment: <strong>{order.payment_status}</strong>
        </span>
      </div>
    </div>
  );
}
```

---

## Acceptance Criteria

**Product Detail Page:**
- [ ] Loads product by slug from URL (`/product/oslo-velvet-sofa`)
- [ ] Shows 404-style message for nonexistent slug
- [ ] Displays effective price (with discount) for logged-in user with discount
- [ ] Shows "X units remaining at this price" when discount has a count limit
- [ ] Quantity selector is bounded by `product.stock` and minimum 1
- [ ] "Add to Cart" adds the correct quantity to cart and shows toast
- [ ] Similar products section renders up to 4 cards
- [ ] Breadcrumb renders correctly with category name

**Cart Page:**
- [ ] Shows all cart items with CartItem component
- [ ] Subtotal uses `effective_price` (discount-aware)
- [ ] "You saved ₹X" line shows when discounts applied
- [ ] Shipping: FREE for orders ≥ ₹2,999, ₹499 otherwise
- [ ] Grand total is correct
- [ ] "Proceed to Checkout" navigates to `/checkout`
- [ ] Removing item updates total in real-time
- [ ] Quantity update in CartItem is reflected in total immediately
- [ ] Empty cart shows empty state with "Browse Products" link

**Orders Page:**
- [ ] Guest: email search form works, shows orders for that email
- [ ] Authenticated user: auto-loads their orders without email form
- [ ] OrderCard shows order ID, date, status (color-coded), items with images, total
- [ ] Empty state when no orders found
