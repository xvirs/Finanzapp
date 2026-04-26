import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/month_item.dart';

class MonthSummaryView extends StatelessWidget {
  const MonthSummaryView({required this.summary, super.key});

  final MonthSummary? summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    if (s == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final pending = s.estimatedTotal - s.paidTotal;
    final showPending = pending > 0.5;

    final tabular = const [FontFeature.tabularFigures()];

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimado del mes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(s.estimatedTotal),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabular,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: theme.dividerColor,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pagado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(s.paidTotal),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabular,
                      color: AppColors.urgencyPaid,
                    ),
                  ),
                  if (showPending)
                    Text(
                      'falta ${formatCurrency(pending)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: tabular,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
