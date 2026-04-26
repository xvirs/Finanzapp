import 'package:intl/intl.dart';

import '../models/enums.dart';

final NumberFormat _currencyAr = NumberFormat.currency(
  locale: 'es_AR',
  symbol: '\$',
  decimalDigits: 0,
);

String formatCurrency(num? value) {
  if (value == null) return '—';
  return _currencyAr.format(value);
}

String formatCurrencyOrVariable(num? value) {
  if (value == null) return 'Variable';
  return _currencyAr.format(value);
}

String formatMonthYear(DateTime date) =>
    DateFormat.yMMMM('es_AR').format(date);

const Map<BillKind, String> kBillKindLabels = {
  BillKind.rent: 'Alquiler',
  BillKind.electricity: 'Luz',
  BillKind.water: 'Agua',
  BillKind.gas: 'Gas',
  BillKind.internet: 'Internet / Teléfono',
  BillKind.health: 'Salud',
  BillKind.tax: 'Impuesto',
  BillKind.consortium: 'Expensas / Consorcio',
  BillKind.subscription: 'Suscripción',
  BillKind.other: 'Otro',
};

const Map<BillKind, String> kBillKindEmoji = {
  BillKind.rent: '🏠',
  BillKind.electricity: '💡',
  BillKind.water: '💧',
  BillKind.gas: '🔥',
  BillKind.internet: '📶',
  BillKind.health: '🏥',
  BillKind.tax: '🏛️',
  BillKind.consortium: '🏢',
  BillKind.subscription: '📺',
  BillKind.other: '📌',
};

const Map<CardBrand, String> kCardBrandLabels = {
  CardBrand.visa: 'VISA',
  CardBrand.mastercard: 'Mastercard',
  CardBrand.amex: 'Amex',
  CardBrand.other: 'Otra',
};
