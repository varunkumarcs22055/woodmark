/**
 * SignupPage — split-layout registration with password strength indicator.
 * On success, the user is auto-logged-in (backend returns access+refresh).
 */
import { useState, useMemo } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { FiUser, FiMail, FiPhone, FiLock, FiEye, FiEyeOff } from 'react-icons/fi';
import { FcGoogle } from 'react-icons/fc';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';
import { registerUser } from '../api';
import './LoginPage.css';

/**
 * Password strength score (0–4):
 *   0 = empty
 *   1 = < 8 chars (weak)
 *   2 = 8+ chars (fair)
 *   3 = 8+ chars + has number OR symbol (good)
 *   4 = 8+ chars + mixed case + number + symbol (strong)
 */
function passwordStrength(pw) {
  if (!pw) return 0;
  if (pw.length < 8) return 1;
  const hasLower = /[a-z]/.test(pw);
  const hasUpper = /[A-Z]/.test(pw);
  const hasDigit = /\d/.test(pw);
  const hasSymbol = /[^A-Za-z0-9]/.test(pw);
  const variety = hasLower + hasUpper + hasDigit + hasSymbol;
  if (variety >= 4) return 4;
  if (variety >= 3) return 3;
  return 2;
}

const STRENGTH_LABELS = ['', 'Weak', 'Fair', 'Good', 'Strong'];
const STRENGTH_CLASSES = ['', 'weak', 'fair', 'good', 'strong'];

export default function SignupPage() {
  const { login } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    password: '',
    confirm_password: '',
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const strength = useMemo(() => passwordStrength(form.password), [form.password]);

  const validate = () => {
    const errs = {};
    if (!form.full_name.trim()) errs.full_name = 'Full name is required';
    if (!form.email) errs.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(form.email)) errs.email = 'Invalid email address';
    if (form.phone && !/^\d{10}$/.test(form.phone))
      errs.phone = 'Enter a valid 10-digit phone number';
    if (!form.password) errs.password = 'Password is required';
    else if (form.password.length < 8)
      errs.password = 'Password must be at least 8 characters';
    if (form.password !== form.confirm_password)
      errs.confirm_password = 'Passwords do not match';
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
      const data = await registerUser(form);
      // RegisterView now creates the user as inactive and emails an OTP.
      // We MUST send the user to the verify-email page; only after they
      // enter the OTP does the backend issue tokens.
      if (data.requires_verification) {
        toast.success('Check your email for a 6-digit code.');
        navigate(`/verify-email?email=${encodeURIComponent(data.email || form.email)}`);
        return;
      }
      // Legacy fallback — backend issued tokens directly (older builds).
      login({ access: data.access, refresh: data.refresh }, data.user);
      toast.success('Account created! Welcome to FurnoTech.');
      navigate('/');
    } catch (err) {
      const serverErrors = err.response?.data || {};
      // Each field maps to an array of strings — pick the first one
      const fieldErrors = {};
      Object.keys(serverErrors).forEach((k) => {
        const v = serverErrors[k];
        fieldErrors[k] = Array.isArray(v) ? v[0] : String(v);
      });
      setErrors(fieldErrors.detail ? { form: fieldErrors.detail } : fieldErrors);
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = () => {
    // Navigate to the backend host (Render) so the OAuth redirect actually
    // starts. The SPA catch-all on Vercel was eating /api/auth/google/ and
    // showing a blank page.
    const base = (import.meta.env.VITE_API_BASE_URL || '/api').replace(/\/$/, '');
    window.location.href = `${base}/auth/google/`;
  };

  return (
    <div className="auth-page">
      <div className="auth-page__left">
        <img
          src="https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&q=80"
          alt="Beautifully designed bedroom"
          className="auth-page__bg-image"
        />
        <div className="auth-page__overlay">
          <div className="auth-page__brand">
            <h1>Join FurnoTech</h1>
            <blockquote>"Designed for the modern Indian home."</blockquote>
            <p>Free shipping on orders above ₹2,999 · 30-day easy returns.</p>
          </div>
        </div>
      </div>

      <div className="auth-page__right">
        <div className="auth-form-container">
          <div className="auth-form-header">
            <h2>Create Your Account</h2>
            <p>Start shopping premium furniture in seconds</p>
          </div>

          <button className="google-btn" onClick={handleGoogleLogin} type="button">
            <FcGoogle size={20} />
            Sign up with Google
          </button>

          <div className="auth-divider">
            <span>or sign up with email</span>
          </div>

          {errors.form && <div className="auth-error-banner">{errors.form}</div>}

          <form onSubmit={handleSubmit} className="auth-form" noValidate>
            <div className={`form-group ${errors.full_name ? 'form-group--error' : ''}`}>
              <label htmlFor="full_name">Full name</label>
              <div className="input-wrapper">
                <FiUser className="input-icon" />
                <input
                  id="full_name"
                  type="text"
                  autoComplete="name"
                  value={form.full_name}
                  onChange={(e) => setForm((f) => ({ ...f, full_name: e.target.value }))}
                  placeholder="Your name"
                />
              </div>
              {errors.full_name && <span className="form-error">{errors.full_name}</span>}
            </div>

            <div className={`form-group ${errors.email ? 'form-group--error' : ''}`}>
              <label htmlFor="email">Email address</label>
              <div className="input-wrapper">
                <FiMail className="input-icon" />
                <input
                  id="email"
                  type="email"
                  autoComplete="email"
                  value={form.email}
                  onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
                  placeholder="you@example.com"
                />
              </div>
              {errors.email && <span className="form-error">{errors.email}</span>}
            </div>

            <div className={`form-group ${errors.phone ? 'form-group--error' : ''}`}>
              <label htmlFor="phone">Phone (optional)</label>
              <div className="input-wrapper">
                <FiPhone className="input-icon" />
                <input
                  id="phone"
                  type="tel"
                  autoComplete="tel"
                  value={form.phone}
                  onChange={(e) => setForm((f) => ({ ...f, phone: e.target.value }))}
                  placeholder="10-digit mobile number"
                  maxLength={10}
                />
              </div>
              {errors.phone && <span className="form-error">{errors.phone}</span>}
            </div>

            <div className={`form-group ${errors.password ? 'form-group--error' : ''}`}>
              <label htmlFor="password">Password</label>
              <div className="input-wrapper">
                <FiLock className="input-icon" />
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="new-password"
                  value={form.password}
                  onChange={(e) => setForm((f) => ({ ...f, password: e.target.value }))}
                  placeholder="At least 8 characters"
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

              {form.password && (
                <>
                  <div className="password-strength">
                    {[1, 2, 3, 4].map((i) => (
                      <div
                        key={i}
                        className={`password-strength__bar ${
                          strength >= i
                            ? `password-strength__bar--${STRENGTH_CLASSES[strength]}`
                            : ''
                        }`}
                      />
                    ))}
                  </div>
                  <span
                    className="password-strength__label"
                    style={{
                      color:
                        strength >= 4
                          ? 'var(--color-success)'
                          : strength >= 3
                            ? '#B58900'
                            : strength >= 2
                              ? 'var(--color-warning)'
                              : 'var(--color-error)',
                    }}
                  >
                    {STRENGTH_LABELS[strength]}
                  </span>
                </>
              )}

              {errors.password && <span className="form-error">{errors.password}</span>}
            </div>

            <div
              className={`form-group ${errors.confirm_password ? 'form-group--error' : ''}`}
            >
              <label htmlFor="confirm_password">Confirm password</label>
              <div className="input-wrapper">
                <FiLock className="input-icon" />
                <input
                  id="confirm_password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="new-password"
                  value={form.confirm_password}
                  onChange={(e) =>
                    setForm((f) => ({ ...f, confirm_password: e.target.value }))
                  }
                  placeholder="Re-enter your password"
                />
              </div>
              {errors.confirm_password && (
                <span className="form-error">{errors.confirm_password}</span>
              )}
            </div>

            <button
              type="submit"
              className="btn-primary auth-submit"
              disabled={loading}
            >
              {loading ? 'Creating account…' : 'Create Account'}
            </button>
          </form>

          <p className="auth-switch">
            Already have an account? <Link to="/login">Sign in →</Link>
          </p>
          <p className="auth-switch">
            Business buyer? <Link to="/dealer-apply">Apply as Dealer →</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
