import 'package:flutter/material.dart';

import '../../../../design/tokens.dart';
import '../../../../widgets/shimmer_box.dart';

/// Skeleton/shimmer del header del Mes (compact). Replica la estructura
/// de [MonthHeaderSection]: caplabel · nav · grid de totales · progress
/// · tabs. Se usa en lugar del header real cuando `state.status` está
/// en `loading` / `initial`.
class MonthHeaderShimmer extends StatelessWidget {
  const MonthHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // Caplabel "MES ACTUAL"
          Align(
            alignment: Alignment.centerLeft,
            child: ShimmerBox(width: 90, height: 11, radius: 2),
          ),
          SizedBox(height: 10),
          // Month nav
          Row(
            children: [
              ShimmerBox(width: 28, height: 28, radius: 6),
              Expanded(
                child: Center(
                  child: ShimmerBox(width: 130, height: 19, radius: 4),
                ),
              ),
              ShimmerBox(width: 28, height: 28, radius: 6),
            ],
          ),
          SizedBox(height: 16),
          // Summary grid: ESTIMADO + PAGADO
          Row(
            children: [
              Expanded(child: _SummaryCardShimmer()),
              SizedBox(width: 10),
              Expanded(child: _SummaryCardShimmer(withFooter: true)),
            ],
          ),
          SizedBox(height: 14),
          // Progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 78, height: 11, radius: 2),
              ShimmerBox(width: 28, height: 11, radius: 2),
            ],
          ),
          SizedBox(height: 6),
          ShimmerBox(width: double.infinity, height: 4, radius: 2),
          SizedBox(height: 14),
          // Filter tabs
          Row(
            children: [
              ShimmerBox(width: 56, height: 22, radius: 999),
              SizedBox(width: 6),
              ShimmerBox(width: 84, height: 22, radius: 999),
              SizedBox(width: 6),
              ShimmerBox(width: 78, height: 22, radius: 999),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCardShimmer extends StatelessWidget {
  const _SummaryCardShimmer({this.withFooter = false});

  final bool withFooter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const ShimmerBox(width: 70, height: 11, radius: 2),
          const SizedBox(height: 8),
          const ShimmerBox(width: 110, height: 22, radius: 4),
          if (withFooter) ...[
            const SizedBox(height: 6),
            const ShimmerBox(width: 90, height: 11, radius: 2),
          ],
        ],
      ),
    );
  }
}

/// Skeleton/shimmer para el área de items mientras se cargan los datos
/// del mes. Replica visualmente la estructura de los grupos (header de
/// categoría + cards de pago) con barras animadas.
class MonthShimmer extends StatelessWidget {
  const MonthShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: const [
        _CategoryHeaderShimmer(),
        _ItemShimmer(),
        _ItemShimmer(),
        SizedBox(height: 8),
        _CategoryHeaderShimmer(),
        _ItemShimmer(),
        _ItemShimmer(),
        _ItemShimmer(),
      ],
    );
  }
}

class _CategoryHeaderShimmer extends StatelessWidget {
  const _CategoryHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerBox(width: 110, height: 11, radius: 2),
          ShimmerBox(width: 70, height: 11, radius: 2),
        ],
      ),
    );
  }
}

class _ItemShimmer extends StatelessWidget {
  const _ItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerBox(width: 38, height: 38, radius: 11),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 130, height: 14, radius: 3),
                SizedBox(height: 6),
                ShimmerBox(width: 90, height: 11, radius: 2),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerBox(width: 50, height: 10, radius: 2),
              SizedBox(height: 6),
              ShimmerBox(width: 80, height: 14, radius: 3),
            ],
          ),
        ],
      ),
    );
  }
}
