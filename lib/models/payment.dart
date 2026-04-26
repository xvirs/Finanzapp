import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/json_converters.dart';
import 'enums.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String userId,
    required String period,
    required PaymentKind kind,
    String? billId,
    String? cardId,
    String? label,
    @NullableDoubleConverter() double? amountReal,
    @Default(PaymentStatus.pending) PaymentStatus status,
    DateTime? paidAt,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
