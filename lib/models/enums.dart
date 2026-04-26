import 'package:json_annotation/json_annotation.dart';

enum BillKind {
  @JsonValue('rent')
  rent,
  @JsonValue('electricity')
  electricity,
  @JsonValue('water')
  water,
  @JsonValue('gas')
  gas,
  @JsonValue('internet')
  internet,
  @JsonValue('health')
  health,
  @JsonValue('tax')
  tax,
  @JsonValue('consortium')
  consortium,
  @JsonValue('subscription')
  subscription,
  @JsonValue('other')
  other,
}

enum CardBrand {
  @JsonValue('visa')
  visa,
  @JsonValue('mastercard')
  mastercard,
  @JsonValue('amex')
  amex,
  @JsonValue('other')
  other,
}

enum PaymentKind {
  @JsonValue('bill')
  bill,
  @JsonValue('card_total')
  cardTotal,
  @JsonValue('manual')
  manual,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('skipped')
  skipped,
}
