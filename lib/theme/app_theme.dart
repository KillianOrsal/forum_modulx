import 'package:flutter/material.dart';

class AppTheme {
  // ── Couleurs principales ──
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPurpleLight = Color(0xFFA855F7);
  static const Color primaryPurpleDark = Color(0xFF5B21B6);
  static const Color backgroundDark = Color(0xFF0F0B1A);
  static const Color surfaceDark = Color(0xFF1A1429);
  static const Color cardDark = Color(0xFF241E35);
  static const Color cardHover = Color(0xFF2D2545);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4A9CC);
  static const Color textMuted = Color(0xFF7C7394);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color borderColor = Color(0xFF352F4A);
  static const Color placeholderGrey = Color(0xFF3A3450);

  // ── Dégradés ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryPurpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, Color(0xFF1A0F2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF1A0F2E),
      Color(0xFF2D1B69),
      Color(0xFF1A0F2E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Ombres ──
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> cardHoverShadow = [
    BoxShadow(
      color: primaryPurple.withValues(alpha: 0.3),
      blurRadius: 25,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Bordures arrondies ──
  static BorderRadius cardRadius = BorderRadius.circular(16);
  static BorderRadius chipRadius = BorderRadius.circular(30);
  static BorderRadius buttonRadius = BorderRadius.circular(12);

  // ── ThemeData ──
  static ThemeData get darkTheme {
    const interFont = 'Inter';
    const outfitFont = 'Outfit';

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryPurple,
      fontFamily: interFont,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: primaryPurpleLight,
        surface: surfaceDark,
        error: Color(0xFFEF4444),
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: outfitFont,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1,
        ),
        displayMedium: const TextStyle(
          fontFamily: outfitFont,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: const TextStyle(
          fontFamily: outfitFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontFamily: outfitFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: const TextStyle(
          fontFamily: interFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: const TextStyle(
          fontFamily: interFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontFamily: interFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodyMedium: const TextStyle(
          fontFamily: interFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: const TextStyle(
          fontFamily: interFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: outfitFont,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        hintStyle: const TextStyle(fontFamily: interFont, color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
