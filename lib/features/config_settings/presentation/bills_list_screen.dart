import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../models/bill.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../widgets/bill_kind_icon.dart';
import '../../../widgets/shimmer_box.dart';
import 'bloc/bills_list_bloc.dart';

/// Pantalla 9 — Cuentas fijas (lista).
/// Port del JSX `AFixedAccounts` (handoff/screens-a-config.jsx).
class BillsListScreen extends StatelessWidget {
  const BillsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<BillsListBloc, BillsListBlocState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FzAppBar(
                  title: 'Cuentas fijas',
                  trailing: _AddButton(
                    onPressed: () async {
                      final bloc = context.read<BillsListBloc>();
                      final result =
                          await context.push<bool>('/config/bills/new');
                      if (result == true) {
                        bloc.add(const BillsListRefreshRequested());
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _Body(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Botón "+" cuadrado primary verde con sombra — para el trailing del
/// AppBar.
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
  final BillsListBlocState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case BillsListStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Error',
          onRetry: () => context
              .read<BillsListBloc>()
              .add(const BillsListRefreshRequested()),
        );

      case BillsListStatus.initial:
      case BillsListStatus.loading:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context
                .read<BillsListBloc>()
                .add(const BillsListRefreshRequested());
          },
          child: const _Shimmer(),
        );

      case BillsListStatus.success:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context
                .read<BillsListBloc>()
                .add(const BillsListRefreshRequested());
          },
          child: state.bills.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [_EmptyView()],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _SummaryRow(state: state),
                    const SizedBox(height: 12),
                    ..._buildBillTiles(context, state),
                  ],
                ),
        );
    }
  }

  List<Widget> _buildBillTiles(
      BuildContext context, BillsListBlocState state) {
    return [
      for (final bill in state.bills) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _BillTile(
            bill: bill,
            autoDebitCard: bill.autoDebitCardId != null
                ? state.cardsById[bill.autoDebitCardId]
                : null,
            onTap: () async {
              final bloc = context.read<BillsListBloc>();
              final result = await context.push<bool>(
                '/config/bills/${bill.id}',
              );
              if (result == true) {
                bloc.add(const BillsListRefreshRequested());
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
  const _SummaryRow({required this.state});
  final BillsListBlocState state;

  @override
  Widget build(BuildContext context) {
    final activeBills = state.bills.where((b) => b.active).toList();
    final activeCount = activeBills.length;
    final fixedCount =
        activeBills.where((b) => b.defaultAmount != null).length;
    final variableCount = activeCount - fixedCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          _SummaryStat(value: activeCount, label: 'activas'),
          _SummaryStat(value: fixedCount, label: 'con monto fijo'),
          _SummaryStat(value: variableCount, label: 'variables'),
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

class _BillTile extends StatelessWidget {
  const _BillTile({
    required this.bill,
    required this.autoDebitCard,
    required this.onTap,
  });

  final Bill bill;
  final CreditCard? autoDebitCard;
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
                opacity: bill.active ? 1.0 : 0.5,
                child: BillKindIcon(kind: bill.kind),
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
                            bill.name,
                            style: TextStyle(
                              fontFamily: FzType.sans,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: bill.active
                                  ? FzColors.text
                                  : FzColors.textDim,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!bill.active) ...[
                          const SizedBox(width: 6),
                          const _InactivePill(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    _Subtitle(bill: bill, autoDebitCard: autoDebitCard),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AmountOrVariable(amount: bill.defaultAmount),
            ],
          ),
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.bill, required this.autoDebitCard});

  final Bill bill;
  final CreditCard? autoDebitCard;

  @override
  Widget build(BuildContext context) {
    final base = StringBuffer(kBillKindLabels[bill.kind] ?? '—');
    if (bill.dayOfMonth != null) base.write(' · Día ${bill.dayOfMonth}');

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          base.toString(),
          style: const TextStyle(
            fontFamily: FzType.mono,
            fontSize: 11,
            color: FzColors.textMute,
            letterSpacing: 0.44,
          ),
        ),
        if (autoDebitCard != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '· ',
                style: TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 11,
                  color: FzColors.textMute,
                ),
              ),
              _CardSwatch(brand: autoDebitCard!.brand),
              const SizedBox(width: 4),
              Text(
                autoDebitCard!.name,
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 11,
                  color: FzColors.textDim,
                  letterSpacing: 0.44,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _CardSwatch extends StatelessWidget {
  const _CardSwatch({required this.brand});
  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    final color = switch (brand) {
      CardBrand.visa => FzColors.visaBg,
      CardBrand.mastercard => FzColors.mastercardBg,
      CardBrand.amex => FzColors.mpBg,
      CardBrand.other => FzColors.cardHi,
      null => FzColors.cardHi,
    };
    return Container(
      width: 14,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _AmountOrVariable extends StatelessWidget {
  const _AmountOrVariable({required this.amount});
  final double? amount;

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: FzColors.cardHi,
          borderRadius: BorderRadius.circular(FzRadius.xs),
        ),
        child: const Text(
          'VARIABLE',
          style: TextStyle(
            fontFamily: FzType.mono,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.44,
            color: FzColors.textDim,
          ),
        ),
      );
    }
    return Text(
      formatCurrency(amount),
      style: const TextStyle(
        fontFamily: FzType.sans,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFeatures: FzType.tabularNums,
        color: FzColors.text,
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
          child: ShimmerBox(width: 220, height: 11, radius: 2),
        ),
        _BillRowShimmer(),
        SizedBox(height: 6),
        _BillRowShimmer(),
        SizedBox(height: 6),
        _BillRowShimmer(),
        SizedBox(height: 6),
        _BillRowShimmer(),
        SizedBox(height: 6),
        _BillRowShimmer(),
      ],
    );
  }
}

class _BillRowShimmer extends StatelessWidget {
  const _BillRowShimmer();

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
                  ShimmerBox(width: 130, height: 14, radius: 3),
                  SizedBox(height: 6),
                  ShimmerBox(width: 90, height: 11, radius: 2),
                ],
              ),
            ),
            SizedBox(width: 12),
            ShimmerBox(width: 80, height: 14, radius: 3),
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
            const Icon(Icons.error_outline,
                size: 48, color: FzColors.lateColor),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar las cuentas',
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
              Icons.receipt_long_outlined,
              size: 48,
              color: FzColors.primary,
            ),
            SizedBox(height: 12),
            Text(
              'No tenés cuentas fijas',
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
