import 'package:flutter/material.dart';

import '../../../../design/tokens.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _ShimmerBox(width: 110, height: 11, radius: 2),
          _ShimmerBox(width: 70, height: 11, radius: 2),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lead 38x38
          const _ShimmerBox(width: 38, height: 38, radius: 11),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                _ShimmerBox(width: 130, height: 14, radius: 3),
                SizedBox(height: 6),
                _ShimmerBox(width: 90, height: 11, radius: 2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: const [
              _ShimmerBox(width: 50, height: 10, radius: 2),
              SizedBox(height: 6),
              _ShimmerBox(width: 80, height: 14, radius: 3),
            ],
          ),
        ],
      ),
    );
  }
}

/// Caja animada con un gradiente que pasa de izquierda a derecha,
/// emulando el shimmer típico (sin paquete extra).
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Mapea el progreso 0..1 a stops [-1, 0, 1] desplazándose.
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(1 + t * 2, 0),
              colors: const [
                FzColors.cardHi,
                FzColors.borderHi,
                FzColors.cardHi,
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        );
      },
    );
  }
}
