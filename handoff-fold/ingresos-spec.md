# Ingresos · spec (token nuevo)

Notamos que se sumó un bloque "Ingresos" (sueldo) en mobile y también en web. Este es el lineamiento para que se vea coherente en los 3 formatos.

## Concepto

- **Ingresos** = lo que entra al mes (sueldo, freelances, otros).
- **Egresos** = lo que se paga (las cuentas fijas).
- **Saldo** = Ingresos − Estimado del mes.

## Tokens nuevos

```css
--fz-income:      #1FB87A;  /* mismo verde primary; los ingresos son "buenos" */
--fz-income-hi:   #2DD891;
--fz-income-soft: #0E2A1E;
--fz-saldo:       #2DD891;  /* saldo positivo */
--fz-saldo-neg:   #E5604A;  /* saldo negativo: usa late */
```

Categoría visual de ingresos: ícono **moneybag** 💰 (lucide `wallet` o `briefcase`), color verde, fondo `cardPaid`.

## Por formato

### Compact (mobile)

Tal como ya está en la captura: dos chips bajos en el header, debajo de "Estimado / Pagado":
- `INGRESOS  $4.640.000` (verde brillante)
- `SALDO     $3.140.939` (verde si positivo, rojo si negativo)

```
┌─────────────────────────────────┐
│ ESTIMADO    │ PAGADO            │
│ $1.499.061  │ $0                │
│             │ falta $1.499.061  │
├─────────────┼───────────────────┤
│ INGRESOS    │ SALDO             │
│ $4.640.000  │ $3.140.939        │
└─────────────────────────────────┘
```

Y en la lista: una **categoría INGRESOS** arriba de TARJETAS, mismo estilo de header (ícono · nombre · count · total a la derecha).
Items de ingreso con check verde fijo (no son "pagables") y fondo `cardPaid`.

### Expanded (Fold inner / tablet)

Mismo bloque pero en grilla 4 columnas en el header:
`ESTIMADO · PAGADO · INGRESOS · SALDO` cada uno en su card.

La sección INGRESOS arriba en la lista, con grilla 2 columnas si hay más de un ingreso.

### Desktop (web)

Header con 4 stat cards (ya está el patrón en web/Mes — solo agregar las dos nuevas):

```
┌─Estimado─┐ ┌─Pagado──┐ ┌─Ingresos─┐ ┌─Saldo───┐
│$1.499.061│ │$0       │ │$4.640.000│ │$3.140.939│
└──────────┘ └─────────┘ └──────────┘ └──────────┘
```

Sección INGRESOS arriba de TARJETAS en grid 3 columnas. Cada ingreso = card con ícono moneybag + nombre + meta `SUELDO · DÍA 10` + monto verde grande.

## Modelo de datos sugerido

```dart
class Ingreso {
  final String id;
  final String nombre;        // "Sueldo", "Freelance Acme", etc.
  final IngresoTipo tipo;     // sueldo, freelance, otro
  final int dia;              // día del mes que entra
  final double monto;
  final bool recurrente;      // se repite mes a mes
}

double saldoMes(List<Ingreso> ingresos, double estimadoEgresos) =>
  ingresos.fold(0.0, (a, i) => a + i.monto) - estimadoEgresos;
```

## Estados visuales del saldo

- `saldo > 0` → verde `--fz-saldo`
- `saldo == 0` → text-dim
- `saldo < 0` → rojo `--fz-saldo-neg` + ícono ⚠ + chip "ALERTA"
