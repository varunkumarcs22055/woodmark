/**
 * Global Error Boundary.
 *
 * Wraps the whole app in App.jsx. Catches any render-time crash from any
 * descendant and renders a friendly fallback instead of a blank screen.
 * In DEV the stack trace is shown to speed up debugging; in production
 * we display a generic message + a "Reload" button.
 *
 * Note: error boundaries do NOT catch errors in event handlers, async
 * code (promises, setTimeout), or server-side rendering. Those bubble
 * to window.onerror; we still attach a listener for telemetry.
 */
import { Component } from 'react';
import { FiAlertTriangle, FiRefreshCw } from 'react-icons/fi';

export default class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { error: null, info: null };
  }

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidCatch(error, info) {
    // eslint-disable-next-line no-console
    console.error('[ErrorBoundary] React render crash:', error, info);
    this.setState({ info });
  }

  handleReload = () => {
    this.setState({ error: null, info: null });
    window.location.reload();
  };

  render() {
    if (!this.state.error) return this.props.children;
    const isDev = import.meta.env.DEV;
    return (
      <div role="alert" style={shellStyle}>
        <div style={cardStyle}>
          <FiAlertTriangle size={42} style={{ color: '#DC2626', marginBottom: 8 }} />
          <h1 style={titleStyle}>Something went wrong</h1>
          <p style={pStyle}>
            We've logged the error and our team will investigate. Try
            reloading the page — most issues clear on a fresh request.
          </p>
          <button onClick={this.handleReload} style={btnStyle}>
            <FiRefreshCw size={14} /> Reload page
          </button>
          {isDev && (
            <details style={{ marginTop: 20, textAlign: 'left' }}>
              <summary style={{ cursor: 'pointer', fontWeight: 600 }}>
                Dev details
              </summary>
              <pre style={preStyle}>{String(this.state.error?.stack || this.state.error)}</pre>
              {this.state.info?.componentStack && (
                <pre style={preStyle}>{this.state.info.componentStack}</pre>
              )}
            </details>
          )}
        </div>
      </div>
    );
  }
}

const shellStyle = {
  minHeight: '60vh',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  padding: 24,
  background: '#FAFAF7',
};
const cardStyle = {
  background: '#fff',
  border: '1px solid #E5E7EB',
  borderRadius: 14,
  padding: '32px 28px',
  maxWidth: 520,
  width: '100%',
  textAlign: 'center',
  boxShadow: '0 12px 28px -16px rgba(17,24,39,0.18)',
};
const titleStyle = { margin: '6px 0 8px', color: '#111827', fontSize: '1.4rem' };
const pStyle = { color: '#6B7280', fontSize: 14, lineHeight: 1.55, margin: '0 0 18px' };
const btnStyle = {
  display: 'inline-flex', alignItems: 'center', gap: 6,
  padding: '9px 18px', background: '#1E3A6B', color: '#fff',
  border: 0, borderRadius: 8, cursor: 'pointer', fontWeight: 600, fontSize: 13.5,
};
const preStyle = {
  fontSize: 11.5, color: '#374151', background: '#F9FAFB',
  padding: 10, borderRadius: 8, overflow: 'auto', maxHeight: 200,
};
