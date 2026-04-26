import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/json_converters.dart';

part 'installment_purchase.freezed.dart';
part 'installment_purchase.g.dart';

@freezed
class InstallmentPurchase with _$InstallmentPurchase {
  const factory InstallmentPurchase({
    required String id,
    required String userId,
    required String creditCardId,
    required String description,
    @DoubleConverter() required double totalAmount,
    required int installmentCount,
    @DoubleConverter() required double installmentAmount,
    required String firstPeriod,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _InstallmentPurchase;

  factory InstallmentPurchase.fromJson(Map<String, dynamic> json) =>
      _$InstallmentPurchaseFromJson(json);
}
