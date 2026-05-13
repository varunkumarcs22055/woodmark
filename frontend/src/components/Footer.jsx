/**
 * Footer — Livspace-style footer with full column layout.
 */

import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { FiFacebook, FiInstagram, FiTwitter, FiYoutube } from 'react-icons/fi';
import toast from 'react-hot-toast';
import { subscribeNewsletter, fetchContentBlock } from '../api';
import './Footer.css';

const FOOTER_LINKS = [
  {
    heading: 'Shop',
    links: [
      { label: 'Sofas & Seating', to: '/?category=sofas' },
      { label: 'Tables', to: '/?category=tables' },
      { label: 'Chairs', to: '/?category=chairs' },
      { label: 'Beds', to: '/?category=beds' },
      { label: 'Storage', to: '/?category=storage' },
      { label: 'Outdoor', to: '/?category=outdoor' },
    ],
  },
  {
    heading: 'Quick Links',
    links: [
      { label: 'My Orders', to: '/orders' },
      { label: 'Cart', to: '/cart' },
      { label: 'Track Order', to: '/orders' },
      { label: 'Become a Dealer', to: '/dealer-apply' },
      { label: 'Sign In', to: '/login' },
    ],
  },
  {
    heading: 'Help & Support',
    links: [
      { label: 'FAQ', to: '/faq' },
      { label: 'Shipping Policy', to: '/shipping-policy' },
      { label: 'Return Policy', to: '/return-policy' },
      { label: 'Contact Us', to: '/contact' },
      { label: 'Open Support Ticket', to: '/support' },
      { label: 'Privacy Policy', to: '/privacy-policy' },
    ],
  },
];

export default function Footer() {
  const [newsletterEmail, setNewsletterEmail] = useState('');
  const [newsletterSent, setNewsletterSent] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [newsletterContent, setNewsletterContent] = useState(null);

  useEffect(() => {
    fetchContentBlock('newsletter_footer')
      .then((block) => setNewsletterContent(block))
      .catch(() => setNewsletterContent(null));
  }, []);

  const newsletterData = newsletterContent?.data_json || {};
  const newsletterHeading = newsletterData.heading || 'Newsletter';
  const newsletterDesc = newsletterData.desc
    || newsletterContent?.body_md
    || 'Get exclusive offers, style tips, and new arrivals directly in your inbox.';
  const newsletterNote = newsletterData.note || 'No spam. Unsubscribe anytime.';
  const handleNewsletter = async (e) => {
    e.preventDefault();
    const v = newsletterEmail.trim();
    if (!/\S+@\S+\.\S+/.test(v)) {
      toast.error('Enter a valid email address.');
      return;
    }
    setSubmitting(true);
    try {
      await subscribeNewsletter(v);
      toast.success(`Subscribed — we'll send offers to ${v}.`);
      setNewsletterSent(true);
      setNewsletterEmail('');
      setTimeout(() => setNewsletterSent(false), 5000);
    } catch {
      toast.error('Could not subscribe. Please try again later.');
    } finally {
      setSubmitting(false);
    }
  };

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
              <h4 className="footer-col-heading">{newsletterHeading}</h4>
              <p className="footer-newsletter-desc">{newsletterDesc}</p>
              <form className="footer-newsletter-form" onSubmit={handleNewsletter}>
                <input
                  type="email"
                  placeholder="Your email address"
                  className="footer-newsletter-input"
                  id="newsletter-email"
                  value={newsletterEmail}
                  onChange={(e) => setNewsletterEmail(e.target.value)}
                  required
                />
                <button type="submit" className="footer-newsletter-btn">
                  {newsletterSent ? '✓ Subscribed' : 'Subscribe'}
                </button>
              </form>
              <p className="footer-newsletter-note">
                {newsletterSent
                  ? 'Thanks — check your inbox for our welcome email.'
                  : newsletterNote}
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
