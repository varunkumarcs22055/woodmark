import { createContext, useContext, useState, useEffect } from 'react';
import { fetchStoreSettings } from '../api';

const SettingsContext = createContext();

export function SettingsProvider({ children }) {
  const [settings, setSettings] = useState({
    free_shipping_threshold: 2999,
    gst_percent: 18,
    standard_shipping_fee: 499,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStoreSettings()
      .then((data) => {
        if (data) {
          setSettings({
            free_shipping_threshold: parseFloat(data.free_shipping_threshold),
            gst_percent: parseFloat(data.gst_percent),
            standard_shipping_fee: parseFloat(data.standard_shipping_fee),
          });
        }
      })
      .catch(() => {
        // Fallback to defaults
        console.warn('Failed to fetch store settings, using defaults.');
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <SettingsContext.Provider value={{ settings, loading }}>
      {children}
    </SettingsContext.Provider>
  );
}

export function useSettings() {
  return useContext(SettingsContext);
}
