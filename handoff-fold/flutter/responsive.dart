// lib/core/responsive.dart
import 'package:flutter/widgets.dart';

enum FormFactor { compact, expanded, desktop }

extension BoxConstraintsX on BoxConstraints {
  FormFactor get formFactor {
    if (maxWidth >= 1024) return FormFactor.desktop;
    if (maxWidth >= 600) return FormFactor.expanded;
    return FormFactor.compact;
  }
}

extension BuildContextResponsive on BuildContext {
  FormFactor get formFactor {
    final w = MediaQuery.sizeOf(this).width;
    if (w >= 1024) return FormFactor.desktop;
    if (w >= 600) return FormFactor.expanded;
    return FormFactor.compact;
  }

  bool get isCompact => formFactor == FormFactor.compact;
  bool get isExpanded => formFactor == FormFactor.expanded;
  bool get isDesktop => formFactor == FormFactor.desktop;

  /// True cuando estamos en un Fold desplegado (hinge presente y ancho >= 600).
  bool get isFoldInner {
    final features = MediaQuery.of(this).displayFeatures;
    final hasHinge = features.any((f) =>
        f.type == DisplayFeatureType.hinge ||
        f.type == DisplayFeatureType.fold);
    return hasHinge && MediaQuery.sizeOf(this).width >= 600;
  }
}
