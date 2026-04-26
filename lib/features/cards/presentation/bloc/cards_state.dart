part of 'cards_bloc.dart';

enum CardsStatus { initial, loading, success, failure }

final class CardsBlocState extends Equatable {
  CardsBlocState({
    this.status = CardsStatus.initial,
    PeriodKey? period,
    this.items = const [],
    this.totalForPeriod = 0,
    this.errorMessage,
  }) : period = period ?? PeriodKey.current();

  final CardsStatus status;
  final PeriodKey period;
  final List<CardListItemData> items;
  final double totalForPeriod;
  final String? errorMessage;

  CardsBlocState copyWith({
    CardsStatus? status,
    PeriodKey? period,
    List<CardListItemData>? items,
    double? totalForPeriod,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CardsBlocState(
      status: status ?? this.status,
      period: period ?? this.period,
      items: items ?? this.items,
      totalForPeriod: totalForPeriod ?? this.totalForPeriod,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        period,
        items,
        totalForPeriod,
        errorMessage,
      ];
}
