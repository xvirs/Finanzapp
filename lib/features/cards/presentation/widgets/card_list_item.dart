import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../../month/presentation/widgets/brand_chip.dart';
import '../../../month/presentation/widgets/calendar_tag.dart';
import '../../../month/presentation/widgets/urgency_badge.dart';
import '../../domain/card_list_item_data.dart';

class CardListItem extends StatelessWidget {
  const CardListItem({
    required this.data,
    required this.period,
    required this.onTap,
    super.key,
  });

  final CardListItemData data;
  final PeriodKey period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = data.card;
    final paid = data.payment?.status == PaymentStatus.paid;
    final hasAmount = data.total > 0;
    final urgency = hasAmount
        ? getUrgency(
            dayOfMonth: card.dueDay,
            paid: paid,
            period: period,
          )
        : const Urgency.normal();

    final amount = paid && data.payment?.amountReal != null
        ? data.payment!.amountReal!
        : data.total;

    final url = card.url;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CalendarTag(
                    day: card.dueDay,
                    urgency: urgency,
                    paid: paid,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                card.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (card.brand != null) ...[
                              const SizedBox(width: 8),
                              BrandChip(brand: card.brand),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitleFor(data),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (urgency is! UrgencyNormal) ...[
                          const SizedBox(height: 6),
                          UrgencyBadge(urgency: urgency),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(amount),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  if (card.dueDay != null && !paid && hasAmount)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Vence día ${card.dueDay}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (paid)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Pagado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (url != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openPayUrl(context, url),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Ir a pagar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleFor(CardListItemData data) {
    if (!data.hasCharges) return 'Sin cargos este mes';
    final parts = <String>[];
    if (data.installmentsCount > 0) {
      parts.add(
        '${data.installmentsCount} ${data.installmentsCount == 1 ? "cuota" : "cuotas"}',
      );
    }
    if (data.autoDebitsCount > 0) {
      parts.add(
        '${data.autoDebitsCount} ${data.autoDebitsCount == 1 ? "déb. aut." : "débs. aut."}',
      );
    }
    return parts.join(' · ');
  }

  Future<void> _openPayUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack(context, 'El link no es válido.');
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _showSnack(context, 'No se pudo abrir el link.');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'No se pudo abrir el link.');
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
