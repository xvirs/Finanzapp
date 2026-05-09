import 'dart:ui' show DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// Form factor del dispositivo según ancho lógico (dp).
///
/// Los breakpoints siguen los de Material 3 / handoff-fold:
/// - `compact`  (<600 dp): celular estándar / Fold cerrado.
/// - `expanded` (600-1023 dp): Fold inner / tablet vertical.
/// - `desktop`  (≥1024 dp): tablet horizontal / web / ChromeOS.
enum FormFactor { compact, expanded, desktop }

const double _kExpandedBreakpoint = 600;
const double _kDesktopBreakpoint = 1024;

extension FzBoxConstraints on BoxConstraints {
  /// Form factor calculado a partir de las constraints actuales del
  /// subárbol. **Siempre preferir esto sobre `MediaQuery.size`** porque
  /// respeta splitscreen y multi-window del Fold.
  FormFactor get formFactor {
    if (maxWidth >= _kDesktopBreakpoint) return FormFactor.desktop;
    if (maxWidth >= _kExpandedBreakpoint) return FormFactor.expanded;
    return FormFactor.compact;
  }
}

extension FzBuildContextResponsive on BuildContext {
  /// Form factor de la ventana entera (no del subárbol). Usar para
  /// decisiones globales tipo "habilitar feature X". Para layout
  /// preferir `LayoutBuilder` + [FzBoxConstraints.formFactor].
  FormFactor get formFactor {
    final w = MediaQuery.sizeOf(this).width;
    if (w >= _kDesktopBreakpoint) return FormFactor.desktop;
    if (w >= _kExpandedBreakpoint) return FormFactor.expanded;
    return FormFactor.compact;
  }

  bool get isCompact => formFactor == FormFactor.compact;
  bool get isExpanded => formFactor == FormFactor.expanded;
  bool get isDesktop => formFactor == FormFactor.desktop;

  /// True cuando el dispositivo tiene un hinge/fold físico Y el ancho
  /// es >= 600 dp (Fold desplegado). Útil para evitar que una grilla
  /// caiga justo sobre la bisagra.
  bool get isFoldInner {
    final features = MediaQuery.of(this).displayFeatures;
    final hasHinge = features.any(
      (f) =>
          f.type == DisplayFeatureType.hinge ||
          f.type == DisplayFeatureType.fold,
    );
    return hasHinge && MediaQuery.sizeOf(this).width >= _kExpandedBreakpoint;
  }
}
