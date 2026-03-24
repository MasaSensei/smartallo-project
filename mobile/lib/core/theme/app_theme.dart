import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF6366F1);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const bgDark = Color(0xFF0B0F1A);
  static const cardDark = Color(0xFF1E293B);

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: bgDark,
    primaryColor: primary,
    cardColor: cardDark,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
