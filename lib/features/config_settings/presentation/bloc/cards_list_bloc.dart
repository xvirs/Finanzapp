import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/realtime_service.dart';
import '../../../../data/cards_repository.dart';
import '../../../../models/credit_card.dart';

part 'cards_list_event.dart';
part 'cards_list_state.dart';

class CardsListBloc extends Bloc<CardsListEvent, CardsListBlocState> {
  CardsListBloc({
    required CardsRepository cardsRepository,
    required RealtimeService realtimeService,
  }) : _cardsRepository = cardsRepository,
       super(const CardsListBlocState()) {
    on<CardsListRequested>(_onRequested);
    on<CardsListRefreshRequested>(_onRefreshRequested);
    on<CardsListSilentRefreshRequested>(_onSilentRefreshRequested);

    _realtimeSubscription = realtimeService.changes.listen((table) {
      if (table != RealtimeTable.creditCards) return;
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 250),
        () => add(const CardsListSilentRefreshRequested()),
      );
    });
  }

  final CardsRepository _cardsRepository;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _refreshDebounce;

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRequested(
    CardsListRequested event,
    Emitter<CardsListBlocState> emit,
  ) async {
    emit(state.copyWith(status: CardsListStatus.loading, clearError: true));
    try {
      final cards = await _cardsRepository.fetchAll();
      emit(state.copyWith(status: CardsListStatus.success, cards: cards));
    } catch (error) {
      emit(
        state.copyWith(
          status: CardsListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    CardsListRefreshRequested event,
    Emitter<CardsListBlocState> emit,
  ) async {
    add(const CardsListRequested());
  }

  Future<void> _onSilentRefreshRequested(
    CardsListSilentRefreshRequested event,
    Emitter<CardsListBlocState> emit,
  ) async {
    if (state.status != CardsListStatus.success) return;
    try {
      final cards = await _cardsRepository.fetchAll();
      emit(state.copyWith(cards: cards));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
