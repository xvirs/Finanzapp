import 'package:equatable/equatable.dart';

import '../../../models/credit_card.dart';
import '../../../models/payment.dart';

/// Datos pre-computados de una tarjeta para el período actual, listos
/// para renderizar en la lista de tarjetas.
class CardListItemData extends Equatable {
  const CardListItemData({
    required this.card,
    required this.installmentsCount,
    required this.autoDebitsCount,
    required this.total,
    required this.payment,
  });

  final CreditCard card;
  final int installmentsCount;
  final int autoDebitsCount;
  final double total;
  final Payment? payment;

  bool get hasCharges => installmentsCount > 0 || autoDebitsCount > 0;

  @override
  List<Object?> get props => [
        card,
        installmentsCount,
        autoDebitsCount,
        total,
        payment,
      ];
}
