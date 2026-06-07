import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adaptive_scaffold.dart';
import '../../../core/analytics_service.dart';
import '../../../core/format.dart';
import '../../../design/tokens.dart';
import '../../../domain/period.dart';
import '../../../widgets/animated_amount.dart';
import '../../../widgets/empty_state.dart';
import 'bloc/cards_bloc.dart';
import 'widgets/card_list_item.dart';
import 'widgets/cards_expanded_layout.dart';
import 'widgets/cards_expanded_shimmer.dart';
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
  /// Tarjeta seleccionada en master/detail (expanded/desktop).
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnalyticsService>().screenView('tarjetas');
    });
  }

  void _selectCard(String id) => setState(() => _selectedCardId = id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: BlocBuilder<CardsBloc, CardsBlocState>(
        builder: (context, state) {
          return AdaptiveScaffold(
            compact: (_) {
              final isLoading = state.status == CardsStatus.loading ||
                  state.status == CardsStatus.initial;
              return SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      color: FzColors.bg,
                      child: isLoading
                          ? const CardsHeaderShimmer()
                          : _CardsHeader(state: state),
                    ),
                    Expanded(child: _Body(state: state)),
                  ],
                ),
              );
            },
            expanded: (_) => SafeArea(
              bottom: false,
              child: state.status == CardsStatus.loading ||
                      state.status == CardsStatus.initial
                  ? const CardsExpandedShimmer()
                  : CardsExpandedLayout(
                      state: state,
                      selectedCardId: _selectedCardId,
                      onSelect: _selectCard,
                    ),
            ),
          );
        },
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
              ? FzEmptyState(
                  icon: Icons.credit_card_outlined,
                  title: 'No tenés tarjetas',
                  description:
                      'Agregá tu primera tarjeta para llevar el control de tus cuotas y resúmenes.',
                  ctaLabel: 'Agregar tarjeta',
                  onCta: () async {
                    final bloc = context.read<CardsBloc>();
                    final result = await context.push<bool>('/cards/new');
                    if (result == true) {
                      bloc.add(const CardsRefreshRequested());
                    }
                  },
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 14, bottom: 12),
                  itemCount: state.items.length,
                  itemBuilder: (ctx, i) {
                    final item = state.items[i];
                    return CardListItem(
                      key: ValueKey(item.card.id),
                      data: item,
                      period: state.period,
                      mutating: state.mutatingCardId == item.card.id,
                      onMarkPaid: (amount) =>
                          ctx.read<CardsBloc>().add(
                            CardsMarkPaidRequested(
                              cardId: item.card.id,
                              amount: amount,
                            ),
                          ),
                      onMarkPending: () => ctx.read<CardsBloc>().add(
                        CardsMarkPendingRequested(cardId: item.card.id),
                      ),
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
    final estimated = state.totalForPeriod;
    final paid = state.paidForPeriod;
    final pending = (estimated - paid).clamp(0, double.infinity);

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
          // Sin tarjetas, el resumen estimado/pagado son ceros que
          // confunden: lo ocultamos (la guía vive en el estado vacío).
          if (state.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'ESTIMADO',
                      amount: estimated,
                      paid: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'PAGADO',
                      amount: paid,
                      paid: true,
                      footer: 'falta ${formatCurrency(pending)}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // "abril de 2026" lowercase como en el JSX.
  String _formatLowerMonth(PeriodKey p) => p.formatLong().toLowerCase();
}

/// Card "ESTIMADO" / "PAGADO" del header de /cards. Replica el lenguaje
/// visual de las stat cards del Inicio (`MonthHeaderSection._SummaryCard`)
/// para que el usuario lea el total del mes de tarjetas igual que el del
/// mes completo: estimado neutro + pagado en verde tinted.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.paid,
    this.footer,
  });

  final String label;
  final double amount;
  final bool paid;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final bg = paid ? FzColors.cardPaid : FzColors.card;
    final border = paid ? FzColors.borderPaid : FzColors.border;
    final labelColor = paid
        ? FzColors.primary.withValues(alpha: 0.85)
        : FzColors.textMute;
    final amountColor = paid ? FzColors.primaryHi : FzColors.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FzType.mono,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.63,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedCurrency(
            value: amount,
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.44,
              fontFeatures: FzType.tabularNums,
              color: amountColor,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 2),
            Text(
              footer!,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 11,
                color: FzColors.textMute,
              ),
            ),
          ],
        ],
      ),
    );
  }
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

