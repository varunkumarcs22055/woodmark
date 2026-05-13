/**
 * useAddToCartGuarded — wraps useCart().addToCart.
 *
 * Guest checkout is supported end-to-end (backend accepts guest orders
 * via /api/orders/create/ with email + address), so we no longer block
 * anonymous users at "Add to Cart". They can build a cart freely; the
 * sign-in nudge happens only when they actually open the checkout page
 * (which can also accept guest submissions).
 */
import { useCart } from '../context/CartContext';

export default function useAddToCartGuarded() {
  const { addToCart } = useCart();
  return (product, quantity = 1) => {
    addToCart(product, quantity);
    return true;
  };
}
