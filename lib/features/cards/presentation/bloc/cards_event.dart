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

/// Marca el total del mes de la tarjeta [cardId] como pagado por [amount].
/// Equivale al flujo `MonthMarkPaidRequested` pero disparado desde el
/// item de la lista de Tarjetas.
final class CardsMarkPaidRequested extends CardsEvent {
  const CardsMarkPaidRequested({required this.cardId, required this.amount});

  final String cardId;
  final double amount;

  @override
  List<Object?> get props => [cardId, amount];
}

/// Vuelve la tarjeta a pendiente — borra el pago del mes.
final class CardsMarkPendingRequested extends CardsEvent {
  const CardsMarkPendingRequested({required this.cardId});

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}
