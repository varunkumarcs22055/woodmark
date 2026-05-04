/**
 * Auth Context — JWT session state.
 *
 * - Access token kept in window.__accessToken (memory only, not localStorage).
 * - Refresh token stored in localStorage as 'furnishop_refresh_token'.
 * - On mount, attempts to restore the session by calling /auth/profile/ — the
 *   request interceptor will trigger an auto-refresh if the access token is
 *   missing/expired and a refresh token is available.
 */

import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { fetchProfile, logoutUser } from '../api';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Restore session from refresh token on app boot
  useEffect(() => {
    const restore = async () => {
      const refresh = localStorage.getItem('furnishop_refresh_token');
      if (!refresh) {
        setLoading(false);
        return;
      }
      try {
        const profile = await fetchProfile();
        setUser(profile);
      } catch {
        localStorage.removeItem('furnishop_refresh_token');
        window.__accessToken = null;
      } finally {
        setLoading(false);
      }
    };
    restore();
  }, []);

  const login = useCallback((tokens, userProfile) => {
    window.__accessToken = tokens.access;
    localStorage.setItem('furnishop_refresh_token', tokens.refresh);
    setUser(userProfile);
  }, []);

  const logout = useCallback(async () => {
    const refresh = localStorage.getItem('furnishop_refresh_token');
    if (refresh) {
      try {
        await logoutUser(refresh);
      } catch {
        /* ignore — logout is best-effort */
      }
    }
    window.__accessToken = null;
    localStorage.removeItem('furnishop_refresh_token');
    setUser(null);
  }, []);

  // Used by AuthCallbackPage after Google OAuth redirect
  const loginFromTokens = useCallback(async (tokens) => {
    window.__accessToken = tokens.access;
    localStorage.setItem('furnishop_refresh_token', tokens.refresh);
    try {
      const profile = await fetchProfile();
      setUser(profile);
      return profile;
    } catch (err) {
      window.__accessToken = null;
      localStorage.removeItem('furnishop_refresh_token');
      throw err;
    }
  }, []);

  /**
   * DEV-ONLY: synthesize a fake authenticated session without calling the
   * backend. Lets you preview role-gated screens (admin/dealer dashboards)
   * before the auth backend is wired up. NEVER ship this to production —
   * the guard below ensures it's a no-op outside Vite's dev mode.
   */
  const loginAsTestUser = useCallback((role = 'admin') => {
    if (!import.meta.env.DEV) {
      console.warn('loginAsTestUser is dev-only');
      return;
    }
    const profiles = {
      admin: { id: 1, email: 'test-admin@furnishop.local', full_name: 'Test Admin',
               role: 'admin', dealer_status: null, phone: '' },
      dealer: { id: 2, email: 'test-dealer@furnishop.local', full_name: 'Test Dealer',
                role: 'dealer', dealer_status: 'active',
                dealer_company_name: 'Test Dealer Co.',
                dealer_gst_number: '29ABCDE1234F1Z5', phone: '9876543210' },
      user: { id: 3, email: 'test-user@furnishop.local', full_name: 'Test User',
              role: 'user', dealer_status: null, phone: '9876543210' },
    };
    window.__accessToken = `dev-test-token-${role}`;
    setUser(profiles[role] || profiles.user);
  }, []);

  // Refresh user profile in-place (used after profile edits, dealer apply, etc.)
  const refreshProfile = useCallback(async () => {
    try {
      const profile = await fetchProfile();
      setUser(profile);
      return profile;
    } catch {
      return null;
    }
  }, []);

  return (
    <AuthContext.Provider
      value={{ user, loading, login, logout, loginFromTokens, refreshProfile, loginAsTestUser }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
