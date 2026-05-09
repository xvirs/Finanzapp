# AGENTS.md — Finanzapp Fold/Responsive (Flutter)

## Quién sos

Sos un agente IA implementando responsive en una app Flutter ya funcionando bien en mobile. **No rompas mobile**. Sumá adaptaciones para anchos mayores.

## Stack asumido

- Flutter ≥ 3.22
- Material 3 con tema custom (oscuro `#0B0F0D`, primary `#1FB87A`)
- Geist + Geist Mono (vía `google_fonts`)
- Riverpod o Provider (lo que ya use el repo)

## Plan

1. Leer `breakpoints.md` y crear `lib/core/responsive.dart`.
2. Crear `lib/core/adaptive_scaffold.dart` que recibe 3 builders: `compact`, `expanded`, `desktop`. Si no se pasa uno, hace fallback al inferior.
3. Para cada pantalla del repo (login, mes, tarjetas, config):
   - Mover el contenido actual a un `_CompactLayout`
   - Crear `_ExpandedLayout` (Fold inner / tablet)
   - Crear `_DesktopLayout` (web Flutter o ChromeOS) reutilizando widgets atómicos
4. **Reusar widgets atómicos**: `CardItem`, `AccountTile`, `AmountRow`, `CategoryHeader`. NO duplicar.

## Reglas no-negociables

- **El layout `compact` no se toca**. Es lo que ya está en producción.
- **Los widgets atómicos se reusan**, no se reescriben.
- En `expanded` y `desktop`, **grillas de cards 2-3 columnas** en lugar de listas verticales largas (premisa del usuario).
- **Ingresos siempre visibles** en Mes — ver `ingresos-spec.md`.
- Usar `LayoutBuilder` o `MediaQuery.sizeOf(context).width` — preferir LayoutBuilder porque respeta multi-window y splitscreen del Fold.

## Detección Fold-specific (opcional)

Para diferenciar Fold inner desplegada de tablet común, usar `display_features` de `MediaQuery`:

```dart
final hinge = MediaQuery.of(context).displayFeatures.firstWhereOrNull(
  (f) => f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold,
);
final isFoldInner = hinge != null && size.width >= 600;
```

Si hay `hinge`, evitar poner contenido crítico cruzando la bisagra (usar `TwoPane` o split en la columna del hinge).

## Tokens

Ya están definidos en el theme actual del repo. Si faltan los de "ingresos" (verde brillante para ingresos, rojo suave para egresos) ver `ingresos-spec.md`.
