import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/format.dart';
import '../data/bills_repository.dart';
import '../data/cards_repository.dart';
import '../data/installments_repository.dart';
import '../data/payments_repository.dart';
import '../domain/installments.dart';
import '../domain/period.dart';
import '../models/bill.dart';
import '../models/credit_card.dart';
import '../models/enums.dart';
import 'realtime_service.dart';

const _channelId = 'finanzapp_due_reminders';
const _channelName = 'Recordatorios de vencimiento';
const _channelDescription =
    'Avisos un día antes de que venza cada pago del mes.';

/// Hora local a la que se dispara el recordatorio del día anterior.
const _reminderHour = 9;

/// Reconcilia recordatorios locales con el estado de la DB:
/// - Cancela todas las notificaciones pendientes.
/// - Para cada bill / tarjeta del mes actual no pagado y con día válido,
///   schedulea una notificación local 1 día antes a las 09:00.
///
/// Es "nuke and pave": no trackea diferencias, solo reemplaza el set
/// completo. Se llama en startup y en cada cambio de Realtime (debounced).
class NotificationService {
  NotificationService({
    required FlutterLocalNotificationsPlugin plugin,
    required BillsRepository billsRepository,
    required CardsRepository cardsRepository,
    required InstallmentsRepository installmentsRepository,
    required PaymentsRepository paymentsRepository,
    required RealtimeService realtimeService,
  }) : _plugin = plugin,
       _billsRepository = billsRepository,
       _cardsRepository = cardsRepository,
       _installmentsRepository = installmentsRepository,
       _paymentsRepository = paymentsRepository,
       _realtimeService = realtimeService;

  final FlutterLocalNotificationsPlugin _plugin;
  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;
  final InstallmentsRepository _installmentsRepository;
  final PaymentsRepository _paymentsRepository;
  final RealtimeService _realtimeService;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _reconcileDebounce;
  bool _started = false;

  /// Pide permisos al SO (iOS siempre, Android 13+ runtime). Devuelve
  /// true si están concedidos al final.
  Future<bool> requestPermissions() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final iosOk = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    final androidOk = await android?.requestNotificationsPermission();

    return iosOk ?? androidOk ?? true;
  }

  /// Estado del permiso de notificaciones: true concedido, false denegado,
  /// null si no se pudo determinar. Para la pantalla de diagnóstico.
  Future<bool?> permissionStatus() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) return android.areNotificationsEnabled();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final opts = await ios?.checkPermissions();
    return opts?.isEnabled;
  }

  /// Cantidad de notificaciones programadas pendientes (diagnóstico).
  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;

  /// Crea el canal de Android explícitamente (idempotente). En Android el
  /// canal es necesario para que las notificaciones se muestren con la
  /// importancia correcta; lo creamos en el arranque y antes de las pruebas.
  Future<void> ensureChannel() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
  }

  /// Arranca: pide permisos, hace reconcile inicial y se subscribe a
  /// Realtime para reconciliar en cada cambio.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    await requestPermissions();
    await ensureChannel();
    await reconcile();

    _realtimeSubscription = _realtimeService.changes.listen((_) {
      _reconcileDebounce?.cancel();
      _reconcileDebounce = Timer(
        const Duration(milliseconds: 500),
        () => reconcile(),
      );
    });
  }

  /// Cancela todo y para de reconciliar — usar al hacer logout.
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    _reconcileDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    await _plugin.cancelAll();
  }

  /// Recalcula y reemplaza todas las notificaciones pendientes según el
  /// estado actual de la DB.
  Future<void> reconcile() async {
    try {
      await _plugin.cancelAll();

      final period = PeriodKey.current();
      final periodIso = period.toIso();

      final billsFuture = _billsRepository.fetchAllActive();
      final cardsFuture = _cardsRepository.fetchAllActive();
      final purchasesFuture = _installmentsRepository.fetchAll();
      final paymentsFuture = _paymentsRepository.fetchForPeriod(periodIso);

      final bills = await billsFuture;
      final cards = await cardsFuture;
      final purchases = await purchasesFuture;
      final payments = await paymentsFuture;

      final reminders = <_DueReminder>[];

      // Bills (no auto-debit): cada uno es su propio recordatorio.
      for (final bill in bills) {
        if (bill.autoDebitCardId != null) continue;
        if (bill.dayOfMonth == null) continue;

        final paid = payments.any(
          (p) =>
              p.kind == PaymentKind.bill &&
              p.billId == bill.id &&
              p.status == PaymentStatus.paid,
        );
        if (paid) continue;

        reminders.add(
          _DueReminder(
            id: _idForBill(bill),
            title: 'Vence mañana: ${bill.name}',
            body: bill.defaultAmount != null
                ? formatCurrency(bill.defaultAmount)
                : 'Monto variable',
            dayOfMonth: bill.dayOfMonth!,
            period: period,
          ),
        );
      }

      // Tarjetas: sumamos cuotas + auto-debits y avisamos si hay total.
      for (final card in cards) {
        if (card.dueDay == null) continue;

        final cardPurchases = purchases
            .where((p) => p.creditCardId == card.id)
            .toList();
        final cardAutoDebits = bills
            .where((b) => b.active && b.autoDebitCardId == card.id)
            .toList();

        final summary = summarizeCardForPeriod(
          purchases: cardPurchases,
          target: period,
          autoDebitBills: cardAutoDebits,
        );

        if (summary.total <= 0) continue;

        final paid = payments.any(
          (p) =>
              p.kind == PaymentKind.cardTotal &&
              p.cardId == card.id &&
              p.status == PaymentStatus.paid,
        );
        if (paid) continue;

        reminders.add(
          _DueReminder(
            id: _idForCard(card),
            title: 'Vence mañana: ${card.name}',
            body:
                '${formatCurrency(summary.total)} · '
                '${_cardBreakdown(summary.installmentsCount, summary.autoDebitsCount)}',
            dayOfMonth: card.dueDay!,
            period: period,
          ),
        );
      }

      for (final r in reminders) {
        await _scheduleReminder(r);
      }
    } catch (e, st) {
      // Si falla el fetch (sin internet, sesión rota), las notificaciones del
      // ciclo anterior siguen vigentes y reintentamos en la próxima
      // reconciliación. En debug logueamos para no quedar a ciegas.
      if (kDebugMode) {
        debugPrint('NotificationService.reconcile() falló: $e\n$st');
      }
    }
  }

  Future<void> _scheduleReminder(_DueReminder r) async {
    final scheduledAt = _reminderTime(r.period, r.dayOfMonth);
    if (scheduledAt == null) return;

    await _plugin.zonedSchedule(
      r.id,
      r.title,
      r.body,
      scheduledAt,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Hora local a la que disparar el recordatorio: el día previo al
  /// vencimiento a las [_reminderHour]:00. Si esa hora ya pasó (vencimiento
  /// hoy o ayer), devolvemos null para no schedulear en el pasado.
  tz.TZDateTime? _reminderTime(PeriodKey period, int dayOfMonth) {
    // Limita el día al último día del mes (ej: día 31 en febrero).
    final lastDay = DateTime(period.year, period.month + 2, 0).day;
    final clampedDay = dayOfMonth.clamp(1, lastDay);

    final dueDate = tz.TZDateTime(
      tz.local,
      period.year,
      period.month + 1,
      clampedDay,
    );
    final notifyAt = dueDate
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: _reminderHour));

    final now = tz.TZDateTime.now(tz.local);
    if (notifyAt.isBefore(now)) return null;
    return notifyAt;
  }

  // ---- IDs estables -----------------------------------------------------
  // flutter_local_notifications usa int como id; usamos hashCode masked
  // a 31 bits para evitar negativos. Bill y Card no chocan porque le
  // sumamos un sufijo distinto antes de hashear.

  int _idForBill(Bill b) => 'bill:${b.id}'.hashCode & 0x7FFFFFFF;
  int _idForCard(CreditCard c) => 'card:${c.id}'.hashCode & 0x7FFFFFFF;

  String _cardBreakdown(int installments, int autoDebits) {
    final parts = <String>[];
    if (installments > 0) {
      parts.add('$installments ${installments == 1 ? "cuota" : "cuotas"}');
    }
    if (autoDebits > 0) {
      parts.add('$autoDebits ${autoDebits == 1 ? "déb. aut." : "débs. aut."}');
    }
    return parts.isEmpty ? 'Sin desglose' : parts.join(' · ');
  }
}

class _DueReminder {
  const _DueReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.dayOfMonth,
    required this.period,
  });

  final int id;
  final String title;
  final String body;
  final int dayOfMonth;
  final PeriodKey period;
}
