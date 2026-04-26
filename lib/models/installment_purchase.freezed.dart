// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'installment_purchase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InstallmentPurchase _$InstallmentPurchaseFromJson(Map<String, dynamic> json) {
  return _InstallmentPurchase.fromJson(json);
}

/// @nodoc
mixin _$InstallmentPurchase {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get creditCardId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @DoubleConverter()
  double get totalAmount => throw _privateConstructorUsedError;
  int get installmentCount => throw _privateConstructorUsedError;
  @DoubleConverter()
  double get installmentAmount => throw _privateConstructorUsedError;
  String get firstPeriod => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this InstallmentPurchase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InstallmentPurchase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InstallmentPurchaseCopyWith<InstallmentPurchase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstallmentPurchaseCopyWith<$Res> {
  factory $InstallmentPurchaseCopyWith(
    InstallmentPurchase value,
    $Res Function(InstallmentPurchase) then,
  ) = _$InstallmentPurchaseCopyWithImpl<$Res, InstallmentPurchase>;
  @useResult
  $Res call({
    String id,
    String userId,
    String creditCardId,
    String description,
    @DoubleConverter() double totalAmount,
    int installmentCount,
    @DoubleConverter() double installmentAmount,
    String firstPeriod,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$InstallmentPurchaseCopyWithImpl<$Res, $Val extends InstallmentPurchase>
    implements $InstallmentPurchaseCopyWith<$Res> {
  _$InstallmentPurchaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InstallmentPurchase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? creditCardId = null,
    Object? description = null,
    Object? totalAmount = null,
    Object? installmentCount = null,
    Object? installmentAmount = null,
    Object? firstPeriod = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            creditCardId: null == creditCardId
                ? _value.creditCardId
                : creditCardId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            installmentCount: null == installmentCount
                ? _value.installmentCount
                : installmentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            installmentAmount: null == installmentAmount
                ? _value.installmentAmount
                : installmentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            firstPeriod: null == firstPeriod
                ? _value.firstPeriod
                : firstPeriod // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InstallmentPurchaseImplCopyWith<$Res>
    implements $InstallmentPurchaseCopyWith<$Res> {
  factory _$$InstallmentPurchaseImplCopyWith(
    _$InstallmentPurchaseImpl value,
    $Res Function(_$InstallmentPurchaseImpl) then,
  ) = __$$InstallmentPurchaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String creditCardId,
    String description,
    @DoubleConverter() double totalAmount,
    int installmentCount,
    @DoubleConverter() double installmentAmount,
    String firstPeriod,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$InstallmentPurchaseImplCopyWithImpl<$Res>
    extends _$InstallmentPurchaseCopyWithImpl<$Res, _$InstallmentPurchaseImpl>
    implements _$$InstallmentPurchaseImplCopyWith<$Res> {
  __$$InstallmentPurchaseImplCopyWithImpl(
    _$InstallmentPurchaseImpl _value,
    $Res Function(_$InstallmentPurchaseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InstallmentPurchase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? creditCardId = null,
    Object? description = null,
    Object? totalAmount = null,
    Object? installmentCount = null,
    Object? installmentAmount = null,
    Object? firstPeriod = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$InstallmentPurchaseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        creditCardId: null == creditCardId
            ? _value.creditCardId
            : creditCardId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        installmentCount: null == installmentCount
            ? _value.installmentCount
            : installmentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        installmentAmount: null == installmentAmount
            ? _value.installmentAmount
            : installmentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        firstPeriod: null == firstPeriod
            ? _value.firstPeriod
            : firstPeriod // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InstallmentPurchaseImpl implements _InstallmentPurchase {
  const _$InstallmentPurchaseImpl({
    required this.id,
    required this.userId,
    required this.creditCardId,
    required this.description,
    @DoubleConverter() required this.totalAmount,
    required this.installmentCount,
    @DoubleConverter() required this.installmentAmount,
    required this.firstPeriod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$InstallmentPurchaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstallmentPurchaseImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String creditCardId;
  @override
  final String description;
  @override
  @DoubleConverter()
  final double totalAmount;
  @override
  final int installmentCount;
  @override
  @DoubleConverter()
  final double installmentAmount;
  @override
  final String firstPeriod;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'InstallmentPurchase(id: $id, userId: $userId, creditCardId: $creditCardId, description: $description, totalAmount: $totalAmount, installmentCount: $installmentCount, installmentAmount: $installmentAmount, firstPeriod: $firstPeriod, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstallmentPurchaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.creditCardId, creditCardId) ||
                other.creditCardId == creditCardId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.installmentCount, installmentCount) ||
                other.installmentCount == installmentCount) &&
            (identical(other.installmentAmount, installmentAmount) ||
                other.installmentAmount == installmentAmount) &&
            (identical(other.firstPeriod, firstPeriod) ||
                other.firstPeriod == firstPeriod) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    creditCardId,
    description,
    totalAmount,
    installmentCount,
    installmentAmount,
    firstPeriod,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of InstallmentPurchase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InstallmentPurchaseImplCopyWith<_$InstallmentPurchaseImpl> get copyWith =>
      __$$InstallmentPurchaseImplCopyWithImpl<_$InstallmentPurchaseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InstallmentPurchaseImplToJson(this);
  }
}

abstract class _InstallmentPurchase implements InstallmentPurchase {
  const factory _InstallmentPurchase({
    required final String id,
    required final String userId,
    required final String creditCardId,
    required final String description,
    @DoubleConverter() required final double totalAmount,
    required final int installmentCount,
    @DoubleConverter() required final double installmentAmount,
    required final String firstPeriod,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$InstallmentPurchaseImpl;

  factory _InstallmentPurchase.fromJson(Map<String, dynamic> json) =
      _$InstallmentPurchaseImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get creditCardId;
  @override
  String get description;
  @override
  @DoubleConverter()
  double get totalAmount;
  @override
  int get installmentCount;
  @override
  @DoubleConverter()
  double get installmentAmount;
  @override
  String get firstPeriod;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of InstallmentPurchase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InstallmentPurchaseImplCopyWith<_$InstallmentPurchaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
