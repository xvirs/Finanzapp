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

final class MonthOnlyPendingToggled extends MonthEvent {
  const MonthOnlyPendingToggled();
}
