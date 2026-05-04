/**
 * Placeholder pages — overwritten by later prompts.
 *   LoginPage, SignupPage, AuthCallbackPage, DealerApplyPage  → Frontend Prompt 4
 *   AdminDashboard                                            → Frontend Prompt 6
 *   DealerDashboard                                           → Frontend Prompt 7
 */

import { Link } from 'react-router-dom';

function StubPage({ title, prompt }) {
  return (
    <div className="page" style={{ maxWidth: 600, margin: '4rem auto', padding: '2rem' }}>
      <div
        style={{
          background: 'var(--color-surface)',
          borderRadius: 'var(--radius-lg)',
          padding: '2.5rem',
          textAlign: 'center',
          boxShadow: 'var(--shadow-md)',
        }}
      >
        <h1 style={{ fontFamily: 'var(--font-heading)', marginBottom: '0.5rem' }}>{title}</h1>
        <p style={{ color: 'var(--color-text-muted)', marginBottom: '1.5rem' }}>
          Coming soon — implemented in Frontend Prompt {prompt}.
        </p>
        <Link to="/" className="btn-primary">Back to Home</Link>
      </div>
    </div>
  );
}

export const LoginPage = () => <StubPage title="Sign In" prompt={4} />;
export const SignupPage = () => <StubPage title="Create Account" prompt={4} />;
export const AuthCallbackPage = () => <StubPage title="Completing Sign-In…" prompt={4} />;
export const DealerApplyPage = () => <StubPage title="Apply to Become a Dealer" prompt={4} />;
export const DealerDashboard = () => <StubPage title="Dealer Portal" prompt={7} />;
export const AdminDashboard = () => <StubPage title="Admin Dashboard" prompt={6} />;
