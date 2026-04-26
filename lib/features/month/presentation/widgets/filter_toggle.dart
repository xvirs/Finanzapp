import 'package:flutter/material.dart';

class FilterToggle extends StatelessWidget {
  const FilterToggle({
    required this.paidCount,
    required this.totalCount,
    required this.onlyPending,
    required this.onChanged,
    super.key,
  });

  final int paidCount;
  final int totalCount;
  final bool onlyPending;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '$paidCount/$totalCount pagadas',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          'Solo pendientes',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 6),
        Switch.adaptive(
          value: onlyPending,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
