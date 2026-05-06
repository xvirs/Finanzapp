import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../models/enums.dart';
import '../../../models/income.dart';
import '../../../widgets/shimmer_box.dart';
import 'bloc/incomes_list_bloc.dart';

/// Lista de ingresos del usuario (sueldo, freelance, alquileres que cobra,
/// etc.). Espejo simétrico de [BillsListScreen] del lado del haber.
class IncomesListScreen extends StatelessWidget {
  const IncomesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<IncomesListBloc, IncomesListBlocState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FzAppBar(
                  title: 'Ingresos',
                  trailing: _AddButton(
                    onPressed: () async {
                      final bloc = context.read<IncomesListBloc>();
                      final result = await context.push<bool>(
                        '/config/incomes/new',
                      );
                      if (result == true) {
                        bloc.add(const IncomesListRefreshRequested());
                      }
                    },
                  ),
                ),
                Expanded(child: _Body(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FzRadius.md),
        boxShadow: [
          BoxShadow(
            color: FzColors.primary.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: FzColors.primary,
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(FzRadius.md),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: FzColors.primaryInk,
              weight: 800,
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final IncomesListBlocState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case IncomesListStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Error',
          onRetry: () => context.read<IncomesListBloc>().add(
            const IncomesListRefreshRequested(),
          ),
        );

      case IncomesListStatus.initial:
      case IncomesListStatus.loading:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<IncomesListBloc>().add(
              const IncomesListRefreshRequested(),
            );
          },
          child: const _Shimmer(),
        );

      case IncomesListStatus.success:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<IncomesListBloc>().add(
              const IncomesListRefreshRequested(),
            );
          },
          child: state.incomes.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [_EmptyView()],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _SummaryRow(state: state),
                    const SizedBox(height: 12),
                    ..._buildTiles(context, state),
                  ],
                ),
        );
    }
  }

  List<Widget> _buildTiles(BuildContext context, IncomesListBlocState state) {
    return [
      for (final income in state.incomes) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _IncomeTile(
            income: income,
            onTap: () async {
              final bloc = context.read<IncomesListBloc>();
              final result = await context.push<bool>(
                '/config/incomes/${income.id}',
              );
              if (result == true) {
                bloc.add(const IncomesListRefreshRequested());
              }
            },
          ),
        ),
        const SizedBox(height: 6),
      ],
    ];
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});
  final IncomesListBlocState state;

  @override
  Widget build(BuildContext context) {
    final activeIncomes = state.incomes.where((i) => i.active).toList();
    final activeCount = activeIncomes.length;
    final fixedCount =
        activeIncomes.where((i) => i.defaultAmount != null).length;
    final variableCount = activeCount - fixedCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          _SummaryStat(value: activeCount, label: 'activos'),
          _SummaryStat(value: fixedCount, label: 'con monto fijo'),
          _SummaryStat(value: variableCount, label: 'variables'),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FzColors.text,
              letterSpacing: 0.44,
            ),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 11,
              color: FzColors.textDim,
              letterSpacing: 0.44,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeTile extends StatelessWidget {
  const _IncomeTile({required this.income, required this.onTap});

  final Income income;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOneShot =
        income.endPeriod != null && income.endPeriod == income.startPeriod;
    return Material(
      color: FzColors.card,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: FzColors.border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: income.active ? 1.0 : 0.5,
                child: _IncomeKindIcon(kind: income.kind),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            income.name,
                            style: TextStyle(
                              fontFamily: FzType.sans,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: income.active
                                  ? FzColors.text
                                  : FzColors.textDim,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!income.active) ...[
                          const SizedBox(width: 6),
                          const _InactivePill(),
                        ],
                        if (isOneShot) ...[
                          const SizedBox(width: 6),
                          const _OneShotPill(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    _Subtitle(income: income),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AmountOrVariable(amount: income.defaultAmount),
            ],
          ),
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.income});
  final Income income;

  @override
  Widget build(BuildContext context) {
    final base = StringBuffer(kIncomeKindLabels[income.kind] ?? '—');
    if (income.dayOfMonth != null) base.write(' · Día ${income.dayOfMonth}');
    return Text(
      base.toString(),
      style: const TextStyle(
        fontFamily: FzType.mono,
        fontSize: 11,
        color: FzColors.textMute,
        letterSpacing: 0.44,
      ),
    );
  }
}

class _IncomeKindIcon extends StatelessWidget {
  const _IncomeKindIcon({required this.kind});
  final IncomeKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FzColors.cardHi,
        borderRadius: BorderRadius.circular(FzRadius.md),
        border: Border.all(color: FzColors.border),
      ),
      child: Text(
        kIncomeKindEmoji[kind] ?? '💰',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

class _AmountOrVariable extends StatelessWidget {
  const _AmountOrVariable({required this.amount});
  final double? amount;

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: FzColors.cardHi,
          borderRadius: BorderRadius.circular(FzRadius.xs),
        ),
        child: const Text(
          'VARIABLE',
          style: TextStyle(
            fontFamily: FzType.mono,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.44,
            color: FzColors.textDim,
          ),
        ),
      );
    }
    return Text(
      formatCurrency(amount),
      style: const TextStyle(
        fontFamily: FzType.sans,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFeatures: FzType.tabularNums,
        color: FzColors.primary,
      ),
    );
  }
}

class _InactivePill extends StatelessWidget {
  const _InactivePill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: FzColors.cardHi,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: const Text(
        'INACTIVO',
        style: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.36,
          color: FzColors.textMute,
        ),
      ),
    );
  }
}

class _OneShotPill extends StatelessWidget {
  const _OneShotPill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: FzColors.primarySoft,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: const Text(
        'PUNTUAL',
        style: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.36,
          color: FzColors.primaryHi,
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: ShimmerBox(width: 180, height: 11, radius: 2),
        ),
        _IncomeRowShimmer(),
        SizedBox(height: 6),
        _IncomeRowShimmer(),
        SizedBox(height: 6),
        _IncomeRowShimmer(),
      ],
    );
  }
}

class _IncomeRowShimmer extends StatelessWidget {
  const _IncomeRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: FzColors.card,
          border: Border.all(color: FzColors.border),
          borderRadius: BorderRadius.circular(FzRadius.lg),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 38, height: 38, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 130, height: 14, radius: 3),
                  SizedBox(height: 6),
                  ShimmerBox(width: 90, height: 11, radius: 2),
                ],
              ),
            ),
            SizedBox(width: 12),
            ShimmerBox(width: 80, height: 14, radius: 3),
          ],
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
              'No se pudieron cargar los ingresos',
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
          children: const [
            Icon(
              Icons.savings_outlined,
              size: 48,
              color: FzColors.primary,
            ),
            SizedBox(height: 12),
            Text(
              'No tenés ingresos cargados',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Tocá "+" arriba para crear uno.',
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
