import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/analytics_service.dart';
import 'core/realtime_service.dart';
import 'data/bills_repository.dart';
import 'data/cards_repository.dart';
import 'data/incomes_repository.dart';
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
import 'features/config_settings/presentation/bill_form_screen.dart';
import 'features/config_settings/presentation/bill_type_chooser_screen.dart';
import 'features/config_settings/presentation/bills_list_screen.dart';
import 'features/config_settings/presentation/bloc/bills_list_bloc.dart';
import 'features/config_settings/presentation/bloc/cards_list_bloc.dart';
import 'features/config_settings/presentation/bloc/incomes_list_bloc.dart';
import 'features/config_settings/presentation/cards_list_screen.dart';
import 'features/config_settings/presentation/config_screen.dart';
import 'features/config_settings/presentation/income_form_screen.dart';
import 'features/config_settings/presentation/incomes_list_screen.dart';
import 'features/month/presentation/bloc/month_bloc.dart';
import 'features/month/presentation/month_screen.dart';
import 'shell/app_shell.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  /// Navigator raíz — usado para flujos full-screen que deben vivir por
  /// encima del shell (y no dentro de la rama de un tab), como el alta de
  /// gasto. Así, al terminar, podemos `go('/')` sin dejar el stack del tab
  /// colgado.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
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
                    incomesRepository: ctx.read<IncomesRepository>(),
                    installmentsRepository: ctx.read<InstallmentsRepository>(),
                    paymentsRepository: ctx.read<PaymentsRepository>(),
                    realtimeService: ctx.read<RealtimeService>(),
                    analytics: ctx.read<AnalyticsService>(),
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
                    realtimeService: ctx.read<RealtimeService>(),
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
                          installmentsRepository: ctx
                              .read<InstallmentsRepository>(),
                          billsRepository: ctx.read<BillsRepository>(),
                          paymentsRepository: ctx.read<PaymentsRepository>(),
                          realtimeService: ctx.read<RealtimeService>(),
                        )..add(CardDetailRequested(id)),
                        child: const CardDetailScreen(),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'card-edit',
                        builder: (context, state) =>
                            CardFormScreen(cardId: state.pathParameters['id']),
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
                routes: [
                  GoRoute(
                    path: 'bills',
                    name: 'bills-list',
                    builder: (context, state) => BlocProvider(
                      create: (ctx) => BillsListBloc(
                        billsRepository: ctx.read<BillsRepository>(),
                        cardsRepository: ctx.read<CardsRepository>(),
                        realtimeService: ctx.read<RealtimeService>(),
                      )..add(const BillsListRequested()),
                      child: const BillsListScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: 'bill-new',
                        // Flujo de alta full-screen sobre el shell: al
                        // guardar hacemos go('/') y no queda nada montado
                        // en la rama de config.
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const BillTypeChooserScreen(),
                        routes: [
                          GoRoute(
                            path: 'oneshot',
                            name: 'bill-new-oneshot',
                            parentNavigatorKey: rootNavigatorKey,
                            builder: (context, state) => const BillFormScreen(
                              initialMode: BillFormMode.oneShot,
                            ),
                          ),
                          GoRoute(
                            path: 'recurring',
                            name: 'bill-new-recurring',
                            parentNavigatorKey: rootNavigatorKey,
                            builder: (context, state) => const BillFormScreen(
                              initialMode: BillFormMode.recurring,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: ':id',
                        name: 'bill-edit',
                        builder: (context, state) =>
                            BillFormScreen(billId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'cards',
                    name: 'config-cards-list',
                    builder: (context, state) => BlocProvider(
                      create: (ctx) => CardsListBloc(
                        cardsRepository: ctx.read<CardsRepository>(),
                        realtimeService: ctx.read<RealtimeService>(),
                      )..add(const CardsListRequested()),
                      child: const CardsListScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: 'config-card-new',
                        builder: (context, state) => const CardFormScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: 'config-card-edit',
                        builder: (context, state) =>
                            CardFormScreen(cardId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'incomes',
                    name: 'incomes-list',
                    builder: (context, state) => BlocProvider(
                      create: (ctx) => IncomesListBloc(
                        incomesRepository: ctx.read<IncomesRepository>(),
                        realtimeService: ctx.read<RealtimeService>(),
                      )..add(const IncomesListRequested()),
                      child: const IncomesListScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: 'income-new',
                        builder: (context, state) => const IncomeFormScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: 'income-edit',
                        builder: (context, state) => IncomeFormScreen(
                          incomeId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
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
