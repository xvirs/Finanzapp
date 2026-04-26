part of 'bills_list_bloc.dart';

sealed class BillsListEvent extends Equatable {
  const BillsListEvent();

  @override
  List<Object?> get props => const [];
}

final class BillsListRequested extends BillsListEvent {
  const BillsListRequested();
}

final class BillsListRefreshRequested extends BillsListEvent {
  const BillsListRefreshRequested();
}

/// Refresh disparado por Realtime — sin tocar status (no flash).
final class BillsListSilentRefreshRequested extends BillsListEvent {
  const BillsListSilentRefreshRequested();
}
