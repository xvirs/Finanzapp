import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: BlocBuilder<AuthBloc, AuthBlocState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (state.email != null)
                Padding(
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
                      Text(
                        state.email!,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Cuentas fijas'),
                subtitle: const Text('Disponible en próxima etapa'),
                trailing: const Icon(Icons.chevron_right),
                enabled: false,
                onTap: null,
              ),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Tarjetas'),
                subtitle: const Text('Disponible en próxima etapa'),
                trailing: const Icon(Icons.chevron_right),
                enabled: false,
                onTap: null,
              ),
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthSignOutRequested(),
                        );
                  },
                  icon: const Icon(Icons.logout),
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
