import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/json_converters.dart';
import 'enums.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

@freezed
class Bill with _$Bill {
  const factory Bill({
    required String id,
    required String userId,
    required String name,
    @NullableDoubleConverter() double? defaultAmount,
    int? dayOfMonth,
    required BillKind kind,
    String? providerCode,
    @Default(true) bool active,
    String? notes,
    String? autoDebitCardId,
    String? url,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Bill;

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
}
