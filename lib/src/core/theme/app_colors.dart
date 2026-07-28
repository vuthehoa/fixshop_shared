import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE31E24);
  static const Color primaryVariant = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFFFCDD2);
  static const Color accent = Color(0xFFF59E0B);

  // ── Light theme ───────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F3F9);
  static const Color borderLight = Color(0xFFDDE2EE);
  static const Color dividerLight = Color(0xFFE8EBF4);

  static const Color textPrimaryLight = Color(0xFF0D1420);
  static const Color textSecondaryLight = Color(0xFF455078);
  static const Color textHintLight = Color(0xFF8494B8);
  static const Color textDisabledLight = Color(0xFFB0BADA);

  static const Color iconLight = Color(0xFF455078);
  static const Color iconMutedLight = Color(0xFF8494B8);

  static const Color appBarBackgroundLight = Color(0xFFFFFFFF);
  static const Color appBarForegroundLight = Color(0xFF0D1420);

  static const Color navBarBackgroundLight = Color(0xFFFFFFFF);
  static const Color navBarSelectedLight = Color(0xFFE31E24);
  static const Color navBarUnselectedLight = Color(0xFF8494B8);

  static const Color buttonPrimaryLight = Color(0xFFE31E24);
  static const Color buttonPrimaryForegroundLight = Color(0xFFFFFFFF);
  static const Color buttonSecondaryLight = Color(0xFFF1F3F9);
  static const Color buttonSecondaryForegroundLight = Color(0xFF0D1420);

  static const Color inputBackgroundLight = Color(0xFFFFFFFF);
  static const Color inputBorderLight = Color(0xFFDDE2EE);
  static const Color inputFocusBorderLight = Color(0xFFE31E24);
  static const Color inputErrorBorderLight = Color(0xFFDC2626);

  static const Color statusActiveLight = Color(0xFF059669);
  static const Color statusActiveBgLight = Color(0xFFECFDF5);
  static const Color statusWarningLight = Color(0xFFD97706);
  static const Color statusWarningBgLight = Color(0xFFFFFBEB);
  static const Color statusErrorLight = Color(0xFFDC2626);
  static const Color statusErrorBgLight = Color(0xFFFEF2F2);
  static const Color statusInfoLight = Color(0xFF2563EB);
  static const Color statusInfoBgLight = Color(0xFFEFF6FF);

  // ── Dark theme ────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D1420);
  static const Color surfaceDark = Color(0xFF141C2E);
  static const Color surfaceVariantDark = Color(0xFF1B2540);
  static const Color borderDark = Color(0xFF283352);
  static const Color dividerDark = Color(0xFF1F2D47);

  static const Color textPrimaryDark = Color(0xFFECF0FF);
  static const Color textSecondaryDark = Color(0xFF9CAACE);
  static const Color textHintDark = Color(0xFF526080);
  static const Color textDisabledDark = Color(0xFF3A4A6A);

  static const Color iconDark = Color(0xFF9CAACE);
  static const Color iconMutedDark = Color(0xFF526080);

  static const Color appBarBackgroundDark = Color(0xFF141C2E);
  static const Color appBarForegroundDark = Color(0xFFECF0FF);

  static const Color navBarBackgroundDark = Color(0xFF141C2E);
  static const Color navBarSelectedDark = Color(0xFFE31E24);
  static const Color navBarUnselectedDark = Color(0xFF526080);

  static const Color buttonPrimaryDark = Color(0xFFE31E24);
  static const Color buttonPrimaryForegroundDark = Color(0xFFFFFFFF);
  static const Color buttonSecondaryDark = Color(0xFF1B2540);
  static const Color buttonSecondaryForegroundDark = Color(0xFFECF0FF);

  static const Color inputBackgroundDark = Color(0xFF141C2E);
  static const Color inputBorderDark = Color(0xFF283352);
  static const Color inputFocusBorderDark = Color(0xFFE31E24);
  static const Color inputErrorBorderDark = Color(0xFFF87171);

  static const Color statusActiveDark = Color(0xFF34D399);
  static const Color statusActiveBgDark = Color(0x1A34D399);
  static const Color statusWarningDark = Color(0xFFFBBF24);
  static const Color statusWarningBgDark = Color(0x1AFBBF24);
  static const Color statusErrorDark = Color(0xFFF87171);
  static const Color statusErrorBgDark = Color(0x1AF87171);
  static const Color statusInfoDark = Color(0xFF60A5FA);
  static const Color statusInfoBgDark = Color(0x1A60A5FA);

  // ── Semantic helpers (brightness-aware) ───────────────────────────────────
  static Color background(Brightness brightness) =>
      brightness == Brightness.light ? backgroundLight : backgroundDark;

  static Color surface(Brightness brightness) =>
      brightness == Brightness.light ? surfaceLight : surfaceDark;

  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.light ? textPrimaryLight : textPrimaryDark;

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.light ? textSecondaryLight : textSecondaryDark;

  static Color border(Brightness brightness) =>
      brightness == Brightness.light ? borderLight : borderDark;
}
