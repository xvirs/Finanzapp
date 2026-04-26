import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  })  : _billsRepository = billsRepository,
        _cardsRepository = cardsRepository,
        _installmentsRepository = installmentsRepository,
        _paymentsRepository = paymentsRepository,
        super(CardsBlocState()) {
    on<CardsRequested>(_onRequested);
    on<CardsRefreshRequested>(_onRefreshRequested);
  }

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final PaymentsRepository _paymentsRepository;

  Future<void> _onRequested(
    CardsRequested event,
    Emitter<CardsBlocState> emit,
  ) async {
    emit(state.copyWith(status: CardsStatus.loading, clearError: true));

    try {
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

      for (final card in cards) {
        final cardPurchases =
            purchases.where((p) => p.creditCardId == card.id).toList();
        final cardAutoDebits = bills
            .where((b) => b.active && b.autoDebitCardId == card.id)
            .toList();

        final summary = summarizeCardForPeriod(
          purchases: cardPurchases,
          target: period,
          autoDebitBills: cardAutoDebits,
        );

        final payment = payments
            .where(
              (p) => p.kind == PaymentKind.cardTotal && p.cardId == card.id,
            )
            .cast<Payment?>()
            .firstWhere((_) => true, orElse: () => null);

        items.add(CardListItemData(
          card: card,
          installmentsCount: summary.installmentsCount,
          autoDebitsCount: summary.autoDebitsCount,
          total: summary.total,
          payment: payment,
        ));

        totalForPeriod += summary.total;
      }

      emit(state.copyWith(
        status: CardsStatus.success,
        period: period,
        items: items,
        totalForPeriod: totalForPeriod,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CardsStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onRefreshRequested(
    CardsRefreshRequested event,
    Emitter<CardsBlocState> emit,
  ) async {
    add(const CardsRequested());
  }
}
