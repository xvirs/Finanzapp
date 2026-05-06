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
    this.incomes = const [],
    this.filter = MonthFilter.all,
    this.errorMessage,
    this.mutatingItemKey,
    this.navigableMin,
    this.navigableMax,
  }) : period = period ?? PeriodKey.current();

  final MonthStatus status;
  final PeriodKey period;
  final List<MonthGroup> groups;
  final MonthSummary? summary;
  final List<Income> incomes;
  final MonthFilter filter;
  final String? errorMessage;
  final String? mutatingItemKey;

  /// Cota inferior y superior de la navegación entre meses. Se calculan
  /// según los datos del usuario; `null` significa "todavía no calculado".
  /// Las flechas se desactivan cuando `period` toca el extremo.
  final PeriodKey? navigableMin;
  final PeriodKey? navigableMax;

  bool get isCurrentPeriod => period == PeriodKey.current();

  bool get isFuturePeriod => period.compareTo(PeriodKey.current()) > 0;

  bool get isPastPeriod => period.compareTo(PeriodKey.current()) < 0;

  /// Saldo del mes (ingresos − gastos estimados). Null si no hay summary.
  double? get balance {
    final s = summary;
    if (s == null) return null;
    return s.incomeTotal - s.estimatedTotal;
  }

  bool get canGoPrevious {
    final min = navigableMin;
    if (min == null) return true;
    return period.compareTo(min) > 0;
  }

  bool get canGoNext {
    final max = navigableMax;
    if (max == null) return true;
    return period.compareTo(max) < 0;
  }

  MonthBlocState copyWith({
    MonthStatus? status,
    PeriodKey? period,
    List<MonthGroup>? groups,
    MonthSummary? summary,
    List<Income>? incomes,
    MonthFilter? filter,
    String? errorMessage,
    bool clearError = false,
    String? mutatingItemKey,
    bool clearMutating = false,
    PeriodKey? navigableMin,
    PeriodKey? navigableMax,
  }) {
    return MonthBlocState(
      status: status ?? this.status,
      period: period ?? this.period,
      groups: groups ?? this.groups,
      summary: summary ?? this.summary,
      incomes: incomes ?? this.incomes,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mutatingItemKey: clearMutating
          ? null
          : (mutatingItemKey ?? this.mutatingItemKey),
      navigableMin: navigableMin ?? this.navigableMin,
      navigableMax: navigableMax ?? this.navigableMax,
    );
  }

  @override
  List<Object?> get props => [
    status,
    period,
    groups,
    summary,
    incomes,
    filter,
    errorMessage,
    mutatingItemKey,
    navigableMin,
    navigableMax,
  ];
}
