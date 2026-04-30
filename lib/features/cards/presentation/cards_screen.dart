import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics_service.dart';
import '../../../design/tokens.dart';
import '../../../domain/period.dart';
import '../../../widgets/animated_amount.dart';
import 'bloc/cards_bloc.dart';
import 'widgets/card_list_item.dart';
import 'widgets/cards_shimmer.dart';

/// Pantalla 4 — Tarjetas (lista).
/// Port pixel-perfect del JSX `ACardsList` (handoff/screens-a-cards.jsx).
///
/// Layout:
/// - Header anclado: título h1 "Tarjetas" + caplabel mono "abril de 2026"
///   + caplabel "TOTAL DEL MES" + monto display 32px.
/// - Body con scroll: cards grandes (1 por tarjeta).
class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnalyticsService>().screenView('tarjetas');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CardsBloc, CardsBlocState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: FzColors.bg,
                  child: _CardsHeader(state: state),
                ),
                Expanded(child: _Body(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final CardsBlocState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case CardsStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Error desconocido',
          onRetry: () =>
              context.read<CardsBloc>().add(const CardsRefreshRequested()),
        );

      case CardsStatus.initial:
      case CardsStatus.loading:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<CardsBloc>().add(const CardsRefreshRequested());
          },
          child: const CardsShimmer(),
        );

      case CardsStatus.success:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<CardsBloc>().add(const CardsRefreshRequested());
          },
          child: state.items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [_EmptyView()],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 14, bottom: 12),
                  itemCount: state.items.length,
                  itemBuilder: (ctx, i) {
                    final item = state.items[i];
                    return CardListItem(
                      data: item,
                      period: state.period,
                      onTap: () async {
                        final bloc = ctx.read<CardsBloc>();
                        final result = await ctx.push<bool>(
                          '/cards/${item.card.id}',
                        );
                        if (result == true) {
                          bloc.add(const CardsRefreshRequested());
                        }
                      },
                    );
                  },
                ),
        );
    }
  }
}

class _CardsHeader extends StatelessWidget {
  const _CardsHeader({required this.state});

  final CardsBlocState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FzColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tarjetas',
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.65,
              color: FzColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatLowerMonth(state.period),
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 12,
              color: FzColors.textDim,
              letterSpacing: 0.24,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'TOTAL DEL MES',
            style: TextStyle(
              fontFamily: FzType.mono,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.66,
              color: FzColors.textMute,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedCurrency(
            value: state.totalForPeriod,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
              fontFeatures: FzType.tabularNums,
              color: FzColors.text,
            ),
          ),
        ],
      ),
    );
  }

  // "abril de 2026" lowercase como en el JSX.
  String _formatLowerMonth(PeriodKey p) => p.formatLong().toLowerCase();
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: FzColors.lateColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar las tarjetas',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12,
                color: FzColors.textDim,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.credit_card_off_outlined,
              size: 48,
              color: FzColors.primary,
            ),
            SizedBox(height: 12),
            Text(
              'No tenés tarjetas activas',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Creá una desde Config → Tarjetas → +.',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12,
                color: FzColors.textDim,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
