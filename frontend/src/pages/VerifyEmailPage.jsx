/**
 * VerifyEmailPage — landing after signup until the user enters the 6-digit
 * OTP we mailed them. Successful verification activates the account and
 * issues JWT tokens.
 *
 * Why this page exists: RegisterView creates the user with is_active=False
 * + sends an OTP via Brevo. The frontend used to call login() with the
 * tokens that the OLD register endpoint returned, which bypassed the
 * verification step entirely. This page closes that gap.
 */
import { useEffect, useRef, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { FiMail, FiKey, FiRefreshCw } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';
import { verifySignupEmail, resendSignupOtp } from '../api';
import './LoginPage.css';

export default function VerifyEmailPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { login } = useAuth();
  const initialEmail = searchParams.get('email') || '';
  const [email, setEmail] = useState(initialEmail);
  const [otp, setOtp] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [resending, setResending] = useState(false);
  // Cooldown so admins can't spam the resend button.
  const [cooldown, setCooldown] = useState(0);
  const otpInputRef = useRef(null);

  useEffect(() => {
    if (otpInputRef.current) otpInputRef.current.focus();
  }, []);

  useEffect(() => {
    if (cooldown <= 0) return;
    const t = setTimeout(() => setCooldown((s) => s - 1), 1000);
    return () => clearTimeout(t);
  }, [cooldown]);

  const handleVerify = async (e) => {
    e.preventDefault();
    if (submitting) return;
    if (!/^\d{6}$/.test(otp)) {
      toast.error('Please enter the 6-digit code from your email.');
      return;
    }
    setSubmitting(true);
    try {
      const data = await verifySignupEmail(email, otp);
      // Backend returned tokens — log the user in for real this time.
      login({ access: data.access, refresh: data.refresh }, data.user);
      toast.success('Email verified! Welcome to FurniShop.');
      navigate('/');
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Invalid or expired code.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleResend = async () => {
    if (resending || cooldown > 0 || !email) return;
    setResending(true);
    try {
      await resendSignupOtp(email);
      toast.success('A new code has been sent.');
      setCooldown(60);
    } catch {
      toast.error('Could not resend code. Please try again in a moment.');
    } finally {
      setResending(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-page__left">
        <img
          src="https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&q=80"
          alt="FurniShop"
          className="auth-page__bg-image"
        />
        <div className="auth-page__overlay">
          <div className="auth-page__brand">
            <h1>Almost there</h1>
            <blockquote>"One quick step to keep your account safe."</blockquote>
            <p>We sent a 6-digit code to your inbox.</p>
          </div>
        </div>
      </div>

      <div className="auth-page__right">
        <div className="auth-form-container">
          <div className="auth-form-header">
            <h2>Verify your email</h2>
            <p>
              Enter the 6-digit code we sent to{' '}
              <strong>{email || 'your email'}</strong>.
            </p>
          </div>

          <form onSubmit={handleVerify} className="auth-form" noValidate>
            <div className="form-group">
              <label htmlFor="email">Email</label>
              <div className="input-wrapper">
                <FiMail className="input-icon" />
                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="you@example.com"
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="otp">6-digit code</label>
              <div className="input-wrapper">
                <FiKey className="input-icon" />
                <input
                  id="otp"
                  ref={otpInputRef}
                  type="text"
                  inputMode="numeric"
                  maxLength={6}
                  pattern="\d{6}"
                  value={otp}
                  onChange={(e) =>
                    setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))
                  }
                  placeholder="123456"
                  style={{
                    letterSpacing: '0.4em',
                    fontSize: '1.25rem',
                    fontWeight: 700,
                    textAlign: 'center',
                  }}
                  required
                />
              </div>
            </div>

            <button
              type="submit"
              className="btn-primary auth-submit"
              disabled={submitting || otp.length !== 6}
            >
              {submitting ? 'Verifying…' : 'Verify & Sign in'}
            </button>
          </form>

          <button
            type="button"
            onClick={handleResend}
            disabled={resending || cooldown > 0}
            className="auth-switch"
            style={{
              background: 'none',
              border: 'none',
              cursor: cooldown > 0 ? 'not-allowed' : 'pointer',
              color: cooldown > 0 ? 'var(--color-text-muted)' : 'var(--color-brand)',
              display: 'inline-flex',
              alignItems: 'center',
              gap: 6,
              fontWeight: 600,
              padding: 0,
              margin: '14px 0 0',
              fontFamily: 'inherit',
              fontSize: 'inherit',
            }}
          >
            <FiRefreshCw size={13} />
            {cooldown > 0
              ? `Resend code (${cooldown}s)`
              : resending
                ? 'Sending…'
                : 'Resend code'}
          </button>

          <p className="auth-switch">
            Already verified? <Link to="/login">Sign in →</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
