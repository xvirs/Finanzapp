import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  })  : _billsRepository = billsRepository,
        _cardsRepository = cardsRepository,
        _installmentsRepository = installmentsRepository,
        _paymentsRepository = paymentsRepository,
        super(MonthBlocState()) {
    on<MonthRequested>(_onRequested);
    on<MonthRefreshRequested>(_onRefreshRequested);
    on<MonthOnlyPendingToggled>(_onOnlyPendingToggled);
    on<MonthMarkPaidRequested>(_onMarkPaidRequested);
    on<MonthMarkPendingRequested>(_onMarkPendingRequested);
  }

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final PaymentsRepository _paymentsRepository;

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
      final period = event.period;
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

      final groups = groupChecklistByCategory(items);
      final summary = summarizeChecklist(items);

      emit(state.copyWith(
        status: MonthStatus.success,
        groups: groups,
        summary: summary,
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

  void _onOnlyPendingToggled(
    MonthOnlyPendingToggled event,
    Emitter<MonthBlocState> emit,
  ) {
    emit(state.copyWith(onlyPending: !state.onlyPending));
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
      add(const MonthRefreshRequested());
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
      add(const MonthRefreshRequested());
    } catch (error) {
      emit(state.copyWith(
        clearMutating: true,
        errorMessage: error.toString(),
      ));
    }
  }
}
