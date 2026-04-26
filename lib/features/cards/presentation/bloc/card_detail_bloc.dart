import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  })  : _cardsRepository = cardsRepository,
        _installmentsRepository = installmentsRepository,
        _billsRepository = billsRepository,
        _paymentsRepository = paymentsRepository,
        super(CardDetailBlocState()) {
    on<CardDetailRequested>(_onRequested);
    on<CardDetailRefreshRequested>(_onRefreshRequested);
  }

  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final BillsRepository _billsRepository;
  final PaymentsRepository _paymentsRepository;

  Future<void> _onRequested(
    CardDetailRequested event,
    Emitter<CardDetailBlocState> emit,
  ) async {
    emit(state.copyWith(
      status: CardDetailStatus.loading,
      cardId: event.cardId,
      clearError: true,
    ));

    try {
      final period = PeriodKey.current();
      final periodIso = period.toIso();

      final cardFuture = _cardsRepository.fetchById(event.cardId);
      final purchasesFuture =
          _installmentsRepository.fetchForCard(event.cardId);
      final billsFuture = _billsRepository.fetchAllActive();
      final paymentsFuture = _paymentsRepository.fetchForPeriod(periodIso);

      final card = await cardFuture;
      if (card == null) {
        emit(state.copyWith(
          status: CardDetailStatus.failure,
          errorMessage: 'La tarjeta no existe.',
        ));
        return;
      }

      final purchases = await purchasesFuture;
      final bills = await billsFuture;
      final payments = await paymentsFuture;

      final autoDebitBills = bills
          .where((b) => b.active && b.autoDebitCardId == card.id)
          .toList();

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

      final payment = payments
          .where(
            (p) => p.kind == PaymentKind.cardTotal && p.cardId == card.id,
          )
          .cast<Payment?>()
          .firstWhere((_) => true, orElse: () => null);

      emit(state.copyWith(
        status: CardDetailStatus.success,
        card: card,
        purchases: purchasesWithStatus,
        autoDebitBills: autoDebitBills,
        payment: payment,
        clearPayment: payment == null,
        summary: summary,
        period: period,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CardDetailStatus.failure,
        errorMessage: error.toString(),
      ));
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
}
