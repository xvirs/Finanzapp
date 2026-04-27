// ─── Logo Finanzapp — recreación SVG del logo de la web ─────
// Cuadrado redondeado verde + $ blanco bold

function FzLogo({ size = 56, radius, bg = '#10B981', fg = '#FFFFFF', shadow = false }) {
  const r = radius ?? Math.round(size * 0.26);
  return (
    <div style={{
      width: size, height: size,
      borderRadius: r, background: bg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: shadow ? `0 6px 20px ${bg}55, 0 1px 0 rgba(255,255,255,0.15) inset` : 'none',
      flexShrink: 0,
    }}>
      <svg width={size * 0.55} height={size * 0.62} viewBox="0 0 22 26" fill="none" aria-hidden="true">
        {/* vertical stroke through the S */}
        <path d="M11 1.5 v23" stroke={fg} strokeWidth="2.6" strokeLinecap="round"/>
        {/* S shape — bold, rounded */}
        <path
          d="M18.5 6.5 C 18.5 4 16.3 2.8 13.2 2.8 H 9 C 6 2.8 3.5 4.4 3.5 7.4 C 3.5 10.2 5.6 11.4 9 12.2 L 13.5 13.2 C 16.5 13.9 18.5 15 18.5 17.8 C 18.5 21 16 22.7 13 22.7 H 8.5 C 5.5 22.7 3.5 21.4 3.5 19"
          stroke={fg} strokeWidth="3.2" strokeLinecap="round" strokeLinejoin="round" fill="none"
        />
      </svg>
    </div>
  );
}

Object.assign(window, { FzLogo });
