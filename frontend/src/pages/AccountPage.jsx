/**
 * AccountPage — user profile hub (orders, wishlist, profile).
 */
import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  FiUser, FiPackage, FiHeart, FiEdit2, FiSave, FiX,
  FiMapPin, FiPlus, FiTrash2,
  FiBell, FiShield,
} from 'react-icons/fi';
import toast from 'react-hot-toast';
import {
  fetchOrders, fetchWishlist, updateProfile,
  fetchAddresses, createAddress, updateAddress, deleteAddress,
  fetchNotifications, markNotificationRead, markAllNotificationsRead,
  changePassword, fetchNotificationPreferences, updateNotificationPreferences,
} from '../api';
import { useAuth } from '../context/AuthContext';
import OrderCard from '../components/OrderCard';
import ProductCard from '../components/ProductCard';
import { formatDate } from '../utils/format';
import './AccountPage.css';

const TABS = [
  { key: 'overview', label: 'Overview', icon: <FiUser /> },
  { key: 'orders', label: 'Orders', icon: <FiPackage /> },
  { key: 'wishlist', label: 'Wishlist', icon: <FiHeart /> },
  { key: 'addresses', label: 'Addresses', icon: <FiMapPin /> },
  { key: 'notifications', label: 'Notifications', icon: <FiBell /> },
  { key: 'profile', label: 'Profile', icon: <FiEdit2 /> },
];

const emptyAddress = {
  full_name: '',
  phone: '',
  line1: '',
  line2: '',
  landmark: '',
  city: '',
  state: '',
  postal_code: '',
  country: 'India',
  address_type: 'home',
  is_default_shipping: false,
  is_default_billing: false,
};

export default function AccountPage() {
  const { user, loading: authLoading, refreshProfile } = useAuth();
  const [activeTab, setActiveTab] = useState('overview');

  const [orders, setOrders] = useState([]);
  const [wishlist, setWishlist] = useState([]);
  const [ordersLoading, setOrdersLoading] = useState(false);
  const [wishlistLoading, setWishlistLoading] = useState(false);
  const [addresses, setAddresses] = useState([]);
  const [addressesLoading, setAddressesLoading] = useState(false);
  const [addressForm, setAddressForm] = useState(emptyAddress);
  const [addressEditingId, setAddressEditingId] = useState(null);
  const [notifications, setNotifications] = useState([]);
  const [notificationsLoading, setNotificationsLoading] = useState(false);
  const [prefLoading, setPrefLoading] = useState(false);
  const [prefs, setPrefs] = useState(null);
  const [pwForm, setPwForm] = useState({ old_password: '', new_password: '', confirm_password: '' });
  const [pwSaving, setPwSaving] = useState(false);

  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({
    full_name: '',
    phone: '',
  });

  useEffect(() => {
    if (!user) return;
    setForm({
      full_name: user.full_name || '',
      phone: user.phone || '',
    });
  }, [user]);

  useEffect(() => {
    if (!user) return;
    setOrdersLoading(true);
    fetchOrders()
      .then((data) => setOrders(Array.isArray(data) ? data : data?.results || []))
      .catch(() => setOrders([]))
      .finally(() => setOrdersLoading(false));
  }, [user]);

  useEffect(() => {
    if (!user) return;
    setWishlistLoading(true);
    fetchWishlist()
      .then((data) => setWishlist(Array.isArray(data) ? data : data?.results || []))
      .catch(() => setWishlist([]))
      .finally(() => setWishlistLoading(false));
  }, [user]);

  useEffect(() => {
    if (!user) return;
    setAddressesLoading(true);
    fetchAddresses()
      .then((data) => setAddresses(Array.isArray(data) ? data : data?.results || []))
      .catch(() => setAddresses([]))
      .finally(() => setAddressesLoading(false));
  }, [user]);

  useEffect(() => {
    if (!user) return;
    setNotificationsLoading(true);
    fetchNotifications()
      .then((data) => setNotifications(Array.isArray(data) ? data : data?.results || []))
      .catch(() => setNotifications([]))
      .finally(() => setNotificationsLoading(false));
  }, [user]);

  useEffect(() => {
    if (!user) return;
    setPrefLoading(true);
    fetchNotificationPreferences()
      .then((data) => setPrefs(data))
      .catch(() => setPrefs(null))
      .finally(() => setPrefLoading(false));
  }, [user]);

  const recentOrders = useMemo(() => orders.slice(0, 3), [orders]);
  const wishlistProducts = useMemo(
    () => wishlist.map((w) => w.product_detail).filter(Boolean),
    [wishlist]
  );
  const defaultAddress = useMemo(
    () => addresses.find((a) => a.is_default_shipping) || addresses[0],
    [addresses]
  );

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await updateProfile({
        full_name: form.full_name.trim(),
        phone: form.phone.trim(),
      });
      await refreshProfile();
      toast.success('Profile updated.');
      setEditing(false);
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to update profile.');
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    setForm({
      full_name: user?.full_name || '',
      phone: user?.phone || '',
    });
    setEditing(false);
  };

  const resetAddressForm = () => {
    setAddressForm(emptyAddress);
    setAddressEditingId(null);
  };

  const startEditAddress = (addr) => {
    setAddressForm({
      full_name: addr.full_name || '',
      phone: addr.phone || '',
      line1: addr.line1 || '',
      line2: addr.line2 || '',
      landmark: addr.landmark || '',
      city: addr.city || '',
      state: addr.state || '',
      postal_code: addr.postal_code || '',
      country: addr.country || 'India',
      address_type: addr.address_type || 'home',
      is_default_shipping: !!addr.is_default_shipping,
      is_default_billing: !!addr.is_default_billing,
    });
    setAddressEditingId(addr.id);
    setActiveTab('addresses');
  };

  const submitAddress = async (e) => {
    e.preventDefault();
    try {
      const payload = {
        ...addressForm,
        full_name: addressForm.full_name.trim(),
        phone: addressForm.phone.trim(),
        line1: addressForm.line1.trim(),
        line2: addressForm.line2.trim(),
        landmark: addressForm.landmark.trim(),
        city: addressForm.city.trim(),
        state: addressForm.state.trim(),
        postal_code: addressForm.postal_code.trim(),
        country: addressForm.country.trim() || 'India',
      };
      if (addressEditingId) {
        const updated = await updateAddress(addressEditingId, payload);
        setAddresses((prev) => prev.map((a) => (a.id === updated.id ? updated : a)));
        toast.success('Address updated.');
      } else {
        const created = await createAddress(payload);
        setAddresses((prev) => [created, ...prev]);
        toast.success('Address saved.');
      }
      resetAddressForm();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to save address.');
    }
  };

  const removeAddress = async (addr) => {
    if (!window.confirm('Delete this address?')) return;
    try {
      await deleteAddress(addr.id);
      setAddresses((prev) => prev.filter((a) => a.id !== addr.id));
      if (addressEditingId === addr.id) resetAddressForm();
      toast.success('Address deleted.');
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Failed to delete address.');
    }
  };

  const markRead = async (n) => {
    if (n.is_read) return;
    try {
      await markNotificationRead(n.id);
      setNotifications((prev) => prev.map((x) => (x.id === n.id ? { ...x, is_read: true } : x)));
    } catch {
      toast.error('Failed to mark as read.');
    }
  };

  const markAllRead = async () => {
    try {
      await markAllNotificationsRead();
      setNotifications((prev) => prev.map((x) => ({ ...x, is_read: true })));
      toast.success('All notifications marked as read.');
    } catch {
      toast.error('Failed to mark all.');
    }
  };

  const submitPassword = async (e) => {
    e.preventDefault();
    // Catch the obvious mistakes client-side so the user gets a precise
    // message instead of a generic backend rejection.
    if (pwForm.new_password.length < 8) {
      toast.error('New password must be at least 8 characters.');
      return;
    }
    if (pwForm.new_password !== pwForm.confirm_password) {
      toast.error("Passwords don't match.");
      return;
    }
    if (pwForm.new_password === pwForm.old_password) {
      toast.error('Pick a new password different from the current one.');
      return;
    }
    setPwSaving(true);
    try {
      await changePassword(pwForm);
      toast.success('Password updated.');
      setPwForm({ old_password: '', new_password: '', confirm_password: '' });
    } catch (err) {
      const data = err.response?.data || {};
      // DRF validators return per-field arrays; flatten the first useful one
      // so messages like "This password is too common." surface to the user.
      const msg =
        data.old_password?.[0] || data.old_password
        || data.new_password?.[0] || data.new_password
        || data.confirm_password?.[0] || data.confirm_password
        || data.non_field_errors?.[0]
        || data.detail
        || 'Failed to update password.';
      toast.error(typeof msg === 'string' ? msg : 'Failed to update password.');
    } finally {
      setPwSaving(false);
    }
  };

  const togglePref = async (key, value) => {
    if (!prefs) return;
    const next = { ...prefs, [key]: value };
    setPrefs(next);
    try {
      const updated = await updateNotificationPreferences({ [key]: value });
      setPrefs(updated);
    } catch {
      toast.error('Failed to update preferences.');
      setPrefs(prefs);
    }
  };

  if (!authLoading && !user) {
    return (
      <div className="account-page container">
        <div className="account-hero">
          <h1>Your Account</h1>
          <p>Sign in to see your orders, wishlist, and profile details.</p>
          <div className="account-hero__actions">
            <Link to="/login" className="btn-primary">Sign In</Link>
            <Link to="/signup" className="btn-secondary">Create Account</Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="account-page container">
      <div className="account-hero">
        <div>
          <h1>Welcome back{user?.full_name ? `, ${user.full_name}` : ''}</h1>
          <p>Manage your orders, wishlist, and account details in one place.</p>
        </div>
        <div className="account-hero__meta">
          <div className="account-meta-card">
            <span className="account-meta-label">Orders</span>
            <strong>{orders.length}</strong>
          </div>
          <div className="account-meta-card">
            <span className="account-meta-label">Wishlist</span>
            <strong>{wishlist.length}</strong>
          </div>
          {user?.date_joined && (
            <div className="account-meta-card">
              <span className="account-meta-label">Member Since</span>
              <strong>{formatDate(user.date_joined)}</strong>
            </div>
          )}
        </div>
      </div>

      <div className="account-tabs">
        {TABS.map((t) => (
          <button
            key={t.key}
            className={`account-tab ${activeTab === t.key ? 'active' : ''}`}
            onClick={() => setActiveTab(t.key)}
          >
            {t.icon} {t.label}
          </button>
        ))}
      </div>

      {activeTab === 'overview' && (
        <div className="account-grid">
          <section className="account-card">
            <div className="account-card__header">
              <h2>Recent Orders</h2>
              <Link to="/orders" className="account-link">View all</Link>
            </div>
            {ordersLoading ? (
              <div className="account-skeleton" />
            ) : recentOrders.length === 0 ? (
              <div className="account-empty">No orders yet.</div>
            ) : (
              <div className="account-orders-list">
                {recentOrders.map((o) => <OrderCard key={o.order_id} order={o} />)}
              </div>
            )}
          </section>

          <section className="account-card">
            <div className="account-card__header">
              <h2>Wishlist</h2>
              <button
                className="account-link"
                onClick={() => setActiveTab('wishlist')}
              >
                View all
              </button>
            </div>
            {wishlistLoading ? (
              <div className="account-skeleton" />
            ) : wishlistProducts.length === 0 ? (
              <div className="account-empty">Your wishlist is empty.</div>
            ) : (
              <div className="account-wishlist-preview">
                {wishlistProducts.slice(0, 4).map((p) => (
                  <ProductCard key={p.id} product={p} />
                ))}
              </div>
            )}
          </section>

          <section className="account-card">
            <div className="account-card__header">
              <h2>Profile</h2>
              <button className="account-link" onClick={() => setActiveTab('profile')}>
                Edit
              </button>
            </div>
            <div className="account-profile-summary">
              <div>
                <span className="account-meta-label">Name</span>
                <strong>{user?.full_name || '—'}</strong>
              </div>
              <div>
                <span className="account-meta-label">Email</span>
                <strong>{user?.email || '—'}</strong>
              </div>
              <div>
                <span className="account-meta-label">Phone</span>
                <strong>{user?.phone || '—'}</strong>
              </div>
            </div>
          </section>

          <section className="account-card">
            <div className="account-card__header">
              <h2>Default Address</h2>
              <button className="account-link" onClick={() => setActiveTab('addresses')}>
                Manage
              </button>
            </div>
            {addressesLoading ? (
              <div className="account-skeleton" />
            ) : defaultAddress ? (
              <div className="account-address-card">
                <strong>{defaultAddress.full_name}</strong>
                <span className="account-meta-label">
                  {defaultAddress.address_type}
                </span>
                <p>
                  {defaultAddress.line1}
                  {defaultAddress.line2 ? `, ${defaultAddress.line2}` : ''}
                </p>
                <p>
                  {defaultAddress.city}, {defaultAddress.state} {defaultAddress.postal_code}
                </p>
                <p>{defaultAddress.country}</p>
              </div>
            ) : (
              <div className="account-empty">No address saved yet.</div>
            )}
          </section>
        </div>
      )}

      {activeTab === 'orders' && (
        <section className="account-card">
          <div className="account-card__header">
            <h2>My Orders</h2>
          </div>
          {ordersLoading ? (
            <div className="account-skeleton" />
          ) : orders.length === 0 ? (
            <div className="account-empty">No orders yet.</div>
          ) : (
            <div className="account-orders-list">
              {orders.map((o) => <OrderCard key={o.order_id} order={o} />)}
            </div>
          )}
        </section>
      )}

      {activeTab === 'wishlist' && (
        <section className="account-card">
          <div className="account-card__header">
            <h2>Wishlist</h2>
          </div>
          {wishlistLoading ? (
            <div className="account-skeleton" />
          ) : wishlistProducts.length === 0 ? (
            <div className="account-empty">Your wishlist is empty.</div>
          ) : (
            <div className="account-wishlist-grid">
              {wishlistProducts.map((p) => (
                <ProductCard key={p.id} product={p} />
              ))}
            </div>
          )}
        </section>
      )}

      {activeTab === 'notifications' && (
        <section className="account-card">
          <div className="account-card__header">
            <h2>Notifications</h2>
            <button className="account-link" onClick={markAllRead}>
              Mark all read
            </button>
          </div>
          <details className="account-preferences" open={false}>
            <summary>Notification Preferences</summary>
            {prefLoading ? (
              <div className="account-empty">Loading preferences...</div>
            ) : !prefs ? (
              <div className="account-empty">Preferences unavailable.</div>
            ) : (
              <div className="account-preferences-grid">
                <label>
                  <input
                    type="checkbox"
                    checked={!!prefs.email_order_updates}
                    onChange={(e) => togglePref('email_order_updates', e.target.checked)}
                  />
                  Email order updates
                </label>
                <label>
                  <input
                    type="checkbox"
                    checked={!!prefs.email_marketing}
                    onChange={(e) => togglePref('email_marketing', e.target.checked)}
                  />
                  Email marketing
                </label>
                <label>
                  <input
                    type="checkbox"
                    checked={!!prefs.sms_order_updates}
                    onChange={(e) => togglePref('sms_order_updates', e.target.checked)}
                  />
                  SMS order updates
                </label>
                <label>
                  <input
                    type="checkbox"
                    checked={!!prefs.sms_marketing}
                    onChange={(e) => togglePref('sms_marketing', e.target.checked)}
                  />
                  SMS marketing
                </label>
              </div>
            )}
          </details>
          {notificationsLoading ? (
            <div className="account-skeleton" />
          ) : notifications.length === 0 ? (
            <div className="account-empty">No notifications yet.</div>
          ) : (
            <div className="account-notifications">
              {notifications.map((n) => (
                <button
                  key={n.id}
                  className={`account-note ${n.is_read ? 'is-read' : ''}`}
                  onClick={() => markRead(n)}
                >
                  <div>
                    <strong>{n.title || 'Update'}</strong>
                    <p>{n.body}</p>
                  </div>
                  {!n.is_read && <span className="account-note-dot" />}
                </button>
              ))}
            </div>
          )}
        </section>
      )}

      {activeTab === 'addresses' && (
        <section className="account-card">
          <div className="account-card__header">
            <h2>Saved Addresses</h2>
            <button className="account-link" onClick={resetAddressForm}>
              <FiPlus size={14} /> Add New
            </button>
          </div>

          <form className="account-address-form" onSubmit={submitAddress}>
            <div className="address-form-grid">
              <div className="account-form__field">
                <label>Full Name</label>
                <input
                  type="text"
                  value={addressForm.full_name}
                  onChange={(e) => setAddressForm({ ...addressForm, full_name: e.target.value })}
                  required
                />
              </div>
              <div className="account-form__field">
                <label>Phone</label>
                <input
                  type="tel"
                  value={addressForm.phone}
                  onChange={(e) => setAddressForm({ ...addressForm, phone: e.target.value })}
                />
              </div>
              <div className="account-form__field address-form-span">
                <label>Address Line 1</label>
                <input
                  type="text"
                  value={addressForm.line1}
                  onChange={(e) => setAddressForm({ ...addressForm, line1: e.target.value })}
                  required
                />
              </div>
              <div className="account-form__field address-form-span">
                <label>Address Line 2</label>
                <input
                  type="text"
                  value={addressForm.line2}
                  onChange={(e) => setAddressForm({ ...addressForm, line2: e.target.value })}
                />
              </div>
              <div className="account-form__field address-form-span">
                <label>Landmark</label>
                <input
                  type="text"
                  value={addressForm.landmark}
                  onChange={(e) => setAddressForm({ ...addressForm, landmark: e.target.value })}
                />
              </div>
              <div className="account-form__field">
                <label>City</label>
                <input
                  type="text"
                  value={addressForm.city}
                  onChange={(e) => setAddressForm({ ...addressForm, city: e.target.value })}
                  required
                />
              </div>
              <div className="account-form__field">
                <label>State</label>
                <input
                  type="text"
                  value={addressForm.state}
                  onChange={(e) => setAddressForm({ ...addressForm, state: e.target.value })}
                  required
                />
              </div>
              <div className="account-form__field">
                <label>Postal Code</label>
                <input
                  type="text"
                  value={addressForm.postal_code}
                  onChange={(e) => setAddressForm({ ...addressForm, postal_code: e.target.value })}
                  required
                />
              </div>
              <div className="account-form__field">
                <label>Country</label>
                <input
                  type="text"
                  value={addressForm.country}
                  onChange={(e) => setAddressForm({ ...addressForm, country: e.target.value })}
                />
              </div>
              <div className="account-form__field">
                <label>Address Type</label>
                <select
                  value={addressForm.address_type}
                  onChange={(e) => setAddressForm({ ...addressForm, address_type: e.target.value })}
                >
                  <option value="home">Home</option>
                  <option value="office">Office</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>

            <div className="address-form-flags">
              <label>
                <input
                  type="checkbox"
                  checked={addressForm.is_default_shipping}
                  onChange={(e) => setAddressForm({ ...addressForm, is_default_shipping: e.target.checked })}
                />
                Default shipping
              </label>
              <label>
                <input
                  type="checkbox"
                  checked={addressForm.is_default_billing}
                  onChange={(e) => setAddressForm({ ...addressForm, is_default_billing: e.target.checked })}
                />
                Default billing
              </label>
            </div>

            <div className="account-form__actions">
              <button type="submit" className="btn-primary">
                <FiSave size={14} /> {addressEditingId ? 'Update' : 'Save'}
              </button>
              {addressEditingId && (
                <button type="button" className="btn-secondary" onClick={resetAddressForm}>
                  <FiX size={14} /> Cancel
                </button>
              )}
            </div>
          </form>

          <div className="account-addresses">
            {addressesLoading ? (
              <div className="account-skeleton" />
            ) : addresses.length === 0 ? (
              <div className="account-empty">No addresses saved yet.</div>
            ) : (
              addresses.map((addr) => (
                <div key={addr.id} className="account-address-card">
                  <div className="account-address-header">
                    <div>
                      <strong>{addr.full_name}</strong>
                      <span className="account-meta-label">{addr.address_type}</span>
                    </div>
                    <div className="account-address-actions">
                      <button className="account-link" onClick={() => startEditAddress(addr)}>
                        <FiEdit2 size={14} /> Edit
                      </button>
                      <button className="account-link account-link--danger" onClick={() => removeAddress(addr)}>
                        <FiTrash2 size={14} /> Delete
                      </button>
                    </div>
                  </div>
                  <p>
                    {addr.line1}
                    {addr.line2 ? `, ${addr.line2}` : ''}
                  </p>
                  {addr.landmark && <p>Landmark: {addr.landmark}</p>}
                  <p>
                    {addr.city}, {addr.state} {addr.postal_code}
                  </p>
                  <p>{addr.country}</p>
                  <div className="account-address-badges">
                    {addr.is_default_shipping && <span>Default shipping</span>}
                    {addr.is_default_billing && <span>Default billing</span>}
                  </div>
                </div>
              ))
            )}
          </div>
        </section>
      )}

      {activeTab === 'profile' && (
        <section className="account-card">
          <div className="account-card__header">
            <h2>Profile Details</h2>
            {!editing && (
              <button className="account-link" onClick={() => setEditing(true)}>
                <FiEdit2 size={14} /> Edit
              </button>
            )}
          </div>
          {editing ? (
            <form className="account-form" onSubmit={handleSave}>
              <div className="account-form__field">
                <label>Full Name</label>
                <input
                  type="text"
                  value={form.full_name}
                  onChange={(e) => setForm({ ...form, full_name: e.target.value })}
                  required
                />
              </div>
              <div className="account-form__field">
                <label>Phone</label>
                <input
                  type="tel"
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                  pattern="\d{10}"
                  required
                />
              </div>
              <div className="account-form__actions">
                <button type="submit" className="btn-primary" disabled={saving}>
                  <FiSave size={14} /> {saving ? 'Saving...' : 'Save'}
                </button>
                <button type="button" className="btn-secondary" onClick={handleCancel}>
                  <FiX size={14} /> Cancel
                </button>
              </div>
            </form>
          ) : (
            <div className="account-profile-summary">
              <div>
                <span className="account-meta-label">Name</span>
                <strong>{user?.full_name || '—'}</strong>
              </div>
              <div>
                <span className="account-meta-label">Email</span>
                <strong>{user?.email || '—'}</strong>
              </div>
              <div>
                <span className="account-meta-label">Phone</span>
                <strong>{user?.phone || '—'}</strong>
              </div>
            </div>
          )}

          <div className="account-divider" />

          <div className="account-card__header">
            <h2><FiShield size={16} /> Security</h2>
          </div>
          <form className="account-form" onSubmit={submitPassword}>
            <div className="account-form__field">
              <label>Current Password</label>
              <input
                type="password"
                value={pwForm.old_password}
                onChange={(e) => setPwForm({ ...pwForm, old_password: e.target.value })}
                required
              />
            </div>
            <div className="account-form__field">
              <label>New Password</label>
              <input
                type="password"
                value={pwForm.new_password}
                onChange={(e) => setPwForm({ ...pwForm, new_password: e.target.value })}
                required
              />
            </div>
            <div className="account-form__field">
              <label>Confirm New Password</label>
              <input
                type="password"
                value={pwForm.confirm_password}
                onChange={(e) => setPwForm({ ...pwForm, confirm_password: e.target.value })}
                required
              />
            </div>
            <div className="account-form__actions">
              <button type="submit" className="btn-primary" disabled={pwSaving}>
                <FiSave size={14} /> {pwSaving ? 'Saving...' : 'Update Password'}
              </button>
            </div>
          </form>
        </section>
      )}
    </div>
  );
}
