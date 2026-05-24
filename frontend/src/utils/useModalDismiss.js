/**
 * useModalDismiss — wire Esc-to-close + body scroll lock on a modal.
 * Overlay click is intentionally NOT bound here — pass it on the JSX overlay
 * div if you want it, or omit to require explicit X / Cancel for forms with
 * unsaved data. The default-no-overlay-click stance is the safer one: the
 * AdminProducts modal had 7 tabs of typed data silently dropped by stray
 * outside-clicks before this hook landed.
 */
import { useEffect } from 'react';

export default function useModalDismiss(open, onClose) {
  useEffect(() => {
    if (!open) return undefined;
    const onKey = (e) => {
      if (e.key === 'Escape') {
        e.stopPropagation();
        onClose?.();
      }
    };
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    document.addEventListener('keydown', onKey);
    return () => {
      document.body.style.overflow = prevOverflow;
      document.removeEventListener('keydown', onKey);
    };
  }, [open, onClose]);
}
