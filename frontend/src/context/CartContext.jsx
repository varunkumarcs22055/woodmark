/**
 * Cart Context — Global cart state management.
 *
 * Uses React Context + useReducer for predictable state updates.
 * Cart is persisted to localStorage so it survives page refreshes.
 *
 * Provides:
 *   - cartItems: array of { product, quantity }
 *   - cartTotal: calculated total price
 *   - cartCount: total number of items
 *   - addToCart(product, quantity)
 *   - removeFromCart(productId)
 *   - updateQuantity(productId, quantity)
 *   - clearCart()
 */

import { createContext, useContext, useReducer, useEffect } from 'react';

const CartContext = createContext();

// Load cart from localStorage
const loadCart = () => {
  try {
    const stored = localStorage.getItem('furnishop_cart');
    return stored ? JSON.parse(stored) : [];
  } catch {
    return [];
  }
};

// Save cart to localStorage
const saveCart = (items) => {
  localStorage.setItem('furnishop_cart', JSON.stringify(items));
};

// ─── Reducer ───────────────────────────────────────────────────────

const cartReducer = (state, action) => {
  let newState;

  switch (action.type) {
    case 'ADD_ITEM': {
      const { product, quantity = 1 } = action.payload;
      const existingIndex = state.findIndex(item => item.product.id === product.id);

      if (existingIndex >= 0) {
        // Update quantity of existing item
        newState = state.map((item, index) =>
          index === existingIndex
            ? { ...item, quantity: item.quantity + quantity }
            : item
        );
      } else {
        // Add new item
        newState = [...state, { product, quantity }];
      }
      break;
    }

    case 'REMOVE_ITEM': {
      newState = state.filter(item => item.product.id !== action.payload);
      break;
    }

    case 'UPDATE_QUANTITY': {
      const { productId, quantity } = action.payload;
      if (quantity <= 0) {
        newState = state.filter(item => item.product.id !== productId);
      } else {
        newState = state.map(item =>
          item.product.id === productId
            ? { ...item, quantity }
            : item
        );
      }
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

  // Calculate derived values
  const cartTotal = cartItems.reduce(
    (sum, item) => sum + parseFloat(item.product.price) * item.quantity,
    0
  );
  const cartCount = cartItems.reduce((sum, item) => sum + item.quantity, 0);

  const addToCart = (product, quantity = 1) => {
    dispatch({ type: 'ADD_ITEM', payload: { product, quantity } });
  };

  const removeFromCart = (productId) => {
    dispatch({ type: 'REMOVE_ITEM', payload: productId });
  };

  const updateQuantity = (productId, quantity) => {
    dispatch({ type: 'UPDATE_QUANTITY', payload: { productId, quantity } });
  };

  const clearCart = () => {
    dispatch({ type: 'CLEAR_CART' });
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
