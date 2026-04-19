import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const primary = Color(0xFF6366F1); // Indigo
  static const success = Color(0xFF10B981); // Emerald
  static const danger = Color(0xFFEF4444); // Rose
  static const warning = Color(0xFFF59E0B); // Amber

  // Dark Theme Colors
  static const bgDark = Color(0xFF0B0F1A);
  static const cardDark = Color(0xFF1E293B);

  // Light Theme Colors
  static const bgLight = Color(0xFFF8FAFC);
  static const cardLight = Colors.white;
  static const textLight = Color(0xFF1E293B);

  // --- DARK THEME ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: primary,
    cardColor: cardDark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: cardDark,
      error: danger,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  // --- LIGHT THEME ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    primaryColor: primary,
    cardColor: cardLight,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primary,
      surface: cardLight,
      error: danger,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      bodyLarge: const TextStyle(color: textLight),
      bodyMedium: const TextStyle(color: textLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgLight,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textLight),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
    ),
  );
}
