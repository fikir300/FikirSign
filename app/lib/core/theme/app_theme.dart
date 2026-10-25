import 'package:flutter/material.dart';

/// App theme configurations providing standard light and high-contrast modes
/// with enlarged text typography optimized for hospital environments and accessibility.
class AppTheme {
  AppTheme._();

  // Color tokens - Light Theme
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color secondaryTeal = Color(0xFF00796B);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Color tokens - High-Contrast Theme
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF121212);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcYellow = Color(0xFFFFD600);
  static const Color hcCyan = Color(0xFF00E5FF);

  /// Standard Light Theme with enlarged readable typography.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: surfaceLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// High-Contrast Theme with extreme contrast and large text for accessibility.
  static ThemeData get highContrastTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: hcYellow,
        secondary: hcCyan,
        surface: hcSurface,
        onSurface: hcText,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      ),
      scaffoldBackgroundColor: hcBackground,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: hcYellow,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: hcText,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: hcText,
        ),
        bodyLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: hcText,
        ),
        bodyMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: hcText,
        ),
        labelLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: hcYellow,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: hcBackground,
        foregroundColor: hcYellow,
        centerTitle: true,
        elevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: hcYellow,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hcYellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
