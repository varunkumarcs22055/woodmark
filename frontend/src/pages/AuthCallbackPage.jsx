/**
 * AuthCallbackPage — completes Google OAuth.
 *
 * Backend redirects here with ?access=<jwt>&refresh=<jwt> query params.
 * We immediately strip those tokens from the URL via history.replaceState
 * (so they don't end up in browser history, referer headers, or bookmarks),
 * then hand them to AuthContext.loginFromTokens which fetches the profile
 * and sets up the session.
 */
import { useEffect, useRef } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';
import './LoginPage.css';

export default function AuthCallbackPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { loginFromTokens } = useAuth();
  const ranRef = useRef(false);

  useEffect(() => {
    // Guard against StrictMode double-invoke in dev
    if (ranRef.current) return;
    ranRef.current = true;

    const access = searchParams.get('access');
    const refresh = searchParams.get('refresh');
    const error = searchParams.get('error');

    if (error) {
      toast.error('Sign-in was cancelled or failed. Please try again.');
      navigate('/login', { replace: true });
      return;
    }

    if (!access || !refresh) {
      toast.error('Authentication failed. Please try again.');
      navigate('/login', { replace: true });
      return;
    }

    // Strip the tokens from the URL immediately
    window.history.replaceState({}, document.title, '/auth-callback');

    (async () => {
      try {
        const profile = await loginFromTokens({ access, refresh });
        toast.success(`Welcome${profile?.full_name ? `, ${profile.full_name}` : ''}!`);
        // Send dealers to their portal, admins to theirs, everyone else to home
        const dest =
          profile?.role === 'admin'
            ? '/admin-dashboard'
            : profile?.role === 'dealer'
              ? '/dealer-dashboard'
              : '/';
        navigate(dest, { replace: true });
      } catch {
        toast.error('Could not complete sign-in. Please try again.');
        navigate('/login', { replace: true });
      }
    })();
  }, [searchParams, navigate, loginFromTokens]);

  return (
    <div className="auth-callback">
      <div className="auth-callback__spinner" />
      <p>Completing sign-in…</p>
    </div>
  );
}
