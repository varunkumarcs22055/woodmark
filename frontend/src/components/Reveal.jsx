/**
 * Reveal — wraps children in a scroll-triggered entrance animation.
 *
 * Usage:
 *   <Reveal>…</Reveal>                       // fade-up (default)
 *   <Reveal variant="fade" delay={120}>…     // fade only, 120ms in
 *   <Reveal as="section" variant="left">…    // render as <section>
 *
 * Variants map to CSS in index.css: 'up' | 'fade' | 'left' | 'right' | 'scale'.
 * `delay` (ms) staggers siblings without per-child CSS rules.
 */
import useScrollReveal from '../utils/useScrollReveal';

export default function Reveal({
  as: Tag = 'div',
  variant = 'up',
  delay = 0,
  className = '',
  style,
  children,
  ...rest
}) {
  const ref = useScrollReveal();
  return (
    <Tag
      ref={ref}
      className={`reveal reveal--${variant} ${className}`.trim()}
      style={delay ? { ...style, transitionDelay: `${delay}ms` } : style}
      {...rest}
    >
      {children}
    </Tag>
  );
}
