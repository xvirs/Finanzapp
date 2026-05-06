import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/json_converters.dart';
import 'enums.dart';

part 'income.freezed.dart';
part 'income.g.dart';

@freezed
class Income with _$Income {
  const factory Income({
    required String id,
    required String userId,
    required String name,
    @NullableDoubleConverter() double? defaultAmount,
    int? dayOfMonth,
    required IncomeKind kind,
    required String startPeriod,
    String? endPeriod,
    @Default(true) bool active,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Income;

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);
}
