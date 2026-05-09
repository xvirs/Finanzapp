import 'package:flutter/material.dart';

import 'responsive.dart';

/// Wrapper que selecciona el layout según el form factor de las
/// constraints del subárbol.
///
/// **Premisa**: el [compact] builder no se toca — es la pantalla móvil
/// que ya está en producción. [expanded] y [desktop] son aditivos. Si
/// no se pasa uno, hace fallback al inferior.
///
/// Usa [LayoutBuilder] (no MediaQuery.size) para respetar splitscreen y
/// multi-window del Fold: cuando el usuario tiene 2 apps abiertas en
/// pantalla partida, el ancho efectivo puede caer en `compact` aunque
/// el dispositivo esté desplegado.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.compact,
    this.expanded,
    this.desktop,
    super.key,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? expanded;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final f = constraints.formFactor;
        if (f == FormFactor.desktop && desktop != null) return desktop!(ctx);
        if (f != FormFactor.compact && expanded != null) return expanded!(ctx);
        return compact(ctx);
      },
    );
  }
}
