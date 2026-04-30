// lib/design/theme.dart
//
// ThemeData completo construído sobre los tokens de tokens.dart.
// Llamalo desde MaterialApp:
//   MaterialApp(
//     theme: FzTheme.dark(),       // default
//     darkTheme: FzTheme.dark(),
//     // si querés soportar light:
//     // theme: FzTheme.light(),
//   );

import 'package:flutter/material.dart';
import 'tokens.dart';

class FzTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FzColors.bg,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: FzColors.primary,
        onPrimary: FzColors.primaryInk,
        primaryContainer: FzColors.primarySoft,
        onPrimaryContainer: FzColors.primaryHi,
        secondary: FzColors.primaryHi,
        onSecondary: FzColors.primaryInk,
        error: FzColors.late,
        onError: FzColors.lateInk,
        errorContainer: FzColors.lateSoft,
        surface: FzColors.card,
        onSurface: FzColors.text,
        surfaceContainerHighest: FzColors.cardHi,
        outline: FzColors.border,
        outlineVariant: FzColors.borderHi,
      ),
      textTheme: _textTheme(FzColors.text, FzColors.textDim, FzColors.textMute),

      // Cards
      cardTheme: CardThemeData(
        color: FzColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FzRadius.xxl),
          side: const BorderSide(color: FzColors.border, width: 1),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FzColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: const TextStyle(
          color: FzColors.textMute,
          fontSize: 14,
          fontFamily: FzType.sans,
        ),
        labelStyle: FzText.caplabel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FzRadius.lg),
          borderSide: const BorderSide(color: FzColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FzRadius.lg),
          borderSide: const BorderSide(color: FzColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FzRadius.lg),
          borderSide: const BorderSide(color: FzColors.borderHi, width: 1.5),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FzColors.primary,
          foregroundColor: FzColors.primaryInk,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          textStyle: const TextStyle(
            fontFamily: FzType.sans,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FzColors.text,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: FzColors.border),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          textStyle: const TextStyle(
            fontFamily: FzType.sans,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FzColors.primary,
          textStyle: const TextStyle(
            fontFamily: FzType.sans,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FzColors.bg,
        selectedItemColor: FzColors.primary,
        unselectedItemColor: FzColors.textMute,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: FzColors.border,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : FzColors.textDim,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? FzColors.primary
              : FzColors.cardHi,
        ),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: FzColorsLight.bg,
      colorScheme: const ColorScheme.light(
        primary: FzColorsLight.primary,
        onPrimary: Colors.white,
        primaryContainer: FzColorsLight.primarySoft,
        error: FzColorsLight.late,
        surface: FzColorsLight.card,
        onSurface: FzColorsLight.text,
        outline: FzColorsLight.border,
      ),
      textTheme: _textTheme(
        FzColorsLight.text,
        FzColorsLight.textDim,
        FzColorsLight.textMute,
      ),
    );
  }

  static TextTheme _textTheme(Color text, Color dim, Color mute) {
    TextStyle base(
      double size,
      FontWeight w, {
      double letter = 0,
      Color? color,
      String f = FzType.sans,
    }) => TextStyle(
      fontFamily: f,
      fontSize: size,
      fontWeight: w,
      letterSpacing: letter,
      color: color ?? text,
    );

    return TextTheme(
      displayLarge: base(
        36,
        FontWeight.w600,
        letter: -1.08,
      ).copyWith(fontFeatures: FzType.tabularNums),
      headlineLarge: base(26, FontWeight.w600, letter: -0.65),
      headlineMedium: base(20, FontWeight.w600, letter: -0.4),
      titleLarge: base(17, FontWeight.w600, letter: -0.17),
      titleMedium: base(15, FontWeight.w600),
      bodyLarge: base(14.5, FontWeight.w400),
      bodyMedium: base(14, FontWeight.w400),
      bodySmall: base(12, FontWeight.w400, color: dim),
      labelLarge: base(13, FontWeight.w500),
      labelMedium: base(
        11,
        FontWeight.w500,
        letter: 0.66,
        f: FzType.mono,
        color: mute,
      ),
      labelSmall: base(
        10.5,
        FontWeight.w500,
        letter: 0.84,
        f: FzType.mono,
        color: mute,
      ),
    );
  }
}
