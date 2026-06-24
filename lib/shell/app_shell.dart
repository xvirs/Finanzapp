import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Back del sistema: si hay un sub-flujo abierto dentro de la sección
  /// actual (ej. detalle de tarjeta), vuelve directo a la página principal
  /// de esa sección en vez de obligar a usar el back de arriba. Si ya está
  /// en la raíz de la sección, deja salir de la app (comportamiento normal).
  void _onBack(BuildContext context, bool didPop) {
    if (didPop) return;
    if (GoRouter.of(context).canPop()) {
      navigationShell.goBranch(
        navigationShell.currentIndex,
        initialLocation: true,
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onBack(context, didPop),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return AdaptiveScaffold(
      compact: (_) => Scaffold(
        backgroundColor: FzColors.bg,
        // El body se extiende por detrás de la bottom nav flotante para que
        // las listas se vean pasar bajo la píldora (look moderno). Flutter
        // suma el alto de la nav a MediaQuery.padding.bottom del body, así
        // las listas usan ese inset como clearance del último ítem.
        extendBody: true,
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
              FzNavRail(index: navigationShell.currentIndex, onChange: _onTap),
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
