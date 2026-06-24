import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/realtime_service.dart';
import '../../../../data/bills_repository.dart';
import '../../../../data/cards_repository.dart';
import '../../../../data/installments_repository.dart';
import '../../../../data/payments_repository.dart';
import '../../../../domain/installments.dart';
import '../../../../domain/period.dart';
import '../../../../models/bill.dart';
import '../../../../models/credit_card.dart';
import '../../../../models/enums.dart';
import '../../../../models/installment_purchase.dart';
import '../../../../models/payment.dart';

part 'card_detail_event.dart';
part 'card_detail_state.dart';

class CardDetailBloc extends Bloc<CardDetailEvent, CardDetailBlocState> {
  CardDetailBloc({
    required CardsRepository cardsRepository,
    required InstallmentsRepository installmentsRepository,
    required BillsRepository billsRepository,
    required PaymentsRepository paymentsRepository,
    required RealtimeService realtimeService,
  }) : _cardsRepository = cardsRepository,
       _installmentsRepository = installmentsRepository,
       _billsRepository = billsRepository,
       _paymentsRepository = paymentsRepository,
       super(CardDetailBlocState()) {
    on<CardDetailRequested>(_onRequested);
    on<CardDetailRefreshRequested>(_onRefreshRequested);
    on<CardDetailSilentRefreshRequested>(_onSilentRefreshRequested);

    _realtimeSubscription = realtimeService.changes.listen((_) {
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 250),
        () => add(const CardDetailSilentRefreshRequested()),
      );
    });
  }

  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final BillsRepository _billsRepository;
  final PaymentsRepository _paymentsRepository;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _refreshDebounce;

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  Future<
    ({
      CreditCard? card,
      List<PurchaseWithStatus> purchases,
      List<Bill> autoDebitBills,
      Payment? payment,
      CardMonthSummary summary,
      PeriodKey period,
    })
  >
  _loadDetailData(String cardId) async {
    final period = PeriodKey.current();
    final periodIso = period.toIso();

    final cardFuture = _cardsRepository.fetchById(cardId);
    final purchasesFuture = _installmentsRepository.fetchForCard(cardId);
    final billsFuture = _billsRepository.fetchAllActive();
    final paymentsFuture = _paymentsRepository.fetchForPeriod(periodIso);

    final card = await cardFuture;
    final purchases = await purchasesFuture;
    final bills = await billsFuture;
    final payments = await paymentsFuture;

    final autoDebitBills = card == null
        ? <Bill>[]
        : bills.where((b) => b.active && b.autoDebitCardId == card.id).toList();

    final purchasesWithStatus = purchases.map((p) {
      final inMonth = installmentForPeriod(p, period);
      return PurchaseWithStatus(
        purchase: p,
        activeCuotaIndex: inMonth?.cuotaIndex,
      );
    }).toList();

    final summary = summarizeCardForPeriod(
      purchases: purchases,
      target: period,
      autoDebitBills: autoDebitBills,
    );

    final payment = card == null
        ? null
        : payments
              .where(
                (p) => p.kind == PaymentKind.cardTotal && p.cardId == card.id,
              )
              .cast<Payment?>()
              .firstWhere((_) => true, orElse: () => null);

    return (
      card: card,
      purchases: purchasesWithStatus,
      autoDebitBills: autoDebitBills,
      payment: payment,
      summary: summary,
      period: period,
    );
  }

  Future<void> _onRequested(
    CardDetailRequested event,
    Emitter<CardDetailBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CardDetailStatus.loading,
        cardId: event.cardId,
        clearError: true,
      ),
    );

    try {
      final data = await _loadDetailData(event.cardId);
      if (data.card == null) {
        emit(
          state.copyWith(
            status: CardDetailStatus.failure,
            errorMessage: 'La tarjeta no existe.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: CardDetailStatus.success,
          card: data.card,
          purchases: data.purchases,
          autoDebitBills: data.autoDebitBills,
          payment: data.payment,
          clearPayment: data.payment == null,
          summary: data.summary,
          period: data.period,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CardDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    CardDetailRefreshRequested event,
    Emitter<CardDetailBlocState> emit,
  ) async {
    final id = state.cardId;
    if (id == null) return;
    add(CardDetailRequested(id));
  }

  Future<void> _onSilentRefreshRequested(
    CardDetailSilentRefreshRequested event,
    Emitter<CardDetailBlocState> emit,
  ) async {
    final id = state.cardId;
    if (id == null || state.status != CardDetailStatus.success) return;
    try {
      final data = await _loadDetailData(id);
      // Si la tarjeta fue eliminada, dejamos el estado como está; el
      // usuario volverá a la lista por su lado.
      if (data.card == null) return;
      emit(
        state.copyWith(
          card: data.card,
          purchases: data.purchases,
          autoDebitBills: data.autoDebitBills,
          payment: data.payment,
          clearPayment: data.payment == null,
          summary: data.summary,
          period: data.period,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
