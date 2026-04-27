import 'package:flutter/material.dart';

import '../../../../design/tokens.dart';
import '../../../../widgets/shimmer_box.dart';

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
