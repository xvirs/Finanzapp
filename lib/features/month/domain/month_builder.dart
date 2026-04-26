import '../../../domain/period.dart';
import '../../../models/bill.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../models/installment_purchase.dart';
import '../../../models/payment.dart';
import 'month_item.dart';

const int _kRecentMonthsWindow = 3;

class _RecentAverage {
  const _RecentAverage(this.average, this.sampleSize);
  final double? average;
  final int sampleSize;
}

class _ActiveInstallment {
  const _ActiveInstallment(this.cuotaIndex, this.amount);
  final int cuotaIndex;
  final double amount;
}

_ActiveInstallment? _installmentForPeriod(
  InstallmentPurchase purchase,
  PeriodKey target,
) {
  final start = PeriodKey.fromIso(purchase.firstPeriod);
  final diff = start.differenceInMonths(target);
  if (diff < 0) return null;
  final cuotaIndex = diff + 1;
  if (cuotaIndex > purchase.installmentCount) return null;
  return _ActiveInstallment(cuotaIndex, purchase.installmentAmount);
}

/// Reproduce 1:1 `lib/installments.ts → installmentForPeriod` para uso fuera
/// del builder (ej: detalle de tarjeta).
({int cuotaIndex, double amount})? installmentForPeriod(
  InstallmentPurchase purchase,
  PeriodKey target,
) {
  final r = _installmentForPeriod(purchase, target);
  return r == null ? null : (cuotaIndex: r.cuotaIndex, amount: r.amount);
}

/// Construye los ítems del mes. Reproduce `lib/month.ts → buildMonthChecklist`.
List<MonthItem> buildMonthChecklist({
  required PeriodKey period,
  required List<Bill> bills,
  required List<CreditCard> cards,
  required List<InstallmentPurchase> purchases,
  required List<Payment> payments,
  List<Payment> recentPayments = const [],
}) {
  final windowStartIso = period.subtractMonths(_kRecentMonthsWindow).toIso();
  final periodIso = period.toIso();

  _RecentAverage averageFor(bool Function(Payment) matcher) {
    var sum = 0.0;
    var count = 0;
    for (final p in recentPayments) {
      if (p.status == PaymentStatus.paid &&
          p.amountReal != null &&
          p.period.compareTo(windowStartIso) >= 0 &&
          p.period.compareTo(periodIso) < 0 &&
          matcher(p)) {
        sum += p.amountReal!;
        count++;
      }
    }
    return count == 0
        ? const _RecentAverage(null, 0)
        : _RecentAverage(sum / count, count);
  }

  final items = <MonthItem>[];

  // 1. Bills sin auto-debit → ítem propio del mes
  for (final bill in bills) {
    if (!bill.active) continue;
    if (bill.autoDebitCardId != null) continue;

    final payment = payments
        .where((p) => p.kind == PaymentKind.bill && p.billId == bill.id)
        .cast<Payment?>()
        .firstWhere((_) => true, orElse: () => null);

    final avg = averageFor(
      (p) => p.kind == PaymentKind.bill && p.billId == bill.id,
    );

    items.add(MonthItem(
      key: 'bill:${bill.id}',
      kind: MonthItemKind.bill,
      bill: bill,
      label: bill.name,
      estimatedAmount: bill.defaultAmount,
      dayOfMonth: bill.dayOfMonth,
      payment: payment,
      recentAverage: avg.average,
      recentSampleSize: avg.sampleSize,
    ));
  }

  // 2. Tarjetas: total = cuotas activas + bills auto-debit en esa tarjeta
  for (final card in cards) {
    if (!card.active) continue;

    final cardPurchases =
        purchases.where((p) => p.creditCardId == card.id).toList();
    var installmentsTotal = 0.0;
    var installmentsCount = 0;
    for (final p in cardPurchases) {
      final inMonth = _installmentForPeriod(p, period);
      if (inMonth != null) {
        installmentsTotal += inMonth.amount;
        installmentsCount++;
      }
    }

    final cardAutoDebits = bills
        .where((b) => b.active && b.autoDebitCardId == card.id)
        .toList();
    final autoDebitsTotal = cardAutoDebits.fold<double>(
      0,
      (sum, b) => sum + (b.defaultAmount ?? 0),
    );

    if (installmentsCount == 0 && cardAutoDebits.isEmpty) continue;

    final payment = payments
        .where((p) => p.kind == PaymentKind.cardTotal && p.cardId == card.id)
        .cast<Payment?>()
        .firstWhere((_) => true, orElse: () => null);

    final avg = averageFor(
      (p) => p.kind == PaymentKind.cardTotal && p.cardId == card.id,
    );

    items.add(MonthItem(
      key: 'card:${card.id}',
      kind: MonthItemKind.cardTotal,
      card: card,
      cardInstallmentsCount: installmentsCount,
      cardAutoDebitsCount: cardAutoDebits.length,
      label: card.name,
      estimatedAmount: installmentsTotal + autoDebitsTotal,
      dayOfMonth: card.dueDay,
      payment: payment,
      recentAverage: avg.average,
      recentSampleSize: avg.sampleSize,
    ));
  }

  // tarjetas primero; dentro de cada grupo, por día y luego por nombre
  items.sort((a, b) {
    if (a.kind != b.kind) {
      return a.kind == MonthItemKind.cardTotal ? -1 : 1;
    }
    final da = a.dayOfMonth ?? 99;
    final db = b.dayOfMonth ?? 99;
    if (da != db) return da - db;
    return a.label.compareTo(b.label);
  });

  return items;
}

/// Sugerencia de monto al marcar pagado: default_amount > promedio últimos
/// pagos > vacío.
double? suggestedAmount(MonthItem item) {
  if (item.estimatedAmount != null) return item.estimatedAmount;
  if (item.recentAverage != null) return item.recentAverage!.roundToDouble();
  return null;
}

// ---------------------------------------------------------------------------
// Macro categories (port de month.ts)
// ---------------------------------------------------------------------------

enum _MacroCategory {
  cards,
  housing,
  services,
  internet,
  health,
  tax,
  subscription,
  other,
}

const Map<BillKind, _MacroCategory> _kindToMacro = {
  BillKind.rent: _MacroCategory.housing,
  BillKind.consortium: _MacroCategory.housing,
  BillKind.electricity: _MacroCategory.services,
  BillKind.water: _MacroCategory.services,
  BillKind.gas: _MacroCategory.services,
  BillKind.internet: _MacroCategory.internet,
  BillKind.health: _MacroCategory.health,
  BillKind.tax: _MacroCategory.tax,
  BillKind.subscription: _MacroCategory.subscription,
  BillKind.other: _MacroCategory.other,
};

const List<_MacroCategory> _macroOrder = [
  _MacroCategory.cards,
  _MacroCategory.housing,
  _MacroCategory.services,
  _MacroCategory.internet,
  _MacroCategory.health,
  _MacroCategory.tax,
  _MacroCategory.subscription,
  _MacroCategory.other,
];

const Map<_MacroCategory, String> _macroLabels = {
  _MacroCategory.cards: 'Tarjetas',
  _MacroCategory.housing: 'Vivienda',
  _MacroCategory.services: 'Servicios',
  _MacroCategory.internet: 'Internet / Teléfono',
  _MacroCategory.health: 'Salud',
  _MacroCategory.tax: 'Impuestos',
  _MacroCategory.subscription: 'Suscripciones',
  _MacroCategory.other: 'Otros',
};

const Map<_MacroCategory, String> _macroEmojis = {
  _MacroCategory.cards: '💳',
  _MacroCategory.housing: '🏠',
  _MacroCategory.services: '⚡',
  _MacroCategory.internet: '📶',
  _MacroCategory.health: '🏥',
  _MacroCategory.tax: '🏛️',
  _MacroCategory.subscription: '📺',
  _MacroCategory.other: '📌',
};

List<MonthGroup> groupChecklistByCategory(List<MonthItem> items) {
  final buckets = <_MacroCategory, List<MonthItem>>{
    for (final macro in _macroOrder) macro: <MonthItem>[],
  };

  for (final item in items) {
    if (item.kind == MonthItemKind.cardTotal) {
      buckets[_MacroCategory.cards]!.add(item);
    } else if (item.bill != null) {
      buckets[_kindToMacro[item.bill!.kind]!]!.add(item);
    }
  }

  final groups = <MonthGroup>[];
  for (final macro in _macroOrder) {
    final bucket = buckets[macro]!;
    if (bucket.isEmpty) continue;
    groups.add(_buildGroup(
      key: macro.name,
      title: _macroLabels[macro]!,
      emoji: _macroEmojis[macro]!,
      items: bucket,
    ));
  }
  return groups;
}

MonthGroup _buildGroup({
  required String key,
  required String title,
  required String emoji,
  required List<MonthItem> items,
}) {
  var estimatedTotal = 0.0;
  var paidTotal = 0.0;
  var paidCount = 0;
  var pendingCount = 0;
  for (final item in items) {
    if (item.estimatedAmount != null) estimatedTotal += item.estimatedAmount!;
    if (item.payment?.status == PaymentStatus.paid) {
      paidTotal +=
          item.payment?.amountReal ?? item.estimatedAmount ?? 0;
      paidCount++;
    } else {
      pendingCount++;
    }
  }
  return MonthGroup(
    key: key,
    title: title,
    emoji: emoji,
    items: items,
    estimatedTotal: estimatedTotal,
    paidTotal: paidTotal,
    paidCount: paidCount,
    pendingCount: pendingCount,
  );
}

MonthSummary summarizeChecklist(List<MonthItem> items) {
  var estimatedTotal = 0.0;
  var paidTotal = 0.0;
  var pendingCount = 0;
  var paidCount = 0;
  for (final item in items) {
    if (item.estimatedAmount != null) estimatedTotal += item.estimatedAmount!;
    if (item.payment?.status == PaymentStatus.paid) {
      paidTotal +=
          item.payment?.amountReal ?? item.estimatedAmount ?? 0;
      paidCount++;
    } else {
      pendingCount++;
    }
  }
  return MonthSummary(
    estimatedTotal: estimatedTotal,
    paidTotal: paidTotal,
    pendingCount: pendingCount,
    paidCount: paidCount,
    totalCount: items.length,
  );
}
