import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/enums.dart';

// Formato custom: separador de miles con punto (es_AR) pero el símbolo
// "$" al PRINCIPIO (no al final como el default es_AR de intl), para
// alinear con el handoff del diseño que usa "$1.629.560".
final NumberFormat _amountFormatter = NumberFormat('#,##0', 'es_AR');

String formatCurrency(num? value) {
  if (value == null) return '—';
  return '\$${_amountFormatter.format(value)}';
}

String formatCurrencyOrVariable(num? value) {
  if (value == null) return 'Variable';
  return '\$${_amountFormatter.format(value)}';
}

/// Formatea un monto entero para mostrarlo dentro de un input de texto:
/// `1629560` → `"1.629.560"` (sin símbolo `$`, que va como prefix del campo).
String formatAmountInput(num value) => _amountFormatter.format(value);

/// Agrupa los miles con punto a medida que el usuario escribe un monto
/// entero (es_AR). Descarta todo lo que no sea dígito, así que el campo
/// siempre queda con el formato `1.234.567`.
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final formatted = _amountFormatter.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatMonthYear(DateTime date) => DateFormat.yMMMM('es_AR').format(date);

/// "1 cuenta" / "3 cuentas". Helper para evitar templates como
/// `'$n cuenta${n == 1 ? "" : "s"}'` repartidos por el código.
String pluralizeCount(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}

/// Versión corta del kind para subtítulos en filas estrechas (master
/// row del expanded, etc). Mantiene `kBillKindLabels` como fuente de
/// verdad para descripciones largas y este mapa para cuando hay
/// poco espacio.
const Map<BillKind, String> kBillKindShortLabels = {
  BillKind.rent: 'ALQUILER',
  BillKind.electricity: 'LUZ',
  BillKind.water: 'AGUA',
  BillKind.gas: 'GAS',
  BillKind.internet: 'INTERNET',
  BillKind.health: 'SALUD',
  BillKind.tax: 'IMPUESTO',
  BillKind.consortium: 'EXPENSAS',
  BillKind.subscription: 'SUSCR',
  BillKind.other: 'OTRO',
};

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

const Map<IncomeKind, String> kIncomeKindLabels = {
  IncomeKind.salary: 'Sueldo',
  IncomeKind.freelance: 'Freelance',
  IncomeKind.rental: 'Alquiler que cobro',
  IncomeKind.other: 'Otro',
};

const Map<IncomeKind, String> kIncomeKindEmoji = {
  IncomeKind.salary: '💼',
  IncomeKind.freelance: '🧑‍💻',
  IncomeKind.rental: '🏠',
  IncomeKind.other: '💰',
};
