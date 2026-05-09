import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics_service.dart';
import '../../../../core/realtime_service.dart';
import '../../../../data/bills_repository.dart';
import '../../../../data/cards_repository.dart';
import '../../../../data/incomes_repository.dart';
import '../../../../data/installments_repository.dart';
import '../../../../data/payments_repository.dart';
import '../../../../domain/period.dart';
import '../../../../models/enums.dart';
import '../../../../models/income.dart';
import '../../domain/month_builder.dart';
import '../../domain/month_item.dart';

part 'month_event.dart';
part 'month_state.dart';

class MonthBloc extends Bloc<MonthEvent, MonthBlocState> {
  MonthBloc({
    required BillsRepository billsRepository,
    required CardsRepository cardsRepository,
    required IncomesRepository incomesRepository,
    required InstallmentsRepository installmentsRepository,
    required PaymentsRepository paymentsRepository,
    required RealtimeService realtimeService,
    required AnalyticsService analytics,
  }) : _billsRepository = billsRepository,
       _cardsRepository = cardsRepository,
       _incomesRepository = incomesRepository,
       _installmentsRepository = installmentsRepository,
       _paymentsRepository = paymentsRepository,
       _analytics = analytics,
       super(MonthBlocState()) {
    on<MonthRequested>(_onRequested);
    on<MonthRefreshRequested>(_onRefreshRequested);
    on<MonthSilentRefreshRequested>(_onSilentRefreshRequested);
    on<MonthFilterChanged>(_onFilterChanged);
    on<MonthMarkPaidRequested>(_onMarkPaidRequested);
    on<MonthMarkPendingRequested>(_onMarkPendingRequested);

    // Realtime: cualquier cambio en las 4 tablas → silent refresh
    // (debounce 250ms para batchear cambios rápidos).
    _realtimeSubscription = realtimeService.changes.listen((_) {
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(
        const Duration(milliseconds: 250),
        () => add(const MonthSilentRefreshRequested()),
      );
    });
  }

  final BillsRepository _billsRepository;
  final CardsRepository _cardsRepository;
  final IncomesRepository _incomesRepository;
  final InstallmentsRepository _installmentsRepository;
  final PaymentsRepository _paymentsRepository;
  final AnalyticsService _analytics;

  StreamSubscription<RealtimeTable>? _realtimeSubscription;
  Timer? _refreshDebounce;

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  /// Fetch + build helpers — usado por load inicial, navegación de mes,
  /// pull-to-refresh, y refresh post-mutación.
  Future<
    ({List<MonthGroup> groups, MonthSummary summary, List<Income> incomes})
  >
  _loadMonthData(PeriodKey period) async {
    final periodIso = period.toIso();
    final windowStartIso = period.subtractMonths(3).toIso();

    final billsFuture = _billsRepository.fetchActiveForPeriod(period);
    final cardsFuture = _cardsRepository.fetchAllActive();
    final incomesFuture = _incomesRepository.fetchActiveForPeriod(period);
    final purchasesFuture = _installmentsRepository.fetchAll();
    final paymentsFuture = _paymentsRepository.fetchForPeriod(periodIso);
    final recentFuture = _paymentsRepository.fetchPaidInWindow(
      startIso: windowStartIso,
      endIso: periodIso,
    );

    final bills = await billsFuture;
    final cards = await cardsFuture;
    final incomes = await incomesFuture;
    final purchases = await purchasesFuture;
    final payments = await paymentsFuture;
    final recentPayments = await recentFuture;

    final items = buildMonthChecklist(
      period: period,
      bills: bills,
      cards: cards,
      purchases: purchases,
      payments: payments,
      recentPayments: recentPayments,
    );

    return (
      groups: groupChecklistByCategory(items),
      summary: summarizeChecklist(items, incomes: incomes, period: period),
      incomes: incomes,
    );
  }

  Future<void> _onRequested(
    MonthRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MonthStatus.loading,
        period: event.period,
        clearError: true,
        clearMutating: true,
      ),
    );

    try {
      final data = await _loadMonthData(event.period);
      final range = await _computeNavigableRange();
      emit(
        state.copyWith(
          status: MonthStatus.success,
          groups: data.groups,
          summary: data.summary,
          incomes: data.incomes,
          navigableMin: range.min,
          navigableMax: range.max,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MonthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Calcula el rango navegable considerando todos los datos del usuario:
  /// - bills/incomes activos: aportan `start_period` al min y, si tienen
  ///   `end_period`, al max.
  /// - cuotas: aportan `first_period` al min y `first_period + count - 1` al max.
  /// - payments: el `period` mínimo y máximo.
  /// Cap superior: `mes_actual + 12 meses` para los recurrentes sin fin.
  Future<({PeriodKey min, PeriodKey max})> _computeNavigableRange() async {
    final now = PeriodKey.current();
    final cap = PeriodKey(year: now.year + 1, month: now.month);

    final bills = await _billsRepository.fetchAll();
    final incomes = await _incomesRepository.fetchAll();
    final purchases = await _installmentsRepository.fetchAll();

    PeriodKey? min;
    PeriodKey? max;

    void considerMin(PeriodKey p) {
      if (min == null || p.compareTo(min!) < 0) min = p;
    }

    void considerMax(PeriodKey p) {
      if (max == null || p.compareTo(max!) > 0) max = p;
    }

    bool hasOpenEnd = false;
    for (final b in bills) {
      if (!b.active) continue;
      final start = PeriodKey.fromIso(b.startPeriod);
      considerMin(start);
      if (b.endPeriod == null) {
        hasOpenEnd = true;
      } else {
        considerMax(PeriodKey.fromIso(b.endPeriod!));
      }
    }
    for (final i in incomes) {
      if (!i.active) continue;
      final start = PeriodKey.fromIso(i.startPeriod);
      considerMin(start);
      if (i.endPeriod == null) {
        hasOpenEnd = true;
      } else {
        considerMax(PeriodKey.fromIso(i.endPeriod!));
      }
    }
    for (final p in purchases) {
      final start = PeriodKey.fromIso(p.firstPeriod);
      considerMin(start);
      // Última cuota = first_period + (count - 1) meses
      final last = PeriodKey(
        year: start.year,
        month: start.month,
      ).subtractMonths(-(p.installmentCount - 1));
      considerMax(last);
    }

    // Si hay recurrentes activos sin end_period, podemos navegar hasta el cap.
    if (hasOpenEnd) considerMax(cap);

    // Cap absoluto a futuro.
    if (max != null && max!.compareTo(cap) > 0) max = cap;

    // Si no hay nada cargado, el mes actual es el único navegable.
    return (min: min ?? now, max: max ?? now);
  }

  Future<void> _onRefreshRequested(
    MonthRefreshRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    add(MonthRequested(state.period));
  }

  Future<void> _onSilentRefreshRequested(
    MonthSilentRefreshRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    if (state.status != MonthStatus.success) return;
    await _silentRefresh(emit);
  }

  void _onFilterChanged(
    MonthFilterChanged event,
    Emitter<MonthBlocState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  /// Refresh "silencioso" después de mutar: NO toca status, así la lista
  /// no parpadea con el spinner full-screen. El feedback visual queda
  /// solamente en el spinner del botón del item modificado (driveado por
  /// mutatingItemKey).
  Future<void> _silentRefresh(Emitter<MonthBlocState> emit) async {
    try {
      final data = await _loadMonthData(state.period);
      final range = await _computeNavigableRange();
      emit(
        state.copyWith(
          groups: data.groups,
          summary: data.summary,
          incomes: data.incomes,
          navigableMin: range.min,
          navigableMax: range.max,
          clearMutating: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(clearMutating: true, errorMessage: error.toString()));
    }
  }

  Future<void> _onMarkPaidRequested(
    MonthMarkPaidRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    final item = event.item;
    final isFirstPaymentOfThisItem = item.payment == null;
    emit(state.copyWith(mutatingItemKey: item.key, clearError: true));
    try {
      await _paymentsRepository.savePaidPayment(
        existingPaymentId: item.payment?.id,
        periodIso: state.period.toIso(),
        kind: item.kind == MonthItemKind.bill
            ? PaymentKind.bill
            : PaymentKind.cardTotal,
        billId: item.bill?.id,
        cardId: item.card?.id,
        amount: event.amount,
      );
      // Solo trackeamos cuando es la primera marca de pagado del item
      // del mes (no edición de monto). Y solo bills — para cardTotal
      // tenemos el caso pero no lo modelamos como evento separado por
      // ahora; si más adelante hace falta agregamos `cardPaid`.
      if (isFirstPaymentOfThisItem &&
          item.kind == MonthItemKind.bill &&
          item.bill != null) {
        unawaited(
          _analytics.billPaid(kind: item.bill!.kind.name, amount: event.amount),
        );
      }
      await _silentRefresh(emit);
    } catch (error) {
      emit(state.copyWith(clearMutating: true, errorMessage: error.toString()));
    }
  }

  Future<void> _onMarkPendingRequested(
    MonthMarkPendingRequested event,
    Emitter<MonthBlocState> emit,
  ) async {
    final item = event.item;
    final paymentId = item.payment?.id;
    if (paymentId == null) return;

    emit(state.copyWith(mutatingItemKey: item.key, clearError: true));
    try {
      await _paymentsRepository.deletePayment(paymentId);
      await _silentRefresh(emit);
    } catch (error) {
      emit(state.copyWith(clearMutating: true, errorMessage: error.toString()));
    }
  }
}
