import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../domain/month_item.dart';
import 'brand_chip.dart';
import 'calendar_tag.dart';
import 'urgency_badge.dart';

class MonthItemCard extends StatelessWidget {
  const MonthItemCard({
    required this.item,
    required this.period,
    super.key,
  });

  final MonthItem item;
  final PeriodKey period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paid = item.payment?.status == PaymentStatus.paid;
    final hasAmount =
        item.estimatedAmount != null && item.estimatedAmount! > 0;
    final urgency = hasAmount
        ? getUrgency(
            dayOfMonth: item.dayOfMonth,
            paid: paid,
            period: period,
          )
        : const Urgency.normal();

    final amount = paid && item.payment?.amountReal != null
        ? item.payment!.amountReal
        : item.estimatedAmount;

    final subtitle = _subtitleFor(item);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CalendarTag(day: item.dayOfMonth, urgency: urgency, paid: paid),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          item.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.kind == MonthItemKind.cardTotal &&
                          item.card?.brand != null) ...[
                        const SizedBox(width: 8),
                        BrandChip(brand: item.card!.brand),
                      ],
                      if (urgency is! UrgencyNormal) ...[
                        const SizedBox(width: 8),
                        UrgencyBadge(urgency: urgency),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatCurrency(amount),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _subtitleFor(MonthItem item) {
    if (item.kind == MonthItemKind.cardTotal) {
      final ic = item.cardInstallmentsCount ?? 0;
      final ad = item.cardAutoDebitsCount ?? 0;
      if (ic == 0 && ad == 0) return 'Sin cargos este mes';
      final parts = <String>[];
      if (ic > 0) parts.add('$ic ${ic == 1 ? "cuota" : "cuotas"}');
      if (ad > 0) parts.add('$ad ${ad == 1 ? "déb. aut." : "débs. aut."}');
      return parts.join(' · ');
    }
    final code = item.bill?.providerCode;
    if (code != null && code.isNotEmpty) return code;
    return null;
  }
}
