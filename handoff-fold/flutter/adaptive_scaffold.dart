// lib/core/adaptive_scaffold.dart
import 'package:flutter/material.dart';
import 'responsive.dart';

/// Wrap each screen with this. Pass the existing mobile layout as [compact]
/// (no changes), and add [expanded] / [desktop] as needed.
class AdaptiveScaffold extends StatelessWidget {
  final WidgetBuilder compact;
  final WidgetBuilder? expanded;
  final WidgetBuilder? desktop;

  const AdaptiveScaffold({
    super.key,
    required this.compact,
    this.expanded,
    this.desktop,
  });

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

/// Helper: rail nav vertical para layout expanded.
class FzNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const FzNavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today_outlined),
          label: Text('Mes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.credit_card_outlined),
          label: Text('Tarjetas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          label: Text('Config'),
        ),
      ],
    );
  }
}
