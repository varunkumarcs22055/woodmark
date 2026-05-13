/**
 * ForgotPasswordPage — request a reset link by email.
 *
 * Backend always returns 200 with the same body (anti-enumeration).
 * In DEV the response includes a debug_reset_url we surface for convenience.
 */
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { FiMail } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { requestPasswordReset } from '../api';
import './LoginPage.css';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [debugUrl, setDebugUrl] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!/\S+@\S+\.\S+/.test(email)) {
      setError('Please enter a valid email address.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const data = await requestPasswordReset(email);
      setSent(true);
      if (data?.debug_reset_url) setDebugUrl(data.debug_reset_url);
      toast.success('If that email is registered, a reset link is on its way.');
    } catch {
      setError('Could not submit request. Try again in a moment.');
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
            <h1>FurniShop</h1>
            <blockquote>"Your home, your story."</blockquote>
          </div>
        </div>
      </div>

      <div className="auth-page__right">
        <div className="auth-form-container">
          <div className="auth-form-header">
            <h2>Reset your password</h2>
            <p>Enter the email tied to your account and we'll send a reset link.</p>
          </div>

          {sent ? (
            <div className="auth-form">
              <div className="auth-error-banner" style={{ background: '#ECFDF5', color: '#065F46', borderColor: '#A7F3D0' }}>
                If an account exists for <strong>{email}</strong>, a reset link has been sent.
                It expires in 1 hour.
              </div>
              {debugUrl && (
                <p style={{ fontSize: 12, color: '#6B7280', wordBreak: 'break-all' }}>
                  <strong>DEV reset URL:</strong>{' '}
                  <Link to={debugUrl.replace(/^https?:\/\/[^/]+/, '')}>
                    {debugUrl}
                  </Link>
                </p>
              )}
              <p className="auth-switch">
                <Link to="/login">← Back to sign in</Link>
              </p>
            </div>
          ) : (
            <>
              {error && <div className="auth-error-banner">{error}</div>}
              <form onSubmit={handleSubmit} className="auth-form" noValidate>
                <div className="form-group">
                  <label htmlFor="email">Email address</label>
                  <div className="input-wrapper">
                    <FiMail className="input-icon" />
                    <input
                      id="email"
                      type="email"
                      autoComplete="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="you@example.com"
                    />
                  </div>
                </div>
                <button type="submit" className="btn-primary auth-submit" disabled={loading}>
                  {loading ? 'Sending…' : 'Send reset link'}
                </button>
              </form>
              <p className="auth-switch">
                Remembered it? <Link to="/login">Back to sign in →</Link>
              </p>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
