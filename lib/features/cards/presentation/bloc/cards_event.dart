part of 'cards_bloc.dart';

sealed class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object?> get props => const [];
}

final class CardsRequested extends CardsEvent {
  const CardsRequested();
}

final class CardsRefreshRequested extends CardsEvent {
  const CardsRefreshRequested();
}

/// Refresh disparado por Realtime — sin tocar status (no flash).
final class CardsSilentRefreshRequested extends CardsEvent {
  const CardsSilentRefreshRequested();
}
