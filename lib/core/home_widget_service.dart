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

/// App Group iOS / grupo de prefs compartido. Debe coincidir con el
/// entitlement de los targets iOS y con el appGroupId del widget nativo.
const _iosAppGroupId = 'group.app.finanzapp.client';

/// Providers nativos Android (uno por tamaño) + nombre del widget iOS.
const _androidProviders = [
  'FinanzappSmallWidgetProvider',
  'FinanzappMediumWidgetProvider',
  'FinanzappListWidgetProvider',
];
const _iosWidgetName = 'FinanzappWidget';

/// Cantidad de próximos pagos que empujamos para el widget de lista.
const _listSize = 4;

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
/// actual: cuánto falta pagar, progreso, y los próximos vencimientos.
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

      final items = buildMonthChecklist(
        period: period,
        bills: (results[0] as List).cast(),
        cards: (results[1] as List).cast(),
        purchases: (results[2] as List).cast(),
        payments: (results[3] as List).cast(),
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

      final upcoming = _upcoming(items, period);
      final next = upcoming.isNotEmpty ? upcoming.first : null;

      final writes = <Future<void>>[
        HomeWidget.saveWidgetData('period', _periodLabel(period)),
        HomeWidget.saveWidgetData('falta', formatCurrency(falta.toDouble())),
        HomeWidget.saveWidgetData(
          'progress_label',
          '${summary.paidCount}/${summary.totalCount} pagadas',
        ),
        HomeWidget.saveWidgetData('progress_percent', percent),
        // Próximo (widget chico + mediano)
        HomeWidget.saveWidgetData('has_next', next != null),
        HomeWidget.saveWidgetData('next_name', next?.name ?? ''),
        HomeWidget.saveWidgetData('next_amount', next?.amount ?? ''),
        HomeWidget.saveWidgetData('next_when', next?.whenLabel ?? ''),
        HomeWidget.saveWidgetData('next_overdue', next?.overdue ?? false),
        // Lista (widget grande)
        HomeWidget.saveWidgetData(
          'upcoming_count',
          upcoming.length.clamp(0, _listSize),
        ),
      ];
      for (var i = 0; i < _listSize; i++) {
        final it = i < upcoming.length ? upcoming[i] : null;
        writes.addAll([
          HomeWidget.saveWidgetData('item${i}_name', it?.name ?? ''),
          HomeWidget.saveWidgetData('item${i}_amount', it?.amount ?? ''),
          HomeWidget.saveWidgetData('item${i}_when', it?.whenLabel ?? ''),
          HomeWidget.saveWidgetData('item${i}_overdue', it?.overdue ?? false),
        ]);
      }
      await Future.wait(writes);

      for (final provider in _androidProviders) {
        await HomeWidget.updateWidget(androidName: provider);
      }
      await HomeWidget.updateWidget(iOSName: _iosWidgetName);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('HomeWidgetService.update() falló: $e\n$st');
      }
    }
  }

  /// Ítems no pagados ordenados por cercanía de vencimiento: primero los que
  /// están por venir (días>=0) de más cercano a más lejano, luego los vencidos
  /// del menos al más vencido.
  List<_DueItem> _upcoming(List<MonthItem> items, PeriodKey period) {
    final now = DateTime.now();
    final lastDay = DateTime(period.year, period.month + 2, 0).day;

    final list = <_DueItem>[];
    for (final item in items) {
      if (item.payment?.status == PaymentStatus.paid) continue;
      final day = item.dayOfMonth;
      final amount = item.estimatedAmount;
      if (day == null || amount == null || amount <= 0) continue;
      final days = day.clamp(1, lastDay) - now.day;
      list.add(
        _DueItem(
          name: item.bill?.name ?? item.card?.name ?? 'Pago',
          amount: formatCurrency(amount),
          whenLabel: _whenLabel(days),
          overdue: days < 0,
          days: days,
        ),
      );
    }
    list.sort((a, b) {
      final au = a.days >= 0, bu = b.days >= 0;
      if (au != bu) return au ? -1 : 1; // por-venir antes que vencidos
      return au ? a.days.compareTo(b.days) : b.days.compareTo(a.days);
    });
    return list;
  }

  String _whenLabel(int days) => days > 1
      ? 'en $days días'
      : days == 1
      ? 'mañana'
      : days == 0
      ? 'vence hoy'
      : 'vencido';

  String _periodLabel(PeriodKey period) =>
      '${_months[period.month]} ${period.year}';
}

class _DueItem {
  const _DueItem({
    required this.name,
    required this.amount,
    required this.whenLabel,
    required this.overdue,
    required this.days,
  });

  final String name;
  final String amount;
  final String whenLabel;
  final bool overdue;
  final int days;
}
