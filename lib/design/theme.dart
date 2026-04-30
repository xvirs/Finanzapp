// lib/design/theme.dart
//
// ThemeData completo construído sobre los tokens de tokens.dart.
// Tipografía: Inter (sans) y JetBrains Mono (mono) — fallbacks
// documentados en handoff/AGENTS.md mientras Geist/Geist Mono no estén
// en el catálogo de google_fonts.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        error: FzColors.lateColor,
        onError: FzColors.lateInk,
        errorContainer: FzColors.lateSoft,
        surface: FzColors.card,
        onSurface: FzColors.text,
        surfaceContainerHighest: FzColors.cardHi,
        outline: FzColors.border,
        outlineVariant: FzColors.borderHi,
      ),
      textTheme: _textTheme(FzColors.text, FzColors.textDim, FzColors.textMute),
      cardTheme: CardThemeData(
        color: FzColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FzRadius.xxl),
          side: const BorderSide(color: FzColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FzColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.inter(color: FzColors.textMute, fontSize: 14),
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.66,
          color: FzColors.textMute,
        ),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FzColors.primary,
          foregroundColor: FzColors.primaryInk,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FzColors.primary,
          foregroundColor: FzColors.primaryInk,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
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
          textStyle: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FzColors.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FzColors.bg,
        selectedItemColor: FzColors.primary,
        unselectedItemColor: FzColors.textMute,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FzColors.bg,
        indicatorColor: FzColors.primarySoft,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: FzColors.textMute,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: FzColors.border,
        thickness: 1,
        space: 1,
      ),
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
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FzColorsLight.bg,
      colorScheme: const ColorScheme.light(
        primary: FzColorsLight.primary,
        onPrimary: Colors.white,
        primaryContainer: FzColorsLight.primarySoft,
        error: FzColorsLight.lateColor,
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
    final sans = GoogleFonts.interTextTheme().apply(
      bodyColor: text,
      displayColor: text,
    );

    TextStyle s(double size, FontWeight w, {double letter = 0, Color? color}) {
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: w,
        letterSpacing: letter,
        color: color ?? text,
      );
    }

    TextStyle m(double size, FontWeight w, {double letter = 0, Color? color}) {
      return GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: w,
        letterSpacing: letter,
        color: color ?? mute,
      );
    }

    return sans.copyWith(
      displayLarge: s(
        36,
        FontWeight.w600,
        letter: -1.08,
      ).copyWith(fontFeatures: FzType.tabularNums),
      headlineLarge: s(26, FontWeight.w600, letter: -0.65),
      headlineMedium: s(20, FontWeight.w600, letter: -0.4),
      titleLarge: s(17, FontWeight.w600, letter: -0.17),
      titleMedium: s(15, FontWeight.w600),
      bodyLarge: s(14.5, FontWeight.w400),
      bodyMedium: s(14, FontWeight.w400),
      bodySmall: s(12, FontWeight.w400, color: dim),
      labelLarge: s(13, FontWeight.w500),
      labelMedium: m(11, FontWeight.w500, letter: 0.66),
      labelSmall: m(10.5, FontWeight.w500, letter: 0.84),
    );
  }
}
