import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/tokens.dart';
import '../design/widgets.dart';

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
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: FzBottomNav(
          index: navigationShell.currentIndex,
          onChange: _onTap,
        ),
      ),
    );
  }
}
