import 'package:flutter/material.dart';

import '../../../../domain/urgency.dart';
import '../../../../theme/app_colors.dart';

class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({required this.urgency, super.key});

  final Urgency urgency;

  @override
  Widget build(BuildContext context) {
    return switch (urgency) {
      UrgencyOverdue _ => _Pill(
        label: 'Atrasada',
        fg: AppColors.urgencyOverdue,
        bg: AppColors.urgencyOverdueBg,
      ),
      UrgencyDueSoon(:final daysUntil) => _Pill(
        label: switch (daysUntil) {
          0 => 'Vence hoy',
          1 => 'Mañana',
          _ => 'En $daysUntil días',
        },
        fg: AppColors.urgencyDueSoon,
        bg: AppColors.urgencyDueSoonBg,
      ),
      UrgencyNormal _ => const SizedBox.shrink(),
    };
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.fg, required this.bg});

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
