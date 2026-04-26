// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Bill _$BillFromJson(Map<String, dynamic> json) {
  return _Bill.fromJson(json);
}

/// @nodoc
mixin _$Bill {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @NullableDoubleConverter()
  double? get defaultAmount => throw _privateConstructorUsedError;
  int? get dayOfMonth => throw _privateConstructorUsedError;
  BillKind get kind => throw _privateConstructorUsedError;
  String? get providerCode => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get autoDebitCardId => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Bill to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillCopyWith<Bill> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillCopyWith<$Res> {
  factory $BillCopyWith(Bill value, $Res Function(Bill) then) =
      _$BillCopyWithImpl<$Res, Bill>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    @NullableDoubleConverter() double? defaultAmount,
    int? dayOfMonth,
    BillKind kind,
    String? providerCode,
    bool active,
    String? notes,
    String? autoDebitCardId,
    String? url,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$BillCopyWithImpl<$Res, $Val extends Bill>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? defaultAmount = freezed,
    Object? dayOfMonth = freezed,
    Object? kind = null,
    Object? providerCode = freezed,
    Object? active = null,
    Object? notes = freezed,
    Object? autoDebitCardId = freezed,
    Object? url = freezed,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultAmount: freezed == defaultAmount
                ? _value.defaultAmount
                : defaultAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            dayOfMonth: freezed == dayOfMonth
                ? _value.dayOfMonth
                : dayOfMonth // ignore: cast_nullable_to_non_nullable
                      as int?,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as BillKind,
            providerCode: freezed == providerCode
                ? _value.providerCode
                : providerCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            autoDebitCardId: freezed == autoDebitCardId
                ? _value.autoDebitCardId
                : autoDebitCardId // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BillImplCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$$BillImplCopyWith(
    _$BillImpl value,
    $Res Function(_$BillImpl) then,
  ) = __$$BillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    @NullableDoubleConverter() double? defaultAmount,
    int? dayOfMonth,
    BillKind kind,
    String? providerCode,
    bool active,
    String? notes,
    String? autoDebitCardId,
    String? url,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$BillImplCopyWithImpl<$Res>
    extends _$BillCopyWithImpl<$Res, _$BillImpl>
    implements _$$BillImplCopyWith<$Res> {
  __$$BillImplCopyWithImpl(_$BillImpl _value, $Res Function(_$BillImpl) _then)
    : super(_value, _then);

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? defaultAmount = freezed,
    Object? dayOfMonth = freezed,
    Object? kind = null,
    Object? providerCode = freezed,
    Object? active = null,
    Object? notes = freezed,
    Object? autoDebitCardId = freezed,
    Object? url = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$BillImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultAmount: freezed == defaultAmount
            ? _value.defaultAmount
            : defaultAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        dayOfMonth: freezed == dayOfMonth
            ? _value.dayOfMonth
            : dayOfMonth // ignore: cast_nullable_to_non_nullable
                  as int?,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as BillKind,
        providerCode: freezed == providerCode
            ? _value.providerCode
            : providerCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        autoDebitCardId: freezed == autoDebitCardId
            ? _value.autoDebitCardId
            : autoDebitCardId // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
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
class _$BillImpl implements _Bill {
  const _$BillImpl({
    required this.id,
    required this.userId,
    required this.name,
    @NullableDoubleConverter() this.defaultAmount,
    this.dayOfMonth,
    required this.kind,
    this.providerCode,
    this.active = true,
    this.notes,
    this.autoDebitCardId,
    this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$BillImpl.fromJson(Map<String, dynamic> json) =>
      _$$BillImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  @NullableDoubleConverter()
  final double? defaultAmount;
  @override
  final int? dayOfMonth;
  @override
  final BillKind kind;
  @override
  final String? providerCode;
  @override
  @JsonKey()
  final bool active;
  @override
  final String? notes;
  @override
  final String? autoDebitCardId;
  @override
  final String? url;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Bill(id: $id, userId: $userId, name: $name, defaultAmount: $defaultAmount, dayOfMonth: $dayOfMonth, kind: $kind, providerCode: $providerCode, active: $active, notes: $notes, autoDebitCardId: $autoDebitCardId, url: $url, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.defaultAmount, defaultAmount) ||
                other.defaultAmount == defaultAmount) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.providerCode, providerCode) ||
                other.providerCode == providerCode) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.autoDebitCardId, autoDebitCardId) ||
                other.autoDebitCardId == autoDebitCardId) &&
            (identical(other.url, url) || other.url == url) &&
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
    name,
    defaultAmount,
    dayOfMonth,
    kind,
    providerCode,
    active,
    notes,
    autoDebitCardId,
    url,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      __$$BillImplCopyWithImpl<_$BillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BillImplToJson(this);
  }
}

abstract class _Bill implements Bill {
  const factory _Bill({
    required final String id,
    required final String userId,
    required final String name,
    @NullableDoubleConverter() final double? defaultAmount,
    final int? dayOfMonth,
    required final BillKind kind,
    final String? providerCode,
    final bool active,
    final String? notes,
    final String? autoDebitCardId,
    final String? url,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$BillImpl;

  factory _Bill.fromJson(Map<String, dynamic> json) = _$BillImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  @NullableDoubleConverter()
  double? get defaultAmount;
  @override
  int? get dayOfMonth;
  @override
  BillKind get kind;
  @override
  String? get providerCode;
  @override
  bool get active;
  @override
  String? get notes;
  @override
  String? get autoDebitCardId;
  @override
  String? get url;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
