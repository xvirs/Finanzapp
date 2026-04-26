import '../models/bill.dart';
import '../models/installment_purchase.dart';
import 'period.dart';

/// ¿Está activa esta cuota en el período `target`?
///
/// Reproduce 1:1 `lib/installments.ts → installmentForPeriod` de la web.
({int cuotaIndex, double amount})? installmentForPeriod(
  InstallmentPurchase purchase,
  PeriodKey target,
) {
  final start = PeriodKey.fromIso(purchase.firstPeriod);
  final diff = start.differenceInMonths(target);
  if (diff < 0) return null;
  final cuotaIndex = diff + 1;
  if (cuotaIndex > purchase.installmentCount) return null;
  return (cuotaIndex: cuotaIndex, amount: purchase.installmentAmount);
}

typedef CardMonthSummary = ({
  double total,
  int installmentsCount,
  double installmentsTotal,
  int autoDebitsCount,
  double autoDebitsTotal,
});

/// Total del mes para una tarjeta = cuotas activas + bills con débito
/// automático en esa tarjeta.
CardMonthSummary summarizeCardForPeriod({
  required List<InstallmentPurchase> purchases,
  required PeriodKey target,
  List<Bill> autoDebitBills = const [],
}) {
  var installmentsTotal = 0.0;
  var installmentsCount = 0;
  for (final p in purchases) {
    final result = installmentForPeriod(p, target);
    if (result != null) {
      installmentsTotal += result.amount;
      installmentsCount++;
    }
  }

  var autoDebitsTotal = 0.0;
  var autoDebitsCount = 0;
  for (final bill in autoDebitBills) {
    if (!bill.active) continue;
    autoDebitsTotal += bill.defaultAmount ?? 0;
    autoDebitsCount++;
  }

  return (
    total: installmentsTotal + autoDebitsTotal,
    installmentsCount: installmentsCount,
    installmentsTotal: installmentsTotal,
    autoDebitsCount: autoDebitsCount,
    autoDebitsTotal: autoDebitsTotal,
  );
}

/// Período de la última cuota de una compra (la cuota N).
PeriodKey purchaseFinalPeriod(InstallmentPurchase purchase) {
  final start = PeriodKey.fromIso(purchase.firstPeriod);
  final lastIndex = purchase.installmentCount - 1;
  final totalMonth = start.month + lastIndex;
  return PeriodKey(
    year: start.year + totalMonth ~/ 12,
    month: totalMonth % 12,
  );
}
