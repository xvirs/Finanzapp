# Feature: Ingresos + Rango de Validez — Implementación en Finanzapp Web

> Doc técnico para implementar en el proyecto web (Next.js 16 / React 19 / Tailwind / Supabase).
> Schema de Supabase ya migrado vía `0006_validity_and_incomes.sql`.
> Móvil (Flutter) replica el mismo flujo en paralelo.

---

## 1. Contexto

Tres cambios se resuelven con un solo modelo:

1. **Gasto puntual de un mes**: ej. compra al contado de un sillón. Aparece solo en su mes.
2. **Sueldo / ingresos**: nueva entidad para calcular **saldo** del mes (ingresos − gastos).
3. **Histórico real**: si un gasto recurrente se carga en mayo, no aparece en abril. Si se da de baja en junio, no aparece desde julio.

**Pieza clave del modelo:** todas las entidades de plata (bills, incomes) tienen ahora un **rango de validez** (`start_period`, `end_period`):

| Caso | Modelado como |
|------|---------------|
| Gasto puntual en M | `start_period = end_period = M` |
| Recurrente activo | `start_period = mes_creación`, `end_period = NULL` |
| Recurrente dado de baja | `end_period = mes anterior al de baja` |

Las cuotas (`installment_purchases`) ya tenían rango natural (`first_period` + `installment_count`); no cambian.

**Convención de fechas:** `start_period` y `end_period` son de tipo `date` y siempre apuntan al **primer día del mes** (`YYYY-MM-01`).

---

## 2. Schema de referencia (post-migración)

### Tabla `bills` (modificada)

Columnas nuevas:

| Columna | Tipo | Nullable | Notas |
|---------|------|----------|-------|
| `start_period` | `date` | NO | Primer día del mes en que aplica |
| `end_period` | `date` | SÍ | Primer día del último mes válido. NULL = activo indefinido |

Constraints: ambas son primer día del mes; `end_period >= start_period`.

### Tabla `incomes` (nueva)

```ts
{
  id: string;                                              // uuid
  user_id: string;                                         // uuid
  name: string;
  default_amount: number | null;                           // numeric(12,2)
  day_of_month: number | null;                             // 1..31
  kind: 'salary' | 'freelance' | 'rental' | 'other';
  start_period: string;                                    // 'YYYY-MM-01'
  end_period: string | null;                               // 'YYYY-MM-01' | null
  active: boolean;                                         // default true
  notes: string | null;
  created_at: string;
  updated_at: string;
}
```

RLS: `incomes_owner_all` — solo el dueño ve/modifica.

### Cuotas: sin cambios

`installment_purchases` mantiene `first_period` + `installment_count`. La validez del registro en un mes M se calcula:

```
first_period <= M < first_period + installment_count meses
```

---

## 3. Regenerar tipos TypeScript

Después de la migración:

```bash
# Asumiendo proyecto Supabase linkeado
supabase gen types typescript --linked > src/lib/database.types.ts
```

Si se generan localmente desde el proyecto remoto, regenerar e importar `Database['public']['Tables']['incomes']['Row']` y verificar que `bills` ahora tenga `start_period` / `end_period`.

---

## 4. Capa de datos (queries)

### 4.1. Listar bills válidos en un mes M

`M` es un string `'YYYY-MM-01'`.

```ts
const { data: bills } = await supabase
  .from('bills')
  .select('*')
  .eq('user_id', userId)
  .eq('active', true)
  .lte('start_period', M)
  .or(`end_period.is.null,end_period.gte.${M}`)
  .order('day_of_month', { ascending: true });
```

### 4.2. Listar incomes válidos en un mes M

```ts
const { data: incomes } = await supabase
  .from('incomes')
  .select('*')
  .eq('user_id', userId)
  .eq('active', true)
  .lte('start_period', M)
  .or(`end_period.is.null,end_period.gte.${M}`)
  .order('day_of_month', { ascending: true });
```

### 4.3. Cuotas válidas en un mes M (sin cambio)

Lógica existente: `first_period <= M` y `M < first_period + installment_count`.

### 4.4. Crear bill / income

- `start_period`: default = mes en curso (`YYYY-MM-01`). Editable en el form.
- `end_period`: default `null`. Si el usuario activa el toggle **"Solo este mes"**, set `end_period = start_period`.

### 4.5. Editar bill / income

Permitir editar `start_period` y `end_period`. Validar en cliente y server: `end_period >= start_period`.

### 4.6. "Eliminar" bill / income (soft-delete condicional)

```ts
async function deleteBillOrIncome(table: 'bills' | 'incomes', id: string) {
  // 1. ¿Tiene pagos asociados? (solo aplica a bills)
  if (table === 'bills') {
    const { count } = await supabase
      .from('payments')
      .select('id', { count: 'exact', head: true })
      .eq('bill_id', id);

    if ((count ?? 0) > 0) {
      // Soft-delete: end_period = mes anterior al actual
      const prevMonth = firstDayOfPreviousMonth(); // helper: 'YYYY-MM-01'
      await supabase.from('bills').update({ end_period: prevMonth }).eq('id', id);
      return;
    }
  }

  // 2. Sin historial → DELETE real
  await supabase.from(table).delete().eq('id', id);
}
```

Para `incomes`, hoy no hay tabla de "pagos de ingresos", así que es DELETE directo. Si en el futuro se agrega, replicar el patrón.

### 4.6.bis. Helper: primer día del mes anterior

```ts
function firstDayOfPreviousMonth(today = new Date()): string {
  const d = new Date(today.getFullYear(), today.getMonth() - 1, 1);
  return d.toISOString().slice(0, 10); // 'YYYY-MM-01'
}
```

---

## 5. Lógica de navegación entre meses

### 5.1. Reglas (acordadas con el producto)

Un mes M es **navegable** si tiene al menos uno de:

- bill con `active = true AND start_period <= M AND (end_period IS NULL OR end_period >= M)`
- income con `active = true AND start_period <= M AND (end_period IS NULL OR end_period >= M)`
- installment_purchase con `first_period <= M < first_period + installment_count meses`
- payment con `period = M`

**Tope a futuro:** cap de **12 meses** desde hoy. Más allá de eso, la navegación se desactiva aunque haya recurrentes activos.

**Empty state:** si el usuario no tiene NADA cargado, el mes actual sigue visible (con un empty state "Cargá tu primer gasto / ingreso") y las flechas aparecen solo cuando ya hay datos navegables.

### 5.2. Implementación sugerida

Crear un hook/loader `useNavigableMonths(userId)` que devuelva `{ minMonth, maxMonth }`:

```ts
async function getNavigableRange(userId: string): Promise<{ min: string; max: string }> {
  const today = firstDayOfMonth();             // 'YYYY-MM-01'
  const cap = monthsFromNow(12);               // 'YYYY-MM-01' + 12 meses

  // 1. Min: primer mes con contenido
  // - bills.start_period mínimo (si hay)
  // - incomes.start_period mínimo (si hay)
  // - installment_purchases.first_period mínimo (si hay)
  // - payments.period mínimo (si hay)
  // -> Math.min de todos ellos. Si no hay ninguno, min = today.

  // 2. Max: último mes con contenido (cap a today + 12 meses)
  // - max(today, lastBillEndOrInf, lastIncomeEndOrInf, lastInstallmentLast, lastPaymentPeriod)
  // - clip a today + 12 meses.
  // -> Si no hay nada activo a futuro, max = today.

  // Implementación con 4 queries paralelas (count o min/max) y agregación en memoria.
  // ...
  return { min, max };
}
```

`useMonthNavigation()` consume eso y desactiva las flechas:

```tsx
<Button disabled={currentMonth <= minMonth} onClick={prevMonth}>←</Button>
<Button disabled={currentMonth >= maxMonth} onClick={nextMonth}>→</Button>
```

Cachear el rango por sesión y refrescar tras crear/editar/eliminar gastos o ingresos (invalidación con SWR / React Query / Server Actions, según el patrón actual).

---

## 6. Cambios en pantallas

### 6.1. Pantalla "Mes" (home)

- **Resumen:** ahora se muestran **3 números**:
  - **Ingresos del mes** (suma de `default_amount` de incomes válidos en M).
  - **Gastos del mes** (suma de bills válidos + cuotas activas en M, calculado como hoy).
  - **Saldo** (ingresos − gastos). Coloreado: verde si > 0, rojo si < 0.
- **Listado de gastos:** sigue como hoy. Indicador sutil para los que tienen `start_period = end_period` (ej: badge "una sola vez" o ícono).
- **Sección Ingresos del mes:** nuevo bloque (colapsable o aparte) listando los ingresos del mes. Cada uno muestra nombre, monto, día y tipo.
- **Navegación:** flechas ←/→ usan `{ minMonth, maxMonth }` del hook.
- **Empty state:** si no hay nada en M y M = mes actual, mostrar CTA "Cargá tu primer ingreso o gasto". Las flechas se ocultan/desactivan hasta que haya algo.

### 6.2. Form "Nuevo gasto / Editar gasto" (bills)

Agregar:

- **Selector "Desde"** (`start_period`). Default: mes actual. Selector mes/año (`YYYY-MM`).
- **Toggle "Solo este mes"**. Si está activado:
  - Setea `end_period = start_period` al guardar.
  - Oculta el siguiente campo.
- **Selector "Hasta" (opcional)** (`end_period`). Default: vacío (= NULL = activo indefinido). Solo visible si el toggle de arriba está apagado.
- Validación cliente: `end_period >= start_period` cuando ambos están seteados.

### 6.3. Form "Nuevo ingreso / Editar ingreso" (incomes) — **NUEVO**

Estructura simétrica a bills:

- Nombre (text, required)
- Monto sugerido (number, optional)
- Día del mes (1..31, optional)
- Tipo: select (`salary` / `freelance` / `rental` / `other`)
- Desde (`start_period`, default: mes actual)
- Toggle "Solo este mes" (analogía con bills)
- Hasta (`end_period`, opcional)
- Notas (textarea, optional)

### 6.4. Configuración

Agregar nueva sección **"Ingresos"** en el menú, simétrica a "Cuentas Fijas":

- Listado de incomes activos (filtrado por `active=true AND end_period IS NULL`) y/o todos según preferencia.
- CTA "+ Nuevo ingreso" → abre el form de 6.3.
- Cada item permite Editar / Eliminar (soft o hard según 4.6).

---

## 7. Comportamiento esperado (casos)

| Caso | Resultado esperado |
|------|--------------------|
| Cargo "Netflix" en mayo 2026 (recurrente sin fin) | Aparece en mayo y todos los meses futuros (hasta el cap). NO aparece en abril ni antes. |
| Cargo "Sillón" puntual en mayo 2026 | Aparece solo en mayo. No en abril ni junio. |
| Doy de baja "Netflix" en julio (con pagos previos) | Soft-delete: `end_period = junio 2026`. Aparece hasta junio inclusive, no en julio. Se conserva el histórico de pagos. |
| Doy de baja "Netflix" recién creado, sin pagos | DELETE real. Desaparece de todo. |
| Cargo sueldo desde marzo 2026 | Aparece en marzo en adelante. Saldo del mes pasa a ingresos − gastos. |
| Usuario nuevo, sin nada cargado | Pantalla actual visible con empty state. Flechas desactivadas. |
| Usuario solo con un puntual en mayo | Solo mayo navegable. Flechas desactivadas. |
| Usuario con un recurrente desde enero | Enero..hoy+12 navegables. |

---

## 8. Edge cases y validaciones

- **Backdating al crear:** permitir `start_period` < mes actual (caso "olvidé cargar Netflix en marzo, lo cargo ahora desde marzo"). No bloquear.
- **Edit que recorta histórico:** si el usuario edita un bill y achica `start_period` o adelanta `end_period`, los `payments` viejos asociados se conservan en la DB pero ya no se muestran en su mes (porque la query filtra por validez). Decisión: aceptarlo (es comportamiento esperado).
- **Mes futuro fuera del cap:** las flechas de navegación nunca permiten pasar `today + 12 meses`, aunque haya recurrentes activos a perpetuidad.
- **Tipos de income que no aplican:** mientras `kind` esté en el enum, OK. Si en el futuro se agrega un tipo nuevo, requiere migración + actualización del select.
- **Día del mes vs. fecha real de cobro/pago:** `day_of_month` es informativo. No condiciona la lógica de validez.

---

## 9. Testing manual antes de mergear

- [ ] Crear un bill recurrente desde mayo 2026 → aparece en mayo, no en abril.
- [ ] Crear un bill puntual en mayo → aparece solo en mayo.
- [ ] Editar el puntual → cambiar a recurrente (toggle off, end_period vacío) → aparece desde mayo en adelante.
- [ ] Crear un income → aparece en el mes actual y futuros.
- [ ] Saldo del mes muestra correctamente ingresos − gastos.
- [ ] Eliminar un bill con pagos → queda como soft-delete; el pago histórico sigue visible en su mes.
- [ ] Eliminar un bill sin pagos → desaparece completamente.
- [ ] Navegación: ir al mes más antiguo → flecha ← se desactiva. Ir 12 meses adelante → flecha → se desactiva.
- [ ] Empty state: con cuenta nueva, mes actual visible sin flechas.
- [ ] Validación: intentar guardar `end_period < start_period` falla en cliente y server.

---

## 10. Pendientes que NO van en este PR

- Reportes anuales / gráficos.
- Múltiples monedas.
- Import/export JSON.
- Tipo `debit` en cards.

---

## 11. Estructura de PR sugerida

1. **PR 1 — Schema y tipos:** regenerar `database.types.ts` y actualizar imports.
2. **PR 2 — Bills con validez:** form + queries + indicador de "puntual" + soft-delete.
3. **PR 3 — Incomes:** tabla, form, sección en Configuración, repositorio.
4. **PR 4 — Pantalla del mes:** 3 números + navegación bounded + empty state.

Mergeables por separado siempre que cada uno deje la app en estado coherente. Si se prefiere un solo PR, mantener el orden interno.
