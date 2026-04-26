// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreditCard _$CreditCardFromJson(Map<String, dynamic> json) {
  return _CreditCard.fromJson(json);
}

/// @nodoc
mixin _$CreditCard {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get issuer => throw _privateConstructorUsedError;
  CardBrand? get brand => throw _privateConstructorUsedError;
  int? get closingDay => throw _privateConstructorUsedError;
  int? get dueDay => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CreditCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditCardCopyWith<CreditCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditCardCopyWith<$Res> {
  factory $CreditCardCopyWith(
    CreditCard value,
    $Res Function(CreditCard) then,
  ) = _$CreditCardCopyWithImpl<$Res, CreditCard>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String? issuer,
    CardBrand? brand,
    int? closingDay,
    int? dueDay,
    bool active,
    String? url,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CreditCardCopyWithImpl<$Res, $Val extends CreditCard>
    implements $CreditCardCopyWith<$Res> {
  _$CreditCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? issuer = freezed,
    Object? brand = freezed,
    Object? closingDay = freezed,
    Object? dueDay = freezed,
    Object? active = null,
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
            issuer: freezed == issuer
                ? _value.issuer
                : issuer // ignore: cast_nullable_to_non_nullable
                      as String?,
            brand: freezed == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as CardBrand?,
            closingDay: freezed == closingDay
                ? _value.closingDay
                : closingDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            dueDay: freezed == dueDay
                ? _value.dueDay
                : dueDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$CreditCardImplCopyWith<$Res>
    implements $CreditCardCopyWith<$Res> {
  factory _$$CreditCardImplCopyWith(
    _$CreditCardImpl value,
    $Res Function(_$CreditCardImpl) then,
  ) = __$$CreditCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String? issuer,
    CardBrand? brand,
    int? closingDay,
    int? dueDay,
    bool active,
    String? url,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CreditCardImplCopyWithImpl<$Res>
    extends _$CreditCardCopyWithImpl<$Res, _$CreditCardImpl>
    implements _$$CreditCardImplCopyWith<$Res> {
  __$$CreditCardImplCopyWithImpl(
    _$CreditCardImpl _value,
    $Res Function(_$CreditCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? issuer = freezed,
    Object? brand = freezed,
    Object? closingDay = freezed,
    Object? dueDay = freezed,
    Object? active = null,
    Object? url = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CreditCardImpl(
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
        issuer: freezed == issuer
            ? _value.issuer
            : issuer // ignore: cast_nullable_to_non_nullable
                  as String?,
        brand: freezed == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as CardBrand?,
        closingDay: freezed == closingDay
            ? _value.closingDay
            : closingDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        dueDay: freezed == dueDay
            ? _value.dueDay
            : dueDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$CreditCardImpl implements _CreditCard {
  const _$CreditCardImpl({
    required this.id,
    required this.userId,
    required this.name,
    this.issuer,
    this.brand,
    this.closingDay,
    this.dueDay,
    this.active = true,
    this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$CreditCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditCardImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? issuer;
  @override
  final CardBrand? brand;
  @override
  final int? closingDay;
  @override
  final int? dueDay;
  @override
  @JsonKey()
  final bool active;
  @override
  final String? url;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CreditCard(id: $id, userId: $userId, name: $name, issuer: $issuer, brand: $brand, closingDay: $closingDay, dueDay: $dueDay, active: $active, url: $url, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.closingDay, closingDay) ||
                other.closingDay == closingDay) &&
            (identical(other.dueDay, dueDay) || other.dueDay == dueDay) &&
            (identical(other.active, active) || other.active == active) &&
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
    issuer,
    brand,
    closingDay,
    dueDay,
    active,
    url,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CreditCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditCardImplCopyWith<_$CreditCardImpl> get copyWith =>
      __$$CreditCardImplCopyWithImpl<_$CreditCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditCardImplToJson(this);
  }
}

abstract class _CreditCard implements CreditCard {
  const factory _CreditCard({
    required final String id,
    required final String userId,
    required final String name,
    final String? issuer,
    final CardBrand? brand,
    final int? closingDay,
    final int? dueDay,
    final bool active,
    final String? url,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CreditCardImpl;

  factory _CreditCard.fromJson(Map<String, dynamic> json) =
      _$CreditCardImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get issuer;
  @override
  CardBrand? get brand;
  @override
  int? get closingDay;
  @override
  int? get dueDay;
  @override
  bool get active;
  @override
  String? get url;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CreditCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditCardImplCopyWith<_$CreditCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
