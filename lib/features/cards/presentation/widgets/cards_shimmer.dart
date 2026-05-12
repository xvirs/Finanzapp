import 'package:flutter/material.dart';

import '../../../../design/tokens.dart';
import '../../../../widgets/shimmer_box.dart';

/// Skeleton del header de Tarjetas (compact). Replica el título · fecha
/// · grid 2-col (ESTIMADO / PAGADO).
class CardsHeaderShimmer extends StatelessWidget {
  const CardsHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FzColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBox(width: 130, height: 26, radius: 5),
          SizedBox(height: 6),
          ShimmerBox(width: 110, height: 12, radius: 2),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SummaryCardShimmer()),
              SizedBox(width: 10),
              Expanded(child: _SummaryCardShimmer()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCardShimmer extends StatelessWidget {
  const _SummaryCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 72, height: 10, radius: 2),
          SizedBox(height: 8),
          ShimmerBox(width: 140, height: 22, radius: 4),
        ],
      ),
    );
  }
}

/// Skeleton para la lista de tarjetas mientras carga.
class CardsShimmer extends StatelessWidget {
  const CardsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      children: const [_CardShimmer(), _CardShimmer(), _CardShimmer()],
    );
  }
}

class _CardShimmer extends StatelessWidget {
  const _CardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: FzColors.card,
          borderRadius: BorderRadius.circular(FzRadius.xxl),
          border: Border.all(color: FzColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ShimmerBox(width: 38, height: 38, radius: 10),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 140, height: 14, radius: 3),
                      SizedBox(height: 6),
                      ShimmerBox(width: 90, height: 11, radius: 2),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 130, height: 22, radius: 4),
                ShimmerBox(width: 80, height: 10, radius: 2),
              ],
            ),
            SizedBox(height: 12),
            ShimmerBox(width: double.infinity, height: 36, radius: 10),
          ],
        ),
      ),
    );
  }
}
