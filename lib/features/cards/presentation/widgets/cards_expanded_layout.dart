import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/fz_snackbar.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/bill.dart';
import '../../../../models/enums.dart';
import '../../../../widgets/animated_amount.dart';
import '../../../../widgets/animated_progress_bar.dart';
import '../../domain/card_list_item_data.dart';
import '../bloc/cards_bloc.dart';

/// Master/detail para Tarjetas en Fold inner / tablet.
/// Master 340 dp con lista compacta de tarjetas; detail flex con hero
/// de la tarjeta seleccionada y CTA para abrir el detalle completo.
class CardsExpandedLayout extends StatelessWidget {
  const CardsExpandedLayout({
    required this.state,
    required this.selectedCardId,
    required this.onSelect,
    super.key,
  });

  final CardsBlocState state;
  final String? selectedCardId;
  final ValueChanged<String> onSelect;

  CardListItemData? _selected() {
    if (selectedCardId == null) return null;
    for (final item in state.items) {
      if (item.card.id == selectedCardId) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected();
    final mutating = selected != null &&
        state.mutatingCardId == selected.card.id;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 340,
          child: _Master(
            state: state,
            selectedId: selectedCardId,
            onSelect: onSelect,
          ),
        ),
        Expanded(
          child: _Detail(
            item: selected,
            period: state.period,
            mutating: mutating,
          ),
        ),
      ],
    );
  }
}

// ============================================================
//  MASTER
// ============================================================

class _Master extends StatelessWidget {
  const _Master({
    required this.state,
    required this.selectedId,
    required this.onSelect,
  });

  final CardsBlocState state;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: FzColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MIS TARJETAS',
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 11,
                    color: FzColors.textMute,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.items.length} '
                  '${state.items.length == 1 ? "activa" : "activas"}',
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.44,
                    color: FzColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total mes · ${formatCurrency(state.totalForPeriod)}',
                  style: const TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 11,
                    color: FzColors.textDim,
                    letterSpacing: 0.44,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.items.isEmpty
                ? const Center(
                    child: Text(
                      'Sin tarjetas',
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 13,
                        color: FzColors.textDim,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = state.items[i];
                      return _MasterRow(
                        item: item,
                        period: state.period,
                        selected: item.card.id == selectedId,
                        onTap: () => onSelect(item.card.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MasterRow extends StatelessWidget {
  const _MasterRow({
    required this.item,
    required this.period,
    required this.selected,
    required this.onTap,
  });

  final CardListItemData item;
  final PeriodKey period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = item.card;
    final paid = item.payment?.status == PaymentStatus.paid;

    // Cada fila se ve como una mini-tarjeta (no un item plano de lista):
    // gradiente sutil, brand chip arriba a la izquierda, monto a la derecha
    // y nombre + estado abajo. Refleja el lenguaje del hero del detail
    // pero a menor escala.
    final List<Color> bgGradient;
    final Color border;
    if (selected) {
      bgGradient = const [FzColors.cardHi, FzColors.cardHi];
      border = FzColors.borderHi;
    } else if (paid) {
      bgGradient = const [FzColors.cardHi, FzColors.cardPaid];
      border = FzColors.borderPaid;
    } else {
      bgGradient = const [FzColors.cardHi, FzColors.card];
      border = FzColors.border;
    }

    final amountColor = paid ? FzColors.primaryHi : FzColors.text;
    final subColor = paid ? FzColors.primary : FzColors.textMute;
    final subLabel = paid
        ? 'PAGADA ESTE MES'
        : card.dueDay != null
        ? 'VENCE DÍA ${card.dueDay}'
        : 'SIN DÍA CONFIGURADO';
    final amountLabel = paid ? 'PAGADO' : 'A PAGAR';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgGradient,
            ),
            borderRadius: BorderRadius.circular(FzRadius.xl),
            border: Border.all(color: border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: brand chip + label/monto a la derecha.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandChip(brand: card.brand),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountLabel,
                          style: TextStyle(
                            fontFamily: FzType.mono,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.66,
                            color: paid ? FzColors.primary : FzColors.textMute,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedCurrency(
                          value: item.total,
                          style: TextStyle(
                            fontFamily: FzType.sans,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.28,
                            fontFeatures: FzType.tabularNums,
                            color: amountColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Nombre + estado abajo.
                Text(
                  card.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.29,
                    color: FzColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 10,
                    letterSpacing: 0.66,
                    color: subColor,
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

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.brand});
  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (brand) {
      CardBrand.visa => ('VISA', FzColors.visaBg),
      CardBrand.mastercard => ('MC', FzColors.mastercardBg),
      CardBrand.amex => ('AMEX', FzColors.mpBg),
      CardBrand.other => ('OTRA', FzColors.cardHi),
      null => ('—', FzColors.cardHi),
    };
    return Container(
      width: 38,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: FzType.sans,
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
        ),
      ),
    );
  }
}

// ============================================================
//  DETAIL
// ============================================================

class _Detail extends StatelessWidget {
  const _Detail({
    required this.item,
    required this.period,
    required this.mutating,
  });

  final CardListItemData? item;
  final PeriodKey period;
  final bool mutating;

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return const _DetailEmpty();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: _Hero(item: item!, period: period, mutating: mutating),
    );
  }
}

class _Hero extends StatefulWidget {
  const _Hero({
    required this.item,
    required this.period,
    required this.mutating,
  });

  final CardListItemData item;
  final PeriodKey period;
  final bool mutating;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _initialAmountText());
  }

  @override
  void didUpdateWidget(covariant _Hero oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cardChanged = oldWidget.item.card.id != widget.item.card.id;
    final realChanged = oldWidget.item.payment?.amountReal !=
        widget.item.payment?.amountReal;
    final totalChanged = oldWidget.item.total != widget.item.total;
    if (cardChanged || realChanged || totalChanged) {
      _amountController.text = _initialAmountText();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _initialAmountText() {
    final paid = widget.item.payment?.amountReal;
    if (paid != null) return paid.toStringAsFixed(0);
    final total = widget.item.total;
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
    context.read<CardsBloc>().add(
      CardsMarkPaidRequested(cardId: widget.item.card.id, amount: value),
    );
  }

  void _submitPending() {
    if (widget.mutating) return;
    context.read<CardsBloc>().add(
      CardsMarkPendingRequested(cardId: widget.item.card.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final period = widget.period;
    final card = item.card;
    final paid = item.payment?.status == PaymentStatus.paid;
    final hasAmount = item.total > 0;
    final urgency = hasAmount
        ? getUrgency(dayOfMonth: card.dueDay, paid: paid, period: period)
        : const Urgency.normal();
    final isOverdue = urgency is UrgencyOverdue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: paid
                  ? [FzColors.cardHi, FzColors.cardPaid]
                  : isOverdue
                  ? [FzColors.cardHi, FzColors.cardLate]
                  : [FzColors.cardHi, FzColors.card],
            ),
            borderRadius: BorderRadius.circular(FzRadius.xxl),
            border: Border.all(
              color: paid
                  ? FzColors.borderPaid
                  : isOverdue
                  ? FzColors.borderLate
                  : FzColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _BrandChip(brand: card.brand),
              ),
              const SizedBox(height: 10),
              Text(
                card.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.55,
                  color: FzColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _metaText(card.brand, card.dueDay, paid),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 11,
                  letterSpacing: 0.44,
                  color: FzColors.textDim,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    paid ? 'PAGADO' : 'A PAGAR',
                    style: TextStyle(
                      fontFamily: FzType.mono,
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: paid ? FzColors.primary : FzColors.textMute,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: AnimatedCurrency(
                        value: item.payment?.amountReal ?? item.total,
                        style: TextStyle(
                          fontFamily: FzType.sans,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.55,
                          fontFeatures: FzType.tabularNums,
                          color: paid ? FzColors.primaryHi : FzColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Quick-pay block — input + botón Marcar pagado/pendiente.
        // Espejo del flujo del compact `CardListItem`: acción primaria
        // sobre el monto del hero, sin necesidad de navegar al detail.
        const SizedBox(height: 12),
        _QuickPayBlock(
          controller: _amountController,
          paid: paid,
          mutating: widget.mutating,
          onMarkPaid: _submitPaid,
          onMarkPending: _submitPending,
        ),
        // Cuotas activas: lista con progress por compra. Si no hay,
        // omitimos el panel completo (no mostrar "0 cuotas" sin info).
        if (item.activeInstallments.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InstallmentsPanel(items: item.activeInstallments),
        ],
        // Débitos automáticos: lista de bills + monto.
        if (item.autoDebitBills.isNotEmpty) ...[
          const SizedBox(height: 12),
          _AutoDebitsPanel(bills: item.autoDebitBills),
        ],
        // Empty state: ni cuotas ni débitos en este mes.
        if (item.activeInstallments.isEmpty &&
            item.autoDebitBills.isEmpty) ...[
          const SizedBox(height: 12),
          const _NoChargesNote(),
        ],
        const SizedBox(height: 12),
        // CTA al detail completo (con histórico, edición, etc.).
        Material(
          color: FzColors.primary,
          borderRadius: BorderRadius.circular(FzRadius.lg),
          child: InkWell(
            onTap: () => context.push('/cards/${card.id}'),
            borderRadius: BorderRadius.circular(FzRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FzRadius.lg),
                boxShadow: FzShadow.ctaPrimary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: FzColors.primaryInk,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Abrir tarjeta',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FzColors.primaryInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _metaText(CardBrand? brand, int? dueDay, bool paid) {
    final brandText = switch (brand) {
      CardBrand.visa => 'VISA',
      CardBrand.mastercard => 'MASTERCARD',
      CardBrand.amex => 'AMEX',
      CardBrand.other => 'TARJETA',
      null => 'TARJETA',
    };
    if (paid) return '$brandText · PAGADA ESTE MES';
    if (dueDay != null) return '$brandText · VENCE DÍA $dueDay';
    return brandText;
  }
}

/// Bloque "Quick pay": input "MONTO PAGADO (ARS)" + botón Marcar
/// pagado/pendiente. Mismos tokens que en `CardListItem`.
class _QuickPayBlock extends StatelessWidget {
  const _QuickPayBlock({
    required this.controller,
    required this.paid,
    required this.mutating,
    required this.onMarkPaid,
    required this.onMarkPending,
  });

  final TextEditingController controller;
  final bool paid;
  final bool mutating;
  final VoidCallback onMarkPaid;
  final VoidCallback onMarkPending;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: 10),
        _QuickPayButton(
          label: paid ? 'Marcar pendiente' : 'Marcar pagado',
          icon: paid ? Icons.undo_rounded : Icons.check_rounded,
          primary: !paid,
          loading: mutating,
          onTap: paid ? onMarkPending : onMarkPaid,
        ),
      ],
    );
  }
}

class _QuickPayButton extends StatelessWidget {
  const _QuickPayButton({
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

/// Panel "Cuotas activas (N)": lista de cuotas en curso para esta tarjeta
/// en el período actual. Cada fila muestra descripción + monto/mes +
/// progress bar `cuotaIndex / installmentCount`.
class _InstallmentsPanel extends StatelessWidget {
  const _InstallmentsPanel({required this.items});

  final List<ActiveInstallment> items;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      icon: Icons.payments_outlined,
      title: 'CUOTAS ACTIVAS',
      count: items.length,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _InstallmentRow(item: items[i]),
            if (i < items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow({required this.item});

  final ActiveInstallment item;

  @override
  Widget build(BuildContext context) {
    final purchase = item.purchase;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                purchase.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FzColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${formatCurrency(purchase.installmentAmount)}/mes',
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                fontFeatures: FzType.tabularNums,
                color: FzColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: AnimatedProgressBar(value: item.progress)),
            const SizedBox(width: 8),
            Text(
              '${item.cuotaIndex}/${purchase.installmentCount}',
              style: const TextStyle(
                fontFamily: FzType.mono,
                fontSize: 10.5,
                color: FzColors.textDim,
                letterSpacing: 0.44,
                fontFeatures: FzType.tabularNums,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Panel "Débitos automáticos (N)": bills que se descuentan automáticamente
/// de esta tarjeta. Cada fila muestra el ícono del kind + nombre + monto.
class _AutoDebitsPanel extends StatelessWidget {
  const _AutoDebitsPanel({required this.bills});

  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      icon: Icons.bolt_outlined,
      title: 'DÉBITOS AUTOMÁTICOS',
      count: bills.length,
      child: Column(
        children: [
          for (var i = 0; i < bills.length; i++) ...[
            _AutoDebitRow(bill: bills[i]),
            if (i < bills.length - 1)
              const Divider(
                height: 12,
                thickness: 0.5,
                color: FzColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _AutoDebitRow extends StatelessWidget {
  const _AutoDebitRow({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final amount = bill.defaultAmount;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: FzColors.cardHi,
            borderRadius: BorderRadius.circular(FzRadius.sm),
            border: Border.all(color: FzColors.border),
          ),
          child: Text(
            kBillKindEmoji[bill.kind] ?? '📌',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bill.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: FzColors.text,
                ),
              ),
              if (kBillKindShortLabels[bill.kind] != null) ...[
                const SizedBox(height: 1),
                Text(
                  kBillKindShortLabels[bill.kind]!,
                  style: const TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 10,
                    color: FzColors.textMute,
                    letterSpacing: 0.66,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount == null ? 'variable' : formatCurrency(amount),
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontFamily: FzType.sans,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFeatures: FzType.tabularNums,
            color: amount == null ? FzColors.textDim : FzColors.text,
          ),
        ),
      ],
    );
  }
}

/// Card contenedor con header `icon + TITLE + count` y el contenido
/// abajo. Reusable por los dos panels (cuotas + débitos).
class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.title,
    required this.count,
    required this.child,
  });

  final IconData icon;
  final String title;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: FzColors.textDim),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: const TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.05,
                    color: FzColors.textDim,
                  ),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 10.5,
                  color: FzColors.textMute,
                  letterSpacing: 0.44,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Empty state cuando una tarjeta no tiene ni cuotas ni débitos en el
/// mes (o es nueva, o ya se pagó todo de un mes anterior).
class _NoChargesNote extends StatelessWidget {
  const _NoChargesNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: FzColors.primary,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta tarjeta no tiene cuotas ni débitos automáticos en el mes.',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12.5,
                color: FzColors.textDim,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailEmpty extends StatelessWidget {
  const _DetailEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: FzColors.card,
            borderRadius: BorderRadius.circular(FzRadius.xxl),
            border: Border.all(color: FzColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.credit_card_outlined,
                size: 36,
                color: FzColors.textMute,
              ),
              SizedBox(height: 10),
              Text(
                'Seleccioná una tarjeta',
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: FzColors.text,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tocá una tarjeta a la izquierda para ver su detalle.',
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 12,
                  color: FzColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
