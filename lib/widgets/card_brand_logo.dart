import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../design/tokens.dart';
import '../models/enums.dart';

/// Logo de marca de tarjeta usando los iconos vectoriales de Font Awesome
/// (cc_visa, cc_mastercard, cc_amex) + un genérico para "Otra"/sin marca.
///
/// Son monocromos: por defecto se pintan en el color de marca cuando tiene
/// buen contraste sobre el fondo oscuro, y en un gris tenue para "Otra".
/// Se puede forzar el color con [color].
class CardBrandLogo extends StatelessWidget {
  const CardBrandLogo({
    required this.brand,
    this.size = 18,
    this.color,
    super.key,
  });

  final CardBrand? brand;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final icon = switch (brand) {
      CardBrand.visa => FontAwesomeIcons.ccVisa,
      CardBrand.mastercard => FontAwesomeIcons.ccMastercard,
      CardBrand.amex => FontAwesomeIcons.ccAmex,
      CardBrand.other || null => FontAwesomeIcons.creditCard,
    };
    return FaIcon(icon, size: size, color: color ?? _defaultColor);
  }

  Color get _defaultColor => switch (brand) {
    // Sobre el fondo oscuro, el azul Visa real queda muy apagado: usamos
    // el texto claro para que el wordmark se lea. Mastercard/Amex sí
    // contrastan bien en su color.
    CardBrand.visa => FzColors.text,
    CardBrand.mastercard => FzColors.mastercardBg,
    CardBrand.amex => FzColors.mpBg,
    CardBrand.other || null => FzColors.textDim,
  };
}
