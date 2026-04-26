import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Tag cuadrado tipo "X/N" si la cuota está activa este mes (verde) o "—"
/// si no (gris). Reproduce el InstallmentProgressTag de la web.
class InstallmentProgressTag extends StatelessWidget {
  const InstallmentProgressTag({
    required this.activeCuotaIndex,
    required this.totalCount,
    super.key,
  });

  final int? activeCuotaIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = activeCuotaIndex != null;

    final bg = isActive
        ? AppColors.urgencyPaidBg
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isActive
        ? AppColors.urgencyPaid
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: 56,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        isActive ? '$activeCuotaIndex/$totalCount' : '—',
        style: TextStyle(
          color: fg,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
