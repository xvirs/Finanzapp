import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/analytics_service.dart';
import '../../../core/format.dart';
import '../../../design/tokens.dart';
import '../../../models/income.dart';
import 'bloc/month_bloc.dart';
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
  String? _expandedKey;

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (_expandedKey != null) {
            setState(() => _expandedKey = null);
          }
        },
        builder: (context, state) {
          return SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header anclado siempre — se mantiene durante carga
                // y solo cambian sus valores cuando llegan los datos.
                Material(
                  color: FzColors.bg,
                  child: MonthHeaderSection(state: state),
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
        final hasIncomes = state.incomes.isNotEmpty;
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<MonthBloc>().add(const MonthRefreshRequested());
          },
          child: !hasGroups && !hasIncomes
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [_EmptyView()],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
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
                    if (hasIncomes) _IncomesSection(incomes: state.incomes),
                  ],
                ),
        );
    }
  }
}

class _IncomesSection extends StatelessWidget {
  const _IncomesSection({required this.incomes});

  final List<Income> incomes;

  @override
  Widget build(BuildContext context) {
    final total = incomes.fold<double>(
      0,
      (sum, i) => sum + (i.defaultAmount ?? 0),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: FzColors.cardPaid,
          borderRadius: BorderRadius.circular(FzRadius.xl),
          border: Border.all(color: FzColors.borderPaid),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('💰', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Ingresos',
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FzColors.text,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatCurrency(total),
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFeatures: FzType.tabularNums,
                    color: FzColors.primaryHi,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final income in incomes) ...[
              _IncomeRow(income: income),
              if (income != incomes.last) const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _IncomeRow extends StatelessWidget {
  const _IncomeRow({required this.income});

  final Income income;

  @override
  Widget build(BuildContext context) {
    final amount = income.defaultAmount;
    return Row(
      children: [
        Expanded(
          child: Text(
            income.name,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 13,
              color: FzColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (income.dayOfMonth != null) ...[
          const SizedBox(width: 8),
          Text(
            'día ${income.dayOfMonth}',
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 11,
              color: FzColors.textDim,
              letterSpacing: 0.44,
            ),
          ),
        ],
        const SizedBox(width: 8),
        Text(
          amount == null ? 'variable' : formatCurrency(amount),
          style: TextStyle(
            fontFamily: FzType.sans,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFeatures: FzType.tabularNums,
            color: amount == null ? FzColors.textDim : FzColors.text,
          ),
        ),
      ],
    );
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: 48,
              color: FzColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sin pagos este mes',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'No hay cuentas ni cuotas activas para este período.',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12,
                color: FzColors.textDim,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
