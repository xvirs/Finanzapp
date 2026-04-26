import 'package:flutter/material.dart';

import '../../../../domain/urgency.dart';
import '../../../../theme/app_colors.dart';

class CalendarTag extends StatelessWidget {
  const CalendarTag({
    required this.day,
    required this.urgency,
    required this.paid,
    super.key,
  });

  final int? day;
  final Urgency urgency;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: paid
          ? Icon(Icons.check_rounded, size: 22, color: colors.fg)
          : Text(
              day?.toString() ?? '—',
              style: TextStyle(
                color: colors.fg,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  _TagColors _resolveColors(BuildContext context) {
    final theme = Theme.of(context);
    if (paid) {
      return const _TagColors(
        bg: AppColors.urgencyPaidBg,
        fg: AppColors.urgencyPaid,
      );
    }
    return switch (urgency) {
      UrgencyOverdue _ => const _TagColors(
          bg: AppColors.urgencyOverdueBg,
          fg: AppColors.urgencyOverdue,
        ),
      UrgencyDueSoon _ => const _TagColors(
          bg: AppColors.urgencyDueSoonBg,
          fg: AppColors.urgencyDueSoon,
        ),
      UrgencyNormal _ => _TagColors(
          bg: theme.colorScheme.surfaceContainerHighest,
          fg: theme.colorScheme.onSurface,
        ),
    };
  }
}

class _TagColors {
  const _TagColors({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}
