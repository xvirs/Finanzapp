import 'package:flutter/material.dart';

import '../../../core/biometric_service.dart';
import 'lock_screen.dart';

/// Wrapper que decide si mostrar [child] (app desbloqueada) o el
/// [LockScreen]. Escucha el lifecycle del SO para re-bloquear cuando la
/// app vuelve después de [_lockAfterBackground] en background.
///
/// La decisión se basa en el estado SINCRÓNICO de [BiometricService.enabledCached]
/// — main.dart se asegura de refrescarlo antes de runApp.
class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.service, required this.child, super.key});

  final BiometricService service;
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  static const _lockAfterBackground = Duration(seconds: 60);

  bool _locked = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.service.enabledCached) {
      _locked = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.service.enabledCached) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Solo registramos si todavía no había una marca de pausa, así
        // mantenemos la primera (no la reseteamos al pasar por inactive→
        // paused→hidden).
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final at = _backgroundedAt;
        _backgroundedAt = null;
        if (at == null) return;
        final elapsed = DateTime.now().difference(at);
        if (elapsed >= _lockAfterBackground && !_locked) {
          setState(() => _locked = true);
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  void _unlock() {
    if (!_locked) return;
    setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      // Navigator propio: el AppLockGate se monta desde el `builder` de
      // MaterialApp.router, que está ARRIBA del Navigator del router.
      // Sin este Navigator, `showDialog` desde LockScreen no encuentra
      // un Navigator ancestor y crashea con "Navigator operation
      // requested with a context that does not include a Navigator".
      return Navigator(
        onGenerateRoute: (_) => PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) =>
              LockScreen(service: widget.service, onUnlock: _unlock),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
    return widget.child;
  }
}
