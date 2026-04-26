import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../models/bill.dart';
import '../../cards/presentation/widgets/bill_kind_tag.dart';
import 'bloc/bills_list_bloc.dart';

class BillsListScreen extends StatelessWidget {
  const BillsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas fijas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nueva cuenta fija',
            onPressed: () async {
              final bloc = context.read<BillsListBloc>();
              final result = await context.push<bool>('/config/bills/new');
              if (result == true) {
                bloc.add(const BillsListRefreshRequested());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<BillsListBloc, BillsListBlocState>(
        builder: (context, state) {
          return switch (state.status) {
            BillsListStatus.initial ||
            BillsListStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            BillsListStatus.failure => _ErrorView(
                message: state.errorMessage ?? 'Error',
                onRetry: () => context
                    .read<BillsListBloc>()
                    .add(const BillsListRefreshRequested()),
              ),
            BillsListStatus.success => state.bills.isEmpty
                ? const _EmptyView()
                : RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<BillsListBloc>()
                          .add(const BillsListRefreshRequested());
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.bills.length,
                      itemBuilder: (ctx, i) {
                        final bill = state.bills[i];
                        final autoCard = bill.autoDebitCardId != null
                            ? state.cardsById[bill.autoDebitCardId]
                            : null;
                        return _BillTile(
                          bill: bill,
                          autoDebitCardName: autoCard?.name,
                          onTap: () async {
                            final bloc = ctx.read<BillsListBloc>();
                            final result = await ctx.push<bool>(
                              '/config/bills/${bill.id}',
                            );
                            if (result == true) {
                              bloc.add(const BillsListRefreshRequested());
                            }
                          },
                        );
                      },
                    ),
                  ),
          };
        },
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({
    required this.bill,
    required this.autoDebitCardName,
    required this.onTap,
  });

  final Bill bill;
  final String? autoDebitCardName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final kindLabel = kBillKindLabels[bill.kind] ?? '';
    final subtitle = <String>[];
    subtitle.add(kindLabel);
    if (bill.dayOfMonth != null) subtitle.add('Día ${bill.dayOfMonth}');
    if (autoDebitCardName != null) {
      subtitle.add('💳 $autoDebitCardName');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: bill.active ? 1.0 : 0.5,
                child: BillKindTag(kind: bill.kind),
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: bill.active
                                  ? null
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!bill.active) ...[
                          const SizedBox(width: 8),
                          _InactiveTag(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatCurrencyOrVariable(bill.defaultAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: bill.defaultAmount == null
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

class _InactiveTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Inactiva',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
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
            'No se pudieron cargar las cuentas',
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
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No tenés cuentas fijas',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Tocá "+" arriba para crear una.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
