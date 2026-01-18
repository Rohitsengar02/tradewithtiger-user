import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Palette inspired by the lavender/soft aesthetic
  static const Color background = Color(0xFFF5F6FA);
  static const Color primaryBlue = Color(0xFF4A68FF);
  static const Color primaryPurple = Color(0xFF907DFF);
  static const Color softRed = Color(0xFFFF6B6B);
  static const Color softPink = Color(0xFFFF85C0);
  static const Color softYellow = Color(0xFFFFD166);

  static const Color textBlack = Color(0xFF2D3142);
  static const Color textGrey = Color(0xFF9EA3B0);
  static const Color surfaceWhite = Colors.white;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryPurple,
      surface: surfaceWhite,
      onPrimary: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          color: textBlack,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textBlack,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: textBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(color: textGrey, fontSize: 14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
