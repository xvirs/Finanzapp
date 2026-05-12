part of 'cards_bloc.dart';

enum CardsStatus { initial, loading, success, failure }

final class CardsBlocState extends Equatable {
  CardsBlocState({
    this.status = CardsStatus.initial,
    PeriodKey? period,
    this.items = const [],
    this.totalForPeriod = 0,
    this.paidForPeriod = 0,
    this.errorMessage,
    this.mutatingCardId,
  }) : period = period ?? PeriodKey.current();

  final CardsStatus status;
  final PeriodKey period;
  final List<CardListItemData> items;

  /// Estimado del mes: suma de cuotas activas + débitos automáticos en
  /// todas las tarjetas activas.
  final double totalForPeriod;

  /// Pagado del mes: suma de `Payment.amountReal` (o estimado si no hay
  /// amountReal explícito) de las tarjetas marcadas como pagadas.
  final double paidForPeriod;

  final String? errorMessage;

  /// Id de la tarjeta cuyo pago está siendo mutado (mark paid/pending).
  /// La fila correspondiente muestra spinner y desactiva su botón.
  final String? mutatingCardId;

  CardsBlocState copyWith({
    CardsStatus? status,
    PeriodKey? period,
    List<CardListItemData>? items,
    double? totalForPeriod,
    double? paidForPeriod,
    String? errorMessage,
    bool clearError = false,
    String? mutatingCardId,
    bool clearMutating = false,
  }) {
    return CardsBlocState(
      status: status ?? this.status,
      period: period ?? this.period,
      items: items ?? this.items,
      totalForPeriod: totalForPeriod ?? this.totalForPeriod,
      paidForPeriod: paidForPeriod ?? this.paidForPeriod,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mutatingCardId: clearMutating
          ? null
          : (mutatingCardId ?? this.mutatingCardId),
    );
  }

  @override
  List<Object?> get props => [
    status,
    period,
    items,
    totalForPeriod,
    paidForPeriod,
    errorMessage,
    mutatingCardId,
  ];
}
