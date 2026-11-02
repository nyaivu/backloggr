import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF5F5F7);
  static const Color cardPurple = Color(0xFFEADDFF); // "Old friends in Paris"
  static const Color cardGreen = Color(0xFFE4F9C2); // "Honeymoon"
  static const Color cardBlue = Color(0xFFC3F3FA); // "Seoul"
  static const Color cardPeach = Color(0xFFFCE4D6); // "Italy"

  // High contrast UI elements (Buttons, floating nav)
  static const Color uiBlack = Color(0xFF1C1C1E);
  static const Color uiWhite = Colors.white;

  // Typography
  static const Color textPrimary = uiBlack;
  static const Color textSecondary = Color(0xFF757575);
}

class AppLayout {
  // Padding & Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border Radii
  static const double radiusSmall = 12.0; // Small photos
  static const double radiusMedium = 20.0; // Medium elements
  static const double radiusLarge = 32.0; // The main pastel cards

  static final BorderRadius cardBorderRadius = BorderRadius.circular(
    radiusLarge,
  );
  static final BorderRadius imageBorderRadius = BorderRadius.circular(
    radiusMedium,
  );
  static final BorderRadius pillBorderRadius = BorderRadius.circular(50.0);
}
