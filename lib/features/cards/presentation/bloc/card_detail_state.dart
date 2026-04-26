part of 'card_detail_bloc.dart';

enum CardDetailStatus { initial, loading, success, failure }

/// Compra en cuotas con info de si es activa en el período actual.
class PurchaseWithStatus extends Equatable {
  const PurchaseWithStatus({
    required this.purchase,
    required this.activeCuotaIndex,
  });

  final InstallmentPurchase purchase;
  final int? activeCuotaIndex;

  bool get isActiveThisMonth => activeCuotaIndex != null;

  double? get thisMonthAmount =>
      isActiveThisMonth ? purchase.installmentAmount : null;

  @override
  List<Object?> get props => [purchase, activeCuotaIndex];
}

final class CardDetailBlocState extends Equatable {
  CardDetailBlocState({
    this.status = CardDetailStatus.initial,
    this.cardId,
    this.card,
    this.purchases = const [],
    this.autoDebitBills = const [],
    this.payment,
    this.summary,
    PeriodKey? period,
    this.errorMessage,
  }) : period = period ?? PeriodKey.current();

  final CardDetailStatus status;
  final String? cardId;
  final CreditCard? card;
  final List<PurchaseWithStatus> purchases;
  final List<Bill> autoDebitBills;
  final Payment? payment;
  final CardMonthSummary? summary;
  final PeriodKey period;
  final String? errorMessage;

  bool get isPaid => payment?.status == PaymentStatus.paid;

  CardDetailBlocState copyWith({
    CardDetailStatus? status,
    String? cardId,
    CreditCard? card,
    List<PurchaseWithStatus>? purchases,
    List<Bill>? autoDebitBills,
    Payment? payment,
    bool clearPayment = false,
    CardMonthSummary? summary,
    PeriodKey? period,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CardDetailBlocState(
      status: status ?? this.status,
      cardId: cardId ?? this.cardId,
      card: card ?? this.card,
      purchases: purchases ?? this.purchases,
      autoDebitBills: autoDebitBills ?? this.autoDebitBills,
      payment: clearPayment ? null : (payment ?? this.payment),
      summary: summary ?? this.summary,
      period: period ?? this.period,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        cardId,
        card,
        purchases,
        autoDebitBills,
        payment,
        summary,
        period,
        errorMessage,
      ];
}
