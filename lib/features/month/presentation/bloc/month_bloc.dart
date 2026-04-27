import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/realtime_service.dart';
import '../../../../data/bills_repository.dart';
import '../../../../data/cards_repository.dart';
import '../../../../data/installments_repository.dart';
import '../../../../data/payments_repository.dart';
import '../../../../domain/period.dart';
import '../../../../models/enums.dart';
import '../../domain/month_builder.dart';
import '../../domain/month_item.dart';

part 'month_event.dart';
part 'month_state.dart';

class MonthBloc extends Bloc<MonthEvent, MonthBlocState> {
  MonthBloc({
    required BillsRepository billsRepository,
    required CardsRepository cardsRepository,
    required InstallmentsRepository installmentsRepository,
    required PaymentsRepository paymentsRepository,
    required RealtimeService realtimeService,
  })  : _billsRepository = billsRepository,
        _cardsRepository = cardsRepository,
        _installmentsRepository = installmentsRepository,
        _paymentsRepository = paymentsRepository,
        super(MonthBlocState()) {
    on<MonthRequested>(_onRequested);
    on<MonthRefreshRequested>(_onRefreshRequested);
    on<MonthSilentRefreshRequested>(_onSilentRefreshRequested);
    on<MonthFilterChanged>(_onFilterChanged);
    on<MonthMarkPaidRequested>(_onMarkPaidRequested);
    on<MonthMarkPendingRequested>(_onMarkPendingRequested);

    // Realtime: cualquier cambio en las 4 tablas → silent refresh
    // (debounce 250ms para batchear cambios rápidos).
    _realtimeSubscription = realtimeService.changes.listen((_) {
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 250),
        () => add(const MonthSilentRefreshRequested()),
      );
    });
  }

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final PaymentsRepository _paymentsRepository;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _refreshDebounce;

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  /// Fetch + build helpers — usado por load inicial, navegación de mes,
  /// pull-to-refresh, y refresh post-mutación.
  Future<({List<MonthGroup> groups, MonthSummary summary})> _loadMonthData(
    PeriodKey period,
  ) async {
    final periodIso = period.toIso();
    final windowStartIso = period.subtractMonths(3).toIso();

    final billsFuture = _billsRepository.fetchAllActive();
    final cardsFuture = _cardsRepository.fetchAllActive();
    final purchasesFuture = _installmentsRepository.fetchAll();
    final paymentsFuture = _paymentsRepository.fetchForPeriod(periodIso);
    final recentFuture = _paymentsRepository.fetchPaidInWindow(
      startIso: windowStartIso,
      endIso: periodIso,
    );

    final bills = await billsFuture;
    final cards = await cardsFuture;
    final purchases = await purchasesFuture;
    final payments = await paymentsFuture;
    final recentPayments = await recentFuture;

    final items = buildMonthChecklist(
      period: period,
      bills: bills,
      cards: cards,
      purchases: purchases,
      payments: payments,
      recentPayments: recentPayments,
    );

    return (
      groups: groupChecklistByCategory(items),
      summary: summarizeChecklist(items),
    );
  }

  Future<void> _onRequested(
    MonthRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    emit(state.copyWith(
      status: MonthStatus.loading,
      period: event.period,
      clearError: true,
      clearMutating: true,
    ));

    try {
      final data = await _loadMonthData(event.period);
      emit(state.copyWith(
        status: MonthStatus.success,
        groups: data.groups,
        summary: data.summary,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: MonthStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onRefreshRequested(
    MonthRefreshRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    add(MonthRequested(state.period));
  }

  Future<void> _onSilentRefreshRequested(
    MonthSilentRefreshRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    if (state.status != MonthStatus.success) return;
    await _silentRefresh(emit);
  }

  void _onFilterChanged(
    MonthFilterChanged event,
    Emitter<MonthBlocState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  /// Refresh "silencioso" después de mutar: NO toca status, así la lista
  /// no parpadea con el spinner full-screen. El feedback visual queda
  /// solamente en el spinner del botón del item modificado (driveado por
  /// mutatingItemKey).
  Future<void> _silentRefresh(Emitter<MonthBlocState> emit) async {
    try {
      final data = await _loadMonthData(state.period);
      emit(state.copyWith(
        groups: data.groups,
        summary: data.summary,
        clearMutating: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        clearMutating: true,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onMarkPaidRequested(
    MonthMarkPaidRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    final item = event.item;
    emit(state.copyWith(mutatingItemKey: item.key, clearError: true));
    try {
      await _paymentsRepository.savePaidPayment(
        existingPaymentId: item.payment?.id,
        periodIso: state.period.toIso(),
        kind: item.kind == MonthItemKind.bill
            ? PaymentKind.bill
            : PaymentKind.cardTotal,
        billId: item.bill?.id,
        cardId: item.card?.id,
        amount: event.amount,
      );
      await _silentRefresh(emit);
    } catch (error) {
      emit(state.copyWith(
        clearMutating: true,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onMarkPendingRequested(
    MonthMarkPendingRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    final item = event.item;
    final paymentId = item.payment?.id;
    if (paymentId == null) return;

    emit(state.copyWith(mutatingItemKey: item.key, clearError: true));
    try {
      await _paymentsRepository.deletePayment(paymentId);
      await _silentRefresh(emit);
    } catch (error) {
      emit(state.copyWith(
        clearMutating: true,
        errorMessage: error.toString(),
      ));
    }
  }
}
