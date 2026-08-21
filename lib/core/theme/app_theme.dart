import 'package:flutter/material.dart';

abstract final class EssenzaColors {
  static const background = Color(0xFFF7F4EF);
  static const backgroundMuted = Color(0xFFEEE8DF);
  static const burgundy = Color(0xFF681E2B);
  static const burgundyDark = Color(0xFF42141D);
  static const gold = Color(0xFFB99863);
  static const ink = Color(0xFF211E1D);
  static const muted = Color(0xFF736D68);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFDED8D1);
  static const success = Color(0xFF56705A);
  static const warning = Color(0xFFC38B48);
  static const error = Color(0xFFA44343);
  static const ocean = gold;
  static const deepOcean = burgundy;
  static const softBackground = background;
  static const warmGray = muted;
  static const darkBackground = Color(0xFF171314);
  static const darkSurface = Color(0xFF241C1D);
  static const darkMuted = Color(0xFFC7B9B5);
  static const darkBorder = Color(0xFF49393B);
}

abstract final class EssenzaTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: EssenzaColors.burgundy,
      onPrimary: Colors.white,
      secondary: EssenzaColors.gold,
      onSecondary: EssenzaColors.ink,
      surface: EssenzaColors.card,
      onSurface: EssenzaColors.ink,
      error: EssenzaColors.error,
      outline: EssenzaColors.border,
    );
    final base = ThemeData.light(useMaterial3: true).textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: EssenzaColors.background,
      textTheme: base.copyWith(
        displaySmall: const TextStyle(
          fontFamily: 'serif',
          fontSize: 38,
          height: 1.08,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.burgundyDark,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'serif',
          fontSize: 32,
          height: 1.12,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.burgundyDark,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'serif',
          fontSize: 27,
          height: 1.15,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.burgundyDark,
        ),
        headlineSmall: const TextStyle(
          fontFamily: 'serif',
          fontSize: 24,
          height: 1.18,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.burgundyDark,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: EssenzaColors.ink,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: EssenzaColors.ink,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          height: 1.45,
          color: EssenzaColors.ink,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: EssenzaColors.muted,
        ),
        labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EssenzaColors.background,
        foregroundColor: EssenzaColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: EssenzaColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: EssenzaColors.border, width: .7),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EssenzaColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: const TextStyle(color: EssenzaColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: EssenzaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: EssenzaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: EssenzaColors.burgundy,
            width: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EssenzaColors.burgundy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EssenzaColors.burgundy,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: EssenzaColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: EssenzaColors.backgroundMuted,
        selectedColor: EssenzaColors.burgundy,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        labelStyle: const TextStyle(color: EssenzaColors.ink, fontSize: 13),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: EssenzaColors.card,
        indicatorColor: EssenzaColors.backgroundMuted,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? EssenzaColors.burgundy
                : EssenzaColors.muted,
            size: 23,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            color: s.contains(WidgetState.selected)
                ? EssenzaColors.burgundy
                : EssenzaColors.muted,
            fontSize: 11,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: EssenzaColors.border,
        thickness: .7,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EssenzaColors.burgundy,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: EssenzaColors.burgundyDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData dark() {
    final base = light();
    const scheme = ColorScheme.dark(
      primary: Color(0xFFB9576A),
      onPrimary: Colors.white,
      secondary: EssenzaColors.gold,
      onSecondary: EssenzaColors.ink,
      surface: EssenzaColors.darkSurface,
      onSurface: Color(0xFFF7F4EF),
      error: EssenzaColors.error,
      outline: EssenzaColors.darkBorder,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: EssenzaColors.darkBackground,
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFFF7F4EF),
        displayColor: const Color(0xFFF7F4EF),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EssenzaColors.darkBackground,
        foregroundColor: Color(0xFFF7F4EF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: EssenzaColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: EssenzaColors.darkBorder, width: .7),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: EssenzaColors.darkSurface,
        hintStyle: const TextStyle(color: EssenzaColors.darkMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: EssenzaColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB9576A), width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: EssenzaColors.darkSurface,
        indicatorColor: const Color(0xFF3A292C),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFFE08A98)
                : EssenzaColors.darkMuted,
            size: 23,
          ),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: EssenzaColors.darkMuted, fontSize: 11),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: EssenzaColors.darkBorder,
        thickness: .7,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFE08A98),
      ),
    );
  }
}
