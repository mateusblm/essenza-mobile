import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class EssenzaColors {
  static const background = Color(0xFFF4F2ED);
  static const backgroundMuted = Color(0xFFE7E8E1);
  static const burgundy = Color(0xFF3F5B50);
  static const burgundyDark = Color(0xFF24362F);
  static const gold = Color(0xFFC98662);
  static const ink = Color(0xFF1D2421);
  static const muted = Color(0xFF68716B);
  static const card = Color(0xFFFCFBF8);
  static const border = Color(0xFFD9DDD7);
  static const success = Color(0xFF5D7D66);
  static const warning = Color(0xFFC68A55);
  static const error = Color(0xFFB65E5E);
  static const ocean = gold;
  static const deepOcean = burgundy;
  static const softBackground = background;
  static const warmGray = muted;
  static const darkBackground = Color(0xFF121916);
  static const darkSurface = Color(0xFF1C2521);
  static const darkMuted = Color(0xFFB8C5BD);
  static const darkBorder = Color(0xFF36443D);
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
      primaryContainer: Color(0xFFDCE8E0),
      onPrimaryContainer: EssenzaColors.burgundyDark,
      surfaceContainerHighest: EssenzaColors.backgroundMuted,
      error: EssenzaColors.error,
      outline: EssenzaColors.border,
    );
    final base = GoogleFonts.openSansTextTheme(
      ThemeData.light(useMaterial3: true).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: EssenzaColors.background,
      textTheme: base.copyWith(
        displaySmall: const TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 38,
          height: 1.08,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.ink,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 32,
          height: 1.12,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.ink,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 27,
          height: 1.15,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.ink,
        ),
        headlineSmall: const TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 24,
          height: 1.18,
          fontWeight: FontWeight.w500,
          color: EssenzaColors.ink,
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
          borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EssenzaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EssenzaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
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
    final darkTextTheme = base.textTheme.apply(
      bodyColor: const Color(0xFFF7F4EF),
      displayColor: const Color(0xFFF7F4EF),
    ).copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        color: const Color(0xFFF7F4EF),
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        color: const Color(0xFFF7F4EF),
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        color: const Color(0xFFF7F4EF),
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        color: const Color(0xFFF7F4EF),
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: const Color(0xFFF7F4EF),
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        color: const Color(0xFFF7F4EF),
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: const Color(0xFFF7F4EF),
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: EssenzaColors.darkMuted,
      ),
    );
    const scheme = ColorScheme.dark(
      primary: Color(0xFF9FC5B1),
      onPrimary: Colors.white,
      secondary: EssenzaColors.gold,
      onSecondary: EssenzaColors.ink,
      surface: EssenzaColors.darkSurface,
      onSurface: Color(0xFFF7F4EF),
      onSurfaceVariant: EssenzaColors.darkMuted,
      primaryContainer: Color(0xFF30443B),
      onPrimaryContainer: Color(0xFFE1F2E8),
      surfaceContainerHighest: Color(0xFF2A3530),
      error: EssenzaColors.error,
      outline: EssenzaColors.darkBorder,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: EssenzaColors.darkBackground,
      textTheme: darkTextTheme,
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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: EssenzaColors.darkBorder, width: .7),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: EssenzaColors.darkSurface,
        hintStyle: const TextStyle(color: EssenzaColors.darkMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EssenzaColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9FC5B1), width: 1.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB5D8C5),
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: EssenzaColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF527967),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFB5D8C5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2A3530),
        selectedColor: const Color(0xFF527967),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        labelStyle: const TextStyle(
          color: Color(0xFFF7F4EF),
          fontSize: 13,
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
                ? const Color(0xFFB5D8C5)
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
        color: Color(0xFFB5D8C5),
      ),
    );
  }
}
