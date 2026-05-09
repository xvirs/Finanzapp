import 'package:flutter/material.dart';

import '../../../../design/tokens.dart';
import '../../../../widgets/shimmer_box.dart';

/// Skeleton/shimmer del layout expandido del Mes (Fold inner / tablet).
/// Refleja la estructura real: master 320 (header + tabs + lista) +
/// detail (TOTAL DEL MES + Pagado/Atrasado + paneles).
///
/// Las alturas de los `ShimmerBox` están dimensionadas para coincidir
/// con la altura real renderizada del texto (≈ fontSize * 1.2 por
/// el line-height por defecto), no con la fontSize cruda. Si no se
/// hace eso, los placeholders quedan visiblemente más bajos que el
/// contenido real al cargar.
class MonthExpandedShimmer extends StatelessWidget {
  const MonthExpandedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(width: 320, child: _MasterShimmer()),
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
          // Header con flechas + título.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _MonthNavSkeleton(),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 140, height: 27, radius: 5),
                      SizedBox(height: 6),
                      ShimmerBox(width: 170, height: 13, radius: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tabs filter (TODAS / PENDIENTE / ATRASO).
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Row(
              children: const [
                _TabPill(width: 56),
                SizedBox(width: 6),
                _TabPill(width: 84),
                SizedBox(width: 6),
                _TabPill(width: 64),
              ],
            ),
          ),
          // Lista de items.
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (_, __) => const _MasterRowSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavSkeleton extends StatelessWidget {
  const _MonthNavSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        ShimmerBox(width: 36, height: 36, radius: 8),
        Expanded(
          child: Center(child: ShimmerBox(width: 110, height: 13, radius: 2)),
        ),
        ShimmerBox(width: 36, height: 36, radius: 8),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: width, height: 25, radius: 6);
  }
}

class _MasterRowSkeleton extends StatelessWidget {
  const _MasterRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        border: Border.all(color: FzColors.border),
      ),
      child: Row(
        children: const [
          ShimmerBox(width: 8, height: 8, radius: 999),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 130, height: 16, radius: 3),
                SizedBox(height: 4),
                ShimmerBox(width: 90, height: 13, radius: 2),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerBox(width: 78, height: 16, radius: 3),
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
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _TotalCardSkeleton(),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StatCardSkeleton()),
              SizedBox(width: 10),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
          SizedBox(height: 14),
          _PanelSkeleton(rows: 3),
          SizedBox(height: 14),
          _PanelSkeleton(rows: 4),
        ],
      ),
    );
  }
}

class _TotalCardSkeleton extends StatelessWidget {
  const _TotalCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 110, height: 13, radius: 2),
              ShimmerBox(width: 36, height: 13, radius: 2),
            ],
          ),
          SizedBox(height: 6),
          ShimmerBox(width: 200, height: 33, radius: 4),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 5, radius: 2),
          SizedBox(height: 6),
          ShimmerBox(width: 170, height: 13, radius: 2),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBox(width: 70, height: 12, radius: 2),
          SizedBox(height: 4),
          ShimmerBox(width: 110, height: 21, radius: 3),
          SizedBox(height: 5),
          ShimmerBox(width: 88, height: 12, radius: 2),
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
          // Header del panel: ícono + título + count.
          Row(
            children: const [
              ShimmerBox(width: 14, height: 14, radius: 3),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(width: 160, height: 13, radius: 2)),
              ShimmerBox(width: 22, height: 13, radius: 2),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows; i++) ...[
            Row(
              children: [
                Container(
                  width: 38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: FzColors.cardHi,
                    borderRadius: BorderRadius.circular(FzRadius.sm),
                    border: Border.all(color: FzColors.border),
                  ),
                  child: const ShimmerBox(width: 18, height: 16, radius: 2),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: ShimmerBox(width: double.infinity, height: 16, radius: 3),
                ),
                const SizedBox(width: 8),
                const ShimmerBox(width: 80, height: 15, radius: 3),
              ],
            ),
            if (i < rows - 1)
              const Divider(
                height: 12,
                thickness: 0.5,
                color: FzColors.border,
              ),
          ],
        ],
      ),
    );
  }
}
