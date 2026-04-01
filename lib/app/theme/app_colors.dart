import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Deep forest green (verde bosque profundo)
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF66BB6A);
  static const Color primaryDark = Color(0xFF1B5E20);

  // Secondary - Earthy amber (contraste cálido para CTAs)
  static const Color secondary = Color(0xFFE76F51);

  // Neutrals
  static const Color lavaBlack = Color(0xFF0A1A0E);

  // Conservation status colors
  static const Color statusEX = Color(0xFF000000);
  static const Color statusEW = Color(0xFF542344);
  static const Color statusCR = Color(0xFFCC3333);
  static const Color statusEN = Color(0xFFCC6633);
  static const Color statusVU = Color(0xFFCC9900);
  static const Color statusNT = Color(0xFF006666);
  static const Color statusLC = Color(0xFF009900);
  static const Color statusDD = Color(0xFFD1D1C6);
  static const Color statusNE = Color(0xFFFFFFFF);

  // Light theme surfaces
  static const Color background = Color(0xFFF1F5F1);
  static const Color surface = Color(0xFFFAFCFA);
  static const Color error = Color(0xFFDC3545);

  // Dark theme surfaces - green-tinted blacks (como la imagen)
  static const Color darkBackground = Color(0xFF060E08);
  static const Color darkSurface = Color(0xFF0F1A12);
  static const Color darkCard = Color(0xFF152219);
  static const Color darkBorder = Color(0xFF1E3024);

  // Accent - bright green for interactive elements (como "Read More" en la imagen)
  static const Color accentOrange = Color(0xFF66BB6A);
}
