import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────
  static const Color primary    = Color(0xFFE8590C);
  static const Color primaryDk  = Color(0xFFB8440A);
  static const Color primarySft = Color(0xFFFDEBDF);

  // ── Text / Ink ─────────────────────────────────────────
  static const Color ink        = Color(0xFF1A1A2E);
  static const Color textGrey   = Color(0xFF6B7280);
  static const Color textMid    = Color(0xFF4B5160);
  static const Color muted      = Color(0xFF9CA3AF);

  // ── Surfaces & Borders ─────────────────────────────────
  static const Color surface    = Color(0xFFF8F8F8);
  static const Color card       = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFEEEEEE);
  static const Color inputBdr   = Color(0xFFE5E7EB);
  static const Color listBdr    = Color(0xFFF3F4F6);
  static const Color fill       = Color(0xFFF1EEEA);
  static const Color disabled   = Color(0xFFC7C9D1);

  // ── Semantic ───────────────────────────────────────────
  static const Color error      = Color(0xFFE53935);
  static const Color success    = Color(0xFF2E7D32);
  static const Color warning    = Color(0xFFFB8C00);
  static const Color info       = Color(0xFF1E88E5);

  // ── Semantic backgrounds ───────────────────────────────
  static const Color errorBg    = Color(0xFFFFEBEE);
  static const Color successBg  = Color(0xFFE8F5E9);
  static const Color warningBg  = Color(0xFFFFF3E0);
}

/// Shorthand for Figtree text style — used across all screens.
TextStyle fig(double size, FontWeight w, {Color? c, double? ls}) =>
    GoogleFonts.figtree(fontSize: size, fontWeight: w, color: c, letterSpacing: ls);

/// Format number as "184 500 F" with thin non-breaking space.
String fmtAmount(int n) {
  final s = n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]} ',
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

/// Couleurs dynamiques selon le thème actif — utiliser context.sc, context.cardBg, etc.
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get sc      => isDark ? const Color(0xFF0F0F1A) : AppColors.surface;
  Color get cardBg  => isDark ? const Color(0xFF1A1A2E) : AppColors.card;
  Color get ink     => isDark ? const Color(0xFFEEEEF5) : AppColors.ink;
  Color get textGr  => isDark ? const Color(0xFF9AA0AB) : AppColors.textGrey;
  Color get textMd  => isDark ? const Color(0xFFCBCDD8) : AppColors.textMid;
  Color get mutedC  => isDark ? const Color(0xFF6B7280) : AppColors.muted;
  Color get borderC => isDark ? const Color(0xFF2A2A3E) : AppColors.border;
  Color get fillC   => isDark ? const Color(0xFF252538) : AppColors.fill;
  Color get listBdrC => isDark ? const Color(0xFF1E1E30) : AppColors.listBdr;
}

class AppTheme {
  // ── Direct aliases ─────────────────────────────────────
  static const Color primary   = AppColors.primary;
  static const Color secondary = AppColors.ink;

  // ── Semantic aliases ───────────────────────────────────
  static const Color error     = AppColors.error;
  static const Color success   = AppColors.success;
  static const Color warning   = AppColors.warning;
  static const Color info      = AppColors.info;
  static const Color textGrey  = AppColors.textGrey;
  static const Color textMid   = AppColors.textMid;
  static const Color muted     = AppColors.muted;

  // ── Surface aliases ────────────────────────────────────
  static const Color surface   = AppColors.surface;
  static const Color card      = AppColors.card;
  static const Color border    = AppColors.border;
  static const Color fill      = AppColors.fill;

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: GoogleFonts.figtreeTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      error: AppColors.error,
      surface: const Color(0xFF1A1A2E),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F0F1A),
    textTheme: GoogleFonts.figtreeTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1A1A2E),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A3E)),
      ),
    ),
  );
}