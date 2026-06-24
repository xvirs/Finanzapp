import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../../../../widgets/animated_amount.dart';
import '../../../../widgets/animated_progress_bar.dart';
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
    // Sin items en el mes (primer uso o período vacío) no mostramos el
    // resumen estimado/pagado, la barra de progreso ni los filtros: son
    // datos vacíos que confunden. Dejamos solo el navegador de mes; la
    // guía para cargar el primer gasto vive en el estado vacío del body.
    final hasItems = state.groups.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Inicio', style: FzText.h1),
          const SizedBox(height: 14),
          _MonthNav(state: state),
          if (hasItems) ...[
            const SizedBox(height: 16),
            _SummaryGrid(state: state),
            const SizedBox(height: 14),
            _ProgressRow(state: state),
            const SizedBox(height: 14),
            _FilterTabs(state: state),
          ],
        ],
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({required this.state});
  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = state.canGoPrevious;
    final canGoNext = state.canGoNext;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Flecha visible solo si se puede navegar; si no, un hueco del
        // mismo ancho para que el mes quede centrado.
        canGoPrevious
            ? _NavArrow(
                icon: Icons.chevron_left_rounded,
                onPressed: () => context.read<MonthBloc>().add(
                  MonthRequested(state.period.previous()),
                ),
              )
            : const SizedBox(width: 28, height: 28),
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
        canGoNext
            ? _NavArrow(
                icon: Icons.chevron_right_rounded,
                onPressed: () => context.read<MonthBloc>().add(
                  MonthRequested(state.period.next()),
                ),
              )
            : const SizedBox(width: 28, height: 28),
      ],
    );
  }

  // El JSX usa "Abril 2026" sin la preposición "de".
  String _formatMonth(PeriodKey p) {
    final long = p.formatLong(); // "Abril de 2026"
    return long.replaceFirst(' de ', ' ');
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: FzColors.textDim),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      onPressed: onPressed,
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.state});
  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final income = summary?.incomeTotal ?? 0;
    final estimated = summary?.estimatedTotal ?? 0;
    final paid = summary?.paidTotal ?? 0;
    final pending = (estimated - paid).clamp(0, double.infinity);
    // Saldo = lo que te queda disponible HOY. Sólo descontamos lo
    // efectivamente pagado (no lo estimado), porque lo estimado todavía
    // no salió de la cuenta. El "saldo proyectado a fin de mes" sería
    // `income - estimated`, pero el usuario lee este número como saldo
    // actual.
    final balance = income - paid;
    final hasIncome = income > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cards principales: Estimado / Pagado. Es la info clave del mes.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'ESTIMADO',
                  amount: estimated,
                  tone: _CardTone.neutral,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'PAGADO',
                  amount: paid,
                  tone: _CardTone.paid,
                  footer: 'falta ${formatCurrency(pending)}',
                ),
              ),
            ],
          ),
        ),
        // Info secundaria de ingresos/saldo, solo si tiene ingresos
        // cargados. No queremos ocupar espacio en pantalla si el usuario
        // no usa la feature de ingresos.
        if (hasIncome) ...[
          const SizedBox(height: 10),
          _IncomeBalanceRow(income: income, balance: balance),
        ],
      ],
    );
  }
}

class _IncomeBalanceRow extends StatelessWidget {
  const _IncomeBalanceRow({required this.income, required this.balance});

  final double income;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final balancePositive = balance >= 0;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MiniStat(
              label: 'INGRESOS',
              amount: income,
              valueColor: FzColors.primaryHi,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStat(
              label: 'SALDO',
              amount: balance,
              valueColor: balancePositive
                  ? FzColors.primaryHi
                  : FzColors.lateInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.amount,
    required this.valueColor,
  });

  final String label;
  final double amount;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        border: Border.all(color: FzColors.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              color: FzColors.textMute,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedCurrency(
              value: amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: FzType.tabularNums,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CardTone { neutral, paid, late }

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.tone,
    this.footer,
  });

  final String label;
  final double amount;
  final _CardTone tone;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final bg = switch (tone) {
      _CardTone.neutral => FzColors.card,
      _CardTone.paid => FzColors.cardPaid,
      _CardTone.late => FzColors.cardLate,
    };
    final border = switch (tone) {
      _CardTone.neutral => FzColors.border,
      _CardTone.paid => FzColors.borderPaid,
      _CardTone.late => FzColors.borderLate,
    };
    final labelColor = switch (tone) {
      _CardTone.neutral => FzColors.textMute,
      _CardTone.paid => FzColors.primary.withValues(alpha: 0.85),
      _CardTone.late => FzColors.lateColor.withValues(alpha: 0.85),
    };
    final amountColor = switch (tone) {
      _CardTone.neutral => FzColors.text,
      _CardTone.paid => FzColors.primaryHi,
      _CardTone.late => FzColors.lateInk,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: border),
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
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedCurrency(
            value: amount,
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.44,
              fontFeatures: FzType.tabularNums,
              color: amountColor,
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
        AnimatedProgressBar(value: ratio),
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
          onTap: () => context.read<MonthBloc>().add(
            const MonthFilterChanged(MonthFilter.all),
          ),
        ),
        _FilterPill(
          label: 'Pendientes',
          active: state.filter == MonthFilter.pending,
          onTap: () => context.read<MonthBloc>().add(
            const MonthFilterChanged(MonthFilter.pending),
          ),
        ),
        _FilterPill(
          label: 'Atrasadas',
          active: state.filter == MonthFilter.overdue,
          onTap: () => context.read<MonthBloc>().add(
            const MonthFilterChanged(MonthFilter.overdue),
          ),
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
