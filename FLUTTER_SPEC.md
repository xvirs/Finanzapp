# FinanzasXavier — Especificación para versión nativa en Flutter

Este documento describe todo lo necesario para replicar en Flutter la app web actual (Next.js + Supabase), conservando la base de datos compartida para que ambas versiones se mantengan sincronizadas.

> **Versión web de referencia:** repo [xvirs/FinanzasXavier](https://github.com/xvirs/FinanzasXavier) deploy en https://finanzas-xavier.vercel.app.

---

## 1. Resumen y norte del producto

App personal para llevar el control de **gastos recurrentes obligatorios** del mes. NO es un budget tracker general.

**Objetivos primarios:**
1. Visualizar fácilmente los servicios y montos a pagar cada mes.
2. Tener claridad sobre el gasto mensual fijo.
3. Evitar pagar intereses por mora — recordatorios y estado visual de urgencia.

**Lo que NO hace (decisión consciente):**
- No registra gastos variables (supermercado, social, restaurantes).
- No es presupuesto.
- No registra ingresos / sueldo (queda fuera del scope actual).

---

## 2. Features completas

### 2.1 Autenticación
- **Login con Google OAuth** (proveedor Supabase).
- **Login con magic link** (email + link mágico, fallback).
- **Logout** desde la pantalla de Configuración.
- Sesión persistente entre aperturas de la app.

### 2.2 Navegación
Bottom navigation con 3 tabs:
1. **Mes** (`/`) — checklist de pagos del mes.
2. **Tarjetas** (`/cards`) — lista y detalle de tarjetas de crédito.
3. **Config** (`/config`) — gestión de cuentas y tarjetas, logout.

### 2.3 Pantalla "Mes"

**Header anclado (sticky):** mantiene visible al scrollear.
- Subtítulo: "Mes actual" / "Mes pasado".
- Navegador de mes: chevron izquierdo (siempre), título "Abril de 2026", chevron derecho (solo si está viendo un mes pasado).
- "Volver al mes actual" cuando no se está en el actual.
- Tarjeta resumen con dos métricas:
  - **Estimado del mes** (suma de todos los items pendientes + pagados a su valor estimado).
  - **Pagado** (suma de los pagos reales) + "falta $X" cuando hay pendiente.
- Línea con "X/Y pagadas" y switch "Solo pendientes".

**Body (scrollea):**
- Items agrupados por **categoría macro** (un emoji + título + count):
  - 💳 **Tarjetas** (tarjetas activas con cargos del mes).
  - 🏠 **Vivienda** (rent + consortium).
  - ⚡ **Servicios** (electricity + water + gas).
  - 📶 **Internet / Teléfono**.
  - 🏥 **Salud**.
  - 🏛️ **Impuestos**.
  - 📺 **Suscripciones**.
  - 📌 **Otros**.
- Cada ítem (`MonthItemCard`):
  - **CalendarTag** a la izquierda (cuadrado de 40x40 con el día de vencimiento, coloreado según urgencia: neutro / ámbar / rojo / verde-pagado).
  - Nombre + **UrgencyBadge** (Atrasada / Vence hoy / Mañana / En N días).
  - Subtítulo contextual (provider_code para bills, "X cuotas + Y débitos aut." para tarjetas).
  - Total a la derecha (estimado o pagado).
  - **Acordeón:** solo un ítem expandido a la vez. Al expandir muestra:
    - Botón "🔗 Ir a pagar" (si tiene URL). Al tocarlo, copia silenciosamente el `provider_code` al clipboard si existe.
    - Form de "Marcar como pagado" con input de monto (sugerencia: monto fijo si lo tiene, sino promedio de los últimos 3 pagos).
    - Si ya está pagado, muestra "Marcar como pendiente" para deshacer.

**Estados visuales por urgencia (solo en mes actual):**
- `overdue` (día venc. ya pasó): tinte rojo claro + badge "Atrasada".
- `due-soon` (día venc. ≤ 3 días): tinte ámbar + badge "Vence hoy / Mañana / En N días".
- `normal`: neutro.
- `paid`: tinte verde + ✓ en CalendarTag.

### 2.4 Pantalla "Tarjetas"

**Header anclado:**
- "Tarjetas · Abril de 2026".
- Total del mes (suma de todas las tarjetas activas).

**Body:**
- Cada tarjeta como **`CardListItem`** (card grande con tinte violeta):
  - **CalendarTag** con día de vencimiento + urgencia.
  - Nombre + **BrandChip** (VISA azul, Mastercard naranja, Amex sky, Otra zinc).
  - UrgencyBadge si aplica.
  - Subtítulo: "X cuotas · Y débitos aut." (o "Sin cargos este mes").
  - Total del mes (text-2xl).
  - "Vence día N" si aplica y no está pagada.
  - Botón "🔗 Ir a pagar" si la tarjeta tiene URL.
  - Toda la card es tappable y navega al detalle.

**Detalle de tarjeta (`/cards/[id]`):**

- Header sticky con:
  - ← Tarjetas (back).
  - Nombre + brand label.
  - Engranaje ⚙ → editar tarjeta.
  - Total del mes + breakdown (X cuotas · Y déb. aut.).
  - Botón "🔗 Ir a pagar" si tiene URL.
- Sección **"💳 COMPRAS EN CUOTAS"** primero:
  - Botón "+ Nueva".
  - Cada compra muestra **InstallmentProgressTag** (X/N en bloque, emerald si activa este mes, gris "—" si no), descripción, monto por cuota, monto del mes.
  - Click → editar/eliminar compra.
- Sección **"🔁 DÉBITOS AUTOMÁTICOS"** debajo:
  - Cada bill asociado se muestra con **BillKindTag** (cuadrado neutro con emoji del kind), nombre, "Día N", monto.
  - Click → ir a editar el bill en `/config/bills/[id]`.

**Edición de tarjeta (`/cards/[id]/edit`):**
- Form con: nombre, banco, marca, día cierre, día vencimiento, link para pagar.
- Toggle "Activa".
- Botón eliminar (con confirmación).

**Nueva tarjeta (`/cards/new`):**
- Mismo form, sin toggle ni delete.

**Compra en cuotas (`/cards/[id]/installments/new` y `/[iid]`):**
- Form con: descripción, monto por cuota, total cuotas, mes de la primera cuota, notas.
- Total de la compra calculado en vivo.

### 2.5 Pantalla "Configuración"

- Header con email del usuario.
- Lista de secciones, cada fila con:
  - Texto principal (link al listado).
  - Mini "+" verde a la derecha (link a crear nuevo).
- Secciones:
  - **Cuentas fijas** (link → `/config/bills`, "+" → `/config/bills/new`).
  - **Tarjetas** (link → `/cards`, "+" → `/cards/new`).
- Botón "Cerrar sesión".

**Lista de cuentas fijas (`/config/bills`):**
- Cada bill con emoji del kind, nombre, kind label, día, indicador "💳 [tarjeta]" si es débito automático, monto o "Variable".
- Botón "+ Nueva" en el header.

**Edición/creación de cuenta fija:**
- Form con: nombre, tipo (10 kinds), monto estimado, día del mes, débito automático en tarjeta (select con tarjetas activas), código de referencia, link para pagar, notas.
- Toggle "Activa".
- Botón eliminar (con confirmación).

### 2.6 Lógica de negocio clave

**Cálculo de cuotas activas en un mes target:**
```
cuotaIndex = (target.year - first_period.year) * 12
           + (target.month - first_period.month) + 1
si 1 <= cuotaIndex <= installment_count → activa con monto = installment_amount
```

**Total de tarjeta en un mes:**
```
total = Σ (installment_amount de cuotas activas en el mes)
      + Σ (default_amount de bills con auto_debit_card_id = card.id y active = true)
```

**Sugerencia de monto al marcar pagado:**
- Si bill/card tiene `default_amount` → ese.
- Si no, promedio de los últimos 3 pagos (`status='paid'`, `amount_real != null`) en los meses previos al actual.
- Si no hay histórico → input vacío.

**Auto-debits:**
- Bills con `auto_debit_card_id` NO aparecen como ítems propios en el Mes.
- Se suman al total mensual de su tarjeta y aparecen en la sección "Débitos automáticos" del detalle de la tarjeta.

**Urgencia:**
- Solo aplica al mes actual (no a meses pasados/futuros).
- Solo aplica si `total > 0` (tarjetas con $0 no marcan urgencia).
- Solo aplica si NO está pagado.

### 2.7 PWA (web actual)
- Instalable como app desde Chrome/Safari (manifest + service worker).
- En Flutter NO aplica — sería una app nativa (.apk / .ipa).

---

## 3. Modelo de datos (Supabase)

### 3.1 Tablas

#### `bills`
```sql
id                  uuid PRIMARY KEY
user_id             uuid REFERENCES auth.users ON DELETE CASCADE
name                text NOT NULL
default_amount      numeric(12,2) NULL
day_of_month        smallint NULL CHECK (1..31)
kind                text NOT NULL CHECK (
                      'rent' | 'electricity' | 'water' | 'gas' |
                      'internet' | 'health' | 'tax' | 'consortium' |
                      'subscription' | 'other'
                    )
provider_code       text NULL              -- ref de pago a copiar al clipboard
active              boolean NOT NULL DEFAULT true
notes               text NULL
auto_debit_card_id  uuid NULL REFERENCES credit_cards ON DELETE SET NULL
url                 text NULL              -- deep link o URL web
created_at          timestamptz NOT NULL DEFAULT now()
updated_at          timestamptz NOT NULL DEFAULT now()
```

#### `credit_cards`
```sql
id           uuid PRIMARY KEY
user_id      uuid REFERENCES auth.users ON DELETE CASCADE
name         text NOT NULL
issuer       text NULL
brand        text NULL CHECK ('visa' | 'mastercard' | 'amex' | 'other')
closing_day  smallint NULL CHECK (1..31)
due_day      smallint NULL CHECK (1..31)
active       boolean NOT NULL DEFAULT true
url          text NULL
created_at   timestamptz NOT NULL DEFAULT now()
updated_at   timestamptz NOT NULL DEFAULT now()
```

#### `installment_purchases`
```sql
id                  uuid PRIMARY KEY
user_id             uuid REFERENCES auth.users ON DELETE CASCADE
credit_card_id      uuid NOT NULL REFERENCES credit_cards ON DELETE CASCADE
description         text NOT NULL
total_amount        numeric(12,2) NOT NULL
installment_count   smallint NOT NULL CHECK (> 0)
installment_amount  numeric(12,2) NOT NULL
first_period        date NOT NULL          -- primer día del mes (ej: 2026-04-01)
notes               text NULL
created_at          timestamptz NOT NULL
updated_at          timestamptz NOT NULL
```

#### `payments`
```sql
id            uuid PRIMARY KEY
user_id       uuid REFERENCES auth.users ON DELETE CASCADE
period        date NOT NULL              -- primer día del mes
kind          text NOT NULL CHECK ('bill' | 'card_total' | 'manual')
bill_id       uuid NULL REFERENCES bills ON DELETE SET NULL
card_id       uuid NULL REFERENCES credit_cards ON DELETE SET NULL
label         text NULL
amount_real   numeric(12,2) NULL
status        text NOT NULL DEFAULT 'pending' CHECK (
                'pending' | 'paid' | 'overdue' | 'skipped'
              )
paid_at       timestamptz NULL
notes         text NULL
created_at    timestamptz NOT NULL
updated_at    timestamptz NOT NULL

UNIQUE (user_id, period, bill_id)        -- un payment por bill/mes
UNIQUE (user_id, period, card_id)        -- un payment por card/mes
```

### 3.2 Row Level Security (RLS)
Todas las tablas tienen RLS habilitado y una sola policy:
```sql
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id)
```
Cada usuario solo ve y modifica sus propias filas.

### 3.3 Migrations existentes
- `0001_init.sql` — tablas iniciales + RLS.
- `0002_bills_auto_debit.sql` — agrega `bills.auto_debit_card_id`.
- `0003_bills_url.sql` — agrega `bills.url`.
- `0004_bills_kind_refactor.sql` — expande `kind` de 6 a 10 valores y migra datos existentes.
- `0005_cards_url.sql` — agrega `credit_cards.url`.

**No se necesitan nuevas migrations para el cliente Flutter** — la base ya está lista.

---

## 4. Stack recomendado para Flutter

### 4.1 Core
- **Flutter SDK** (estable, 3.x+).
- **Dart 3.x**.
- **Material 3** (default).

### 4.2 Packages clave

| Función | Package | Notas |
|---|---|---|
| Auth + DB | `supabase_flutter` | Cliente oficial. Cubre auth, queries, realtime, RLS. |
| Google OAuth | `google_sign_in` | Para login con Google. Integrar con Supabase via `signInWithIdToken`. |
| State management | `flutter_riverpod` | Recomendado por su simplicidad y testabilidad. Alternativas: bloc, provider. |
| Routing | `go_router` | Soporta deep links nativos, sticky URLs, redirects post-auth. |
| Formato i18n | `intl` | Currency formatter (es-AR, ARS), DateFormat. |
| Iconos | Material Icons (built-in) o `lucide_icons` | Para los chevrons, settings, plus, external link. |
| Open URLs / deep links | `url_launcher` | Soporta http/https + custom schemes (mercadopago://, etc.). |
| Clipboard | `flutter/services.dart` (built-in) | `Clipboard.setData(ClipboardData(text: code))`. |
| Toasts/snackbars | `ScaffoldMessenger` (built-in) | Para feedback. |
| Datos persistentes locales | `shared_preferences` o `hive` | Si se quiere caché offline. |
| Push notifications | `firebase_messaging` o `flutter_local_notifications` | Si más adelante se implementan recordatorios. |
| Debouncing forms | `flutter_hooks` (opcional) | Si se quiere lifecycle-style forms. |

### 4.3 Estructura de carpetas sugerida
```
lib/
├── main.dart                       — entry, Supabase.initialize, runApp
├── app.dart                        — MaterialApp + Router + Theme
├── theme/
│   ├── theme.dart                  — ThemeData light + dark
│   └── colors.dart                 — paleta (urgency, brand, kind)
├── core/
│   ├── supabase_client.dart        — wrapper del client
│   ├── url.dart                    — normalizeUrl + isWebUrl (port de lib/url.ts)
│   └── format.dart                 — formatCurrency, kind labels/emojis, brand chip
├── models/                         — clases Dart con freezed para Bill, CreditCard, etc.
│   ├── bill.dart
│   ├── credit_card.dart
│   ├── installment_purchase.dart
│   ├── payment.dart
│   └── enums.dart                  — BillKind, CardBrand, PaymentStatus
├── data/                           — repositorios (queries Supabase)
│   ├── bills_repository.dart
│   ├── cards_repository.dart
│   ├── installments_repository.dart
│   └── payments_repository.dart
├── domain/                         — lógica pura
│   ├── period.dart                 — PeriodKey + helpers (port de lib/installments.ts)
│   ├── month_builder.dart          — buildMonthChecklist + groupByCategory
│   └── urgency.dart                — getUrgency
├── features/
│   ├── auth/
│   │   ├── login_screen.dart       — Google + magic link
│   │   └── auth_callback.dart
│   ├── month/
│   │   ├── month_screen.dart
│   │   ├── widgets/
│   │   │   ├── month_navigation.dart
│   │   │   ├── month_summary.dart
│   │   │   ├── filter_toggle.dart
│   │   │   ├── month_item_card.dart
│   │   │   ├── calendar_tag.dart
│   │   │   ├── urgency_badge.dart
│   │   │   └── pay_button.dart
│   ├── cards/
│   │   ├── cards_screen.dart
│   │   ├── card_detail_screen.dart
│   │   ├── card_form_screen.dart
│   │   ├── installment_form_screen.dart
│   │   └── widgets/
│   │       ├── card_list_item.dart
│   │       ├── brand_chip.dart
│   │       ├── installment_progress_tag.dart
│   │       └── auto_debit_item.dart
│   └── config/
│       ├── config_screen.dart
│       ├── bills_list_screen.dart
│       └── bill_form_screen.dart
└── widgets/
    ├── bill_kind_tag.dart
    ├── confirm_delete_dialog.dart
    └── toggle_active_switch.dart
```

---

## 5. Lineamientos UI/UX

### 5.1 Lo que se conserva
- **Estructura general:** bottom nav con 3 tabs (Mes / Tarjetas / Config), sticky headers, agrupación por categoría macro en el Mes.
- **Jerarquía visual:** total del mes prominente en headers, items con tag a la izquierda + nombre + monto a la derecha.
- **Acordeón** (un solo ítem expandido) en el Mes.
- **Sticky headers** en Mes y Tarjetas.
- **Patrones de feedback:** confirm dialog para delete, toggle activa, badges de urgencia.
- **Agrupación de bills en macro-categorías** (Vivienda, Servicios, etc.) — está validado por el usuario.
- **Orden:** tarjetas primero en el Mes; en el detalle de tarjeta, cuotas antes que débitos automáticos.

### 5.2 Lo que se rediseña

#### Paleta de colores
La actual es funcional pero poco emotiva. Para la versión Flutter, la idea es:
- **Tonos más sobrios y legibles** que sigan transmitiendo lo mismo:
  - **Urgencia:** rojo (atrasada) / ámbar (vence pronto) / verde (pagado) — funciona, mantener semántica.
  - **Identidad de tarjeta:** considerar un azul medianoche / teal en vez del violeta actual.
  - **Branding de cards:** los chips VISA / Mastercard / Amex pueden ser monocromos (sin el azul/naranja saturados actuales) para no saturar la pantalla.
- Decidir entre **Material 3 con seed color** (genera paleta automática) o paleta custom.
- Sugerencia: empezar con `ColorScheme.fromSeed(seedColor: ...)` con un seed teal/indigo y ajustar manualmente los tonos de urgencia.
- **Soporte light + dark mode** con `ThemeMode.system` por default.

#### Tipografía
- En la web: `Geist Sans + Geist Mono` (Vercel).
- En Flutter: usar `Inter` o `Roboto` (default Material) — más nativos. Dejar `tabular-nums` para cifras de dinero (Dart soporta `FontFeature.tabularFigures()`).

#### Iconografía
- La versión web usa **emojis** (🏠 💡 💧 🔥 📺 etc.) en los tags de categoría.
- En Flutter, **Material Symbols** es más coherente con el SO. Reemplazar:
  - 🏠 alquiler → `Icons.home_outlined`
  - 💡 luz → `Icons.lightbulb_outline`
  - 💧 agua → `Icons.water_drop_outlined`
  - 🔥 gas → `Icons.local_fire_department_outlined`
  - 📶 internet → `Icons.wifi`
  - 🏥 salud → `Icons.local_hospital_outlined`
  - 🏛️ impuesto → `Icons.account_balance_outlined`
  - 🏢 expensas → `Icons.apartment_outlined`
  - 📺 suscripción → `Icons.subscriptions_outlined`
  - 📌 otro → `Icons.label_outline`
  - 💳 tarjeta → `Icons.credit_card`
  - 🔁 débitos aut. → `Icons.autorenew`
- Mantener consistencia outline/filled.

#### Componentes nativos a aprovechar
- **`SliverAppBar`** con `pinned: true` para el sticky header.
- **`NavigationBar`** (Material 3) para el bottom nav.
- **`ExpansionTile`** o un `AnimatedContainer` con `AnimatedSize` para el acordeón.
- **`Hero`** transitions opcional al navegar de lista a detalle de tarjeta.
- **`Switch.adaptive`** para el toggle "Solo pendientes" (se ve nativo en cada plataforma).
- **`showBottomSheet`** para el form de "Marcar como pagado" en lugar de expandir inline (más nativo en mobile).

### 5.3 Pantallas — orden de componentes (NO cambiar)

#### Mes
1. AppBar sticky:
   - Subtítulo "Mes actual / pasado".
   - Navegación de mes (chevron izq + título + chevron der opcional).
   - Resumen (Estimado / Pagado).
   - "X/Y pagadas" + Switch "Solo pendientes".
2. Body scrollable:
   - Categorías macro con header (icono + título + count).
   - Items.

#### Tarjetas (lista)
1. AppBar sticky:
   - "Tarjetas · Mes".
   - Total del mes.
2. Body: cards grandes (CardListItem).

#### Tarjetas (detalle)
1. AppBar sticky:
   - Back + nombre + brand label + ⚙ engranaje.
   - Total del mes + breakdown.
   - Botón "Ir a pagar" si tiene URL.
2. Body:
   - Compras en cuotas (icono + título + count + "+ Nueva").
   - Débitos automáticos (icono + título + count).

#### Config
1. AppBar simple con email.
2. Lista de secciones con "+" lateral.
3. Botón "Cerrar sesión" al final.

---

## 6. Servicios

### 6.1 Reutilizar (sin tocar)

| Servicio | Estado |
|---|---|
| **Supabase Database** | Mismo proyecto, mismas tablas, mismas migrations, misma RLS. La app Flutter consume directamente. |
| **Supabase Auth** | Mismo provider. Magic link y Google OAuth ya configurados. |
| **Google Cloud OAuth Client** | Reutilizar el Client ID/Secret. Hay que **agregar** la huella SHA-1 de Android y el bundle ID de iOS a Google Cloud Console para que el OAuth funcione en mobile. |
| **Migrations SQL existentes** | Ya aplicadas en producción; no se duplican. |
| **Lógica de negocio** | `lib/installments.ts`, `lib/month.ts`, `lib/url.ts` se portan a Dart 1:1 (son funciones puras). |
| **Modelo de datos** | Mismo schema; generar clases Dart equivalentes (idealmente con `freezed` + `json_serializable`). |

### 6.2 Sustituir

| Web | Flutter |
|---|---|
| **Next.js (server actions, route handlers, RSC)** | Llamadas directas a Supabase desde el cliente. No hay "server side" en Flutter — todo sucede en el dispositivo. |
| **Tailwind CSS** | `ThemeData` + `ColorScheme` + `TextStyle`. Crear constantes equivalentes. |
| **PWA (manifest, sw.js)** | App nativa empaquetada como APK (Play Store) / IPA (App Store). |
| **Vercel** | No aplica para hosting de la app. Se mantiene Vercel para la versión web; las stores manejan distribución mobile. |
| **`@supabase/ssr` + middleware** | `supabase_flutter` maneja sesión persistente con `Supabase.instance.client.auth`. No hay middleware necesario porque no hay SSR. |
| **`useActionState` + `useFormStatus`** | `Form` + `TextFormField` + `FutureBuilder` o controllers manuales con Riverpod. |
| **`revalidatePath`** | Refrescar manualmente el provider de Riverpod tras una mutación, o usar `Stream` + Supabase Realtime. |

### 6.3 Servicios nuevos opcionales
- **Push notifications** (firebase_messaging) — para los recordatorios pre-vencimiento. En Flutter es más simple que en PWA web, especialmente en iOS.
- **Local database cache** (drift / hive) — para uso offline.

---

## 7. Sincronización web ↔ Flutter

### 7.1 Modelo
Ambas apps usan **el mismo proyecto Supabase**. Los datos están centralizados. Cada cambio (insert/update/delete) en una app es inmediatamente visible en la otra apenas se hace fetch.

### 7.2 Real-time (recomendado)
Habilitar Supabase Realtime en las 4 tablas y usar `.stream()` en Flutter:

```dart
final stream = Supabase.instance.client
  .from('bills')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId);
```

Beneficios:
- Si marcás un pago en la app Flutter, la web lo refleja en tiempo real.
- Si editás una cuenta en la web, la app móvil se actualiza sin pull-to-refresh.

Costo: Supabase free tier permite 200 mensajes simultáneos, suficiente para un solo usuario.

### 7.3 Auth compartido
- **Mismo email** en ambas apps → misma `auth.users.id` → mismo conjunto de filas (RLS las protege correctamente).
- Magic link funciona idéntico (deep link a la app via `supabase_flutter`).
- Google OAuth requiere **agregar la huella Android (SHA-1) y bundle iOS** al cliente OAuth de Google Cloud (no es bloqueante, es config).

### 7.4 Conflictos
Concurrencia mínima por ser un solo usuario. Casos posibles:
- Editar la misma bill simultáneamente en ambas apps → "last write wins" (Postgres). No hay merge automático. Aceptable para este uso.
- Marcar un payment como pagado en ambas → la `UNIQUE` constraint sobre `(user_id, period, bill_id)` bloquea la 2da inserción. Manejar con `upsert` con `onConflict`.

### 7.5 Versionado de schema
- Si Flutter agrega un campo o tabla, **aplicar la migration en Supabase**, ambas apps deben adaptarse.
- Mantener las migrations en `supabase/migrations/` del repo web (ya hay 5). Coordinar releases.

### 7.6 Tipos compartidos (opcional)
Para mantener tipos sincronizados entre TypeScript (web) y Dart (Flutter), se puede usar:
- `supabase gen types typescript --project-id <id>` para web.
- Para Flutter, generar manualmente las clases Dart con `freezed` o usar herramientas como [supabase-dart-types](https://pub.dev/packages/supabase_codegen) (verificar madurez antes de adoptar).

---

## 8. Roadmap sugerido de implementación

Dividido en 6 hitos. Cada uno entregable.

### Hito 1 — Setup + Auth (3-5 días)
- `flutter create` + estructura de carpetas.
- Configurar `supabase_flutter` con la URL y el anon key (el mismo que la web).
- Pantalla de Login con magic link y "Continuar con Google".
- Configurar Google OAuth para Android + iOS (SHA-1, bundle ID, `intent-filter` para el callback de magic link).
- Persistencia de sesión (auto-login en próximos abriendos).

### Hito 2 — Navegación + Config (2-3 días)
- `go_router` con 3 tabs y rutas anidadas.
- `NavigationBar` (Material 3) con los 3 destinos.
- Pantalla de Configuración (placeholder funcional + logout).

### Hito 3 — Mes (lectura) (5-7 días)
- Repositories (bills, cards, purchases, payments).
- Provider Riverpod que combina los 4 fetches y devuelve `MonthGroup[]`.
- Port de la lógica `buildMonthChecklist` + `groupByCategory` + `getUrgency` a Dart.
- UI completa del Mes: sticky header (SliverAppBar), summary cards, filter toggle, lista agrupada con MonthItemCard.
- CalendarTag, UrgencyBadge, BillKindTag, BrandChip como widgets reutilizables.
- Navegador de meses con `?p=YYYY-MM` reflejado en URL del router.

### Hito 4 — Mes (escritura) (3-5 días)
- Acordeón con expansion controller (estado: solo uno a la vez).
- "Ir a pagar" con `url_launcher` + clipboard (copia `provider_code`).
- BottomSheet "Marcar como pagado" con sugerencia de monto.
- "Marcar como pendiente" (delete del payment).

### Hito 5 — Tarjetas (5-7 días)
- Lista (`CardListItem` + total del mes).
- Detalle (compras + débitos automáticos).
- Forms: nueva tarjeta, editar tarjeta, nueva compra, editar compra.
- Borrar tarjeta / compra con confirmación.

### Hito 6 — Configuración completa (3-5 días)
- Lista de bills con filtros mínimos.
- Form de creación / edición de bill (todos los campos, incluido auto_debit_card_id, url, provider_code).
- Borrar bill con confirmación.
- Toggle activa.

### Pulido (opcional)
- Real-time con `.stream()` en lugar de fetch manual.
- Animaciones de transición entre pantallas.
- Push notifications para vencimientos.
- Splash screen + app icon.
- Dark mode polish.
- Tests (unit + widget).
- CI/CD (GitHub Actions + Codemagic / Fastlane).

---

## 9. Otros puntos relevantes

### 9.1 Distribución
- **Android:** firmar con keystore propio, subir a Play Console, lanzar en cerrada → testing → producción.
- **iOS:** Apple Developer Program (USD 99/año), provisioning profiles, App Store Connect, TestFlight → review → producción.
- **Sin app store (Android):** podés distribuir el `.apk` directamente, útil para uso personal.

### 9.2 Magic link callback en mobile
El magic link en la web abre `https://finanzas-xavier.vercel.app/auth/callback?code=...`. Para que funcione en mobile, hay dos opciones:
- **Universal Link / App Link:** registrás un dominio en `assetlinks.json` (Android) y `apple-app-site-association` (iOS). El SO abre tu app en lugar del browser. Más limpio, requiere setup.
- **Custom scheme:** el callback es `finanzasxavier://auth/callback` y configurás un `intent-filter` Android + `CFBundleURLSchemes` iOS. Más simple para empezar.

`supabase_flutter` documenta ambos approaches.

### 9.3 Deep links a apps de pago
- En web (Chrome) muchos deep links no funcionan o requieren extensiones.
- En mobile nativo, **`url_launcher` los abre directo** si la app está instalada. Mejor experiencia.
- Si la app no está instalada, `url_launcher` retorna error — manejarlo con `try/catch` y mostrar SnackBar "App no instalada".

### 9.4 Performance y compilación
- **Flutter compila a binario nativo** (ARM/x64). Sin runtime intermedio. Mejor performance que cualquier wrapper webview.
- **Hot reload** en development = iteración rápida.
- Build sizes razonables: ~15-25 MB para una app simple en Android (más en iOS por el universal binary).

### 9.5 Reaprovechar la versión web
- **Mantener la web operativa** durante el desarrollo de Flutter — sirve como referencia visual y como backup si algo falla en mobile.
- A largo plazo, decidir si:
  - **Mantener ambas:** ambos consumen el mismo backend Supabase. Ideal si querés acceso desde computadora ocasionalmente.
  - **Discontinuar la web:** si Flutter cubre todos los casos. Solo apagar Vercel; el backend sigue.
- Si se mantienen ambas, definir cuál es la "fuente de verdad" para nuevas features (recomendación: Flutter, porque es el caso de uso primario).

### 9.6 Testing recomendado
- **Unit tests** para la lógica pura (`buildMonthChecklist`, `getUrgency`, `installmentForPeriod`, `normalizeUrl`). Son funciones puras, fáciles de testear.
- **Widget tests** para componentes clave (CalendarTag, MonthItemCard, formularios).
- **Integration tests** opcional para los flows críticos (login, marcar pagado, agregar tarjeta).

### 9.7 Internacionalización
La app es solo en español (es-AR). Si en algún momento se quiere multi-idioma:
- Usar `flutter_localizations` + `intl` con `.arb` files.
- Las claves ya están centralizadas en `BILL_KIND_LABELS`, `CARD_BRAND_LABELS`, etc. — facilita el port.

### 9.8 Privacidad y seguridad
- **Anon key de Supabase** se incluye en el binario. Es público por diseño (RLS lo protege). No incluir el `service_role` key bajo ningún concepto.
- Apple va a pedir privacy declarations en el App Store — describir que la app guarda datos personales del usuario en Supabase.
- Considerar sumar **biometric lock** (face/touch ID) opcional con `local_auth` — relevante porque la app maneja info financiera.

### 9.9 Accesibilidad
- Material widgets ya incluyen semantics correctas por default.
- Dar **aria-labels equivalentes** (`Semantics`) a los tags y badges, especialmente CalendarTag y UrgencyBadge.
- Soporte de **scaling de texto del SO** (no usar font-sizes fijos chicos).

---

## 10. Checklist de "ready to start"

Antes de comenzar el desarrollo de Flutter, asegurarse de tener:

- [ ] Cuenta de Apple Developer (iOS) — opcional inicialmente.
- [ ] Cuenta de Google Play Console (Android) — opcional inicialmente.
- [ ] Acceso al proyecto Supabase actual (URL + anon key).
- [ ] Acceso al cliente de Google Cloud OAuth (para agregar SHA-1 + bundle ID).
- [ ] Decisión sobre paleta de colores nueva (un seed color y dejar Material 3 hacer el resto, o paleta custom).
- [ ] Decisión sobre el bundle ID (ej: `com.xavier.finanzasxavier`).
- [ ] Decisión sobre el deep link scheme para auth callback (ej: `finanzasxavier://`).
- [ ] Repo git nuevo (puede ser un sibling de este, ej: `FinanzasXavier-flutter`).

---

**Última actualización:** 2026-04-26 — basado en el commit `c7b4568` (deep link support).
