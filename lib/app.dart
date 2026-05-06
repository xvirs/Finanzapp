import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session;

import 'core/analytics_service.dart';
import 'core/biometric_service.dart';
import 'core/firebase_init.dart';
import 'core/notification_service.dart';
import 'core/realtime_service.dart';
import 'data/bills_repository.dart';
import 'data/cards_repository.dart';
import 'data/incomes_repository.dart';
import 'data/installments_repository.dart';
import 'data/payments_repository.dart';
import 'design/theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/lock/presentation/app_lock_gate.dart';
import 'router.dart';

class FinanzappApp extends StatefulWidget {
  const FinanzappApp({
    required this.notifications,
    required this.biometricService,
    required this.firebase,
    super.key,
  });

  final FlutterLocalNotificationsPlugin notifications;
  final BiometricService biometricService;
  final FirebaseSetup firebase;

  @override
  State<FinanzappApp> createState() => _FinanzappAppState();
}

class _FinanzappAppState extends State<FinanzappApp> {
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  late final RealtimeService _realtimeService;
  late final BillsRepository _billsRepository;
  late final CardsRepository _cardsRepository;
  late final IncomesRepository _incomesRepository;
  late final InstallmentsRepository _installmentsRepository;
  late final PaymentsRepository _paymentsRepository;
  late final NotificationService _notificationService;
  late final AnalyticsService _analytics;

  StreamSubscription<AuthBlocState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _authBloc = AuthBloc(repository: _authRepository);
    _appRouter = AppRouter(_authBloc);
    _realtimeService = RealtimeService();
    _analytics = AnalyticsService(widget.firebase.analytics);

    _billsRepository = BillsRepository();
    _cardsRepository = CardsRepository();
    _incomesRepository = IncomesRepository();
    _installmentsRepository = InstallmentsRepository();
    _paymentsRepository = PaymentsRepository();

    _notificationService = NotificationService(
      plugin: widget.notifications,
      billsRepository: _billsRepository,
      cardsRepository: _cardsRepository,
      installmentsRepository: _installmentsRepository,
      paymentsRepository: _paymentsRepository,
      realtimeService: _realtimeService,
    );

    // Arrancar/parar realtime + notifications según el estado de auth.
    // También seteamos el user_id en Analytics + logueamos signed_in /
    // signed_out para correlacionar el resto de eventos por usuario.
    if (_authBloc.state.status == AuthStatus.authenticated) {
      _bootSession();
      _trackSignIn(_authBloc.state.session);
    }
    _authSubscription = _authBloc.stream.listen((authState) {
      switch (authState.status) {
        case AuthStatus.authenticated:
          _bootSession();
          _trackSignIn(authState.session);
        case AuthStatus.unauthenticated:
          _shutdownSession();
          _trackSignOut();
        case AuthStatus.unknown:
          break;
      }
    });
  }

  void _trackSignIn(Session? session) {
    final user = session?.user;
    if (user == null) return;
    _analytics.setUser(user.id);
    // El provider lo guarda Supabase en appMetadata.provider; típicamente
    // 'google' (Google Sign-In) o 'email' (magic link). Si por algún motivo
    // no está, dejamos 'unknown' — preferimos un evento anónimo que ninguno.
    final method = user.appMetadata['provider'] as String? ?? 'unknown';
    _analytics.signedIn(method: method);
  }

  void _trackSignOut() {
    _analytics.signedOut();
    _analytics.setUser(null);
  }

  Future<void> _bootSession() async {
    if (!_realtimeService.isActive) await _realtimeService.start();
    await _notificationService.start();
  }

  Future<void> _shutdownSession() async {
    await _notificationService.stop();
    if (_realtimeService.isActive) await _realtimeService.stop();

    // Cleanup post-signout (lo dispara cualquier camino: Config, LockScreen
    // failsafe, expiración de sesión en Supabase). Si esto NO se hace:
    //   1. El flag de biometric queda en disco → al reabrir la app sin
    //      sesión, AppLockGate igual muestra el LockScreen.
    //   2. Los blocs hydrated devuelven datos del usuario anterior al
    //      próximo login (otro user en el mismo device, o el mismo
    //      después de una sesión vencida).
    await widget.biometricService.setEnabled(false);
    await HydratedBloc.storage.clear();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _notificationService.stop();
    _realtimeService.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _realtimeService),
        RepositoryProvider.value(value: widget.biometricService),
        RepositoryProvider.value(value: _billsRepository),
        RepositoryProvider.value(value: _cardsRepository),
        RepositoryProvider.value(value: _incomesRepository),
        RepositoryProvider.value(value: _installmentsRepository),
        RepositoryProvider.value(value: _paymentsRepository),
        // FirebaseSetup expuesto para que cualquier screen llame
        // `context.read<FirebaseSetup>().analytics?.logEvent(...)`.
        // Si Firebase no fue configurado todavía, los nullable getters
        // devuelven null y los call sites son no-op.
        RepositoryProvider.value(value: widget.firebase),
        // AnalyticsService wrapper: las screens deberían usar este
        // (`context.read<AnalyticsService>().billCreated(...)`) en
        // lugar de FirebaseSetup directo. Si Firebase no inició, las
        // llamadas son no-op silencioso.
        RepositoryProvider.value(value: _analytics),
      ],
      child: BlocProvider.value(
        value: _authBloc,
        child: MaterialApp.router(
          title: 'Finanzapp',
          debugShowCheckedModeBanner: false,
          theme: FzTheme.dark(),
          darkTheme: FzTheme.dark(),
          themeMode: ThemeMode.dark,
          routerConfig: _appRouter.router,
          builder: (context, child) => AppLockGate(
            service: widget.biometricService,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
