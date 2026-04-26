// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      period: json['period'] as String,
      kind: $enumDecode(_$PaymentKindEnumMap, json['kind']),
      billId: json['bill_id'] as String?,
      cardId: json['card_id'] as String?,
      label: json['label'] as String?,
      amountReal: const NullableDoubleConverter().fromJson(json['amount_real']),
      status:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.pending,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(
  _$PaymentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'period': instance.period,
  'kind': _$PaymentKindEnumMap[instance.kind]!,
  if (instance.billId case final value?) 'bill_id': value,
  if (instance.cardId case final value?) 'card_id': value,
  if (instance.label case final value?) 'label': value,
  if (const NullableDoubleConverter().toJson(instance.amountReal)
      case final value?)
    'amount_real': value,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  if (instance.paidAt?.toIso8601String() case final value?) 'paid_at': value,
  if (instance.notes case final value?) 'notes': value,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$PaymentKindEnumMap = {
  PaymentKind.bill: 'bill',
  PaymentKind.cardTotal: 'card_total',
  PaymentKind.manual: 'manual',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.overdue: 'overdue',
  PaymentStatus.skipped: 'skipped',
};
