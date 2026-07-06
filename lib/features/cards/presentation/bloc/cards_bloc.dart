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
import '../../../../models/enums.dart';
import '../../../../models/payment.dart';
import '../../domain/card_list_item_data.dart';

part 'cards_event.dart';
part 'cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsBlocState> {
  CardsBloc({
    required BillsRepository billsRepository,
    required CardsRepository cardsRepository,
    required InstallmentsRepository installmentsRepository,
    required PaymentsRepository paymentsRepository,
    required RealtimeService realtimeService,
  }) : _billsRepository = billsRepository,
       _cardsRepository = cardsRepository,
       _installmentsRepository = installmentsRepository,
       _paymentsRepository = paymentsRepository,
       _realtimeService = realtimeService,
       super(CardsBlocState()) {
    on<CardsRequested>(_onRequested);
    on<CardsRefreshRequested>(_onRefreshRequested);
    on<CardsSilentRefreshRequested>(_onSilentRefreshRequested);
    on<CardsMarkPaidRequested>(_onMarkPaidRequested);
    on<CardsMarkPendingRequested>(_onMarkPendingRequested);

    _realtimeSubscription = realtimeService.changes.listen((_) {
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 250),
        () => add(const CardsSilentRefreshRequested()),
      );
    });
  }

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final PaymentsRepository _paymentsRepository;
  final RealtimeService _realtimeService;

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
      PeriodKey period,
      List<CardListItemData> items,
      double totalForPeriod,
      double paidForPeriod,
    })
  >
  _loadCardsData() async {
    final period = PeriodKey.current();
    final periodIso = period.toIso();

    final cardsFuture = _cardsRepository.fetchAllActive();
    final purchasesFuture = _installmentsRepository.fetchAll();
    final billsFuture = _billsRepository.fetchAllActive();
    final paymentsFuture = _paymentsRepository.fetchForPeriod(periodIso);

    final cards = await cardsFuture;
    final purchases = await purchasesFuture;
    final bills = await billsFuture;
    final payments = await paymentsFuture;

    final items = <CardListItemData>[];
    var totalForPeriod = 0.0;
    var paidForPeriod = 0.0;

    for (final card in cards) {
      final cardPurchases = purchases
          .where((p) => p.creditCardId == card.id)
          .toList();
      final cardAutoDebits = bills
          .where((b) => b.active && b.autoDebitCardId == card.id)
          .toList();

      // Cuotas activas en el período actual (con su índice 1..N).
      final activeInstallments = <ActiveInstallment>[];
      for (final purchase in cardPurchases) {
        final result = installmentForPeriod(purchase, period);
        if (result == null) continue;
        activeInstallments.add(
          ActiveInstallment(purchase: purchase, cuotaIndex: result.cuotaIndex),
        );
      }
      activeInstallments.sort(
        (a, b) => a.purchase.description.compareTo(b.purchase.description),
      );

      final summary = summarizeCardForPeriod(
        purchases: cardPurchases,
        target: period,
        autoDebitBills: cardAutoDebits,
      );

      final payment = payments
          .where((p) => p.kind == PaymentKind.cardTotal && p.cardId == card.id)
          .cast<Payment?>()
          .firstWhere((_) => true, orElse: () => null);

      items.add(
        CardListItemData(
          card: card,
          activeInstallments: activeInstallments,
          autoDebitBills: cardAutoDebits,
          total: summary.total,
          payment: payment,
        ),
      );

      totalForPeriod += summary.total;
      if (payment?.status == PaymentStatus.paid) {
        paidForPeriod += payment?.amountReal ?? summary.total;
      }
    }

    return (
      period: period,
      items: items,
      totalForPeriod: totalForPeriod,
      paidForPeriod: paidForPeriod,
    );
  }

  Future<void> _onRequested(
    CardsRequested event,
    Emitter<CardsBlocState> emit,
  ) async {
    emit(state.copyWith(status: CardsStatus.loading, clearError: true));
    try {
      final data = await _loadCardsData();
      emit(
        state.copyWith(
          status: CardsStatus.success,
          period: data.period,
          items: data.items,
          totalForPeriod: data.totalForPeriod,
          paidForPeriod: data.paidForPeriod,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CardsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    CardsRefreshRequested event,
    Emitter<CardsBlocState> emit,
  ) async {
    add(const CardsRequested());
  }

  Future<void> _onSilentRefreshRequested(
    CardsSilentRefreshRequested event,
    Emitter<CardsBlocState> emit,
  ) async {
    if (state.status != CardsStatus.success) return;
    try {
      final data = await _loadCardsData();
      emit(
        state.copyWith(
          period: data.period,
          items: data.items,
          totalForPeriod: data.totalForPeriod,
          paidForPeriod: data.paidForPeriod,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onMarkPaidRequested(
    CardsMarkPaidRequested event,
    Emitter<CardsBlocState> emit,
  ) async {
    final item = _findItem(event.cardId);
    if (item == null) return;
    emit(state.copyWith(mutatingCardId: event.cardId, clearError: true));
    try {
      await _paymentsRepository.savePaidPayment(
        existingPaymentId: item.payment?.id,
        periodIso: state.period.toIso(),
        kind: PaymentKind.cardTotal,
        cardId: event.cardId,
        amount: event.amount,
      );
      _realtimeService.notifyLocalChange(RealtimeTable.payments);
      await _silentRefreshAfterMutation(emit);
    } catch (error) {
      emit(state.copyWith(clearMutating: true, errorMessage: error.toString()));
    }
  }

  Future<void> _onMarkPendingRequested(
    CardsMarkPendingRequested event,
    Emitter<CardsBlocState> emit,
  ) async {
    final item = _findItem(event.cardId);
    final paymentId = item?.payment?.id;
    if (paymentId == null) return;
    emit(state.copyWith(mutatingCardId: event.cardId, clearError: true));
    try {
      await _paymentsRepository.deletePayment(paymentId);
      _realtimeService.notifyLocalChange(RealtimeTable.payments);
      await _silentRefreshAfterMutation(emit);
    } catch (error) {
      emit(state.copyWith(clearMutating: true, errorMessage: error.toString()));
    }
  }

  CardListItemData? _findItem(String cardId) {
    for (final item in state.items) {
      if (item.card.id == cardId) return item;
    }
    return null;
  }

  /// Refresh tras mutación: recarga + limpia mutating en una sola
  /// emisión, para evitar flicker entre el spinner y el estado nuevo.
  Future<void> _silentRefreshAfterMutation(Emitter<CardsBlocState> emit) async {
    try {
      final data = await _loadCardsData();
      emit(
        state.copyWith(
          period: data.period,
          items: data.items,
          totalForPeriod: data.totalForPeriod,
          paidForPeriod: data.paidForPeriod,
          clearMutating: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(clearMutating: true, errorMessage: error.toString()));
    }
  }
}
