import 'package:intl/intl.dart';

final NumberFormat _currencyAr = NumberFormat.currency(
  locale: 'es_AR',
  symbol: '\$',
  decimalDigits: 0,
);

String formatCurrency(num? value) {
  if (value == null) return '—';
  return _currencyAr.format(value);
}

String formatMonthYear(DateTime date) {
  final formatter = DateFormat.yMMMM('es_AR');
  return formatter.format(date);
}
