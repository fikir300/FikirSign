import 'package:flutter/material.dart';

class AppTheme {
  // Brand Palette: Light Orange, Olive, Black, Warm Paper
  static const Color lightOrange = Color(0xFFE07A5F);
  static const Color lightOrangeSoft = Color(0xFFF4A261);
  static const Color olive = Color(0xFF588157);
  static const Color oliveDark = Color(0xFF385E38);
  static const Color oliveLight = Color(0xFFEBF1EB);

  // Dark Mode (Deep Black Obsidian)
  static const Color darkBg = Color(0xFF111215);
  static const Color darkSurface = Color(0xFF181A20);
  static const Color darkCard = Color(0xFF20232B);
  static const Color darkBorder = Color(0xFF2C303B);

  // Light Mode (Warm Claude Paper)
  static const Color lightBg = Color(0xFFFAF8F5);
  static const Color lightSurface = Color(0xFFF2EFE9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4DFD5);

  // Dark Theme Data
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: lightOrange,
    colorScheme: const ColorScheme.dark(
      primary: lightOrange,
      secondary: olive,
      surface: darkSurface,
    ),
    cardColor: darkCard,
    dividerColor: darkBorder,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );

  // Light Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: lightOrange,
    colorScheme: const ColorScheme.light(
      primary: lightOrange,
      secondary: olive,
      surface: lightSurface,
    ),
    cardColor: lightCard,
    dividerColor: lightBorder,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}