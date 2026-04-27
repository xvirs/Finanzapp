part of 'month_bloc.dart';

enum MonthStatus { initial, loading, success, failure }

/// Filtro de la lista del Mes. 3 estados (todos / pendientes / atrasadas)
/// reemplaza al toggle binario "solo pendientes" de la versión anterior
/// para alinearse con el diseño handoff (filter tabs en el header).
enum MonthFilter { all, pending, overdue }

final class MonthBlocState extends Equatable {
  MonthBlocState({
    this.status = MonthStatus.initial,
    PeriodKey? period,
    this.groups = const [],
    this.summary,
    this.filter = MonthFilter.all,
    this.errorMessage,
    this.mutatingItemKey,
  }) : period = period ?? PeriodKey.current();

  final MonthStatus status;
  final PeriodKey period;
  final List<MonthGroup> groups;
  final MonthSummary? summary;
  final MonthFilter filter;
  final String? errorMessage;
  final String? mutatingItemKey;

  bool get isCurrentPeriod => period == PeriodKey.current();

  bool get isFuturePeriod => period.compareTo(PeriodKey.current()) > 0;

  bool get isPastPeriod => period.compareTo(PeriodKey.current()) < 0;

  MonthBlocState copyWith({
    MonthStatus? status,
    PeriodKey? period,
    List<MonthGroup>? groups,
    MonthSummary? summary,
    MonthFilter? filter,
    String? errorMessage,
    bool clearError = false,
    String? mutatingItemKey,
    bool clearMutating = false,
  }) {
    return MonthBlocState(
      status: status ?? this.status,
      period: period ?? this.period,
      groups: groups ?? this.groups,
      summary: summary ?? this.summary,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mutatingItemKey: clearMutating
          ? null
          : (mutatingItemKey ?? this.mutatingItemKey),
    );
  }

  @override
  List<Object?> get props => [
        status,
        period,
        groups,
        summary,
        filter,
        errorMessage,
        mutatingItemKey,
      ];
}
