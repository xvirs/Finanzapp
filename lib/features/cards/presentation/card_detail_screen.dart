import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format.dart';
import '../../../design/tokens.dart';
import '../../../models/bill.dart';
import '../../../models/enums.dart';
import '../../../widgets/shimmer_box.dart';
import 'bloc/card_detail_bloc.dart';
import 'widgets/installment_progress_tag.dart';

/// Pantalla 5 — Detalle de tarjeta (MercadoPago en el JSX como ejemplo).
/// Port pixel-perfect del JSX `ACardDetail` (handoff/screens-a-cards.jsx).
class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CardDetailBloc, CardDetailBlocState>(
          builder: (context, state) {
            final hasHeroData =
                state.card != null && state.summary != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AppBar siempre visible.
                _DetailAppBar(state: state),
                // Hero card anclado: durante carga inicial muestra
                // shimmer; cuando hay datos, muestra valores reales (se
                // mantiene durante refresh, datos se actualizan in-place).
                Material(
                  color: FzColors.bg,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: hasHeroData
                        ? _HeroCard(state: state)
                        : const _HeroShimmer(),
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

/// Cuerpo bajo el hero — solo las secciones (cuotas + débitos).
/// Maneja loading (shimmer) / failure / success.
class _Body extends StatelessWidget {
  const _Body({required this.state});
  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case CardDetailStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Error',
          onRetry: () => context
              .read<CardDetailBloc>()
              .add(const CardDetailRefreshRequested()),
        );

      case CardDetailStatus.initial:
      case CardDetailStatus.loading:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context
                .read<CardDetailBloc>()
                .add(const CardDetailRefreshRequested());
          },
          child: const _BodyShimmer(),
        );

      case CardDetailStatus.success:
        return RefreshIndicator(
          color: FzColors.primary,
          backgroundColor: FzColors.card,
          onRefresh: () async {
            context
                .read<CardDetailBloc>()
                .add(const CardDetailRefreshRequested());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _InstallmentsSection(state: state),
              _DebitsSection(state: state),
            ],
          ),
        );
    }
  }
}

/// AppBar custom — port del `ACBackBar` del JSX. Back square + título +
/// brand chip + ⚙.
class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.state});
  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    final card = state.card;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _SquareIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: card == null
                ? const Text(
                    'Tarjeta',
                    style: TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.17,
                      color: FzColors.text,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          card.name,
                          style: const TextStyle(
                            fontFamily: FzType.sans,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.17,
                            color: FzColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (card.brand != null) ...[
                        const SizedBox(width: 8),
                        _BrandChip(brand: card.brand!),
                      ],
                    ],
                  ),
          ),
          if (card != null)
            _SquareIconButton(
              icon: Icons.settings_outlined,
              iconColor: FzColors.textDim,
              onPressed: () => _editCard(context, card.id),
            ),
        ],
      ),
    );
  }

  Future<void> _editCard(BuildContext context, String cardId) async {
    final bloc = context.read<CardDetailBloc>();
    final result = await context.push<bool>('/cards/$cardId/edit');
    if (result == true) {
      bloc.add(const CardDetailRefreshRequested());
    }
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = FzColors.text,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: FzColors.border),
            borderRadius: BorderRadius.circular(FzRadius.md),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.brand});
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (brand) {
      CardBrand.visa => ('VISA', FzColors.visaBg),
      CardBrand.mastercard => ('Mastercard', FzColors.mastercardBg),
      CardBrand.amex => ('AMEX', FzColors.mpBg),
      CardBrand.other => ('Otra', FzColors.cardHi),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: FzType.sans,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
        ),
      ),
    );
  }
}

/// Hero card grande con halo radial verde si está pagada.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state});
  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final card = state.card;
    if (summary == null || card == null) return const SizedBox.shrink();

    final paid = state.isPaid;
    final amount = paid && state.payment?.amountReal != null
        ? state.payment!.amountReal!
        : summary.total;

    final breakdownParts = <String>[];
    if (summary.installmentsCount > 0) {
      breakdownParts.add(
        '${summary.installmentsCount} ${summary.installmentsCount == 1 ? "cuota" : "cuotas"}',
      );
    }
    if (summary.autoDebitsCount > 0) {
      breakdownParts.add(
        '${summary.autoDebitsCount} ${summary.autoDebitsCount == 1 ? "débito automático" : "débitos automáticos"}',
      );
    }
    if (card.dueDay != null) {
      breakdownParts.add('vence ${card.dueDay}');
    }
    final breakdown = breakdownParts.isEmpty
        ? 'Sin cargos este mes'
        : breakdownParts.join(' · ');

    final url = card.url;

    return Container(
      decoration: BoxDecoration(
        color: paid ? FzColors.cardPaid : FzColors.card,
          borderRadius: BorderRadius.circular(FzRadius.xxxl),
          border: Border.all(
            color: paid ? FzColors.borderPaid : FzColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (paid) const _GreenHalo(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (paid)
                    const _PaidCaplabel()
                  else
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
                  Text(
                    formatCurrency(amount),
                    style: TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.08,
                      fontFeatures: FzType.tabularNums,
                      color: paid ? FzColors.primaryHi : FzColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    breakdown,
                    style: const TextStyle(
                      fontFamily: FzType.mono,
                      fontSize: 12,
                      color: FzColors.textDim,
                      letterSpacing: 0.24,
                    ),
                  ),
                  if (url != null) ...[
                    const SizedBox(height: 14),
                    _OutlinePillButton(
                      icon: Icons.open_in_new_rounded,
                      label: 'Ir a pagar',
                      borderColor:
                          paid ? FzColors.borderPaid : FzColors.border,
                      onPressed: () => _openUrl(context, url),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el link.')),
        );
      }
    }
  }
}

class _PaidCaplabel extends StatelessWidget {
  const _PaidCaplabel();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.check_rounded, size: 13, color: FzColors.primary),
        SizedBox(width: 6),
        Text(
          'PAGADO',
          style: TextStyle(
            fontFamily: FzType.mono,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.66,
            color: FzColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Halo radial verde decorativo que aparece arriba-derecha del hero
/// pagado.
class _GreenHalo extends StatelessWidget {
  const _GreenHalo();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -50,
      top: -50,
      child: IgnorePointer(
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                FzColors.primary.withValues(alpha: 0.14),
                FzColors.primary.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinePillButton extends StatelessWidget {
  const _OutlinePillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.borderColor = FzColors.border,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(FzRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: FzColors.text),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: FzColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sección "COMPRAS EN CUOTAS" — caplabel + count + "+ Nueva" pill.
class _InstallmentsSection extends StatelessWidget {
  const _InstallmentsSection({required this.state});
  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    final purchases = state.purchases;
    final cardId = state.card?.id;
    if (cardId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: _SectionCaplabel(
                    icon: Icons.credit_card_outlined,
                    title: 'COMPRAS EN CUOTAS',
                    count: purchases.length,
                  ),
                ),
                _NewPill(onPressed: () => _newPurchase(context, cardId)),
              ],
            ),
          ),
          if (purchases.isEmpty)
            const _EmptyDashed(
              message: 'Sin compras en cuotas registradas',
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final p in purchases) ...[
                    _PurchaseTile(
                      data: p,
                      onTap: () =>
                          _editPurchase(context, cardId, p.purchase.id),
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _newPurchase(BuildContext context, String cardId) async {
    final bloc = context.read<CardDetailBloc>();
    final result =
        await context.push<bool>('/cards/$cardId/installments/new');
    if (result == true) {
      bloc.add(const CardDetailRefreshRequested());
    }
  }

  Future<void> _editPurchase(
    BuildContext context,
    String cardId,
    String purchaseId,
  ) async {
    final bloc = context.read<CardDetailBloc>();
    final result =
        await context.push<bool>('/cards/$cardId/installments/$purchaseId');
    if (result == true) {
      bloc.add(const CardDetailRefreshRequested());
    }
  }
}

class _SectionCaplabel extends StatelessWidget {
  const _SectionCaplabel({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: FzColors.textDim),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: FzType.mono,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.1,
            color: FzColors.textDim,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '· $count',
          style: const TextStyle(
            fontFamily: FzType.mono,
            fontSize: 11,
            color: FzColors.textMute,
          ),
        ),
      ],
    );
  }
}

class _NewPill extends StatelessWidget {
  const _NewPill({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FzColors.primarySoft,
      borderRadius: BorderRadius.circular(FzRadius.sm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FzRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: FzColors.borderPaid),
            borderRadius: BorderRadius.circular(FzRadius.sm),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 12, color: FzColors.primary),
              SizedBox(width: 4),
              Text(
                'Nueva',
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: FzColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card vacío con borde dasheado — para "Sin compras en cuotas registradas".
class _EmptyDashed extends StatelessWidget {
  const _EmptyDashed({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 12,
              color: FzColors.textMute,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FzColors.border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(FzRadius.lg),
        ),
      );
    canvas.drawPath(_dashed(path), paint);
  }

  Path _dashed(Path source,
      {double dash = 5, double gap = 4}) {
    final dest = Path();
    for (final m in source.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final s = d;
        final e = (d + dash).clamp(0.0, m.length);
        dest.addPath(m.extractPath(s, e), Offset.zero);
        d += dash + gap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({required this.data, required this.onTap});

  final PurchaseWithStatus data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = data.purchase;
    final thisMonth = data.thisMonthAmount;

    return Material(
      color: FzColors.card,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: FzColors.border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            children: [
              InstallmentProgressTag(
                activeCuotaIndex: data.activeCuotaIndex,
                totalCount: p.installmentCount,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.description,
                      style: const TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: FzColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cuota: ${formatCurrency(p.installmentAmount)}',
                      style: const TextStyle(
                        fontFamily: FzType.mono,
                        fontSize: 10.5,
                        color: FzColors.textMute,
                        letterSpacing: 0.42,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                thisMonth != null ? formatCurrency(thisMonth) : '—',
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: FzType.tabularNums,
                  color: thisMonth == null
                      ? FzColors.textMute
                      : FzColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sección "DÉBITOS AUTOMÁTICOS" — caplabel + lista de bills auto-debit.
class _DebitsSection extends StatelessWidget {
  const _DebitsSection({required this.state});
  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    final bills = state.autoDebitBills;
    if (bills.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _SectionCaplabel(
              icon: Icons.autorenew_rounded,
              title: 'DÉBITOS AUTOMÁTICOS',
              count: bills.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final b in bills) ...[
                  _DebitTile(bill: b),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebitTile extends StatelessWidget {
  const _DebitTile({required this.bill});
  final Bill bill;

  String get _initials {
    final clean = bill.name.trim();
    if (clean.isEmpty) return '··';
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FzColors.card,
        border: Border.all(color: FzColors.border),
        borderRadius: BorderRadius.circular(FzRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: FzColors.cardHi,
              borderRadius: BorderRadius.circular(FzRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: const TextStyle(
                fontFamily: FzType.mono,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: FzColors.textDim,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bill.name,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: FzColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (bill.dayOfMonth != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    'Día ${bill.dayOfMonth}',
                    style: const TextStyle(
                      fontFamily: FzType.mono,
                      fontSize: 10.5,
                      color: FzColors.textMute,
                      letterSpacing: 0.42,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatCurrencyOrVariable(bill.defaultAmount),
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFeatures: FzType.tabularNums,
              color: bill.defaultAmount == null
                  ? FzColors.textDim
                  : FzColors.text,
            ),
          ),
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
            const Icon(Icons.error_outline,
                size: 48, color: FzColors.lateColor),
            const SizedBox(height: 12),
            const Text(
              'No se pudo cargar la tarjeta',
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

/// Shimmer del hero card mientras se cargan los datos por primera vez.
/// Replica el shape del hero (mismo tamaño/padding/radius) para evitar
/// salto al aparecer.
class _HeroShimmer extends StatelessWidget {
  const _HeroShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xxxl),
        border: Border.all(color: FzColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 96, height: 11, radius: 2),
          SizedBox(height: 8),
          ShimmerBox(width: 200, height: 36, radius: 4),
          SizedBox(height: 8),
          ShimmerBox(width: 220, height: 12, radius: 2),
          SizedBox(height: 14),
          ShimmerBox(width: 110, height: 36, radius: 10),
        ],
      ),
    );
  }
}

/// Shimmer del cuerpo (secciones de cuotas + débitos).
class _BodyShimmer extends StatelessWidget {
  const _BodyShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: ShimmerBox(width: 160, height: 11, radius: 2),
        ),
        const _SectionItemShimmer(),
        const SizedBox(height: 6),
        const _SectionItemShimmer(),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: ShimmerBox(width: 180, height: 11, radius: 2),
        ),
        const _SectionItemShimmer(),
        const SizedBox(height: 6),
        const _SectionItemShimmer(),
        const SizedBox(height: 6),
        const _SectionItemShimmer(),
      ],
    );
  }
}

class _SectionItemShimmer extends StatelessWidget {
  const _SectionItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: FzColors.card,
          border: Border.all(color: FzColors.border),
          borderRadius: BorderRadius.circular(FzRadius.lg),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 32, height: 32, radius: 8),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(width: 130, height: 13, radius: 3),
                  SizedBox(height: 5),
                  ShimmerBox(width: 70, height: 10, radius: 2),
                ],
              ),
            ),
            SizedBox(width: 12),
            ShimmerBox(width: 70, height: 13, radius: 3),
          ],
        ),
      ),
    );
  }
}
