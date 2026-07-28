import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0.0,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height / fontSize,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle displayLarge({Color? color}) => _inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 64,
        letterSpacing: -0.25,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => _inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 52,
        color: color,
      );

  static TextStyle headlineLarge({Color? color}) => _inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40,
        color: color,
      );

  static TextStyle headlineMedium({Color? color}) => _inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36,
        color: color,
      );

  static TextStyle titleLarge({Color? color}) => _inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => _inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24,
        letterSpacing: 0.15,
        color: color,
      );

  static TextStyle bodyLarge({Color? color}) => _inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => _inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20,
        letterSpacing: 0.25,
        color: color,
      );

  static TextStyle labelLarge({Color? color}) => _inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16,
        letterSpacing: 0.5,
        color: color,
      );
}
