/**
 * DealerApplyPage — multi-step B2B account application.
 *
 * Step 1: Account credentials (email, password, contact)
 * Step 2: Business details (company, GST, monthly volume, address)
 * Step 3: Submitted — pending admin approval (no auto-login)
 *
 * Backend creates the user with role='dealer' and dealer_status='pending'.
 * The dealer waits for admin approval before they can sign in to the portal.
 */
import { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  FiUser, FiMail, FiPhone, FiLock, FiHome, FiBriefcase,
  FiCheckCircle, FiArrowRight, FiArrowLeft, FiEye, FiEyeOff,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import { applyForDealer } from '../api';
import './LoginPage.css';
import './DealerApplyPage.css';

const VOLUME_OPTIONS = [
  '< ₹50,000',
  '₹50,000 – ₹2,00,000',
  '₹2,00,000 – ₹10,00,000',
  '₹10,00,000+',
];

export default function DealerApplyPage() {
  const [step, setStep] = useState(1);
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [showPassword, setShowPassword] = useState(false);

  const [form, setForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    password: '',
    confirm_password: '',
    dealer_company_name: '',
    dealer_gst_number: '',
    monthly_volume: '',
    business_address: '',
  });

  const update = (key) => (e) =>
    setForm((f) => ({ ...f, [key]: e.target.value }));

  const validateStep1 = () => {
    const errs = {};
    if (!form.full_name.trim()) errs.full_name = 'Full name is required';
    if (!form.email) errs.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(form.email)) errs.email = 'Invalid email address';
    if (!form.phone) errs.phone = 'Phone number is required';
    else if (!/^\d{10}$/.test(form.phone))
      errs.phone = 'Enter a valid 10-digit number';
    if (!form.password) errs.password = 'Password is required';
    else if (form.password.length < 8)
      errs.password = 'Password must be at least 8 characters';
    if (form.password !== form.confirm_password)
      errs.confirm_password = 'Passwords do not match';
    return errs;
  };

  const validateStep2 = () => {
    const errs = {};
    if (!form.dealer_company_name.trim())
      errs.dealer_company_name = 'Company name is required';
    // Indian GSTIN structure: 2-digit state + 10-char PAN + entity digit + Z + checksum.
    if (form.dealer_gst_number &&
        !/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/.test(form.dealer_gst_number))
      errs.dealer_gst_number = 'Invalid GSTIN. Format: 22AAAAA0000A1Z5';
    if (!form.monthly_volume)
      errs.monthly_volume = 'Please pick an expected volume range';
    if (!form.business_address.trim() || form.business_address.trim().length < 20)
      errs.business_address = 'Provide a complete business address (min 20 chars)';
    return errs;
  };

  const handleNext = () => {
    const errs = validateStep1();
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    setErrors({});
    setStep(2);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleBack = () => {
    setErrors({});
    setStep(1);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errs = validateStep2();
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    setLoading(true);
    setErrors({});
    try {
      await applyForDealer(form);
      setSubmitted(true);
      toast.success('Application submitted!');
    } catch (err) {
      const serverErrors = err.response?.data || {};
      const fieldErrors = {};
      Object.keys(serverErrors).forEach((k) => {
        const v = serverErrors[k];
        fieldErrors[k] = Array.isArray(v) ? v[0] : String(v);
      });
      if (fieldErrors.detail) {
        setErrors({ form: fieldErrors.detail });
      } else {
        setErrors(fieldErrors);
        // If error was in step 1 fields, jump back so user can fix
        if (
          fieldErrors.email || fieldErrors.password ||
          fieldErrors.phone || fieldErrors.full_name
        ) {
          setStep(1);
        }
      }
      toast.error('Could not submit application. Please review and retry.');
    } finally {
      setLoading(false);
    }
  };

  // ─── Success state ────────────────────────────────────────────────
  if (submitted) {
    return (
      <div className="dealer-apply">
        <div className="dealer-apply__success">
          <FiCheckCircle size={72} className="dealer-apply__success-icon" />
          <h2>Application Submitted!</h2>
          <p>
            Your dealer application has been received. Our team will review it and
            get back to you at <strong>{form.email}</strong> within 2–3 business days.
          </p>
          <p className="dealer-apply__note">
            Once approved, you'll gain access to exclusive dealer pricing, bulk
            purchase benefits, and the dealer portal.
          </p>
          <div className="dealer-apply__actions">
            <Link to="/" className="btn-primary">
              Continue Browsing
            </Link>
            <Link to="/login" className="btn-outline">
              Back to Sign In
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // ─── Form ─────────────────────────────────────────────────────────
  return (
    <div className="dealer-apply">
      <div className="dealer-apply__container">
        <div className="dealer-apply__header">
          <h1>Become a Dealer</h1>
          <p>
            Join Woodmark's B2B network. Get exclusive trade pricing and bulk
            purchase benefits for your business.
          </p>
        </div>

        {/* Step indicator */}
        <div className="dealer-apply__steps">
          <div className={`dealer-apply__step ${step >= 1 ? 'active' : ''}`}>
            <span className="dealer-apply__step-num">1</span>
            <span className="dealer-apply__step-label">Account</span>
          </div>
          <div className="dealer-apply__step-line" />
          <div className={`dealer-apply__step ${step >= 2 ? 'active' : ''}`}>
            <span className="dealer-apply__step-num">2</span>
            <span className="dealer-apply__step-label">Business</span>
          </div>
        </div>

        {errors.form && <div className="auth-error-banner">{errors.form}</div>}

        <form className="auth-form" onSubmit={handleSubmit} noValidate>
          {step === 1 && (
            <>
              <div className={`form-group ${errors.full_name ? 'form-group--error' : ''}`}>
                <label htmlFor="full_name">Full name</label>
                <div className="input-wrapper">
                  <FiUser className="input-icon" />
                  <input
                    id="full_name"
                    type="text"
                    value={form.full_name}
                    onChange={update('full_name')}
                    placeholder="Your name"
                  />
                </div>
                {errors.full_name && <span className="form-error">{errors.full_name}</span>}
              </div>

              <div className={`form-group ${errors.email ? 'form-group--error' : ''}`}>
                <label htmlFor="email">Business email</label>
                <div className="input-wrapper">
                  <FiMail className="input-icon" />
                  <input
                    id="email"
                    type="email"
                    value={form.email}
                    onChange={update('email')}
                    placeholder="contact@yourcompany.com"
                  />
                </div>
                {errors.email && <span className="form-error">{errors.email}</span>}
              </div>

              <div className={`form-group ${errors.phone ? 'form-group--error' : ''}`}>
                <label htmlFor="phone">Phone</label>
                <div className="input-wrapper">
                  <FiPhone className="input-icon" />
                  <input
                    id="phone"
                    type="tel"
                    value={form.phone}
                    onChange={update('phone')}
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
                    value={form.password}
                    onChange={update('password')}
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
                    value={form.confirm_password}
                    onChange={update('confirm_password')}
                    placeholder="Re-enter your password"
                  />
                </div>
                {errors.confirm_password && (
                  <span className="form-error">{errors.confirm_password}</span>
                )}
              </div>

              <button
                type="button"
                className="btn-primary auth-submit"
                onClick={handleNext}
              >
                Continue to Business Details <FiArrowRight size={16} />
              </button>
            </>
          )}

          {step === 2 && (
            <>
              <div
                className={`form-group ${errors.dealer_company_name ? 'form-group--error' : ''}`}
              >
                <label htmlFor="dealer_company_name">Company name</label>
                <div className="input-wrapper">
                  <FiBriefcase className="input-icon" />
                  <input
                    id="dealer_company_name"
                    type="text"
                    value={form.dealer_company_name}
                    onChange={update('dealer_company_name')}
                    placeholder="Your registered business name"
                  />
                </div>
                {errors.dealer_company_name && (
                  <span className="form-error">{errors.dealer_company_name}</span>
                )}
              </div>

              <div
                className={`form-group ${errors.dealer_gst_number ? 'form-group--error' : ''}`}
              >
                <label htmlFor="dealer_gst_number">GST number (optional)</label>
                <div className="input-wrapper">
                  <FiBriefcase className="input-icon" />
                  <input
                    id="dealer_gst_number"
                    type="text"
                    value={form.dealer_gst_number}
                    onChange={(e) =>
                      setForm((f) => ({
                        ...f,
                        dealer_gst_number: e.target.value.toUpperCase(),
                      }))
                    }
                    placeholder="15-character GSTIN"
                    maxLength={15}
                  />
                </div>
                {errors.dealer_gst_number && (
                  <span className="form-error">{errors.dealer_gst_number}</span>
                )}
              </div>

              <div
                className={`form-group ${errors.monthly_volume ? 'form-group--error' : ''}`}
              >
                <label htmlFor="monthly_volume">Expected monthly purchase volume</label>
                <select
                  id="monthly_volume"
                  className="form-input"
                  value={form.monthly_volume}
                  onChange={update('monthly_volume')}
                >
                  <option value="">Select a range…</option>
                  {VOLUME_OPTIONS.map((v) => (
                    <option key={v} value={v}>
                      {v}
                    </option>
                  ))}
                </select>
                {errors.monthly_volume && (
                  <span className="form-error">{errors.monthly_volume}</span>
                )}
              </div>

              <div
                className={`form-group ${errors.business_address ? 'form-group--error' : ''}`}
              >
                <label htmlFor="business_address">Business address</label>
                <div className="input-wrapper">
                  <FiHome className="input-icon" />
                  <textarea
                    id="business_address"
                    rows={3}
                    value={form.business_address}
                    onChange={update('business_address')}
                    placeholder="Building, street, city, state, PIN code"
                    style={{
                      paddingLeft: '40px',
                      width: '100%',
                      border: '1.5px solid var(--color-border)',
                      borderRadius: 'var(--radius-md)',
                      padding: '12px 12px 12px 40px',
                      fontFamily: 'inherit',
                      fontSize: 'var(--text-base)',
                      resize: 'vertical',
                    }}
                  />
                </div>
                {errors.business_address && (
                  <span className="form-error">{errors.business_address}</span>
                )}
              </div>

              <div className="dealer-apply__actions-row">
                <button
                  type="button"
                  className="btn-outline"
                  onClick={handleBack}
                >
                  <FiArrowLeft size={16} /> Back
                </button>
                <button
                  type="submit"
                  className="btn-primary auth-submit"
                  style={{ flex: 1, marginTop: 0 }}
                  disabled={loading}
                >
                  {loading ? 'Submitting…' : 'Submit Application'}
                </button>
              </div>
            </>
          )}
        </form>

        <p className="auth-switch">
          Already a customer? <Link to="/login">Sign in →</Link>
        </p>
      </div>
    </div>
  );
}
