import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Global Accents (Dono themes mein same rahenge) ---
  static const Color teal = Color(0xFF06B6D4);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color amber = Color(0xFFFBBF24);

  // --- Dark Mode Colors ---
  static const Color _bgDark = Color(0xFF0A0A0A);
  static const Color _cardDark = Color(0xFF171717); // Boxes aur cards ka color
  static const Color _textDark = Color(0xFFFFFFFF);
  static const Color _borderDark = Color(0x1AFFFFFF); // 10% White border k liye

  // --- Light Mode Colors ---
  static const Color _bgLight = Color(0xFFF8FAFC);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _textLight = Color(0xFF0F172A);
  static const Color _borderLight = Color(0x1A0F172A); // 10% Dark border k liye

  // ==========================================
  // 🌙 DARK THEME SETUP
  // ==========================================
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _bgDark,
    cardColor: _cardDark,
    dividerColor: _borderDark, // Borders k liye use hoga
    hintColor: _textDark.withOpacity(0.5), // Faded text k liye

    // Core Colors
    colorScheme: const ColorScheme.dark(
      primary: teal,
      secondary: violet,
      tertiary: amber,
      surface: _cardDark,
      onSurface: _textDark, // Main Text Color
    ),

    // Default Text Styles
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: _textDark,
      displayColor: _textDark,
    ),

    // App Bar Design
    appBarTheme: const AppBarTheme(
      backgroundColor: _bgDark,
      elevation: 0,
      iconTheme: IconThemeData(color: _textDark),
      titleTextStyle: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.bold),
    ),

    // TextField Design (Ab UI ma lamba code nahi likhna paray ga)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _textDark.withOpacity(0.05),
      hintStyle: TextStyle(color: _textDark.withOpacity(0.3)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: teal),
      ),
    ),
  );

  // ==========================================
  // ☀️ LIGHT THEME SETUP
  // ==========================================
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _bgLight,
    cardColor: _cardLight,
    dividerColor: _borderLight,
    hintColor: _textLight.withOpacity(0.5),

    // Core Colors
    colorScheme: const ColorScheme.light(
      primary: teal,
      secondary: violet,
      tertiary: amber,
      surface: _cardLight,
      onSurface: _textLight, // Main Text Color
    ),

    // Default Text Styles
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: _textLight,
      displayColor: _textLight,
    ),

    // App Bar Design
    appBarTheme: const AppBarTheme(
      backgroundColor: _bgLight,
      elevation: 0,
      iconTheme: IconThemeData(color: _textLight),
      titleTextStyle: TextStyle(color: _textLight, fontSize: 18, fontWeight: FontWeight.bold),
    ),

    // TextField Design
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _textLight.withOpacity(0.05),
      hintStyle: TextStyle(color: _textLight.withOpacity(0.3)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: teal),
      ),
    ),
  );
}