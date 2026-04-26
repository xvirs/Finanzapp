import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/bills_repository.dart';
import '../../../../data/cards_repository.dart';
import '../../../../models/bill.dart';
import '../../../../models/credit_card.dart';

part 'bills_list_event.dart';
part 'bills_list_state.dart';

class BillsListBloc extends Bloc<BillsListEvent, BillsListBlocState> {
  BillsListBloc({
    required BillsRepository billsRepository,
    required CardsRepository cardsRepository,
  })  : _billsRepository = billsRepository,
        _cardsRepository = cardsRepository,
        super(const BillsListBlocState()) {
    on<BillsListRequested>(_onRequested);
    on<BillsListRefreshRequested>(_onRefreshRequested);
  }

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;

  Future<void> _onRequested(
    BillsListRequested event,
    Emitter<BillsListBlocState> emit,
  ) async {
    emit(state.copyWith(status: BillsListStatus.loading, clearError: true));
    try {
      final billsFuture = _billsRepository.fetchAll();
      final cardsFuture = _cardsRepository.fetchAll();

      final bills = await billsFuture;
      final cards = await cardsFuture;
      final cardsById = {for (final c in cards) c.id: c};

      emit(state.copyWith(
        status: BillsListStatus.success,
        bills: bills,
        cardsById: cardsById,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: BillsListStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onRefreshRequested(
    BillsListRefreshRequested event,
    Emitter<BillsListBlocState> emit,
  ) async {
    add(const BillsListRequested());
  }
}
