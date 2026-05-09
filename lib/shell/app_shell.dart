import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/adaptive_scaffold.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';

/// Shell raíz de la app. En `compact` muestra bottom nav; en `expanded`
/// y `desktop` reemplaza por un rail lateral. La rama activa
/// ([navigationShell]) preserva su estado al cambiar de form factor.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      compact: (_) => Scaffold(
        backgroundColor: FzColors.bg,
        body: navigationShell,
        bottomNavigationBar: SafeArea(
          top: false,
          child: FzBottomNav(
            index: navigationShell.currentIndex,
            onChange: _onTap,
          ),
        ),
      ),
      expanded: (_) => Scaffold(
        backgroundColor: FzColors.bg,
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              FzNavRail(
                index: navigationShell.currentIndex,
                onChange: _onTap,
              ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
      desktop: (_) => Scaffold(
        backgroundColor: FzColors.bg,
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              FzNavRail(
                index: navigationShell.currentIndex,
                onChange: _onTap,
                extended: true,
              ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
    );
  }
}
