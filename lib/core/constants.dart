import 'package:flutter/material.dart';

class AppColors {
  // ---------------------------------------------------------------------------
  // Tailwind Gray Palette (Slate / Cool Gray: 50 - 950)
  // ---------------------------------------------------------------------------
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8); // Muted secondary text
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569); // Elevated panel borders
  static const Color gray700 = Color(0xFF334155); // Elevated card surface
  static const Color gray800 = Color(0xFF1E293B); // Deep card surface
  static const Color gray900 = Color(0xFF0F172A); // Dark container surface
  static const Color gray950 = Color(0xFF020617); // Deepest background surface

  // ---------------------------------------------------------------------------
  // Backgrounds & Canvas
  // ---------------------------------------------------------------------------
  static const Color scaffoldBackground = Color(0xFF171A21); // Main dark canvas

  // ---------------------------------------------------------------------------
  // Interactive Accents & CTAs
  // ---------------------------------------------------------------------------
  static const Color steamBlue = Color(0xFF66C0F4); // Links & highlights
  static const Color steamGreen = Color(0xFF5BA32B); // Signature CTA Green
  static const Color steamGreenHi = Color(0xFFA4D007); // High-emphasis lime CTA
  static const Color steamDiscountRed = Color(
    0xFFD94126,
  ); // Sale badge / Error red

  // ---------------------------------------------------------------------------
  // High Contrast UI Elements
  // ---------------------------------------------------------------------------
  static const Color uiBlack = Color(0xFF0E141B); // Top app bar fill
  static const Color uiWhite = Color(0xFFFFFFFF); // High-emphasis iconography

  // ---------------------------------------------------------------------------
  // Typography (WCAG AA compliant)
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFFCCD8E3); // Pale body text
  static const Color textSecondary = gray400; // Muted slate secondary text
  static const Color textAccent = Color(0xFF66C0F4); // Interactive link text
}

class AppLayout {
  // Padding & Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border Radii
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(
    radiusMedium,
  );
  static final BorderRadius imageBorderRadius = BorderRadius.circular(
    radiusSmall,
  );
  static final BorderRadius pillBorderRadius = BorderRadius.circular(4.0);
}
