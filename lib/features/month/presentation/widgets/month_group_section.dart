import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../domain/period.dart';
import '../../../../models/enums.dart';
import '../../domain/month_item.dart';
import 'month_item_card.dart';

class MonthGroupSection extends StatelessWidget {
  const MonthGroupSection({
    required this.group,
    required this.period,
    required this.onlyPending,
    required this.expandedKey,
    required this.mutatingItemKey,
    required this.onToggle,
    super.key,
  });

  final MonthGroup group;
  final PeriodKey period;
  final bool onlyPending;
  final String? expandedKey;
  final String? mutatingItemKey;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleItems = onlyPending
        ? group.items
            .where((i) => i.payment?.status != PaymentStatus.paid)
            .toList()
        : group.items;

    if (visibleItems.isEmpty) return const SizedBox.shrink();

    final groupTotal = visibleItems.fold<double>(
      0,
      (acc, i) => acc + (i.estimatedAmount ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
            child: Row(
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  group.title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 0.6,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${visibleItems.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  formatCurrency(groupTotal),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          ...visibleItems.map(
            (item) => MonthItemCard(
              item: item,
              period: period,
              expanded: expandedKey == item.key,
              isMutating: mutatingItemKey == item.key,
              onTap: () => onToggle(item.key),
            ),
          ),
        ],
      ),
    );
  }
}
