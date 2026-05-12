# Cambios tarjetas + Inicio expanded — para portar al proyecto web

Fecha: 2026-05-12
Origen: aplicado en el cliente Flutter `Finanzapp`. Este doc resume los
cambios para reproducirlos en el cliente web (Next/React) que comparte
data model y backend.

## Resumen ejecutivo

1. **Bug fix**: tarjetas pagadas que no tienen cuotas activas ni débitos
   automáticos en el mes desaparecían del Inicio (y su monto no se
   sumaba al “Total pagado”). Una sola condición mal ordenada.
2. **Header de Tarjetas**: el total único “TOTAL DEL MES” se reemplaza
   por dos stat cards `ESTIMADO / PAGADO` (mismo lenguaje visual que
   Inicio), con footer “falta $X”.
3. **CRUD de tarjetas movido a Gestión** (`/config/cards`): antes desde
   Config → Tarjetas se navegaba al dashboard (`/cards`), inconsistente
   con Gastos e Ingresos. Ahora `/config/cards` espeja `/config/bills`
   (lista de gestión + form de edición). El dashboard `/cards` queda
   sólo para visualizar.
4. **Detail vacío de Tarjetas (vista expanded)**: cuando no hay tarjeta
   seleccionada, el pane derecho mostraba un placeholder. Ahora muestra
   resumen del mes (estimado/pagado, contadores, próximas a vencer).
5. **Inicio (vista expanded)**: el master pane mostraba la lista de
   gastos plana. Ahora los items se agrupan por categoría (Tarjetas,
   Vivienda, Servicios, …) como en la vista compact.
6. **Card detail**: se elimina el botón ⚙ del AppBar. La edición vive en
   Gestión, ya no se entra a editar desde el dashboard.
7. **Bug fix saldo**: el “SALDO” del header de Inicio se calculaba como
   `ingreso − estimado` (saldo proyectado a fin de mes). Cambia a
   `ingreso − pagado` (lo que te queda disponible hoy).
8. **Bug fix monto pagado en mini-tarjetas (expanded)**: las filas del
   master de `/cards` en vista expandida mostraban el estimado aunque
   estuvieran pagadas. El label decía “PAGADO” pero el número era el
   estimado. Pasa a usar `amount_real` con fallback al estimado, igual
   que en compact.

---

## 1. Bug fix — tarjeta pagada “fantasma” en Inicio

### Síntoma

Usuario con 3 tarjetas. Una de ellas no tiene cuotas activas en el mes
ni débitos automáticos vinculados, pero la pagó (registró un
`Payment.kind = card_total` con `amount_real > 0`).

- Inicio mostraba sólo 2 tarjetas (la pagada desaparecía).
- El “Total pagado” del header no sumaba el `amount_real` de esa
  tarjeta.

### Root cause

En el builder que arma los items del mes, la tarjeta se filtraba antes
de chequear si tenía un payment registrado:

```ts
// Pseudocódigo del estado anterior
for (const card of cards.filter(c => c.active)) {
  const installmentsCount = activeInstallmentsForPeriod(card, period).length;
  const autoDebits = bills.filter(b => b.active && b.autoDebitCardId === card.id);

  if (installmentsCount === 0 && autoDebits.length === 0) continue;  // ← bug

  const payment = payments.find(
    p => p.kind === 'card_total' && p.cardId === card.id,
  );
  // ...crea el item...
}
```

Como el `continue` está antes del lookup del `payment`, las tarjetas con
payment pero sin cuotas/débitos nunca entran en la lista del mes.
Resultado: el item no existe, el `paid_total` del summary no lo suma.

### Fix

Mover el lookup del `payment` antes del `continue`, e incluir
`payment == null` en la condición:

```ts
for (const card of cards.filter(c => c.active)) {
  const installmentsCount = activeInstallmentsForPeriod(card, period).length;
  const autoDebits = bills.filter(b => b.active && b.autoDebitCardId === card.id);

  const payment = payments.find(
    p => p.kind === 'card_total' && p.cardId === card.id,
  );

  if (installmentsCount === 0 && autoDebits.length === 0 && payment == null) {
    continue;
  }

  // ...crea el item, mismo código que antes...
}
```

### Validación

- Marcar pagada una tarjeta sin cuotas/débitos del mes → aparece en
  Inicio con tono pagado.
- El `amount_real` de ese payment se suma al “Total pagado” del header
  (incluido cuando supera al estimado).

---

## 2. Header de Tarjetas: ESTIMADO / PAGADO

### Antes

`TOTAL DEL MES` + un solo monto (estimado). No había forma de ver desde
el dashboard de tarjetas cuánto ya se pagó.

### Después

Grid 2-col con el mismo lenguaje visual que el header de Inicio:

```
┌────────────────────┬────────────────────┐
│ ESTIMADO           │ PAGADO             │
│ $1.234.000         │ $980.500           │
│                    │ falta $253.500     │
└────────────────────┴────────────────────┘
```

- `tone = neutral` para Estimado, `tone = paid` (verde tinted) para
  Pagado.
- Footer “falta $X” cuando `estimado − pagado > 0`. Para versiones más
  compactas (ej. sidebar del expanded), se puede omitir.

### Lógica del `paidForPeriod`

Suma de cada tarjeta cuyo payment del mes esté en `paid`:

```ts
let paidForPeriod = 0;
for (const card of activeCards) {
  // ...summary.total = cuotas activas + autoDebits...
  const payment = payments.find(
    p => p.kind === 'card_total' && p.cardId === card.id,
  );
  if (payment?.status === 'paid') {
    paidForPeriod += payment.amount_real ?? summary.total;
  }
}
```

Fallback al estimado (`summary.total`) si `amount_real` es null.

### Donde aplicarlo en web

- Dashboard `/cards` (vista lista): reemplazar el header monumental por
  el grid de 2 stat cards.
- Versión “expanded”/desktop (si existe master+detail): replicar el
  mismo grid en el sidebar (más compacto, sin footer).
- Shimmer/skeleton del header: pasar de un solo box grande a dos boxes
  más chicos lado a lado.

---

## 3. CRUD de tarjetas → `/config/cards`

### Motivación

Antes:

- Config → **Gastos** → `/config/bills` (lista de gestión propia, edit
  inline).
- Config → **Ingresos** → `/config/incomes` (idem).
- Config → **Tarjetas** → `/cards` (¡el dashboard!).

Editar una tarjeta requería: Config → Tarjetas → dashboard → tap →
detail → ⚙ → form. 4 hops. Además ”te lleva a tarjeta cuando la
seleccionas”, que es confuso.

### Cambios

1. **Nueva ruta de gestión `/config/cards`**, espejo de `/config/bills`:
   - Lista de todas las tarjetas (incluye inactivas).
   - Botón `+` arriba a la derecha → `/config/cards/new`.
   - Tap en fila → `/config/cards/:id` (form de edición/borrado).
   - Misma fuente de datos (`cards_repository.fetchAll()`), realtime
     suscrito a la tabla `credit_cards`.

2. **Repuntar Config → Tarjetas**:
   - Compact: la fila “Tarjetas” en Config navega a `/config/cards` (no
     a `/cards`).
   - Expanded: la sección `Cards` en el detail pane embebía un
     placeholder “usá la pestaña Tarjetas”. Ahora embebe la nueva lista
     de gestión sin AppBar (mismo patrón que Gastos en expanded).

3. **El dashboard `/cards` permanece igual** (visualización, pagos
   rápidos, cuotas, débitos). No hay edición desde ahí.

### Form de edición — pequeño ajuste de navegación

`card_form_screen._delete()` antes hacía `router.go('/cards')` después
de eliminar, lo que sacaba al usuario al dashboard aunque hubiera
entrado desde Gestión. Cambiado a `router.pop(true)` para respetar el
origen (idéntico al patrón de `bill_form`).

### Tile de la lista de gestión

Sugerido: misma estética que las filas de Gastos:

- Brand chip a la izquierda (visa / mastercard / amex / “OTRA” / “—”).
- Nombre de la tarjeta + (opcional) pill `INACTIVA` si `active=false`.
- Subtitle mono: `MARCA · ISSUER · Vence día N`.
- Chevron a la derecha como affordance de tap.

### State del bloc / store

```
status: 'initial' | 'loading' | 'success' | 'failure'
cards: CreditCard[]
errorMessage?: string
```

Idéntico a `bills_list_state` salvo por la entidad. Eventos:
`requested`, `refreshRequested`, `silentRefreshRequested` (este último
disparado por el realtime con debounce de 250ms).

---

## 4. Detail vacío de Tarjetas (vista expanded)

### Antes

Pane derecho con un cuadro al medio: ícono + “Seleccioná una tarjeta”.

### Después

Aprovechar el espacio para resumen del mes:

```
RESUMEN DEL MES
Mayo 2026

┌───────────────┬───────────────┐
│ ESTIMADO      │ PAGADO        │
│ $X            │ $Y            │
│               │ falta $Z      │
│               │ (o "al día")  │
└───────────────┴───────────────┘

┌─────────────────────────────────┐
│  3        2        1            │
│ activas  pagadas  pendiente     │
└─────────────────────────────────┘

PRÓXIMAS A PAGAR
┌─────────────────────────────────┐
│ [VISA]  Visa Macro       $...   │
│         VENCE DÍA 12            │
│ [MC]    MC Galicia       $...   │
│         VENCE DÍA 18            │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ ← Tocá una tarjeta a la izq...  │
└─────────────────────────────────┘
```

Reglas:

- Stat row sólo se muestra si hay al menos una tarjeta.
- “Próximas a pagar”: hasta 3 tarjetas pendientes ordenadas por
  `dueDay` asc (las que no tienen `dueDay` van al final).
- “falta $X” → “al día” cuando `pendiente ≤ 0`.

---

## 5. Inicio expanded — master agrupado por categoría

### Antes

Master pane (sidebar de 320 dp) con lista plana de items, sin headers
de categoría. Difícil escanear cuando hay muchos gastos.

### Después

Lista mixta `[header, item, item, header, item, ...]`. Mismas
categorías que el compact (ya provistas por
`group_checklist_by_category` en el dominio):

- Tarjetas
- Vivienda
- Servicios
- Internet / Teléfono
- Salud
- Impuestos
- Suscripciones
- Otros

Cada header compacto: `icon · TÍTULO · count   ...   $total`.

Si una categoría queda vacía después de aplicar el filter
(Todas/Pendiente/Atraso), su header se omite. Si TODO queda vacío, se
muestra el empty state existente.

### Implementación sugerida (web)

Si en web tu master es un componente `<MasterPane items={…} />` que
recibe ya el array aplanado, refactorizalo a:

```tsx
type MasterEntry =
  | { kind: 'header'; groupKey: string; title: string; count: number; totalLabel: string }
  | { kind: 'item'; item: MonthItem };

function buildEntries(state): MasterEntry[] {
  const entries: MasterEntry[] = [];
  for (const group of state.groups) {
    const visible = group.items.filter(passesFilter);
    if (visible.length === 0) continue;
    const hasVariable = visible.some(i => i.estimatedAmount == null);
    const total = hasVariable ? null
      : visible.reduce((acc, i) => acc + (i.estimatedAmount ?? 0), 0);
    entries.push({
      kind: 'header',
      groupKey: group.key,
      title: group.title,
      count: visible.length,
      totalLabel: hasVariable ? '—' : formatCurrency(total),
    });
    for (const item of visible) entries.push({ kind: 'item', item });
  }
  return entries;
}
```

El renderer hace switch sobre `kind`. Los headers usan menos padding
que en el compact porque el ancho disponible es menor (≈320 dp).

### Donde NO cambia nada

- La vista compact ya estaba agrupada (componente
  `MonthGroupSection`). No tocar.
- El detail pane del expanded (panel “Distribución por categoría”)
  tampoco cambia.

---

## 7. Bug fix — saldo del header de Inicio

### Síntoma

El stat “SALDO” del header de Inicio (compact y expanded) no cambiaba
al marcar items como pagados. Sólo se movía al cambiar montos
estimados. Un usuario que cobró $1000 y aún no pagó nada veía un saldo
muy bajo (o negativo) si su estimado mensual era alto, en lugar de ver
los $1000 reales que tenía disponibles.

### Root cause

```ts
const balance = income - estimated;  // ← lo que vas a quedar a fin de mes
```

Eso es “saldo proyectado”, no saldo real. El estimado todavía no salió
de la cuenta.

### Fix

```ts
const balance = income - paid;  // ← lo que te queda disponible hoy
```

`paid` viene del summary del mes (suma de `payment.amount_real` —
fallback al estimado del item si `amount_real` es null — para items con
`status = paid`).

### Donde aplicarlo en web

Dos lugares (uno por viewport):

- Header del Inicio (compact): la fila secundaria “INGRESOS / SALDO”
  bajo el grid Estimado/Pagado. Pintar el `balance` con la nueva
  fórmula.
- Header/detail del Inicio (expanded): el stat “SALDO” al lado de
  “INGRESOS”. Idem.

El color del valor sigue la misma regla:
`balance >= 0` → verde (`primaryHi`), si no → rojo (`lateInk`).

### Trade-off, por si surge

Si en algún momento querés mostrar también el saldo proyectado a fin
de mes, agregalo como tercer stat (“SALDO PROYECTADO”) — no
reemplaces el SALDO actual.

### Validación

- Ingreso $1000, estimado $800, pagado $0 → saldo $1000 (antes mostraba
  $200).
- Marcar pagado un item por $300 → saldo baja a $700.
- Pagar todos los items ($800) → saldo $200.
- Pagar un item con `amount_real` > estimado → saldo se reduce por el
  `amount_real` real, no por el estimado.

---

## 8. Bug fix — monto pagado en mini-tarjetas del master (expanded)

### Síntoma

En la vista expandida de `/cards`, las filas del sidebar (mini-tarjetas
con brand chip + label `PAGADO|A PAGAR` + monto + nombre + estado)
mostraban siempre el monto **estimado**, aunque la tarjeta estuviera
marcada como pagada. Si el pago real difería del estimado (caso típico
en tarjetas, donde casi siempre difiere), el número era engañoso:
label “PAGADO” + monto del estimado.

Sólo afectaba al modo expandido. La fila compact (`CardListItem`) y el
hero del detail ya hacían bien la lógica.

### Root cause

```ts
// mini-tarjeta del master del expanded
<AnimatedCurrency value={item.total} />  // ← siempre estimado
```

### Fix

Mismo criterio que la fila compact:

```ts
const amountForDisplay =
  paid && item.payment?.amount_real != null
    ? item.payment.amount_real
    : item.total;

<AnimatedCurrency value={amountForDisplay} />
```

- Si está pagada y hay `amount_real` → mostramos lo que efectivamente
  se pagó.
- Si está pagada sin `amount_real` explícito (caso borde, ej. payment
  legacy) → fallback al estimado.
- Si está pendiente → estimado.

### Donde aplicarlo en web

En el componente de las filas del master de la vista expanded/desktop
de `/cards` (la mini-card con label “PAGADO / A PAGAR” a la derecha).
Buscar el componente equivalente a `_MasterRow` y aplicar la misma
condición.

### Validación

- Marcar pagada una tarjeta con `amount_real` > estimado → la
  mini-tarjeta del sidebar muestra el `amount_real`, no el estimado.
  Coincide con lo que se ve en el hero del detail al seleccionarla.
- Marcar pagada con `amount_real` < estimado → mismo resultado, valor
  real.
- Tarjeta pendiente → estimado (sin cambios).

---

## 6. Card detail — sin ⚙

### Cambio

Quitar el botón “configuración” del AppBar de `card-detail`.

### Motivación

La edición de la tarjeta ahora vive sólo en Gestión
(`/config/cards/:id`). Tener un atajo desde el detail rompe la
intención del nuevo IA: “editar es operación de Gestión, el dashboard
es lectura + pagos”.

### Implementación

Eliminar el icon button trailing del `AppBar` de la pantalla de detalle
y el handler asociado (`_editCard` que hacía `push('/cards/:id/edit')`).

### Nota

La ruta `/cards/:id/edit` puede dejarse registrada (no rompe), o
deprecarse si querés ser estricto. En el cliente Flutter se mantuvo
registrada por compatibilidad con deep links.

---

## Diff de rutas

| Ruta                       | Estado  | Notas                              |
|----------------------------|---------|------------------------------------|
| `/cards`                   | igual   | Dashboard. Sin edición.            |
| `/cards/new`               | igual   | Form de creación.                  |
| `/cards/:id`               | igual   | Detail. Sin ⚙.                     |
| `/cards/:id/edit`          | igual   | Form de edición (vive todavía).    |
| `/config/cards`            | **nueva** | Lista de gestión.               |
| `/config/cards/new`        | **nueva** | Form de creación desde gestión. |
| `/config/cards/:id`        | **nueva** | Form de edición desde gestión.  |

Config → Tarjetas (fila) antes hacía `go('/cards')`; ahora
`push('/config/cards')`.

Config → Tarjetas (+) antes hacía `push('/cards/new')`; ahora
`push('/config/cards/new')`.

---

## Checklist de QA

- [ ] Marcar pagada una tarjeta sin cuotas ni débitos del mes y con
      monto > estimado. Aparece en Inicio. El monto entra en “Total
      pagado” del header.
- [ ] Header de `/cards` muestra dos cards Estimado/Pagado. Footer
      “falta $X” correcto. Cuando todo está pagado, valor de Pagado
      iguala al Estimado.
- [ ] Config → Tarjetas (compact) abre `/config/cards`. Tap en fila
      abre form. Volver al guardar/eliminar deja al usuario en
      `/config/cards`, no en el dashboard.
- [ ] Config expanded → sección Tarjetas muestra la lista de gestión
      embebida (no el placeholder anterior).
- [ ] `/cards` expanded sin selección: pane derecho muestra estimado,
      pagado, contadores, próximas a vencer. Selección de tarjeta
      cambia al hero como antes.
- [ ] Inicio expanded master: gastos agrupados por categoría con
      headers. Filtros Todas/Pendiente/Atraso colapsan categorías
      vacías.
- [ ] `/cards/:id` (detail) no muestra ícono ⚙ a la derecha del título.
- [ ] Inicio header: el stat “SALDO” baja al marcar items como pagados
      (no sólo al editar estimados). Con todo sin pagar el saldo iguala
      al ingreso.
- [ ] `/cards` expanded: marcar pagada una tarjeta con monto real ≠
      estimado. La mini-tarjeta del sidebar muestra el monto real (no
      el estimado), igual que el hero del detail.

---

## Archivos tocados en Flutter (referencia)

Útil si querés diff-by-diff:

- `lib/features/month/domain/month_builder.dart` — bug fix (#1).
- `lib/features/cards/presentation/bloc/cards_bloc.dart` + `cards_state.dart` — `paidForPeriod` (#2).
- `lib/features/cards/presentation/cards_screen.dart` — header compact (#2).
- `lib/features/cards/presentation/widgets/cards_expanded_layout.dart` — header sidebar (#2) + detail vacío (#4) + monto pagado en master row (#8).
- `lib/features/cards/presentation/widgets/cards_shimmer.dart` + `cards_expanded_shimmer.dart` — shimmers (#2).
- `lib/features/config_settings/presentation/bloc/cards_list_bloc.dart` (+ event/state) — nuevo bloc (#3).
- `lib/features/config_settings/presentation/cards_list_screen.dart` — nueva screen (#3).
- `lib/features/config_settings/presentation/config_screen.dart` — fila Tarjetas (#3).
- `lib/features/config_settings/presentation/widgets/config_expanded_layout.dart` — sección embebida (#3).
- `lib/router.dart` — rutas nuevas (#3).
- `lib/features/cards/presentation/card_form_screen.dart` — pop(true) tras delete (#3).
- `lib/features/cards/presentation/card_detail_screen.dart` — quitar ⚙ (#6).
- `lib/features/month/presentation/widgets/month_expanded_layout.dart` — master agrupado (#5) + saldo (#7).
- `lib/features/month/presentation/widgets/month_header_section.dart` — saldo (#7).
