part of 'month_bloc.dart';

enum MonthStatus { initial, loading, success, failure }

final class MonthBlocState extends Equatable {
  MonthBlocState({
    this.status = MonthStatus.initial,
    PeriodKey? period,
    this.groups = const [],
    this.summary,
    this.onlyPending = false,
    this.errorMessage,
  }) : period = period ?? PeriodKey.current();

  final MonthStatus status;
  final PeriodKey period;
  final List<MonthGroup> groups;
  final MonthSummary? summary;
  final bool onlyPending;
  final String? errorMessage;

  bool get isCurrentPeriod => period == PeriodKey.current();

  bool get isFuturePeriod => period.compareTo(PeriodKey.current()) > 0;

  bool get isPastPeriod => period.compareTo(PeriodKey.current()) < 0;

  MonthBlocState copyWith({
    MonthStatus? status,
    PeriodKey? period,
    List<MonthGroup>? groups,
    MonthSummary? summary,
    bool? onlyPending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MonthBlocState(
      status: status ?? this.status,
      period: period ?? this.period,
      groups: groups ?? this.groups,
      summary: summary ?? this.summary,
      onlyPending: onlyPending ?? this.onlyPending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        period,
        groups,
        summary,
        onlyPending,
        errorMessage,
      ];
}
