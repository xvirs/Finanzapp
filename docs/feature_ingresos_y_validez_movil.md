# Feature: Ingresos + Rango de Validez — Plan implementacional móvil (Flutter)

> Plan concreto de archivos y orden para aplicar los cambios en `Finanzapp` (Flutter).
> Backend ya migrado (`0006_validity_and_incomes.sql`).
> Web se implementa en paralelo.

---

## Stack confirmado

- **State management:** `flutter_bloc` (BLoC). Inyección por constructor.
- **Router:** `go_router` con `StatefulShellRoute` de 3 ramas (Mes / Cards / Config).
- **Modelos:** Freezed + `json_serializable`.
- **Realtime:** `RealtimeService` central con stream → BLoCs lo escuchan y disparan refresh silencioso (debounce 250ms).
- **Repos:** singleton instanciados en `app.dart`, inyectados por constructor a cada BLoC.

---

## Fases

### Fase 1 — Modelo + repo de Bills con rango de validez

**Archivos a tocar:**
- `lib/models/bill.dart` → agregar campos `startPeriod` (PeriodKey, requerido) y `endPeriod` (PeriodKey?, opcional).
- `lib/models/bill.g.dart` y `bill.freezed.dart` → regenerar con `dart run build_runner build --delete-conflicting-outputs`.
- `lib/data/bills_repository.dart`:
  - `fetchAllActive()` → cambiar a `fetchActiveForPeriod(period)` con filtro `start_period <= period AND (end_period IS NULL OR end_period >= period)`. Mantener `fetchAll()` para Config (lista completa).
  - `softDeleteOrDelete(billId)` → método nuevo que decide DELETE vs `end_period = mes anterior` según existencia de pagos.
  - `saveBill()` → asegurar que `start_period` se persista; default mes actual si no se pasa.
- `lib/domain/period_key.dart` (si existe) → verificar helpers `firstDayOfMonth()`, `previousMonth()`, etc.

**Test rápido:** crear un bill desde la UI, verificar en Supabase que `start_period` quedó seteado al mes actual.

---

### Fase 2 — Modelo + repo de Incomes (nuevo)

**Archivos a crear:**
- `lib/models/income.dart` — Freezed con campos:
  - `id`, `userId`, `name`, `defaultAmount`, `dayOfMonth`, `kind` (IncomeKind enum), `startPeriod`, `endPeriod`, `active`, `notes`, `createdAt`, `updatedAt`.
- `lib/models/enums.dart` — agregar `IncomeKind` con valores `salary`, `freelance`, `rental`, `other` (con `@JsonValue`).
- `lib/data/incomes_repository.dart` — espejo de `bills_repository.dart`:
  - `fetchAllActive()`, `fetchActiveForPeriod(period)`, `fetchAll()`, `fetchById(id)`, `saveIncome()`, `softDeleteOrDelete(id)` (en incomes hoy es siempre DELETE, pero dejamos el método con la firma para consistencia futura).

**Archivos a modificar:**
- `lib/core/realtime_service.dart` — agregar suscripción al canal `incomes` para que el stream emita cambios de esa tabla.
- `lib/app.dart` — instanciar `IncomesRepository` y pasarlo en DI a los BLoCs que lo necesiten.

---

### Fase 3 — Form de Bill (UI) con rango de validez y soft-delete

**Archivos a tocar:**
- `lib/features/config_settings/presentation/bill_form_screen.dart`:
  - Agregar campo **"Desde"** (`start_period`): selector mes/año, default mes actual.
  - Agregar **toggle "Solo este mes"**:
    - Activo → setea `end_period = start_period` al guardar; oculta el siguiente campo.
    - Apagado (default) → muestra campo "Hasta (opcional)".
  - Agregar campo **"Hasta"** (`end_period`): selector mes/año o vacío.
  - Validación cliente: `end_period >= start_period`.
  - En modo edición: precargar valores existentes.
- `lib/features/config_settings/presentation/bills_list_screen.dart` o similar:
  - Botón eliminar → llama `softDeleteOrDelete(billId)` en vez del DELETE actual.
  - Mostrar badge sutil ("una sola vez") en bills donde `start_period == end_period`.
- `lib/features/config_settings/presentation/bloc/bills_list_bloc.dart`:
  - Manejar el caso soft-delete (refrescar lista; el soft-deleted desaparece porque `fetchAll()` puede filtrar `end_period < hoy` o mostrar todo según preferencia — confirmar UX).
- `lib/widgets/` — crear `MonthYearPicker` reutilizable si no existe (lo van a usar también incomes).

**Decisión UX a confirmar al implementar:** ¿la lista de Cuentas Fijas en Config muestra solo activos vigentes (`end_period IS NULL OR end_period >= mes_actual`) o todos? Recomiendo activos vigentes con un toggle "Mostrar archivados".

---

### Fase 4 — CRUD de Incomes (nuevo, simétrico a bills)

**Archivos a crear:**
- `lib/features/config_settings/presentation/incomes_list_screen.dart` — espejo de `bills_list_screen.dart`.
- `lib/features/config_settings/presentation/income_form_screen.dart` — espejo de `bill_form_screen.dart` con campos:
  - Nombre, monto sugerido, día del mes, tipo (`IncomeKind`), Desde, toggle "Solo este mes", Hasta, Notas.
- `lib/features/config_settings/presentation/bloc/incomes_list_bloc.dart` — espejo de `bills_list_bloc.dart`.
- `lib/features/config_settings/presentation/bloc/income_form_bloc.dart` (si los forms tienen su propio BLoC) — chequear patrón actual.

**Archivos a modificar:**
- `lib/features/config_settings/presentation/config_screen.dart` — agregar entrada **"Ingresos"** entre las opciones del menú.
- `lib/router.dart` — agregar rutas `/config/incomes`, `/config/incomes/new`, `/config/incomes/:id` dentro de la rama Config.

**Iconografía:** definir un ícono para `IncomeKind` (similar a `BillKindIcon`). Crear `lib/widgets/income_kind_icon.dart`.

---

### Fase 5 — Lógica de mes: incluir incomes y filtrar por validez

**Archivos a tocar:**
- `lib/domain/month_builder.dart` (lib/features/month/domain/...):
  - Recibir como input también la lista de **incomes válidos en el mes**.
  - Filtrar bills por validez (`start <= period AND (end IS NULL OR end >= period)`) — si los repos ya devuelven filtrado por período, esto solo es passthrough.
  - Generar un nuevo `MonthGroup` o un struct `MonthIncomeSummary` con los ingresos.
- `lib/features/month/domain/month_item.dart` — si se quiere modelar income como item en una lista, agregar `MonthIncomeItem`. Caso contrario, mantener separado.
- `lib/features/month/presentation/bloc/month_bloc.dart`:
  - En `_loadMonth(period)`, además de bills/cards/installments/payments, levantar `incomesRepo.fetchActiveForPeriod(period)`.
  - Calcular `MonthSummary` con 3 totales: `totalIncome`, `estimatedExpenses`, `balance` (= income - expenses).
  - Calcular rango navegable (`navigableMin`, `navigableMax`) con la lógica:
    - **min**: el menor `start_period` entre bills, incomes, installments, payments del usuario. Si no hay datos → mes actual.
    - **max**: el mayor entre bills/incomes con `end_period` o cap a `mes_actual + 12 meses` para los activos sin fin. Las cuotas extienden hasta `first_period + installment_count - 1`. Cap absoluto: `mes_actual + 12 meses`.
  - Exponer `navigableMin`/`navigableMax` en `MonthBlocState` para el header.

**Implementación sugerida del rango:** un método `_computeNavigableRange()` que hace 4 queries paralelas (`min(start_period)` en bills/incomes, `min(period)` en payments, `min(first_period)` en installments) y calcula el min absoluto. Para max similar pero con cap. Cachear durante la sesión y refrescar tras mutaciones (con el realtime ya enganchado).

---

### Fase 6 — UI del Mes: 3 números, bounded nav, empty state

**Archivos a tocar:**
- `lib/features/month/presentation/widgets/month_header_section.dart`:
  - Reemplazar el resumen actual (estimado/pagado) por 3 cifras: **Ingresos**, **Gastos**, **Saldo**. Saldo coloreado según signo.
  - Mantener barra de progreso de pagos (estimado vs pagado) en una línea aparte si se quiere conservar.
- Selector de mes (parte del `MonthHeaderSection` o widget aparte):
  - Flecha ← deshabilitada si `currentPeriod <= navigableMin`.
  - Flecha → deshabilitada si `currentPeriod >= navigableMax`.
- `lib/features/month/presentation/month_screen.dart`:
  - Renderizar nuevo `MonthIncomeSection` arriba del listado de gastos (puede ser un grupo colapsable similar a los actuales).
  - Empty state: si `summary` está vacío y no hay incomes, mostrar CTA "Cargá tu primer gasto o ingreso" y ocultar flechas (o mantenerlas grises).
- Indicador "una sola vez" en `MonthItemCard` (badge pequeño en la esquina) cuando el bill subyacente es puntual.

---

## Convenciones a respetar

- **Naming en JSON:** snake_case en Supabase (`start_period`, `end_period`, `default_amount`). Freezed mapea con `@JsonKey(name: '...')` o el converter del proyecto.
- **PeriodKey:** ya existe en `lib/domain/period_key.dart`. Reusar — no inventar otro tipo.
- **Soft-delete vs DELETE:** la decisión va en el repo, no en el BLoC. El BLoC solo llama `softDeleteOrDelete()`.
- **Realtime:** después de cualquier mutación (save/delete) NO hace falta refrescar manualmente — `RealtimeService` ya emite y los BLoCs ya escuchan.
- **Tests:** el proyecto no tiene tests automáticos extensivos; validación es por `flutter analyze` + smoke test manual.

---

## Orden recomendado y commits

1. **Commit 1** — Fase 1: bill model + repo (con regen de Freezed).
2. **Commit 2** — Fase 2: income model + repo + realtime.
3. **Commit 3** — Fase 3: bill form (validez + soft-delete) + lista con badge.
4. **Commit 4** — Fase 4: incomes CRUD completo (screens + router + config entry).
5. **Commit 5** — Fase 5: MonthBuilder + MonthBloc (lógica).
6. **Commit 6** — Fase 6: MonthHeader + nav bounded + empty state.

Cada commit deja la app **compilando** y `flutter analyze` limpio.

---

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Bills viejos sin `start_period` rompen el parsing | El backfill de la migración 0006 ya seteó `start_period` para todos los bills existentes. Al levantar la app por primera vez post-migración no debería haber NULL. Si igual hay edge case, default en parser a `firstDayOfMonth(createdAt)`. |
| Cambio en `fetchAllActive` rompe pantallas que lo consumían | Hacer `grep` antes de remover. Si hay otros callers además de Mes, mantener el método legacy y crear `fetchActiveForPeriod` como nuevo. |
| Realtime no se gatilla para `incomes` (canal nuevo) | Verificar que la tabla esté incluida en la suscripción de `RealtimeService` y que la replicación esté habilitada en Supabase Studio (Database → Replication). |
| Filtro de períodos en queries genera N+1 al navegar meses | El filtro es server-side, una sola query por mes. Sin riesgo. |
| MonthYearPicker no existe en el proyecto | Crearlo en `lib/widgets/` como reusable. Tope visual: bounded por `navigableMin`/`navigableMax` también en el picker. |

---

## Pendientes que NO van en este sprint

- Reportes anuales / gráficos.
- Múltiples monedas.
- Import/export JSON.
- Tipo `debit` en cards.

---

## Checklist final antes de mergear cada commit

- [ ] `flutter analyze` sin errores ni warnings nuevos.
- [ ] App compila en iOS y Android (al menos un build de debug).
- [ ] Smoke test manual del flujo cambiado.
- [ ] Sin TODOs nuevos sin issue asociado.
