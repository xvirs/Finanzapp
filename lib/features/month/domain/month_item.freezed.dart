// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MonthItem {
  String get key => throw _privateConstructorUsedError;
  MonthItemKind get kind => throw _privateConstructorUsedError;
  Bill? get bill => throw _privateConstructorUsedError;
  CreditCard? get card => throw _privateConstructorUsedError;
  int? get cardInstallmentsCount => throw _privateConstructorUsedError;
  int? get cardAutoDebitsCount => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  double? get estimatedAmount => throw _privateConstructorUsedError;
  int? get dayOfMonth => throw _privateConstructorUsedError;
  Payment? get payment => throw _privateConstructorUsedError;

  /// Promedio de los últimos pagos reales (excluyendo el mes actual).
  double? get recentAverage => throw _privateConstructorUsedError;

  /// Cantidad de pagos previos usados para promediar.
  int get recentSampleSize => throw _privateConstructorUsedError;

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthItemCopyWith<MonthItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthItemCopyWith<$Res> {
  factory $MonthItemCopyWith(MonthItem value, $Res Function(MonthItem) then) =
      _$MonthItemCopyWithImpl<$Res, MonthItem>;
  @useResult
  $Res call({
    String key,
    MonthItemKind kind,
    Bill? bill,
    CreditCard? card,
    int? cardInstallmentsCount,
    int? cardAutoDebitsCount,
    String label,
    double? estimatedAmount,
    int? dayOfMonth,
    Payment? payment,
    double? recentAverage,
    int recentSampleSize,
  });

  $BillCopyWith<$Res>? get bill;
  $CreditCardCopyWith<$Res>? get card;
  $PaymentCopyWith<$Res>? get payment;
}

/// @nodoc
class _$MonthItemCopyWithImpl<$Res, $Val extends MonthItem>
    implements $MonthItemCopyWith<$Res> {
  _$MonthItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? kind = null,
    Object? bill = freezed,
    Object? card = freezed,
    Object? cardInstallmentsCount = freezed,
    Object? cardAutoDebitsCount = freezed,
    Object? label = null,
    Object? estimatedAmount = freezed,
    Object? dayOfMonth = freezed,
    Object? payment = freezed,
    Object? recentAverage = freezed,
    Object? recentSampleSize = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as MonthItemKind,
            bill: freezed == bill
                ? _value.bill
                : bill // ignore: cast_nullable_to_non_nullable
                      as Bill?,
            card: freezed == card
                ? _value.card
                : card // ignore: cast_nullable_to_non_nullable
                      as CreditCard?,
            cardInstallmentsCount: freezed == cardInstallmentsCount
                ? _value.cardInstallmentsCount
                : cardInstallmentsCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            cardAutoDebitsCount: freezed == cardAutoDebitsCount
                ? _value.cardAutoDebitsCount
                : cardAutoDebitsCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            estimatedAmount: freezed == estimatedAmount
                ? _value.estimatedAmount
                : estimatedAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            dayOfMonth: freezed == dayOfMonth
                ? _value.dayOfMonth
                : dayOfMonth // ignore: cast_nullable_to_non_nullable
                      as int?,
            payment: freezed == payment
                ? _value.payment
                : payment // ignore: cast_nullable_to_non_nullable
                      as Payment?,
            recentAverage: freezed == recentAverage
                ? _value.recentAverage
                : recentAverage // ignore: cast_nullable_to_non_nullable
                      as double?,
            recentSampleSize: null == recentSampleSize
                ? _value.recentSampleSize
                : recentSampleSize // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BillCopyWith<$Res>? get bill {
    if (_value.bill == null) {
      return null;
    }

    return $BillCopyWith<$Res>(_value.bill!, (value) {
      return _then(_value.copyWith(bill: value) as $Val);
    });
  }

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreditCardCopyWith<$Res>? get card {
    if (_value.card == null) {
      return null;
    }

    return $CreditCardCopyWith<$Res>(_value.card!, (value) {
      return _then(_value.copyWith(card: value) as $Val);
    });
  }

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentCopyWith<$Res>? get payment {
    if (_value.payment == null) {
      return null;
    }

    return $PaymentCopyWith<$Res>(_value.payment!, (value) {
      return _then(_value.copyWith(payment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MonthItemImplCopyWith<$Res>
    implements $MonthItemCopyWith<$Res> {
  factory _$$MonthItemImplCopyWith(
    _$MonthItemImpl value,
    $Res Function(_$MonthItemImpl) then,
  ) = __$$MonthItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String key,
    MonthItemKind kind,
    Bill? bill,
    CreditCard? card,
    int? cardInstallmentsCount,
    int? cardAutoDebitsCount,
    String label,
    double? estimatedAmount,
    int? dayOfMonth,
    Payment? payment,
    double? recentAverage,
    int recentSampleSize,
  });

  @override
  $BillCopyWith<$Res>? get bill;
  @override
  $CreditCardCopyWith<$Res>? get card;
  @override
  $PaymentCopyWith<$Res>? get payment;
}

/// @nodoc
class __$$MonthItemImplCopyWithImpl<$Res>
    extends _$MonthItemCopyWithImpl<$Res, _$MonthItemImpl>
    implements _$$MonthItemImplCopyWith<$Res> {
  __$$MonthItemImplCopyWithImpl(
    _$MonthItemImpl _value,
    $Res Function(_$MonthItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? kind = null,
    Object? bill = freezed,
    Object? card = freezed,
    Object? cardInstallmentsCount = freezed,
    Object? cardAutoDebitsCount = freezed,
    Object? label = null,
    Object? estimatedAmount = freezed,
    Object? dayOfMonth = freezed,
    Object? payment = freezed,
    Object? recentAverage = freezed,
    Object? recentSampleSize = null,
  }) {
    return _then(
      _$MonthItemImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as MonthItemKind,
        bill: freezed == bill
            ? _value.bill
            : bill // ignore: cast_nullable_to_non_nullable
                  as Bill?,
        card: freezed == card
            ? _value.card
            : card // ignore: cast_nullable_to_non_nullable
                  as CreditCard?,
        cardInstallmentsCount: freezed == cardInstallmentsCount
            ? _value.cardInstallmentsCount
            : cardInstallmentsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        cardAutoDebitsCount: freezed == cardAutoDebitsCount
            ? _value.cardAutoDebitsCount
            : cardAutoDebitsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        estimatedAmount: freezed == estimatedAmount
            ? _value.estimatedAmount
            : estimatedAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        dayOfMonth: freezed == dayOfMonth
            ? _value.dayOfMonth
            : dayOfMonth // ignore: cast_nullable_to_non_nullable
                  as int?,
        payment: freezed == payment
            ? _value.payment
            : payment // ignore: cast_nullable_to_non_nullable
                  as Payment?,
        recentAverage: freezed == recentAverage
            ? _value.recentAverage
            : recentAverage // ignore: cast_nullable_to_non_nullable
                  as double?,
        recentSampleSize: null == recentSampleSize
            ? _value.recentSampleSize
            : recentSampleSize // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$MonthItemImpl implements _MonthItem {
  const _$MonthItemImpl({
    required this.key,
    required this.kind,
    this.bill,
    this.card,
    this.cardInstallmentsCount,
    this.cardAutoDebitsCount,
    required this.label,
    required this.estimatedAmount,
    required this.dayOfMonth,
    required this.payment,
    required this.recentAverage,
    required this.recentSampleSize,
  });

  @override
  final String key;
  @override
  final MonthItemKind kind;
  @override
  final Bill? bill;
  @override
  final CreditCard? card;
  @override
  final int? cardInstallmentsCount;
  @override
  final int? cardAutoDebitsCount;
  @override
  final String label;
  @override
  final double? estimatedAmount;
  @override
  final int? dayOfMonth;
  @override
  final Payment? payment;

  /// Promedio de los últimos pagos reales (excluyendo el mes actual).
  @override
  final double? recentAverage;

  /// Cantidad de pagos previos usados para promediar.
  @override
  final int recentSampleSize;

  @override
  String toString() {
    return 'MonthItem(key: $key, kind: $kind, bill: $bill, card: $card, cardInstallmentsCount: $cardInstallmentsCount, cardAutoDebitsCount: $cardAutoDebitsCount, label: $label, estimatedAmount: $estimatedAmount, dayOfMonth: $dayOfMonth, payment: $payment, recentAverage: $recentAverage, recentSampleSize: $recentSampleSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthItemImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.bill, bill) || other.bill == bill) &&
            (identical(other.card, card) || other.card == card) &&
            (identical(other.cardInstallmentsCount, cardInstallmentsCount) ||
                other.cardInstallmentsCount == cardInstallmentsCount) &&
            (identical(other.cardAutoDebitsCount, cardAutoDebitsCount) ||
                other.cardAutoDebitsCount == cardAutoDebitsCount) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.estimatedAmount, estimatedAmount) ||
                other.estimatedAmount == estimatedAmount) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.payment, payment) || other.payment == payment) &&
            (identical(other.recentAverage, recentAverage) ||
                other.recentAverage == recentAverage) &&
            (identical(other.recentSampleSize, recentSampleSize) ||
                other.recentSampleSize == recentSampleSize));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    key,
    kind,
    bill,
    card,
    cardInstallmentsCount,
    cardAutoDebitsCount,
    label,
    estimatedAmount,
    dayOfMonth,
    payment,
    recentAverage,
    recentSampleSize,
  );

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthItemImplCopyWith<_$MonthItemImpl> get copyWith =>
      __$$MonthItemImplCopyWithImpl<_$MonthItemImpl>(this, _$identity);
}

abstract class _MonthItem implements MonthItem {
  const factory _MonthItem({
    required final String key,
    required final MonthItemKind kind,
    final Bill? bill,
    final CreditCard? card,
    final int? cardInstallmentsCount,
    final int? cardAutoDebitsCount,
    required final String label,
    required final double? estimatedAmount,
    required final int? dayOfMonth,
    required final Payment? payment,
    required final double? recentAverage,
    required final int recentSampleSize,
  }) = _$MonthItemImpl;

  @override
  String get key;
  @override
  MonthItemKind get kind;
  @override
  Bill? get bill;
  @override
  CreditCard? get card;
  @override
  int? get cardInstallmentsCount;
  @override
  int? get cardAutoDebitsCount;
  @override
  String get label;
  @override
  double? get estimatedAmount;
  @override
  int? get dayOfMonth;
  @override
  Payment? get payment;

  /// Promedio de los últimos pagos reales (excluyendo el mes actual).
  @override
  double? get recentAverage;

  /// Cantidad de pagos previos usados para promediar.
  @override
  int get recentSampleSize;

  /// Create a copy of MonthItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthItemImplCopyWith<_$MonthItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MonthGroup {
  String get key => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  List<MonthItem> get items => throw _privateConstructorUsedError;
  double get estimatedTotal => throw _privateConstructorUsedError;
  double get paidTotal => throw _privateConstructorUsedError;
  int get paidCount => throw _privateConstructorUsedError;
  int get pendingCount => throw _privateConstructorUsedError;

  /// Create a copy of MonthGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthGroupCopyWith<MonthGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthGroupCopyWith<$Res> {
  factory $MonthGroupCopyWith(
    MonthGroup value,
    $Res Function(MonthGroup) then,
  ) = _$MonthGroupCopyWithImpl<$Res, MonthGroup>;
  @useResult
  $Res call({
    String key,
    String title,
    String emoji,
    List<MonthItem> items,
    double estimatedTotal,
    double paidTotal,
    int paidCount,
    int pendingCount,
  });
}

/// @nodoc
class _$MonthGroupCopyWithImpl<$Res, $Val extends MonthGroup>
    implements $MonthGroupCopyWith<$Res> {
  _$MonthGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? title = null,
    Object? emoji = null,
    Object? items = null,
    Object? estimatedTotal = null,
    Object? paidTotal = null,
    Object? paidCount = null,
    Object? pendingCount = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<MonthItem>,
            estimatedTotal: null == estimatedTotal
                ? _value.estimatedTotal
                : estimatedTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            paidTotal: null == paidTotal
                ? _value.paidTotal
                : paidTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            paidCount: null == paidCount
                ? _value.paidCount
                : paidCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingCount: null == pendingCount
                ? _value.pendingCount
                : pendingCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthGroupImplCopyWith<$Res>
    implements $MonthGroupCopyWith<$Res> {
  factory _$$MonthGroupImplCopyWith(
    _$MonthGroupImpl value,
    $Res Function(_$MonthGroupImpl) then,
  ) = __$$MonthGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String key,
    String title,
    String emoji,
    List<MonthItem> items,
    double estimatedTotal,
    double paidTotal,
    int paidCount,
    int pendingCount,
  });
}

/// @nodoc
class __$$MonthGroupImplCopyWithImpl<$Res>
    extends _$MonthGroupCopyWithImpl<$Res, _$MonthGroupImpl>
    implements _$$MonthGroupImplCopyWith<$Res> {
  __$$MonthGroupImplCopyWithImpl(
    _$MonthGroupImpl _value,
    $Res Function(_$MonthGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? title = null,
    Object? emoji = null,
    Object? items = null,
    Object? estimatedTotal = null,
    Object? paidTotal = null,
    Object? paidCount = null,
    Object? pendingCount = null,
  }) {
    return _then(
      _$MonthGroupImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<MonthItem>,
        estimatedTotal: null == estimatedTotal
            ? _value.estimatedTotal
            : estimatedTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        paidTotal: null == paidTotal
            ? _value.paidTotal
            : paidTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        paidCount: null == paidCount
            ? _value.paidCount
            : paidCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingCount: null == pendingCount
            ? _value.pendingCount
            : pendingCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$MonthGroupImpl implements _MonthGroup {
  const _$MonthGroupImpl({
    required this.key,
    required this.title,
    required this.emoji,
    required final List<MonthItem> items,
    required this.estimatedTotal,
    required this.paidTotal,
    required this.paidCount,
    required this.pendingCount,
  }) : _items = items;

  @override
  final String key;
  @override
  final String title;
  @override
  final String emoji;
  final List<MonthItem> _items;
  @override
  List<MonthItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double estimatedTotal;
  @override
  final double paidTotal;
  @override
  final int paidCount;
  @override
  final int pendingCount;

  @override
  String toString() {
    return 'MonthGroup(key: $key, title: $title, emoji: $emoji, items: $items, estimatedTotal: $estimatedTotal, paidTotal: $paidTotal, paidCount: $paidCount, pendingCount: $pendingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthGroupImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.estimatedTotal, estimatedTotal) ||
                other.estimatedTotal == estimatedTotal) &&
            (identical(other.paidTotal, paidTotal) ||
                other.paidTotal == paidTotal) &&
            (identical(other.paidCount, paidCount) ||
                other.paidCount == paidCount) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    key,
    title,
    emoji,
    const DeepCollectionEquality().hash(_items),
    estimatedTotal,
    paidTotal,
    paidCount,
    pendingCount,
  );

  /// Create a copy of MonthGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthGroupImplCopyWith<_$MonthGroupImpl> get copyWith =>
      __$$MonthGroupImplCopyWithImpl<_$MonthGroupImpl>(this, _$identity);
}

abstract class _MonthGroup implements MonthGroup {
  const factory _MonthGroup({
    required final String key,
    required final String title,
    required final String emoji,
    required final List<MonthItem> items,
    required final double estimatedTotal,
    required final double paidTotal,
    required final int paidCount,
    required final int pendingCount,
  }) = _$MonthGroupImpl;

  @override
  String get key;
  @override
  String get title;
  @override
  String get emoji;
  @override
  List<MonthItem> get items;
  @override
  double get estimatedTotal;
  @override
  double get paidTotal;
  @override
  int get paidCount;
  @override
  int get pendingCount;

  /// Create a copy of MonthGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthGroupImplCopyWith<_$MonthGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MonthSummary {
  double get estimatedTotal => throw _privateConstructorUsedError;
  double get paidTotal => throw _privateConstructorUsedError;
  int get pendingCount => throw _privateConstructorUsedError;
  int get paidCount => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  double get incomeTotal => throw _privateConstructorUsedError;
  double get overdueTotal => throw _privateConstructorUsedError;
  int get overdueCount => throw _privateConstructorUsedError;

  /// Create a copy of MonthSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthSummaryCopyWith<MonthSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthSummaryCopyWith<$Res> {
  factory $MonthSummaryCopyWith(
    MonthSummary value,
    $Res Function(MonthSummary) then,
  ) = _$MonthSummaryCopyWithImpl<$Res, MonthSummary>;
  @useResult
  $Res call({
    double estimatedTotal,
    double paidTotal,
    int pendingCount,
    int paidCount,
    int totalCount,
    double incomeTotal,
    double overdueTotal,
    int overdueCount,
  });
}

/// @nodoc
class _$MonthSummaryCopyWithImpl<$Res, $Val extends MonthSummary>
    implements $MonthSummaryCopyWith<$Res> {
  _$MonthSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimatedTotal = null,
    Object? paidTotal = null,
    Object? pendingCount = null,
    Object? paidCount = null,
    Object? totalCount = null,
    Object? incomeTotal = null,
    Object? overdueTotal = null,
    Object? overdueCount = null,
  }) {
    return _then(
      _value.copyWith(
            estimatedTotal: null == estimatedTotal
                ? _value.estimatedTotal
                : estimatedTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            paidTotal: null == paidTotal
                ? _value.paidTotal
                : paidTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            pendingCount: null == pendingCount
                ? _value.pendingCount
                : pendingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            paidCount: null == paidCount
                ? _value.paidCount
                : paidCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            incomeTotal: null == incomeTotal
                ? _value.incomeTotal
                : incomeTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            overdueTotal: null == overdueTotal
                ? _value.overdueTotal
                : overdueTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            overdueCount: null == overdueCount
                ? _value.overdueCount
                : overdueCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthSummaryImplCopyWith<$Res>
    implements $MonthSummaryCopyWith<$Res> {
  factory _$$MonthSummaryImplCopyWith(
    _$MonthSummaryImpl value,
    $Res Function(_$MonthSummaryImpl) then,
  ) = __$$MonthSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double estimatedTotal,
    double paidTotal,
    int pendingCount,
    int paidCount,
    int totalCount,
    double incomeTotal,
    double overdueTotal,
    int overdueCount,
  });
}

/// @nodoc
class __$$MonthSummaryImplCopyWithImpl<$Res>
    extends _$MonthSummaryCopyWithImpl<$Res, _$MonthSummaryImpl>
    implements _$$MonthSummaryImplCopyWith<$Res> {
  __$$MonthSummaryImplCopyWithImpl(
    _$MonthSummaryImpl _value,
    $Res Function(_$MonthSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimatedTotal = null,
    Object? paidTotal = null,
    Object? pendingCount = null,
    Object? paidCount = null,
    Object? totalCount = null,
    Object? incomeTotal = null,
    Object? overdueTotal = null,
    Object? overdueCount = null,
  }) {
    return _then(
      _$MonthSummaryImpl(
        estimatedTotal: null == estimatedTotal
            ? _value.estimatedTotal
            : estimatedTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        paidTotal: null == paidTotal
            ? _value.paidTotal
            : paidTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        pendingCount: null == pendingCount
            ? _value.pendingCount
            : pendingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        paidCount: null == paidCount
            ? _value.paidCount
            : paidCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        incomeTotal: null == incomeTotal
            ? _value.incomeTotal
            : incomeTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        overdueTotal: null == overdueTotal
            ? _value.overdueTotal
            : overdueTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        overdueCount: null == overdueCount
            ? _value.overdueCount
            : overdueCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$MonthSummaryImpl implements _MonthSummary {
  const _$MonthSummaryImpl({
    required this.estimatedTotal,
    required this.paidTotal,
    required this.pendingCount,
    required this.paidCount,
    required this.totalCount,
    this.incomeTotal = 0.0,
    this.overdueTotal = 0.0,
    this.overdueCount = 0,
  });

  @override
  final double estimatedTotal;
  @override
  final double paidTotal;
  @override
  final int pendingCount;
  @override
  final int paidCount;
  @override
  final int totalCount;
  @override
  @JsonKey()
  final double incomeTotal;
  @override
  @JsonKey()
  final double overdueTotal;
  @override
  @JsonKey()
  final int overdueCount;

  @override
  String toString() {
    return 'MonthSummary(estimatedTotal: $estimatedTotal, paidTotal: $paidTotal, pendingCount: $pendingCount, paidCount: $paidCount, totalCount: $totalCount, incomeTotal: $incomeTotal, overdueTotal: $overdueTotal, overdueCount: $overdueCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthSummaryImpl &&
            (identical(other.estimatedTotal, estimatedTotal) ||
                other.estimatedTotal == estimatedTotal) &&
            (identical(other.paidTotal, paidTotal) ||
                other.paidTotal == paidTotal) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.paidCount, paidCount) ||
                other.paidCount == paidCount) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.incomeTotal, incomeTotal) ||
                other.incomeTotal == incomeTotal) &&
            (identical(other.overdueTotal, overdueTotal) ||
                other.overdueTotal == overdueTotal) &&
            (identical(other.overdueCount, overdueCount) ||
                other.overdueCount == overdueCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    estimatedTotal,
    paidTotal,
    pendingCount,
    paidCount,
    totalCount,
    incomeTotal,
    overdueTotal,
    overdueCount,
  );

  /// Create a copy of MonthSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthSummaryImplCopyWith<_$MonthSummaryImpl> get copyWith =>
      __$$MonthSummaryImplCopyWithImpl<_$MonthSummaryImpl>(this, _$identity);
}

abstract class _MonthSummary implements MonthSummary {
  const factory _MonthSummary({
    required final double estimatedTotal,
    required final double paidTotal,
    required final int pendingCount,
    required final int paidCount,
    required final int totalCount,
    final double incomeTotal,
    final double overdueTotal,
    final int overdueCount,
  }) = _$MonthSummaryImpl;

  @override
  double get estimatedTotal;
  @override
  double get paidTotal;
  @override
  int get pendingCount;
  @override
  int get paidCount;
  @override
  int get totalCount;
  @override
  double get incomeTotal;
  @override
  double get overdueTotal;
  @override
  int get overdueCount;

  /// Create a copy of MonthSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthSummaryImplCopyWith<_$MonthSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
