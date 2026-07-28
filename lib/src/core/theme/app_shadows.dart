import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> lightSmall = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lightMedium = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lightLarge = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> darkSmall = [
    BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> darkMedium = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> darkLarge = [
    BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static List<BoxShadow> small(Brightness brightness) =>
      brightness == Brightness.light ? lightSmall : darkSmall;

  static List<BoxShadow> medium(Brightness brightness) =>
      brightness == Brightness.light ? lightMedium : darkMedium;

  static List<BoxShadow> large(Brightness brightness) =>
      brightness == Brightness.light ? lightLarge : darkLarge;
}
