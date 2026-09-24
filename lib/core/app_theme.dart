import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary    = Color(0xFFE8590C);
  static const Color primaryDk  = Color(0xFFB8440A);
  static const Color primarySft = Color(0xFFFDEBDF);
  static const Color ink        = Color(0xFF1A1A2E);
  static const Color textGrey   = Color(0xFF6B7280);
  static const Color textMid    = Color(0xFF4B5160);
  static const Color muted      = Color(0xFF9CA3AF);
  static const Color surface    = Color(0xFFF8F8F8);
  static const Color card       = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFEEEEEE);
  static const Color inputBdr   = Color(0xFFE5E7EB);
  static const Color listBdr    = Color(0xFFF3F4F6);
  static const Color fill       = Color(0xFFF1EEEA);
  static const Color disabled   = Color(0xFFC7C9D1);
}

/// Shorthand for Figtree text style — used across all screens.
TextStyle fig(double size, FontWeight w, {Color? c, double? ls}) =>
    GoogleFonts.figtree(fontSize: size, fontWeight: w, color: c, letterSpacing: ls);

/// Format number as "184 500 F" with thin non-breaking space.
String fmtAmount(int n) {
  final s = n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]} ',
  );
  return '$s F';
}

String initials(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();

class AppTheme {
  static const Color primary   = AppColors.primary;
  static const Color secondary = AppColors.ink;

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: GoogleFonts.figtreeTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
