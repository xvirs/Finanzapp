# Pantallas — Especificación detallada

> Cada pantalla tiene una sección con: **propósito**, **layout** (de arriba a abajo), **estados**, **interacciones**, **referencias al código** (archivo JSX en `screens/` que es la fuente de verdad pixel-perfect) y **widgets Flutter sugeridos**.
>
> Mockups vivos: abrir `_grid.html` en un navegador local para ver las 14 pantallas en grilla, o `_single.html?s=<id>` para una pantalla aislada.

---

## 0 · Bottom navigation (siempre visible)

3 tabs fijos: **Mes** (calendar), **Tarjetas** (card), **Config** (gear). Tab activo: pill `primarySoft` con icono y label en `primary`.

`Widget`: `FzBottomNav(index, onChange)` (en `lib/design/widgets.dart`).

---

## 1 · Login

**JSX**: `screens-a.jsx > ALogin`

**Propósito**: punto de entrada. Login con Google primario o magic link por email.

**Layout** (top → bottom, todo centrado vertical):
1. Halo radial verde sutil arriba (`radial-gradient` 480 px desde el primary @22% alpha).
2. **Logo `FzLogo`** 64 px con shadow.
3. **Título** "Finanzapp" — `display` 30 px.
4. **Subtítulo** "Tus pagos del mes, ordenados." — `bodyL` `textDim`.
5. **Botón Google** — fondo `#FFFFFF`, ícono Google color (vendor logo), texto `#1F1F1F`.
6. **Divider** "o por email" — caplabel mono entre dos líneas `border`.
7. **Input email** con label flotante "EMAIL" en mono mute (overlap del top border).
8. **Botón primary** "Enviarme el link →".
9. **Footer** mono mute: `v2.0 · finanzapp.app`.

**Estados**:
- Email vacío → CTA disabled (alpha 60%).
- Submit → loading spinner reemplazando el "→".
- Error → texto rojo debajo del input.

**Interacciones**:
- Tap Google → flujo OAuth nativo (Firebase Auth).
- Submit email → POST + toast "Te mandamos un link a {email}".

---

## 2 · Mes (Home)

**JSX**: `screens-a.jsx > AHome`

**Propósito**: pantalla principal. Vista del mes actual con resumen, progreso y categorías colapsables.

**Layout**:
1. Caplabel "MES ACTUAL" + selector de mes con flechas (`< Abril 2026 >`).
2. **Dos cards en grid 2-col**:
   - "ESTIMADO" → monto en `text`.
   - "PAGADO" → monto en `primaryHi`, sub "falta $0".
3. **Progress bar segmentada**: 8/10 pagadas, 80% — barra `primary` sobre track `cardHi`, label izquierda mono "8/10 pagadas", label derecha mono "80%".
4. **Filter tabs** (segmented): "Todos" / "Pendientes" / "Atrasadas" — pill activa con bg `primarySoft`.
5. **Categorías** (collapsibles), cada una con header sticky:
   - **Tarjetas** — total de la categoría a la derecha. Items: una card por tarjeta con icono check verde si pagada, número rojo si atrasada, badge de marca (VISA/MC/MP), monto y "PAGADO"/"VENCE DÍA X".
   - **Vivienda** — alquiler, expensas, ABL, etc.
   - **Servicios** — luz, agua, gas, internet, etc.
   - **Suscripciones** — Netflix, Spotify, etc.
6. **Bottom nav** ("Mes" activo).

**Estados de ítem**:
- ✅ Pagado: `cardPaid` bg, `borderPaid`, ícono check verde, monto `primaryHi`, label "PAGADO" mono.
- ❗ Atrasada: `cardLate` bg, `borderLate`, ícono número del día rojo, badge "ATRASADA" mono `lateInk`.
- 🟡 Pendiente: `card` bg, ícono número del día neutro, label "VENCE DÍA X".
- ⚪ Sin cargos (tarjetas sólo): monto `$0` en `textDim`.

**Interacciones**:
- Tap en ítem → expande in-place (ver pantalla 3).
- Tap categoría header → colapsa/expande sección.
- Tap selector mes → bottom sheet de selección.
- Tap filter tab → filtra la lista.

---

## 3 · Item expandido (pagar servicio)

**JSX**: `screens-a.jsx > AHomeExpanded` (EPEC atrasada como ejemplo).

**Propósito**: ver detalles del servicio y registrarlo como pagado.

**Layout** (item expandido in-place dentro del Mes):
- Card crece, fondo `cardLate`, borde `borderLate`.
- Header con icono + nombre + badge "ATRASADA".
- Monto grande + meta info (día de vencimiento, tarjeta de débito si aplica).
- Notas (si las hay) en `textDim`.
- Acción primaria: **botón verde "Marcar como pagado"** full-width.
- Acciones secundarias: "Ir a pagar" (link externo), "Editar".

**Interacciones**:
- "Marcar como pagado" → animación: la card se transforma a estado pagado (verde), monto cambia a `primaryHi`, badge se reemplaza por check + "PAGADO". Optimistic UI.
- "Ir a pagar" → abre `link_para_pagar` y copia `codigo_de_referencia` al clipboard.

---

## 4 · Tarjetas (lista)

**JSX**: `screens-a-cards.jsx > ACardsList`

**Propósito**: ver todas las tarjetas con su resumen del mes.

**Layout**:
1. Header: "Tarjetas" + caplabel mono "abril de 2026".
2. **Total del mes** — caplabel "TOTAL DEL MES" + display 32 px.
3. Lista de cards (1 por tarjeta):
   - Indicador izq: día de vencimiento en mono dentro de cuadrado 38×38, color según estado.
   - Nombre + chip de marca (VISA/MC/MP).
   - Sub: cantidad de débitos automáticos.
   - Monto grande (24 px).
   - Label derecha: "PAGADO" / "VENCE DÍA 15" / "ATRASADA".
   - **Botón secundario** "Ir a pagar" full-width con icono link externo.
4. **Bottom nav** ("Tarjetas" activo).

---

## 5 · Detalle MercadoPago (tarjeta)

**JSX**: `screens-a-cards.jsx > ACardDetail`

**Propósito**: ver el resumen de la tarjeta seleccionada con compras en cuotas y débitos automáticos.

**Layout**:
1. AppBar back + nombre + chip marca + botón ⚙️ derecha.
2. **Hero card** (`cardPaid` con halo radial verde, borde `borderPaid`):
   - Caplabel "PAGADO" con check.
   - Monto display 36 px en `primaryHi`.
   - Sub mono "7 débitos automáticos · vence 15".
   - Botón "Ir a pagar" outline.
3. Caplabel "COMPRAS EN CUOTAS · 0" + botón "Nueva" (pill verde soft).
4. Estado vacío: card dashed "Sin compras en cuotas registradas" (italic mute).
5. Caplabel "DÉBITOS AUTOMÁTICOS · 7".
6. Lista de débitos: avatar 32 (iniciales mono), nombre, "Día N" mono, monto.

---

## 6 · Nueva compra (cuotas)

**JSX**: `screens-a-cards.jsx > ANewPurchase`

**Propósito**: registrar una nueva compra en cuotas en una tarjeta.

**Layout**:
1. AppBar "Nueva compra".
2. Card de contexto: "en **MercadoPago**" con chip de marca.
3. Form fields (caplabels mono mayúscula, inputs radius 12):
   - Descripción*
   - Monto por cuota* + Cuotas* (grid 1fr 90px).
   - **Total calculado** (card destacada `primarySoft`/`borderPaid`): caplabel "TOTAL DE LA COMPRA" + sub "se calcula automáticamente" + monto en `primaryHi`.
   - Mes de la primera cuota* (date picker estilo input con icono calendar).
   - Notas (textarea).
4. Botón primary full-width "💾 Crear compra".

---

## 7 · Editar tarjeta

**JSX**: `screens-a-cards.jsx > AEditCard`

**Propósito**: editar metadata de una tarjeta.

**Layout**:
1. AppBar "Editar tarjeta".
2. Preview card de la tarjeta (icono marca + nombre + cierre/vence + chip "ACTIVA").
3. Form fields:
   - Nombre*
   - Banco / emisor
   - Marca (dropdown con swatch de color)
   - Día cierre / Día vencimiento (grid 2-col, mono)
   - Link para pagar (mono)
4. Toggle "Activa" — pill verde con knob blanco.
5. Botón primary "💾 Guardar cambios".
6. Botón danger (outline rojo) "🗑 Eliminar tarjeta".

---

## 8 · Configuración

**JSX**: `screens-a-config.jsx > AConfig`

**Propósito**: hub principal de ajustes.

**Layout**:
1. Header "Configuración" (h1 26 px).
2. **Card sesión**: avatar 38 + caplabel "SESIÓN INICIADA COMO" + email (truncado).
3. Caplabel sección "DATOS".
4. Cards de acceso (con contador y botón +):
   - Cuentas fijas — N activas — `→` Cuentas fijas
   - Tarjetas — N activas — `→` Tarjetas
5. Caplabel sección "SEGURIDAD".
6. Card Bloqueo biométrico con icono + descripción + toggle.
7. **Botón danger** "Cerrar sesión".
8. Footer mono `FINANZAPP · vX.X.X`.
9. Bottom nav ("Config" activo).

---

## 9 · Cuentas fijas (lista)

**JSX**: `screens-a-config.jsx > AFixedAccounts`

**Propósito**: ver y gestionar las cuentas fijas (servicios, suscripciones, impuestos).

**Layout**:
1. AppBar "Cuentas fijas" + botón **+** primary.
2. Resumen mono inline: `9 activas · 5 con monto fijo · 4 variables`.
3. Lista de items, una card por cuenta:
   - Icono custom por categoría (luz, agua, gas, impuesto, suscripción, salud — ver `CCTypeIcon`).
   - Nombre.
   - Sub mono: "Tipo · Día N" + opcional "· {color-swatch} Tarjeta asociada".
   - Derecha: monto fijo (`bodyL`) o **chip "VARIABLE"** (mono uppercase `cardHi`/`textDim`).

---

## 10 · Nueva cuenta fija

**JSX**: `screens-a-config.jsx > ANewFixedAccount`

**Layout**:
1. AppBar "Nueva cuenta fija".
2. Form fields con **hints en cursiva debajo**:
   - Nombre*
   - Tipo* (dropdown con icono custom)
   - Monto estimado — hint *"Vacío = monto variable"*.
   - Día del mes — hint *"1 a 31"*.
   - Débito automático en (dropdown) — hint *"Si está seleccionada, esta cuenta no aparece como ítem en Mes."*
   - Código de referencia (mono) — hint *'Se copia al clipboard al tocar "Ir a pagar" en el Mes.'*
   - Link para pagar (mono).
   - Notas (textarea).
3. Botón primary "💾 Crear cuenta".

---

## 11 · Editar cuenta

**JSX**: `screens-a-config.jsx > AEditFixedAccount`

Mismos campos que **10**, pre-cargados, con:
- Toggle "Activa" — descripción "La cuenta aparece en Mes".
- Botón primary "Guardar".
- Botón danger "Eliminar cuenta".

---

## 12-14 · Modo claro

JSX: `screens-a-light.jsx > ALLogin / ALHome / ALHomeExpanded`.

Mismos componentes y layout que las versiones oscuras (1-3), con paleta `FzColorsLight`. La paleta soft de `cardPaid`/`cardLate` cambia a tonos claros. La tipografía y espaciados son idénticos.

Si vas a soportar modo claro: usá `ThemeMode.system` en `MaterialApp` y `FzTheme.light()` como `theme`.

---

## Resumen de pantallas/rutas sugerido (go_router)

```
/login                     → Login (1)
/                          → Mes/Home (2)  — bottom nav 0
/cards                     → Tarjetas list (4) — bottom nav 1
/cards/:id                 → Card detail (5)
/cards/:id/purchases/new   → Nueva compra (6)
/cards/:id/edit            → Editar tarjeta (7)
/config                    → Config (8)  — bottom nav 2
/config/accounts           → Cuentas fijas list (9)
/config/accounts/new       → Nueva cuenta (10)
/config/accounts/:id/edit  → Editar cuenta (11)
```

Item expandido (3) NO es ruta — es estado interno de la pantalla 2.
