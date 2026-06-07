import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../widgets/card_brand_logo.dart';

class BrandChip extends StatelessWidget {
  const BrandChip({required this.brand, super.key});

  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    if (brand == null) return const SizedBox.shrink();
    return CardBrandLogo(brand: brand, size: 20);
  }
}
