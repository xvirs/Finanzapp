import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  const FinanzappApp({super.key});

  @override
  State<FinanzappApp> createState() => _FinanzappAppState();
}

class _FinanzappAppState extends State<FinanzappApp> {
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  late final RealtimeService _realtimeService;
  StreamSubscription<AuthBlocState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _authBloc = AuthBloc(repository: _authRepository);
    _appRouter = AppRouter(_authBloc);
    _realtimeService = RealtimeService();

    // Arrancar/parar el canal de realtime según el estado de auth.
    if (_authBloc.state.status == AuthStatus.authenticated) {
      _realtimeService.start();
    }
    _authSubscription = _authBloc.stream.listen((authState) {
      switch (authState.status) {
        case AuthStatus.authenticated:
          if (!_realtimeService.isActive) _realtimeService.start();
        case AuthStatus.unauthenticated:
          if (_realtimeService.isActive) _realtimeService.stop();
        case AuthStatus.unknown:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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
        RepositoryProvider(create: (_) => BillsRepository()),
        RepositoryProvider(create: (_) => CardsRepository()),
        RepositoryProvider(create: (_) => InstallmentsRepository()),
        RepositoryProvider(create: (_) => PaymentsRepository()),
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
