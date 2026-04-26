part of 'bills_list_bloc.dart';

enum BillsListStatus { initial, loading, success, failure }

final class BillsListBlocState extends Equatable {
  const BillsListBlocState({
    this.status = BillsListStatus.initial,
    this.bills = const [],
    this.cardsById = const {},
    this.errorMessage,
  });

  final BillsListStatus status;
  final List<Bill> bills;
  final Map<String, CreditCard> cardsById;
  final String? errorMessage;

  BillsListBlocState copyWith({
    BillsListStatus? status,
    List<Bill>? bills,
    Map<String, CreditCard>? cardsById,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BillsListBlocState(
      status: status ?? this.status,
      bills: bills ?? this.bills,
      cardsById: cardsById ?? this.cardsById,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, bills, cardsById, errorMessage];
}
