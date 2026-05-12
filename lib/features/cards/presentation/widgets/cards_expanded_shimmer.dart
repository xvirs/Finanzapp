import 'package:flutter/material.dart';

import '../../../../design/tokens.dart';
import '../../../../widgets/shimmer_box.dart';

/// Skeleton/shimmer del layout expandido de Tarjetas (Fold inner /
/// tablet). Refleja la estructura real: master 340 (header + lista de
/// mini-tarjetas) + detail (hero + paneles + CTA).
class CardsExpandedShimmer extends StatelessWidget {
  const CardsExpandedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(width: 340, child: _MasterShimmer()),
        Expanded(child: _DetailShimmer()),
      ],
    );
  }
}

// ============================================================
//  MASTER
// ============================================================

class _MasterShimmer extends StatelessWidget {
  const _MasterShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: FzColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 96, height: 11, radius: 2),
                SizedBox(height: 8),
                ShimmerBox(width: 120, height: 22, radius: 4),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _MasterTotalSkeleton()),
                    SizedBox(width: 8),
                    Expanded(child: _MasterTotalSkeleton()),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => const _MasterRowSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterTotalSkeleton extends StatelessWidget {
  const _MasterTotalSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        border: Border.all(color: FzColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 60, height: 9, radius: 2),
          SizedBox(height: 6),
          ShimmerBox(width: 90, height: 14, radius: 3),
        ],
      ),
    );
  }
}

class _MasterRowSkeleton extends StatelessWidget {
  const _MasterRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 38, height: 26, radius: 6),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerBox(width: 40, height: 9, radius: 2),
                  SizedBox(height: 4),
                  ShimmerBox(width: 70, height: 14, radius: 3),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          ShimmerBox(width: 150, height: 14, radius: 3),
          SizedBox(height: 4),
          ShimmerBox(width: 100, height: 10, radius: 2),
        ],
      ),
    );
  }
}

// ============================================================
//  DETAIL
// ============================================================

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _HeroSkeleton(),
          SizedBox(height: 12),
          _PanelSkeleton(rows: 2),
          SizedBox(height: 12),
          _PanelSkeleton(rows: 3),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 44, radius: 12),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xxl),
        border: Border.all(color: FzColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          ShimmerBox(width: 38, height: 26, radius: 6),
          SizedBox(height: 12),
          ShimmerBox(width: 200, height: 27, radius: 5),
          SizedBox(height: 6),
          ShimmerBox(width: 170, height: 13, radius: 2),
          SizedBox(height: 14),
          Row(
            children: [
              ShimmerBox(width: 60, height: 12, radius: 2),
              Spacer(),
              ShimmerBox(width: 160, height: 32, radius: 5),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelSkeleton extends StatelessWidget {
  const _PanelSkeleton({required this.rows});

  final int rows;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              ShimmerBox(width: 14, height: 14, radius: 3),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(width: 140, height: 11, radius: 2)),
              ShimmerBox(width: 18, height: 11, radius: 2),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 160, height: 13, radius: 3),
                      SizedBox(height: 6),
                      ShimmerBox(width: 90, height: 11, radius: 2),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const ShimmerBox(width: 70, height: 14, radius: 3),
              ],
            ),
            if (i < rows - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
