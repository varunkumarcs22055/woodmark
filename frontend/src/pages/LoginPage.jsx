/**
 * LoginPage — split-layout sign-in form with Google OAuth.
 * After successful login, redirects to the page the user came from
 * (read from location.state.from), or to "/" by default.
 */
import { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { FiMail, FiLock, FiEye, FiEyeOff } from 'react-icons/fi';
import { FcGoogle } from 'react-icons/fc';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';
import { loginUser } from '../api';
import './LoginPage.css';

export default function LoginPage() {
  const { login, loginAsTestUser } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const from = location.state?.from?.pathname || '/';

  const [form, setForm] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

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
      const detail =
        err.response?.data?.detail ||
        err.response?.data?.non_field_errors?.[0] ||
        err.response?.data?.email?.[0];
      setErrors({
        form: detail || 'Login failed. Please check your credentials.',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = () => {
    window.location.href = '/api/auth/google/';
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
            <h1>FurniShop</h1>
            <blockquote>"Your home, your story."</blockquote>
            <p>Premium furniture crafted for the modern Indian home.</p>
          </div>
        </div>
      </div>

      <div className="auth-page__right">
        <div className="auth-form-container">
          <div className="auth-form-header">
            <h2>Welcome Back</h2>
            <p>Sign in to your FurniShop account</p>
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

          {errors.form && (
            <div className="auth-error-banner">{errors.form}</div>
          )}

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
            </div>

            <button
              type="submit"
              className="btn-primary auth-submit"
              disabled={loading}
            >
              {loading ? 'Signing in…' : 'Sign In'}
            </button>
          </form>

          <p className="auth-switch">
            Don't have an account? <Link to="/signup">Sign up →</Link>
          </p>
          <p className="auth-switch">
            Business buyer? <Link to="/dealer-apply">Apply as Dealer →</Link>
          </p>

          {/* DEV-ONLY: instant role-based test login. Hidden in production builds. */}
          {import.meta.env.DEV && (
            <div className="dev-quick-login">
              <div className="dev-quick-login__label">Dev Quick Login</div>
              <div className="dev-quick-login__buttons">
                <button
                  type="button"
                  onClick={() => { loginAsTestUser('user'); navigate('/'); }}
                >
                  As User
                </button>
                <button
                  type="button"
                  onClick={() => { loginAsTestUser('dealer'); navigate('/dealer-dashboard'); }}
                >
                  As Dealer
                </button>
                <button
                  type="button"
                  onClick={() => { loginAsTestUser('admin'); navigate('/admin-dashboard'); }}
                >
                  As Admin
                </button>
              </div>
              <p className="dev-quick-login__note">
                Bypasses backend — preview role-gated screens locally.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
