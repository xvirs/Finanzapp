import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../data/bills_repository.dart';
import '../data/cards_repository.dart';
import '../data/installments_repository.dart';
import '../data/payments_repository.dart';
import '../domain/period.dart';
import '../features/month/domain/month_builder.dart';
import '../features/month/domain/month_item.dart';
import '../models/enums.dart';
import 'format.dart';
import 'realtime_service.dart';

/// Nombre del App Group iOS y del grupo de prefs compartido. Debe coincidir
/// con el configurado en el target de WidgetKit (entitlements).
const _iosAppGroupId = 'group.app.finanzapp.client';

/// Providers nativos que se refrescan al actualizar los datos.
const _androidProvider = 'FinanzappWidgetProvider';
const _iosWidgetName = 'FinanzappWidget';

/// Meses en español para el label del período (evita depender de init de
/// locale de intl en un contexto de servicio).
const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Empuja al widget de pantalla de inicio (Android + iOS) un resumen del mes
/// actual: cuánto falta pagar, progreso, y el próximo vencimiento.
///
/// "Nuke and pave" como [NotificationService]: recalcula todo el set en cada
/// cambio de Realtime (debounced) y al arrancar. No trackea diferencias.
class HomeWidgetService {
  HomeWidgetService({
    required BillsRepository billsRepository,
    required CardsRepository cardsRepository,
    required InstallmentsRepository installmentsRepository,
    required PaymentsRepository paymentsRepository,
    required RealtimeService realtimeService,
  }) : _billsRepository = billsRepository,
       _cardsRepository = cardsRepository,
       _installmentsRepository = installmentsRepository,
       _paymentsRepository = paymentsRepository,
       _realtimeService = realtimeService;

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final PaymentsRepository _paymentsRepository;
  final RealtimeService _realtimeService;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _debounce;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await HomeWidget.setAppGroupId(_iosAppGroupId);
    await update();
    _realtimeSubscription = _realtimeService.changes.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), update);
    });
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    _debounce?.cancel();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    await _clear();
  }

  /// Recalcula el resumen del mes y lo empuja a los widgets nativos.
  Future<void> update() async {
    try {
      final period = PeriodKey.current();
      final periodIso = period.toIso();

      final results = await Future.wait([
        _billsRepository.fetchAllActive(),
        _cardsRepository.fetchAllActive(),
        _installmentsRepository.fetchAll(),
        _paymentsRepository.fetchForPeriod(periodIso),
      ]);
      final bills = results[0] as List;
      final cards = results[1] as List;
      final purchases = results[2] as List;
      final payments = results[3] as List;

      final items = buildMonthChecklist(
        period: period,
        bills: bills.cast(),
        cards: cards.cast(),
        purchases: purchases.cast(),
        payments: payments.cast(),
      );
      final summary = summarizeChecklist(items, period: period);

      final falta = (summary.estimatedTotal - summary.paidTotal).clamp(
        0,
        double.infinity,
      );
      final percent = summary.estimatedTotal <= 0
          ? 0
          : ((summary.paidTotal / summary.estimatedTotal) * 100)
                .clamp(0, 100)
                .round();

      final next = _nextDue(items, period);

      await Future.wait([
        HomeWidget.saveWidgetData('period', _periodLabel(period)),
        HomeWidget.saveWidgetData('falta', formatCurrency(falta.toDouble())),
        HomeWidget.saveWidgetData(
          'progress_label',
          '${summary.paidCount}/${summary.totalCount} pagadas',
        ),
        HomeWidget.saveWidgetData('progress_percent', percent),
        HomeWidget.saveWidgetData('next_name', next?.name ?? ''),
        HomeWidget.saveWidgetData('next_amount', next?.amount ?? ''),
        HomeWidget.saveWidgetData('next_when', next?.whenLabel ?? ''),
        HomeWidget.saveWidgetData('next_overdue', next?.overdue ?? false),
        HomeWidget.saveWidgetData('has_next', next != null),
      ]);

      await Future.wait([
        HomeWidget.updateWidget(
          androidName: _androidProvider,
          iOSName: _iosWidgetName,
        ),
      ]);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('HomeWidgetService.update() falló: $e\n$st');
      }
    }
  }

  Future<void> _clear() async {
    await HomeWidget.saveWidgetData('has_next', false);
    await HomeWidget.saveWidgetData('falta', '—');
    await HomeWidget.updateWidget(
      androidName: _androidProvider,
      iOSName: _iosWidgetName,
    );
  }

  /// Próximo vencimiento: el ítem no pagado con vencimiento más cercano.
  /// Prefiere el próximo por venir; si todos están vencidos, el menos vencido.
  _NextDue? _nextDue(List<MonthItem> items, PeriodKey period) {
    final now = DateTime.now();
    final lastDay = DateTime(period.year, period.month + 2, 0).day;

    ({MonthItem item, int days})? best;
    for (final item in items) {
      if (item.payment?.status == PaymentStatus.paid) continue;
      final day = item.dayOfMonth;
      final amount = item.estimatedAmount;
      if (day == null || amount == null || amount <= 0) continue;
      final dueDay = day.clamp(1, lastDay);
      final days = dueDay - now.day;
      if (best == null) {
        best = (item: item, days: days);
        continue;
      }
      // Preferir el próximo por venir (days>=0) más cercano; entre vencidos,
      // el menos vencido (days más alto, es decir más cerca de hoy).
      final b = best;
      final betterUpcoming = days >= 0 && (b.days < 0 || days < b.days);
      final betterOverdue = days < 0 && b.days < 0 && days > b.days;
      if (betterUpcoming || betterOverdue) {
        best = (item: item, days: days);
      }
    }
    if (best == null) return null;

    final item = best.item;
    final days = best.days;
    final name = item.bill?.name ?? item.card?.name ?? 'Pago';
    final whenLabel = days > 1
        ? 'en $days días'
        : days == 1
        ? 'mañana'
        : days == 0
        ? 'vence hoy'
        : 'vencido';
    return _NextDue(
      name: name,
      amount: formatCurrency(item.estimatedAmount!),
      whenLabel: whenLabel,
      overdue: days < 0,
    );
  }

  String _periodLabel(PeriodKey period) =>
      '${_months[period.month]} ${period.year}';
}

class _NextDue {
  const _NextDue({
    required this.name,
    required this.amount,
    required this.whenLabel,
    required this.overdue,
  });

  final String name;
  final String amount;
  final String whenLabel;
  final bool overdue;
}
