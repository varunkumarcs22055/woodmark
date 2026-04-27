/**
 * Footer — Livspace-style footer with full column layout.
 */

import { Link } from 'react-router-dom';
import { FiFacebook, FiInstagram, FiTwitter, FiYoutube } from 'react-icons/fi';
import './Footer.css';

const FOOTER_LINKS = [
  {
    heading: 'Shop',
    links: [
      { label: 'Bed Linen', to: '/?category=Beds' },
      { label: 'Bath Linen', to: '/?category=Bath' },
      { label: 'Furniture', to: '/?category=Sofas' },
      { label: 'Cushions & Pillows', to: '/?category=Cushions' },
      { label: 'Best Sellers', to: '/' },
    ],
  },
  {
    heading: 'Quick Links',
    links: [
      { label: 'My Orders', to: '/orders' },
      { label: 'Cart', to: '/cart' },
      { label: 'Track Order', to: '/orders' },
      { label: 'Wishlist', to: '/' },
    ],
  },
  {
    heading: 'Help & Support',
    links: [
      { label: 'FAQ', to: '/' },
      { label: 'Shipping Policy', to: '/' },
      { label: 'Return Policy', to: '/' },
      { label: 'Contact Us', to: '/' },
      { label: 'Privacy Policy', to: '/' },
    ],
  },
];

export default function Footer() {
  return (
    <footer className="footer" id="main-footer">
      {/* Top section */}
      <div className="footer-top">
        <div className="footer-inner container">
          <div className="footer-grid">
            {/* Brand column */}
            <div className="footer-brand-col">
              <Link to="/" className="footer-logo" id="footer-logo">
                <div className="footer-logo-mark">
                  <svg width="32" height="32" viewBox="0 0 28 28" fill="none">
                    <rect width="28" height="28" rx="6" fill="#00736A"/>
                    <path d="M7 20V12L14 7L21 12V20H16V15H12V20H7Z" fill="white"/>
                  </svg>
                </div>
                <span className="footer-logo-text">FurniShop</span>
              </Link>
              <p className="footer-tagline">
                Premium furniture &amp; home essentials — crafted for the Indian home. Trusted by over 1 lakh happy families.
              </p>
              <div className="footer-socials">
                <a href="#" className="social-btn" aria-label="Facebook"><FiFacebook size={18} /></a>
                <a href="#" className="social-btn" aria-label="Instagram"><FiInstagram size={18} /></a>
                <a href="#" className="social-btn" aria-label="Twitter"><FiTwitter size={18} /></a>
                <a href="#" className="social-btn" aria-label="YouTube"><FiYoutube size={18} /></a>
              </div>
              <div className="footer-contact">
                <p className="footer-contact-item">📞 1800-123-4567 (Toll Free)</p>
                <p className="footer-contact-item">✉️ hello@furnishop.in</p>
                <p className="footer-contact-item">📍 Mumbai, India</p>
              </div>
            </div>

            {/* Link columns */}
            {FOOTER_LINKS.map((col) => (
              <div className="footer-col" key={col.heading}>
                <h4 className="footer-col-heading">{col.heading}</h4>
                <ul className="footer-link-list">
                  {col.links.map((link) => (
                    <li key={link.label}>
                      <Link to={link.to} className="footer-link">
                        {link.label}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            ))}

            {/* Newsletter column */}
            <div className="footer-col">
              <h4 className="footer-col-heading">Newsletter</h4>
              <p className="footer-newsletter-desc">
                Get exclusive offers, style tips, and new arrivals directly in your inbox.
              </p>
              <form
                className="footer-newsletter-form"
                onSubmit={(e) => e.preventDefault()}
              >
                <input
                  type="email"
                  placeholder="Your email address"
                  className="footer-newsletter-input"
                  id="newsletter-email"
                />
                <button type="submit" className="footer-newsletter-btn">
                  Subscribe
                </button>
              </form>
              <p className="footer-newsletter-note">
                No spam. Unsubscribe anytime.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom bar */}
      <div className="footer-bottom">
        <div className="footer-bottom-inner container">
          <p className="footer-copyright">
            © {new Date().getFullYear()} FurniShop. All rights reserved.
          </p>
          <div className="footer-payments">
            {['Visa', 'Mastercard', 'UPI', 'PayTM', 'Net Banking'].map(p => (
              <span key={p} className="payment-badge">{p}</span>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}
