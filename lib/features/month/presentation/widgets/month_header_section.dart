import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/period.dart';
import '../bloc/month_bloc.dart';
import 'filter_toggle.dart';
import 'month_summary_view.dart';

class MonthHeaderSection extends StatelessWidget {
  const MonthHeaderSection({required this.state, super.key});

  final MonthBlocState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = state.period;
    final canGoNext = state.isPastPeriod;
    final isCurrent = state.isCurrentPeriod;

    final subtitle = state.isFuturePeriod
        ? 'Mes futuro'
        : state.isPastPeriod
            ? 'Mes pasado'
            : 'Mes actual';

    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              subtitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  iconSize: 28,
                  onPressed: () => context
                      .read<MonthBloc>()
                      .add(MonthRequested(period.previous())),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      period.formatLong(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  iconSize: 28,
                  onPressed: canGoNext
                      ? () => context
                          .read<MonthBloc>()
                          .add(MonthRequested(period.next()))
                      : null,
                ),
              ],
            ),
            if (!isCurrent)
              Center(
                child: TextButton.icon(
                  onPressed: () => context
                      .read<MonthBloc>()
                      .add(MonthRequested(PeriodKey.current())),
                  icon: const Icon(Icons.today_outlined, size: 16),
                  label: const Text('Volver al mes actual'),
                ),
              ),
            const SizedBox(height: 8),
            MonthSummaryView(summary: state.summary),
            const SizedBox(height: 12),
            FilterToggle(
              paidCount: state.summary?.paidCount ?? 0,
              totalCount: state.summary?.totalCount ?? 0,
              onlyPending: state.onlyPending,
              onChanged: (_) => context
                  .read<MonthBloc>()
                  .add(const MonthOnlyPendingToggled()),
            ),
          ],
        ),
      ),
    );
  }
}
