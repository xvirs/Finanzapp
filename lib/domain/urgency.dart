import 'package:freezed_annotation/freezed_annotation.dart';

import 'period.dart';

part 'urgency.freezed.dart';

@freezed
sealed class Urgency with _$Urgency {
  const factory Urgency.normal() = UrgencyNormal;
  const factory Urgency.dueSoon({required int daysUntil}) = UrgencyDueSoon;
  const factory Urgency.overdue() = UrgencyOverdue;
}

/// Solo aplica al mes actual (no a meses pasados/futuros). Si está pagado o
/// no hay día de vencimiento, devuelve `normal`.
Urgency getUrgency({
  required int? dayOfMonth,
  required bool paid,
  required PeriodKey period,
  DateTime? now,
}) {
  if (paid || dayOfMonth == null) return const Urgency.normal();

  final reference = now ?? DateTime.now();
  final isCurrent =
      period.year == reference.year && period.month == reference.month - 1;
  if (!isCurrent) return const Urgency.normal();

  final today = reference.day;
  final daysUntil = dayOfMonth - today;
  if (daysUntil < 0) return const Urgency.overdue();
  if (daysUntil <= 3) return Urgency.dueSoon(daysUntil: daysUntil);
  return const Urgency.normal();
}
