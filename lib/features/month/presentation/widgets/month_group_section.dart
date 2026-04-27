import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../domain/month_item.dart';
import '../bloc/month_bloc.dart';
import 'month_item_card.dart';

/// Sección de categoría — port pixel-perfect de `ACategoryHeader` + lista
/// de `APayItem` del JSX.
class MonthGroupSection extends StatelessWidget {
  const MonthGroupSection({
    required this.group,
    required this.period,
    required this.filter,
    required this.expandedKey,
    required this.mutatingItemKey,
    required this.onToggle,
    super.key,
  });

  final MonthGroup group;
  final PeriodKey period;
  final MonthFilter filter;
  final String? expandedKey;
  final String? mutatingItemKey;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final visibleItems = _filtered(group.items);
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CategoryHeader(
          icon: _categoryIcon(group.key),
          title: group.title,
          count: visibleItems.length,
          totalLabel: _totalLabel(visibleItems),
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
    );
  }

  List<MonthItem> _filtered(List<MonthItem> items) {
    switch (filter) {
      case MonthFilter.all:
        return items;
      case MonthFilter.pending:
        return items
            .where((i) => i.payment?.status != PaymentStatus.paid)
            .toList();
      case MonthFilter.overdue:
        return items.where((i) {
          if (i.payment?.status == PaymentStatus.paid) return false;
          if (i.estimatedAmount == null || i.estimatedAmount! <= 0) {
            return false;
          }
          final urgency = getUrgency(
            dayOfMonth: i.dayOfMonth,
            paid: false,
            period: period,
          );
          return urgency is UrgencyOverdue;
        }).toList();
    }
  }

  /// Si todos los items tienen estimatedAmount → suma. Si alguno es Variable
  /// (estimatedAmount==null) → "—" como en el JSX.
  String _totalLabel(List<MonthItem> items) {
    final hasVariable = items.any((i) => i.estimatedAmount == null);
    if (hasVariable) return '—';
    final total =
        items.fold<double>(0, (acc, i) => acc + (i.estimatedAmount ?? 0));
    return formatCurrency(total);
  }
}

/// Icono que mapea cada macrocategoría al icono Material equivalente al
/// AIcon del JSX (card / home / bolt / bank / etc.).
IconData _categoryIcon(String macroKey) {
  switch (macroKey) {
    case 'cards':
      return Icons.credit_card_outlined;
    case 'housing':
      return Icons.home_outlined;
    case 'services':
      return Icons.bolt_outlined;
    case 'internet':
      return Icons.wifi;
    case 'health':
      return Icons.local_hospital_outlined;
    case 'tax':
      return Icons.account_balance_outlined;
    case 'subscription':
      return Icons.subscriptions_outlined;
    case 'other':
    default:
      return Icons.label_outline;
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.totalLabel,
  });

  final IconData icon;
  final String title;
  final int count;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: FzColors.textDim),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.1,
                  color: FzColors.textDim,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· $count',
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 11,
                  color: FzColors.textMute,
                ),
              ),
            ],
          ),
          Text(
            totalLabel,
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 12,
              color: FzColors.textMute,
              fontFeatures: FzType.tabularNums,
            ),
          ),
        ],
      ),
    );
  }
}
