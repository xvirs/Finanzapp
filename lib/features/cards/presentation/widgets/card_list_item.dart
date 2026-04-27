import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../domain/card_list_item_data.dart';

/// Card grande de la lista de tarjetas — port pixel-perfect del item
/// dentro de `ACardsList` (handoff/screens-a-cards.jsx).
///
/// Layout vertical:
///   Row 1: lead 38x38 (day or ✓) + nombre + brand chip + ATRASADA badge
///   Row 2: monto 24 px + caplabel mono ("PAGADO" / "VENCE DÍA 15")
///   Row 3: botón "Ir a pagar" outline
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
    final isOverdue = urgency is UrgencyOverdue;
    final isEmpty = !paid && !hasAmount;

    final cardBg = paid
        ? FzColors.cardPaid
        : isOverdue
            ? FzColors.cardLate
            : FzColors.card;
    final cardBorder = paid
        ? FzColors.borderPaid
        : isOverdue
            ? FzColors.borderLate
            : FzColors.border;

    final amountForDisplay = paid && data.payment?.amountReal != null
        ? data.payment!.amountReal!
        : data.total;

    final url = card.url;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(FzRadius.xxl),
          border: Border.all(color: cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _LeadBox(
                      day: card.dueDay,
                      paid: paid,
                      overdue: isOverdue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                card.name,
                                style: const TextStyle(
                                  fontFamily: FzType.sans,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.07,
                                  color: FzColors.text,
                                ),
                              ),
                              if (card.brand != null)
                                _BrandChip(brand: card.brand!),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _subtitle(data),
                            style: const TextStyle(
                              fontFamily: FzType.mono,
                              fontSize: 11.5,
                              color: FzColors.textMute,
                              letterSpacing: 0.46,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      const _OverdueBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(amountForDisplay),
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.48,
                        fontFeatures: FzType.tabularNums,
                        color: isEmpty
                            ? FzColors.textDim
                            : paid
                                ? FzColors.primaryHi
                                : FzColors.text,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _rightCaplabel(
                        paid: paid,
                        isOverdue: isOverdue,
                        dueDay: card.dueDay,
                      ),
                      style: TextStyle(
                        fontFamily: FzType.mono,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.44,
                        color: paid ? FzColors.primary : FzColors.textMute,
                      ),
                    ),
                  ],
                ),

                // Row 3 — botón "Ir a pagar" si hay url
                if (url != null) ...[
                  const SizedBox(height: 12),
                  _PayButton(
                    url: url,
                    cardBorder: cardBorder,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _subtitle(CardListItemData data) {
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

  static String _rightCaplabel({
    required bool paid,
    required bool isOverdue,
    required int? dueDay,
  }) {
    if (paid) return 'PAGADO';
    if (isOverdue) return 'ATRASADA';
    if (dueDay != null) return 'VENCE DÍA $dueDay';
    return '';
  }
}

class _LeadBox extends StatelessWidget {
  const _LeadBox({
    required this.day,
    required this.paid,
    required this.overdue,
  });

  final int? day;
  final bool paid;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final bg = paid
        ? FzColors.primary
        : overdue
            ? FzColors.lateSoft
            : FzColors.cardHi;
    final fg = paid
        ? FzColors.primaryInk
        : overdue
            ? FzColors.lateInk
            : FzColors.textDim;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.md),
        border: overdue
            ? Border.all(color: FzColors.lateColor.withValues(alpha: 0.4))
            : null,
      ),
      alignment: Alignment.center,
      child: paid
          ? Icon(Icons.check_rounded, size: 18, color: fg)
          : Text(
              day?.toString() ?? '·',
              style: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
                fontFeatures: FzType.tabularNums,
              ),
            ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.brand});
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (brand) {
      CardBrand.visa => ('VISA', FzColors.visaBg),
      CardBrand.mastercard => ('Mastercard', FzColors.mastercardBg),
      CardBrand.amex => ('AMEX', FzColors.mpBg),
      CardBrand.other => ('Otra', FzColors.cardHi),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: FzType.sans,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
        ),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: FzColors.lateSoft,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: const Text(
        'ATRASADA',
        style: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.54,
          color: FzColors.lateInk,
        ),
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.url, required this.cardBorder});

  final String url;
  final Color cardBorder;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack(context, 'El link no es válido.');
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _snack(context, 'No se pudo abrir el link.');
    } catch (_) {
      if (context.mounted) _snack(context, 'No se pudo abrir el link.');
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.md),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: cardBorder),
            borderRadius: BorderRadius.circular(FzRadius.md),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_new_rounded, size: 14, color: FzColors.text),
              SizedBox(width: 8),
              Text(
                'Ir a pagar',
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: FzColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
