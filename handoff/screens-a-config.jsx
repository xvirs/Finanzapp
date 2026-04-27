// ─── A · FLUJO CONFIG + CUENTAS FIJAS ────────────────────────
const CC = {
  bg: '#0B0F0D', card: '#141B18', cardHi: '#192521',
  border: '#1F2A26', borderHi: '#2A3833',
  text: '#E8EDEA', textDim: '#8A9590', textMute: '#5C6661',
  primary: '#1FB87A', primaryHi: '#2DD891', primarySoft: '#0E2A1E', primaryInk: '#04130C', borderPrimary: '#1B3A2A',
  late: '#E5604A', lateSoft: '#3A1813', lateInk: '#FF8B72', borderLate: '#3A1813',
  fontBody: '"Geist", "Inter", system-ui, sans-serif',
  fontMono: '"Geist Mono", "JetBrains Mono", ui-monospace, monospace',
};

// Iconos para tipos de cuenta — glifos custom, sin emoji
function CCTypeIcon({ type, size = 22, color }) {
  const c = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: color || CC.text, strokeWidth: 1.6, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (type) {
    case 'luz':   return (<svg {...c}><path d="M9 17h6"/><path d="M10 20h4"/><path d="M8.5 14a5 5 0 1 1 7 0c-.7.6-1 1.4-1 2.3V17H9.5v-.7c0-.9-.3-1.7-1-2.3Z"/></svg>);
    case 'agua':  return (<svg {...c}><path d="M12 3.5C8.5 8 6 11.5 6 14.5a6 6 0 0 0 12 0c0-3-2.5-6.5-6-11Z"/></svg>);
    case 'gas':   return (<svg {...c}><path d="M12 3c1 3 4 4.5 4 8.5a4 4 0 1 1-8 0c0-2 1-3 1-4.5C9 9 10 11 11 11c0-2 1-5 1-8Z"/></svg>);
    case 'impuesto': return (<svg {...c}><path d="M3.5 10 12 4.5 20.5 10"/><path d="M5 10v9.5h14V10"/><path d="M3.5 19.5h17"/><path d="M8 13v4M12 13v4M16 13v4"/></svg>);
    case 'sub':   return (<svg {...c}><rect x="3" y="5" width="18" height="13" rx="2"/><path d="M9 21h6"/><path d="M12 18v3"/><path d="M9.5 11l3 1.5-3 1.5z" fill={color || CC.text}/></svg>);
    case 'salud': return (<svg {...c}><rect x="3.5" y="5.5" width="17" height="14" rx="2.5"/><path d="M12 9.5v6M9 12.5h6"/></svg>);
    case 'pin':   return (<svg {...c}><path d="M12 2.5 14 8h5l-4 3.5 1.5 5L12 13.5 7.5 16.5 9 11.5 5 8h5z"/></svg>);
    case 'otro':  return (<svg {...c}><circle cx="12" cy="12" r="8.5"/><path d="M12 8v4l2.5 2.5"/></svg>);
  }
  return null;
}

function CCBackBar({ title, right }) {
  return (
    <div style={{ padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12, color: CC.text, fontFamily: CC.fontBody }}>
      <button style={{ width: 36, height: 36, borderRadius: 10, background: 'transparent', border: `1px solid ${CC.border}`, color: CC.text, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5M11 6l-6 6 6 6"/></svg>
      </button>
      <span style={{ flex: 1, fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em' }}>{title}</span>
      {right}
    </div>
  );
}

function CCTabBar({ active = 'config' }) {
  const tabs = [
    { id: 'mes', label: 'Mes' },
    { id: 'tarjetas', label: 'Tarjetas' },
    { id: 'config', label: 'Config' },
  ];
  const icons = {
    mes: <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="3.5" y="5" width="17" height="15" rx="2.5"/><path d="M3.5 10h17"/><path d="M8 3v4M16 3v4"/></svg>,
    tarjetas: <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="2.5" y="5.5" width="19" height="13" rx="2.5"/><path d="M2.5 10h19"/><path d="M6 14.5h3"/></svg>,
    config: <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5 5l1.4 1.4M17.6 17.6 19 19M5 19l1.4-1.4M17.6 6.4 19 5"/></svg>,
  };
  return (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, borderTop: `1px solid ${CC.border}`, background: CC.bg, padding: '8px 0 12px', display: 'flex' }}>
      {tabs.map(t => {
        const on = t.id === active;
        return (
          <div key={t.id} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, color: on?CC.primary:CC.textMute }}>
            <div style={{ padding: '4px 16px', borderRadius: 10, background: on ? CC.primarySoft : 'transparent', display: 'flex' }}>
              {React.cloneElement(icons[t.id], { stroke: on ? CC.primary : CC.textMute })}
            </div>
            <span style={{ fontSize: 10.5, fontWeight: 500 }}>{t.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ── 1. CONFIGURACIÓN ─────────────────────────────────────────
function AConfig() {
  return (
    <div style={{ width: '100%', height: '100%', background: CC.bg, color: CC.text, fontFamily: CC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        {/* Header */}
        <div style={{ padding: '14px 20px 18px' }}>
          <div style={{ fontSize: 26, fontWeight: 600, letterSpacing: '-0.025em' }}>Configuración</div>
        </div>

        {/* Sesión */}
        <div style={{ padding: '0 16px 16px' }}>
          <div style={{ padding: '14px 16px', borderRadius: 14, background: CC.card, border: `1px solid ${CC.border}`, display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 38, height: 38, borderRadius: 10, background: CC.primarySoft, color: CC.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: CC.fontMono, fontSize: 14, fontWeight: 600 }}>X</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 10.5, color: CC.textMute, fontFamily: CC.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 2 }}>Sesión iniciada como</div>
              <div style={{ fontSize: 13, fontWeight: 500, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>rosales.xavier.eloy@gmail.com</div>
            </div>
          </div>
        </div>

        {/* Sección "Datos" */}
        <div style={{ padding: '0 20px 8px' }}>
          <div style={{ fontSize: 11, color: CC.textMute, fontFamily: CC.fontMono, letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 500 }}>Datos</div>
        </div>
        <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 18 }}>
          {[
            { label: 'Cuentas fijas', count: 14, icon: 'doc' },
            { label: 'Tarjetas', count: 3, icon: 'card' },
          ].map((row, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderRadius: 14, background: CC.card, border: `1px solid ${CC.border}` }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: CC.cardHi, display: 'flex', alignItems: 'center', justifyContent: 'center', color: CC.textDim }}>
                {row.icon === 'doc'
                  ? <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M6 3.5h9l4 4v13a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V4.5a1 1 0 0 1 1-1Z"/><path d="M14.5 3.5v4.5h4.5"/><path d="M8.5 13h7M8.5 17h5"/></svg>
                  : <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="2.5" y="5.5" width="19" height="13" rx="2.5"/><path d="M2.5 10h19"/><path d="M6 14.5h3"/></svg>}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14.5, fontWeight: 500 }}>{row.label}</div>
                <div style={{ fontSize: 11, color: CC.textMute, fontFamily: CC.fontMono, marginTop: 1 }}>{row.count} activas</div>
              </div>
              <button style={{ width: 32, height: 32, borderRadius: 8, background: CC.primarySoft, color: CC.primary, border: `1px solid ${CC.borderPrimary}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 5v14M5 12h14"/></svg>
              </button>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={CC.textMute} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" style={{ marginLeft: 2 }}><path d="M9 6l6 6-6 6"/></svg>
            </div>
          ))}
        </div>

        {/* Sección Seguridad */}
        <div style={{ padding: '0 20px 8px' }}>
          <div style={{ fontSize: 11, color: CC.textMute, fontFamily: CC.fontMono, letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 500 }}>Seguridad</div>
        </div>
        <div style={{ padding: '0 16px', marginBottom: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderRadius: 14, background: CC.card, border: `1px solid ${CC.border}` }}>
            <div style={{ width: 36, height: 36, borderRadius: 10, background: CC.cardHi, display: 'flex', alignItems: 'center', justifyContent: 'center', color: CC.textDim }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M12 4c-2 0-4 1-5.5 2.5"/><path d="M12 8c-1.5 0-3 .8-4 2"/><path d="M12 12v6"/><path d="M9 14v3"/><path d="M15 14v5"/><path d="M6 13v3"/><path d="M18 11v4"/></svg>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2 }}>Bloqueo biométrico</div>
              <div style={{ fontSize: 11.5, color: CC.textMute, lineHeight: 1.4 }}>Pedir Face ID / huella al abrir o volver a la app</div>
            </div>
            <div style={{ width: 44, height: 26, borderRadius: 999, background: CC.cardHi, border: `1px solid ${CC.border}`, position: 'relative', flexShrink: 0 }}>
              <div style={{ position: 'absolute', left: 3, top: 2, width: 20, height: 20, borderRadius: '50%', background: CC.textDim }}/>
            </div>
          </div>
        </div>

        {/* Cerrar sesión */}
        <div style={{ padding: '0 16px' }}>
          <button style={{
            width: '100%', padding: '14px', borderRadius: 12,
            background: 'transparent', color: CC.late,
            border: `1px solid ${CC.borderLate}`,
            fontFamily: CC.fontBody, fontSize: 14, fontWeight: 500,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          }}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M14 4.5h4a1.5 1.5 0 0 1 1.5 1.5v12a1.5 1.5 0 0 1-1.5 1.5h-4"/><path d="M10 8 14 12l-4 4"/><path d="M14 12H4.5"/></svg>
            Cerrar sesión
          </button>
        </div>

        <div style={{ padding: '20px 20px', textAlign: 'center' }}>
          <div style={{ fontSize: 10, color: CC.textMute, fontFamily: CC.fontMono, letterSpacing: '0.08em' }}>FINANZAPP · v1.4.2</div>
        </div>
      </div>
      <CCTabBar active="config"/>
    </div>
  );
}

// ── 2. LISTA DE CUENTAS FIJAS ────────────────────────────────
function AFixedAccounts() {
  const accounts = [
    { name: 'EPEC',         sub: 'Luz · Día 1',                          type: 'luz',      amount: 'Variable' },
    { name: 'Agua',         sub: 'Agua · Día 2',                         type: 'agua',     amount: 'Variable' },
    { name: 'Gas',          sub: 'Gas · Día 2',                          type: 'gas',      amount: 'Variable' },
    { name: 'Renta',        sub: 'Impuesto · Día 3',                     type: 'impuesto', amount: 'Variable' },
    { name: 'Brave VPN',    sub: 'Suscripción · Día 4',                  type: 'sub',      amount: '$14.500',  card: 'MercadoPago', cardColor: '#009EE3' },
    { name: 'Municipalidad',sub: 'Impuesto · Día 5',                     type: 'impuesto', amount: '$34.637' },
    { name: 'GEMINI',       sub: 'Suscripción · Día 5',                  type: 'sub',      amount: '$29.000',  card: 'MercadoPago', cardColor: '#009EE3' },
    { name: 'Claude',       sub: 'Suscripción · Día 5',                  type: 'sub',      amount: '$145.000', card: 'MercadoPago', cardColor: '#009EE3' },
    { name: 'OSDE',         sub: 'Salud · Día 6',                        type: 'salud',    amount: '$175.557', card: 'Galicia VISA', cardColor: '#1A1F71' },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: CC.bg, color: CC.text, fontFamily: CC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <CCBackBar
          title="Cuentas fijas"
          right={
            <button style={{ width: 36, height: 36, borderRadius: 10, background: CC.primary, color: CC.primaryInk, border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: `0 2px 10px ${CC.primary}33` }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 5v14M5 12h14"/></svg>
            </button>
          }
        />

        {/* Resumen pequeño */}
        <div style={{ padding: '0 20px 12px', display: 'flex', gap: 18, fontFamily: CC.fontMono, fontSize: 11, color: CC.textDim, letterSpacing: '0.04em' }}>
          <span><span style={{ color: CC.text, fontWeight: 600 }}>9</span> activas</span>
          <span><span style={{ color: CC.text, fontWeight: 600 }}>5</span> con monto fijo</span>
          <span><span style={{ color: CC.text, fontWeight: 600 }}>4</span> variables</span>
        </div>

        <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 6 }}>
          {accounts.map((a, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', background: CC.card, border: `1px solid ${CC.border}`, borderRadius: 12 }}>
              <div style={{
                width: 38, height: 38, borderRadius: 10,
                background: CC.cardHi, border: `1px solid ${CC.border}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: CC.text, flexShrink: 0,
              }}>
                <CCTypeIcon type={a.type} size={20} color={CC.text}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{a.name}</div>
                <div style={{ fontSize: 11, color: CC.textMute, fontFamily: CC.fontMono, display: 'flex', alignItems: 'center', gap: 6, flexWrap: 'wrap' }}>
                  <span>{a.sub}</span>
                  {a.card && (
                    <>
                      <span style={{ color: CC.textMute }}>·</span>
                      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                        <span style={{ width: 14, height: 9, borderRadius: 2, background: a.cardColor, display: 'inline-block' }}/>
                        <span style={{ color: CC.textDim }}>{a.card}</span>
                      </span>
                    </>
                  )}
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                {a.amount === 'Variable' ? (
                  <span style={{ fontSize: 11, padding: '3px 8px', borderRadius: 4, background: CC.cardHi, color: CC.textDim, fontFamily: CC.fontMono, letterSpacing: '0.04em', fontWeight: 500 }}>VARIABLE</span>
                ) : (
                  <div style={{ fontSize: 14, fontWeight: 600, fontFeatureSettings: '"tnum"' }}>{a.amount}</div>
                )}
              </div>
            </div>
          ))}
        </div>
        <div style={{ height: 12 }}/>
      </div>
      <CCTabBar active="config"/>
    </div>
  );
}

// helpers de form (re-locales para no depender de a-cards)
function CFField({ label, required, hint, children }) {
  return (
    <div>
      <div style={{ fontSize: 10.5, color: CC.textMute, marginBottom: 6, fontFamily: CC.fontMono, letterSpacing: '0.06em', textTransform: 'uppercase' }}>
        {label}{required && <span style={{ color: CC.late, marginLeft: 3 }}>*</span>}
      </div>
      {children}
      {hint && <div style={{ fontSize: 10.5, color: CC.textMute, marginTop: 5, fontStyle: 'italic' }}>{hint}</div>}
    </div>
  );
}
function CFInput({ value, placeholder, mono, prefix }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', padding: '12px 14px', borderRadius: 12, background: CC.card, border: `1px solid ${CC.border}` }}>
      {prefix && <span style={{ fontFamily: CC.fontMono, fontSize: 14, color: CC.textMute, marginRight: 8 }}>{prefix}</span>}
      <input defaultValue={value} placeholder={placeholder} style={{
        flex: 1, background: 'transparent', border: 'none', outline: 'none',
        color: value ? CC.text : CC.textMute,
        fontFamily: mono ? CC.fontMono : CC.fontBody,
        fontSize: 14, fontWeight: mono ? 500 : 400,
        fontFeatureSettings: '"tnum"', minWidth: 0, width: '100%',
      }}/>
    </div>
  );
}
function CFSelect({ value, icon }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', padding: '12px 14px', borderRadius: 12, background: CC.card, border: `1px solid ${CC.border}` }}>
      {icon && <span style={{ marginRight: 10, color: CC.text, display: 'flex' }}>{icon}</span>}
      <span style={{ flex: 1, fontSize: 14 }}>{value}</span>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={CC.textDim} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M5.5 9 12 15.5 18.5 9"/></svg>
    </div>
  );
}

// ── 3. NUEVA CUENTA FIJA ─────────────────────────────────────
function ANewFixedAccount() {
  return (
    <div style={{ width: '100%', height: '100%', background: CC.bg, color: CC.text, fontFamily: CC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <CCBackBar title="Nueva cuenta fija"/>

        <div style={{ padding: '4px 16px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <CFField label="Nombre" required>
            <CFInput placeholder="Ej. EPEC, Netflix, OSDE"/>
          </CFField>

          <CFField label="Tipo" required>
            <CFSelect value="Otro" icon={<CCTypeIcon type="otro" size={16} color={CC.textDim}/>}/>
          </CFField>

          <CFField label="Monto estimado" hint="Vacío = monto variable">
            <CFInput prefix="$" placeholder="0" mono/>
          </CFField>

          <CFField label="Día del mes" hint="1 a 31">
            <CFInput placeholder="—" mono/>
          </CFField>

          <CFField label="Débito automático en" hint="Si está seleccionada, esta cuenta no aparece como ítem en Mes (ya viene en el resumen de la tarjeta).">
            <CFSelect value="Ninguna"/>
          </CFField>

          <CFField label="Código de referencia" hint='Se copia al clipboard al tocar "Ir a pagar" en el Mes.'>
            <CFInput placeholder="0292849306" mono/>
          </CFField>

          <CFField label="Link para pagar">
            <CFInput placeholder="https://..." mono/>
          </CFField>

          <CFField label="Notas">
            <div style={{ padding: '12px 14px', borderRadius: 12, background: CC.card, border: `1px solid ${CC.border}`, minHeight: 70, color: CC.textMute, fontSize: 13.5 }}>
              Opcional
            </div>
          </CFField>

          <button style={{
            marginTop: 6, padding: '14px', borderRadius: 12,
            background: CC.primary, color: CC.primaryInk, border: 'none',
            fontFamily: CC.fontBody, fontSize: 14.5, fontWeight: 600,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            boxShadow: `0 4px 16px ${CC.primary}33`,
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={CC.primaryInk} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 4.5h12L19.5 7v12.5a1 1 0 0 1-1 1H5.5a1 1 0 0 1-1-1V5.5a1 1 0 0 1 1-1Z"/><path d="M8 4.5v5h7v-5"/><path d="M8 14h8v6H8z"/></svg>
            Crear cuenta
          </button>
        </div>
        <div style={{ height: 16 }}/>
      </div>
      <CCTabBar active="config"/>
    </div>
  );
}

// ── 4. EDITAR CUENTA ─────────────────────────────────────────
function AEditFixedAccount() {
  return (
    <div style={{ width: '100%', height: '100%', background: CC.bg, color: CC.text, fontFamily: CC.fontBody, position: 'relative', overflow: 'hidden', paddingBottom: 78 }}>
      <div style={{ height: '100%', overflowY: 'auto' }}>
        <CCBackBar title="Editar cuenta"/>

        <div style={{ padding: '4px 16px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <CFField label="Nombre" required>
            <CFInput value="EPEC"/>
          </CFField>

          <CFField label="Tipo" required>
            <CFSelect value="Luz" icon={<CCTypeIcon type="luz" size={16} color={CC.text}/>}/>
          </CFField>

          <CFField label="Monto estimado" hint="Vacío = monto variable">
            <CFInput prefix="$" placeholder="0" mono/>
          </CFField>

          <CFField label="Día del mes" hint="1 a 31">
            <CFInput value="1" mono/>
          </CFField>

          <CFField label="Débito automático en" hint="Si está seleccionada, esta cuenta no aparece como ítem en Mes.">
            <CFSelect value="Ninguna"/>
          </CFField>

          <CFField label="Código de referencia" hint='Se copia al clipboard al tocar "Ir a pagar".'>
            <CFInput value="0292849306" mono/>
          </CFField>

          <CFField label="Link para pagar">
            <CFInput value="https://www.epec.com.ar/oficina-virtual/" mono/>
          </CFField>

          <CFField label="Notas">
            <div style={{ padding: '12px 14px', borderRadius: 12, background: CC.card, border: `1px solid ${CC.border}`, minHeight: 70, color: CC.textMute, fontSize: 13.5 }}/>
          </CFField>

          {/* Toggle activa */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderRadius: 14, background: CC.card, border: `1px solid ${CC.border}` }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2 }}>Activa</div>
              <div style={{ fontSize: 11.5, color: CC.textMute }}>La cuenta aparece en Mes</div>
            </div>
            <div style={{ width: 44, height: 26, borderRadius: 999, background: CC.primary, position: 'relative', flexShrink: 0 }}>
              <div style={{ position: 'absolute', right: 3, top: 3, width: 20, height: 20, borderRadius: '50%', background: '#fff', boxShadow: '0 2px 4px rgba(0,0,0,0.3)' }}/>
            </div>
          </div>

          <button style={{
            marginTop: 6, padding: '14px', borderRadius: 12,
            background: CC.primary, color: CC.primaryInk, border: 'none',
            fontFamily: CC.fontBody, fontSize: 14.5, fontWeight: 600,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            boxShadow: `0 4px 16px ${CC.primary}33`,
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={CC.primaryInk} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 4.5h12L19.5 7v12.5a1 1 0 0 1-1 1H5.5a1 1 0 0 1-1-1V5.5a1 1 0 0 1 1-1Z"/><path d="M8 4.5v5h7v-5"/><path d="M8 14h8v6H8z"/></svg>
            Guardar
          </button>

          <button style={{
            padding: '13px', borderRadius: 12,
            background: 'transparent', color: CC.late,
            border: `1px solid ${CC.borderLate}`,
            fontFamily: CC.fontBody, fontSize: 13.5, fontWeight: 500,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          }}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={CC.late} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M4.5 7h15"/><path d="M9 7V4.5h6V7"/><path d="M6 7l1 13.5h10L18 7"/></svg>
            Eliminar cuenta
          </button>
        </div>
        <div style={{ height: 16 }}/>
      </div>
      <CCTabBar active="config"/>
    </div>
  );
}

Object.assign(window, { AConfig, AFixedAccounts, ANewFixedAccount, AEditFixedAccount });
