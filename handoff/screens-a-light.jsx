// ─────────────────────────────────────────────────────────────
// DIRECCIÓN A — modo CLARO
// Misma identidad: verde savings, Geist, iconos finos. Aire limpio.
// ─────────────────────────────────────────────────────────────

const AL = {
  bg:        '#F6F5F1',          // off-white cálido (no blanco puro)
  bgAlt:     '#FBFAF7',
  card:      '#FFFFFF',
  cardHi:    '#F0EFEA',
  cardPaid:  '#EBF5EE',
  cardLate:  '#FBECE7',
  border:    '#E6E4DC',
  borderHi:  '#D8D5CB',
  borderPaid:'#C6E4CD',
  borderLate:'#F1C8BD',

  text:      '#0F1410',
  textDim:   '#5C6A63',
  textMute:  '#8A958E',

  primary:   '#0E8F5A',           // verde un poco más profundo para contraste sobre claro
  primaryHi: '#0B7A4C',
  primarySoft:'#DDF1E5',
  primaryInk:'#FFFFFF',

  late:      '#C73E20',
  lateSoft:  '#FBECE7',
  pendingInk:'#996A12',
  pendingSoft:'#FBF1D9',

  fontDisplay: '"Geist", "Inter", system-ui, sans-serif',
  fontBody:    '"Geist", "Inter", system-ui, sans-serif',
  fontMono:    '"Geist Mono", "JetBrains Mono", ui-monospace, monospace',
};

function ALIcon({ name, size = 20, color = 'currentColor', strokeWidth = 1.6 }) {
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
    case 'goog': return (<svg viewBox="0 0 24 24" width={size} height={size}><path fill="#4285F4" d="M22.5 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.76h3.56c2.08-1.92 3.22-4.74 3.22-8.09Z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.56-2.76c-.99.66-2.25 1.05-3.72 1.05-2.86 0-5.29-1.93-6.15-4.53H2.18v2.84A11 11 0 0 0 12 23Z"/><path fill="#FBBC05" d="M5.85 14.1A6.6 6.6 0 0 1 5.5 12c0-.73.13-1.43.35-2.1V7.06H2.18A11 11 0 0 0 1 12c0 1.78.43 3.46 1.18 4.94l3.67-2.84Z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.46 2.13 14.97 1 12 1A11 11 0 0 0 2.18 7.06l3.67 2.84C6.71 7.31 9.14 5.38 12 5.38Z"/></svg>);
  }
  return null;
}

function ALTopMonth({ paged = '8/10' }) {
  return (
    <div style={{ padding: '10px 20px 14px' }}>
      <div style={{ color: AL.textMute, fontSize: 11, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 10, fontFamily: AL.fontMono }}>Mes actual</div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
        <button style={{ background: 'transparent', border: 'none', color: AL.textDim, padding: 4, display: 'flex' }}><ALIcon name="chevL" size={20}/></button>
        <div style={{ fontSize: 19, fontWeight: 600, letterSpacing: '-0.01em', color: AL.text }}>Abril 2026</div>
        <button style={{ background: 'transparent', border: 'none', color: AL.textDim, padding: 4, display: 'flex' }}><ALIcon name="chevR" size={20}/></button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <div style={{ background: AL.card, border: `1px solid ${AL.border}`, borderRadius: 14, padding: '12px 14px' }}>
          <div style={{ color: AL.textMute, fontSize: 10.5, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 6, fontFamily: AL.fontMono }}>Estimado</div>
          <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em', fontFeatureSettings: '"tnum"', color: AL.text }}>$1.308.402</div>
        </div>
        <div style={{ background: AL.cardPaid, border: `1px solid ${AL.borderPaid}`, borderRadius: 14, padding: '12px 14px' }}>
          <div style={{ color: AL.primary, fontSize: 10.5, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 6, fontFamily: AL.fontMono }}>Pagado</div>
          <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em', color: AL.primary, fontFeatureSettings: '"tnum"' }}>$1.629.560</div>
          <div style={{ color: AL.textMute, fontSize: 11, marginTop: 2 }}>falta $0</div>
        </div>
      </div>

      <div style={{ marginTop: 14 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
          <span style={{ fontSize: 11.5, color: AL.textDim, fontFamily: AL.fontMono }}>{paged} pagadas</span>
          <span style={{ fontSize: 11.5, color: AL.textMute, fontFamily: AL.fontMono }}>80%</span>
        </div>
        <div style={{ height: 4, background: AL.cardHi, borderRadius: 2, overflow: 'hidden' }}>
          <div style={{ width: '80%', height: '100%', background: `linear-gradient(90deg, ${AL.primary}, ${AL.primaryHi})`, borderRadius: 2 }}/>
        </div>
      </div>

      <div style={{ marginTop: 14, display: 'flex', gap: 6 }}>
        {['Todos','Pendientes','Atrasadas'].map((t,i)=>(
          <span key={t} style={{
            padding: '5px 11px', borderRadius: 999, fontSize: 11.5,
            background: i===0 ? AL.primarySoft : 'transparent',
            border: `1px solid ${i===0?AL.borderPaid:AL.border}`,
            color: i===0?AL.primary:AL.textDim, fontWeight: i===0?500:400,
          }}>{t}</span>
        ))}
      </div>
    </div>
  );
}

function ALCategoryHeader({ icon, title, count, total }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 20px 8px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: AL.textDim }}>
        <ALIcon name={icon} size={14} color={AL.textDim}/>
        <span style={{ fontSize: 11, letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 500, fontFamily: AL.fontMono }}>{title}</span>
        <span style={{ color: AL.textMute, fontSize: 11, fontFamily: AL.fontMono }}>· {count}</span>
      </div>
      <div style={{ fontSize: 12, color: AL.textMute, fontFeatureSettings: '"tnum"', fontFamily: AL.fontMono }}>{total}</div>
    </div>
  );
}

function ALPayItem({ name, sub, amount, status = 'paid', brand, expanded = false, children }) {
  const isPaid = status === 'paid';
  const isLate = status === 'late';

  const cardBg = isPaid ? AL.cardPaid : isLate ? AL.cardLate : AL.card;
  const cardBorder = isPaid ? AL.borderPaid : isLate ? AL.borderLate : AL.border;

  const leadBg = isPaid ? AL.primary : isLate ? AL.late : AL.cardHi;
  const leadInk = isPaid ? '#fff' : isLate ? '#fff' : AL.textDim;

  return (
    <div style={{ margin: '0 16px 8px', background: cardBg, border: `1px solid ${cardBorder}`, borderRadius: 14, overflow: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'center', padding: '12px 14px', gap: 12 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 11, background: leadBg, color: leadInk,
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 600, fontSize: 14,
          flexShrink: 0,
        }}>
          {isPaid ? <ALIcon name="check" size={18} color={leadInk} strokeWidth={2.4}/> : isLate ? '!' : '·'}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ fontSize: 14.5, fontWeight: 500, letterSpacing: '-0.005em', color: AL.text }}>{name}</span>
            {brand && (
              <span style={{ fontSize: 9, padding: '2px 6px', borderRadius: 4, background: brand.bg, color: brand.fg, fontWeight: 700, letterSpacing: '0.04em' }}>{brand.label}</span>
            )}
            {isLate && (
              <span style={{ fontSize: 9, padding: '2px 7px', borderRadius: 4, background: '#F8DAD1', color: AL.late, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Atrasada</span>
            )}
          </div>
          <div style={{ fontSize: 11.5, color: AL.textMute, marginTop: 2, fontFamily: AL.fontMono }}>{sub}</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 10, color: isPaid?AL.primary:AL.textMute, letterSpacing: '0.06em', textTransform: 'uppercase', fontFamily: AL.fontMono, marginBottom: 2 }}>
            {isPaid ? 'Pagado' : isLate ? 'Estimado' : 'A pagar'}
          </div>
          <div style={{ fontSize: 15, fontWeight: 600, color: AL.text, fontFeatureSettings: '"tnum"', letterSpacing: '-0.01em' }}>
            {isLate && amount === 'Variable' ? <span style={{ color: AL.textDim, fontWeight: 500 }}>Variable</span> : amount}
          </div>
        </div>
        <ALIcon name={expanded?'chevU':'chevD'} size={16} color={AL.textMute}/>
      </div>
      {expanded && children && (
        <div style={{ borderTop: `1px solid ${cardBorder}`, padding: '14px', background: AL.bgAlt }}>
          {children}
        </div>
      )}
    </div>
  );
}

function ALTabBar({ active = 'mes' }) {
  const tabs = [
    { id: 'mes', label: 'Mes', icon: 'cal' },
    { id: 'tarjetas', label: 'Tarjetas', icon: 'card' },
    { id: 'config', label: 'Config', icon: 'gear' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      borderTop: `1px solid ${AL.border}`, background: AL.bg,
      padding: '8px 0 12px', display: 'flex',
    }}>
      {tabs.map(t => {
        const on = t.id === active;
        return (
          <div key={t.id} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, color: on?AL.primary:AL.textMute }}>
            <div style={{ padding: '4px 16px', borderRadius: 10, background: on ? AL.primarySoft : 'transparent', display: 'flex' }}>
              <ALIcon name={t.icon} size={20} color={on?AL.primary:AL.textMute}/>
            </div>
            <span style={{ fontSize: 10.5, fontWeight: 500 }}>{t.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ─── A LIGHT · LOGIN ──────────────────────────────────────────
function ALLogin() {
  return (
    <div style={{ width: '100%', height: '100%', background: AL.bg, color: AL.text, fontFamily: AL.fontBody, display: 'flex', flexDirection: 'column', position: 'relative' }}>
      <div style={{ position: 'absolute', top: '-15%', left: '50%', transform: 'translateX(-50%)', width: 480, height: 480, background: `radial-gradient(circle, ${AL.primary}15, transparent 60%)`, pointerEvents: 'none' }}/>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '0 28px', position: 'relative' }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 28 }}>
          <FzLogo size={64} bg={AL.primary} fg="#FFFFFF" shadow/>
        </div>

        <div style={{ textAlign: 'center', marginBottom: 44 }}>
          <div style={{ fontSize: 30, fontWeight: 600, letterSpacing: '-0.025em', marginBottom: 8 }}>Finanzapp</div>
          <div style={{ fontSize: 14, color: AL.textDim, lineHeight: 1.5, maxWidth: 260, margin: '0 auto' }}>Tus pagos del mes, ordenados.</div>
        </div>

        <button style={{
          width: '100%', padding: '14px 16px', borderRadius: 14,
          background: AL.text, border: 'none', color: '#fff',
          fontSize: 14.5, fontWeight: 500, fontFamily: AL.fontBody,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, marginBottom: 10,
        }}>
          <ALIcon name="goog" size={18}/>
          Continuar con Google
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '14px 0', color: AL.textMute }}>
          <div style={{ flex: 1, height: 1, background: AL.border }}/>
          <span style={{ fontSize: 11, fontFamily: AL.fontMono, letterSpacing: '0.1em', textTransform: 'uppercase' }}>o por email</span>
          <div style={{ flex: 1, height: 1, background: AL.border }}/>
        </div>

        <div style={{ position: 'relative', marginBottom: 10 }}>
          <div style={{ position: 'absolute', left: 14, top: -6, background: AL.bg, padding: '0 6px', fontSize: 10.5, color: AL.textMute, fontFamily: AL.fontMono, letterSpacing: '0.05em', textTransform: 'uppercase' }}>Email</div>
          <input placeholder="tu@email.com" style={{
            width: '100%', padding: '14px 16px', borderRadius: 14,
            background: AL.card, border: `1px solid ${AL.border}`,
            color: AL.text, fontSize: 14, fontFamily: AL.fontBody, outline: 'none',
            boxSizing: 'border-box',
          }}/>
        </div>

        <button style={{
          width: '100%', padding: '14px 16px', borderRadius: 14,
          background: AL.primary, color: '#fff', border: 'none',
          fontSize: 14.5, fontWeight: 600, fontFamily: AL.fontBody,
          letterSpacing: '-0.005em', boxShadow: `0 4px 16px ${AL.primary}33`,
        }}>
          Enviarme el link →
        </button>

        <div style={{ textAlign: 'center', marginTop: 28, fontSize: 11.5, color: AL.textMute, fontFamily: AL.fontMono, letterSpacing: '0.04em' }}>
          v2.0 · finanzapp.app
        </div>
      </div>
    </div>
  );
}

// ─── A LIGHT · HOME ───────────────────────────────────────────
function ALHome() {
  return (
    <div style={{ width: '100%', height: '100%', background: AL.bg, color: AL.text, fontFamily: AL.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <ALTopMonth paged="8/10"/>
        <ALCategoryHeader icon="card" title="Tarjetas" count={2} total="$410.953"/>
        <ALPayItem name="Galicia VISA" sub="1 débito aut." amount="$187.557" status="paid" brand={{label:'VISA', bg:'#1A1F71', fg:'#fff'}}/>
        <ALPayItem name="MercadoPago" sub="7 débitos aut." amount="$245.396" status="paid" brand={{label:'MC', bg:'#EB001B', fg:'#fff'}}/>

        <ALCategoryHeader icon="home" title="Vivienda" count={2} total="$795.567"/>
        <ALPayItem name="Alquiler" sub="Vence el 5" amount="$795.567" status="paid"/>
        <ALPayItem name="Expensas" sub="Vence el 10" amount="$144.740" status="paid"/>

        <ALCategoryHeader icon="bolt" title="Servicios" count={3} total="—"/>
        <ALPayItem name="EPEC" sub="Ref · 0292849306" amount="Variable" status="late"/>
        <ALPayItem name="Agua" sub="Ref · 755013" amount="Variable" status="late"/>
        <ALPayItem name="Gas" sub="Ref · 22052249" amount="$14.418" status="paid"/>

        <ALCategoryHeader icon="bank" title="Impuestos" count={3} total="—"/>
        <ALPayItem name="Renta" sub="Ref · 110141966502" amount="Variable" status="late"/>
        <div style={{ height: 12 }}/>
      </div>
      <ALTabBar active="mes"/>
    </div>
  );
}

// ─── A LIGHT · HOME EXPANDED ──────────────────────────────────
function ALHomeExpanded() {
  return (
    <div style={{ width: '100%', height: '100%', background: AL.bg, color: AL.text, fontFamily: AL.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <ALTopMonth paged="7/10"/>
        <ALCategoryHeader icon="bolt" title="Servicios" count={3} total="—"/>

        <ALPayItem name="EPEC" sub="Ref · 0292849306" amount="Variable" status="late" expanded>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <button style={{
              padding: '12px 14px', borderRadius: 12,
              background: AL.card, border: `1px solid ${AL.border}`, color: AL.text,
              fontSize: 13.5, fontWeight: 500, fontFamily: AL.fontBody,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            }}>
              <ALIcon name="ext" size={15}/> Ir a pagar · copiar código
            </button>

            <div>
              <div style={{ fontSize: 10.5, color: AL.textMute, marginBottom: 6, fontFamily: AL.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Monto pagado (ARS)</div>
              <div style={{
                padding: '12px 14px', borderRadius: 12,
                background: AL.card, border: `1px solid ${AL.border}`,
                fontSize: 16, fontWeight: 600, fontFamily: AL.fontMono, color: AL.textDim,
                fontFeatureSettings: '"tnum"',
              }}>$ 0</div>
            </div>

            <button style={{
              padding: '13px 14px', borderRadius: 12,
              background: AL.primary, color: '#fff', border: 'none',
              fontSize: 14, fontWeight: 600, fontFamily: AL.fontBody,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              boxShadow: `0 4px 14px ${AL.primary}30`,
            }}>
              <ALIcon name="check" size={16} color="#fff" strokeWidth={2.4}/> Marcar como pagado
            </button>
          </div>
        </ALPayItem>

        <ALPayItem name="Agua" sub="Ref · 755013" amount="Variable" status="late"/>
        <ALPayItem name="Gas" sub="Ref · 22052249" amount="$14.418" status="paid"/>

        <ALCategoryHeader icon="bank" title="Impuestos" count={3} total="—"/>
        <ALPayItem name="Municipalidad" sub="Ref · 031902403800123" amount="$34.637" status="paid"/>
        <div style={{ height: 12 }}/>
      </div>
      <ALTabBar active="mes"/>
    </div>
  );
}

Object.assign(window, { ALLogin, ALHome, ALHomeExpanded });
