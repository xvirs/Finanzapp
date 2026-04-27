import 'package:flutter/widgets.dart';

import '../core/format.dart';

/// Texto de monto que cuenta de forma progresiva entre el valor previo
/// y el nuevo. Usar en headers y montos prominentes para dar feedback
/// "el dato llegó" cuando la pantalla termina de cargar.
///
/// Comportamiento:
/// - Cuando el widget se monta por primera vez con `value = X`, anima
///   de 0 a X (efecto "count up").
/// - Cuando cambia `value` (ej: refresh, cambio de período), anima del
///   valor actual al nuevo (sin volver a 0).
/// - Si `value` no cambia entre rebuilds, no hay animación.
class AnimatedCurrency extends StatelessWidget {
  const AnimatedCurrency({
    required this.value,
    this.style,
    this.textAlign,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final num value;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, val, _) {
        return Text(
          formatCurrency(val),
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}

/// Variante para enteros (ej. count "8/10 pagadas"). Útil cuando
/// querés que la transición de un número entero también se anime.
class AnimatedInt extends StatelessWidget {
  const AnimatedInt({
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, val, _) {
        return Text(val.round().toString(), style: style);
      },
    );
  }
}
