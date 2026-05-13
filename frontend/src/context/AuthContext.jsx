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
import axios from 'axios';
import api, { fetchProfile, logoutUser } from '../api';

const AuthContext = createContext();
const API_BASE = import.meta.env.VITE_API_BASE_URL || '/api';

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Restore session from refresh token on app boot.
  //
  // On a fresh tab/window, `window.__accessToken` is undefined (it lives in
  // memory only, per the XSS-mitigation policy). If we just call fetchProfile
  // it produces a 401 → the interceptor refreshes → retries. That worked, BUT
  // it failed silently when the refresh token had been rotated and never saved
  // back to localStorage (now fixed in api/index.js). To make session restore
  // bulletproof we now refresh proactively here so the access token is in
  // memory before any other request fires.
  useEffect(() => {
    const restore = async () => {
      const refresh = localStorage.getItem('furnishop_refresh_token');
      if (!refresh) {
        setLoading(false);
        return;
      }
      try {
        // Proactive refresh — pre-warms window.__accessToken and rotates the
        // refresh token in localStorage so every tab opened later sees a
        // fresh, non-blacklisted token.
        const res = await axios.post(`${API_BASE}/auth/token/refresh/`,
          { refresh });
        window.__accessToken = res.data.access;
        if (res.data.refresh) {
          localStorage.setItem('furnishop_refresh_token', res.data.refresh);
        }
        const profile = await fetchProfile();
        setUser(profile);
      } catch {
        // Refresh failed → token is dead, clear and force re-login.
        localStorage.removeItem('furnishop_refresh_token');
        window.__accessToken = null;
        setUser(null);
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
   * Quick test login — issues real JWTs for seeded user / dealer / admin
   * accounts. The endpoint is gated server-side on `DEBUG=True` OR
   * `ALLOW_DEV_LOGIN=true` (Render env var), so this is safe to call from
   * both `vite dev` and prod when the flag is on.
   *
   * Uses the configured axios `api` client (so VITE_API_BASE_URL is
   * honored on prod). The earlier `fetch('/api/...')` hit the Vercel
   * SPA itself in production and silently failed.
   */
  const loginAsTestUser = useCallback(async (role = 'admin') => {
    try {
      const { data } = await api.post('/auth/dev-login/', { role });
      window.__accessToken = data.access;
      localStorage.setItem('furnishop_refresh_token', data.refresh);
      setUser(data.user);
      return data.user;
    } catch (err) {
      console.error('Dev login failed:', err.response?.data || err.message);
      throw err;
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
