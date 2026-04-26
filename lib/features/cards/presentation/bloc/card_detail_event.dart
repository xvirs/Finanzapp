part of 'card_detail_bloc.dart';

sealed class CardDetailEvent extends Equatable {
  const CardDetailEvent();

  @override
  List<Object?> get props => const [];
}

final class CardDetailRequested extends CardDetailEvent {
  const CardDetailRequested(this.cardId);

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}

final class CardDetailRefreshRequested extends CardDetailEvent {
  const CardDetailRefreshRequested();
}

/// Refresh disparado por Realtime — sin tocar status (no flash).
final class CardDetailSilentRefreshRequested extends CardDetailEvent {
  const CardDetailSilentRefreshRequested();
}
