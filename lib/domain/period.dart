import 'package:intl/intl.dart';

/// Identifica un mes calendario. `month` es 0-indexed (Enero = 0)
/// para mantener paridad con el código TS de la web.
class PeriodKey {
  const PeriodKey({required this.year, required this.month})
    : assert(month >= 0 && month <= 11, 'month must be 0..11');

  final int year;
  final int month;

  static PeriodKey current() {
    final now = DateTime.now();
    return PeriodKey(year: now.year, month: now.month - 1);
  }

  /// Parsea "YYYY-MM-DD" o "YYYY-MM". Evita problemas de timezone usando
  /// solo el split en `-`.
  static PeriodKey fromIso(String iso) {
    final parts = iso.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]) - 1;
    return PeriodKey(year: year, month: month);
  }

  /// Parsea slug de URL "YYYY-MM" (ej: "2026-04"). Devuelve null si es
  /// inválido.
  static PeriodKey? tryFromSlug(String slug) {
    final match = RegExp(r'^(\d{4})-(\d{1,2})$').firstMatch(slug);
    if (match == null) return null;
    final year = int.tryParse(match.group(1)!);
    final monthOneIndexed = int.tryParse(match.group(2)!);
    if (year == null || monthOneIndexed == null) return null;
    final month = monthOneIndexed - 1;
    if (month < 0 || month > 11) return null;
    return PeriodKey(year: year, month: month);
  }

  /// ISO date del primer día del mes — formato que usa Supabase para
  /// `payments.period` y `installment_purchases.first_period`.
  String toIso() {
    final m = (month + 1).toString().padLeft(2, '0');
    return '$year-$m-01';
  }

  /// Slug "YYYY-MM" para la URL del router.
  String toSlug() {
    final m = (month + 1).toString().padLeft(2, '0');
    return '$year-$m';
  }

  /// Formato `<input type="month">` (sin día).
  String toInputMonth() => toSlug();

  PeriodKey previous() {
    if (month == 0) return PeriodKey(year: year - 1, month: 11);
    return PeriodKey(year: year, month: month - 1);
  }

  PeriodKey next() {
    if (month == 11) return PeriodKey(year: year + 1, month: 0);
    return PeriodKey(year: year, month: month + 1);
  }

  PeriodKey subtractMonths(int n) {
    var m = month - n;
    var y = year;
    while (m < 0) {
      m += 12;
      y -= 1;
    }
    return PeriodKey(year: y, month: m);
  }

  int differenceInMonths(PeriodKey other) {
    return (other.year - year) * 12 + (other.month - month);
  }

  int compareTo(PeriodKey other) {
    if (year != other.year) return year - other.year;
    return month - other.month;
  }

  /// "Abril de 2026"
  String formatLong({String locale = 'es_AR'}) {
    final date = DateTime(year, month + 1, 1);
    return DateFormat.yMMMM(locale).format(date);
  }

  /// "abr. 26"
  String formatShort({String locale = 'es_AR'}) {
    final date = DateTime(year, month + 1, 1);
    return DateFormat("MMM ''yy", locale).format(date);
  }

  @override
  bool operator ==(Object other) =>
      other is PeriodKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'PeriodKey($year-${month + 1})';
}
