# Mes · adaptativo

## Compact (<600 dp)

Sin cambios. Lo que ya está en producción (captura SM N980F):
- Header con flechas mes
- 2×2 stat cards: Estimado / Pagado / **Ingresos** / **Saldo**
- Chip "0/10 pagadas" + barra
- Filter tabs: Todos / Pendientes / Atrasadas
- Lista vertical de categorías con `CardItemTile`
- Bottom nav: Mes · Tarjetas · Config

## Expanded (600–1023 dp · Fold inner)

Layout 2 columnas:

```
┌──────┬───────────────────────────────────┐
│ RAIL │ MAIN                              │
│  88  │                                   │
│      │ Header (← Mayo 2026 → / + Nueva)  │
│ Mes  │ Stats grid 4 col:                 │
│ Tar  │ [Estim][Pagado][Ingresos][Saldo]  │
│ Cfg  │                                   │
│      │ Categorías en grid 2 col:         │
│      │  • INGRESOS                       │
│      │    [sueldo card]                  │
│      │  • TARJETAS (2)         $420.953  │
│      │    [VISA] [MP]                    │
│      │  • VIVIENDA (2)         $940.307  │
│      │    [Alquiler] [Expensas]          │
│      │  ...                              │
└──────┴───────────────────────────────────┘
```

Si hay espacio para `hinge`, evitar grilla cruzando la bisagra. Usar `TwoPane` package o detectar el `displayFeature` y dejar gutter.

Atención inmediata: como **banner sticky arriba** del scroll (no aside).

## Desktop (≥1024 dp)

Layout 3 columnas (web ya implementado):

```
┌─────────┬──────────────────────────┬──────────┐
│ SIDEBAR │ MAIN                     │ ASIDE    │
│ 240     │                          │ 300      │
│         │ Header                   │ Atención │
│ Logo    │ Stats 4 col              │ inmediata│
│ Nav     │                          │          │
│ User    │ INGRESOS                 │ Próx 7d  │
│         │  [sueldo]                │          │
│         │ TARJETAS (2)             │ Distrib  │
│         │  [VISA][MP][+slot]       │ del mes  │
│         │ VIVIENDA (2)             │          │
│         │  [Alquiler][Expensas]    │          │
│         │ ...                      │          │
└─────────┴──────────────────────────┴──────────┘
```

## Card de item (atómico, mismo en todos los formatos)

```dart
class MonthItemCard extends StatelessWidget {
  final MonthItem item;
  final bool dense; // dense=true en compact (lista), false en grilla
  // ...
}
```

Composición:
- Top row: chip día (mono) | brand chip (si tarjeta) o ícono categoría
- Body: nombre 14/600 + sub mono (`REF: …` o `DÍA N`)
- Divider
- Bottom row: label `ESTIMADO`/`PAGADO`/`A PAGAR` + monto tabular

Estados: default · paid (cardPaid) · late (cardLate)

## Ingresos en cada formato

Ver `../ingresos-spec.md`. Resumen:
- Compact: 2 chips abajo del header + categoría INGRESOS arriba en lista
- Expanded: stats grid 4 col + categoría INGRESOS arriba (grilla 2)
- Desktop: stats 4 col + categoría INGRESOS arriba (grilla 3)
