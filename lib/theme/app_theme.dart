import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  // New color palette from prompt
  static const Color primary = Color(0xFF2F3FAF); // Primary Blue
  static const Color accent = Color(0xFFFDB913); // Accent Gold/Yellow
  static const Color background = Color(0xFFF4F6FB); // Light Background
  static const Color card = Color(0xFFFFFFFF); // White Card
  static const Color textPrimary = Color(0xFF1A1A1A); // Text Primary
  static const Color textSecondary = Color(0xFF6B7280); // Text Secondary

  static final ColorScheme _lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: Colors.white, // Text on primary buttons
        secondary: accent, // Used for accent elements
        onSecondary: textPrimary,
        surface: card, // Card background
        onSurface: textPrimary,
        error: Colors.red.shade700,
      );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme()).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: background,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      floatingLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
      prefixIconColor: primary,
      counterStyle: TextStyle(color: textSecondary.withOpacity(0.8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primary.withOpacity(0.6),
        disabledForegroundColor: Colors.white.withOpacity(0.7),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 2,
        shadowColor: primary.withOpacity(0.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primary,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
  );

  static InputDecoration getFilledInputDecoration({
    String? label,
    String? hintText,
    IconData? prefixIcon,
  }) {
    // This helper is needed for DropdownButtonFormField which doesn't automatically
    // pick up the theme's inputDecorationTheme for all properties.
    return InputDecoration(
      label: label != null ? Text(label) : null,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      floatingLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
      prefixIconColor: primary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.8),
      ),
    );
  }
}
