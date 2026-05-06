// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BillImpl _$$BillImplFromJson(Map<String, dynamic> json) => _$BillImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  defaultAmount: const NullableDoubleConverter().fromJson(
    json['default_amount'],
  ),
  dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
  kind: $enumDecode(_$BillKindEnumMap, json['kind']),
  providerCode: json['provider_code'] as String?,
  active: json['active'] as bool? ?? true,
  notes: json['notes'] as String?,
  autoDebitCardId: json['auto_debit_card_id'] as String?,
  url: json['url'] as String?,
  startPeriod: json['start_period'] as String,
  endPeriod: json['end_period'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$BillImplToJson(
  _$BillImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  if (const NullableDoubleConverter().toJson(instance.defaultAmount)
      case final value?)
    'default_amount': value,
  if (instance.dayOfMonth case final value?) 'day_of_month': value,
  'kind': _$BillKindEnumMap[instance.kind]!,
  if (instance.providerCode case final value?) 'provider_code': value,
  'active': instance.active,
  if (instance.notes case final value?) 'notes': value,
  if (instance.autoDebitCardId case final value?) 'auto_debit_card_id': value,
  if (instance.url case final value?) 'url': value,
  'start_period': instance.startPeriod,
  if (instance.endPeriod case final value?) 'end_period': value,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$BillKindEnumMap = {
  BillKind.rent: 'rent',
  BillKind.electricity: 'electricity',
  BillKind.water: 'water',
  BillKind.gas: 'gas',
  BillKind.internet: 'internet',
  BillKind.health: 'health',
  BillKind.tax: 'tax',
  BillKind.consortium: 'consortium',
  BillKind.subscription: 'subscription',
  BillKind.other: 'other',
};
