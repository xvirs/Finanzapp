# Paridad Web — Cambios a portar

Resumen de los cambios hechos en la app móvil (Flutter) que hay que replicar en la web para mantener consistencia de funcionalidad y vocabulario entre plataformas.

Cada sección incluye **qué cambió**, **por qué**, y **notas de implementación** independientes de Flutter.

---

## 1. Vocabulario / Renombramientos

### 1.1 Tab "Mes" → **"Inicio"**
- **Ícono**: `home_outlined` (casa con outline).
- **Razón**: "Mes" no reflejaba que es el dashboard principal con totales, balance, etc. "Inicio" es más claro como punto de entrada. El navegador `< Abril 2026 >` del header sigue dando el contexto temporal.
- **Aplica a**: bottom nav (mobile), nav rail (Fold/desktop), cualquier link a "/" o "home".

### 1.2 Tab "Configuración" → **"Gestión"**
- **Ícono**: `tune` (sliders horizontales).
- **Razón**: "Configuración" sugería ajustes/preferencias técnicos, pero la sección contiene gestión de tarjetas, gastos e ingresos — operaciones de negocio del usuario. "Gestión" describe mejor lo que hay adentro.
- **Aplica a**: bottom nav, nav rail.
- **No tocar**: identificadores internos (folder `config_settings`, clase `ConfigScreen`, etc.) — solo strings visibles.

### 1.3 "Cuentas fijas" → **"Gastos"**
- **Razón**: "cuentas" es ambiguo (¿cuenta bancaria? ¿factura?). "Gastos" a secas es el término más simple y claro — se opone naturalmente a "tarjetas" e "ingresos" en el menú de Gestión, sin necesidad de adjetivos.
- **Aplica a todas las apariciones visibles**:
  - Etiqueta en el menú de Gestión.
  - Título de la pantalla lista.
  - Empty state ("No tenés gastos").
  - Título del form ("Nuevo gasto" / "Editar gasto").
  - Confirmación de eliminar ("Eliminar gasto").
  - Mensajes de error ("No se encontró el gasto.").
- **No tocar**: nombres internos del modelo (`Bill`, `BillsRepository`, tabla `bills`).

---

## 2. Loading states / Shimmers

### 2.1 Header del Inicio (compact / mobile)
- **Antes**: durante loading el header mostraba ceros o vacíos en estimado/pagado/balance.
- **Ahora**: durante `loading`/`initial` se renderiza un shimmer del header completo (caplabel · nav · grid de totales · progress bar · tabs filter).
- **Implementación**: condicional en el render del header — si está cargando, montar el placeholder; si no, los datos reales.

### 2.2 Header de Tarjetas (compact / mobile)
- **Antes**: el título "Tarjetas" + total del mes se mostraban con datos reales durante loading.
- **Ahora**: shimmer del título · fecha · "TOTAL DEL MES" · monto.

### 2.3 Tarjetas expanded (Fold / desktop)
- **Antes**: no había shimmer — siempre se renderizaba el layout real.
- **Ahora**: `CardsExpandedShimmer` espejo del `MonthExpandedShimmer`: master 340dp con header + 5 mini-cards · detail con hero + 2 paneles (cuotas/débitos) + CTA.

### Patrón general para web
Los headers/laterales con datos derivados deben mostrar shimmer **a la misma forma que el contenido real** (mismas alturas, paddings, anchos aproximados). Mantener el shape evita layout shift cuando llegan los datos.

---

## 3. Sección Inicio — Ingresos y Saldo

### 3.1 Compact (mobile)
- **ELIMINADO**: card "Ingresos" al final de la lista de gastos. Era visualmente disruptivo (sección de salidas + entrada al final).
- **Mantener**: la fila INGRESOS + SALDO en el header (`_IncomeBalanceRow`), visible solo cuando `incomeTotal > 0`.

### 3.2 Expanded (Fold / desktop)
- **AGREGADO**: fila de 2 stat cards INGRESOS + SALDO debajo de PAGADO/ATRASADO en el detail pane.
- **Visibilidad**: solo cuando `incomeTotal > 0`.
- **Estilo**:
  - INGRESOS — tono "paid" (verde), sub "del mes".
  - SALDO — tono "paid" si `>= 0` (sub "a favor"), "late" si negativo (sub "déficit").
  - `balance = incomeTotal - estimatedTotal`.

---

## 4. Flujo de pago de Tarjetas

Patrón principal: la **lista** es el lugar de acción rápida; el **detail** es para revisar el desglose y abrir la app de pago.

### 4.1 Item de la lista de Tarjetas
- **AGREGADO**: cada item ahora tiene en su parte inferior:
  - Caplabel "MONTO PAGADO (ARS)".
  - Input numérico con prefijo `$`, pre-rellenado con el monto pagado real (si existe) o el total estimado del mes.
  - Botón full-width: **"Marcar pagado"** (primary verde) cuando pendiente, **"Marcar pendiente"** (outline) cuando pagado.
  - Spinner reemplaza el ícono mientras se procesa la mutación.
- **ELIMINADO**: botón "Ir a pagar" del item.
- **Comportamiento del tap**: el área superior del item (info de la tarjeta) sigue siendo tap-to-detail; el input + botón viven afuera del área de tap, manejan sus propios eventos.

### 4.2 Detail de tarjeta
- **Hero**: solo info — caplabel ("TOTAL DEL MES" / "PAGADO") + monto + breakdown (`X cuotas · Y débitos · vence Z`).
  - **Hint nuevo**: cuando está pagado y el monto real difiere del estimado en más de $0.50, mostrar `"estimado: $X"` debajo del breakdown como referencia. Caso de uso: pagaste $123.450 cuando el resumen estimaba $120.000 — querés ver ambos montos.
- **Sin input ni botón de marcar** en el hero (la acción rápida vive en la lista).
- **CTA "Ir a pagar"**: botón primary verde con sombra, al final del body, después de los paneles de cuotas + débitos. Solo visible si la tarjeta tiene `url` configurada.

### 4.3 Tarjetas expanded (Fold / desktop)
- **AGREGADO**: bloque "quick-pay" en el detail pane (lateral derecho), entre el hero card y los paneles de cuotas/débitos.
- Mismo patrón que la lista compact: input + botón Marcar pagado/pendiente.
- Despacha los mismos eventos del bloc.
- "Abrir tarjeta" (CTA al detail completo) se mantiene al final.

### 4.4 Eventos / API
Implementar en el bloc/store de Tarjetas (lista):

| Evento | Payload | Comportamiento |
|---|---|---|
| `CardsMarkPaidRequested` | `{ cardId, amount }` | Upsert en `payments` con `kind: 'card_total'`, `card_id: cardId`, `amount_real: amount`, `status: 'paid'`. |
| `CardsMarkPendingRequested` | `{ cardId }` | Delete del payment correspondiente al período actual. |

Estado: agregar `mutatingCardId: string | null` para mostrar spinner solo en el item afectado y bloquear su botón.

Tras la mutación: refresh silencioso (sin tocar `status`) + clear del `mutatingCardId` en una sola emisión, para evitar flicker entre estados.

### 4.5 Validación del input
- Trim + reemplazar `,` por `.` (decimales).
- `parseFloat` → si null o `<= 0`, mostrar snack "Ingresá un monto válido."
- Sin decimales en el display (se muestra entero, pero el modelo acepta double).

---

## 5. Deep links a apps de pago

### 5.1 Patrón híbrido
La app móvil intenta primero un **scheme custom** (deep link a la app instalada) y cae a **HTTPS** (App Links) si el scheme no resuelve. La web tiene un comportamiento distinto pero el modelo de datos es el mismo.

### 5.2 Schemes verificados (Argentina)
| Proveedor | Scheme | Notas |
|---|---|---|
| Mercado Pago | `mercadopago://home` | El bare `mercadopago://` NO resuelve. Confirmado con `dumpsys` y `adb am start`. También responde a `mpago://`, `meli://`. |

### 5.3 Schemes propuestos (sin verificar uno por uno)
| Proveedor | Scheme tentativo |
|---|---|
| Modo | `modo://` |
| Ualá | `uala://` |
| Naranja X | `naranjax://` |
| Brubank | `brubank://` |
| Galicia | `bgalicia://` |
| Santander | `santandermobile://` |
| BBVA | `bbvanetcash://` |

Para verificar cada uno en Android:
```
adb shell dumpsys package <package.name> | grep Scheme
adb shell am start -W -a android.intent.action.VIEW -d "<scheme>://<host>"
```
Probar hosts típicos: `home`, `main`, `wallet`, `app`, `dashboard`.

### 5.4 Comportamiento esperado en web
- En **mobile web** (Android/iOS browser): un `<a href="mercadopago://home">` o `window.location = 'mercadopago://home'` puede disparar la apertura de la app si está instalada.
- En **desktop web**: el scheme custom no resuelve a nada → fallback a HTTPS.
- **Recomendación**: implementar el mismo modelo "el bill guarda una sola URL", que puede ser scheme custom O HTTPS. La web solo hace `window.open(url, '_blank', 'noopener')` y deja que el SO/browser resuelva.

### 5.5 HTTPS oficiales (fallback robusto)
Funcionan en desktop, mobile web y mobile app (por App Links/Universal Links):

```
Mercado Pago    https://www.mercadopago.com.ar
Modo            https://www.modo.com.ar
Ualá            https://www.uala.com.ar
Naranja X       https://www.naranjax.com
Galicia         https://onlinebanking.bancogalicia.com.ar
Santander       https://www.santander.com.ar
BBVA            https://www.bbva.com.ar
Macro           https://www.macro.com.ar
Brubank         https://www.brubank.com
ICBC            https://www.icbc.com.ar
ARCA (ex AFIP)  https://www.afip.gob.ar
ARBA            https://www.arba.gov.ar
AGIP            https://www.agip.gob.ar
```

---

## 6. Resumen tabular de paridad

| Feature | Compact (mobile) | Expanded (Fold/tablet) | Web equivalente |
|---|---|---|---|
| Tab "Inicio" | ✅ home_outlined | ✅ home_outlined | Replicar nombre + ícono |
| Tab "Gestión" | ✅ tune | ✅ tune | Replicar nombre + ícono |
| "Gastos" | ✅ todas las strings | ✅ todas las strings | Replicar todas las strings |
| Shimmer header Inicio | ✅ Nuevo | (ya existía) | Implementar shimmer del header |
| Shimmer header Tarjetas | ✅ Nuevo | (no aplica) | Implementar shimmer del header |
| Shimmer Tarjetas expanded | (no aplica) | ✅ Nuevo | Implementar shimmer del layout master+detail |
| Quitar card "Ingresos" del fondo | ✅ | (no aplica) | Quitar |
| Stat cards INGRESOS+SALDO en detail | (en header) | ✅ Nuevo | Implementar en el panel lateral |
| Quick-pay en item de tarjeta | ✅ Nuevo | ✅ Nuevo (en detail pane) | Implementar en ambos layouts |
| Hero del detail solo info | ✅ | ✅ | Replicar |
| Hint "estimado: $X" | ✅ | (en hero del expanded layout: opcional) | Implementar lógica del hint |
| CTA "Ir a pagar" al final del detail | ✅ | (no aplica directo) | Implementar |
| Deep links de proveedores | ✅ (con queries en manifest) | ✅ | En web es solo HTTPS o `window.open` con scheme |

---

## 7. Notas de implementación independientes de Flutter

- Los **textos** son string literales — buscar y reemplazar con cuidado de no romper identificadores internos.
- Los **íconos** son nombres de Material Icons; si la web usa otro set (Heroicons, Lucide, FontAwesome), elegir el equivalente más cercano por significado:
  - `home_outlined` → ícono "home" outline
  - `tune` → ícono "sliders" / "adjustments"
  - `receipt_long_outlined` → ícono "document" / "receipt"
- Los **shimmers** pueden implementarse con CSS gradient animado, react-loading-skeleton, o equivalente.
- Las **mutations** del bloc (`CardsMarkPaidRequested`, etc.) tienen contraparte directa en el endpoint REST/Supabase: insert/update/delete sobre `payments`. La constraint `UNIQUE(user_id, period, card_id)` garantiza un solo pago por tarjeta y mes.
- El estado `mutatingCardId` permite spinner por-fila sin necesidad de un loading global.
