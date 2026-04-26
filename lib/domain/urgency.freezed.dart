// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'urgency.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Urgency {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() normal,
    required TResult Function(int daysUntil) dueSoon,
    required TResult Function() overdue,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? normal,
    TResult? Function(int daysUntil)? dueSoon,
    TResult? Function()? overdue,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? normal,
    TResult Function(int daysUntil)? dueSoon,
    TResult Function()? overdue,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UrgencyNormal value) normal,
    required TResult Function(UrgencyDueSoon value) dueSoon,
    required TResult Function(UrgencyOverdue value) overdue,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UrgencyNormal value)? normal,
    TResult? Function(UrgencyDueSoon value)? dueSoon,
    TResult? Function(UrgencyOverdue value)? overdue,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UrgencyNormal value)? normal,
    TResult Function(UrgencyDueSoon value)? dueSoon,
    TResult Function(UrgencyOverdue value)? overdue,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UrgencyCopyWith<$Res> {
  factory $UrgencyCopyWith(Urgency value, $Res Function(Urgency) then) =
      _$UrgencyCopyWithImpl<$Res, Urgency>;
}

/// @nodoc
class _$UrgencyCopyWithImpl<$Res, $Val extends Urgency>
    implements $UrgencyCopyWith<$Res> {
  _$UrgencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Urgency
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$UrgencyNormalImplCopyWith<$Res> {
  factory _$$UrgencyNormalImplCopyWith(
    _$UrgencyNormalImpl value,
    $Res Function(_$UrgencyNormalImpl) then,
  ) = __$$UrgencyNormalImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UrgencyNormalImplCopyWithImpl<$Res>
    extends _$UrgencyCopyWithImpl<$Res, _$UrgencyNormalImpl>
    implements _$$UrgencyNormalImplCopyWith<$Res> {
  __$$UrgencyNormalImplCopyWithImpl(
    _$UrgencyNormalImpl _value,
    $Res Function(_$UrgencyNormalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Urgency
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UrgencyNormalImpl implements UrgencyNormal {
  const _$UrgencyNormalImpl();

  @override
  String toString() {
    return 'Urgency.normal()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UrgencyNormalImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() normal,
    required TResult Function(int daysUntil) dueSoon,
    required TResult Function() overdue,
  }) {
    return normal();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? normal,
    TResult? Function(int daysUntil)? dueSoon,
    TResult? Function()? overdue,
  }) {
    return normal?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? normal,
    TResult Function(int daysUntil)? dueSoon,
    TResult Function()? overdue,
    required TResult orElse(),
  }) {
    if (normal != null) {
      return normal();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UrgencyNormal value) normal,
    required TResult Function(UrgencyDueSoon value) dueSoon,
    required TResult Function(UrgencyOverdue value) overdue,
  }) {
    return normal(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UrgencyNormal value)? normal,
    TResult? Function(UrgencyDueSoon value)? dueSoon,
    TResult? Function(UrgencyOverdue value)? overdue,
  }) {
    return normal?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UrgencyNormal value)? normal,
    TResult Function(UrgencyDueSoon value)? dueSoon,
    TResult Function(UrgencyOverdue value)? overdue,
    required TResult orElse(),
  }) {
    if (normal != null) {
      return normal(this);
    }
    return orElse();
  }
}

abstract class UrgencyNormal implements Urgency {
  const factory UrgencyNormal() = _$UrgencyNormalImpl;
}

/// @nodoc
abstract class _$$UrgencyDueSoonImplCopyWith<$Res> {
  factory _$$UrgencyDueSoonImplCopyWith(
    _$UrgencyDueSoonImpl value,
    $Res Function(_$UrgencyDueSoonImpl) then,
  ) = __$$UrgencyDueSoonImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int daysUntil});
}

/// @nodoc
class __$$UrgencyDueSoonImplCopyWithImpl<$Res>
    extends _$UrgencyCopyWithImpl<$Res, _$UrgencyDueSoonImpl>
    implements _$$UrgencyDueSoonImplCopyWith<$Res> {
  __$$UrgencyDueSoonImplCopyWithImpl(
    _$UrgencyDueSoonImpl _value,
    $Res Function(_$UrgencyDueSoonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Urgency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? daysUntil = null}) {
    return _then(
      _$UrgencyDueSoonImpl(
        daysUntil: null == daysUntil
            ? _value.daysUntil
            : daysUntil // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$UrgencyDueSoonImpl implements UrgencyDueSoon {
  const _$UrgencyDueSoonImpl({required this.daysUntil});

  @override
  final int daysUntil;

  @override
  String toString() {
    return 'Urgency.dueSoon(daysUntil: $daysUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UrgencyDueSoonImpl &&
            (identical(other.daysUntil, daysUntil) ||
                other.daysUntil == daysUntil));
  }

  @override
  int get hashCode => Object.hash(runtimeType, daysUntil);

  /// Create a copy of Urgency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UrgencyDueSoonImplCopyWith<_$UrgencyDueSoonImpl> get copyWith =>
      __$$UrgencyDueSoonImplCopyWithImpl<_$UrgencyDueSoonImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() normal,
    required TResult Function(int daysUntil) dueSoon,
    required TResult Function() overdue,
  }) {
    return dueSoon(daysUntil);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? normal,
    TResult? Function(int daysUntil)? dueSoon,
    TResult? Function()? overdue,
  }) {
    return dueSoon?.call(daysUntil);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? normal,
    TResult Function(int daysUntil)? dueSoon,
    TResult Function()? overdue,
    required TResult orElse(),
  }) {
    if (dueSoon != null) {
      return dueSoon(daysUntil);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UrgencyNormal value) normal,
    required TResult Function(UrgencyDueSoon value) dueSoon,
    required TResult Function(UrgencyOverdue value) overdue,
  }) {
    return dueSoon(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UrgencyNormal value)? normal,
    TResult? Function(UrgencyDueSoon value)? dueSoon,
    TResult? Function(UrgencyOverdue value)? overdue,
  }) {
    return dueSoon?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UrgencyNormal value)? normal,
    TResult Function(UrgencyDueSoon value)? dueSoon,
    TResult Function(UrgencyOverdue value)? overdue,
    required TResult orElse(),
  }) {
    if (dueSoon != null) {
      return dueSoon(this);
    }
    return orElse();
  }
}

abstract class UrgencyDueSoon implements Urgency {
  const factory UrgencyDueSoon({required final int daysUntil}) =
      _$UrgencyDueSoonImpl;

  int get daysUntil;

  /// Create a copy of Urgency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UrgencyDueSoonImplCopyWith<_$UrgencyDueSoonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UrgencyOverdueImplCopyWith<$Res> {
  factory _$$UrgencyOverdueImplCopyWith(
    _$UrgencyOverdueImpl value,
    $Res Function(_$UrgencyOverdueImpl) then,
  ) = __$$UrgencyOverdueImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UrgencyOverdueImplCopyWithImpl<$Res>
    extends _$UrgencyCopyWithImpl<$Res, _$UrgencyOverdueImpl>
    implements _$$UrgencyOverdueImplCopyWith<$Res> {
  __$$UrgencyOverdueImplCopyWithImpl(
    _$UrgencyOverdueImpl _value,
    $Res Function(_$UrgencyOverdueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Urgency
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UrgencyOverdueImpl implements UrgencyOverdue {
  const _$UrgencyOverdueImpl();

  @override
  String toString() {
    return 'Urgency.overdue()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UrgencyOverdueImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() normal,
    required TResult Function(int daysUntil) dueSoon,
    required TResult Function() overdue,
  }) {
    return overdue();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? normal,
    TResult? Function(int daysUntil)? dueSoon,
    TResult? Function()? overdue,
  }) {
    return overdue?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? normal,
    TResult Function(int daysUntil)? dueSoon,
    TResult Function()? overdue,
    required TResult orElse(),
  }) {
    if (overdue != null) {
      return overdue();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UrgencyNormal value) normal,
    required TResult Function(UrgencyDueSoon value) dueSoon,
    required TResult Function(UrgencyOverdue value) overdue,
  }) {
    return overdue(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UrgencyNormal value)? normal,
    TResult? Function(UrgencyDueSoon value)? dueSoon,
    TResult? Function(UrgencyOverdue value)? overdue,
  }) {
    return overdue?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UrgencyNormal value)? normal,
    TResult Function(UrgencyDueSoon value)? dueSoon,
    TResult Function(UrgencyOverdue value)? overdue,
    required TResult orElse(),
  }) {
    if (overdue != null) {
      return overdue(this);
    }
    return orElse();
  }
}

abstract class UrgencyOverdue implements Urgency {
  const factory UrgencyOverdue() = _$UrgencyOverdueImpl;
}
