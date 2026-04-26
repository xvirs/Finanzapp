import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';

class BrandChip extends StatelessWidget {
  const BrandChip({required this.brand, super.key});

  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    final b = brand;
    if (b == null) return const SizedBox.shrink();

    final color = switch (b) {
      CardBrand.visa => AppColors.brandVisa,
      CardBrand.mastercard => AppColors.brandMastercard,
      CardBrand.amex => AppColors.brandAmex,
      CardBrand.other => AppColors.brandOther,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        kCardBrandLabels[b]!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
