import 'package:flutter/material.dart';

abstract final class EssenzaColors {
  static const ocean = Color(0xFF55C9C2);
  static const deepOcean = Color(0xFF176B6D);
  static const softBackground = Color(0xFFF4FAF9);
  static const warmGray = Color(0xFF77736F);
}

abstract final class EssenzaTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: EssenzaColors.deepOcean,
      brightness: Brightness.light,
    ).copyWith(
      primary: EssenzaColors.deepOcean,
      onPrimary: Colors.white,
      secondary: EssenzaColors.ocean,
      onSecondary: EssenzaColors.deepOcean,
      surface: Colors.white,
    );

    final textTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'sans-serif',
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          color: EssenzaColors.deepOcean,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          color: EssenzaColors.deepOcean,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: EssenzaColors.deepOcean,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: EssenzaColors.warmGray,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: EssenzaColors.deepOcean,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: EssenzaColors.ocean.withValues(alpha: 0.18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: EssenzaColors.ocean.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: EssenzaColors.deepOcean, width: 1.5),
        ),
        labelStyle: const TextStyle(color: EssenzaColors.warmGray),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: EssenzaColors.deepOcean),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: EssenzaColors.ocean.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EssenzaColors.deepOcean,
      ),
    );
  }
}
