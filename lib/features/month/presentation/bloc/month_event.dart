part of 'month_bloc.dart';

sealed class MonthEvent extends Equatable {
  const MonthEvent();

  @override
  List<Object?> get props => const [];
}

final class MonthRequested extends MonthEvent {
  const MonthRequested(this.period);

  final PeriodKey period;

  @override
  List<Object?> get props => [period];
}

final class MonthRefreshRequested extends MonthEvent {
  const MonthRefreshRequested();
}

/// Refresh disparado por un cambio recibido por Realtime (web u otro
/// dispositivo). NO toca el status — la lista no parpadea.
final class MonthSilentRefreshRequested extends MonthEvent {
  const MonthSilentRefreshRequested();
}

final class MonthFilterChanged extends MonthEvent {
  const MonthFilterChanged(this.filter);

  final MonthFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class MonthMarkPaidRequested extends MonthEvent {
  const MonthMarkPaidRequested({required this.item, required this.amount});

  final MonthItem item;
  final double amount;

  @override
  List<Object?> get props => [item.key, amount];
}

final class MonthMarkPendingRequested extends MonthEvent {
  const MonthMarkPendingRequested({required this.item});

  final MonthItem item;

  @override
  List<Object?> get props => [item.key];
}
