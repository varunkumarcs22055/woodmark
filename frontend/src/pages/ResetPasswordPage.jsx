/**
 * ResetPasswordPage — consumes the token from ?token= in the URL.
 */
import { useState, useMemo } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { FiLock, FiEye, FiEyeOff } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { confirmPasswordReset } from '../api';
import './LoginPage.css';

export default function ResetPasswordPage() {
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const token = useMemo(() => params.get('token') || '', [params]);

  const [pw, setPw] = useState('');
  const [confirmPw, setConfirmPw] = useState('');
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!token) {
      setError('No reset token in the URL. Request a new link.');
      return;
    }
    if (pw.length < 8) {
      setError('Password must be at least 8 characters.');
      return;
    }
    if (pw !== confirmPw) {
      setError('Passwords do not match.');
      return;
    }
    setLoading(true); setError('');
    try {
      await confirmPasswordReset({ token, new_password: pw, confirm_password: confirmPw });
      toast.success('Password updated. Sign in with your new password.');
      navigate('/login', { replace: true });
    } catch (err) {
      const detail =
        err.response?.data?.detail ||
        err.response?.data?.new_password?.[0] ||
        err.response?.data?.confirm_password?.[0] ||
        'Could not reset password. The link may have expired.';
      setError(detail);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-page__left">
        <img
          src="https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80"
          alt="" className="auth-page__bg-image"
        />
        <div className="auth-page__overlay">
          <div className="auth-page__brand">
            <h1>Woodmark</h1>
            <blockquote>"Your home, your story."</blockquote>
          </div>
        </div>
      </div>

      <div className="auth-page__right">
        <div className="auth-form-container">
          <div className="auth-form-header">
            <h2>Choose a new password</h2>
            <p>Make it at least 8 characters. You'll be signed out of other sessions.</p>
          </div>

          {error && <div className="auth-error-banner">{error}</div>}

          <form onSubmit={handleSubmit} className="auth-form" noValidate>
            <div className="form-group">
              <label htmlFor="pw">New password</label>
              <div className="input-wrapper">
                <FiLock className="input-icon" />
                <input
                  id="pw"
                  type={show ? 'text' : 'password'}
                  autoComplete="new-password"
                  value={pw}
                  onChange={(e) => setPw(e.target.value)}
                  placeholder="At least 8 characters"
                />
                <button
                  type="button" className="input-toggle"
                  onClick={() => setShow((s) => !s)}
                  aria-label={show ? 'Hide password' : 'Show password'}
                >
                  {show ? <FiEyeOff /> : <FiEye />}
                </button>
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="cpw">Confirm password</label>
              <div className="input-wrapper">
                <FiLock className="input-icon" />
                <input
                  id="cpw"
                  type={show ? 'text' : 'password'}
                  autoComplete="new-password"
                  value={confirmPw}
                  onChange={(e) => setConfirmPw(e.target.value)}
                  placeholder="Repeat password"
                />
              </div>
            </div>

            <button type="submit" className="btn-primary auth-submit" disabled={loading || !token}>
              {loading ? 'Updating…' : 'Update password'}
            </button>
          </form>

          <p className="auth-switch">
            <Link to="/login">← Back to sign in</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
