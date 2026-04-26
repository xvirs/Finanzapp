import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format.dart';
import '../../../models/bill.dart';
import '../../month/presentation/widgets/brand_chip.dart';
import 'bloc/card_detail_bloc.dart';
import 'widgets/bill_kind_tag.dart';
import 'widgets/installment_progress_tag.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardDetailBloc, CardDetailBlocState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: state.card == null
                ? const Text('Tarjeta')
                : Row(
                    children: [
                      Flexible(
                        child: Text(
                          state.card!.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (state.card!.brand != null) ...[
                        const SizedBox(width: 8),
                        BrandChip(brand: state.card!.brand),
                      ],
                    ],
                  ),
            actions: [
              if (state.card != null)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Editar tarjeta',
                  onPressed: () => _editCard(context, state.card!.id),
                ),
            ],
          ),
          body: switch (state.status) {
            CardDetailStatus.initial ||
            CardDetailStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            CardDetailStatus.failure => _ErrorView(
                message: state.errorMessage ?? 'Error',
                onRetry: () => context
                    .read<CardDetailBloc>()
                    .add(const CardDetailRefreshRequested()),
              ),
            CardDetailStatus.success => RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<CardDetailBloc>()
                      .add(const CardDetailRefreshRequested());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _SummaryBlock(state: state),
                    const SizedBox(height: 16),
                    _InstallmentsSection(state: state),
                    const SizedBox(height: 8),
                    _AutoDebitsSection(state: state),
                  ],
                ),
              ),
          },
        );
      },
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

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.state});

  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = state.summary;
    final card = state.card;
    if (summary == null || card == null) return const SizedBox.shrink();

    final paid = state.isPaid;
    final amount = paid && state.payment?.amountReal != null
        ? state.payment!.amountReal!
        : summary.total;

    final breakdown = <String>[];
    if (summary.installmentsCount > 0) {
      breakdown.add(
        '${summary.installmentsCount} ${summary.installmentsCount == 1 ? "cuota" : "cuotas"}',
      );
    }
    if (summary.autoDebitsCount > 0) {
      breakdown.add(
        '${summary.autoDebitsCount} ${summary.autoDebitsCount == 1 ? "déb. aut." : "débs. aut."}',
      );
    }
    final breakdownText =
        breakdown.isEmpty ? 'Sin cargos este mes' : breakdown.join(' · ');

    final url = card.url;

    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paid ? 'Pagado' : 'Total del mes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatCurrency(amount),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: paid ? theme.colorScheme.primary : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            breakdownText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (url != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openUrl(context, url),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Ir a pagar'),
            ),
          ],
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

class _InstallmentsSection extends StatelessWidget {
  const _InstallmentsSection({required this.state});

  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final purchases = state.purchases;
    final cardId = state.card?.id;
    if (cardId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                const Text('💳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'COMPRAS EN CUOTAS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${purchases.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _newPurchase(context, cardId),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nueva'),
                ),
              ],
            ),
          ),
          if (purchases.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text(
                'Sin compras en cuotas registradas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...purchases.map(
              (p) => _PurchaseTile(
                data: p,
                onTap: () => _editPurchase(context, cardId, p.purchase.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _newPurchase(BuildContext context, String cardId) async {
    final bloc = context.read<CardDetailBloc>();
    final result = await context.push<bool>('/cards/$cardId/installments/new');
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

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({required this.data, required this.onTap});

  final PurchaseWithStatus data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = data.purchase;
    final thisMonth = data.thisMonthAmount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cuota: ${formatCurrency(p.installmentAmount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                thisMonth != null ? formatCurrency(thisMonth) : '—',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: thisMonth == null
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoDebitsSection extends StatelessWidget {
  const _AutoDebitsSection({required this.state});

  final CardDetailBlocState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bills = state.autoDebitBills;
    if (bills.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                const Text('🔁', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'DÉBITOS AUTOMÁTICOS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${bills.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ...bills.map((b) => _AutoDebitTile(bill: b)),
        ],
      ),
    );
  }
}

class _AutoDebitTile extends StatelessWidget {
  const _AutoDebitTile({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Edición de cuentas fijas disponible en próxima etapa',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              BillKindTag(kind: bill.kind),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bill.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bill.dayOfMonth != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Día ${bill.dayOfMonth}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatCurrencyOrVariable(bill.defaultAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'No se pudo cargar la tarjeta',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
