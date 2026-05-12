part of 'cards_list_bloc.dart';

sealed class CardsListEvent extends Equatable {
  const CardsListEvent();

  @override
  List<Object?> get props => const [];
}

final class CardsListRequested extends CardsListEvent {
  const CardsListRequested();
}

final class CardsListRefreshRequested extends CardsListEvent {
  const CardsListRefreshRequested();
}

/// Refresh disparado por Realtime — sin tocar status (no flash).
final class CardsListSilentRefreshRequested extends CardsListEvent {
  const CardsListSilentRefreshRequested();
}
