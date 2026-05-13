/**
 * Static info pages — FAQ, Shipping, Returns, Privacy, Contact, Support.
 *
 * Render server-driven CMS content where the backend has it (FAQs + Pages),
 * else fall back to sensible defaults so the footer links never 404.
 */
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { FiPhone, FiMail, FiMapPin, FiMessageSquare, FiSend } from 'react-icons/fi';
import toast from 'react-hot-toast';
import api from '../api';
import { useAuth } from '../context/AuthContext';
import { useSettings } from '../context/SettingsContext';
import './InfoPages.css';

function PageShell({ eyebrow, title, sub, children }) {
  return (
    <div className="info-page container">
      <header className="info-page__header">
        <span className="info-page__eyebrow">{eyebrow}</span>
        <h1 className="info-page__title">{title}</h1>
        {sub && <p className="info-page__sub">{sub}</p>}
      </header>
      <div className="info-page__content">{children}</div>
    </div>
  );
}

const LINK_RE = /\[([^\]]+)\]\(([^)]+)\)/g;

function renderInline(text) {
  const nodes = [];
  let lastIndex = 0;
  let match;
  while ((match = LINK_RE.exec(text)) !== null) {
    if (match.index > lastIndex) {
      nodes.push(text.slice(lastIndex, match.index));
    }
    nodes.push(
      <a key={`${match[2]}-${match.index}`} href={match[2]} target="_blank" rel="noreferrer">
        {match[1]}
      </a>
    );
    lastIndex = match.index + match[0].length;
  }
  if (lastIndex < text.length) {
    nodes.push(text.slice(lastIndex));
  }
  return nodes;
}

function renderMarkdown(md) {
  const lines = String(md || '').replace(/\r\n/g, '\n').split('\n');
  const blocks = [];
  let paragraph = [];
  let list = null;

  const flushParagraph = () => {
    if (paragraph.length) {
      blocks.push({ type: 'p', text: paragraph.join(' ').trim() });
      paragraph = [];
    }
  };

  const flushList = () => {
    if (list && list.items.length) {
      blocks.push(list);
    }
    list = null;
  };

  lines.forEach((line) => {
    const trimmed = line.trim();
    if (!trimmed) {
      flushParagraph();
      flushList();
      return;
    }

    const headingMatch = trimmed.match(/^(#{1,3})\s+(.*)$/);
    if (headingMatch) {
      flushParagraph();
      flushList();
      blocks.push({ type: `h${headingMatch[1].length}`, text: headingMatch[2] });
      return;
    }

    const orderedMatch = trimmed.match(/^\d+\.\s+(.*)$/);
    if (orderedMatch) {
      flushParagraph();
      if (!list || list.type !== 'ol') {
        flushList();
        list = { type: 'ol', items: [] };
      }
      list.items.push(orderedMatch[1]);
      return;
    }

    const unorderedMatch = trimmed.match(/^[-*]\s+(.*)$/);
    if (unorderedMatch) {
      flushParagraph();
      if (!list || list.type !== 'ul') {
        flushList();
        list = { type: 'ul', items: [] };
      }
      list.items.push(unorderedMatch[1]);
      return;
    }

    paragraph.push(trimmed);
  });

  flushParagraph();
  flushList();

  return blocks.map((block, index) => {
    if (block.type === 'p') {
      return <p key={`p-${index}`}>{renderInline(block.text)}</p>;
    }
    if (block.type === 'h1') {
      return <h2 key={`h1-${index}`}>{renderInline(block.text)}</h2>;
    }
    if (block.type === 'h2') {
      return <h2 key={`h2-${index}`}>{renderInline(block.text)}</h2>;
    }
    if (block.type === 'h3') {
      return <h3 key={`h3-${index}`}>{renderInline(block.text)}</h3>;
    }
    if (block.type === 'ol') {
      return (
        <ol key={`ol-${index}`}>
          {block.items.map((item, i) => (
            <li key={`ol-${index}-${i}`}>{renderInline(item)}</li>
          ))}
        </ol>
      );
    }
    if (block.type === 'ul') {
      return (
        <ul key={`ul-${index}`}>
          {block.items.map((item, i) => (
            <li key={`ul-${index}-${i}`}>{renderInline(item)}</li>
          ))}
        </ul>
      );
    }
    return null;
  });
}

function useCmsPage(slug) {
  const [page, setPage] = useState(null);

  useEffect(() => {
    let alive = true;
    api.get(`/cms/pages/${slug}/`)
      .then((r) => {
        if (alive) setPage(r.data);
      })
      .catch(() => {
        if (alive) setPage(null);
      });
    return () => { alive = false; };
  }, [slug]);

  return page;
}

/* ─── FAQ ─────────────────────────────────────────────────────────── */

const DEFAULT_FAQS = [
  { q: 'How long does shipping take?',
    a: 'Most orders ship within 24 hours and arrive in 3-7 business days depending on your PIN code. The exact delivery window is shown at checkout.' },
  { q: 'Do you ship across India?',
    a: 'Yes — we deliver to every serviceable PIN code in India. Some remote pin codes may take an extra 2-4 days.' },
  { q: 'Can I cancel my order?',
    a: 'Orders can be cancelled free of charge until they are dispatched. Once shipped, please use the return flow from My Orders.' },
  { q: 'What is the return policy?',
    a: 'We accept returns within 14 days of delivery in original condition with original packaging. Visit the Return Policy page for full details.' },
  { q: 'Do you offer dealer pricing?',
    a: 'Yes. Apply via the "Become a Dealer" link in the footer. Once approved, dealer prices appear automatically site-wide.' },
  { q: 'How do I track my order?',
    a: 'Sign in and visit My Orders, or use the Track Order link in the footer with the email you used at checkout.' },
];

export function FAQPage() {
  const [items, setItems] = useState(DEFAULT_FAQS);
  const [open, setOpen] = useState(0);

  useEffect(() => {
    api.get('/cms/faqs/').then((r) => {
      const rows = r.data?.results || r.data || [];
      if (Array.isArray(rows) && rows.length > 0) {
        setItems(rows.map((f) => ({ q: f.question, a: f.answer })));
      }
    }).catch(() => { /* keep defaults */ });
  }, []);

  return (
    <PageShell
      eyebrow="Help Center"
      title="Frequently asked questions"
      sub="Quick answers to the things customers ask most often."
    >
      <div className="faq-list">
        {items.map((it, i) => (
          <details key={i} open={i === open} className="faq-item"
                   onToggle={(e) => e.currentTarget.open && setOpen(i)}>
            <summary className="faq-item__q">{it.q}</summary>
            <div className="faq-item__a">{it.a}</div>
          </details>
        ))}
      </div>
      <div className="info-page__cta">
        <p>Still have questions?</p>
        <Link to="/contact" className="btn-primary">Contact us</Link>
      </div>
    </PageShell>
  );
}

/* ─── Shipping policy ────────────────────────────────────────────── */

export function ShippingPolicyPage() {
  const { settings } = useSettings();
  const cmsPage = useCmsPage('shipping-policy');
  const threshold = settings.free_shipping_threshold 
    ? new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(settings.free_shipping_threshold)
    : 'any amount';
  const cmsBody = cmsPage?.body_md?.trim();

  return (
    <PageShell
      eyebrow="Logistics"
      title={cmsPage?.title || 'Shipping Policy'}
      sub="How we get your furniture from our warehouse to your home."
    >
      <article className="info-prose">
        {cmsBody ? renderMarkdown(cmsBody) : (
          <>
            <h2>Delivery timelines</h2>
            <p>Standard delivery is 3–7 business days for serviceable PIN codes.
            Remote pin codes may add 2–4 days. Bulk and assembled items (sofas, beds)
            may take 7–12 days because they ship from regional warehouses.</p>

            <h2>Shipping charges</h2>
            <ul>
              <li>Orders above <strong>{threshold}</strong> ship free across India.</li>
              <li>Orders below that threshold attract a flat fee that's shown at checkout
              (varies by PIN code).</li>
            </ul>

            <h2>Cash on delivery</h2>
            <p>COD is available on most pin codes for orders up to ₹50,000. Eligibility
            is checked at checkout the moment you enter your PIN.</p>

            <h2>Damaged in transit?</h2>
            <p>Take a photo at the time of delivery and open a support ticket
            within <strong>48 hours</strong>. We'll replace damaged items at no cost.</p>

            <h2>Assembly &amp; installation</h2>
            <p>White-glove installation is included for sofas, beds, dining sets,
            and wardrobes within metro PIN codes. Smaller items (lamps, side tables,
            cushions) ship pre-assembled or with simple tool-free setup.</p>
          </>
        )}
      </article>
    </PageShell>
  );
}

/* ─── Return policy ──────────────────────────────────────────────── */

export function ReturnPolicyPage() {
  const cmsPage = useCmsPage('return-policy');
  const cmsBody = cmsPage?.body_md?.trim();

  return (
    <PageShell
      eyebrow="Returns &amp; Refunds"
      title={cmsPage?.title || 'Return Policy'}
      sub="14-day no-questions-asked window on most products."
    >
      <article className="info-prose">
        {cmsBody ? renderMarkdown(cmsBody) : (
          <>
            <h2>The 14-day window</h2>
            <p>Returns are accepted within <strong>14 days</strong> of delivery,
            provided the product is in original condition with original packaging,
            unused, and free of damage.</p>

            <h2>How to start a return</h2>
            <ol>
              <li>Sign in and go to <Link to="/orders">My Orders</Link>.</li>
              <li>Pick the order, click <em>Return</em>, choose a reason.</li>
              <li>We schedule a pickup; refund hits your original payment method
              within 5–7 business days after the item reaches our warehouse.</li>
            </ol>

            <h2>What can't be returned</h2>
            <ul>
              <li>Made-to-order / custom-sized furniture.</li>
              <li>Mattresses and bed linens once unsealed (hygiene reasons).</li>
              <li>Items with visible damage caused after delivery.</li>
            </ul>

            <h2>Defective on arrival</h2>
            <p>If your item arrives broken, please open a support ticket within
            <strong> 48 hours </strong> with photos. We'll replace it free of cost
            or issue a full refund — your choice.</p>

            <h2>Dealer returns</h2>
            <p>Dealers placing bulk orders may have negotiated return terms;
            these are spelled out on the dealer agreement. Contact your account
            manager for specifics.</p>
          </>
        )}
      </article>
    </PageShell>
  );
}

/* ─── Privacy policy ─────────────────────────────────────────────── */

export function PrivacyPolicyPage() {
  const cmsPage = useCmsPage('privacy-policy');
  const cmsBody = cmsPage?.body_md?.trim();

  return (
    <PageShell
      eyebrow="Legal"
      title={cmsPage?.title || 'Privacy Policy'}
      sub="What we collect, why we collect it, and your rights."
    >
      <article className="info-prose">
        {cmsBody ? renderMarkdown(cmsBody) : (
          <>
            <h2>What we collect</h2>
            <p>Name, email, phone, shipping address, and order history — the bare
            minimum needed to fulfil your purchase and surface order updates.</p>

            <h2>How it's used</h2>
            <ul>
              <li>Processing orders and contacting you about deliveries.</li>
              <li>Generating tax invoices that comply with Indian GST law.</li>
              <li>Personalising offers (you can opt out in account settings).</li>
            </ul>

            <h2>What we don't do</h2>
            <p>We never sell your data to third parties, ever. The only sharing
            that happens is with shipping partners (to deliver your order) and
            payment processors (Razorpay) — strictly to complete the transaction.</p>

            <h2>Your rights</h2>
            <p>You can request a data export or full account deletion any time —
            email <a href="mailto:privacy@furnishop.in">privacy@furnishop.in</a>.
            We'll honour it within 30 days as required by India's Digital Personal
            Data Protection Act.</p>
          </>
        )}
      </article>
    </PageShell>
  );
}

/* ─── Contact ────────────────────────────────────────────────────── */

export function ContactPage() {
  const cmsPage = useCmsPage('contact-us');
  const cmsBody = cmsPage?.body_md?.trim();

  return (
    <PageShell
      eyebrow="Reach out"
      title={cmsPage?.title || 'Contact Us'}
      sub="We typically reply within one business day."
    >
      <div className="contact-grid">
        <a href="tel:+918001234567" className="contact-card">
          <FiPhone size={20} />
          <div>
            <strong>Call</strong>
            <span>1800-123-4567 (Toll Free)</span>
            <small>Mon–Sat · 9am – 9pm IST</small>
          </div>
        </a>
        <a href="mailto:hello@furnishop.in" className="contact-card">
          <FiMail size={20} />
          <div>
            <strong>Email</strong>
            <span>hello@furnishop.in</span>
            <small>Replies within one business day</small>
          </div>
        </a>
        <Link to="/support" className="contact-card">
          <FiMessageSquare size={20} />
          <div>
            <strong>Open a ticket</strong>
            <span>Full conversation history with our team</span>
            <small>Best for complex order issues</small>
          </div>
        </Link>
        <div className="contact-card contact-card--static">
          <FiMapPin size={20} />
          <div>
            <strong>Visit</strong>
            <span>FurniShop Studios</span>
            <small>Mumbai, India · Showroom by appointment</small>
          </div>
        </div>
      </div>
      {cmsBody && (
        <article className="info-prose" style={{ marginTop: 24 }}>
          {renderMarkdown(cmsBody)}
        </article>
      )}
    </PageShell>
  );
}

/* ─── Public support — open a ticket without admin/dealer access ─── */

const CATEGORIES = [
  { value: 'order',    label: 'Order issue' },
  { value: 'payment',  label: 'Payment' },
  { value: 'shipping', label: 'Shipping / delivery' },
  { value: 'product',  label: 'Product question' },
  { value: 'account',  label: 'Account / login' },
  { value: 'other',    label: 'Something else' },
];

export function SupportPage() {
  const { user } = useAuth();
  const cmsPage = useCmsPage('support');
  const cmsBody = cmsPage?.body_md?.trim();
  const [form, setForm] = useState({
    subject: '', category: 'order', priority: 'normal',
    body: '', email: '', name: '',
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(null); // ticket_number

  const update = (k, v) => setForm((f) => ({ ...f, [k]: v }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.subject.trim() || !form.body.trim()) {
      toast.error('Please fill subject and message.');
      return;
    }
    setSubmitting(true);
    try {
      if (user) {
        const r = await api.post('/support/tickets/', {
          subject: form.subject, category: form.category,
          priority: form.priority, body: form.body,
        });
        setSubmitted(r.data.ticket_number);
      } else {
        // Guest path — now supported via the backend API
        if (!/\S+@\S+\.\S+/.test(form.email)) {
          toast.error('Add a valid email so we can reply.');
          setSubmitting(false);
          return;
        }
        const r = await api.post('/support/tickets/', {
          subject: form.subject, category: form.category,
          priority: form.priority, body: form.body,
          guest_email: form.email, guest_name: form.name,
        });
        setSubmitted(r.data.ticket_number);
      }
      toast.success("Thanks — we've got your message.");
    } catch {
      toast.error('Could not send. Please email hello@furnishop.in directly.');
    } finally {
      setSubmitting(false);
    }
  };

  if (submitted) {
    return (
      <PageShell
        eyebrow="Support"
        title="Message received"
        sub={user
          ? "We'll reply in your account's support inbox."
          : "We'll email you back as soon as we can."}
      >
        <div className="info-page__success">
          <strong>Reference:</strong> <code>{submitted}</code>
          <p>Keep this reference for follow-up. {user
            ? <>Track progress in <Link to={user.role === 'admin' ? '/admin-dashboard/support' : '/dealer-dashboard/support'}>your account</Link>.</>
            : 'Our team replies within one business day.'}</p>
          <Link to="/" className="btn-outline">Back to homepage</Link>
        </div>
      </PageShell>
    );
  }

  return (
    <PageShell
      eyebrow="Support"
      title={cmsPage?.title || 'Open a support request'}
      sub={user
        ? 'Tell us what happened — we\'ll reply right here in your account.'
        : 'Anyone can reach us — sign in for full ticket history, or just leave your email below.'}
    >
      {cmsBody && (
        <article className="info-prose" style={{ marginBottom: 24 }}>
          {renderMarkdown(cmsBody)}
        </article>
      )}
      <form className="support-public-form" onSubmit={handleSubmit}>
        {!user && (
          <div className="support-public-row">
            <label className="support-public-field">
              <span>Your name</span>
              <input value={form.name}
                     onChange={(e) => update('name', e.target.value)}
                     placeholder="Jane Doe" />
            </label>
            <label className="support-public-field">
              <span>Email *</span>
              <input type="email" required value={form.email}
                     onChange={(e) => update('email', e.target.value)}
                     placeholder="jane@example.com" />
            </label>
          </div>
        )}
        <label className="support-public-field">
          <span>Subject *</span>
          <input required value={form.subject}
                 onChange={(e) => update('subject', e.target.value)}
                 placeholder="Brief summary, e.g. 'Order not delivered yet'" />
        </label>
        <div className="support-public-row">
          <label className="support-public-field">
            <span>Category</span>
            <select value={form.category}
                    onChange={(e) => update('category', e.target.value)}>
              {CATEGORIES.map((c) => (
                <option key={c.value} value={c.value}>{c.label}</option>
              ))}
            </select>
          </label>
          <label className="support-public-field">
            <span>Priority</span>
            <select value={form.priority}
                    onChange={(e) => update('priority', e.target.value)}>
              <option value="low">Low</option>
              <option value="normal">Normal</option>
              <option value="high">High</option>
              <option value="urgent">Urgent</option>
            </select>
          </label>
        </div>
        <label className="support-public-field">
          <span>Message *</span>
          <textarea rows={6} required value={form.body}
                    onChange={(e) => update('body', e.target.value)}
                    placeholder="Share the order number, what happened, and what you'd like us to do." />
        </label>
        <div className="support-public-footer">
          <small>Or email us at <a href="mailto:hello@furnishop.in">hello@furnishop.in</a></small>
          <button type="submit" disabled={submitting} className="btn-primary"
                  style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <FiSend size={14} />
            {submitting ? 'Sending…' : 'Send message'}
          </button>
        </div>
      </form>
    </PageShell>
  );
}
