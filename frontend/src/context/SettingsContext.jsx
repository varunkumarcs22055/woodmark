import { createContext, useContext, useState, useEffect } from 'react';
import { fetchStoreSettings } from '../api';

const DEFAULT = {
  gst_percent: '18.00',
  free_shipping_threshold: '2999.00',
  standard_shipping_fee: '499.00',
};

const SettingsContext = createContext(DEFAULT);

export function SettingsProvider({ children }) {
  const [settings, setSettings] = useState(DEFAULT);

  useEffect(() => {
    fetchStoreSettings()
      .then(setSettings)
      .catch(() => {});
  }, []);

  return (
    <SettingsContext.Provider value={settings}>
      {children}
    </SettingsContext.Provider>
  );
}

export const useSettings = () => useContext(SettingsContext);
