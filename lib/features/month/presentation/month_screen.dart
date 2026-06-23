import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adaptive_scaffold.dart';
import '../../../core/analytics_service.dart';
import '../../../design/tokens.dart';
import '../../../domain/period.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/fz_snackbar.dart';
import 'bloc/month_bloc.dart';
import 'widgets/month_expanded_layout.dart';
import 'widgets/month_expanded_shimmer.dart';
import 'widgets/month_group_section.dart';
import 'widgets/month_header_section.dart';
import 'widgets/month_shimmer.dart';

/// Pantalla 2 — Mes (Home).
/// Port pixel-perfect de `AHome` + `AHomeExpanded` del JSX.
///
/// Layout:
/// - Header anclado al tope (no scrollea, no se oculta durante carga;
///   sus valores se actualizan en su lugar cuando llegan los datos).
/// - Body con scroll: durante carga inicial / pull-to-refresh muestra
///   un shimmer skeleton; en éxito, la lista de grupos; en error, una
///   vista de retry.
class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  /// Item expandido (compact: card abre detail inline al tocar).
  String? _expandedKey;

  /// Item seleccionado (expanded/desktop: master/detail).
  String? _selectedItemKey;

  /// Último período visto, usado en el [BlocConsumer] listener para
  /// detectar cambios reales de mes y limpiar la selección master/detail.
  /// Sin esto, el listener también disparaba al completar mutaciones y
  /// borraba el hero recién marcado como pagado.
  PeriodKey? _lastSeenPeriod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnalyticsService>().screenView('mes');
    });
  }

  void _toggleExpanded(String key) {
    setState(() => _expandedKey = _expandedKey == key ? null : key);
  }

  void _selectItem(String key) {
    setState(() => _selectedItemKey = key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: BlocConsumer<MonthBloc, MonthBlocState>(
        listenWhen: (previous, current) =>
            previous.period != current.period ||
            (previous.errorMessage != current.errorMessage &&
                current.errorMessage != null) ||
            (previous.mutatingItemKey != null &&
                current.mutatingItemKey == null),
        listener: (context, state) {
          if (state.errorMessage != null) {
            showFzSnack(context, state.errorMessage!, kind: FzSnackKind.error);
          }
          // Cambio de período → cerrar tarjetas expandidas + limpiar
          // selección master/detail. Comparamos contra el último visto
          // porque el listener también dispara por error/mutación.
          final isPeriodChange =
              _lastSeenPeriod != null && _lastSeenPeriod != state.period;
          if (isPeriodChange) {
            setState(() {
              _expandedKey = null;
              _selectedItemKey = null;
            });
          } else if (_expandedKey != null) {
            // Mutación completada → cerrar la card expandida del compact
            // pero respetar la selección master/detail del expanded.
            setState(() => _expandedKey = null);
          }
          _lastSeenPeriod = state.period;
        },
        builder: (context, state) {
          return AdaptiveScaffold(
            compact: (_) {
              // El header solo muestra shimmer en la PRIMERA carga (sin
              // datos aún). En recargas (pull-to-refresh / cambio de mes)
              // se mantiene montado con los datos previos, así sus números
              // animan al valor nuevo en vez de parpadear a shimmer. El
              // shimmer queda solo para los ítems (en el _Body).
              final hasData = state.summary != null;
              return SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      color: FzColors.bg,
                      child: hasData
                          ? MonthHeaderSection(state: state)
                          : const MonthHeaderShimmer(),
                    ),
                    Expanded(
                      child: _Body(
                        state: state,
                        expandedKey: _expandedKey,
                        onToggle: _toggleExpanded,
                      ),
                    ),
                  ],
                ),
              );
            },
            expanded: (_) => SafeArea(
              bottom: false,
              child:
                  state.status == MonthStatus.loading ||
                      state.status == MonthStatus.initial
                  ? const MonthExpandedShimmer()
                  : MonthExpandedLayout(
                      state: state,
                      selectedKey: _selectedItemKey,
                      onSelect: _selectItem,
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Cuerpo bajo el header. Maneja todos los estados de carga / éxito /
/// error / vacío.
class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.expandedKey,
    required this.onToggle,
  });

  final MonthBlocState state;
  final String? expandedKey;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case MonthStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Error desconocido',
          onRetry: () =>
              context.read<MonthBloc>().add(const MonthRefreshRequested()),
        );

      case MonthStatus.initial:
      case MonthStatus.loading:
        // Shimmer wrapped en RefreshIndicator-friendly scroll para que
        // el pull-to-refresh siga funcionando si el usuario insiste.
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<MonthBloc>().add(const MonthRefreshRequested());
          },
          child: const MonthShimmer(),
        );

      case MonthStatus.success:
        final hasGroups = state.groups.isNotEmpty;
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<MonthBloc>().add(const MonthRefreshRequested());
          },
          child: !hasGroups
              ? FzEmptyState(
                  icon: Icons.description_outlined,
                  title: 'Sin movimientos este mes',
                  description:
                      'Cargá tu primer gasto y empezá a organizar el mes.',
                  ctaLabel: 'Agregar gasto',
                  onCta: () => context.push('/config/bills/new'),
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Clearance para que el último ítem suba por encima de la
                  // bottom nav flotante (extendBody suma su alto al inset).
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 12,
                  ),
                  children: [
                    for (final group in state.groups)
                      MonthGroupSection(
                        group: group,
                        period: state.period,
                        filter: state.filter,
                        expandedKey: expandedKey,
                        mutatingItemKey: state.mutatingItemKey,
                        onToggle: onToggle,
                      ),
                  ],
                ),
        );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: FzColors.lateColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar los datos',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12,
                color: FzColors.textDim,
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
      ),
    );
  }
}
