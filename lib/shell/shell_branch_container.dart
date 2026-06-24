import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/responsive.dart';
import '../design/tokens.dart';

/// Contenedor de las ramas del [StatefulShellRoute] que permite navegar
/// entre Inicio / Tarjetas / Gestión deslizando horizontalmente (PageView),
/// además de los taps en la bottom nav.
///
/// Sincronización bidireccional:
/// - Swipe → [PageView.onPageChanged] → `navigationShell.goBranch`.
/// - Tap en la nav (cambia `currentIndex`) → `didUpdateWidget` anima el
///   PageController a la página nueva.
///
/// El gesto solo se habilita en `compact` (celular / Fold cerrado /
/// splitscreen angosto). En layouts con rail (expanded/desktop) el PageView
/// queda fijo para no chocar con los gestos de las vistas master/detail.
///
/// Las 3 ramas se mantienen vivas ([_KeepAlivePage]) para preservar su
/// estado y scroll al deslizar, igual que hacía el IndexedStack original.
class ShellBranchContainer extends StatefulWidget {
  const ShellBranchContainer({
    required this.navigationShell,
    required this.children,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<ShellBranchContainer> createState() => _ShellBranchContainerState();
}

class _ShellBranchContainerState extends State<ShellBranchContainer> {
  late final PageController _controller = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );

  @override
  void didUpdateWidget(covariant ShellBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // La nav cambió de sección (tap) → llevar el PageView a esa página.
    final target = widget.navigationShell.currentIndex;
    if (_controller.hasClients &&
        (_controller.page?.round() ?? target) != target) {
      _controller.animateToPage(
        target,
        duration: FzMotion.normal,
        curve: FzMotion.easing,
      );
    }
  }

  void _onPageChanged(int index) {
    if (index == widget.navigationShell.currentIndex) return;
    widget.navigationShell.goBranch(index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final swipeable = constraints.formFactor == FormFactor.compact;
        return PageView(
          controller: _controller,
          physics: swipeable
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          onPageChanged: _onPageChanged,
          children: [
            for (final child in widget.children) _KeepAlivePage(child: child),
          ],
        );
      },
    );
  }
}

/// Mantiene viva cada rama aunque esté fuera de pantalla en el PageView,
/// para no perder estado/scroll al deslizar entre secciones.
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
