import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Progress bar que llena progresivamente del valor previo al nuevo
/// (no de vacío a lleno de un golpe).
///
/// `value` es 0..1. Por default usa el gradient primary→primaryHi del
/// design system.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    required this.value,
    this.height = 4,
    this.trackColor = FzColors.card,
    this.gradient = const [FzColors.primary, FzColors.primaryHi],
    this.borderRadius,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final double value;
  final double height;
  final Color trackColor;
  final List<Color> gradient;
  final BorderRadius? borderRadius;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(2);
    return ClipRRect(
      borderRadius: radius,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: curve,
        builder: (context, ratio, _) {
          return Container(
            height: height,
            color: trackColor,
            child: ratio <= 0
                ? const SizedBox.shrink()
                : FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
