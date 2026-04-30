import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/realtime_service.dart';
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
    required RealtimeService realtimeService,
  }) : _billsRepository = billsRepository,
       _cardsRepository = cardsRepository,
       super(const BillsListBlocState()) {
    on<BillsListRequested>(_onRequested);
    on<BillsListRefreshRequested>(_onRefreshRequested);
    on<BillsListSilentRefreshRequested>(_onSilentRefreshRequested);

    _realtimeSubscription = realtimeService.changes.listen((table) {
      // Solo nos interesan cambios en bills y credit_cards.
      if (table != RealtimeTable.bills && table != RealtimeTable.creditCards) {
        return;
      }
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 250),
        () => add(const BillsListSilentRefreshRequested()),
      );
    });
  }

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _refreshDebounce;

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  Future<({List<Bill> bills, Map<String, CreditCard> cardsById})>
  _loadData() async {
    final billsFuture = _billsRepository.fetchAll();
    final cardsFuture = _cardsRepository.fetchAll();
    final bills = await billsFuture;
    final cards = await cardsFuture;
    final cardsById = {for (final c in cards) c.id: c};
    return (bills: bills, cardsById: cardsById);
  }

  Future<void> _onRequested(
    BillsListRequested event,
    Emitter<BillsListBlocState> emit,
  ) async {
    emit(state.copyWith(status: BillsListStatus.loading, clearError: true));
    try {
      final data = await _loadData();
      emit(
        state.copyWith(
          status: BillsListStatus.success,
          bills: data.bills,
          cardsById: data.cardsById,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BillsListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    BillsListRefreshRequested event,
    Emitter<BillsListBlocState> emit,
  ) async {
    add(const BillsListRequested());
  }

  Future<void> _onSilentRefreshRequested(
    BillsListSilentRefreshRequested event,
    Emitter<BillsListBlocState> emit,
  ) async {
    if (state.status != BillsListStatus.success) return;
    try {
      final data = await _loadData();
      emit(state.copyWith(bills: data.bills, cardsById: data.cardsById));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
