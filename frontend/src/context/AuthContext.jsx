/**
 * Auth Context — JWT session state.
 *
 * - Access token kept in window.__accessToken (memory only, not localStorage).
 * - Refresh token stored in localStorage as 'woodmark_refresh_token'.
 * - On mount, attempts to restore the session by calling /auth/profile/ — the
 *   request interceptor will trigger an auto-refresh if the access token is
 *   missing/expired and a refresh token is available.
 */

import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import api, { fetchProfile, logoutUser } from '../api';

const AuthContext = createContext();

const PROFILE_CACHE_KEY = 'woodmark_user_profile';

// Read cached user from localStorage *synchronously* (so first render already
// has it). Returns null if missing or malformed.
function readCachedUser() {
  try {
    const raw = localStorage.getItem(PROFILE_CACHE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    // Sanity check: must have an id+email. Anything else is junk.
    if (parsed && parsed.id && parsed.email) return parsed;
    return null;
  } catch {
    return null;
  }
}

function writeCachedUser(profile) {
  try {
    if (profile) {
      localStorage.setItem(PROFILE_CACHE_KEY, JSON.stringify(profile));
    } else {
      localStorage.removeItem(PROFILE_CACHE_KEY);
    }
  } catch {
    /* quota / privacy mode — ignore */
  }
}

export function AuthProvider({ children }) {
  // Initialise from localStorage so the very first paint already shows the
  // logged-in UI. If the refresh-token validation later fails we'll clear it.
  // This makes session restore feel instant on every page navigation / reload.
  const initialUser = (() => {
    if (typeof window === 'undefined') return null;
    if (!localStorage.getItem('woodmark_refresh_token')) return null;
    return readCachedUser();
  })();
  const [user, setUser] = useState(initialUser);
  // `loading` only stays true on the very first boot when we have NO cached
  // user but DO have a refresh token (we need to fetch the profile). Once
  // we have a cached user, the UI is already correct — no need to gate it.
  const [loading, setLoading] = useState(!initialUser
    && typeof window !== 'undefined'
    && !!localStorage.getItem('woodmark_refresh_token'));

  // Background validate: refresh the profile so any stale data (role change,
  // dealer approval, etc.) reconciles. Failures = token dead -> log out.
  useEffect(() => {
    const refresh = localStorage.getItem('woodmark_refresh_token');
    if (!refresh) {
      setLoading(false);
      return;
    }
    let cancelled = false;
    fetchProfile()
      .then((profile) => {
        if (cancelled) return;
        setUser(profile);
        writeCachedUser(profile);
      })
      .catch(() => {
        if (cancelled) return;
        // Refresh path failed -> token is dead. Clear everything.
        localStorage.removeItem('woodmark_refresh_token');
        writeCachedUser(null);
        window.__accessToken = null;
        setUser(null);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => { cancelled = true; };
  }, []);

  const login = useCallback((tokens, userProfile) => {
    window.__accessToken = tokens.access;
    localStorage.setItem('woodmark_refresh_token', tokens.refresh);
    writeCachedUser(userProfile);
    setUser(userProfile);
  }, []);

  const logout = useCallback(async () => {
    const refresh = localStorage.getItem('woodmark_refresh_token');
    if (refresh) {
      try {
        await logoutUser(refresh);
      } catch {
        /* ignore — logout is best-effort */
      }
    }
    window.__accessToken = null;
    localStorage.removeItem('woodmark_refresh_token');
    writeCachedUser(null);
    setUser(null);
  }, []);

  // Used by AuthCallbackPage after Google OAuth redirect
  const loginFromTokens = useCallback(async (tokens) => {
    window.__accessToken = tokens.access;
    localStorage.setItem('woodmark_refresh_token', tokens.refresh);
    try {
      const profile = await fetchProfile();
      writeCachedUser(profile);
      setUser(profile);
      return profile;
    } catch (err) {
      window.__accessToken = null;
      localStorage.removeItem('woodmark_refresh_token');
      writeCachedUser(null);
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
      localStorage.setItem('woodmark_refresh_token', data.refresh);
      writeCachedUser(data.user);
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
      writeCachedUser(profile);
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
