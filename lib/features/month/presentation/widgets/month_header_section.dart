import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../bloc/month_bloc.dart';

/// Header del Mes — port pixel-perfect de `ATopMonth` del JSX.
///
/// 1. Caplabel "MES ACTUAL / PASADO / FUTURO"
/// 2. Navegador de mes (chevron L · título · chevron R)
/// 3. Grid 2-col: card "Estimado" + card "Pagado" (verde tinted)
/// 4. Progress bar + "X/Y pagadas" + "%"
/// 5. Filter tabs (Todos / Pendientes / Atrasadas)
class MonthHeaderSection extends StatelessWidget {
  const MonthHeaderSection({required this.state, super.key});

  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Caplabel(state),
          const SizedBox(height: 10),
          _MonthNav(state: state),
          const SizedBox(height: 16),
          _SummaryGrid(state: state),
          const SizedBox(height: 14),
          _ProgressRow(state: state),
          const SizedBox(height: 14),
          _FilterTabs(state: state),
        ],
      ),
    );
  }
}

class _Caplabel extends StatelessWidget {
  const _Caplabel(this.state);
  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    final label = state.isFuturePeriod
        ? 'MES FUTURO'
        : state.isPastPeriod
            ? 'MES PASADO'
            : 'MES ACTUAL';
    return Text(
      label,
      style: const TextStyle(
        fontFamily: FzType.mono,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.66,
        color: FzColors.textMute,
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({required this.state});
  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    final canGoNext = state.isPastPeriod;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 20,
            color: FzColors.textDim,
          ),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          onPressed: () => context
              .read<MonthBloc>()
              .add(MonthRequested(state.period.previous())),
        ),
        Text(
          _formatMonth(state.period),
          style: const TextStyle(
            fontFamily: FzType.sans,
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.19,
            color: FzColors.text,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: canGoNext ? FzColors.textDim : FzColors.textMute,
          ),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          onPressed: canGoNext
              ? () => context
                  .read<MonthBloc>()
                  .add(MonthRequested(state.period.next()))
              : null,
        ),
      ],
    );
  }

  // El JSX usa "Abril 2026" sin la preposición "de".
  String _formatMonth(PeriodKey p) {
    final long = p.formatLong(); // "Abril de 2026"
    return long.replaceFirst(' de ', ' ');
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.state});
  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final estimated = summary?.estimatedTotal ?? 0;
    final paid = summary?.paidTotal ?? 0;
    final pending = (estimated - paid).clamp(0, double.infinity);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'ESTIMADO',
              amount: estimated,
              tinted: false,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'PAGADO',
              amount: paid,
              tinted: true,
              footer: 'falta ${formatCurrency(pending)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.tinted,
    this.footer,
  });

  final String label;
  final double amount;
  final bool tinted;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tinted ? FzColors.cardPaid : FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(
          color: tinted ? FzColors.borderPaid : FzColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FzType.mono,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.63,
              color: tinted
                  ? FzColors.primary.withValues(alpha: 0.85)
                  : FzColors.textMute,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.44,
              fontFeatures: FzType.tabularNums,
              color: tinted ? FzColors.primaryHi : FzColors.text,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 2),
            Text(
              footer!,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 11,
                color: FzColors.textMute,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.state});
  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    final paid = state.summary?.paidCount ?? 0;
    final total = state.summary?.totalCount ?? 0;
    final ratio = total == 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$paid/$total pagadas',
              style: const TextStyle(
                fontFamily: FzType.mono,
                fontSize: 11.5,
                color: FzColors.textDim,
                letterSpacing: 0.46,
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: FzType.mono,
                fontSize: 11.5,
                color: FzColors.textMute,
                letterSpacing: 0.46,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            height: 4,
            color: FzColors.card,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio == 0 ? 0.001 : ratio,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [FzColors.primary, FzColors.primaryHi],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.state});
  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        _FilterPill(
          label: 'Todos',
          active: state.filter == MonthFilter.all,
          onTap: () => context
              .read<MonthBloc>()
              .add(const MonthFilterChanged(MonthFilter.all)),
        ),
        _FilterPill(
          label: 'Pendientes',
          active: state.filter == MonthFilter.pending,
          onTap: () => context
              .read<MonthBloc>()
              .add(const MonthFilterChanged(MonthFilter.pending)),
        ),
        _FilterPill(
          label: 'Atrasadas',
          active: state.filter == MonthFilter.overdue,
          onTap: () => context
              .read<MonthBloc>()
              .add(const MonthFilterChanged(MonthFilter.overdue)),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: active ? FzColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(FzRadius.pill),
            border: Border.all(
              color: active ? FzColors.borderPaid : FzColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              color: active ? FzColors.primary : FzColors.textDim,
            ),
          ),
        ),
      ),
    );
  }
}
