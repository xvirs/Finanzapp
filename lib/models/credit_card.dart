import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'credit_card.freezed.dart';
part 'credit_card.g.dart';

@freezed
class CreditCard with _$CreditCard {
  const factory CreditCard({
    required String id,
    required String userId,
    required String name,
    String? issuer,
    CardBrand? brand,
    int? closingDay,
    int? dueDay,
    @Default(true) bool active,
    String? url,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CreditCard;

  factory CreditCard.fromJson(Map<String, dynamic> json) =>
      _$CreditCardFromJson(json);
}
