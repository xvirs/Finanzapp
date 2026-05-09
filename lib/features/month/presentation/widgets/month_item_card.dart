import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../../../widgets/fz_snackbar.dart';
import '../../domain/month_builder.dart';
import '../../domain/month_item.dart';
import '../bloc/month_bloc.dart';

/// Item card del Mes — port pixel-perfect de `APayItem` del JSX.
///
/// Estados visuales:
/// - paid: cardPaid bg, borderPaid, lead verde con check
/// - overdue: cardLate bg, borderLate, lead rojo con "!"
/// - pending (default): card bg, border, lead neutro con "·"
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
    final paid = item.payment?.status == PaymentStatus.paid;
    final hasAmount = item.estimatedAmount != null && item.estimatedAmount! > 0;
    final urgency = hasAmount
        ? getUrgency(dayOfMonth: item.dayOfMonth, paid: paid, period: period)
        : const Urgency.normal();
    final isOverdue = urgency is UrgencyOverdue;

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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: isMutating ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _LeadIcon(paid: paid, overdue: isOverdue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NameRow(item: item, isOverdue: isOverdue),
                        if (_subtitle(item) != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _subtitle(item)!,
                            style: const TextStyle(
                              fontFamily: FzType.mono,
                              fontSize: 11.5,
                              color: FzColors.textMute,
                              letterSpacing: 0.46,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AmountColumn(item: item, paid: paid, isOverdue: isOverdue),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: FzMotion.fast,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: FzColors.textMute,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: FzMotion.normal,
            curve: FzMotion.easing,
            child: expanded
                ? _ItemActions(
                    item: item,
                    isMutating: isMutating,
                    cardBorder: cardBorder,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  static String? _subtitle(MonthItem item) {
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
    if (code != null && code.isNotEmpty) return 'Ref · $code';
    return null;
  }
}

/// 38x38 cuadrado con el icono de estado al inicio del item.
class _LeadIcon extends StatelessWidget {
  const _LeadIcon({required this.paid, required this.overdue});

  final bool paid;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final bg = paid
        ? FzColors.primary
        : overdue
        ? FzColors.lateColor
        : FzColors.cardHi;
    final fg = paid
        ? FzColors.primaryInk
        : overdue
        ? Colors.white
        : FzColors.textDim;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: paid
          ? Icon(Icons.check_rounded, size: 18, color: fg)
          : Text(
              overdue ? '!' : '·',
              style: TextStyle(
                color: fg,
                fontFamily: FzType.sans,
                fontWeight: FontWeight.w600,
                fontSize: overdue ? 18 : 22,
                height: 1,
              ),
            ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.item, required this.isOverdue});

  final MonthItem item;
  final bool isOverdue;

  bool get _isOneShot {
    final bill = item.bill;
    if (bill == null) return false;
    return bill.endPeriod != null && bill.endPeriod == bill.startPeriod;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            item.label,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.07,
              color: FzColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.kind == MonthItemKind.cardTotal &&
            item.card?.brand != null) ...[
          const SizedBox(width: 6),
          _BrandChip(brand: item.card!.brand!),
        ],
        if (_isOneShot) ...[const SizedBox(width: 6), const _OneShotBadge()],
        if (isOverdue) ...[const SizedBox(width: 6), const _OverdueBadge()],
      ],
    );
  }
}

class _OneShotBadge extends StatelessWidget {
  const _OneShotBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: FzColors.primarySoft,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: const Text(
        'PUNTUAL',
        style: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.36,
          color: FzColors.primaryHi,
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
          color: FzColors.lateColor,
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.item,
    required this.paid,
    required this.isOverdue,
  });

  final MonthItem item;
  final bool paid;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final showAmount = paid && item.payment?.amountReal != null
        ? item.payment!.amountReal!
        : item.estimatedAmount;

    final caplabel = paid ? 'PAGADO' : (isOverdue ? 'ESTIMADO' : 'A PAGAR');
    final caplabelColor = paid ? FzColors.primary : FzColors.textMute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          caplabel,
          style: TextStyle(
            fontFamily: FzType.mono,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: caplabelColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          showAmount == null ? 'Variable' : formatCurrency(showAmount),
          style: TextStyle(
            fontFamily: FzType.sans,
            fontSize: 15,
            fontWeight: showAmount == null ? FontWeight.w500 : FontWeight.w600,
            letterSpacing: -0.15,
            fontFeatures: FzType.tabularNums,
            color: showAmount == null ? FzColors.textDim : FzColors.text,
          ),
        ),
      ],
    );
  }
}

/// Sección expandida del item — replica el `AHomeExpanded.children`.
class _ItemActions extends StatefulWidget {
  const _ItemActions({
    required this.item,
    required this.isMutating,
    required this.cardBorder,
  });

  final MonthItem item;
  final bool isMutating;
  final Color cardBorder;

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

  String? get _paymentUrl => widget.item.bill?.url ?? widget.item.card?.url;

  Future<void> _openPayUrl() async {
    final raw = _paymentUrl;
    if (raw == null) return;
    final code = widget.item.bill?.providerCode;
    if (code != null && code.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: code));
      if (mounted) {
        _snack('Código $code copiado', kind: FzSnackKind.success);
      }
    }
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      _snack('El link no es válido.', kind: FzSnackKind.error);
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _snack('No se pudo abrir el link.', kind: FzSnackKind.error);
    } catch (_) {
      _snack('No se pudo abrir el link.', kind: FzSnackKind.error);
    }
  }

  void _submitPaid() {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      _snack('Ingresá un monto válido.', kind: FzSnackKind.error);
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<MonthBloc>().add(
      MonthMarkPaidRequested(item: widget.item, amount: value),
    );
  }

  void _submitPending() {
    context.read<MonthBloc>().add(MonthMarkPendingRequested(item: widget.item));
  }

  void _snack(String msg, {FzSnackKind kind = FzSnackKind.info}) {
    if (!mounted) return;
    showFzSnack(context, msg, kind: kind);
  }

  @override
  Widget build(BuildContext context) {
    final paid = widget.item.payment?.status == PaymentStatus.paid;
    final url = _paymentUrl;
    final hasCode = widget.item.bill?.providerCode?.isNotEmpty ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: widget.cardBorder)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (url != null) ...[
            _SecondaryButton(
              label: hasCode ? 'Ir a pagar · copiar código' : 'Ir a pagar',
              icon: Icons.open_in_new_rounded,
              onPressed: widget.isMutating ? null : _openPayUrl,
            ),
            const SizedBox(height: 10),
          ],
          if (paid) ...[
            if (widget.item.payment?.amountReal != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Pagado por ${formatCurrency(widget.item.payment!.amountReal)}',
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 12,
                    color: FzColors.textDim,
                  ),
                ),
              ),
            _PendingButton(
              loading: widget.isMutating,
              onPressed: widget.isMutating ? null : _submitPending,
            ),
          ] else ...[
            _AmountField(controller: _amountController),
            const SizedBox(height: 10),
            _PrimaryButton(
              label: 'Marcar como pagado',
              icon: Icons.check_rounded,
              loading: widget.isMutating,
              onPressed: widget.isMutating ? null : _submitPaid,
            ),
          ],
        ],
      ),
    );
  }
}

/// Botón secundario (cardHi bg).
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FzColors.cardHi,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: FzColors.border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: FzColors.text),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13.5,
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

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});
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
            fontSize: 10.5,
            color: FzColors.textMute,
            letterSpacing: 0.63,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
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
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.loading,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FzRadius.lg),
        boxShadow: disabled ? null : FzShadow.ctaPrimary,
      ),
      child: Material(
        color: disabled
            ? FzColors.primary.withValues(alpha: 0.6)
            : FzColors.primary,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(FzRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(FzColors.primaryInk),
                    ),
                  )
                else
                  Icon(icon, size: 16, color: FzColors.primaryInk),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FzColors.primaryInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingButton extends StatelessWidget {
  const _PendingButton({required this.loading, this.onPressed});
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _SecondaryButton(
      label: loading ? 'Procesando…' : 'Marcar como pendiente',
      icon: Icons.undo_rounded,
      onPressed: onPressed,
    );
  }
}
