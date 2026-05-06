import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/realtime_service.dart';
import '../../../../data/incomes_repository.dart';
import '../../../../models/income.dart';

part 'incomes_list_event.dart';
part 'incomes_list_state.dart';

class IncomesListBloc extends Bloc<IncomesListEvent, IncomesListBlocState> {
  IncomesListBloc({
    required IncomesRepository incomesRepository,
    required RealtimeService realtimeService,
  }) : _incomesRepository = incomesRepository,
       super(const IncomesListBlocState()) {
    on<IncomesListRequested>(_onRequested);
    on<IncomesListRefreshRequested>(_onRefreshRequested);
    on<IncomesListSilentRefreshRequested>(_onSilentRefreshRequested);

    _realtimeSubscription = realtimeService.changes.listen((table) {
      if (table != RealtimeTable.incomes) return;
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 250),
        () => add(const IncomesListSilentRefreshRequested()),
      );
    });
  }

  final IncomesRepository _incomesRepository;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _refreshDebounce;

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRequested(
    IncomesListRequested event,
    Emitter<IncomesListBlocState> emit,
  ) async {
    emit(state.copyWith(status: IncomesListStatus.loading, clearError: true));
    try {
      final incomes = await _incomesRepository.fetchAll();
      emit(
        state.copyWith(status: IncomesListStatus.success, incomes: incomes),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: IncomesListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    IncomesListRefreshRequested event,
    Emitter<IncomesListBlocState> emit,
  ) async {
    add(const IncomesListRequested());
  }

  Future<void> _onSilentRefreshRequested(
    IncomesListSilentRefreshRequested event,
    Emitter<IncomesListBlocState> emit,
  ) async {
    if (state.status != IncomesListStatus.success) return;
    try {
      final incomes = await _incomesRepository.fetchAll();
      emit(state.copyWith(incomes: incomes));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
