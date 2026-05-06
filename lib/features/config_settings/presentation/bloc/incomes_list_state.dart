part of 'incomes_list_bloc.dart';

enum IncomesListStatus { initial, loading, success, failure }

final class IncomesListBlocState extends Equatable {
  const IncomesListBlocState({
    this.status = IncomesListStatus.initial,
    this.incomes = const [],
    this.errorMessage,
  });

  final IncomesListStatus status;
  final List<Income> incomes;
  final String? errorMessage;

  IncomesListBlocState copyWith({
    IncomesListStatus? status,
    List<Income>? incomes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IncomesListBlocState(
      status: status ?? this.status,
      incomes: incomes ?? this.incomes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, incomes, errorMessage];
}
