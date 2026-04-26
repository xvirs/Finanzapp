import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/month_bloc.dart';
import 'widgets/month_group_section.dart';
import 'widgets/month_header_section.dart';

class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  String? _expandedKey;

  void _toggleExpanded(String key) {
    setState(() {
      _expandedKey = _expandedKey == key ? null : key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<MonthBloc, MonthBlocState>(
          listenWhen: (previous, current) =>
              previous.period != current.period ||
              (previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null) ||
              (previous.status == MonthStatus.loading &&
                  current.status == MonthStatus.success),
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.status == MonthStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            // Cerrar acordeón al cambiar de período o terminar una mutación.
            if (_expandedKey != null) {
              setState(() => _expandedKey = null);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                MonthHeaderSection(state: state),
                const Divider(height: 1),
                Expanded(
                  child: switch (state.status) {
                    MonthStatus.initial ||
                    MonthStatus.loading =>
                      const Center(child: CircularProgressIndicator()),
                    MonthStatus.failure => _ErrorView(
                        message: state.errorMessage ?? 'Error desconocido',
                        onRetry: () => context
                            .read<MonthBloc>()
                            .add(const MonthRefreshRequested()),
                      ),
                    MonthStatus.success => state.groups.isEmpty
                        ? const _EmptyView()
                        : RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<MonthBloc>()
                                  .add(const MonthRefreshRequested());
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: state.groups.length,
                              itemBuilder: (ctx, i) => MonthGroupSection(
                                group: state.groups[i],
                                period: state.period,
                                onlyPending: state.onlyPending,
                                expandedKey: _expandedKey,
                                mutatingItemKey: state.mutatingItemKey,
                                onToggle: _toggleExpanded,
                              ),
                            ),
                          ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'No se pudieron cargar los datos',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin pagos este mes',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'No hay cuentas ni cuotas activas para este período.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
