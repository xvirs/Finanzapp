// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment_purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InstallmentPurchaseImpl _$$InstallmentPurchaseImplFromJson(
  Map<String, dynamic> json,
) => _$InstallmentPurchaseImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  creditCardId: json['credit_card_id'] as String,
  description: json['description'] as String,
  totalAmount: const DoubleConverter().fromJson(json['total_amount']),
  installmentCount: (json['installment_count'] as num).toInt(),
  installmentAmount: const DoubleConverter().fromJson(
    json['installment_amount'],
  ),
  firstPeriod: json['first_period'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$InstallmentPurchaseImplToJson(
  _$InstallmentPurchaseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'credit_card_id': instance.creditCardId,
  'description': instance.description,
  if (const DoubleConverter().toJson(instance.totalAmount) case final value?)
    'total_amount': value,
  'installment_count': instance.installmentCount,
  if (const DoubleConverter().toJson(instance.installmentAmount)
      case final value?)
    'installment_amount': value,
  'first_period': instance.firstPeriod,
  if (instance.notes case final value?) 'notes': value,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
