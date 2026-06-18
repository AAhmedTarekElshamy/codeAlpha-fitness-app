import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FitnessTheme {
  // Brand Colors
  static const Color background = Color(0xFF080C14);
  static const Color surface = Color(0xFF111827);
  static const Color cardBg = Color(0xFF1F2937);
  static const Color cardBorder = Color(0xFF374151);

  static const Color primary = Color(0xFFADFF2F); // Neon Green / Volt
  static const Color steps = Color(0xFFADFF2F);
  static const Color calories = Color(0xFFFF5722); // Vibrant Coral Orange
  static const Color water = Color(0xFF00E5FF); // Electric Cyan
  static const Color workout = Color(0xFFD000FF); // Purple Accent

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF); // slate-400
  static const Color textMuted = Color(0xFF6B7280); // slate-500

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1.5),
        ),
      ),

      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        bodyLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 14,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),

      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: water,
        surface: cardBg,
        error: Color(0xFFEF4444),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: cardBorder,
        thumbColor: primary,
        overlayColor: primary.withAlpha(51),
        valueIndicatorColor: cardBg,
        valueIndicatorTextStyle: const TextStyle(color: textPrimary),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
