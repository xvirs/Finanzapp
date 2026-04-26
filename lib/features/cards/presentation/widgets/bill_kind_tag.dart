import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../models/enums.dart';

/// Cuadrado neutro 40x40 con el emoji del kind de bill.
class BillKindTag extends StatelessWidget {
  const BillKindTag({required this.kind, super.key});

  final BillKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        kBillKindEmoji[kind] ?? '📌',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
