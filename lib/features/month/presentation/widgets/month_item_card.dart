import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format.dart';
import '../../../../core/url.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../domain/month_builder.dart';
import '../../domain/month_item.dart';
import '../bloc/month_bloc.dart';
import 'brand_chip.dart';
import 'calendar_tag.dart';
import 'urgency_badge.dart';

class MonthItemCard extends StatelessWidget {
  const MonthItemCard({
    required this.item,
    required this.period,
    required this.expanded,
    required this.onTap,
    required this.isMutating,
    super.key,
  });

  final MonthItem item;
  final PeriodKey period;
  final bool expanded;
  final VoidCallback onTap;
  final bool isMutating;

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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: isMutating ? null : onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CalendarTag(
                    day: item.dayOfMonth,
                    urgency: urgency,
                    paid: paid,
                  ),
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
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: expanded
                ? _ItemActions(
                    item: item,
                    isMutating: isMutating,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
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

class _ItemActions extends StatefulWidget {
  const _ItemActions({required this.item, required this.isMutating});

  final MonthItem item;
  final bool isMutating;

  @override
  State<_ItemActions> createState() => _ItemActionsState();
}

class _ItemActionsState extends State<_ItemActions> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final suggested = suggestedAmount(widget.item);
    _amountController = TextEditingController(
      text: suggested != null ? suggested.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? get _paymentUrl =>
      widget.item.bill?.url ?? widget.item.card?.url;

  Future<void> _openPayUrl() async {
    final raw = _paymentUrl;
    if (raw == null) return;

    final code = widget.item.bill?.providerCode;
    if (code != null && code.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: code));
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      _showSnack('El link no es válido.');
      return;
    }
    final mode = isWebUrl(raw)
        ? LaunchMode.externalApplication
        : LaunchMode.externalApplication;
    try {
      final ok = await launchUrl(uri, mode: mode);
      if (!ok) _showSnack('No se pudo abrir el link.');
    } catch (e) {
      _showSnack('No se pudo abrir el link.');
    }
  }

  void _submitPaid() {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      _showSnack('Ingresá un monto válido.');
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<MonthBloc>().add(
          MonthMarkPaidRequested(item: widget.item, amount: value),
        );
  }

  void _submitPending() {
    context
        .read<MonthBloc>()
        .add(MonthMarkPendingRequested(item: widget.item));
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paid = widget.item.payment?.status == PaymentStatus.paid;
    final url = _paymentUrl;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (url != null) ...[
            OutlinedButton.icon(
              onPressed: widget.isMutating ? null : _openPayUrl,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                widget.item.bill?.providerCode != null
                    ? 'Ir a pagar (copia código)'
                    : 'Ir a pagar',
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (paid) ...[
            Text(
              widget.item.payment?.amountReal != null
                  ? 'Pagado por ${formatCurrency(widget.item.payment!.amountReal)}'
                  : 'Pagado',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: widget.isMutating ? null : _submitPending,
              icon: widget.isMutating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.undo_rounded, size: 18),
              label: const Text('Marcar como pendiente'),
            ),
          ] else ...[
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto pagado',
                prefixText: '\$ ',
              ),
              onSubmitted: (_) => _submitPaid(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: widget.isMutating ? null : _submitPaid,
              icon: widget.isMutating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text('Marcar como pagado'),
            ),
          ],
        ],
      ),
    );
  }
}
