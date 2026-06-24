import 'package:equatable/equatable.dart';

import '../../../models/bill.dart';
import '../../../models/credit_card.dart';
import '../../../models/installment_purchase.dart';
import '../../../models/payment.dart';

/// Cuota activa en el período: la compra más el índice de cuota actual
/// (1-indexed). Útil para renderizar progress bars `cuotaIndex / total`.
class ActiveInstallment extends Equatable {
  const ActiveInstallment({required this.purchase, required this.cuotaIndex});

  final InstallmentPurchase purchase;
  final int cuotaIndex;

  /// Cuotas que ya se pagaron antes de esta (`cuotaIndex - 1`).
  int get paidCount => cuotaIndex - 1;

  /// Cuotas restantes después de esta (incluye la actual).
  int get remainingCount => purchase.installmentCount - paidCount;

  /// Progreso 0..1 contando la cuota actual como pagada.
  double get progress =>
      cuotaIndex / purchase.installmentCount.clamp(1, 999).toDouble();

  @override
  List<Object?> get props => [purchase, cuotaIndex];
}

/// Datos pre-computados de una tarjeta para el período actual, listos
/// para renderizar en la lista y en el detail pane (fold/expanded).
class CardListItemData extends Equatable {
  const CardListItemData({
    required this.card,
    required this.activeInstallments,
    required this.autoDebitBills,
    required this.total,
    required this.payment,
  });

  final CreditCard card;
  final List<ActiveInstallment> activeInstallments;
  final List<Bill> autoDebitBills;
  final double total;
  final Payment? payment;

  int get installmentsCount => activeInstallments.length;
  int get autoDebitsCount => autoDebitBills.length;

  bool get hasCharges => installmentsCount > 0 || autoDebitsCount > 0;

  @override
  List<Object?> get props => [
    card,
    activeInstallments,
    autoDebitBills,
    total,
    payment,
  ];
}
