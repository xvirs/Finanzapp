// ─────────────────────────────────────────────────────────────
// DIRECCIÓN A — "Banco moderno premium"
// Verde profundo, tipografía display para montos (Geist), iconos
// finos custom, mucho aire. Sensación: serio, ordenado.
// ─────────────────────────────────────────────────────────────

const A = {
  // canvas
  bg:        '#0B0F0D',          // casi negro con leve verde
  surface:   '#11181500',         // transparente sobre bg
  card:      '#141B18',
  cardHi:    '#192521',
  cardPaid:  '#0E2018',
  cardLate:  '#23120F',
  border:    '#1F2A26',
  borderLate:'#3A1813',
  borderPaid:'#1B3A2A',

  // text
  text:      '#E8EDEA',
  textDim:   '#8A9590',
  textMute:  '#5C6661',

  // brand
  primary:   '#1FB87A',           // verde "savings"
  primaryHi: '#2DD891',
  primarySoft:'#0E2A1E',
  primaryInk:'#04130C',

  // states
  late:      '#E5604A',
  lateSoft:  '#3A1813',
  pendingPill:'#2A2218',
  pendingInk:'#E0B65A',

  // typography
  fontDisplay: '"Geist", "Inter", system-ui, sans-serif',
  fontBody:    '"Geist", "Inter", system-ui, sans-serif',
  fontMono:    '"Geist Mono", "JetBrains Mono", ui-monospace, monospace',
};

// Iconos de línea custom (1.6px stroke, redondeado)
function AIcon({ name, size = 20, color = 'currentColor', strokeWidth = 1.6 }) {
  const common = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: color, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'card': return (<svg {...common}><rect x="2.5" y="5.5" width="19" height="13" rx="2.5"/><path d="M2.5 10h19"/><path d="M6 14.5h3"/></svg>);
    case 'home': return (<svg {...common}><path d="M3.5 10.5 12 4l8.5 6.5"/><path d="M5.5 9.5v9.5h13V9.5"/><path d="M10 19v-5h4v5"/></svg>);
    case 'bolt': return (<svg {...common}><path d="M13.5 2.5 4.5 13.5h6L9.5 21.5l9-11h-6Z"/></svg>);
    case 'bank': return (<svg {...common}><path d="M3 10 12 4l9 6"/><path d="M5 10v8M9 10v8M15 10v8M19 10v8"/><path d="M3 19h18"/></svg>);
    case 'cal':  return (<svg {...common}><rect x="3.5" y="5" width="17" height="15" rx="2.5"/><path d="M3.5 10h17"/><path d="M8 3v4M16 3v4"/></svg>);
    case 'gear': return (<svg {...common}><circle cx="12" cy="12" r="3"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5 5l1.4 1.4M17.6 17.6 19 19M5 19l1.4-1.4M17.6 6.4 19 5"/></svg>);
    case 'check':return (<svg {...common}><path d="M4.5 12.5 9.5 17.5 19.5 7.5"/></svg>);
    case 'chevR':return (<svg {...common}><path d="M9 5.5 15.5 12 9 18.5"/></svg>);
    case 'chevL':return (<svg {...common}><path d="M15 5.5 8.5 12 15 18.5"/></svg>);
    case 'chevD':return (<svg {...common}><path d="M5.5 9 12 15.5 18.5 9"/></svg>);
    case 'chevU':return (<svg {...common}><path d="M5.5 15 12 8.5 18.5 15"/></svg>);
    case 'ext':  return (<svg {...common}><path d="M14 4.5h5.5V10"/><path d="M19.5 4.5 12 12"/><path d="M19.5 14v4a2 2 0 0 1-2 2h-12a2 2 0 0 1-2-2v-12a2 2 0 0 1 2-2h4"/></svg>);
    case 'plus': return (<svg {...common}><path d="M12 5v14M5 12h14"/></svg>);
    case 'goog': return (<svg viewBox="0 0 24 24" width={size} height={size}><path fill="#4285F4" d="M22.5 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.76h3.56c2.08-1.92 3.22-4.74 3.22-8.09Z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.56-2.76c-.99.66-2.25 1.05-3.72 1.05-2.86 0-5.29-1.93-6.15-4.53H2.18v2.84A11 11 0 0 0 12 23Z"/><path fill="#FBBC05" d="M5.85 14.1A6.6 6.6 0 0 1 5.5 12c0-.73.13-1.43.35-2.1V7.06H2.18A11 11 0 0 0 1 12c0 1.78.43 3.46 1.18 4.94l3.67-2.84Z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.46 2.13 14.97 1 12 1A11 11 0 0 0 2.18 7.06l3.67 2.84C6.71 7.31 9.14 5.38 12 5.38Z"/></svg>);
  }
  return null;
}

// ─── Common parts ─────────────────────────────────────────────
function ATopMonth({ paged = '8/10', onlyPending = false }) {
  return (
    <div style={{ padding: '10px 20px 14px' }}>
      <div style={{ color: A.textMute, fontSize: 11, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 10, fontFamily: A.fontMono }}>Mes actual</div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
        <button style={{ background: 'transparent', border: 'none', color: A.textDim, padding: 4, display: 'flex' }}><AIcon name="chevL" size={20} /></button>
        <div style={{ fontSize: 19, fontWeight: 600, letterSpacing: '-0.01em' }}>Abril 2026</div>
        <button style={{ background: 'transparent', border: 'none', color: A.textDim, padding: 4, display: 'flex' }}><AIcon name="chevR" size={20} /></button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <div style={{ background: A.card, border: `1px solid ${A.border}`, borderRadius: 14, padding: '12px 14px' }}>
          <div style={{ color: A.textMute, fontSize: 10.5, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 6, fontFamily: A.fontMono }}>Estimado</div>
          <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em', fontFeatureSettings: '"tnum"' }}>$1.308.402</div>
        </div>
        <div style={{ background: A.cardPaid, border: `1px solid ${A.borderPaid}`, borderRadius: 14, padding: '12px 14px' }}>
          <div style={{ color: A.primary, fontSize: 10.5, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 6, fontFamily: A.fontMono, opacity: 0.85 }}>Pagado</div>
          <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em', color: A.primaryHi, fontFeatureSettings: '"tnum"' }}>$1.629.560</div>
          <div style={{ color: A.textMute, fontSize: 11, marginTop: 2 }}>falta $0</div>
        </div>
      </div>

      {/* progress bar */}
      <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
            <span style={{ fontSize: 11.5, color: A.textDim, fontFamily: A.fontMono }}>{paged} pagadas</span>
            <span style={{ fontSize: 11.5, color: A.textMute, fontFamily: A.fontMono }}>80%</span>
          </div>
          <div style={{ height: 4, background: A.card, borderRadius: 2, overflow: 'hidden' }}>
            <div style={{ width: '80%', height: '100%', background: `linear-gradient(90deg, ${A.primary}, ${A.primaryHi})`, borderRadius: 2 }}/>
          </div>
        </div>
      </div>

      <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', gap: 6 }}>
          {['Todos','Pendientes','Atrasadas'].map((t,i)=>(
            <span key={t} style={{
              padding: '5px 11px', borderRadius: 999, fontSize: 11.5,
              background: i===0 ? A.primarySoft : 'transparent',
              border: `1px solid ${i===0?A.borderPaid:A.border}`,
              color: i===0?A.primary:A.textDim, fontWeight: i===0?500:400,
            }}>{t}</span>
          ))}
        </div>
      </div>
    </div>
  );
}

function ACategoryHeader({ icon, title, count, total }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 20px 8px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: A.textDim }}>
        <AIcon name={icon} size={14} color={A.textDim} />
        <span style={{ fontSize: 11, letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 500, fontFamily: A.fontMono }}>{title}</span>
        <span style={{ color: A.textMute, fontSize: 11, fontFamily: A.fontMono }}>· {count}</span>
      </div>
      <div style={{ fontSize: 12, color: A.textMute, fontFeatureSettings: '"tnum"', fontFamily: A.fontMono }}>{total}</div>
    </div>
  );
}

function APayItem({ name, sub, amount, status = 'paid', brand, expanded = false, children }) {
  const isPaid = status === 'paid';
  const isLate = status === 'late';
  const isPending = status === 'pending';

  const cardBg = isPaid ? A.cardPaid : isLate ? A.cardLate : A.card;
  const cardBorder = isPaid ? A.borderPaid : isLate ? A.borderLate : A.border;

  const leadBg = isPaid ? A.primary : isLate ? A.late : A.cardHi;
  const leadInk = isPaid ? A.primaryInk : isLate ? '#fff' : A.textDim;

  return (
    <div style={{ margin: '0 16px 8px', background: cardBg, border: `1px solid ${cardBorder}`, borderRadius: 14, overflow: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'center', padding: '12px 14px', gap: 12 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 11, background: leadBg, color: leadInk,
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 600, fontSize: 14,
          flexShrink: 0,
        }}>
          {isPaid ? <AIcon name="check" size={18} color={leadInk} strokeWidth={2.2}/> : isLate ? '!' : '·'}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ fontSize: 14.5, fontWeight: 500, letterSpacing: '-0.005em' }}>{name}</span>
            {brand && (
              <span style={{ fontSize: 9, padding: '2px 6px', borderRadius: 4, background: brand.bg, color: brand.fg, fontWeight: 700, letterSpacing: '0.04em' }}>{brand.label}</span>
            )}
            {isLate && (
              <span style={{ fontSize: 9, padding: '2px 7px', borderRadius: 4, background: A.lateSoft, color: A.late, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Atrasada</span>
            )}
          </div>
          <div style={{ fontSize: 11.5, color: A.textMute, marginTop: 2, fontFamily: A.fontMono }}>{sub}</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 10, color: isPaid?A.primary:A.textMute, letterSpacing: '0.06em', textTransform: 'uppercase', fontFamily: A.fontMono, marginBottom: 2 }}>
            {isPaid ? 'Pagado' : isLate ? 'Estimado' : 'A pagar'}
          </div>
          <div style={{ fontSize: 15, fontWeight: 600, color: isPaid?A.text:A.text, fontFeatureSettings: '"tnum"', letterSpacing: '-0.01em' }}>
            {isLate && amount === 'Variable' ? <span style={{ color: A.textDim, fontWeight: 500 }}>Variable</span> : amount}
          </div>
        </div>
        <AIcon name={expanded?'chevU':'chevD'} size={16} color={A.textMute} />
      </div>
      {expanded && children && (
        <div style={{ borderTop: `1px solid ${cardBorder}`, padding: '14px' }}>
          {children}
        </div>
      )}
    </div>
  );
}

function ATabBar({ active = 'mes' }) {
  const tabs = [
    { id: 'mes', label: 'Mes', icon: 'cal' },
    { id: 'tarjetas', label: 'Tarjetas', icon: 'card' },
    { id: 'config', label: 'Config', icon: 'gear' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      borderTop: `1px solid ${A.border}`, background: A.bg,
      padding: '8px 0 12px', display: 'flex',
    }}>
      {tabs.map(t => {
        const on = t.id === active;
        return (
          <div key={t.id} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, color: on?A.primary:A.textMute }}>
            <div style={{
              padding: '4px 16px', borderRadius: 10,
              background: on ? A.primarySoft : 'transparent',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <AIcon name={t.icon} size={20} color={on?A.primary:A.textMute} />
            </div>
            <span style={{ fontSize: 10.5, fontWeight: 500, letterSpacing: '0.02em' }}>{t.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ─── A · LOGIN ────────────────────────────────────────────────
function ALogin() {
  return (
    <div style={{ width: '100%', height: '100%', background: A.bg, color: A.text, fontFamily: A.fontBody, display: 'flex', flexDirection: 'column', position: 'relative' }}>
      {/* subtle radial glow */}
      <div style={{ position: 'absolute', top: '-20%', left: '50%', transform: 'translateX(-50%)', width: 480, height: 480, background: `radial-gradient(circle, ${A.primary}22, transparent 60%)`, pointerEvents: 'none' }}/>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '0 28px', position: 'relative' }}>
        {/* Logo mark */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 28 }}>
          <FzLogo size={64} bg={A.primary} fg={A.primaryInk} shadow/>
        </div>

        <div style={{ textAlign: 'center', marginBottom: 44 }}>
          <div style={{ fontSize: 30, fontWeight: 600, letterSpacing: '-0.025em', marginBottom: 8 }}>Finanzapp</div>
          <div style={{ fontSize: 14, color: A.textDim, lineHeight: 1.5, maxWidth: 260, margin: '0 auto' }}>Tus pagos del mes, ordenados.</div>
        </div>

        {/* Google primary */}
        <button style={{
          width: '100%', padding: '14px 16px', borderRadius: 14,
          background: '#fff', border: 'none', color: '#1F1F1F',
          fontSize: 14.5, fontWeight: 500, fontFamily: A.fontBody,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, marginBottom: 10,
        }}>
          <AIcon name="goog" size={18} />
          Continuar con Google
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '14px 0', color: A.textMute }}>
          <div style={{ flex: 1, height: 1, background: A.border }}/>
          <span style={{ fontSize: 11, fontFamily: A.fontMono, letterSpacing: '0.1em', textTransform: 'uppercase' }}>o por email</span>
          <div style={{ flex: 1, height: 1, background: A.border }}/>
        </div>

        <div style={{ position: 'relative', marginBottom: 10 }}>
          <div style={{ position: 'absolute', left: 14, top: -6, background: A.bg, padding: '0 6px', fontSize: 10.5, color: A.textMute, fontFamily: A.fontMono, letterSpacing: '0.05em', textTransform: 'uppercase' }}>Email</div>
          <input placeholder="tu@email.com" style={{
            width: '100%', padding: '14px 16px', borderRadius: 14,
            background: A.card, border: `1px solid ${A.border}`,
            color: A.text, fontSize: 14, fontFamily: A.fontBody, outline: 'none',
            boxSizing: 'border-box',
          }}/>
        </div>

        <button style={{
          width: '100%', padding: '14px 16px', borderRadius: 14,
          background: A.primary, color: A.primaryInk, border: 'none',
          fontSize: 14.5, fontWeight: 600, fontFamily: A.fontBody,
          letterSpacing: '-0.005em',
          boxShadow: `0 4px 20px ${A.primary}33`,
        }}>
          Enviarme el link →
        </button>

        <div style={{ textAlign: 'center', marginTop: 28, fontSize: 11.5, color: A.textMute, fontFamily: A.fontMono, letterSpacing: '0.04em' }}>
          v2.0 · finanzapp.app
        </div>
      </div>
    </div>
  );
}

// ─── A · HOME ─────────────────────────────────────────────────
function AHome() {
  return (
    <div style={{ width: '100%', height: '100%', background: A.bg, color: A.text, fontFamily: A.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <ATopMonth paged="8/10" />

        <ACategoryHeader icon="card" title="Tarjetas" count={2} total="$410.953" />
        <APayItem name="Galicia VISA" sub="1 débito aut." amount="$187.557" status="paid" brand={{label:'VISA', bg:'#1A1F71', fg:'#fff'}}/>
        <APayItem name="MercadoPago" sub="7 débitos aut." amount="$245.396" status="paid" brand={{label:'MC', bg:'#EB001B', fg:'#fff'}}/>

        <ACategoryHeader icon="home" title="Vivienda" count={2} total="$795.567" />
        <APayItem name="Alquiler" sub="Vence el 5" amount="$795.567" status="paid"/>
        <APayItem name="Expensas" sub="Vence el 10" amount="$144.740" status="paid"/>

        <ACategoryHeader icon="bolt" title="Servicios" count={3} total="—" />
        <APayItem name="EPEC" sub="Ref · 0292849306" amount="Variable" status="late"/>
        <APayItem name="Agua" sub="Ref · 755013" amount="Variable" status="late"/>
        <APayItem name="Gas" sub="Ref · 22052249" amount="$14.418" status="paid"/>

        <ACategoryHeader icon="bank" title="Impuestos" count={3} total="—" />
        <APayItem name="Renta" sub="Ref · 110141966502" amount="Variable" status="late"/>
        <div style={{ height: 12 }}/>
      </div>

      <ATabBar active="mes"/>
    </div>
  );
}

// ─── A · HOME EXPANDED ────────────────────────────────────────
function AHomeExpanded() {
  return (
    <div style={{ width: '100%', height: '100%', background: A.bg, color: A.text, fontFamily: A.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <ATopMonth paged="7/10" />

        <ACategoryHeader icon="bolt" title="Servicios" count={3} total="—" />

        <APayItem name="EPEC" sub="Ref · 0292849306" amount="Variable" status="late" expanded>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: 10 }}>
            <button style={{
              padding: '12px 14px', borderRadius: 12,
              background: A.cardHi, border: `1px solid ${A.border}`, color: A.text,
              fontSize: 13.5, fontWeight: 500, fontFamily: A.fontBody,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            }}>
              <AIcon name="ext" size={15}/> Ir a pagar · copiar código
            </button>

            <div>
              <div style={{ fontSize: 10.5, color: A.textMute, marginBottom: 6, fontFamily: A.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Monto pagado (ARS)</div>
              <div style={{
                padding: '12px 14px', borderRadius: 12,
                background: A.bg, border: `1px solid ${A.border}`,
                fontSize: 16, fontWeight: 600, fontFamily: A.fontMono, color: A.textDim,
                fontFeatureSettings: '"tnum"',
              }}>$ 0</div>
            </div>

            <button style={{
              padding: '13px 14px', borderRadius: 12,
              background: A.primary, color: A.primaryInk, border: 'none',
              fontSize: 14, fontWeight: 600, fontFamily: A.fontBody,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              boxShadow: `0 4px 16px ${A.primary}30`,
            }}>
              <AIcon name="check" size={16} color={A.primaryInk} strokeWidth={2.4}/> Marcar como pagado
            </button>
          </div>
        </APayItem>

        <APayItem name="Agua" sub="Ref · 755013" amount="Variable" status="late"/>
        <APayItem name="Gas" sub="Ref · 22052249" amount="$14.418" status="paid"/>

        <ACategoryHeader icon="bank" title="Impuestos" count={3} total="—" />
        <APayItem name="Municipalidad" sub="Ref · 031902403800123" amount="$34.637" status="paid"/>
        <div style={{ height: 12 }}/>
      </div>

      <ATabBar active="mes"/>
    </div>
  );
}

Object.assign(window, { ALogin, AHome, AHomeExpanded });
