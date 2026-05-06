// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IncomeImpl _$$IncomeImplFromJson(Map<String, dynamic> json) => _$IncomeImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  defaultAmount: const NullableDoubleConverter().fromJson(
    json['default_amount'],
  ),
  dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
  kind: $enumDecode(_$IncomeKindEnumMap, json['kind']),
  startPeriod: json['start_period'] as String,
  endPeriod: json['end_period'] as String?,
  active: json['active'] as bool? ?? true,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$IncomeImplToJson(_$IncomeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      if (const NullableDoubleConverter().toJson(instance.defaultAmount)
          case final value?)
        'default_amount': value,
      if (instance.dayOfMonth case final value?) 'day_of_month': value,
      'kind': _$IncomeKindEnumMap[instance.kind]!,
      'start_period': instance.startPeriod,
      if (instance.endPeriod case final value?) 'end_period': value,
      'active': instance.active,
      if (instance.notes case final value?) 'notes': value,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$IncomeKindEnumMap = {
  IncomeKind.salary: 'salary',
  IncomeKind.freelance: 'freelance',
  IncomeKind.rental: 'rental',
  IncomeKind.other: 'other',
};
