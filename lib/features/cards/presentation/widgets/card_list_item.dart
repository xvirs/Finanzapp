import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../../../widgets/card_brand_logo.dart';
import '../../../../widgets/fz_snackbar.dart';
import '../../domain/card_list_item_data.dart';

/// Card grande de la lista de tarjetas.
///
/// Layout vertical:
///   - Tap area (navega al detail):
///       Row 1: lead 38x38 (day or ✓) + nombre + brand chip + ATRASADA badge
///       Row 2: monto 24 px + caplabel mono ("PAGADO" / "VENCE DÍA 15")
///   - Quick-pay area (fuera del InkWell):
///       Row 3: input "MONTO PAGADO" + botón "Marcar pagado/pendiente"
///
/// El "Ir a pagar" vive en el detail, no acá — el flujo de la lista es
/// rápido (anotás cuánto pagaste sin entrar al detail).
class CardListItem extends StatefulWidget {
  const CardListItem({
    required this.data,
    required this.period,
    required this.onTap,
    required this.mutating,
    required this.onMarkPaid,
    required this.onMarkPending,
    super.key,
  });

  final CardListItemData data;
  final PeriodKey period;
  final VoidCallback onTap;

  /// True mientras corre un mark paid/pending para esta tarjeta —
  /// muestra spinner y bloquea el botón.
  final bool mutating;

  /// Disparada cuando el usuario tap "Marcar pagado". Recibe el monto
  /// validado (> 0).
  final ValueChanged<double> onMarkPaid;

  /// Disparada cuando el usuario tap "Marcar pendiente".
  final VoidCallback onMarkPending;

  @override
  State<CardListItem> createState() => _CardListItemState();
}

class _CardListItemState extends State<CardListItem> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _initialAmountText());
  }

  @override
  void didUpdateWidget(covariant CardListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldReal = oldWidget.data.payment?.amountReal;
    final newReal = widget.data.payment?.amountReal;
    final oldTotal = oldWidget.data.total;
    final newTotal = widget.data.total;
    if (oldReal != newReal || oldTotal != newTotal) {
      _amountController.text = _initialAmountText();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// pagado real > total estimado > vacío. Sin decimales (pesos enteros).
  String _initialAmountText() {
    final paid = widget.data.payment?.amountReal;
    if (paid != null) return paid.toStringAsFixed(0);
    final total = widget.data.total;
    if (total > 0) return total.toStringAsFixed(0);
    return '';
  }

  void _submitPaid() {
    if (widget.mutating) return;
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      showFzSnack(
        context,
        'Ingresá un monto válido.',
        kind: FzSnackKind.error,
      );
      return;
    }
    widget.onMarkPaid(value);
  }

  void _submitPending() {
    if (widget.mutating) return;
    widget.onMarkPending();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final card = data.card;
    final paid = data.payment?.status == PaymentStatus.paid;
    final hasAmount = data.total > 0;
    final urgency = hasAmount
        ? getUrgency(dayOfMonth: card.dueDay, paid: paid, period: widget.period)
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tap-to-navigate area: ripple solo dentro del area de info,
            // no propaga al input/botón de abajo.
            InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            // Quick-pay area — fuera del InkWell para que el TextField y
            // el botón manejen sus propios taps sin disparar la
            // navegación al detail.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AmountInput(controller: _amountController),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: paid ? 'Marcar pendiente' : 'Marcar pagado',
                    icon: paid ? Icons.undo_rounded : Icons.check_rounded,
                    primary: !paid,
                    loading: widget.mutating,
                    onTap: paid ? _submitPending : _submitPaid,
                  ),
                ],
              ),
            ),
          ],
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
    return CardBrandLogo(brand: brand, size: 22);
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

/// Input numérico inline del item — caplabel "MONTO PAGADO (ARS)" +
/// field con prefijo "$". Mismo lenguaje visual que el `_AmountInput`
/// del hero del Mes (expanded).
class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MONTO PAGADO (ARS)',
          style: TextStyle(
            fontFamily: FzType.mono,
            fontSize: 10,
            color: FzColors.textMute,
            letterSpacing: 0.66,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: FzColors.bg,
            borderRadius: BorderRadius.circular(FzRadius.lg),
            border: Border.all(color: FzColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FzColors.text,
              fontFeatures: FzType.tabularNums,
            ),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
              hintText: '0',
              hintStyle: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FzColors.textDim,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón de acción del item — variantes primary (verde) / secondary
/// (outline). Estado loading reemplaza el icono por spinner y bloquea
/// el tap.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? FzColors.primary : Colors.transparent;
    final fg = primary ? FzColors.primaryInk : FzColors.text;
    final border = primary ? FzColors.primary : FzColors.borderHi;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              else
                Icon(icon, size: 13, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 13,
                    fontWeight: primary ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
