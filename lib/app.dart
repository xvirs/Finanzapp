import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/notification_service.dart';
import 'core/realtime_service.dart';
import 'data/bills_repository.dart';
import 'data/cards_repository.dart';
import 'data/installments_repository.dart';
import 'data/payments_repository.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class FinanzappApp extends StatefulWidget {
  const FinanzappApp({required this.notifications, super.key});

  final FlutterLocalNotificationsPlugin notifications;

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
  late final InstallmentsRepository _installmentsRepository;
  late final PaymentsRepository _paymentsRepository;
  late final NotificationService _notificationService;

  StreamSubscription<AuthBlocState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _authBloc = AuthBloc(repository: _authRepository);
    _appRouter = AppRouter(_authBloc);
    _realtimeService = RealtimeService();

    _billsRepository = BillsRepository();
    _cardsRepository = CardsRepository();
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
    if (_authBloc.state.status == AuthStatus.authenticated) {
      _bootSession();
    }
    _authSubscription = _authBloc.stream.listen((authState) {
      switch (authState.status) {
        case AuthStatus.authenticated:
          _bootSession();
        case AuthStatus.unauthenticated:
          _shutdownSession();
        case AuthStatus.unknown:
          break;
      }
    });
  }

  Future<void> _bootSession() async {
    if (!_realtimeService.isActive) await _realtimeService.start();
    await _notificationService.start();
  }

  Future<void> _shutdownSession() async {
    await _notificationService.stop();
    if (_realtimeService.isActive) await _realtimeService.stop();
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
        RepositoryProvider.value(value: _billsRepository),
        RepositoryProvider.value(value: _cardsRepository),
        RepositoryProvider.value(value: _installmentsRepository),
        RepositoryProvider.value(value: _paymentsRepository),
      ],
      child: BlocProvider.value(
        value: _authBloc,
        child: MaterialApp.router(
          title: 'Finanzapp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
