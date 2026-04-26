import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'data/bills_repository.dart';
import 'data/cards_repository.dart';
import 'data/installments_repository.dart';
import 'data/payments_repository.dart';
import 'domain/period.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/cards/presentation/cards_screen.dart';
import 'features/config_settings/presentation/config_screen.dart';
import 'features/month/presentation/bloc/month_bloc.dart';
import 'features/month/presentation/month_screen.dart';
import 'shell/app_shell.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefreshNotifier(_authBloc),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'month',
                builder: (context, state) => BlocProvider(
                  create: (ctx) => MonthBloc(
                    billsRepository: ctx.read<BillsRepository>(),
                    cardsRepository: ctx.read<CardsRepository>(),
                    installmentsRepository: ctx.read<InstallmentsRepository>(),
                    paymentsRepository: ctx.read<PaymentsRepository>(),
                  )..add(MonthRequested(PeriodKey.current())),
                  child: const MonthScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cards',
                name: 'cards',
                builder: (context, state) => const CardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/config',
                name: 'config',
                builder: (context, state) => const ConfigScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final loggingIn = state.matchedLocation == '/login';

    switch (authState.status) {
      case AuthStatus.unknown:
        return null;
      case AuthStatus.unauthenticated:
        return loggingIn ? null : '/login';
      case AuthStatus.authenticated:
        return loggingIn ? '/' : null;
    }
  }
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._bloc) {
    _subscription = _bloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _bloc;
  late final StreamSubscription<AuthBlocState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
