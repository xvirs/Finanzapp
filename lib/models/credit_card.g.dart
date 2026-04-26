// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreditCardImpl _$$CreditCardImplFromJson(Map<String, dynamic> json) =>
    _$CreditCardImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      issuer: json['issuer'] as String?,
      brand: $enumDecodeNullable(_$CardBrandEnumMap, json['brand']),
      closingDay: (json['closing_day'] as num?)?.toInt(),
      dueDay: (json['due_day'] as num?)?.toInt(),
      active: json['active'] as bool? ?? true,
      url: json['url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CreditCardImplToJson(_$CreditCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      if (instance.issuer case final value?) 'issuer': value,
      if (_$CardBrandEnumMap[instance.brand] case final value?) 'brand': value,
      if (instance.closingDay case final value?) 'closing_day': value,
      if (instance.dueDay case final value?) 'due_day': value,
      'active': instance.active,
      if (instance.url case final value?) 'url': value,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$CardBrandEnumMap = {
  CardBrand.visa: 'visa',
  CardBrand.mastercard: 'mastercard',
  CardBrand.amex: 'amex',
  CardBrand.other: 'other',
};
