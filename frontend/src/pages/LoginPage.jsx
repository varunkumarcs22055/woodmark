/**
 * LoginPage — split-layout sign-in form with Google OAuth.
 * After successful login, redirects to the page the user came from
 * (read from location.state.from), or to "/" by default.
 */
import { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { FiMail, FiLock, FiEye, FiEyeOff, FiKey } from 'react-icons/fi';
import { FcGoogle } from 'react-icons/fc';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';
import { loginUser, requestEmailOtp, verifyEmailOtp } from '../api';
import './LoginPage.css';

export default function LoginPage() {
  const { login, loginAsTestUser } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  // Honor both routed `state.from` (set by ProtectedRoute) and `?next=…`
  // (set by useAddToCartGuarded and other inline auth gates).
  const nextParam = new URLSearchParams(location.search).get('next');
  const from = location.state?.from?.pathname || nextParam || '/';

  const [mode, setMode] = useState('password'); // 'password' | 'otp'
  const [form, setForm] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // OTP state
  const [otpStep, setOtpStep] = useState('request'); // 'request' | 'verify'
  const [otpCode, setOtpCode] = useState('');
  const [otpDebug, setOtpDebug] = useState('');

  // One-tap demo login — authenticates against the live backend with the
  // seeded demo accounts (no OTP, no backdoor — these are real users in the
  // production DB). Lets anyone explore the admin / dealer / shopper views.
  const DEMO_ACCOUNTS = {
    user:   { email: 'shopper-1@example.com',     password: 'UserPass@2024',   dest: '/' },
    dealer: { email: 'dealer-active@example.com',  password: 'DealerPass@2024', dest: '/dealer-dashboard' },
    admin:  { email: 'admin@woodmark.local',       password: 'AdminPass@2024',  dest: '/admin-dashboard' },
  };
  const demoLogin = async (role) => {
    const acc = DEMO_ACCOUNTS[role];
    setLoading(true);
    setErrors({});
    try {
      const data = await loginUser({ email: acc.email, password: acc.password });
      login({ access: data.access, refresh: data.refresh }, data.user);
      toast.success(`Signed in as ${role}`);
      navigate(acc.dest, { replace: true });
    } catch (err) {
      toast.error(
        err.response?.data?.detail || `Demo ${role} login failed. The account may have changed.`
      );
    } finally {
      setLoading(false);
    }
  };

  // Quick test login — surface failures explicitly instead of silently
  // bouncing back to the same page (which is what happened before because
  // the .then() never ran when loginAsTestUser threw).
  const quickLogin = async (role, dest) => {
    try {
      const user = await loginAsTestUser(role);
      if (!user) {
        toast.error('Quick login disabled on this environment.');
        return;
      }
      toast.success(`Signed in as ${user.full_name || user.email}`);
      navigate(dest, { replace: true });
    } catch (err) {
      const msg =
        err.response?.status === 403
          ? 'Quick login is disabled on this backend (set ALLOW_DEV_LOGIN=true).'
          : err.response?.data?.error
          || err.response?.data?.detail
          || 'Quick login failed — see browser console for details.';
      toast.error(msg);
    }
  };

  const handleOtpRequest = async (e) => {
    e.preventDefault();
    if (!/\S+@\S+\.\S+/.test(form.email)) {
      setErrors({ email: 'Enter a valid email first.' });
      return;
    }
    setLoading(true); setErrors({});
    try {
      const data = await requestEmailOtp(form.email);
      setOtpStep('verify');
      if (data?.debug_code) setOtpDebug(data.debug_code);
      toast.success('Code sent. Check your email (or the dev console).');
    } catch {
      setErrors({ form: 'Could not send code. Try again in a moment.' });
    } finally {
      setLoading(false);
    }
  };

  const handleOtpVerify = async (e) => {
    e.preventDefault();
    if (!/^\d{6}$/.test(otpCode)) {
      setErrors({ form: 'Enter the 6-digit code.' });
      return;
    }
    setLoading(true); setErrors({});
    try {
      const data = await verifyEmailOtp(form.email, otpCode);
      login({ access: data.access, refresh: data.refresh }, data.user);
      toast.success(`Welcome back, ${data.user.full_name || data.user.email}!`);
      navigate(from, { replace: true });
    } catch (err) {
      setErrors({ form: err.response?.data?.detail || 'Invalid or expired code.' });
    } finally {
      setLoading(false);
    }
  };

  const validate = () => {
    const errs = {};
    if (!form.email) errs.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(form.email)) errs.email = 'Invalid email address';
    if (!form.password) errs.password = 'Password is required';
    return errs;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    setLoading(true);
    setErrors({});
    try {
      const data = await loginUser(form);
      login({ access: data.access, refresh: data.refresh }, data.user);
      toast.success(`Welcome back, ${data.user.full_name || data.user.email}!`);
      navigate(from, { replace: true });
    } catch (err) {
      // Backend signals "this signup never finished OTP" with a 403 +
      // requires_verification flag. Route the user to the verify page
      // instead of showing a misleading credential error.
      const body = err.response?.data || {};
      if (body.requires_verification) {
        toast(body.detail || 'Please verify your email first.');
        navigate(`/verify-email?email=${encodeURIComponent(body.email || form.email)}`);
        return;
      }
      const detail =
        body.detail ||
        body.non_field_errors?.[0] ||
        body.email?.[0];
      setErrors({
        form: detail || 'Login failed. Please check your credentials.',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = () => {
    // OAuth requires hitting the BACKEND host (Render) — not the frontend
    // host. `/api/auth/google/` on Vercel falls into the SPA catch-all and
    // returned index.html, so clicking previously showed a blank page.
    // Use VITE_API_BASE_URL so the browser navigates straight to Render.
    const base = (import.meta.env.VITE_API_BASE_URL || '/api').replace(/\/$/, '');
    window.location.href = `${base}/auth/google/`;
  };

  return (
    <div className="auth-page">
      <div className="auth-page__left">
        <img
          src="https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80"
          alt="Elegant living room with premium furniture"
          className="auth-page__bg-image"
        />
        <div className="auth-page__overlay">
          <div className="auth-page__brand">
            <h1>Woodmark</h1>
            <blockquote>"Your home, your story."</blockquote>
            <p>Premium furniture crafted for the modern Indian home.</p>
          </div>
        </div>
      </div>

      <div className="auth-page__right">
        <div className="auth-form-container">
          <div className="auth-form-header">
            <h2>Welcome Back</h2>
            <p>Sign in to your Woodmark account</p>
          </div>

          <button
            className="google-btn"
            onClick={handleGoogleLogin}
            type="button"
          >
            <FcGoogle size={20} />
            Continue with Google
          </button>

          <div className="auth-divider">
            <span>or sign in with email</span>
          </div>

          <div className="auth-mode-tabs" role="tablist">
            <button
              type="button"
              role="tab"
              aria-selected={mode === 'password'}
              className={`auth-mode-tab ${mode === 'password' ? 'auth-mode-tab--active' : ''}`}
              onClick={() => { setMode('password'); setErrors({}); }}
            >
              Password
            </button>
            <button
              type="button"
              role="tab"
              aria-selected={mode === 'otp'}
              className={`auth-mode-tab ${mode === 'otp' ? 'auth-mode-tab--active' : ''}`}
              onClick={() => { setMode('otp'); setErrors({}); setOtpStep('request'); setOtpCode(''); }}
            >
              Email OTP
            </button>
          </div>

          {errors.form && (
            <div className="auth-error-banner">{errors.form}</div>
          )}

          {mode === 'otp' ? (
            otpStep === 'request' ? (
              <form onSubmit={handleOtpRequest} className="auth-form" noValidate>
                <div className={`form-group ${errors.email ? 'form-group--error' : ''}`}>
                  <label htmlFor="otp-email">Email address</label>
                  <div className="input-wrapper">
                    <FiMail className="input-icon" />
                    <input
                      id="otp-email" type="email" autoComplete="email"
                      value={form.email}
                      onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
                      placeholder="you@example.com"
                    />
                  </div>
                  {errors.email && <span className="form-error">{errors.email}</span>}
                </div>
                <button type="submit" className="btn-primary auth-submit" disabled={loading}>
                  {loading ? 'Sending…' : 'Send 6-digit code'}
                </button>
              </form>
            ) : (
              <form onSubmit={handleOtpVerify} className="auth-form" noValidate>
                <p style={{ fontSize: 14, color: '#6B7280' }}>
                  Code sent to <strong>{form.email}</strong>. Expires in 10 minutes.
                </p>
                {otpDebug && (
                  <div className="auth-error-banner" style={{ background: '#FEF3C7', color: '#92400E', borderColor: '#FDE68A' }}>
                    DEV code: <strong>{otpDebug}</strong>
                  </div>
                )}
                <div className="form-group">
                  <label htmlFor="otp-code">6-digit code</label>
                  <div className="input-wrapper">
                    <FiKey className="input-icon" />
                    <input
                      id="otp-code"
                      type="text" inputMode="numeric" pattern="\d{6}" maxLength={6}
                      autoComplete="one-time-code"
                      value={otpCode}
                      onChange={(e) => setOtpCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                      placeholder="••••••"
                      style={{ letterSpacing: '0.4em', textAlign: 'center', fontSize: 18 }}
                    />
                  </div>
                </div>
                <button type="submit" className="btn-primary auth-submit" disabled={loading}>
                  {loading ? 'Verifying…' : 'Verify & sign in'}
                </button>
                <button type="button" className="auth-forgot-link"
                  onClick={() => { setOtpStep('request'); setOtpCode(''); setOtpDebug(''); }}
                  style={{ background: 'none', border: 0, padding: 0, cursor: 'pointer' }}>
                  ← Use a different email
                </button>
              </form>
            )
          ) : (
          <form onSubmit={handleSubmit} className="auth-form" noValidate>
            <div
              className={`form-group ${errors.email ? 'form-group--error' : ''}`}
            >
              <label htmlFor="email">Email address</label>
              <div className="input-wrapper">
                <FiMail className="input-icon" />
                <input
                  id="email"
                  type="email"
                  autoComplete="email"
                  value={form.email}
                  onChange={(e) =>
                    setForm((f) => ({ ...f, email: e.target.value }))
                  }
                  placeholder="you@example.com"
                />
              </div>
              {errors.email && <span className="form-error">{errors.email}</span>}
            </div>

            <div
              className={`form-group ${errors.password ? 'form-group--error' : ''}`}
            >
              <label htmlFor="password">Password</label>
              <div className="input-wrapper">
                <FiLock className="input-icon" />
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  value={form.password}
                  onChange={(e) =>
                    setForm((f) => ({ ...f, password: e.target.value }))
                  }
                  placeholder="Your password"
                />
                <button
                  type="button"
                  className="input-toggle"
                  onClick={() => setShowPassword((s) => !s)}
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <FiEyeOff /> : <FiEye />}
                </button>
              </div>
              {errors.password && (
                <span className="form-error">{errors.password}</span>
              )}
              <Link to="/forgot-password" className="auth-forgot-link">
                Forgot password?
              </Link>
            </div>

            <button
              type="submit"
              className="btn-primary auth-submit"
              disabled={loading}
            >
              {loading ? 'Signing in…' : 'Sign In'}
            </button>
          </form>
          )}

          <p className="auth-switch">
            Don't have an account? <Link to="/signup">Sign up →</Link>
          </p>
          <p className="auth-switch">
            Business buyer? <Link to="/dealer-apply">Apply as Dealer →</Link>
          </p>

          {/* Demo access — one-tap login as each role against the live
              backend. Always visible (this is a public demo). */}
          <div className="dev-quick-login">
            <div className="dev-quick-login__label">Explore the demo — one-tap login</div>
            <div className="dev-quick-login__buttons">
              <button type="button" onClick={() => demoLogin('user')} disabled={loading}>
                As Shopper
              </button>
              <button type="button" onClick={() => demoLogin('dealer')} disabled={loading}>
                As Dealer
              </button>
              <button type="button" onClick={() => demoLogin('admin')} disabled={loading}>
                As Admin
              </button>
            </div>
            <p className="dev-quick-login__note">
              Signs in as a real demo account — full admin / dealer / shopper access.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
