import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../models/bill.dart';
import '../../../models/credit_card.dart';
import '../../../models/payment.dart';

part 'month_item.freezed.dart';

enum MonthItemKind { bill, cardTotal }

@freezed
class MonthItem with _$MonthItem {
  const factory MonthItem({
    required String key,
    required MonthItemKind kind,
    Bill? bill,
    CreditCard? card,
    int? cardInstallmentsCount,
    int? cardAutoDebitsCount,
    required String label,
    required double? estimatedAmount,
    required int? dayOfMonth,
    required Payment? payment,

    /// Promedio de los últimos pagos reales (excluyendo el mes actual).
    required double? recentAverage,

    /// Cantidad de pagos previos usados para promediar.
    required int recentSampleSize,
  }) = _MonthItem;
}

@freezed
class MonthGroup with _$MonthGroup {
  const factory MonthGroup({
    required String key,
    required String title,
    required String emoji,
    required List<MonthItem> items,
    required double estimatedTotal,
    required double paidTotal,
    required int paidCount,
    required int pendingCount,
  }) = _MonthGroup;
}

@freezed
class MonthSummary with _$MonthSummary {
  const factory MonthSummary({
    required double estimatedTotal,
    required double paidTotal,
    required int pendingCount,
    required int paidCount,
    required int totalCount,
    @Default(0.0) double incomeTotal,
  }) = _MonthSummary;
}
