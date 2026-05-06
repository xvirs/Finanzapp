# Feature: Ingresos + Rango de Validez — Guía de migración Supabase

> Documento técnico para aplicar el cambio de schema en Supabase.
> Consume: web (FinanzappWeb) y móvil (Finanzapp/Flutter).
> Migración a aplicar: `0006_validity_and_incomes.sql`.

---

## Contexto

Estamos agregando **3 cambios** que se resuelven con **1 sola migración**:

1. **Gasto puntual de un mes** (ej: "este mes me compro un sillón al contado").
2. **Sueldo / ingresos del usuario** para calcular saldo del mes.
3. **Histórico real**: que un gasto recurrente cargado en mayo no aparezca en abril.

El cambio clave: agregamos `start_period` y `end_period` a la tabla `bills` (gastos recurrentes) y creamos la tabla `incomes` con la misma estructura.

| Caso | Cómo se modela |
|------|---------------|
| Gasto puntual del mes M | `start_period = end_period = M` |
| Recurrente activo (lo de hoy) | `start_period = mes_creación`, `end_period = NULL` |
| Recurrente dado de baja | `end_period = mes anterior al de baja` (soft-delete UI) |
| Sueldo recurrente | Igual lógica, en tabla `incomes` |

**Convención existente que mantenemos:** las fechas de "mes" se almacenan como `date` siempre apuntando al **primer día del mes** (ej: `2026-05-01` = "Mayo 2026"), igual que `payments.period` y `installment_purchases.first_period`.

---

## Pre-checks antes de migrar

1. **Backup.** Andá a Supabase → Project Settings → Database → Backups → Create manual backup. Esperá a que termine antes de seguir.
2. **Confirmá que estás en el entorno correcto.** Si tenés staging y prod separados, aplicá primero en staging.
3. **Verificá que ningún cliente está escribiendo activamente.** El `ALTER TABLE` toma un lock breve sobre `bills`.
4. **Migrations previas aplicadas.** Verificá:

   ```sql
   select count(*) from public.bills;
   select column_name from information_schema.columns
     where table_schema='public' and table_name='bills'
     order by ordinal_position;
   ```

   Tenés que ver las columnas: `id, user_id, name, default_amount, day_of_month, kind, provider_code, active, auto_debit_card_id, notes, url, created_at, updated_at`. Si no, parate y revisá qué migraciones faltan.

---

## SQL de migración

Crear archivo: `supabase/migrations/0006_validity_and_incomes.sql`

```sql
-- 0006_validity_and_incomes.sql
-- Rango de validez en bills (start_period / end_period) + nueva tabla incomes.

-- =============================================================================
-- 1. BILLS — agregar rango de validez
-- =============================================================================
-- start_period: primer mes en que aplica este gasto (YYYY-MM-01). NOT NULL post-backfill.
-- end_period:   último mes en que aplica. NULL = activo indefinidamente.
--               Cuando el usuario "elimina" un bill activo desde la UI, se setea
--               end_period al mes anterior (soft-delete) para preservar el histórico.

ALTER TABLE public.bills
  ADD COLUMN start_period date,
  ADD COLUMN end_period   date;

-- Backfill: bills existentes se consideran activos desde su mes de creación.
UPDATE public.bills
   SET start_period = date_trunc('month', created_at)::date
 WHERE start_period IS NULL;

ALTER TABLE public.bills
  ALTER COLUMN start_period SET NOT NULL;

-- Constraints
ALTER TABLE public.bills
  ADD CONSTRAINT bills_start_period_first_day
    CHECK (extract(day from start_period) = 1);

ALTER TABLE public.bills
  ADD CONSTRAINT bills_end_period_first_day
    CHECK (end_period IS NULL OR extract(day from end_period) = 1);

ALTER TABLE public.bills
  ADD CONSTRAINT bills_end_period_after_start
    CHECK (end_period IS NULL OR end_period >= start_period);

-- Índice para queries de mes (válido en M)
CREATE INDEX bills_user_period_range_idx
  ON public.bills (user_id, start_period, end_period)
  WHERE active;

-- =============================================================================
-- 2. INCOMES — ingresos del usuario (sueldo, freelance, alquiler que cobra, etc.)
-- =============================================================================
-- Mismo patrón que bills, pero del lado del haber.

CREATE TABLE public.incomes (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  name            text not null,
  default_amount  numeric(12, 2),
  day_of_month    smallint check (day_of_month between 1 and 31),
  kind            text not null check (kind in ('salary', 'freelance', 'rental', 'other')),
  start_period    date not null check (extract(day from start_period) = 1),
  end_period      date check (end_period IS NULL OR extract(day from end_period) = 1),
  active          boolean not null default true,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint incomes_end_period_after_start
    check (end_period IS NULL OR end_period >= start_period)
);

CREATE INDEX incomes_user_id_idx
  ON public.incomes(user_id)
  WHERE active;

CREATE INDEX incomes_user_period_range_idx
  ON public.incomes(user_id, start_period, end_period)
  WHERE active;

CREATE TRIGGER incomes_set_updated_at
  BEFORE UPDATE ON public.incomes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- 3. RLS — cada usuario solo ve sus ingresos
-- =============================================================================
ALTER TABLE public.incomes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "incomes_owner_all"
  ON public.incomes
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

---

## Cómo aplicar

### Opción A — Supabase CLI (recomendado, queda versionado)

```bash
cd /Users/xavier/Proyectos/FinanzappWeb
# Crear archivo
$EDITOR supabase/migrations/0006_validity_and_incomes.sql
# Pegar el SQL de arriba, guardar, y aplicar:
supabase db push
```

### Opción B — Supabase Studio (SQL Editor)

1. Abrí https://supabase.com/dashboard → tu proyecto → SQL Editor.
2. Pegá el SQL completo del bloque de arriba.
3. Run.
4. Después subí el mismo archivo a `supabase/migrations/0006_validity_and_incomes.sql` en el repo `FinanzappWeb` para no perder versionado.

---

## Verificación post-migración

Corré estas queries — todas deben pasar:

```sql
-- 1. start_period existe en todos los bills (no quedó nada en NULL)
select count(*) as bills_total,
       count(start_period) as bills_with_start,
       count(*) filter (where end_period is not null) as bills_with_end
  from public.bills;
-- bills_total y bills_with_start deben ser iguales.

-- 2. Todos los start_period son primer día del mes
select count(*) from public.bills where extract(day from start_period) <> 1;
-- Debe devolver 0.

-- 3. La tabla incomes existe y está vacía
select count(*) from public.incomes;
-- Debe devolver 0.

-- 4. RLS activo en incomes
select tablename, rowsecurity
  from pg_tables
 where schemaname = 'public' and tablename = 'incomes';
-- rowsecurity debe ser true.

-- 5. Probar inserción de income (con tu user_id real)
insert into public.incomes (user_id, name, default_amount, kind, start_period)
values ('<TU-AUTH-UID>', 'Sueldo prueba', 100000, 'salary', '2026-05-01')
returning id, name;
-- Debe insertar OK. Después borralo:
delete from public.incomes where name = 'Sueldo prueba';
```

---

## Patrón de query: gastos válidos en un mes M

Esta es la query que **web y móvil** tienen que adoptar al levantar bills/incomes para una pantalla de mes (`M = '2026-05-01'` por ejemplo):

```sql
select *
  from public.bills
 where user_id = $1
   and active = true
   and start_period <= $2
   and (end_period is null or end_period >= $2);

select *
  from public.incomes
 where user_id = $1
   and active = true
   and start_period <= $2
   and (end_period is null or end_period >= $2);
```

**Cuotas** (`installment_purchases`) ya tienen rango natural por `first_period` + `installment_count`. La query existente sigue siendo válida; solo hay que asegurar que filtra meses fuera de rango.

---

## Soft-delete en bills (no es DB, es comportamiento de la app)

> Importante para web y móvil: este bloque no toca la DB, pero condiciona cómo deben llamar al backend.

Cuando el usuario "elimina" un `bill` activo desde la UI:

- Si **tiene pagos asociados** (`payments where bill_id = X`): NO borrar. Hacer:
  ```sql
  update public.bills
     set end_period = date_trunc('month', current_date - interval '1 month')::date
   where id = $1;
  ```
  (esto deja end_period = mes anterior al actual, así no aparece más en el mes actual ni futuros, pero queda en histórico).
- Si **no tiene pagos**: hacer DELETE normal.

Misma lógica para `incomes`.

Esto se decide en la app (web/móvil), no acá. El schema soporta ambos casos.

---

## Rollback (si algo sale mal)

Solo en emergencia, antes de que la app empiece a usar las nuevas columnas:

```sql
DROP TABLE IF EXISTS public.incomes;

ALTER TABLE public.bills DROP CONSTRAINT IF EXISTS bills_start_period_first_day;
ALTER TABLE public.bills DROP CONSTRAINT IF EXISTS bills_end_period_first_day;
ALTER TABLE public.bills DROP CONSTRAINT IF EXISTS bills_end_period_after_start;
DROP INDEX IF EXISTS bills_user_period_range_idx;
ALTER TABLE public.bills DROP COLUMN IF EXISTS start_period;
ALTER TABLE public.bills DROP COLUMN IF EXISTS end_period;
```

Después restaurá el backup si era prod.

---

## Checklist final

- [ ] Backup manual hecho en Supabase.
- [ ] Migración `0006_validity_and_incomes.sql` aplicada sin errores.
- [ ] Las 5 queries de verificación pasan.
- [ ] Archivo `0006_validity_and_incomes.sql` commiteado en `FinanzappWeb/supabase/migrations/`.
- [ ] Avisar a web y móvil: la migración está aplicada, pueden empezar a usar las nuevas columnas y tabla.
