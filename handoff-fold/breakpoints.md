# Breakpoints

| Nombre | Ancho lógico | Dispositivos | Layout |
|--------|--------------|--------------|--------|
| `compact` | < 600 dp | Cel estándar, Fold cover (cerrado) | 1 columna, bottom nav |
| `expanded` | 600–1023 dp | Fold inner (desplegado), tablet vertical | Rail nav + master/detail, grillas 2 col |
| `desktop` | ≥ 1024 dp | Tablet horizontal, ChromeOS, web | Sidebar 240 + main + aside, grillas 3 col |

## Por pantalla

| Pantalla | Compact | Expanded | Desktop |
|----------|---------|----------|---------|
| Login | Form centrado | Split brand + form (50/50) | Split brand + form (form 480 fixed) |
| Mes | Lista vertical + bottom nav | Rail + main 2 col + (próximos colapsable) | Sidebar + main 2-3 col + aside |
| Tarjetas | Lista vertical | Rail + master/detail | Sidebar + grilla 3 col + aside |
| Config | Lista vertical | Rail + master/detail | Sidebar dual + grilla 3 col + aside |

## Helper Dart

```dart
// lib/core/responsive.dart
import 'package:flutter/widgets.dart';

enum FormFactor { compact, expanded, desktop }

extension BoxConstraintsX on BoxConstraints {
  FormFactor get formFactor {
    if (maxWidth >= 1024) return FormFactor.desktop;
    if (maxWidth >= 600)  return FormFactor.expanded;
    return FormFactor.compact;
  }
}

extension BuildContextResponsive on BuildContext {
  FormFactor get formFactor {
    final w = MediaQuery.sizeOf(this).width;
    if (w >= 1024) return FormFactor.desktop;
    if (w >= 600)  return FormFactor.expanded;
    return FormFactor.compact;
  }

  bool get isCompact  => formFactor == FormFactor.compact;
  bool get isExpanded => formFactor == FormFactor.expanded;
  bool get isDesktop  => formFactor == FormFactor.desktop;
}
```

## AdaptiveScaffold

```dart
// lib/core/adaptive_scaffold.dart
class AdaptiveScaffold extends StatelessWidget {
  final WidgetBuilder compact;
  final WidgetBuilder? expanded;
  final WidgetBuilder? desktop;
  const AdaptiveScaffold({super.key, required this.compact, this.expanded, this.desktop});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (ctx, c) {
      final f = c.formFactor;
      if (f == FormFactor.desktop && desktop != null) return desktop!(ctx);
      if (f != FormFactor.compact && expanded != null) return expanded!(ctx);
      return compact(ctx);
    },
  );
}
```
