# Frontend Prompt 4 — Authentication Pages (Login, Signup, Google OAuth, Dealer Apply)

## Role
You are a senior frontend engineer. Build all authentication pages for FurniShop: Login, Signup, Google OAuth callback handler, and Dealer Application form. These pages must be beautiful, accessible, and handle all error states gracefully.

---

## Context
Authentication is the gateway to role-based features. These pages work with the JWT auth backend (Prompts 3 & 4). After login/signup, users are redirected back to where they came from. Google OAuth involves a redirect loop — `AuthCallbackPage` reads tokens from the URL and stores them. Dealer application has a richer form.

**Depends on:** Frontend Prompt 1 (AuthContext, API layer, design system)
**Backend endpoints used:**
- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `GET /api/auth/google/` → redirect
- `GET /api/auth/profile/` (after OAuth callback)
- `POST /api/auth/dealer-apply/`

---

## Files to Create

```
frontend/src/pages/
├── LoginPage.jsx
├── LoginPage.css
├── SignupPage.jsx
├── SignupPage.css
├── AuthCallbackPage.jsx
├── DealerApplyPage.jsx
└── DealerApplyPage.css
```

---

## Design Language for Auth Pages

Use Claude Design to generate mockups. The design should be:
- **Split-layout** on desktop: left side = decorative furniture image with brand quote, right side = form
- **Centered card** on mobile
- Form inputs: clean, labeled, with inline validation
- Primary action button: `var(--color-primary)` teal
- Google button: white with Google logo icon, border

```
┌─────────────────────────────────────────────────────┐
│  ╔══════════════════╗   ╔═════════════════════════╗ │
│  ║                  ║   ║  Welcome Back            ║ │
│  ║  Furniture photo ║   ║  Sign in to FurniShop    ║ │
│  ║  (left panel)    ║   ║  ─────────────────────   ║ │
│  ║                  ║   ║  [G]  Continue with      ║ │
│  ║  "Your home,     ║   ║       Google             ║ │
│  ║   your story."   ║   ║  ─────────── or ──────── ║ │
│  ║                  ║   ║  Email    [____________] ║ │
│  ╚══════════════════╝   ║  Password [____________] ║ │
│                         ║  [Forgot password?]      ║ │
│                         ║  ─────────────────────   ║ │
│                         ║  [Sign In]               ║ │
│                         ║  ─────────────────────   ║ │
│                         ║  Don't have an account?  ║ │
│                         ║  Sign up →               ║ │
│                         ╚═════════════════════════╝ │
└─────────────────────────────────────────────────────┘
```

---

## LoginPage — `src/pages/LoginPage.jsx`

```javascript
import { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { FiMail, FiLock, FiEye, FiEyeOff } from 'react-icons/fi';
import { useAuth } from '../context/AuthContext';
import { loginUser } from '../api';
import toast from 'react-hot-toast';

export default function LoginPage() {
  const { login } = useAuth();
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
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }
    setLoading(true);
    setErrors({});
    try {
      const data = await loginUser(form);
      login({ access: data.access, refresh: data.refresh }, data.user);
      toast.success(`Welcome back, ${data.user.full_name || data.user.email}!`);
      navigate(from, { replace: true });
    } catch (err) {
      const detail = err.response?.data?.detail;
      if (detail) {
        setErrors({ form: detail });
      } else {
        setErrors({ form: 'Login failed. Please check your credentials.' });
      }
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
          src="https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800"
          alt="Elegant living room"
          className="auth-page__bg-image"
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
            <h2>Welcome Back</h2>
            <p>Sign in to your FurniShop account</p>
          </div>

          {/* Google OAuth Button */}
          <button className="google-btn" onClick={handleGoogleLogin} type="button">
            <img src="/google-icon.svg" alt="Google" width={20} height={20} />
            Continue with Google
          </button>

          <div className="auth-divider"><span>or sign in with email</span></div>

          {/* Form Error Banner */}
          {errors.form && (
            <div className="auth-error-banner">{errors.form}</div>
          )}

          <form onSubmit={handleSubmit} className="auth-form" noValidate>
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

            <div className={`form-group ${errors.password ? 'form-group--error' : ''}`}>
              <label htmlFor="password">Password</label>
              <div className="input-wrapper">
                <FiLock className="input-icon" />
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  value={form.password}
                  onChange={(e) => setForm((f) => ({ ...f, password: e.target.value }))}
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
              {errors.password && <span className="form-error">{errors.password}</span>}
            </div>

            <button type="submit" className="btn-primary auth-submit" disabled={loading}>
              {loading ? 'Signing in…' : 'Sign In'}
            </button>
          </form>

          <p className="auth-switch">
            Don't have an account? <Link to="/signup">Sign up →</Link>
          </p>
          <p className="auth-switch">
            Business buyer? <Link to="/dealer-apply">Apply as Dealer →</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
```

---

## SignupPage — `src/pages/SignupPage.jsx`

Same split layout as LoginPage. Form fields:

```javascript
const [form, setForm] = useState({
  full_name: '',
  email: '',
  phone: '',
  password: '',
  confirm_password: '',
});
const [errors, setErrors] = useState({});
const [loading, setLoading] = useState(false);

const validate = () => {
  const errs = {};
  if (!form.full_name.trim()) errs.full_name = 'Full name is required';
  if (!form.email) errs.email = 'Email is required';
  else if (!/\S+@\S+\.\S+/.test(form.email)) errs.email = 'Invalid email';
  if (form.phone && !/^\d{10}$/.test(form.phone)) errs.phone = 'Enter a valid 10-digit phone number';
  if (!form.password) errs.password = 'Password is required';
  else if (form.password.length < 8) errs.password = 'Password must be at least 8 characters';
  if (form.password !== form.confirm_password) errs.confirm_password = 'Passwords do not match';
  return errs;
};

const handleSubmit = async (e) => {
  e.preventDefault();
  const errs = validate();
  if (Object.keys(errs).length > 0) { setErrors(errs); return; }
  setLoading(true);
  try {
    const data = await registerUser(form);
    login({ access: data.access, refresh: data.refresh }, data.user);
    toast.success('Account created! Welcome to FurniShop.');
    navigate('/');
  } catch (err) {
    const serverErrors = err.response?.data || {};
    setErrors(serverErrors);
  } finally {
    setLoading(false);
  }
};
```

Form fields to render: Full Name, Email, Phone (optional), Password (with show/hide toggle), Confirm Password.
Below form: "Already have an account? Sign in →"

**Password strength indicator:** Show a 4-segment bar that fills based on password strength:
- 1 segment: < 8 chars (red)
- 2 segments: 8+ chars (orange)
- 3 segments: 8+ chars + numbers or symbols (yellow)
- 4 segments: 8+ chars + mixed case + number + symbol (green)

---

## AuthCallbackPage — `src/pages/AuthCallbackPage.jsx`

This page handles the redirect from Google OAuth. The backend redirects to:
`{FRONTEND_URL}/auth-callback?access=<token>&refresh=<token>`

```javascript
import { useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import toast from 'react-hot-toast';

export default function AuthCallbackPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { loginFromTokens } = useAuth();

  useEffect(() => {
    const access = searchParams.get('access');
    const refresh = searchParams.get('refresh');

    if (!access || !refresh) {
      toast.error('Authentication failed. Please try again.');
      navigate('/login', { replace: true });
      return;
    }

    // Clean tokens from URL immediately (security best practice)
    window.history.replaceState({}, document.title, '/auth-callback');

    const authenticate = async () => {
      try {
        await loginFromTokens({ access, refresh });
        toast.success('Signed in with Google!');
        navigate('/', { replace: true });
      } catch {
        toast.error('Failed to complete sign-in. Please try again.');
        navigate('/login', { replace: true });
      }
    };

    authenticate();
  }, []);

  return (
    <div className="auth-callback">
      <div className="auth-callback__spinner" />
      <p>Completing sign-in…</p>
    </div>
  );
}
```

---

## DealerApplyPage — `src/pages/DealerApplyPage.jsx`

Multi-step form for dealer account application:

**Step 1 — Account Details:** First Name, Last Name, Email, Phone, Password, Confirm Password
**Step 2 — Business Details:** Company Name (required), GST Number (optional), Expected Monthly Volume (dropdown), Business Address

```javascript
const [step, setStep] = useState(1);
const [form, setForm] = useState({
  first_name: '', last_name: '', email: '', phone: '',
  password: '', confirm_password: '',
  dealer_company_name: '', dealer_gst_number: '',
  monthly_volume: '', business_address: '',
});
const [loading, setLoading] = useState(false);
const [submitted, setSubmitted] = useState(false);

const handleFinalSubmit = async () => {
  setLoading(true);
  try {
    await applyForDealer(form);
    setSubmitted(true);
  } catch (err) {
    const errors = err.response?.data || {};
    // Show field errors
  } finally {
    setLoading(false);
  }
};
```

**Success state** (after submission):
```jsx
{submitted && (
  <div className="dealer-apply__success">
    <div className="success-icon">✓</div>
    <h2>Application Submitted!</h2>
    <p>
      Your dealer application has been received. Our team will review it and 
      get back to you at <strong>{form.email}</strong> within 2-3 business days.
    </p>
    <p className="dealer-apply__note">
      Once approved, you'll gain access to exclusive dealer pricing and 
      bulk purchase benefits.
    </p>
    <Link to="/" className="btn-primary">Continue Shopping</Link>
  </div>
)}
```

---

## CSS — `src/pages/LoginPage.css` (shared by all auth pages)

```css
.auth-page {
  display: grid;
  grid-template-columns: 1fr 1fr;
  min-height: 100vh;
}

.auth-page__left {
  position: relative;
  overflow: hidden;
  display: none; /* hidden on mobile */
}

@media (min-width: 768px) {
  .auth-page__left { display: block; }
}

.auth-page__bg-image {
  width: 100%; height: 100%;
  object-fit: cover;
}

.auth-page__overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to bottom, rgba(0,0,0,0.3), rgba(0,0,0,0.7));
  display: flex; align-items: flex-end;
  padding: 3rem;
  color: white;
}

.auth-page__right {
  display: flex; align-items: center; justify-content: center;
  padding: 2rem;
  background: var(--color-bg);
}

.auth-form-container {
  width: 100%; max-width: 420px;
}

.auth-form-header h2 {
  font-family: var(--font-heading);
  font-size: var(--text-3xl);
  color: var(--color-text-primary);
  margin-bottom: 0.5rem;
}

.google-btn {
  width: 100%;
  display: flex; align-items: center; justify-content: center; gap: 0.75rem;
  padding: 0.75rem 1rem;
  border: 1.5px solid var(--color-border-dark);
  border-radius: var(--radius-md);
  background: white;
  font-size: var(--text-base); font-weight: 500;
  transition: background var(--transition-base), box-shadow var(--transition-base);
  margin: 1.5rem 0;
}
.google-btn:hover {
  background: #f8f9fa;
  box-shadow: var(--shadow-sm);
}

.auth-divider {
  text-align: center; color: var(--color-text-muted);
  position: relative; margin: 1.5rem 0;
}
.auth-divider::before, .auth-divider::after {
  content: ''; position: absolute; top: 50%;
  width: calc(50% - 60px); height: 1px;
  background: var(--color-border);
}
.auth-divider::before { left: 0; }
.auth-divider::after { right: 0; }

.form-group { margin-bottom: 1.25rem; }
.form-group label { display: block; margin-bottom: 0.5rem; font-weight: 500; font-size: var(--text-sm); }
.input-wrapper { position: relative; }
.input-wrapper input {
  width: 100%; padding: 0.75rem 0.75rem 0.75rem 2.5rem;
  border: 1.5px solid var(--color-border-dark);
  border-radius: var(--radius-md);
  font-size: var(--text-base);
  transition: border-color var(--transition-base);
  background: white;
}
.input-wrapper input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-primary-light);
}
.input-icon {
  position: absolute; left: 0.75rem; top: 50%;
  transform: translateY(-50%); color: var(--color-text-muted);
  pointer-events: none;
}
.form-group--error input { border-color: var(--color-error); }
.form-error { color: var(--color-error); font-size: var(--text-sm); margin-top: 0.25rem; display: block; }
.auth-error-banner {
  background: var(--color-error-bg); color: var(--color-error);
  padding: 0.75rem 1rem; border-radius: var(--radius-md);
  font-size: var(--text-sm); margin-bottom: 1rem;
}
.auth-submit { width: 100%; padding: 0.875rem; font-size: var(--text-base); margin-top: 0.5rem; }
.auth-switch { text-align: center; margin-top: 1.25rem; font-size: var(--text-sm); color: var(--color-text-secondary); }
.auth-switch a { color: var(--color-primary); font-weight: 600; }

.auth-callback {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  min-height: 60vh; gap: 1rem;
}
.auth-callback__spinner {
  width: 40px; height: 40px;
  border: 3px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
```

---

## Acceptance Criteria

**LoginPage:**
- [ ] Email + password form renders with icons
- [ ] Validation shows inline errors (empty fields, invalid email)
- [ ] Successful login stores tokens and redirects to previous page (or home)
- [ ] Wrong credentials shows error banner
- [ ] "Continue with Google" button redirects to `/api/auth/google/`
- [ ] Shows loading state during submission
- [ ] Link to `/signup` works

**SignupPage:**
- [ ] All fields validate correctly (email format, password min 8 chars, passwords match)
- [ ] Server-side errors from the API are shown per-field
- [ ] Successful registration logs user in and redirects to home
- [ ] Password strength indicator updates as user types

**AuthCallbackPage:**
- [ ] Reads `?access=` and `?refresh=` from URL on mount
- [ ] Immediately removes tokens from URL (no history entry)
- [ ] Calls `loginFromTokens`, stores session, redirects to home
- [ ] Shows loading spinner while processing

**DealerApplyPage:**
- [ ] Multi-step form (Step 1 → Step 2 → Review → Submit)
- [ ] "Next" validates the current step before advancing
- [ ] Successful submission shows success state with email confirmation
- [ ] No login issued — dealer must wait for admin approval
