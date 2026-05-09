# Tarjetas · adaptativo

## Compact (<600 dp)

Sin cambios. Lista vertical con `CreditCardTile` (lo que ya está).

## Expanded (600–1023 dp · Fold inner)

Master/detail. Rail (88) + lista de tarjetas (320, grilla 2 columnas) + detalle (flex).

```
┌──────┬──────────────────┬──────────────────┐
│ RAIL │ MASTER           │ DETAIL           │
│  88  │                  │                  │
│      │ • CRÉDITO (2)    │ Hero pago verde  │
│ Mes  │ [VISA] [MC]      │ Tabs:            │
│ Tar* │                  │ Cuotas | Débitos │
│ Cfg  │ • DÉBITO (1)     │ Lista expandida  │
│      │ [MP selected]    │ del tab activo   │
│      │                  │ Acciones bottom  │
└──────┴──────────────────┴──────────────────┘
```

Tap en card del master → actualiza el detail sin push de ruta.

## Desktop (≥1024 dp)

Sidebar 220 + main grid 3 col + aside 320 (ya implementado en web).

```
SIDEBAR │ MAIN: Stats + Grid 3 col por tipo │ ASIDE detalle
```

## CardItem atómico

```dart
class CreditCardCard extends StatelessWidget {
  final Tarjeta t;
  final bool selected;
  final VoidCallback onTap;
  // ...
}
```

4 zonas:
1. Top: chip día corte | brand chip color oficial
2. Body: nombre + meta `N déb · M cuotas`
3. Divider
4. Bottom: label estado + monto tabular

Slot dashed "Agregar tarjeta crédito" como último item de cada categoría.

## Brand chip

```dart
const brandColors = {
  'visa':        Color(0xFF1A1F71),
  'mastercard':  Color(0xFFEB001B),
  'mercadopago': Color(0xFF009EE3),
  'amex':        Color(0xFF006FCF),
};
```

Container 44×28, radius 5, texto blanco 700 9.5px.
