part of 'cards_list_bloc.dart';

enum CardsListStatus { initial, loading, success, failure }

final class CardsListBlocState extends Equatable {
  const CardsListBlocState({
    this.status = CardsListStatus.initial,
    this.cards = const [],
    this.errorMessage,
  });

  final CardsListStatus status;
  final List<CreditCard> cards;
  final String? errorMessage;

  CardsListBlocState copyWith({
    CardsListStatus? status,
    List<CreditCard>? cards,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CardsListBlocState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, cards, errorMessage];
}
