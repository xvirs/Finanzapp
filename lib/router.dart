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
import 'features/cards/presentation/bloc/card_detail_bloc.dart';
import 'features/cards/presentation/bloc/cards_bloc.dart';
import 'features/cards/presentation/card_detail_screen.dart';
import 'features/cards/presentation/card_form_screen.dart';
import 'features/cards/presentation/cards_screen.dart';
import 'features/cards/presentation/installment_form_screen.dart';
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
                builder: (context, state) => BlocProvider(
                  create: (ctx) => CardsBloc(
                    billsRepository: ctx.read<BillsRepository>(),
                    cardsRepository: ctx.read<CardsRepository>(),
                    installmentsRepository: ctx.read<InstallmentsRepository>(),
                    paymentsRepository: ctx.read<PaymentsRepository>(),
                  )..add(const CardsRequested()),
                  child: const CardsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'card-new',
                    builder: (context, state) => const CardFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'card-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BlocProvider(
                        create: (ctx) => CardDetailBloc(
                          cardsRepository: ctx.read<CardsRepository>(),
                          installmentsRepository:
                              ctx.read<InstallmentsRepository>(),
                          billsRepository: ctx.read<BillsRepository>(),
                          paymentsRepository: ctx.read<PaymentsRepository>(),
                        )..add(CardDetailRequested(id)),
                        child: const CardDetailScreen(),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'card-edit',
                        builder: (context, state) => CardFormScreen(
                          cardId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'installments/new',
                        name: 'installment-new',
                        builder: (context, state) => InstallmentFormScreen(
                          cardId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'installments/:iid',
                        name: 'installment-edit',
                        builder: (context, state) => InstallmentFormScreen(
                          cardId: state.pathParameters['id']!,
                          installmentId: state.pathParameters['iid'],
                        ),
                      ),
                    ],
                  ),
                ],
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
