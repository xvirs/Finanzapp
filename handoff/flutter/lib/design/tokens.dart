// lib/design/tokens.dart
//
// Finanzapp — tokens de diseño (dirección A · Banco premium).
// Fuente de verdad: handoff/design-system.md
// Generado a partir de los archivos JSX en handoff/screens-a*.jsx
//
// Uso:
//   import 'package:finanzapp/design/tokens.dart';
//   Container(color: FzColors.bg, ...)

import 'package:flutter/material.dart';

/// Paleta — modo oscuro (default).
class FzColors {
  // Backgrounds
  static const bg = Color(0xFF0B0F0D);
  static const card = Color(0xFF141B18);
  static const cardHi = Color(0xFF192521);
  static const cardPaid = Color(0xFF0E2018);
  static const cardLate = Color(0xFF23120F);

  // Borders
  static const border = Color(0xFF1F2A26);
  static const borderHi = Color(0xFF2A3833);
  static const borderPaid = Color(0xFF1B3A2A);
  static const borderLate = Color(0xFF3A1813);

  // Text
  static const text = Color(0xFFE8EDEA);
  static const textDim = Color(0xFF8A9590);
  static const textMute = Color(0xFF5C6661);

  // Brand / states
  static const primary = Color(0xFF1FB87A);
  static const primaryHi = Color(0xFF2DD891);
  static const primarySoft = Color(0xFF0E2A1E);
  static const primaryInk = Color(0xFF04130C);

  static const late = Color(0xFFE5604A);
  static const lateSoft = Color(0xFF3A1813);
  static const lateInk = Color(0xFFFF8B72);

  // Card brands (chips)
  static const visaBg = Color(0xFF1A1F71);
  static const mastercardBg = Color(0xFFEB001B);
  static const mpBg = Color(0xFF009EE3);
}

/// Paleta — modo claro.
class FzColorsLight {
  static const bg = Color(0xFFF6F5F1);
  static const card = Color(0xFFFFFFFF);
  static const cardHi = Color(0xFFF0EEE7);
  static const cardPaid = Color(0xFFE8F5EE);
  static const cardLate = Color(0xFFFCEBE6);

  static const border = Color(0xFFE6E2D8);
  static const text = Color(0xFF1A1F1C);
  static const textDim = Color(0xFF5C6661);
  static const textMute = Color(0xFF8A9590);

  static const primary = Color(0xFF0E9F62);
  static const primarySoft = Color(0xFFD7F0E2);
  static const late = Color(0xFFC73A22);
}

/// Espaciado — sistema base 4 px.
class FzSpace {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x11 = 44.0;
  // Específicos
  static const screenPad = 16.0; // padding lateral cards
  static const screenPadLg = 20.0; // padding lateral texto/headers
  static const navBottom = 78.0; // bottom padding for bottom nav
}

/// Radios.
class FzRadius {
  static const xs = 4.0; // badges
  static const sm = 8.0; // tags
  static const md = 10.0; // toolbar buttons
  static const lg = 12.0; // inputs, primary buttons
  static const xl = 14.0; // standard cards
  static const xxl = 16.0; // large cards
  static const xxxl = 18.0; // hero cards
  static const pill = 999.0;
}

/// Tipografía — familias y feature settings.
class FzType {
  static const sans = 'Geist'; // fallback Inter
  static const mono = 'GeistMono'; // fallback JetBrains Mono
  static const tabularNums = [FontFeature.tabularFigures()];
}

/// Tamaños y pesos por rol.
class FzText {
  // display (hero monto)
  static const display = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.08,
    color: FzColors.text,
    fontFeatures: FzType.tabularNums,
  );
  // h1 (título de pantalla)
  static const h1 = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.65,
    color: FzColors.text,
  );
  // h2
  static const h2 = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: FzColors.text,
  );
  // monto en card
  static const amountLg = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    color: FzColors.text,
    fontFeatures: FzType.tabularNums,
  );
  // body
  static const body = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FzColors.text,
    height: 1.4,
  );
  static const bodyM = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FzColors.text,
  );
  static const bodyS = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: FzColors.text,
  );
  // caption
  static const caption = TextStyle(
    fontFamily: FzType.sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: FzColors.textDim,
  );
  // mono (números, fechas)
  static const mono = TextStyle(
    fontFamily: FzType.mono,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.48,
    color: FzColors.textDim,
  );
  // caplabel (uppercase, mono, all-caps)
  static const caplabel = TextStyle(
    fontFamily: FzType.mono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.66,
    color: FzColors.textMute,
  );
}

/// Sombras / elevaciones.
class FzShadow {
  static List<BoxShadow> ctaPrimary = [
    BoxShadow(
      color: FzColors.primary.withOpacity(0.20),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> hero = [
    BoxShadow(
      color: FzColors.primary.withOpacity(0.33),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Duraciones de animación.
class FzMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 320);
  static const easing = Curves.easeOutCubic;
}
