import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - New TUGON Palette
  static const Color brightBlue = Color(0xFF5A84F7);
  static const Color coralRed = Color(0xFFFA485D);
  static const Color goldenYellow = Color(0xFFFFB300);

  // Background & Text
  static const Color white = Color(0xFFFFFFFF);
  static const Color charcoalBlack = Color(0xFF101010);

  // Utility Colors (derived from primaries)
  static const Color lightBlue = Color(0xFFE3EAFF);
  static const Color lightRed = Color(0xFFFFE5E8);
  static const Color lightYellow = Color(0xFFFFF4D6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brightBlue, coralRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [goldenYellow, coralRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy color mappings for backwards compatibility
  @Deprecated('Use brightBlue instead')
  static const Color deepNavy = brightBlue;

  @Deprecated('Use coralRed instead')
  static const Color warmOrange = coralRed;

  @Deprecated('Use white instead')
  static const Color offWhite = white;

  @Deprecated('Use charcoalBlack instead')
  static const Color softBlack = charcoalBlack;
}