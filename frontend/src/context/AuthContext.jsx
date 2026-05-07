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
   * DEV-ONLY: logs in a real backend test user so all API calls work correctly.
   * Uses POST /api/auth/dev-login/ which is only available when DEBUG=True.
   */
  const loginAsTestUser = useCallback(async (role = 'admin') => {
    if (!import.meta.env.DEV) return;
    try {
      const res = await fetch('/api/auth/dev-login/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ role }),
      });
      if (!res.ok) throw new Error('dev-login failed');
      const data = await res.json();
      window.__accessToken = data.access;
      localStorage.setItem('furnishop_refresh_token', data.refresh);
      setUser(data.user);
    } catch (err) {
      console.error('Dev login failed:', err);
    }
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
