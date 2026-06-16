/**
 * SupportChatbot — floating help widget shown on the public storefront.
 *
 * Behaviour:
 *   - Closed: a round teal button in the bottom-right with a chat icon.
 *   - Open: a 360px panel slides up from the corner.
 *   - First open: bot greets the user + shows topic chips fetched from
 *     /api/support/bot/ (GET).
 *   - Sending a message POSTs to /api/support/bot/ and renders the reply
 *     + any follow-up-prompt chips returned.
 *   - When the bot can't answer, an "Open a support ticket" button appears.
 *     Clicking it creates a SupportTicket with the full conversation history
 *     prefilled into the first message, then closes the chat.
 *
 * State lives in localStorage (`woodmark_chat_history`) so refreshing the
 * page doesn't lose the conversation.
 */
import { useEffect, useRef, useState } from 'react';
import {
  FiMessageCircle, FiX, FiSend, FiUser, FiCpu,
  FiUserPlus, FiTrash2,
} from 'react-icons/fi';
import { askBot, fetchBotTopics, createTicket } from '../api';
import { useAuth } from '../context/AuthContext';
import toast from 'react-hot-toast';

const STORAGE_KEY = 'woodmark_chat_history';

function loadHistory() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch { return null; }
}

function saveHistory(messages) {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(messages)); }
  catch { /* quota */ }
}

const GREETING = {
  role: 'bot',
  text: "Hi! I'm Woodmark's assistant. Pick a topic below, or just type your question.",
  ts: Date.now(),
};

export default function SupportChatbot() {
  const { user } = useAuth();
  const [open, setOpen] = useState(false);
  const [topics, setTopics] = useState([]);
  const [messages, setMessages] = useState(() => loadHistory() || [GREETING]);
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);
  // After every send the last bot reply may carry follow-up chips:
  const [followUps, setFollowUps] = useState([]);
  // True when the last bot reply was a fallback — surfaces the "Open ticket" CTA.
  const [canEscalate, setCanEscalate] = useState(false);
  const scrollRef = useRef(null);

  // Persist on every change.
  useEffect(() => { saveHistory(messages); }, [messages]);

  // Load topic list the first time the panel opens.
  useEffect(() => {
    if (!open || topics.length) return;
    fetchBotTopics()
      .then((data) => setTopics(data.topics || []))
      .catch(() => {});
  }, [open, topics.length]);

  // Auto-scroll to the bottom on new messages.
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, open]);

  // Hard-coded local intents: things the bot should ALWAYS know about so
  // the buyer never gets "I couldn't find an answer" for the most basic
  // questions. Cheaper + faster than a round-trip to the backend matcher.
  const SUPPORT_PHONE = '1800-123-4567';
  const SUPPORT_EMAIL = 'hello@woodmark.in';
  const LOCAL_INTENTS = [
    {
      patterns: [/contact\s*support|phone|call.*us|customer\s*care|helpline|talk\s*to\s*human|talk\s*to\s*a\s*human|speak\s*to\s*(a|an)?\s*agent/i],
      reply: (
        `You can reach Woodmark support directly:\n\n` +
        `📞 ${SUPPORT_PHONE} (Toll Free, 9am–9pm IST)\n` +
        `✉️ ${SUPPORT_EMAIL}\n\n` +
        `If you'd rather have us reach out, tap "Talk to a human (open a ticket)" below and we'll get back within a few hours.`
      ),
      escalate: true,
    },
    {
      patterns: [/^hi$|^hello|^hey/i],
      reply: 'Hi! I can help with orders, payments, shipping, returns, dealer credit, or product questions. What\'s on your mind?',
    },
  ];

  const send = async (rawText) => {
    const text = (rawText ?? input).trim();
    if (!text || sending) return;
    const userMsg = { role: 'user', text, ts: Date.now() };
    setMessages((m) => [...m, userMsg]);
    setInput('');
    setSending(true);
    setFollowUps([]);
    setCanEscalate(false);

    // Try local intents first — instant reply, no network round-trip.
    const intent = LOCAL_INTENTS.find((it) =>
      it.patterns.some((p) => p.test(text)),
    );
    if (intent) {
      setMessages((m) => [...m, { role: 'bot', text: intent.reply, ts: Date.now() }]);
      setCanEscalate(!!intent.escalate);
      setSending(false);
      return;
    }

    try {
      const res = await askBot(text);
      const botMsg = {
        role: 'bot',
        text: res.reply,
        topic: res.topic,
        ts: Date.now(),
      };
      setMessages((m) => [...m, botMsg]);
      setFollowUps(res.follow_ups || []);
      setCanEscalate(!!res.can_escalate);
    } catch (err) {
      setMessages((m) => [...m, {
        role: 'bot',
        text: 'Sorry — something went wrong reaching support. Please try again or open a ticket.',
        ts: Date.now(),
      }]);
      setCanEscalate(true);
    } finally {
      setSending(false);
    }
  };

  const reset = () => {
    setMessages([GREETING]);
    setFollowUps([]);
    setCanEscalate(false);
    saveHistory([GREETING]);
  };

  const escalate = async () => {
    // Build a ticket using the full conversation as the body.
    const lastUserMsg = [...messages].reverse().find((m) => m.role === 'user');
    const subject = lastUserMsg
      ? `Chat escalation: ${lastUserMsg.text.slice(0, 80)}`
      : 'Chat escalation';
    const conversation = messages
      .map((m) => `${m.role === 'user' ? 'You' : 'Bot'}: ${m.text}`)
      .join('\n\n');

    if (!user) {
      toast.error('Please sign in first to open a ticket.');
      window.location.href = '/login?next=/account/support';
      return;
    }

    try {
      const ticket = await createTicket({
        subject,
        category: 'other',
        priority: 'normal',
        // Backend SupportTicketCreateSerializer expects `body`, not
        // `first_message`. The mismatch was silently 400-ing every chatbot
        // escalation attempt.
        body: `Created from chatbot.\n\nConversation transcript:\n\n${conversation}`,
      });
      toast.success(`Ticket ${ticket.ticket_number} opened. Our team will reply soon.`);
      reset();
      setOpen(false);
      // Send user to their inbox so they can follow the ticket.
      window.location.href = '/account/support';
    } catch (err) {
      const data = err.response?.data || {};
      const detail = data.detail
        || data.body?.[0]
        || data.subject?.[0]
        || Object.values(data).flat()[0]
        || 'Could not open ticket. Please try again.';
      toast.error(typeof detail === 'string' ? detail : 'Could not open ticket. Please try again.');
    }
  };

  return (
    <>
      {/* Floating action button — hides itself once the panel is open. */}
      {!open && (
        <button
          type="button"
          onClick={() => setOpen(true)}
          className="chatbot-fab"
          aria-label="Open support chat"
        >
          <FiMessageCircle size={22} />
        </button>
      )}

      {/* Slide-up panel */}
      {open && (
        <div className="chatbot-panel" role="dialog" aria-label="Support chat">
          <header className="chatbot-header">
            <div className="chatbot-header__avatar"><FiCpu size={18} /></div>
            <div className="chatbot-header__title">
              <strong>Woodmark Help</strong>
              <span>Typical reply: instant</span>
            </div>
            <button
              type="button"
              onClick={reset}
              className="chatbot-header__btn"
              title="Reset conversation"
              aria-label="Reset conversation"
            >
              <FiTrash2 size={14} />
            </button>
            <button
              type="button"
              onClick={() => setOpen(false)}
              className="chatbot-header__btn"
              title="Close"
              aria-label="Close chat"
            >
              <FiX size={18} />
            </button>
          </header>

          <div ref={scrollRef} className="chatbot-scroll">
            {messages.map((m, i) => (
              <div key={i} className={`chatbot-msg chatbot-msg--${m.role}`}>
                <span className="chatbot-msg__icon">
                  {m.role === 'user' ? <FiUser size={14} /> : <FiCpu size={14} />}
                </span>
                <div className="chatbot-msg__bubble">{m.text}</div>
              </div>
            ))}

            {/* Topic chips, only at the very start when user hasn't typed yet. */}
            {messages.length === 1 && topics.length > 0 && (
              <div className="chatbot-chips">
                {topics.flatMap((t) =>
                  t.questions.map((q) => (
                    <button
                      key={`${t.topic}-${q.id}`}
                      type="button"
                      className="chatbot-chip"
                      onClick={() => send(q.question)}
                    >
                      {q.question}
                    </button>
                  ))
                )}
              </div>
            )}

            {/* Follow-up chips below the latest bot reply. */}
            {followUps.length > 0 && (
              <div className="chatbot-chips">
                {followUps.map((q) => (
                  <button
                    key={q}
                    type="button"
                    className="chatbot-chip"
                    onClick={() => send(q)}
                  >
                    {q}
                  </button>
                ))}
              </div>
            )}

            {/* "Talk to a human" escalation CTA */}
            {canEscalate && messages.length > 1 && (
              <button
                type="button"
                className="chatbot-escalate"
                onClick={escalate}
              >
                <FiUserPlus size={14} /> Talk to a human (open a ticket)
              </button>
            )}
          </div>

          <form
            className="chatbot-input"
            onSubmit={(e) => { e.preventDefault(); send(); }}
          >
            <input
              type="text"
              placeholder="Ask anything…"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              disabled={sending}
              autoFocus
            />
            <button type="submit" disabled={sending || !input.trim()}>
              <FiSend size={16} />
            </button>
          </form>
        </div>
      )}
    </>
  );
}
