/**
 * Cart Context — Global cart state management.
 *
 * Uses React Context + useReducer for predictable state updates.
 * Cart is persisted to localStorage so it survives page refreshes.
 *
 * Important: only a SLIM product snapshot is stored — we strip large fields
 * like `description` so a typical cart fits well under the ~5MB localStorage
 * quota even with many items. saveCart is wrapped in try/catch so a quota
 * blow-up never crashes the provider.
 *
 * Provides:
 *   - cartItems: array of { product, quantity }
 *   - cartTotal: calculated total price (uses effective_price when present)
 *   - cartCount: total number of units
 *   - addToCart(product, quantity)
 *   - removeFromCart(productId)
 *   - updateQuantity(productId, quantity)
 *   - clearCart()
 */

import { createContext, useContext, useReducer, useState } from 'react';

const CartContext = createContext();
const STORAGE_KEY = 'woodmark_cart';
const SAVED_KEY = 'woodmark_saved';

/**
 * Trim an API product down to only the fields the cart actually renders.
 * Drops `description`, timestamps, and any unknown extras to keep
 * localStorage tiny.
 */
const slimProduct = (p) => ({
  id: p.id,
  name: p.name,
  slug: p.slug,
  price: p.price,
  effective_price: p.effective_price ?? null,
  discount_applied: p.discount_applied ?? null,
  discount_units_remaining: p.discount_units_remaining ?? null,
  image_url: p.image_url,
  category_name: p.category_name ?? p.category?.name ?? '',
  material: p.material ?? '',
  color: p.color ?? '',
  stock: p.stock ?? 0,
  in_stock: p.in_stock ?? (p.stock ?? 0) > 0,
});

const loadCart = () => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    const parsed = stored ? JSON.parse(stored) : [];
    if (!Array.isArray(parsed)) return [];
    // Defensive: re-slim on load in case the stored shape is older/bloated
    return parsed
      .filter((it) => it && it.product && it.product.id)
      .map((it) => ({
        product: slimProduct(it.product),
        quantity: Math.max(1, parseInt(it.quantity, 10) || 1),
      }));
  } catch {
    // Corrupt or unreadable — start fresh
    try { localStorage.removeItem(STORAGE_KEY); } catch { /* ignore */ }
    return [];
  }
};

const saveCart = (items) => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
  } catch (err) {
    // Most likely QuotaExceededError. Don't crash the app — log and continue.
    // The in-memory cart still works for this session.
    console.warn('Cart could not be persisted to localStorage:', err?.name || err);
  }
};

// ─── Saved-for-later (separate slim list) ──────────────────────────
const loadSaved = () => {
  try {
    const stored = localStorage.getItem(SAVED_KEY);
    const parsed = stored ? JSON.parse(stored) : [];
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((p) => p && p.id).map(slimProduct);
  } catch {
    try { localStorage.removeItem(SAVED_KEY); } catch { /* ignore */ }
    return [];
  }
};

const saveSavedList = (items) => {
  try {
    localStorage.setItem(SAVED_KEY, JSON.stringify(items));
  } catch (err) {
    console.warn('Saved list could not be persisted:', err?.name || err);
  }
};

// ─── Reducer ───────────────────────────────────────────────────────

const cartReducer = (state, action) => {
  let newState;

  switch (action.type) {
    case 'ADD_ITEM': {
      const { product, quantity = 1 } = action.payload;
      const slim = slimProduct(product);
      const existingIndex = state.findIndex((item) => item.product.id === slim.id);

      if (existingIndex >= 0) {
        newState = state.map((item, index) =>
          index === existingIndex
            ? { ...item, product: slim, quantity: item.quantity + quantity }
            : item
        );
      } else {
        newState = [...state, { product: slim, quantity }];
      }
      break;
    }

    case 'REMOVE_ITEM': {
      newState = state.filter((item) => item.product.id !== action.payload);
      break;
    }

    case 'UPDATE_QUANTITY': {
      const { productId, quantity } = action.payload;
      if (quantity <= 0) {
        newState = state.filter((item) => item.product.id !== productId);
      } else {
        newState = state.map((item) =>
          item.product.id === productId ? { ...item, quantity } : item
        );
      }
      break;
    }

    case 'UPDATE_PRODUCT_DATA': {
      const { productId, product } = action.payload;
      const slim = slimProduct(product);
      newState = state.map((item) =>
        item.product.id === productId ? { ...item, product: slim } : item
      );
      break;
    }


    case 'CLEAR_CART':
      newState = [];
      break;

    default:
      return state;
  }

  saveCart(newState);
  return newState;
};

// ─── Provider Component ────────────────────────────────────────────

export function CartProvider({ children }) {
  const [cartItems, dispatch] = useReducer(cartReducer, [], loadCart);
  const [savedItems, setSavedItems] = useState(loadSaved);

  const persistSaved = (updater) => {
    setSavedItems((prev) => {
      const next = typeof updater === 'function' ? updater(prev) : updater;
      saveSavedList(next);
      return next;
    });
  };

  // Discount-aware totals
  const cartTotal = cartItems.reduce(
    (sum, item) =>
      sum + parseFloat(item.product.effective_price ?? item.product.price) * item.quantity,
    0
  );
  const cartCount = cartItems.reduce((sum, item) => sum + item.quantity, 0);

  /**
   * Dealer/B2B optimization: when quantity changes, we re-fetch the product
   * from the API with `?qty=N` so the backend pricing engine can re-resolve
   * tiered discounts, ladder pricing, and negotiated overrides.
   */
  const refreshPrice = async (productId, quantity) => {
    const item = cartItems.find(it => it.product.id === productId);
    if (!item) return;

    try {
      const { fetchProducts } = await import('../api');
      const data = await fetchProducts({ id: productId, qty: quantity });
      const updatedProduct = data.results?.find(p => p.id === productId) || data.results?.[0];

      if (updatedProduct) {
        dispatch({
          type: 'UPDATE_PRODUCT_DATA',
          payload: { productId, product: updatedProduct }
        });
      }
    } catch (err) {
      console.error('Failed to refresh cart price:', err);
    }
  };

  const addToCart = (product, quantity = 1) => {
    dispatch({ type: 'ADD_ITEM', payload: { product, quantity } });
    // If quantity > 1, refresh immediately to get tiered price
    if (quantity > 1) refreshPrice(product.id, quantity);
  };

  const removeFromCart = (productId) => {
    dispatch({ type: 'REMOVE_ITEM', payload: productId });
  };

  const updateQuantity = (productId, quantity) => {
    dispatch({ type: 'UPDATE_QUANTITY', payload: { productId, quantity } });
    refreshPrice(productId, quantity);
  };

  const clearCart = () => {
    dispatch({ type: 'CLEAR_CART' });
  };

  // ── Save for later ──────────────────────────────────────────────
  const saveForLater = (productId) => {
    const item = cartItems.find((it) => it.product.id === productId);
    if (!item) return;
    dispatch({ type: 'REMOVE_ITEM', payload: productId });
    persistSaved((prev) =>
      prev.some((p) => p.id === productId) ? prev : [item.product, ...prev]
    );
  };

  const moveToCart = (productId) => {
    const product = savedItems.find((p) => p.id === productId);
    if (!product) return;
    persistSaved((prev) => prev.filter((p) => p.id !== productId));
    dispatch({ type: 'ADD_ITEM', payload: { product, quantity: 1 } });
  };

  const removeSaved = (productId) => {
    persistSaved((prev) => prev.filter((p) => p.id !== productId));
  };

  return (
    <CartContext.Provider
      value={{
        cartItems,
        cartTotal,
        cartCount,
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart,
        savedItems,
        savedCount: savedItems.length,
        saveForLater,
        moveToCart,
        removeSaved,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

// Custom hook for consuming cart context
export function useCart() {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
}
