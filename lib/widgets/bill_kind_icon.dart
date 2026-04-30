import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../models/enums.dart';

/// Container 38x38 con icono Material según el tipo de cuenta fija.
/// Reemplaza al `BillKindTag` viejo que usaba emojis (regla "no emojis
/// en UI" del handoff).
///
/// Mapping a Material icons inspirado en el `CCTypeIcon` del JSX:
///   electricity → bolt   |   water → water_drop
///   gas → local_fire     |   internet → wifi
///   health → hospital    |   tax → account_balance
///   consortium → apartment | subscription → subscriptions
///   rent → home          |   other → label
class BillKindIcon extends StatelessWidget {
  const BillKindIcon({required this.kind, this.size = 38, super.key});

  final BillKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: FzColors.cardHi,
        borderRadius: BorderRadius.circular(FzRadius.md),
        border: Border.all(color: FzColors.border),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconFor(kind),
        size: (size * 0.52).clamp(14.0, 24.0),
        color: FzColors.text,
      ),
    );
  }

  static IconData iconFor(BillKind kind) {
    switch (kind) {
      case BillKind.electricity:
        return Icons.bolt_outlined;
      case BillKind.water:
        return Icons.water_drop_outlined;
      case BillKind.gas:
        return Icons.local_fire_department_outlined;
      case BillKind.internet:
        return Icons.wifi_rounded;
      case BillKind.health:
        return Icons.local_hospital_outlined;
      case BillKind.tax:
        return Icons.account_balance_outlined;
      case BillKind.consortium:
        return Icons.apartment_outlined;
      case BillKind.subscription:
        return Icons.subscriptions_outlined;
      case BillKind.rent:
        return Icons.home_outlined;
      case BillKind.other:
        return Icons.label_outline;
    }
  }
}
