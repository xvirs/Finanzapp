import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/biometric_service.dart';
import '../../../design/tokens.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../auth/data/auth_repository.dart';

/// Pantalla bloqueante que se muestra cuando el biométrico está activo.
///
/// Auto-dispara el prompt biométrico al aparecer; si el usuario lo cancela
/// queda visible un botón "Desbloquear" para reintentar.
///
/// Failsafe iOS: en iOS no hay back gesture ni botón system para salir.
/// Si el biométrico se rompe (cambio de huella, falla de hardware), el
/// usuario queda atrapado. Por eso al pie hay un link "¿Problemas?
/// Cerrar sesión" que limpia la sesión y manda al login.
class LockScreen extends StatefulWidget {
  const LockScreen({required this.service, required this.onUnlock, super.key});

  final BiometricService service;
  final VoidCallback onUnlock;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _attempting = false;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attempt());
  }

  Future<void> _attempt() async {
    if (_attempting) return;
    setState(() => _attempting = true);
    var ok = false;
    try {
      ok = await widget.service.authenticate();
    } catch (_) {
      // PlatformException (no enrollado, lockout, etc) — tratamos
      // como fallo silencioso y dejamos al usuario reintentar o
      // usar el failsafe "Cerrar sesión". Sin este try/catch, una
      // excepción dejaba `_attempting=true` y trababa el botón
      // de exit.
      ok = false;
    }
    if (!mounted) return;
    if (ok) {
      widget.onUnlock();
      return;
    }
    setState(() => _attempting = false);
  }

  Future<void> _exit() async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Cerrar sesión',
      message:
          'Vas a tener que volver a loguearte. Tus datos en la nube no se borran.',
      confirmLabel: 'Cerrar sesión',
    );
    if (!confirmed || !mounted) return;

    setState(() => _signingOut = true);
    final repo = context.read<AuthRepository>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      // AWAIT del signout: esperamos que Supabase confirme antes de
      // desbloquear. Si falla, el usuario queda en la lock screen
      // con un error visible (en vez de "salir" pero seguir
      // autenticado). El AuthBloc detecta el cambio de sesión via
      // su subscripción a authStateChanges y emite unauthenticated;
      // el router redirecciona a /login.
      await repo.signOut();
      if (!mounted) return;
      widget.onUnlock();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo cerrar sesión: $e')),
      );
      setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = _attempting || _signingOut;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Finanzapp',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _attempting
                          ? 'Esperando autenticación…'
                          : 'Desbloqueá para acceder a tus datos',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: busy ? null : _attempt,
                      icon: _attempting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.fingerprint_rounded, size: 20),
                      label: const Text('Desbloquear'),
                    ),
                  ],
                ),
              ),
              // Failsafe al pie: si el biométrico se rompe, salida via
              // logout (especialmente importante en iOS donde no hay
              // hardware back).
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: busy ? null : _exit,
                  style: TextButton.styleFrom(
                    foregroundColor: FzColors.textMute,
                  ),
                  child: Text(
                    _signingOut
                        ? 'Cerrando sesión…'
                        : '¿Problemas? Cerrar sesión',
                    style: const TextStyle(
                      fontFamily: FzType.mono,
                      fontSize: 11,
                      letterSpacing: 0.44,
                      color: FzColors.textMute,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
