import 'package:flutter/material.dart';

import '../../../core/biometric_service.dart';

/// Pantalla bloqueante que se muestra cuando el biométrico está activo.
/// Auto-dispara el prompt biométrico al aparecer; si el usuario lo cancela
/// queda visible un botón "Desbloquear" para reintentar.
class LockScreen extends StatefulWidget {
  const LockScreen({
    required this.service,
    required this.onUnlock,
    super.key,
  });

  final BiometricService service;
  final VoidCallback onUnlock;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _attempting = false;

  @override
  void initState() {
    super.initState();
    // Lanzar el prompt en cuanto el frame se pinta para que el OS se
    // superponga a esta pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) => _attempt());
  }

  Future<void> _attempt() async {
    if (_attempting) return;
    setState(() => _attempting = true);
    final ok = await widget.service.authenticate();
    if (!mounted) return;
    if (ok) {
      widget.onUnlock();
      return;
    }
    setState(() => _attempting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
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
                  onPressed: _attempting ? null : _attempt,
                  icon: _attempting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.fingerprint_rounded, size: 20),
                  label: const Text('Desbloquear'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
