/**
 * RewardsPage — customer hub for loyalty points, referrals, and gift cards.
 */
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { FiAward, FiGift, FiUsers, FiCopy, FiCheck } from 'react-icons/fi';
import { useAuth } from '../context/AuthContext';
import { fetchLoyalty, fetchReferral, buyGiftCard, checkGiftCard } from '../api';
import { formatPrice } from '../utils/format';
import './RewardsPage.css';

const GIFT_AMOUNTS = [500, 1000, 2000, 5000, 10000];

export default function RewardsPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [loyalty, setLoyalty] = useState(null);
  const [referral, setReferral] = useState(null);
  const [copied, setCopied] = useState(false);
  const [giftAmount, setGiftAmount] = useState(1000);
  const [giftEmail, setGiftEmail] = useState('');
  const [giftMsg, setGiftMsg] = useState('');
  const [issuedCard, setIssuedCard] = useState(null);
  const [buying, setBuying] = useState(false);
  const [checkCode, setCheckCode] = useState('');
  const [checkResult, setCheckResult] = useState(null);

  useEffect(() => {
    if (!user) { navigate('/login?next=/rewards'); return; }
    fetchLoyalty().then(setLoyalty).catch(() => setLoyalty(null));
    fetchReferral().then(setReferral).catch(() => setReferral(null));
  }, [user, navigate]);

  const copyLink = () => {
    if (!referral?.share_url) return;
    navigator.clipboard?.writeText(referral.share_url).then(() => {
      setCopied(true);
      toast.success('Referral link copied!');
      setTimeout(() => setCopied(false), 2000);
    });
  };

  const handleBuy = async () => {
    setBuying(true);
    try {
      const card = await buyGiftCard({
        amount: giftAmount,
        recipient_email: giftEmail.trim(),
        message: giftMsg.trim(),
      });
      setIssuedCard(card);
      toast.success('Gift card created!');
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Could not create gift card.');
    } finally {
      setBuying(false);
    }
  };

  const handleCheck = async () => {
    const code = checkCode.trim();
    if (!code) return;
    try {
      const r = await checkGiftCard(code);
      setCheckResult({ ok: true, ...r });
    } catch {
      setCheckResult({ ok: false });
    }
  };

  if (!user) return null;

  const pointValue = parseFloat(loyalty?.point_value ?? 1);

  return (
    <div className="rewards-page container">
      <h1 className="rewards-title">Rewards &amp; Referrals</h1>

      <div className="rewards-grid">
        {/* Loyalty */}
        <section className="rewards-card rewards-card--accent">
          <div className="rewards-card-head"><FiAward /> <span>Reward points</span></div>
          <div className="rewards-balance">
            {loyalty ? loyalty.points_balance.toLocaleString() : '—'}
            <small>points</small>
          </div>
          <p className="rewards-sub">
            Worth {loyalty ? formatPrice(loyalty.points_balance * pointValue) : '—'} ·
            earn {loyalty?.earn_rate ?? 2}% back on every order
          </p>
          <div className="rewards-history">
            {(loyalty?.transactions || []).length === 0 ? (
              <p className="rewards-empty">No activity yet. Place an order to start earning.</p>
            ) : (
              loyalty.transactions.map((t) => (
                <div className="rewards-row" key={t.id}>
                  <span>{t.reason || t.kind}</span>
                  <strong className={t.points >= 0 ? 'pos' : 'neg'}>
                    {t.points >= 0 ? '+' : ''}{t.points}
                  </strong>
                </div>
              ))
            )}
          </div>
        </section>

        {/* Referral */}
        <section className="rewards-card">
          <div className="rewards-card-head"><FiUsers /> <span>Refer &amp; earn</span></div>
          <p className="rewards-sub">
            Share your link. When a friend places their first order, you both get
            <strong> {referral?.bonus_points ?? 200} points</strong>.
          </p>
          <div className="rewards-code-box">
            <input readOnly value={referral?.share_url || ''} />
            <button type="button" onClick={copyLink} className="btn-primary">
              {copied ? <FiCheck size={15} /> : <FiCopy size={15} />}
            </button>
          </div>
          <div className="rewards-refstats">
            <div><strong>{referral?.referred_count ?? 0}</strong><span>Invited</span></div>
            <div><strong>{referral?.rewarded_count ?? 0}</strong><span>Rewarded</span></div>
            <div><strong>{referral?.code || '—'}</strong><span>Your code</span></div>
          </div>
        </section>

        {/* Gift cards */}
        <section className="rewards-card">
          <div className="rewards-card-head"><FiGift /> <span>Gift cards</span></div>
          {issuedCard ? (
            <div className="rewards-issued">
              <p>Your gift card is ready 🎉</p>
              <div className="rewards-giftcode">{issuedCard.code}</div>
              <p className="rewards-sub">Balance {formatPrice(issuedCard.balance)} · redeem at checkout.</p>
              <button className="btn-outline" onClick={() => setIssuedCard(null)}>Buy another</button>
            </div>
          ) : (
            <>
              <p className="rewards-sub">Buy a gift card to share. Redeemable at checkout.</p>
              <div className="rewards-amounts">
                {GIFT_AMOUNTS.map((a) => (
                  <button
                    key={a}
                    type="button"
                    className={`rewards-amount ${giftAmount === a ? 'active' : ''}`}
                    onClick={() => setGiftAmount(a)}
                  >
                    {formatPrice(a)}
                  </button>
                ))}
              </div>
              <input
                className="form-input rewards-input"
                placeholder="Recipient email (optional)"
                value={giftEmail}
                onChange={(e) => setGiftEmail(e.target.value)}
              />
              <input
                className="form-input rewards-input"
                placeholder="Message (optional)"
                value={giftMsg}
                onChange={(e) => setGiftMsg(e.target.value)}
              />
              <button className="btn-primary rewards-buy" onClick={handleBuy} disabled={buying}>
                {buying ? 'Creating…' : `Buy ${formatPrice(giftAmount)} gift card`}
              </button>
            </>
          )}

          <div className="rewards-check">
            <input
              className="form-input rewards-input"
              placeholder="Check a gift card balance"
              value={checkCode}
              onChange={(e) => { setCheckCode(e.target.value); setCheckResult(null); }}
            />
            <button type="button" className="btn-secondary" onClick={handleCheck}>Check</button>
          </div>
          {checkResult && (
            <p className={`rewards-checkres ${checkResult.ok ? 'ok' : 'bad'}`}>
              {checkResult.ok
                ? `Balance: ${formatPrice(checkResult.balance)}`
                : 'Invalid or inactive gift card.'}
            </p>
          )}
        </section>
      </div>
    </div>
  );
}
