// ─── A · FLUJO TARJETAS (modo oscuro) ─────────────────────────
// Reusa los tokens de A definidos en screens-a.jsx (window.A no está exportado,
// así que redefino los necesarios aquí dentro)

const AC = {
  bg: '#0B0F0D', card: '#141B18', cardHi: '#192521',
  cardPaid: '#0E2018', cardLate: '#23120F', cardAccent: '#0F1B26',
  border: '#1F2A26', borderHi: '#2A3833', borderPaid: '#1B3A2A', borderLate: '#3A1813', borderAccent: '#1A2A3D',
  text: '#E8EDEA', textDim: '#8A9590', textMute: '#5C6661',
  primary: '#1FB87A', primaryHi: '#2DD891', primarySoft: '#0E2A1E', primaryInk: '#04130C',
  late: '#E5604A', lateSoft: '#3A1813', lateInk: '#FF8B72',
  fontBody: '"Geist", "Inter", system-ui, sans-serif',
  fontMono: '"Geist Mono", "JetBrains Mono", ui-monospace, monospace',
};

function ACIcon({ name, size = 20, color = 'currentColor', strokeWidth = 1.6 }) {
  const c = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: color, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'card': return (<svg {...c}><rect x="2.5" y="5.5" width="19" height="13" rx="2.5"/><path d="M2.5 10h19"/><path d="M6 14.5h3"/></svg>);
    case 'cal':  return (<svg {...c}><rect x="3.5" y="5" width="17" height="15" rx="2.5"/><path d="M3.5 10h17"/><path d="M8 3v4M16 3v4"/></svg>);
    case 'gear': return (<svg {...c}><circle cx="12" cy="12" r="3"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5 5l1.4 1.4M17.6 17.6 19 19M5 19l1.4-1.4M17.6 6.4 19 5"/></svg>);
    case 'check':return (<svg {...c}><path d="M4.5 12.5 9.5 17.5 19.5 7.5"/></svg>);
    case 'arrL': return (<svg {...c}><path d="M19 12H5M11 6l-6 6 6 6"/></svg>);
    case 'plus': return (<svg {...c}><path d="M12 5v14M5 12h14"/></svg>);
    case 'ext':  return (<svg {...c}><path d="M14 4.5h5.5V10"/><path d="M19.5 4.5 12 12"/><path d="M19.5 14v4a2 2 0 0 1-2 2h-12a2 2 0 0 1-2-2v-12a2 2 0 0 1 2-2h4"/></svg>);
    case 'repeat':return (<svg {...c}><path d="M17 2.5 20.5 6 17 9.5"/><path d="M3.5 13v-2A4 4 0 0 1 7.5 7h13"/><path d="M7 21.5 3.5 18 7 14.5"/><path d="M20.5 11v2a4 4 0 0 1-4 4h-13"/></svg>);
    case 'trash':return (<svg {...c}><path d="M4.5 7h15"/><path d="M9 7V4.5h6V7"/><path d="M6 7l1 13.5h10L18 7"/></svg>);
    case 'save': return (<svg {...c}><path d="M5 4.5h12L19.5 7v12.5a1 1 0 0 1-1 1H5.5a1 1 0 0 1-1-1V5.5a1 1 0 0 1 1-1Z"/><path d="M8 4.5v5h7v-5"/><path d="M8 14h8v6H8z"/></svg>);
    case 'chev': return (<svg {...c}><path d="M5.5 9 12 15.5 18.5 9"/></svg>);
    case 'home': return (<svg {...c}><path d="M3.5 10.5 12 4l8.5 6.5"/><path d="M5.5 9.5v9.5h13V9.5"/><path d="M10 19v-5h4v5"/></svg>);
  }
  return null;
}

function ACBackBar({ title, brand, right }) {
  return (
    <div style={{ padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12, color: AC.text, fontFamily: AC.fontBody }}>
      <button style={{ width: 36, height: 36, borderRadius: 10, background: 'transparent', border: `1px solid ${AC.border}`, color: AC.text, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><ACIcon name="arrL" size={18}/></button>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8, minWidth: 0 }}>
        <span style={{ fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{title}</span>
        {brand && <span style={{ fontSize: 9, padding: '2px 6px', borderRadius: 4, background: brand.bg, color: brand.fg, fontWeight: 700, letterSpacing: '0.04em' }}>{brand.label}</span>}
      </div>
      {right}
    </div>
  );
}

function ACTabBar({ active = 'tarjetas' }) {
  const tabs = [
    { id: 'mes', label: 'Mes', icon: 'cal' },
    { id: 'tarjetas', label: 'Tarjetas', icon: 'card' },
    { id: 'config', label: 'Config', icon: 'gear' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      borderTop: `1px solid ${AC.border}`, background: AC.bg,
      padding: '8px 0 12px', display: 'flex',
    }}>
      {tabs.map(t => {
        const on = t.id === active;
        return (
          <div key={t.id} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, color: on?AC.primary:AC.textMute }}>
            <div style={{ padding: '4px 16px', borderRadius: 10, background: on ? AC.primarySoft : 'transparent', display: 'flex' }}>
              <ACIcon name={t.icon} size={20} color={on?AC.primary:AC.textMute}/>
            </div>
            <span style={{ fontSize: 10.5, fontWeight: 500 }}>{t.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ── 1. LISTA DE TARJETAS ─────────────────────────────────────
function ACardsList() {
  const cards = [
    { name: 'Galicia VISA', sub: '1 déb. aut.', amount: '$175.557', status: 'late', vence: 'Vence día 15', brand: { label: 'VISA', bg: '#1A1F71', fg: '#fff' } },
    { name: 'Galicia Mastercard', sub: 'Sin cargos este mes', amount: '$0', status: 'empty', vence: 'Vence día 15', brand: { label: 'MC', bg: '#EB001B', fg: '#fff' } },
    { name: 'MercadoPago', sub: '7 débitos aut.', amount: '$245.396', status: 'paid', vence: 'Vence día 15', brand: { label: 'MP', bg: '#009EE3', fg: '#fff' } },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: AC.bg, color: AC.text, fontFamily: AC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        {/* Header */}
        <div style={{ padding: '14px 20px 18px', borderBottom: `1px solid ${AC.border}` }}>
          <div style={{ fontSize: 26, fontWeight: 600, letterSpacing: '-0.025em', marginBottom: 2 }}>Tarjetas</div>
          <div style={{ fontSize: 12, color: AC.textDim, fontFamily: AC.fontMono, letterSpacing: '0.02em' }}>abril de 2026</div>
          <div style={{ marginTop: 14, fontSize: 11, color: AC.textMute, fontFamily: AC.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 4 }}>Total del mes</div>
          <div style={{ fontSize: 32, fontWeight: 600, letterSpacing: '-0.025em', fontFeatureSettings: '"tnum"' }}>$410.953</div>
        </div>

        {/* Cards list */}
        <div style={{ padding: '14px 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {cards.map((card, i) => {
            const isPaid = card.status === 'paid';
            const isLate = card.status === 'late';
            const isEmpty = card.status === 'empty';
            const cardBg = isPaid ? AC.cardPaid : isLate ? AC.cardLate : AC.card;
            const cardBorder = isPaid ? AC.borderPaid : isLate ? AC.borderLate : AC.border;
            const accentColor = isPaid ? AC.primary : isLate ? AC.late : AC.textDim;
            return (
              <div key={i} style={{ background: cardBg, border: `1px solid ${cardBorder}`, borderRadius: 16, padding: '14px 16px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
                  <div style={{
                    width: 38, height: 38, borderRadius: 10,
                    background: isPaid ? AC.primary : isLate ? AC.lateSoft : AC.cardHi,
                    color: isPaid ? AC.primaryInk : isLate ? AC.lateInk : AC.textDim,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontFamily: AC.fontMono, fontSize: 14, fontWeight: 600,
                    flexShrink: 0,
                    border: isLate ? `1px solid ${AC.late}66` : 'none',
                  }}>
                    {isPaid ? <ACIcon name="check" size={18} color={AC.primaryInk} strokeWidth={2.4}/> : '15'}
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6, flexWrap: 'wrap' }}>
                      <span style={{ fontSize: 15, fontWeight: 600, letterSpacing: '-0.005em' }}>{card.name}</span>
                      <span style={{ fontSize: 9, padding: '2px 6px', borderRadius: 4, background: card.brand.bg, color: card.brand.fg, fontWeight: 700, letterSpacing: '0.04em' }}>{card.brand.label}</span>
                    </div>
                    <div style={{ fontSize: 11.5, color: AC.textMute, marginTop: 2, fontFamily: AC.fontMono }}>{card.sub}</div>
                  </div>
                  {isLate && (<span style={{ fontSize: 9, padding: '3px 7px', borderRadius: 4, background: AC.lateSoft, color: AC.lateInk, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Atrasada</span>)}
                </div>

                <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
                  <div style={{ fontSize: 24, fontWeight: 600, letterSpacing: '-0.02em', color: isEmpty ? AC.textDim : isPaid ? AC.primaryHi : AC.text, fontFeatureSettings: '"tnum"' }}>{card.amount}</div>
                  <div style={{ fontSize: 11, color: isPaid ? AC.primary : AC.textMute, fontFamily: AC.fontMono, letterSpacing: '0.04em', textTransform: 'uppercase' }}>{isPaid ? 'Pagado' : card.vence}</div>
                </div>

                <button style={{
                  width: '100%', padding: '10px', borderRadius: 10,
                  background: 'transparent', border: `1px solid ${AC.border}`,
                  color: AC.text, fontFamily: AC.fontBody, fontSize: 13, fontWeight: 500,
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                }}>
                  <ACIcon name="ext" size={14}/> Ir a pagar
                </button>
              </div>
            );
          })}
        </div>
        <div style={{ height: 12 }}/>
      </div>
      <ACTabBar active="tarjetas"/>
    </div>
  );
}

// ── 2. DETALLE DE TARJETA (MercadoPago) ──────────────────────
function ACardDetail() {
  const debits = [
    { name: 'Brave VPN', day: 4, amount: '$14.500' },
    { name: 'GEMINI', day: 5, amount: '$29.000' },
    { name: 'Claude', day: 5, amount: '$145.000' },
    { name: 'Youtube', day: 7, amount: '$6.799' },
    { name: 'Google One', day: 8, amount: '$4.500' },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: AC.bg, color: AC.text, fontFamily: AC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <ACBackBar
          title="MercadoPago"
          brand={{ label: 'MP', bg: '#009EE3', fg: '#fff' }}
          right={<button style={{ width: 36, height: 36, borderRadius: 10, background: 'transparent', border: `1px solid ${AC.border}`, color: AC.textDim, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><ACIcon name="gear" size={17}/></button>}
        />

        {/* Hero card "pagado" */}
        <div style={{ margin: '4px 16px 16px', padding: '20px 20px 18px', background: AC.cardPaid, border: `1px solid ${AC.borderPaid}`, borderRadius: 18, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', right: -50, top: -50, width: 180, height: 180, background: `radial-gradient(circle, ${AC.primary}24, transparent 70%)`, pointerEvents: 'none' }}/>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
            <ACIcon name="check" size={13} color={AC.primary} strokeWidth={2.4}/>
            <span style={{ fontSize: 11, color: AC.primary, fontFamily: AC.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase', fontWeight: 500 }}>Pagado</span>
          </div>
          <div style={{ fontSize: 36, fontWeight: 600, letterSpacing: '-0.03em', color: AC.primaryHi, fontFeatureSettings: '"tnum"', marginBottom: 4 }}>$245.396</div>
          <div style={{ fontSize: 12, color: AC.textDim, fontFamily: AC.fontMono, marginBottom: 14 }}>7 débitos automáticos · vence 15</div>

          <button style={{
            padding: '10px 14px', borderRadius: 10,
            background: 'transparent', border: `1px solid ${AC.borderPaid}`,
            color: AC.text, fontFamily: AC.fontBody, fontSize: 13, fontWeight: 500,
            display: 'inline-flex', alignItems: 'center', gap: 8,
          }}>
            <ACIcon name="ext" size={13}/> Ir a pagar
          </button>
        </div>

        {/* Compras en cuotas */}
        <div style={{ padding: '0 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: AC.textDim }}>
            <ACIcon name="card" size={14} color={AC.textDim}/>
            <span style={{ fontSize: 11, letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 500, fontFamily: AC.fontMono }}>Compras en cuotas</span>
            <span style={{ color: AC.textMute, fontSize: 11, fontFamily: AC.fontMono }}>· 0</span>
          </div>
          <button style={{ padding: '4px 10px', borderRadius: 8, background: AC.primarySoft, border: `1px solid ${AC.borderPaid}`, color: AC.primary, fontFamily: AC.fontBody, fontSize: 11.5, fontWeight: 500, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
            <ACIcon name="plus" size={12} color={AC.primary} strokeWidth={2}/> Nueva
          </button>
        </div>

        <div style={{ margin: '0 16px 18px', padding: '16px', background: AC.card, border: `1px dashed ${AC.border}`, borderRadius: 12, textAlign: 'center', fontSize: 12, color: AC.textMute, fontStyle: 'italic' }}>
          Sin compras en cuotas registradas
        </div>

        {/* Débitos automáticos */}
        <div style={{ padding: '0 20px', display: 'flex', alignItems: 'center', gap: 8, color: AC.textDim, marginBottom: 8 }}>
          <ACIcon name="repeat" size={14} color={AC.textDim}/>
          <span style={{ fontSize: 11, letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 500, fontFamily: AC.fontMono }}>Débitos automáticos</span>
          <span style={{ color: AC.textMute, fontSize: 11, fontFamily: AC.fontMono }}>· 7</span>
        </div>

        <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 6 }}>
          {debits.map((d, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px', background: AC.card, border: `1px solid ${AC.border}`, borderRadius: 12 }}>
              <div style={{
                width: 32, height: 32, borderRadius: 8, background: AC.cardHi,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: AC.fontMono, fontSize: 11, color: AC.textDim, fontWeight: 600,
                flexShrink: 0,
              }}>{d.name.slice(0,2).toUpperCase()}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13.5, fontWeight: 500 }}>{d.name}</div>
                <div style={{ fontSize: 10.5, color: AC.textMute, fontFamily: AC.fontMono, marginTop: 1 }}>Día {d.day}</div>
              </div>
              <div style={{ fontSize: 13, fontWeight: 600, fontFeatureSettings: '"tnum"' }}>{d.amount}</div>
            </div>
          ))}
        </div>
        <div style={{ height: 12 }}/>
      </div>
      <ACTabBar active="tarjetas"/>
    </div>
  );
}

// ── helpers de form ──
function ACField({ label, children, required }) {
  return (
    <div>
      <div style={{ fontSize: 10.5, color: AC.textMute, marginBottom: 6, fontFamily: AC.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase' }}>
        {label}{required && <span style={{ color: AC.late, marginLeft: 3 }}>*</span>}
      </div>
      {children}
    </div>
  );
}
function ACInput({ value, placeholder, mono, prefix, suffix }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center',
      padding: '12px 14px', borderRadius: 12,
      background: AC.card, border: `1px solid ${AC.border}`,
    }}>
      {prefix && <span style={{ fontFamily: AC.fontMono, fontSize: 14, color: AC.textMute, marginRight: 8 }}>{prefix}</span>}
      <input defaultValue={value} placeholder={placeholder} style={{
        flex: 1, background: 'transparent', border: 'none', outline: 'none',
        color: value ? AC.text : AC.textMute,
        fontFamily: mono ? AC.fontMono : AC.fontBody,
        fontSize: 14, fontWeight: mono ? 500 : 400,
        fontFeatureSettings: '"tnum"',
        minWidth: 0, width: '100%',
      }}/>
      {suffix && <span style={{ fontFamily: AC.fontMono, fontSize: 12, color: AC.textMute, marginLeft: 8 }}>{suffix}</span>}
    </div>
  );
}

// ── 3. NUEVA COMPRA (cuotas) ─────────────────────────────────
function ANewPurchase() {
  return (
    <div style={{ width: '100%', height: '100%', background: AC.bg, color: AC.text, fontFamily: AC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <ACBackBar title="Nueva compra" />

        <div style={{ padding: '4px 16px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          {/* Contexto */}
          <div style={{ padding: '10px 14px', background: AC.card, border: `1px solid ${AC.border}`, borderRadius: 12, display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 26, height: 26, borderRadius: 6, background: '#009EE3', color: '#fff', fontWeight: 700, fontSize: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', letterSpacing: '0.04em' }}>MP</div>
            <div style={{ flex: 1, fontSize: 12.5, color: AC.textDim }}>en <span style={{ color: AC.text, fontWeight: 600 }}>MercadoPago</span></div>
          </div>

          <ACField label="Descripción" required>
            <ACInput placeholder="Ej. Heladera Whirlpool"/>
          </ACField>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 90px', gap: 10 }}>
            <ACField label="Monto por cuota" required>
              <ACInput prefix="$" placeholder="0" mono/>
            </ACField>
            <ACField label="Cuotas" required>
              <ACInput placeholder="12" mono suffix="x"/>
            </ACField>
          </div>

          {/* Total calculado */}
          <div style={{
            padding: '14px 16px', borderRadius: 14,
            background: AC.primarySoft, border: `1px solid ${AC.borderPaid}`,
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <div>
              <div style={{ fontSize: 10.5, color: AC.primary, fontFamily: AC.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 2 }}>Total de la compra</div>
              <div style={{ fontSize: 11, color: AC.textDim }}>se calcula automáticamente</div>
            </div>
            <div style={{ fontSize: 22, fontWeight: 600, color: AC.primaryHi, letterSpacing: '-0.02em', fontFeatureSettings: '"tnum"' }}>—</div>
          </div>

          <ACField label="Mes de la primera cuota" required>
            <div style={{
              display: 'flex', alignItems: 'center',
              padding: '12px 14px', borderRadius: 12,
              background: AC.card, border: `1px solid ${AC.border}`,
            }}>
              <span style={{ flex: 1, fontSize: 14 }}>Abril 2026</span>
              <ACIcon name="cal" size={16} color={AC.textDim}/>
            </div>
          </ACField>

          <ACField label="Notas">
            <div style={{
              padding: '12px 14px', borderRadius: 12,
              background: AC.card, border: `1px solid ${AC.border}`,
              minHeight: 70, color: AC.textMute, fontSize: 13.5,
            }}>
              Opcional. Ej. "compra en black friday"
            </div>
          </ACField>

          <button style={{
            marginTop: 6, padding: '14px 14px', borderRadius: 12,
            background: AC.primary, color: AC.primaryInk, border: 'none',
            fontFamily: AC.fontBody, fontSize: 14.5, fontWeight: 600,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            boxShadow: `0 4px 16px ${AC.primary}33`,
          }}>
            <ACIcon name="save" size={16} color={AC.primaryInk} strokeWidth={2}/> Crear compra
          </button>
        </div>
        <div style={{ height: 12 }}/>
      </div>
      <ACTabBar active="tarjetas"/>
    </div>
  );
}

// ── 4. EDITAR TARJETA ────────────────────────────────────────
function AEditCard() {
  return (
    <div style={{ width: '100%', height: '100%', background: AC.bg, color: AC.text, fontFamily: AC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <ACBackBar title="Editar tarjeta" />

        <div style={{ padding: '4px 16px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          {/* Preview de la tarjeta editada */}
          <div style={{
            padding: '14px 16px', borderRadius: 14,
            background: AC.card, border: `1px solid ${AC.border}`,
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{ width: 38, height: 38, borderRadius: 10, background: '#EB001B', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: 11 }}>MC</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600 }}>MercadoPago</div>
              <div style={{ fontSize: 11, color: AC.textMute, fontFamily: AC.fontMono }}>cierre 10 · vence 15</div>
            </div>
            <span style={{ fontSize: 9, padding: '3px 7px', borderRadius: 4, background: AC.primarySoft, color: AC.primary, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Activa</span>
          </div>

          <ACField label="Nombre" required>
            <ACInput value="MercadoPago"/>
          </ACField>

          <ACField label="Banco / emisor">
            <ACInput placeholder="Ej. Banco Galicia"/>
          </ACField>

          <ACField label="Marca">
            <div style={{
              display: 'flex', alignItems: 'center',
              padding: '12px 14px', borderRadius: 12,
              background: AC.card, border: `1px solid ${AC.border}`,
            }}>
              <div style={{ width: 22, height: 14, borderRadius: 3, background: '#EB001B', marginRight: 10, flexShrink: 0 }}/>
              <span style={{ flex: 1, fontSize: 14 }}>Mastercard</span>
              <ACIcon name="chev" size={15} color={AC.textDim}/>
            </div>
          </ACField>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <ACField label="Día cierre">
              <ACInput value="10" mono/>
            </ACField>
            <ACField label="Día vencimiento">
              <ACInput value="15" mono/>
            </ACField>
          </div>

          <ACField label="Link para pagar">
            <ACInput value="mercadopago://payments" mono/>
          </ACField>

          {/* Toggle activa */}
          <div style={{
            display: 'flex', alignItems: 'center', gap: 12,
            padding: '14px 16px', borderRadius: 14,
            background: AC.card, border: `1px solid ${AC.border}`,
          }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2 }}>Activa</div>
              <div style={{ fontSize: 11.5, color: AC.textMute }}>Aparece en Mes y Tarjetas</div>
            </div>
            <div style={{
              width: 44, height: 26, borderRadius: 999, background: AC.primary,
              position: 'relative', flexShrink: 0,
            }}>
              <div style={{ position: 'absolute', right: 3, top: 3, width: 20, height: 20, borderRadius: '50%', background: '#fff', boxShadow: '0 2px 4px rgba(0,0,0,0.3)' }}/>
            </div>
          </div>

          <button style={{
            marginTop: 6, padding: '14px', borderRadius: 12,
            background: AC.primary, color: AC.primaryInk, border: 'none',
            fontFamily: AC.fontBody, fontSize: 14.5, fontWeight: 600,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            boxShadow: `0 4px 16px ${AC.primary}33`,
          }}>
            <ACIcon name="save" size={16} color={AC.primaryInk} strokeWidth={2}/> Guardar cambios
          </button>

          <button style={{
            padding: '13px', borderRadius: 12,
            background: 'transparent', color: AC.late,
            border: `1px solid ${AC.borderLate}`,
            fontFamily: AC.fontBody, fontSize: 13.5, fontWeight: 500,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          }}>
            <ACIcon name="trash" size={15} color={AC.late}/> Eliminar tarjeta
          </button>
        </div>
        <div style={{ height: 16 }}/>
      </div>
      <ACTabBar active="tarjetas"/>
    </div>
  );
}

Object.assign(window, { ACardsList, ACardDetail, ANewPurchase, AEditCard });
