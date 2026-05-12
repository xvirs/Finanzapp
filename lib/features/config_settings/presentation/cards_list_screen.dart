import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../widgets/shimmer_box.dart';
import 'bloc/cards_list_bloc.dart';

/// Pantalla — Tarjetas (lista de gestión).
/// Espejo de `BillsListScreen`: cada fila abre el form de edición de la
/// tarjeta en `/config/cards/:id`. Mantiene el dashboard de `/cards`
/// (con estimados/pagos) separado del CRUD de configuración.
class CardsListScreen extends StatelessWidget {
  const CardsListScreen({this.showAppBar = true, super.key});

  /// Cuando se embebe en el detail pane de Config (expanded), el master
  /// ya provee el contexto de la sección, así que no necesitamos otro
  /// `FzAppBar` con botón "atrás" que no tendría a dónde volver.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CardsListBloc, CardsListBlocState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showAppBar)
                  FzAppBar(
                    title: 'Tarjetas',
                    trailing: _AddButton(
                      onPressed: () async {
                        final bloc = context.read<CardsListBloc>();
                        final result = await context.push<bool>(
                          '/config/cards/new',
                        );
                        if (result == true) {
                          bloc.add(const CardsListRefreshRequested());
                        }
                      },
                    ),
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FzRadius.md),
        boxShadow: [
          BoxShadow(
            color: FzColors.primary.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: FzColors.primary,
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(FzRadius.md),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: FzColors.primaryInk,
              weight: 800,
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final CardsListBlocState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case CardsListStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Error',
          onRetry: () => context.read<CardsListBloc>().add(
            const CardsListRefreshRequested(),
          ),
        );

      case CardsListStatus.initial:
      case CardsListStatus.loading:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<CardsListBloc>().add(
              const CardsListRefreshRequested(),
            );
          },
          child: const _Shimmer(),
        );

      case CardsListStatus.success:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context.read<CardsListBloc>().add(
              const CardsListRefreshRequested(),
            );
          },
          child: state.cards.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [_EmptyView()],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _SummaryRow(cards: state.cards),
                    const SizedBox(height: 12),
                    ..._buildCardTiles(context, state.cards),
                  ],
                ),
        );
    }
  }

  List<Widget> _buildCardTiles(BuildContext context, List<CreditCard> cards) {
    return [
      for (final card in cards) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _CardTile(
            card: card,
            onTap: () async {
              final bloc = context.read<CardsListBloc>();
              final result = await context.push<bool>(
                '/config/cards/${card.id}',
              );
              if (result == true) {
                bloc.add(const CardsListRefreshRequested());
              }
            },
          ),
        ),
        const SizedBox(height: 6),
      ],
    ];
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.cards});
  final List<CreditCard> cards;

  @override
  Widget build(BuildContext context) {
    final active = cards.where((c) => c.active).length;
    final inactive = cards.length - active;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          _SummaryStat(value: active, label: 'activas'),
          if (inactive > 0) _SummaryStat(value: inactive, label: 'inactivas'),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FzColors.text,
              letterSpacing: 0.44,
            ),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 11,
              color: FzColors.textDim,
              letterSpacing: 0.44,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.onTap});

  final CreditCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FzColors.card,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: FzColors.border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: card.active ? 1.0 : 0.5,
                child: _BrandChip(brand: card.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            card.name,
                            style: TextStyle(
                              fontFamily: FzType.sans,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: card.active
                                  ? FzColors.text
                                  : FzColors.textDim,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!card.active) ...[
                          const SizedBox(width: 6),
                          const _InactivePill(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(card),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FzType.mono,
                        fontSize: 11,
                        color: FzColors.textMute,
                        letterSpacing: 0.44,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: FzColors.textMute,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(CreditCard card) {
    final parts = <String>[];
    final brandLabel = switch (card.brand) {
      CardBrand.visa => 'VISA',
      CardBrand.mastercard => 'MASTERCARD',
      CardBrand.amex => 'AMEX',
      CardBrand.other => 'OTRA',
      null => 'TARJETA',
    };
    parts.add(brandLabel);
    if (card.issuer != null && card.issuer!.trim().isNotEmpty) {
      parts.add(card.issuer!.trim());
    }
    if (card.dueDay != null) parts.add('Vence día ${card.dueDay}');
    return parts.join(' · ');
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.brand});
  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (brand) {
      CardBrand.visa => ('VISA', FzColors.visaBg),
      CardBrand.mastercard => ('MC', FzColors.mastercardBg),
      CardBrand.amex => ('AMEX', FzColors.mpBg),
      CardBrand.other => ('OTRA', FzColors.cardHi),
      null => ('—', FzColors.cardHi),
    };
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.md),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: FzType.sans,
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
        ),
      ),
    );
  }
}

class _InactivePill extends StatelessWidget {
  const _InactivePill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: FzColors.cardHi,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: const Text(
        'INACTIVA',
        style: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.36,
          color: FzColors.textMute,
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: ShimmerBox(width: 180, height: 11, radius: 2),
        ),
        _CardRowShimmer(),
        SizedBox(height: 6),
        _CardRowShimmer(),
        SizedBox(height: 6),
        _CardRowShimmer(),
      ],
    );
  }
}

class _CardRowShimmer extends StatelessWidget {
  const _CardRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: FzColors.card,
          border: Border.all(color: FzColors.border),
          borderRadius: BorderRadius.circular(FzRadius.lg),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 38, height: 38, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 14, radius: 3),
                  SizedBox(height: 6),
                  ShimmerBox(width: 110, height: 11, radius: 2),
                ],
              ),
            ),
          ],
        ),
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
              'No tenés tarjetas',
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
              'Tocá "+" arriba para crear una.',
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
