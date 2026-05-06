part of 'incomes_list_bloc.dart';

sealed class IncomesListEvent extends Equatable {
  const IncomesListEvent();

  @override
  List<Object?> get props => const [];
}

final class IncomesListRequested extends IncomesListEvent {
  const IncomesListRequested();
}

final class IncomesListRefreshRequested extends IncomesListEvent {
  const IncomesListRefreshRequested();
}

/// Refresh disparado por Realtime — sin tocar status (no flash).
final class IncomesListSilentRefreshRequested extends IncomesListEvent {
  const IncomesListSilentRefreshRequested();
}
