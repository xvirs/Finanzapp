import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/biometric_service.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: BlocBuilder<AuthBloc, AuthBlocState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (state.email != null) _EmailHeader(email: state.email!),
              const Divider(height: 1),
              const SizedBox(height: 4),
              _ConfigRow(
                icon: Icons.receipt_long_outlined,
                title: 'Cuentas fijas',
                onOpenList: () => context.push('/config/bills'),
                onCreate: () => context.push('/config/bills/new'),
              ),
              _ConfigRow(
                icon: Icons.credit_card_outlined,
                title: 'Tarjetas',
                onOpenList: () => context.go('/cards'),
                onCreate: () => context.push('/cards/new'),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const _BiometricToggle(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthSignOutRequested());
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmailHeader extends StatelessWidget {
  const _EmailHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sesión iniciada como',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(email, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    required this.icon,
    required this.title,
    required this.onOpenList,
    required this.onCreate,
  });

  final IconData icon;
  final String title;
  final VoidCallback onOpenList;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onOpenList,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filledTonal(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 20),
            tooltip: 'Crear nuevo',
            style: IconButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BiometricToggle extends StatefulWidget {
  const _BiometricToggle();

  @override
  State<_BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends State<_BiometricToggle> {
  late final BiometricService _service;
  late bool _enabled;
  bool? _supported;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service = context.read<BiometricService>();
    _enabled = _service.enabledCached;
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final ok = await _service.isAvailable();
    if (!mounted) return;
    setState(() => _supported = ok);
  }

  Future<void> _toggle(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      if (value) {
        // Verificá que el biométrico funcione antes de habilitar.
        final ok = await _service.authenticate(
          reason: 'Verificá tu identidad para activar el bloqueo',
        );
        if (!ok) {
          messenger.showSnackBar(
            const SnackBar(content: Text('No se pudo verificar el biométrico.')),
          );
          if (mounted) setState(() => _busy = false);
          return;
        }
        await _service.setEnabled(true);
        if (!mounted) return;
        setState(() {
          _enabled = true;
          _busy = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('Bloqueo biométrico activado.')),
        );
      } else {
        await _service.setEnabled(false);
        if (!mounted) return;
        setState(() {
          _enabled = false;
          _busy = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('Bloqueo biométrico desactivado.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supported = _supported;

    final subtitle = switch (supported) {
      null => 'Verificando…',
      false => 'Tu dispositivo no tiene biometría ni PIN configurado',
      true => 'Pedir Face ID / huella al abrir o volver a la app',
    };

    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Icon(
        Icons.fingerprint_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: const Text('Bloqueo biométrico'),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      value: _enabled,
      onChanged: (supported == true && !_busy) ? _toggle : null,
    );
  }
}
