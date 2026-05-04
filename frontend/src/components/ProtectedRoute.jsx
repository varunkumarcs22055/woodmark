/**
 * Route guards.
 *   ProtectedRoute  — requires authentication.
 *   RoleRoute       — requires authentication AND a specific role.
 *
 * Both honor the `loading` state so guards don't bounce users to /login while
 * the AuthContext is still restoring a session from the refresh token.
 */

import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

function LoadingScreen() {
  return (
    <div
      style={{
        minHeight: '60vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'var(--color-text-muted)',
        fontSize: 'var(--text-sm)',
        letterSpacing: '0.05em',
        textTransform: 'uppercase',
      }}
    >
      Loading…
    </div>
  );
}

export function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <LoadingScreen />;
  if (!user) return <Navigate to="/login" state={{ from: location }} replace />;
  return children;
}

export function RoleRoute({ children, allowedRoles }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <LoadingScreen />;
  if (!user) return <Navigate to="/login" state={{ from: location }} replace />;
  if (!allowedRoles.includes(user.role)) return <Navigate to="/" replace />;
  return children;
}

export default ProtectedRoute;
